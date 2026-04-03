import 'package:flutter/material.dart';

import 'risk_score.dart';

/// Green→red risk styling shared by category mini bars and overall bar segments.
abstract final class CategoryRiskBarColors {
  static const Color low = Color(0xFF16A34A);
  static const Color high = Color(0xFFDC2626);

  static Color lerpRisk(double score) {
    final t = RiskScore.normalizedT(score);
    return Color.lerp(low, high, t)!;
  }

  /// Same fill as [CategoryMiniRiskBar] track.
  static Color fillForScore(double score) {
    final t = RiskScore.normalizedT(score);
    final risk = Color.lerp(low, high, t)!;
    return risk.withValues(alpha: 0.16 + 0.65 * t);
  }

  static Color borderForScore(double score) {
    final t = RiskScore.normalizedT(score);
    final risk = Color.lerp(low, high, t)!;
    return risk.withValues(alpha: 0.7);
  }
}
