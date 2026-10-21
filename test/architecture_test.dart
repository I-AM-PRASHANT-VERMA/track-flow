// Enforces the layer rules in docs/engineering/FILE-ORGANIZATION.md with a
// test, so a forbidden import fails the build instead of relying on review.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _importPattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);

/// Every import of every Dart file under lib/, resolved to a lib-relative path
/// (`domain/day.dart`) or kept as a package/dart URI (`package:flutter/...`).
Map<String, List<String>> _importsByFile() {
  final result = <String, List<String>>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/').substring('lib/'.length);
    final dir = path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '';
    result[path] = [
      for (final match in _importPattern.allMatches(entity.readAsStringSync()))
        _resolve(match.group(1)!, dir),
    ];
  }
  return result;
}

String _resolve(String uri, String fromDir) {
  if (uri.startsWith('package:track_flow/')) return uri.substring('package:track_flow/'.length);
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return uri;
  final parts = [...fromDir.split('/').where((p) => p.isNotEmpty)];
  for (final segment in uri.split('/')) {
    if (segment == '..') {
      parts.removeLast();
    } else if (segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

String _layer(String path) => path.contains('/') ? path.substring(0, path.indexOf('/')) : path;

String? _feature(String path) => path.startsWith('features/') ? path.split('/')[1] : null;

void main() {
  final imports = _importsByFile();

  test('lib/ is organised into the agreed top-level layers only', () {
    final allowed = {'domain', 'data', 'core', 'features', 'app.dart', 'main.dart'};
    expect(imports.keys.map(_layer).toSet().difference(allowed), isEmpty);
  });

  test('domain is pure Dart: no Flutter, no packages, no other layer', () {
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      if (_layer(file) != 'domain') continue;
      for (final uri in uris) {
        final ok = uri.startsWith('dart:') && uri != 'dart:ui' || _layer(uri) == 'domain';
        expect(ok, isTrue, reason: '$file imports $uri');
      }
    }
  });

  test('data depends only on domain (plus Flutter foundation and storage packages)', () {
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      if (_layer(file) != 'data') continue;
      for (final uri in uris) {
        final ok = uri.startsWith('dart:') ||
            uri == 'package:flutter/foundation.dart' ||
            uri.startsWith('package:shared_preferences/') ||
            {'domain', 'data'}.contains(_layer(uri));
        expect(ok, isTrue, reason: '$file imports $uri');
      }
    }
  });

  test('core never depends on data or features', () {
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      if (_layer(file) != 'core') continue;
      for (final uri in uris) {
        expect({'data', 'features'}.contains(_layer(uri)), isFalse, reason: '$file imports $uri');
      }
    }
  });

  test('features use storage only through the repository and backup codec', () {
    const allowedData = {'data/habit_repository.dart', 'data/backup_codec.dart'};
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      if (_layer(file) != 'features') continue;
      for (final uri in uris) {
        expect(uri.startsWith('package:shared_preferences/'), isFalse, reason: '$file imports $uri');
        if (_layer(uri) == 'data') expect(allowedData, contains(uri), reason: '$file imports $uri');
      }
    }
  });

  test('a feature never reaches into another feature, except home composing them', () {
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      final feature = _feature(file);
      if (feature == null || feature == 'home') continue;
      for (final uri in uris) {
        final other = _feature(uri);
        expect(other == null || other == feature, isTrue, reason: '$file imports $uri');
      }
    }
  });

  test('only main.dart chooses the concrete storage implementation', () {
    for (final MapEntry(key: file, value: uris) in imports.entries) {
      if (file == 'main.dart') continue;
      if (_layer(file) == 'data') continue;
      expect(uris, isNot(contains('data/shared_prefs_habit_store.dart')), reason: file);
    }
  });
}
