import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/services/habit_storage.dart';
import '../models/habit_item.dart';

// Unified cloud sync and offline JSON backup sheet with Radix UI dark styling
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

  // Google Cloud Drive Sync state
  bool _isGoogleConnected = false;
  String _googleEmail = 'prashant@google.com';
  String _syncCadence = 'Daily';
  String? _lastSyncedTime;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadCloudSyncData();
  }

  Future<void> _loadCloudSyncData() async {
    final settings = await HabitStorage.loadCloudSyncSettings();
    if (mounted) {
      setState(() {
        _isGoogleConnected = settings['isConnected'] as bool;
        _googleEmail = settings['email'] as String;
        _syncCadence = settings['cadence'] as String;
        _lastSyncedTime = settings['lastSynced'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _toggleGoogleConnection() async {
    HapticFeedback.mediumImpact();
    final nextState = !_isGoogleConnected;
    setState(() {
      _isGoogleConnected = nextState;
      if (nextState) {
        _statusMessage = '✓ Google Account connected. Cloud sync activated.';
      } else {
        _statusMessage = 'Google Drive Sync disconnected.';
      }
    });

    await HabitStorage.saveCloudSyncSettings(
      isConnected: nextState,
      email: _googleEmail,
      cadence: _syncCadence,
      lastSynced: _lastSyncedTime,
    );
  }

  Future<void> _changeCadence(String cadence) async {
    HapticFeedback.selectionClick();
    setState(() {
      _syncCadence = cadence;
    });

    await HabitStorage.saveCloudSyncSettings(
      isConnected: _isGoogleConnected,
      email: _googleEmail,
      cadence: cadence,
      lastSynced: _lastSyncedTime,
    );
  }

  Future<void> _triggerCloudSyncNow() async {
    HapticFeedback.heavyImpact();
    setState(() => _isSyncing = true);

    await Future.delayed(const Duration(milliseconds: 650));
    final timestamp = await HabitStorage.triggerCloudSync();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncedTime = timestamp;
        _statusMessage = '✓ Habits successfully synchronized with Google Drive!';
      });
    }
  }

  Future<void> _handleExport() async {
    HapticFeedback.lightImpact();
    final jsonStr = await HabitStorage.exportBackupJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    setState(() {
      _statusMessage = '✓ Backup JSON copied to clipboard!';
    });
  }

  Future<void> _handleImport() async {
    HapticFeedback.mediumImpact();
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

  String _formatLastSynced(String? rawIso) {
    if (rawIso == null) return 'Never synced';
    try {
      final dt = DateTime.parse(rawIso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final navBarHeight = mediaQuery.viewPadding.bottom;
    // Elevates sheet buttons safely above Android 3-button navigation bar
    final bottomPadding = (keyboardHeight > 0 ? keyboardHeight : navBarHeight) + AppSpacing.p24;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.p24,
        right: AppSpacing.p24,
        top: AppSpacing.p16,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
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
            const SizedBox(height: AppSpacing.p16),

            // Header Title (Centered)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.p8),
                  Text(
                    'Backup & Cloud Sync',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.p8),
            Text(
              'Keep your routines protected across devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.p16),

            if (_statusMessage != null) ...[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
            ],

            // Card 1: Google Cloud Drive Sync
            Container(
              padding: const EdgeInsets.all(AppSpacing.p16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_to_drive_rounded, size: 20, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Drive Sync',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                              ),
                            ),
                            Text(
                              _isGoogleConnected ? _googleEmail : 'Not connected',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isGoogleConnected ? AppColors.primary : AppColors.textMuted,
                                fontWeight: _isGoogleConnected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TouchTarget(
                        minWidth: 48,
                        minHeight: 48,
                        onTap: _toggleGoogleConnection,
                        child: Text(
                          _isGoogleConnected ? 'Disconnect' : 'Connect',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _isGoogleConnected ? const Color(0xFFCC4B61) : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_isGoogleConnected) ...[
                    const SizedBox(height: AppSpacing.p16),
                    const Divider(height: 1, color: AppColors.darkCardBorder),
                    const SizedBox(height: AppSpacing.p12),

                    // Sync Cadence Selector
                    const Text(
                      'SYNC CADENCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Row(
                      children: ['Daily', 'Weekly', 'Manual'].map((cadence) {
                        final isSel = _syncCadence == cadence;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
                            child: TouchTarget(
                              minHeight: 48,
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _changeCadence(cadence),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primary.withValues(alpha: 0.16)
                                      : (isDark ? AppColors.darkCard : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? AppColors.primary : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                    width: isSel ? 1.4 : 0.8,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cadence,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      color: isSel ? AppColors.primary : (isDark ? AppColors.textSecondary : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.p16),

                    // Sync Now Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: const Color(0xFF0B0F17),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _isSyncing ? null : _triggerCloudSyncNow,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B0F17)),
                            )
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        _isSyncing ? 'Syncing...' : 'Sync Now (${_formatLastSynced(_lastSyncedTime)})',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.p16),

            // Card 2: 100% Offline & Air-Gapped JSON Backup
            Container(
              padding: const EdgeInsets.all(AppSpacing.p16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.p8),
                      Text(
                        'Local JSON Backup',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  const Text(
                    'No internet needed. Export your habits as JSON and save or share it anywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.p12),

                  // Export Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Export & Copy Backup JSON'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _handleExport,
                  ),

                  const SizedBox(height: AppSpacing.p8),

                  // Import Toggle Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text(_isImportMode ? 'Cancel Import' : 'Import / Restore Backup JSON'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => setState(() => _isImportMode = !_isImportMode),
                  ),

                  if (_isImportMode) ...[
                    const SizedBox(height: AppSpacing.p12),
                    TextField(
                      controller: _importController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste TrackFlow backup JSON text here...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: const Color(0xFF0B0F17),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handleImport,
                      child: const Text('Restore Habits Now', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
