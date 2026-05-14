import 'package:flutter/material.dart';

import '../../main.dart';

/// Small light/dark theme toggle. Reads + writes the global
/// [RiskDashboardApp.themeMode] notifier so it stays in sync everywhere.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: RiskDashboardApp.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip:
              isDark ? 'Switch to light mode' : 'Switch to dark mode',
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            size: 20,
          ),
          onPressed: () {
            RiskDashboardApp.themeMode.value =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }
}
