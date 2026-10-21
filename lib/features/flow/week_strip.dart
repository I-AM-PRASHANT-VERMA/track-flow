import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';

/// The last seven days ending today; tapping a day toggles it done / not done.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.habit,
    required this.today,
    required this.color,
    required this.onProgress,
  });

  final Habit habit;
  final Day today;
  final Color color;
  final void Function(Day day, int count) onProgress;

  static const _letters = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Row(
        children: [
          // The label only gets the space the seven cells leave; on very narrow
          // screens or with large text it fades instead of pushing cells out.
          const Expanded(
            child: ExcludeSemantics(
              child: Text(
                '7-DAY',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textMuted),
              ),
            ),
          ),
          for (var offset = 6; offset >= 0; offset--) _cell(today.addDays(-offset)),
        ],
      ),
    );
  }

  Widget _cell(Day day) {
    final isToday = day == today;
    final done = habit.isCompletedOn(day);
    final scheduled = habit.isScheduledOn(day);

    final fill = !scheduled
        ? Colors.transparent
        : (done ? color.withValues(alpha: 0.32) : AppColors.cardBorder.withValues(alpha: 0.5));
    final border = isToday
        ? color
        : (!scheduled ? AppColors.cardBorder : (done ? color.withValues(alpha: 0.5) : Colors.transparent));
    final letterColor = !scheduled
        ? AppColors.textFaint
        : (done ? AppColors.textPrimary : AppColors.textMuted);

    final state = done ? 'done' : (scheduled ? 'not done' : 'rest day');
    return Semantics(
      button: true,
      label: '${_names[day.weekday]} ${day.day}, $state',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onProgress(day, done ? 0 : habit.targetPerDay);
        },
        // 30 dp wide x 44 dp tall hit area around a 28 dp visual, so the label
        // and seven cells still fit the 248 dp a card has on a 320 dp screen.
        child: SizedBox(
          width: 30,
          height: 44,
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: border, width: isToday ? 1.5 : 0.8),
              ),
              alignment: Alignment.center,
              child: Text(
                _letters[day.weekday],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: letterColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
