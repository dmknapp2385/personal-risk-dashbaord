/// Risk scores live in [0, 1000]; values are rounded to 2 decimal places for display/storage consistency.
abstract final class RiskScore {
  static const double minValue = 0;
  static const double maxValue = 1000;

  /// Maps a normalized factor in [0, 1] to a score in [0, 1000] with 2 decimal places.
  static double fromNorm(double norm) {
    final v = norm.clamp(0.0, 1.0) * maxValue;
    return (v * 100).round() / 100.0;
  }

  /// Position on the 0–1000 scale for gradients and progress (0..1).
  static double normalizedT(double score) =>
      (score.clamp(minValue, maxValue)) / maxValue;

  static String format(double score) => score.toStringAsFixed(2);
}
