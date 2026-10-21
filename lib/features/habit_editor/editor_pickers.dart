import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/feedback/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/habit_icons.dart';
import '../../domain/habit.dart';

/// Selected/unselected look shared by every option in the editor.
BoxDecoration _optionDecoration({
  required bool selected,
  Color accent = AppColors.primary,
  double radius = 8,
}) {
  return BoxDecoration(
    color: selected ? accent.withValues(alpha: 0.20) : AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: selected ? accent : AppColors.cardBorder,
      width: selected ? 1.2 : 0.8,
    ),
  );
}

class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HabitIcons.choices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final choice = HabitIcons.choices[index];
          final isSelected = choice.key == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: choice.label,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                Haptics.selection();
                onChanged(choice.key);
              },
              child: Container(
                width: 42,
                decoration: _optionDecoration(
                  selected: isSelected,
                  accent: accent,
                  radius: 10,
                ),
                child: Icon(
                  choice.icon,
                  size: 18,
                  color: isSelected ? accent : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category chips plus a "Custom" chip that opens an inline text field. Text
/// typed there counts as the category even if the user saves without confirming.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.isAddingCustom,
    required this.customController,
    required this.onSelected,
    required this.onStartCustom,
    required this.onConfirmCustom,
    required this.onCancelCustom,
    required this.maxLength,
  });

  final List<String> categories;
  final String selected;
  final bool isAddingCustom;
  final TextEditingController customController;
  final ValueChanged<String> onSelected;
  final VoidCallback onStartCustom;
  final VoidCallback onConfirmCustom;
  final VoidCallback onCancelCustom;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    if (isAddingCustom) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: customController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
              onSubmitted: (_) => onConfirmCustom(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Category name',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Use this category',
            onPressed: onConfirmCustom,
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'Cancel',
            onPressed: onCancelCustom,
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
          ),
        ],
      );
    }

    // Wraps onto more lines instead of scrolling sideways, so every category
    // (and the "Custom" option at the end) is visible without discovering a scroll.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          _Chip(
            label: category,
            selected: category == selected,
            onTap: () {
              Haptics.selection();
              onSelected(category);
            },
          ),
        _Chip(
          label: 'Custom',
          icon: Icons.add_rounded,
          selected: false,
          onTap: onStartCustom,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final chipIcon = icon;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: _optionDecoration(selected: selected),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chipIcon != null) ...[
                Icon(chipIcon, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected || chipIcon != null
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : (chipIcon != null
                            ? AppColors.primary
                            : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeOfDayPicker extends StatelessWidget {
  const TimeOfDayPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HabitTimeOfDay selected;
  final ValueChanged<HabitTimeOfDay> onChanged;

  static const _options = {
    HabitTimeOfDay.morning: ('Morning', Icons.wb_twilight_rounded),
    HabitTimeOfDay.afternoon: ('Afternoon', Icons.wb_sunny_rounded),
    HabitTimeOfDay.evening: ('Evening', Icons.nightlight_round),
    HabitTimeOfDay.anytime: ('Anytime', Icons.all_inclusive_rounded),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final MapEntry(key: time, value: (label, icon))
            in _options.entries) ...[
          if (time != HabitTimeOfDay.morning) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              button: true,
              selected: time == selected,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Haptics.selection();
                  onChanged(time);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: _optionDecoration(selected: time == selected),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: time == selected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: time == selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: time == selected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Yes/no vs. measurable. When [locked] the type cannot change any more,
/// because existing history would be judged against a different rule.
class TypePicker extends StatelessWidget {
  const TypePicker({
    super.key,
    required this.selected,
    required this.locked,
    required this.onChanged,
  });

  final HabitType selected;
  final bool locked;
  final ValueChanged<HabitType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(HabitType type, String title, IconData icon) {
      final isSelected = type == selected;
      final enabled = !locked || isSelected;
      return Expanded(
        child: Semantics(
          button: true,
          selected: isSelected,
          enabled: enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled
                ? () {
                    Haptics.selection();
                    onChanged(type);
                  }
                : null,
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: _optionDecoration(selected: isSelected, radius: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            option(
              HabitType.boolean,
              'Yes / No (1-Tap)',
              Icons.check_circle_outline_rounded,
            ),
            const SizedBox(width: 8),
            option(
              HabitType.measurable,
              'Measurable Target',
              Icons.tune_rounded,
            ),
          ],
        ),
        if (locked)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'The tracking type is fixed once progress has been logged.',
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (index, color) in AppColors.habitPalette.indexed)
          Semantics(
            button: true,
            selected: color.toARGB32() == selected,
            label: 'Colour ${index + 1}',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                Haptics.selection();
                onChanged(color.toARGB32());
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.toARGB32() == selected
                        ? Colors.white
                        : Colors.transparent,
                    width: 2.2,
                  ),
                ),
                child: color.toARGB32() == selected
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
