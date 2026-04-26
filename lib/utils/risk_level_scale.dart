/// Continuous risk / exposure input (0 = minimal concern, 100 = maximal) until
/// automated signals replace self-report. Engines consume [toNorm] in \[0, 1\].
abstract final class RiskLevelScale {
  static const int max = 100;

  /// Short labels aligned with legacy five-step UI (anchors at 0, 25, 50, 75, 100).
  static const List<String> anchorLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static int clamp(int v) => v.clamp(0, max);

  static double toNorm(int v) => clamp(v) / max;

  /// Band 0..4 for coloring and coarse tags (20-point buckets).
  static int bandIndex(int v) => (clamp(v) / 20).floor().clamp(0, 4);

  static String bandLabel(int v) => anchorLabels[bandIndex(v)];

  /// Preset values for quick jumps (same as old discrete levels).
  static int anchorValue(int bandIndex) =>
      ((bandIndex.clamp(0, 4) * max) / 4).round();
}
