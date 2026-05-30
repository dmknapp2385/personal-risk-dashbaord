/// Continuous risk / exposure input on a 0.00..100.00 scale.
///
/// Storage is `double` so AI fills (and any future precise signals) keep
/// 2-decimal precision. UI sliders snap to whole integers when dragged but
/// the manual text field accepts up to 2 decimal places.
abstract final class RiskLevelScale {
  static const double max = 100.0;

  /// Short labels aligned with legacy five-step UI (anchors at 0, 25, 50, 75, 100).
  static const List<String> anchorLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static double clamp(num v) => v.toDouble().clamp(0.0, max);

  static double toNorm(num v) => clamp(v) / max;

  /// Band 0..4 for coloring and coarse tags (20-point buckets).
  static int bandIndex(num v) => (clamp(v) / 20).floor().clamp(0, 4);

  /// Preset values for quick jumps (0, 25, 50, 75, 100 as doubles).
  static double anchorValue(int bandIndex) =>
      bandIndex.clamp(0, 4) * (max / 4);

  /// Display helper: always 2 decimal places (e.g. "73.00", "73.42").
  static String format(num v) => clamp(v).toStringAsFixed(2);
}
