// Coverage ratchet: fails when total line coverage in an lcov file drops below the number in a threshold file.
// Usage: dart run tool/coverage_gate.dart coverage/lcov.info tool/coverage_threshold.txt
import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: coverage_gate <lcov.info> <threshold-file>');
    exit(64);
  }

  final lcov = File(args[0]);
  final thresholdFile = File(args[1]);
  if (!lcov.existsSync() || !thresholdFile.existsSync()) {
    stderr.writeln('missing input: ${lcov.path} or ${thresholdFile.path}');
    exit(66);
  }

  var found = 0;
  var hit = 0;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
  }
  if (found == 0) {
    stderr.writeln('no instrumented lines in ${lcov.path}');
    exit(65);
  }

  final threshold = double.parse(thresholdFile.readAsStringSync().trim());
  final percent = 100 * hit / found;
  stdout.writeln(
    'line coverage: $hit/$found = ${percent.toStringAsFixed(1)}% (required >= $threshold%)',
  );

  if (percent + 1e-9 < threshold) {
    stderr.writeln(
      'FAIL: coverage dropped below the ratchet. Add tests; never lower the threshold to pass.',
    );
    exit(1);
  }
  if (percent >= threshold + 2) {
    stdout.writeln(
      'NOTE: coverage is ${(percent - threshold).toStringAsFixed(1)} points above the ratchet. Raise tool/coverage_threshold.txt to ${percent.floor()}.',
    );
  }
}
