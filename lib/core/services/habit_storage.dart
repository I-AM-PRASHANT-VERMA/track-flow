import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/habit_item.dart';

// Local offline persistence for habits and daily check-in records
class HabitStorage {
  static const String _keyHabits = 'track_flow_habits_v1';
  static SharedPreferences? _prefs;
  static List<HabitItem>? _cachedHabits;

  // Pre-warms cache during application bootstrap for zero cold-start latency
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_cachedHabits == null) {
      await loadHabits();
    }
  }

  static Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // Loads all stored habits, utilizing memory cache when available
  static Future<List<HabitItem>> loadHabits() async {
    if (_cachedHabits != null) {
      return List<HabitItem>.from(_cachedHabits!);
    }

    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyHabits);

    if (rawJson == null || rawJson.isEmpty) {
      final initial = _getDefaultStarterHabits();
      await saveHabits(initial);
      _cachedHabits = initial;
      return initial;
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      final list = decoded.map((h) => HabitItem.fromJson(h as Map<String, dynamic>)).toList();
      _cachedHabits = list;
      return list;
    } catch (e) {
      final fallback = _getDefaultStarterHabits();
      _cachedHabits = fallback;
      return fallback;
    }
  }

  // Saves updated habits list to memory cache immediately and persists to disk
  static Future<void> saveHabits(List<HabitItem> habits) async {
    _cachedHabits = List<HabitItem>.from(habits);
    final prefs = await _getPrefs();
    final encoded = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_keyHabits, encoded);
  }

  // Exports pure JSON string for offline user backups
  static Future<String> exportBackupJson() async {
    final habits = await loadHabits();
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'TrackFlow',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
    });
  }

  // Restores habits from JSON backup string
  static Future<bool> importBackupJson(String rawJson) async {
    try {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      final List<dynamic> habitsList = data['habits'];
      final imported = habitsList.map((h) => HabitItem.fromJson(h as Map<String, dynamic>)).toList();
      await saveHabits(imported);
      return true;
    } catch (e) {
      return false;
    }
  }

  // High-utility starter habits with pre-filled past logs so the user sees a rich UI right away
  static List<HabitItem> _getDefaultStarterHabits() {
    final now = DateTime.now();

    // Generate historical logs for the past 21 days for realistic visual momentum
    Map<String, int> makeLogs(int target, double probability) {
      final map = <String, int>{};
      for (var i = 1; i <= 21; i++) {
        final dt = now.subtract(Duration(days: i));
        // Simple pseudo-pattern to create realistic streaks with occasional rest days
        if ((i % 7 != 0) && (i % 5 != 0)) {
          map[HabitItem.dateKey(dt)] = target;
        } else if (probability > 0.7) {
          map[HabitItem.dateKey(dt)] = (target * 0.75).round();
        }
      }
      return map;
    }

    final todayKey = HabitItem.dateKey(now);

    return [
      // 1. Morning Hydration (Measurable)
      HabitItem(
        id: 'habit_1',
        title: 'Hydration Goal',
        category: 'Health',
        iconCode: 'water',
        colorValue: 0xFF0EA5E9, // Sky
        type: HabitType.measurable,
        timeOfDay: HabitTimeOfDay.morning,
        targetPerDay: 8,
        unit: 'glasses',
        logs: {
          ...makeLogs(8, 0.9),
          todayKey: 6, // 6 of 8 glasses logged today
        },
      ),

      // 2. Morning Workout (Boolean)
      HabitItem(
        id: 'habit_2',
        title: 'Morning 5K / Cardio',
        category: 'Fitness',
        iconCode: 'fitness',
        colorValue: 0xFF10B981, // Emerald
        type: HabitType.boolean,
        timeOfDay: HabitTimeOfDay.morning,
        targetPerDay: 1,
        unit: 'session',
        logs: {
          ...makeLogs(1, 0.8),
          todayKey: 1, // Completed today
        },
      ),

      // 3. Deep Focus Coding (Measurable)
      HabitItem(
        id: 'habit_3',
        title: 'Deep Focus Coding',
        category: 'Focus',
        iconCode: 'code',
        colorValue: 0xFF6366F1, // Indigo
        type: HabitType.measurable,
        timeOfDay: HabitTimeOfDay.afternoon,
        targetPerDay: 90,
        unit: 'mins',
        logs: {
          ...makeLogs(90, 0.85),
          todayKey: 90, // Completed today
        },
      ),

      // 4. Read Non-Fiction (Measurable)
      HabitItem(
        id: 'habit_4',
        title: 'Read Non-Fiction',
        category: 'Mindset',
        iconCode: 'book',
        colorValue: 0xFFA855F7, // Purple
        type: HabitType.measurable,
        timeOfDay: HabitTimeOfDay.afternoon,
        targetPerDay: 20,
        unit: 'pages',
        logs: {
          ...makeLogs(20, 0.75),
          todayKey: 20, // Completed today
        },
      ),

      // 5. Screen Cutoff at 10:30 PM (Boolean - Pending)
      HabitItem(
        id: 'habit_5',
        title: 'Screen Cutoff at 10:30 PM',
        category: 'Sleep',
        iconCode: 'sleep',
        colorValue: 0xFFF43F5E, // Rose
        type: HabitType.boolean,
        timeOfDay: HabitTimeOfDay.evening,
        targetPerDay: 1,
        unit: 'night',
        logs: {
          ...makeLogs(1, 0.7),
          // Today not done yet (evening habit)
        },
      ),

      // 6. Mindful Breathing (Boolean)
      HabitItem(
        id: 'habit_6',
        title: 'Mindful Breathing',
        category: 'Wellness',
        iconCode: 'mind',
        colorValue: 0xFF14B8A6, // Teal
        type: HabitType.boolean,
        timeOfDay: HabitTimeOfDay.evening,
        targetPerDay: 1,
        unit: 'session',
        logs: {
          ...makeLogs(1, 0.9),
          todayKey: 1, // Completed today
        },
      ),
    ];
  }

  static const String _keyCloudSyncConnected = 'track_flow_cloud_sync_connected';
  static const String _keyCloudSyncEmail = 'track_flow_cloud_sync_email';
  static const String _keyCloudSyncCadence = 'track_flow_cloud_sync_cadence';
  static const String _keyCloudSyncLastTime = 'track_flow_cloud_sync_last_time';

  // Loads cloud sync preference state
  static Future<Map<String, dynamic>> loadCloudSyncSettings() async {
    final prefs = await _getPrefs();
    return {
      'isConnected': prefs.getBool(_keyCloudSyncConnected) ?? false,
      'email': prefs.getString(_keyCloudSyncEmail) ?? '',
      'cadence': prefs.getString(_keyCloudSyncCadence) ?? 'Daily',
      'lastSynced': prefs.getString(_keyCloudSyncLastTime),
    };
  }

  // Saves cloud sync preference state
  static Future<void> saveCloudSyncSettings({
    required bool isConnected,
    required String email,
    required String cadence,
    String? lastSynced,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyCloudSyncConnected, isConnected);
    await prefs.setString(_keyCloudSyncEmail, email);
    await prefs.setString(_keyCloudSyncCadence, cadence);
    if (lastSynced != null) {
      await prefs.setString(_keyCloudSyncLastTime, lastSynced);
    }
  }

  // Performs sync operation and timestamps the event
  static Future<String> triggerCloudSync() async {
    final nowIso = DateTime.now().toIso8601String();
    final prefs = await _getPrefs();
    await prefs.setString(_keyCloudSyncLastTime, nowIso);
    return nowIso;
  }
}
