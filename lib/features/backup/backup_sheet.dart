import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/sheet_frame.dart';
import '../../data/backup_codec.dart';
import '../../data/habit_repository.dart';
import '../../domain/clock.dart';
import '../../domain/habit.dart';

/// Offline backup: copy all habits as text, or restore from such text.
/// Pops with the habits that were replaced when a restore happened, so the
/// caller can offer to undo it; pops with null otherwise.
class BackupSheet extends StatefulWidget {
  const BackupSheet({super.key, required this.repository, this.clock = systemClock});

  final HabitRepository repository;
  final Clock clock;

  @override
  State<BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<BackupSheet> {
  final TextEditingController _input = TextEditingController();
  bool _isRestoring = false;
  _Status? _status;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    HapticFeedback.lightImpact();
    final text = BackupCodec.export(widget.repository.habits, now: widget.clock());
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _show(_Status.success('Backup of ${widget.repository.habits.length} habits copied. Paste it somewhere safe.'));
    } on PlatformException {
      _show(const _Status.error('Could not copy to the clipboard. Please try again.'));
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      _show(const _Status.error('The clipboard is empty.'));
      return;
    }
    setState(() => _input.text = text);
  }

  Future<void> _restore() async {
    final ParsedBackup backup;
    try {
      backup = BackupCodec.parse(_input.text, now: widget.clock());
    } on BackupException catch (error) {
      HapticFeedback.heavyImpact();
      _show(_Status.error(error.problem.message));
      return;
    }

    final current = widget.repository.habits.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Replace your habits?'),
        content: Text(
          backup.habits.isEmpty
              ? 'This backup is empty. Restoring it removes all $current of your habits.'
              : 'Your $current habits will be replaced by the ${backup.habits.length} habits in this backup. '
                    'You can undo this right after.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Replace')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final List<Habit> previous = widget.repository.replaceAll(backup.habits);
    Navigator.of(context).pop(previous);
  }

  void _show(_Status status) {
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return SheetFrame(
      horizontalPadding: AppSpacing.p24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: AppSpacing.p8),
              Text('Backup & Restore', style: AppText.sheetTitle),
            ],
          ),
          const SizedBox(height: AppSpacing.p8),
          const Text(
            'Your habits are stored only on this phone. Copy a backup and keep it somewhere safe '
            '(notes, email to yourself); paste it here to restore.',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
          const SizedBox(height: AppSpacing.p16),
          if (status != null) ...[
            _StatusBanner(status: status),
            const SizedBox(height: AppSpacing.p16),
          ],
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Backup'),
            style: _outlinedStyle,
            onPressed: _export,
          ),
          const SizedBox(height: AppSpacing.p8),
          OutlinedButton.icon(
            icon: Icon(_isRestoring ? Icons.close_rounded : Icons.download_rounded, size: 16),
            label: Text(_isRestoring ? 'Cancel Restore' : 'Restore from Backup'),
            style: _outlinedStyle,
            onPressed: () => setState(() => _isRestoring = !_isRestoring),
          ),
          if (_isRestoring) ...[
            const SizedBox(height: AppSpacing.p12),
            TextField(
              controller: _input,
              maxLines: 4,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste your TrackFlow backup here',
                suffixIcon: IconButton(
                  tooltip: 'Paste from clipboard',
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.p8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _restore,
              child: const Text('Restore Habits', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }

  static final ButtonStyle _outlinedStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    minimumSize: const Size.fromHeight(48),
    side: const BorderSide(color: AppColors.cardBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

final class _Status {
  const _Status.success(this.message) : isError = false;
  const _Status.error(this.message) : isError = true;

  final String message;
  final bool isError;
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final _Status status;

  @override
  Widget build(BuildContext context) {
    final color = status.isError ? AppColors.danger : AppColors.primary;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          status.message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}
