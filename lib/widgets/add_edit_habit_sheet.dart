import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/habit_item.dart';

// Smooth modal bottom sheet for creating or editing habits
class AddEditHabitSheet extends StatefulWidget {
  final HabitItem? initialHabit;
  final ValueChanged<HabitItem> onSave;

  const AddEditHabitSheet({
    super.key,
    this.initialHabit,
    required this.onSave,
  });

  @override
  State<AddEditHabitSheet> createState() => _AddEditHabitSheetState();
}

class _AddEditHabitSheetState extends State<AddEditHabitSheet> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _unitController;
  late String _selectedCategory;
  late String _selectedIcon;
  late int _selectedColor;
  late HabitType _selectedType;
  late HabitTimeOfDay _selectedTimeOfDay;
  late List<int> _scheduledDays;

  late List<String> _commonCategories;
  bool _isAddingCustomCategory = false;
  late TextEditingController _customCategoryController;

  @override
  void initState() {
    super.initState();
    final h = widget.initialHabit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _targetController = TextEditingController(text: (h?.targetPerDay ?? 1).toString());
    _unitController = TextEditingController(text: h?.unit ?? 'times');
    _customCategoryController = TextEditingController();

    _commonCategories = [
      'Productivity',
      'Fitness & Health',
      'Deep Work',
      'Mindset',
      'Learning',
      'Daily Routine',
    ];

    if (h != null && !_commonCategories.contains(h.category)) {
      _commonCategories.add(h.category);
    }

    _selectedCategory = h?.category ?? 'Productivity';
    _selectedIcon = h?.iconCode ?? 'habit';
    _selectedColor = h?.colorValue ?? AppColors.habitPalettes.first.toARGB32();
    _selectedType = h?.type ?? HabitType.boolean;
    _selectedTimeOfDay = h?.timeOfDay ?? HabitTimeOfDay.morning;
    _scheduledDays = h?.scheduledDays != null ? List.from(h!.scheduledDays) : [1, 2, 3, 4, 5, 6, 7];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final target = int.tryParse(_targetController.text.trim()) ?? 1;
    final unit = _unitController.text.trim().isEmpty ? 'times' : _unitController.text.trim();

    final item = HabitItem(
      id: widget.initialHabit?.id ?? 'habit_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: _selectedCategory,
      iconCode: _selectedIcon,
      colorValue: _selectedColor,
      type: _selectedType,
      timeOfDay: _selectedTimeOfDay,
      targetPerDay: _selectedType == HabitType.boolean ? 1 : (target > 0 ? target : 1),
      unit: unit,
      scheduledDays: _scheduledDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : _scheduledDays,
      logs: widget.initialHabit?.logs ?? {},
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialHabit != null;
    final currentColor = Color(_selectedColor);
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final navBarInset = mediaQuery.viewPadding.bottom;

    return Padding(
      // Smoothly lifts by the exact keyboard height without double-padding jumps
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.p16,
          right: AppSpacing.p16,
          top: AppSpacing.p16,
          bottom: navBarInset + AppSpacing.p16,
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
              const SizedBox(height: 14),

              // Sheet Title
              Text(
                isEditing ? 'Edit Habit / Ritual' : 'New Habit / Ritual',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Title Input with active icon indicator
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentColor.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        AppIcons.getIcon(_selectedIcon),
                        size: 22,
                        color: currentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Habit Title',
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        hintText: 'e.g. Morning 5K, Read 20 pages',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: currentColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fast inline icon selector strip (no popup menu, no keyboard dismiss jumps)
              const Text(
                'CHOOSE ICON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppIcons.availableIcons.map((item) {
                    final key = item['key'] as String;
                    final icon = item['icon'] as IconData;
                    final isSel = _selectedIcon == key;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedIcon = key);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSel
                                ? currentColor.withValues(alpha: isDark ? 0.25 : 0.15)
                                : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? currentColor
                                  : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                              width: isSel ? 1.5 : 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 18,
                              color: isSel
                                  ? currentColor
                                  : (isDark ? AppColors.textMuted : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Category Chips
              const Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              if (_isAddingCustomCategory) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customCategoryController,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter category name...',
                          hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                        onSubmitted: (val) {
                          final name = val.trim();
                          if (name.isNotEmpty) {
                            setState(() {
                              if (!_commonCategories.contains(name)) {
                                _commonCategories.add(name);
                              }
                              _selectedCategory = name;
                              _isAddingCustomCategory = false;
                              _customCategoryController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final name = _customCategoryController.text.trim();
                        if (name.isNotEmpty) {
                          setState(() {
                            if (!_commonCategories.contains(name)) {
                              _commonCategories.add(name);
                            }
                            _selectedCategory = name;
                            _isAddingCustomCategory = false;
                            _customCategoryController.clear();
                          });
                        } else {
                          setState(() => _isAddingCustomCategory = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_rounded, size: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _isAddingCustomCategory = false),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._commonCategories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = cat);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12)
                                    : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 1.2 : 0.8,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? AppColors.textPrimary : AppColors.primary)
                                      : (isDark ? AppColors.textMuted : Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // + Custom Category Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _isAddingCustomCategory = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Custom',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Time of Day Selector with clean borders and zero outer glow
              const Text(
                'RITUAL TIME OF DAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTimeChip(HabitTimeOfDay.morning, 'Morning', Icons.wb_twilight_rounded),
                  const SizedBox(width: 8),
                  _buildTimeChip(HabitTimeOfDay.afternoon, 'Afternoon', Icons.wb_sunny_rounded),
                  const SizedBox(width: 8),
                  _buildTimeChip(HabitTimeOfDay.evening, 'Evening', Icons.nightlight_round),
                  const SizedBox(width: 8),
                  _buildTimeChip(HabitTimeOfDay.anytime, 'Anytime', Icons.all_inclusive_rounded),
                ],
              ),

              const SizedBox(height: 14),

              // Tracking Type
              const Text(
                'TRACKING TYPE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      type: HabitType.boolean,
                      title: 'Yes / No (1-Tap)',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton(
                      type: HabitType.measurable,
                      title: 'Measurable Target',
                      icon: Icons.tune_rounded,
                    ),
                  ),
                ],
              ),

              if (_selectedType == HabitType.measurable) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Daily Target',
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          hintText: 'e.g. 8, 20, 90',
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _unitController,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Unit Label',
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          hintText: 'glasses, pages, mins',
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Color Palette Selector
              const Text(
                'ACCENT COLOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: AppColors.habitPalettes.map((c) {
                  final isSelected = _selectedColor == c.toARGB32();
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedColor = c.toARGB32());
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.black)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Save Action Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF0B0F17),
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _handleSubmit,
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(HabitTimeOfDay time, String label, IconData icon) {
    final isSelected = _selectedTimeOfDay == time;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTimeOfDay = time);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12)
                : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.textPrimary : AppColors.primary)
                      : (isDark ? AppColors.textMuted : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required HabitType type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12)
              : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.textPrimary : AppColors.primary)
                      : (isDark ? AppColors.textMuted : Colors.black87),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
