import 'package:flutter/material.dart';

import '../widgets/category_section.dart';

class CreditTab extends StatelessWidget {
  const CreditTab({
    super.key,
    required this.creditLevels,
    required this.onCreditFactorChanged,
  });

  final List<int> creditLevels;
  final void Function(int index, int level) onCreditFactorChanged;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  @override
  Widget build(BuildContext context) {
    const factorLabels = [
      'Debt-to-income',
      'Utilization',
      'Delinquencies',
      'Payment stability',
      'Income stability',
    ];

    return ListView(
      children: [
        CategorySection(
          title: 'Credit risk',
          icon: Icons.account_balance_wallet_outlined,
          factorLabels: factorLabels,
          levels: creditLevels,
          onLevelChanged: onCreditFactorChanged,
          scaleLabels: _scaleLabels,
        ),
      ],
    );
  }
}

