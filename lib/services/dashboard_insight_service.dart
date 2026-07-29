import 'dart:convert';

import '../controllers/risk_inputs_controller.dart';
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
/// brief justification, and the category it addresses.
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

  /// 3 specific, data-cited actions.
  final List<RecommendedAction> recommendedActions;
}

/// Builds a compact snapshot from [RiskInputsController] and asks a fast
/// local model to summarize it as strict JSON.
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

    // Keep the prompt short — long instructions dominate latency on CPU.
    final buf = StringBuffer()
      ..writeln(
          'Personal risk dashboard demo. Use ONLY this snapshot. No invented risks.')
      ..writeln(
          'SCORES are 0-1000 (cite X.XX/1000). DRIVER LEVELS are 0-100 (cite X.XX/100). Never mix.')
      ..writeln(
          'Return 3 concrete recommended actions. Each: imperative verb, cite one snapshot number with correct suffix, one-sentence why, different theme.')
      ..writeln()
      ..writeln('Snapshot:')
      ..writeln(jsonEncode(snapshot))
      ..writeln()
      ..writeln('Allowed top_concern.label values:')
      ..writeln(jsonEncode(allowedDriverLabels))
      ..writeln()
      ..writeln('JSON shape:')
      ..writeln(
          '{"summary":"1-2 sentences","top_concern":{"label":"...","category":"...","why":"1 sentence"},'
          '"recommended_actions":[{"title":"...","why":"1 sentence","category":"Health|Career|Financial|Personal Safety|Digital / Privacy"}]}');

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
          'minItems': 3,
          'maxItems': 3,
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

    final raw = await _ollama.askJson(
      buf.toString(),
      model: OllamaService.fastModel,
      schema: schema,
      options: const {
        'num_predict': 550,
        'temperature': 0.15,
      },
    );
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

  double _score0_1000(double scoreOutOf1000) =>
      (scoreOutOf1000 * 100).round() / 100.0;

  double _level0_100(double level) => (level * 100).round() / 100.0;

  /// Compact snapshot: category scores + top drivers only (no subcategory fluff).
  Map<String, dynamic> _buildSnapshot(RiskInputsController c) {
    return {
      'overall_score_0_1000': _score0_1000(c.overallRiskScore),
      'categories': {
        'Health': _score0_1000(c.healthRiskScore),
        'Career': _score0_1000(c.careerRiskScore),
        'Financial': _score0_1000(c.financialRiskScore),
        'Personal Safety': _score0_1000(c.personalSafetyRiskScore),
        'Digital / Privacy': _score0_1000(c.digitalPrivacyRiskScore),
      },
      'top_drivers': [
        for (final d in c.topDrivers.take(6))
          {
            'label': d.label,
            'category': d.category.shortLabel,
            'level_0_100': _level0_100(d.level),
          },
      ],
    };
  }
}
