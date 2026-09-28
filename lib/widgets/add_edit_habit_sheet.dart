import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// Streamlined bottom sheet for adding or editing a habit with zero bloat
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

  final List<String> _commonCategories = [
    'Health',
    'Fitness',
    'Focus',
    'Mindset',
    'Sleep',
    'Wellness',
    'Productivity',
  ];

  final List<String> _popularIcons = ['💧', '🏃', '💻', '📚', '🧘', '📵', '🏋️', '🍎', '✍️', '⚡'];

  @override
  void initState() {
    super.initState();
    final h = widget.initialHabit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _targetController = TextEditingController(text: (h?.targetPerDay ?? 1).toString());
    _unitController = TextEditingController(text: h?.unit ?? 'times');
    _selectedCategory = h?.category ?? 'Health';
    _selectedIcon = h?.iconCode ?? '💧';
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
            const SizedBox(height: 16),

            // Sheet Title
            Text(
              isEditing ? 'Edit Habit / Ritual' : 'New Habit / Ritual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textDarkPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Icon & Title Row
            Row(
              children: [
                // Icon Picker Trigger
                PopupMenuButton<String>(
                  initialValue: _selectedIcon,
                  tooltip: 'Select Icon',
                  itemBuilder: (context) => _popularIcons.map((ico) {
                    return PopupMenuItem(
                      value: ico,
                      child: Text(ico, style: const TextStyle(fontSize: 20)),
                    );
                  }).toList(),
                  onSelected: (ico) => setState(() => _selectedIcon = ico),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(_selectedColor).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(_selectedIcon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title Input
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textDarkPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Habit Title',
                      hintText: 'e.g. Read 20 pages, Hydration',
                      hintStyle: TextStyle(color: isDark ? AppColors.textMuted : Colors.black38),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _commonCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.15)
                              : (isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9)),
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
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primary)
                                : (isDark ? AppColors.textMuted : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Time of Day Selector (Morning, Afternoon, Evening, Anytime)
            Text(
              'RITUAL TIME OF DAY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textMuted : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildTimeChip(HabitTimeOfDay.morning, 'Morning 🌅'),
                const SizedBox(width: 6),
                _buildTimeChip(HabitTimeOfDay.afternoon, 'Afternoon ☀️'),
                const SizedBox(width: 6),
                _buildTimeChip(HabitTimeOfDay.evening, 'Evening 🌙'),
                const SizedBox(width: 6),
                _buildTimeChip(HabitTimeOfDay.anytime, 'Anytime ⚡'),
              ],
            ),

            const SizedBox(height: 16),

            // Tracking Type: Boolean (Yes/No) vs Measurable (Countable)
            Text(
              'TRACKING TYPE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textMuted : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    type: HabitType.boolean,
                    title: 'Yes / No (1-Tap)',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Daily Target',
                        hintText: 'e.g. 8, 20, 90',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Unit Label',
                        hintText: 'glasses, pages, mins',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Color Palette Selector
            Text(
              'ACCENT COLOR GLOW',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textMuted : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppColors.habitPalettes.map((c) {
                final isSelected = _selectedColor == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c.toARGB32()),
                  child: Container(
                    width: 32,
                    height: 32,
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
                                color: c.withValues(alpha: 0.5),
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
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _handleSubmit,
              child: Text(
                isEditing ? 'Save Changes' : 'Create Habit',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(HabitTimeOfDay time, String label) {
    final isSelected = _selectedTimeOfDay == time;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeOfDay = time),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.15)
                : (isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? AppColors.textMuted : Colors.black54),
              ),
            ),
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
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.15)
              : (isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9)),
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
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.primary)
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
