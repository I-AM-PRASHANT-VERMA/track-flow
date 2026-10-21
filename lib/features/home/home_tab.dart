import 'package:flutter/material.dart';

/// The three views of the home screen.
enum HomeTab {
  flow("Today's Flow", Icons.view_agenda_outlined),
  matrix('7-Day Matrix', Icons.grid_view_rounded),
  heatmap('365-Day Canvas', Icons.calendar_view_month_rounded);

  const HomeTab(this.title, this.icon);

  final String title;
  final IconData icon;
}
