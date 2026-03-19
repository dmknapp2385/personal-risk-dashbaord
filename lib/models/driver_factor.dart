class DriverFactor {
  const DriverFactor({
    required this.label,
    required this.level,
    required this.tabIndex,
  });

  final String label;
  // 0..4 (very low .. very high)
  final int level;
  final int tabIndex;
}

