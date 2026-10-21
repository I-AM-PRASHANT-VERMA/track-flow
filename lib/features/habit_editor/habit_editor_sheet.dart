import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/feedback/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/habit_icons.dart';
import '../../core/widgets/sheet_frame.dart';
import '../../domain/clock.dart';
import '../../domain/habit.dart';
import 'editor_pickers.dart';
import 'habit_form.dart';

/// Bottom sheet to create a habit or edit one. Pops with the resulting [Habit],
/// or null when dismissed. Editing keeps everything the form does not show
/// (id, creation date, history, archive state).
class HabitEditorSheet extends StatefulWidget {
  const HabitEditorSheet({super.key, this.initial, this.clock = systemClock});

  final Habit? initial;
  final Clock clock;

  @override
  State<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<HabitEditorSheet> {
  static const _defaultCategories = [
    'Productivity',
    'Fitness & Health',
    'Deep Work',
    'Mindset',
    'Learning',
    'Daily Routine',
  ];

  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _unit;
  final TextEditingController _customCategory = TextEditingController();

  late final List<String> _categories;
  late String _category;
  late String _iconKey;
  late int _color;
  late HabitType _type;
  late HabitTimeOfDay _timeOfDay;
  late Set<int> _days;
  bool _isAddingCategory = false;

  String? _titleError;
  String? _targetError;

  bool get _isEditing => widget.initial != null;

  /// Changing the type would re-judge every logged day against a new rule.
  bool get _typeLocked => widget.initial?.logs.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    final habit = widget.initial;
    _title = TextEditingController(text: habit?.title ?? '');
    _target = TextEditingController(text: '${habit?.targetPerDay ?? 1}');
    _unit = TextEditingController(text: habit?.unit ?? 'times');
    _categories = [
      ..._defaultCategories,
      if (habit != null && !_defaultCategories.contains(habit.category))
        habit.category,
    ];
    _category = habit?.category ?? _defaultCategories.first;
    _iconKey = habit?.iconKey ?? 'habit';
    _color = habit?.colorValue ?? AppColors.habitPalette.first.toARGB32();
    _type = habit?.type ?? HabitType.boolean;
    _timeOfDay = habit?.timeOfDay ?? HabitTimeOfDay.morning;
    _days = {...?habit?.scheduledDays};
    if (_days.isEmpty) _days = {...Habit.everyDay};
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _unit.dispose();
    _customCategory.dispose();
    super.dispose();
  }

  void _confirmCustomCategory() {
    final name = _customCategory.text.trim();
    setState(() {
      if (name.isNotEmpty) {
        if (!_categories.contains(name)) _categories.add(name);
        _category = name;
      }
      _customCategory.clear();
      _isAddingCategory = false;
    });
  }

  void _save() {
    // A category typed but not yet confirmed still counts.
    if (_isAddingCategory) _confirmCustomCategory();

    final measurable = _type == HabitType.measurable;
    final titleError = HabitForm.validateTitle(_title.text);
    final targetError = measurable
        ? HabitForm.validateTarget(_target.text)
        : null;
    if (titleError != null || targetError != null) {
      Haptics.heavy();
      setState(() {
        _titleError = titleError;
        _targetError = targetError;
      });
      return;
    }

    final title = _title.text.trim();
    final target = measurable ? int.parse(_target.text.trim()) : 1;
    final unit = measurable ? HabitForm.unitOrDefault(_unit.text) : 'times';
    final initial = widget.initial;

    final habit = initial != null
        ? initial.copyWith(
            title: title,
            category: _category,
            iconKey: _iconKey,
            colorValue: _color,
            type: _type,
            timeOfDay: _timeOfDay,
            targetPerDay: target,
            unit: unit,
            scheduledDays: _days,
          )
        : Habit(
            id: 'habit_${widget.clock().microsecondsSinceEpoch}',
            createdAt: widget.clock(),
            title: title,
            category: _category,
            iconKey: _iconKey,
            colorValue: _color,
            type: _type,
            timeOfDay: _timeOfDay,
            targetPerDay: target,
            unit: unit,
            scheduledDays: _days,
          );
    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.habitColor(_color);

    return SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isEditing ? 'Edit Habit' : 'New Habit',
            style: AppText.sheetTitle,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Icon(HabitIcons.of(_iconKey), size: 22, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(HabitForm.maxTitleLength),
                  ],
                  onChanged: (_) {
                    if (_titleError != null) setState(() => _titleError = null);
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g. Morning 5K, Read 20 pages',
                    errorText: _titleError,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('CHOOSE ICON', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          IconPicker(
            selected: _iconKey,
            accent: accent,
            onChanged: (key) => setState(() => _iconKey = key),
          ),
          const SizedBox(height: 14),
          const Text('CATEGORY', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          CategoryPicker(
            categories: _categories,
            selected: _category,
            isAddingCustom: _isAddingCategory,
            customController: _customCategory,
            maxLength: HabitForm.maxCategoryLength,
            onSelected: (category) => setState(() => _category = category),
            onStartCustom: () => setState(() => _isAddingCategory = true),
            onConfirmCustom: _confirmCustomCategory,
            onCancelCustom: () => setState(() {
              _customCategory.clear();
              _isAddingCategory = false;
            }),
          ),
          const SizedBox(height: 14),
          const Text('TIME OF DAY', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          TimeOfDayPicker(
            selected: _timeOfDay,
            onChanged: (time) => setState(() => _timeOfDay = time),
          ),
          const SizedBox(height: 14),
          const Text('REPEAT ON', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          _DayPicker(
            selected: _days,
            onChanged: (days) => setState(() => _days = days),
          ),
          const SizedBox(height: 14),
          const Text('TRACKING TYPE', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          TypePicker(
            selected: _type,
            locked: _typeLocked,
            onChanged: (type) => setState(() => _type = type),
          ),
          if (_type == HabitType.measurable) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _target,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (_) {
                      if (_targetError != null) {
                        setState(() => _targetError = null);
                      }
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Daily target',
                      hintText: 'e.g. 8, 20, 90',
                      errorText: _targetError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _unit,
                    inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'glasses, pages, mins',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          const Text('ACCENT COLOR', style: AppText.fieldLabel),
          const SizedBox(height: 8),
          ColorPicker(
            selected: _color,
            onChanged: (color) => setState(() => _color = color),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _save,
            child: Text(
              _isEditing ? 'Save Changes' : 'Create Habit',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekday toggles; at least one day always stays selected.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var weekday = 1; weekday <= 7; weekday++)
          Semantics(
            button: true,
            selected: selected.contains(weekday),
            label: _names[weekday - 1],
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                final next = {...selected};
                if (!next.remove(weekday)) next.add(weekday);
                if (next.isEmpty) return;
                Haptics.selection();
                onChanged(next);
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected.contains(weekday)
                      ? AppColors.primary.withValues(alpha: 0.20)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected.contains(weekday)
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: selected.contains(weekday) ? 1.2 : 0.8,
                  ),
                ),
                child: Text(
                  _letters[weekday - 1],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected.contains(weekday)
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
