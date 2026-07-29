import 'dart:convert';

import '../data/personal_safety_subcategories.dart';
import 'ollama_service.dart';

/// Result of running the auto-fill pipeline for the Personal Safety tab.
class SafetyAutofillResult {
  const SafetyAutofillResult({
    required this.factorLevels,
    required this.factorRationales,
    required this.mockData,
    required this.summary,
    this.warning,
  });

  /// One entry per personal-safety factor (length == kPersonalSafetyFactorCount).
  /// Each value is a double in 0.00..100.00.
  final List<double> factorLevels;

  /// One short rationale per factor (same length / same order as
  /// [factorLevels]). May contain empty strings if the model omitted one.
  final List<String> factorRationales;

  /// The raw "FBI-style" mock payload we shipped to the model. Surfaced in the
  /// UI so the user can see what the model was looking at.
  final Map<String, dynamic> mockData;

  /// Llama's short natural-language overall rationale.
  final String summary;

  /// Set when we had to repair the model's output (e.g. it returned 14 levels
  /// instead of 15). Null when the response matched the schema exactly.
  final String? warning;
}

/// How many factor levels we'll tolerate the model being off by before we
/// give up and surface an error. Smaller models sometimes drop one entry;
/// padding with the neutral value is more useful than failing.
const int _kAutofillLengthTolerance = 3;

/// Sample locations the UI surfaces as quick-pick chips. Each maps cleanly to
/// one of the canned profiles in [mockCrimeDataFor].
const List<String> kAutofillSampleLocations = [
  'Downtown Chicago, IL',
  'Palo Alto, CA (suburb)',
  'Rural Iowa',
];

/// Orchestrates the auto-fill: mock data -> Llama JSON -> validated levels.
class SafetyAutofillService {
  SafetyAutofillService({OllamaService? ollama})
      : _ollama = ollama ?? OllamaService();

  final OllamaService _ollama;

  Future<SafetyAutofillResult> autofillFor(String locationInput) async {
    final mock = mockCrimeDataFor(locationInput);
    final labels = kPersonalSafetyAllFactorLabels;

    final buf = StringBuffer()
      ..writeln(
          'You are a risk-assessment assistant for a personal risk dashboard.')
      ..writeln(
          'Given the local crime data below, estimate the personal-safety risk')
      ..writeln('for a typical resident across each listed factor on a precise')
      ..writeln('0.00..100.00 numeric scale, where:')
      ..writeln('  0    = essentially no risk for this factor here')
      ..writeln('  50   = average / typical exposure')
      ..writeln('  100  = severe exposure')
      ..writeln()
      ..writeln('IMPORTANT scoring rules:')
      ..writeln('  - Use TWO decimal places, e.g. 12.40, 47.83, 88.17.')
      ..writeln('  - Do NOT round to multiples of 5 (no 5, 10, 15, 75, 80…).')
      ..writeln('  - Do NOT round to multiples of 10.')
      ..writeln(
          '  - Vary the scores so factors that differ in the data also differ in the score.')
      ..writeln('  - Stay in [0.00, 100.00].')
      ..writeln()
      ..writeln('Crime data (mock FBI Crime Data Explorer style):')
      ..writeln(jsonEncode(mock))
      ..writeln()
      ..writeln(
          'Factors (return one object per factor in this exact order):');
    for (var i = 0; i < labels.length; i++) {
      buf.writeln('${i + 1}. ${labels[i]}');
    }
    buf
      ..writeln()
      ..writeln('How to write each "rationale":')
      ..writeln(
          '  - Write 1-2 short, plain-English sentences (about 15-35 words).')
      ..writeln(
          '  - Explain in simple terms WHY the score for this factor is what it is.')
      ..writeln(
          '  - Tie it to the specific number(s) in the crime data that drove the score.')
      ..writeln('  - Avoid jargon, hedging, or generic statements.')
      ..writeln('  - Do NOT respond with raw field names or "field: value" pairs.')
      ..writeln('  - GOOD examples:')
      ..writeln(
          '      "Violent crime here is high at 720 per 100k — well above typical, so daily outings carry a moderately elevated risk."')
      ..writeln(
          '      "The walkability score is low (38) and lighting is mixed, which makes walking alone less safe than average."')
      ..writeln('  - BAD examples (do NOT do this):')
      ..writeln('      "violent_crime_per_100k: 720"')
      ..writeln('      "walkability_safety_index_0_100"')
      ..writeln('      "high"')
      ..writeln('      "moderate risk"')
      ..writeln()
      ..writeln('Respond with STRICT JSON only, in this exact shape:')
      ..writeln('{')
      ..writeln('  "factors": [')
      ..writeln(
          '    {"level": <number 0.00..100.00, two decimals, no multiples of 5>,'
          ' "rationale": "<plain-English why, as described above>"},')
      ..writeln('    ... ${labels.length} items in the order above ...')
      ..writeln('  ],')
      ..writeln(
          '  "summary": "<one short overall sentence for a layperson>"')
      ..writeln('}');

    final schema = <String, dynamic>{
      'type': 'object',
      'properties': {
        'factors': {
          'type': 'array',
          'minItems': kPersonalSafetyFactorCount,
          'maxItems': kPersonalSafetyFactorCount,
          'items': {
            'type': 'object',
            'properties': {
              'level': {
                'type': 'number',
                'minimum': 0,
                'maximum': 100,
              },
              'rationale': {
                'type': 'string',
                'minLength': 40,
              },
            },
            'required': ['level', 'rationale'],
          },
        },
        'summary': {'type': 'string'},
      },
      'required': ['factors', 'summary'],
    };

    final raw = await _ollama.askJson(buf.toString(), schema: schema);
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Model did not return a JSON object.');
    }

    final factorsAny = decoded['factors'];
    if (factorsAny is! List) {
      throw const FormatException('Missing "factors" array in response.');
    }

    final levels = <double>[];
    final rationales = <String>[];
    for (final item in factorsAny) {
      if (item is Map) {
        final lv = item['level'];
        if (lv is num) {
          // Preserve precision; clamp and round to 2 decimal places.
          final clamped = lv.toDouble().clamp(0.0, 100.0);
          levels.add((clamped * 100).round() / 100.0);
          final raw = ((item['rationale'] as String?) ?? '').trim();
          rationales.add(_isUsefulRationale(raw) ? raw : '');
        }
      }
    }

    final originalCount = levels.length;
    String? warning;
    final expected = kPersonalSafetyFactorCount;
    final diff = (originalCount - expected).abs();

    if (originalCount != expected) {
      if (diff > _kAutofillLengthTolerance) {
        throw FormatException(
          'Expected $expected factors, got $originalCount. '
          'Try again, or confirm the model is installed: ollama pull qwen2.5:3b.',
        );
      }
      if (originalCount < expected) {
        while (levels.length < expected) {
          levels.add(50.0);
          rationales.add('');
        }
      } else {
        levels.removeRange(expected, levels.length);
        rationales.removeRange(expected, rationales.length);
      }
      warning = 'Model returned $originalCount factors instead of $expected. '
          'Repaired by '
          '${originalCount < expected ? "padding with 50 (neutral)" : "truncating extras"}.'
          ' Retry autofill if results look off.';
    }

    final summary = (decoded['summary'] as String?)?.trim() ?? '';

    return SafetyAutofillResult(
      factorLevels: levels,
      factorRationales: rationales,
      mockData: mock,
      summary: summary,
      warning: warning,
    );
  }
}

/// Filters out degenerate rationales the model sometimes returns when it takes
/// the "cite specific fields" instruction too literally — e.g. dumping
/// "violent_crime_per_100k: 720" or just a bare field name. Returning false
/// causes the UI to hide the AI badge for that factor.
bool _isUsefulRationale(String s) {
  final trimmed = s.trim();
  if (trimmed.length < 25) return false;

  if (RegExp(r'^[a-z][a-z0-9_]*\s*[:=]').hasMatch(trimmed)) {
    return false;
  }

  if (RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(trimmed)) {
    return false;
  }

  final letters = RegExp(r'[A-Za-z]').allMatches(trimmed).length;
  final wordChars = RegExp(r'[A-Za-z0-9_]').allMatches(trimmed).length;
  if (wordChars > 0 && letters / wordChars < 0.6) return false;

  if (!trimmed.contains(' ')) return false;

  return true;
}

/// Deterministic mock "FBI Crime Data Explorer"-style payload.
///
/// Picks one of three canned profiles via keyword match on [locationInput],
/// falling back to a hash of the input so different strings produce different
/// profiles. This is intentionally a stand-in for a real API call (which we
/// can't make from a browser due to CORS) so the demo runs offline.
Map<String, dynamic> mockCrimeDataFor(String locationInput) {
  final lc = locationInput.toLowerCase().trim();

  bool hasAny(List<String> needles) =>
      needles.any((n) => lc.contains(n));

  if (hasAny([
    'chicago',
    'detroit',
    'oakland',
    'san francisco',
    'baltimore',
    'memphis',
    'downtown',
    'city center',
  ])) {
    return _profileHighCity(locationInput);
  }

  if (hasAny([
    'suburb',
    'palo alto',
    'plano',
    'mountain view',
    'naperville',
    'irvine',
    'cupertino',
    'frisco',
  ])) {
    return _profileSafeSuburb(locationInput);
  }

  if (hasAny([
    'rural',
    'iowa',
    'wyoming',
    'montana',
    'kansas',
    'nebraska',
    ', mt',
    ', wy',
    ', ia',
  ])) {
    return _profileRural(locationInput);
  }

  final h = locationInput.isEmpty
      ? 0
      : locationInput.codeUnits.fold<int>(0, (a, b) => a + b);
  switch (h % 3) {
    case 0:
      return _profileHighCity(locationInput);
    case 1:
      return _profileSafeSuburb(locationInput);
    default:
      return _profileRural(locationInput);
  }
}

Map<String, dynamic> _profileHighCity(String location) => {
      'location': location.isEmpty ? 'High-crime city center' : location,
      'population': 880000,
      'year': 2023,
      'violent_crime_per_100k': 720,
      'property_crime_per_100k': 5400,
      'burglary_per_100k': 480,
      'vehicle_theft_per_100k': 870,
      'aggravated_assault_per_100k': 460,
      'robbery_per_100k': 230,
      'walkability_safety_index_0_100': 38,
      'street_lighting_quality': 'mixed',
      'transit_incidents_per_100k': 195,
      'emergency_response_minutes_p50': 9,
      'note':
          'Elevated violent and property crime indices; downtown corridors and transit hubs are the largest contributors. Late-night isolation risk on transit.',
    };

Map<String, dynamic> _profileSafeSuburb(String location) => {
      'location': location.isEmpty ? 'Low-crime suburb' : location,
      'population': 64000,
      'year': 2023,
      'violent_crime_per_100k': 110,
      'property_crime_per_100k': 1300,
      'burglary_per_100k': 95,
      'vehicle_theft_per_100k': 120,
      'aggravated_assault_per_100k': 60,
      'robbery_per_100k': 25,
      'walkability_safety_index_0_100': 78,
      'street_lighting_quality': 'good',
      'transit_incidents_per_100k': 12,
      'emergency_response_minutes_p50': 5,
      'note':
          'Low violent crime overall; small uptick in package theft and opportunistic vehicle break-ins in residential pockets.',
    };

Map<String, dynamic> _profileRural(String location) => {
      'location': location.isEmpty ? 'Rural / small town' : location,
      'population': 8400,
      'year': 2023,
      'violent_crime_per_100k': 180,
      'property_crime_per_100k': 1900,
      'burglary_per_100k': 240,
      'vehicle_theft_per_100k': 70,
      'aggravated_assault_per_100k': 90,
      'robbery_per_100k': 10,
      'walkability_safety_index_0_100': 55,
      'street_lighting_quality': 'sparse',
      'transit_incidents_per_100k': 3,
      'emergency_response_minutes_p50': 18,
      'note':
          'Lower overall crime, but sparse street lighting and longer emergency response times raise isolation risk for late-night travel and outdoor errands.',
    };
