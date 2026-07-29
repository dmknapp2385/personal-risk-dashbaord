import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/personal_safety_subcategories.dart';
import '../../data/risk_help_text.dart';
import '../../engine/personal_safety_risk_types.dart';
import '../../services/safety_autofill_service.dart';
import '../widgets/category_section.dart';
import '../widgets/category_tab_overview_header.dart';
import '../widgets/location_row.dart';

class PersonalSafetyTab extends StatefulWidget {
  const PersonalSafetyTab({
    super.key,
    required this.locationInput,
    required this.safetyLevels,
    required this.onLocationChanged,
    required this.onSafetyFactorChanged,
    required this.safetyDetail,
  });

  final String locationInput;
  final List<double> safetyLevels;
  final ValueChanged<String> onLocationChanged;
  final void Function(int index, double level) onSafetyFactorChanged;
  final PersonalSafetyRiskResult safetyDetail;

  static const _scaleLabels = ['VL', 'L', 'M', 'H', 'VH'];

  static const List<IconData> _sectionIcons = [
    Icons.location_city_outlined,
    Icons.home_work_outlined,
    Icons.warning_amber_outlined,
    Icons.flight_takeoff_outlined,
    Icons.emergency_outlined,
  ];

  @override
  State<PersonalSafetyTab> createState() => _PersonalSafetyTabState();
}

class _PersonalSafetyTabState extends State<PersonalSafetyTab> {
  final SafetyAutofillService _autofillService = SafetyAutofillService();

  bool _loading = false;
  String? _lastSummary;
  Map<String, dynamic>? _lastMockData;
  String? _lastLocationUsed;
  String? _lastError;
  String? _lastWarning;

  /// AI-generated rationale per factor. Same length / order as
  /// `widget.safetyLevels`. Entries become null when the user manually
  /// overrides a slider (the AI's reason no longer applies).
  List<String?>? _factorRationales;

  Future<void> _runAutofill() async {
    if (_loading) return;

    final location = widget.locationInput.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a location (or pick a sample below) before auto-filling.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _lastError = null;
      _lastWarning = null;
    });

    try {
      final result = await _autofillService.autofillFor(location);

      for (var i = 0; i < result.factorLevels.length; i++) {
        widget.onSafetyFactorChanged(i, result.factorLevels[i]);
      }

      if (!mounted) return;
      setState(() {
        _lastSummary = result.summary;
        _lastMockData = result.mockData;
        _lastLocationUsed = location;
        _lastWarning = result.warning;
        _factorRationales = List<String?>.from(
          result.factorRationales.map((r) => r.isEmpty ? null : r),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.warning == null
                ? 'Personal safety sliders auto-filled.'
                : 'Sliders auto-filled (with a model repair — see panel).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto-fill failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _pickSample(String value) {
    widget.onLocationChanged(value);
  }

  /// Called when the user drags a slider. Clears that factor's AI rationale
  /// since the value the user just chose no longer matches the AI's reasoning.
  void _onUserFactorChanged(int index, double level) {
    if (_factorRationales != null &&
        index >= 0 &&
        index < _factorRationales!.length &&
        _factorRationales![index] != null) {
      setState(() {
        _factorRationales![index] = null;
      });
    }
    widget.onSafetyFactorChanged(index, level);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.safetyLevels.length == kPersonalSafetyFactorCount,
      'safetyLevels.length (${widget.safetyLevels.length}) != $kPersonalSafetyFactorCount',
    );
    assert(
      widget.safetyDetail.subcategoryShare.length ==
          kPersonalSafetySubcategoryDefs.length,
    );
    assert(
      widget.safetyDetail.subcategoryScores.length ==
          kPersonalSafetySubcategoryDefs.length,
    );

    final barSlices = engineBarSlicesOmittingAllZeroSubcategories(
      factorLevelsFlat: widget.safetyLevels,
      engineSubShares: widget.safetyDetail.subcategoryShare,
      subScores: widget.safetyDetail.subcategoryScores,
      sectionTitles: [for (final d in kPersonalSafetySubcategoryDefs) d.title],
      sectionFactorLabels: [
        for (final d in kPersonalSafetySubcategoryDefs) d.factorLabels,
      ],
    );

    final children = <Widget>[
      LocationRow(
        value: widget.locationInput,
        onChanged: widget.onLocationChanged,
      ),
      const SizedBox(height: 10),
      _AutofillControls(
        loading: _loading,
        onAutofill: _runAutofill,
        onPickSample: _pickSample,
      ),
      if (_lastSummary != null ||
          _lastMockData != null ||
          _lastError != null) ...[
        const SizedBox(height: 12),
        _AutofillResultPanel(
          location: _lastLocationUsed,
          summary: _lastSummary,
          mockData: _lastMockData,
          error: _lastError,
          warning: _lastWarning,
        ),
      ],
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: CategoryTabOverviewHeader(
          overviewTitle: 'Personal Safety overview',
          overallLabel: 'Overall personal safety risk',
          overallScore: widget.safetyDetail.pointScore,
          slices: barSlices,
          scaleLabels: PersonalSafetyTab._scaleLabels,
          barCaption:
              'Weighted share inside your score (hover segments for factors · colors match risk below)',
        ),
      ),
      const SizedBox(height: 20),
    ];

    var offset = 0;
    for (var s = 0; s < kPersonalSafetySubcategoryDefs.length; s++) {
      final def = kPersonalSafetySubcategoryDefs[s];
      final n = def.factorLabels.length;
      final sectionBase = offset;
      if (s > 0) {
        children.add(const SizedBox(height: 12));
      }
      final sectionRationales =
          _factorRationales?.sublist(offset, offset + n);

      children.add(
        CategorySection(
          title: def.title,
          icon: PersonalSafetyTab._sectionIcons[s],
          factorLabels: def.factorLabels,
          levels: widget.safetyLevels.sublist(offset, offset + n),
          onLevelChanged: (i, level) =>
              _onUserFactorChanged(sectionBase + i, level),
          scaleLabels: PersonalSafetyTab._scaleLabels,
          titleHelp: RiskHelpText.subcategory(def.title),
          factorHelps: def.factorLabels
              .map((l) => RiskHelpText.factor(l))
              .toList(),
          factorRationales: sectionRationales,
        ),
      );
      offset += n;
    }

    return ListView(children: children);
  }
}

class _AutofillControls extends StatelessWidget {
  const _AutofillControls({
    required this.loading,
    required this.onAutofill,
    required this.onPickSample,
  });

  final bool loading;
  final VoidCallback onAutofill;
  final ValueChanged<String> onPickSample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Auto-fill sliders from local crime data (mock)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sends a canned "FBI-style" dataset for the location above to your '
            'local Llama model, which maps it onto every Personal Safety factor. '
            'Mocked because browsers cannot call most real data APIs directly (CORS).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: loading ? null : onAutofill,
                icon: loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(loading ? 'Working…' : 'Auto-fill with AI'),
              ),
              Text(
                'Try a sample:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              for (final s in kAutofillSampleLocations)
                ActionChip(
                  label: Text(s),
                  onPressed: loading ? null : () => onPickSample(s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutofillResultPanel extends StatelessWidget {
  const _AutofillResultPanel({
    required this.location,
    required this.summary,
    required this.mockData,
    required this.error,
    required this.warning,
  });

  final String? location;
  final String? summary;
  final Map<String, dynamic>? mockData;
  final String? error;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isError = error != null;
    final accent = isError ? cs.error : cs.primary;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.psychology_outlined,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isError
                      ? 'Auto-fill failed'
                      : 'AI auto-fill applied'
                          '${location != null ? ' · $location' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (isError) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Common cause: Ollama is not running, or qwen2.5:3b is not '
              'pulled (ollama pull qwen2.5:3b). On Chrome, also set '
              'OLLAMA_ORIGINS=* and restart Ollama.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ] else ...[
            if ((warning ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Color(0xFFEA580C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if ((summary ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                summary!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
            if (mockData != null) ...[
              const SizedBox(height: 4),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding:
                      const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    'View source data sent to the model',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ').convert(mockData),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
