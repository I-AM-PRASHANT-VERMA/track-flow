import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/services/habit_storage.dart';
import '../models/habit_item.dart';

// Offline backup management & privacy verification bottom sheet
class BackupSheet extends StatefulWidget {
  final List<HabitItem> habits;
  final ValueChanged<List<HabitItem>> onHabitsReloaded;

  const BackupSheet({
    super.key,
    required this.habits,
    required this.onHabitsReloaded,
  });

  @override
  State<BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<BackupSheet> {
  final TextEditingController _importController = TextEditingController();
  bool _isImportMode = false;
  String? _statusMessage;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final jsonStr = await HabitStorage.exportBackupJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    setState(() {
      _statusMessage = '✓ Backup JSON copied to clipboard!';
    });
  }

  Future<void> _handleImport() async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) return;

    final success = await HabitStorage.importBackupJson(raw);
    if (success) {
      final updated = await HabitStorage.loadHabits();
      widget.onHabitsReloaded(updated);
      if (mounted) {
        setState(() {
          _statusMessage = '✓ Successfully restored ${updated.length} habits!';
          _isImportMode = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = '⚠️ Invalid backup format. Please check JSON.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBorder : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Privacy & Offline Backups',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textDarkPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'TrackFlow is 100% private. Your data never leaves this phone. No accounts, no background trackers.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Export Button
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Export & Copy Backup JSON'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleExport,
            ),

            const SizedBox(height: 10),

            // Import Toggle Button
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text(_isImportMode ? 'Cancel Import' : 'Import / Restore Backup JSON'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(() => _isImportMode = !_isImportMode),
            ),

            if (_isImportMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _importController,
                maxLines: 4,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Paste TrackFlow backup JSON text here...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleImport,
                child: const Text('Restore Habits Now', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
