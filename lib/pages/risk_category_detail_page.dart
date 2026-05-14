import 'package:flutter/material.dart';

import 'widgets/theme_toggle_button.dart';

/// Full-screen page for one risk category (pushed on the navigator stack).
class RiskCategoryDetailPage extends StatelessWidget {
  const RiskCategoryDetailPage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(title),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      body: SelectionArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
