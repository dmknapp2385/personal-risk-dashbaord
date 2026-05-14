import 'dart:convert';

import '../controllers/risk_inputs_controller.dart';
import '../data/career_subcategories.dart';
import '../data/digital_privacy_subcategories.dart';
import '../data/financial_subcategories.dart';
import '../data/health_subcategories.dart';
import '../data/personal_safety_subcategories.dart';
import '../models/risk_category.dart';
import 'ollama_service.dart';

/// The model's pick of the single largest concern across all categories.
class TopConcern {
  const TopConcern({
    required this.label,
    required this.category,
    required this.why,
  });

  final String label;
  final String category;
  final String why;
}

/// A single thought-out recommendation: short imperative title, a
/// 2–3 sentence justification, and the category it addresses.
class RecommendedAction {
  const RecommendedAction({
    required this.title,
    required this.why,
    required this.category,
  });

  final String title;
  final String why;
  final String category;
}

/// Full structured response shown in the AI Insight dialog.
class DashboardInsight {
  const DashboardInsight({
    required this.summary,
    required this.topConcern,
    required this.recommendedActions,
  });

  /// 1–2 sentence overall takeaway.
  final String summary;

  /// Optional — only present if the model returned a usable top_concern object.
  final TopConcern? topConcern;

  /// 4–6 specific, data-cited actions.
  final List<RecommendedAction> recommendedActions;
}

/// Builds a structured snapshot from [RiskInputsController] and asks the local
/// Llama model to summarize it as strict JSON.
class DashboardInsightService {
  DashboardInsightService({OllamaService? ollama})
      : _ollama = ollama ?? OllamaService();

  final OllamaService _ollama;

  Future<DashboardInsight> generate(RiskInputsController c) async {
    final snapshot = _buildSnapshot(c);
    final allowedDriverLabels =
        (snapshot['top_drivers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((d) => d['label'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

    final buf = StringBuffer()
      ..writeln(
          'You are an assistant for a personal risk dashboard demo.')
      ..writeln(
          'Use ONLY the snapshot below. Do not invent risks not present in it.')
      ..writeln(
          'Do not say you lack information. This is a demo, not professional advice.')
      ..writeln()
      ..writeln('TWO SCALES — read carefully and never mix them:')
      ..writeln('  • SCORES (overall risk, category, subcategory) live on a')
      ..writeln(
          '    0–1000 scale, TWO decimals, e.g. "612.50". Field names contain')
      ..writeln(
          '    "score_0_1000". Cite the EXACT value verbatim, ALWAYS with the')
      ..writeln(
          '    suffix "/1000" (e.g. "612.50/1000"). Do NOT round to integers.')
      ..writeln('  • DRIVER LEVELS live on a 0–100 scale, TWO decimals,')
      ..writeln('    e.g. "75.40". Field names contain "level_0_100".')
      ..writeln(
          '    Cite the EXACT value verbatim, ALWAYS with the suffix "/100".')
      ..writeln('    Do NOT round to integers.')
      ..writeln()
      ..writeln('NEVER use the wrong scale for a thing. NEVER drop the suffix.')
      ..writeln('NEVER write a score above 1000 or a driver level above 100.')
      ..writeln(
          'NEVER cite the same number with two different suffixes in one reply.')
      ..writeln()
      ..writeln(
          'Your job is to produce a focused set of recommended actions.')
      ..writeln('Each recommended action MUST:')
      ..writeln('  - start with an imperative verb (Build, Move, Set up, '
          'Replace, Schedule, Cancel, Open, Switch, Cap, …);')
      ..writeln(
          '  - cite at least one specific number from the snapshot — either')
      ..writeln(
          '    a category/overall score (e.g. "Financial at 612.50/1000") or a')
      ..writeln(
          '    driver level (e.g. "Vehicle theft at 75.40/100"), using the')
      ..writeln('    matching suffix for that thing;')
      ..writeln(
          '  - reference a specific driver label or category that ACTUALLY')
      ..writeln('    appears in the snapshot — do not make up names;')
      ..writeln('  - be one concrete step a person can do this week or month, '
          'not a category of advice;')
      ..writeln('  - target a different driver/category from the other '
          'actions (no two duplicate themes);')
      ..writeln('  - include a 2–3 sentence "why" that ties the action to the '
          'snapshot data, with each cited number using its correct suffix.')
      ..writeln()
      ..writeln('Avoid generic advice like "live a healthier lifestyle", '
          '"be more careful online", or "save more money". Tie every '
          'recommendation to a specific number from the snapshot.')
      ..writeln()
      ..writeln('Snapshot:')
      ..writeln(jsonEncode(snapshot))
      ..writeln()
      ..writeln(
          'Allowed driver labels for "top_concern.label" (copy one verbatim):')
      ..writeln('  ${jsonEncode(allowedDriverLabels)}')
      ..writeln()
      ..writeln('GOOD citation examples (do this — copy the number verbatim, '
          'two decimals):')
      ..writeln('  "Overall risk is 612.50/1000"')
      ..writeln('  "Financial is at 612.50/1000"')
      ..writeln('  "Health overall is 437.20/1000"')
      ..writeln('  "Vehicle theft sits at 75.40/100"')
      ..writeln('  "Sleep quality is 60.00/100"')
      ..writeln('BAD citations (do NOT do this):')
      ..writeln('  "Financial at 61.20/100"        ← scores belong on /1000')
      ..writeln('  "Vehicle theft at 754.00/1000"  ← driver levels belong on /100')
      ..writeln('  "Financial at 612"              ← missing decimals AND suffix')
      ..writeln('  "Financial at 612/1000"         ← missing two decimals')
      ..writeln('  "Sleep quality at 60"           ← missing decimals AND suffix')
      ..writeln('  "high"                          ← no number')
      ..writeln()
      ..writeln('Respond with STRICT JSON only, in this exact shape:')
      ..writeln('{')
      ..writeln(
          '  "summary": "<1-2 sentence overall takeaway. If you cite the overall risk number, use X.XX/1000.>",')
      ..writeln('  "top_concern": {')
      ..writeln(
          '    "label":    "<one driver label copied verbatim from the allowed list above>",')
      ..writeln(
          '    "category": "<that driver\'s category from snapshot>",')
      ..writeln(
          '    "why":      "<one sentence reason. Driver level uses X.XX/100; any score uses X.XX/1000.>"')
      ..writeln('  },')
      ..writeln('  "recommended_actions": [')
      ..writeln('    {')
      ..writeln(
          '      "title":    "<imperative phrase citing one number with the correct suffix>",')
      ..writeln(
          '      "why":      "<2-3 sentences. Each cited number uses two decimals AND its correct /1000 or /100 suffix.>",')
      ..writeln(
          '      "category": "<one of: Health | Career | Financial | Personal Safety | Digital / Privacy>"')
      ..writeln('    },')
      ..writeln('    ... 4 to 6 entries total ...')
      ..writeln('  ]')
      ..writeln('}');

    final schema = <String, dynamic>{
      'type': 'object',
      'properties': {
        'summary': {'type': 'string'},
        'top_concern': {
          'type': 'object',
          'properties': {
            'label': {'type': 'string'},
            'category': {'type': 'string'},
            'why': {'type': 'string'},
          },
          'required': ['label', 'category', 'why'],
        },
        'recommended_actions': {
          'type': 'array',
          'minItems': 4,
          'maxItems': 6,
          'items': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string'},
              'why': {'type': 'string'},
              'category': {
                'type': 'string',
                'enum': [
                  'Health',
                  'Career',
                  'Financial',
                  'Personal Safety',
                  'Digital / Privacy',
                ],
              },
            },
            'required': ['title', 'why', 'category'],
          },
        },
      },
      'required': [
        'summary',
        'top_concern',
        'recommended_actions',
      ],
    };

    final raw = await _ollama.askJson(buf.toString(), schema: schema);
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Model did not return a JSON object.');
    }

    final summary = _normalizeScaleCitations(
      (decoded['summary'] as String?)?.trim() ?? '',
    );

    final allowedSet = allowedDriverLabels.toSet();

    TopConcern? topConcern;
    final tcRaw = decoded['top_concern'];
    if (tcRaw is Map) {
      final rawLabel = (tcRaw['label'] as String? ?? '').trim();
      final category = (tcRaw['category'] as String? ?? '').trim();
      final why = _normalizeScaleCitations(
        (tcRaw['why'] as String? ?? '').trim(),
      );
      // Only keep top_concern.label if it actually matches a driver we sent.
      // Otherwise, fall back to the highest-impact driver (first in list).
      String label = rawLabel;
      if (label.isNotEmpty && !allowedSet.contains(label)) {
        label = allowedDriverLabels.isNotEmpty
            ? allowedDriverLabels.first
            : '';
      }
      if (label.isNotEmpty || category.isNotEmpty || why.isNotEmpty) {
        topConcern = TopConcern(
          label: label,
          category: category,
          why: why,
        );
      }
    }

    final actions = <RecommendedAction>[];
    final actionsRaw = decoded['recommended_actions'];
    if (actionsRaw is List) {
      for (final a in actionsRaw) {
        if (a is Map) {
          final title = _normalizeScaleCitations(
            (a['title'] as String? ?? '').trim(),
          );
          final why = _normalizeScaleCitations(
            (a['why'] as String? ?? '').trim(),
          );
          final category = (a['category'] as String? ?? '').trim();
          if (title.isNotEmpty || why.isNotEmpty) {
            actions.add(RecommendedAction(
              title: title,
              why: why,
              category: category,
            ));
          }
        }
      }
    }

    return DashboardInsight(
      summary: summary,
      topConcern: topConcern,
      recommendedActions: actions,
    );
  }

  /// Belt-and-suspenders fix-up for cases where a small model slips past the
  /// prompt and (a) uses the wrong scale suffix or (b) drops the two-decimal
  /// formatting we asked for.
  ///
  /// - `n/100`  where `n > 100`     → `n.XX/1000` (misplaced score)
  /// - `n/100`  with no decimals    → `n.XX/100`  (pad to two decimals)
  /// - `n/1000` with no decimals    → `n.XX/1000` (pad to two decimals)
  static String _normalizeScaleCitations(String s) {
    if (s.isEmpty) return s;

    String out = s;

    final re100 = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*100\b');
    out = out.replaceAllMapped(re100, (m) {
      final raw = double.tryParse(m.group(1) ?? '');
      if (raw == null) return m.group(0)!;
      if (raw > 100) {
        return '${raw.toStringAsFixed(2)}/1000';
      }
      return '${raw.toStringAsFixed(2)}/100';
    });

    final re1000 = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*1000\b');
    out = out.replaceAllMapped(re1000, (m) {
      final raw = double.tryParse(m.group(1) ?? '');
      if (raw == null) return m.group(0)!;
      return '${raw.toStringAsFixed(2)}/1000';
    });

    return out;
  }

  /// Snap a 0–1000 score to a stable two-decimal value for the snapshot.
  double _score0_1000(double scoreOutOf1000) =>
      (scoreOutOf1000 * 100).round() / 100.0;

  /// Driver levels are already 0–100; snap to two decimals so the snapshot
  /// looks uniform.
  double _level0_100(double level) => (level * 100).round() / 100.0;

  Map<String, dynamic> _buildSnapshot(RiskInputsController c) {
    Map<String, dynamic> view({
      required double score,
      required List<String> titles,
      required List<double> subScores,
    }) {
      final order = List.generate(titles.length, (i) => i)
        ..sort((a, b) => subScores[b].compareTo(subScores[a]));
      final top = order.take(2).map((i) => {
            'title': titles[i],
            'score_0_1000': _score0_1000(subScores[i]),
          }).toList();
      return {
        'score_0_1000': _score0_1000(score),
        'top_subcategories': top,
      };
    }

    return {
      'scale_note':
          'Scores (overall / category / subcategory) are 0-1000 — cite as X.XX/1000. '
              'Driver levels are 0-100 — cite as X.XX/100. Never mix scales, '
              'always include two decimals.',
      'overall_score_0_1000': _score0_1000(c.overallRiskScore),
      'location': c.crimeLocationInput.isEmpty ? null : c.crimeLocationInput,
      'categories': {
        'Health': view(
          score: c.healthRiskScore,
          titles: [for (final d in kHealthSubcategoryDefs) d.title],
          subScores: c.healthSubcategoryScores,
        ),
        'Career': view(
          score: c.careerRiskScore,
          titles: [for (final d in kCareerSubcategoryDefs) d.title],
          subScores: c.careerSubcategoryScores,
        ),
        'Financial': view(
          score: c.financialRiskScore,
          titles: [for (final d in kFinancialSubcategoryDefs) d.title],
          subScores: c.financialSubcategoryScores,
        ),
        'Personal Safety': view(
          score: c.personalSafetyRiskScore,
          titles: [for (final d in kPersonalSafetySubcategoryDefs) d.title],
          subScores: c.personalSafetySubcategoryScores,
        ),
        'Digital / Privacy': view(
          score: c.digitalPrivacyRiskScore,
          titles: [for (final d in kDigitalPrivacySubcategoryDefs) d.title],
          subScores: c.digitalSubcategoryScores,
        ),
      },
      'top_drivers': [
        for (final d in c.topDrivers)
          {
            'label': d.label,
            'category': d.category.shortLabel,
            'level_0_100': _level0_100(d.level),
          },
      ],
    };
  }
}
