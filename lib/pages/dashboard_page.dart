import 'package:flutter/material.dart';

import '../controllers/risk_inputs_controller.dart';
import '../models/home_category_score.dart';
import '../models/risk_category.dart';
import '../services/dashboard_insight_service.dart';
import 'risk_category_detail_page.dart';
import 'tabs/career_tab.dart';
import 'tabs/digital_privacy_tab.dart';
import 'tabs/financial_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/overall_tab.dart';
import 'tabs/personal_safety_tab.dart';
import 'widgets/ai_insight_dialog.dart';
import 'widgets/theme_toggle_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RiskInputsController _c = RiskInputsController();
  final DashboardInsightService _insightService = DashboardInsightService();

  bool _loadingInsight = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _runInsight() async {
    if (_loadingInsight) return;
    setState(() => _loadingInsight = true);
    try {
      final insight = await _insightService.generate(_c);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AiInsightDialog(insight: insight),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AiInsightErrorDialog(error: e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingInsight = false);
      }
    }
  }

  void _openCategoryPage(BuildContext context, RiskCategory category) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) {
          return ListenableBuilder(
            listenable: _c,
            builder: (context, _) {
              switch (category) {
                case RiskCategory.health:
                  return RiskCategoryDetailPage(
                    title: category.shortLabel,
                    body: HealthTab(
                      healthLevels: List<double>.from(_c.healthFactorLevels),
                      onHealthFactorChanged: _c.setHealthFactor,
                      healthDetail: _c.healthRiskResult,
                    ),
                  );
                case RiskCategory.career:
                  return RiskCategoryDetailPage(
                    title: category.shortLabel,
                    body: CareerTab(
                      careerLevels: List<double>.from(_c.careerFactorLevels),
                      onCareerFactorChanged: _c.setCareerFactor,
                      careerDetail: _c.careerRiskResult,
                    ),
                  );
                case RiskCategory.financial:
                  return RiskCategoryDetailPage(
                    title: category.shortLabel,
                    body: FinancialTab(
                      financialLevels:
                          List<double>.from(_c.financialFactorLevels),
                      onFinancialFactorChanged: _c.setFinancialFactor,
                      financialDetail: _c.financialRiskResult,
                    ),
                  );
                case RiskCategory.personalSafety:
                  return RiskCategoryDetailPage(
                    title: category.shortLabel,
                    body: PersonalSafetyTab(
                      locationInput: _c.crimeLocationInput,
                      safetyLevels:
                          List<double>.from(_c.personalSafetyFactorLevels),
                      onLocationChanged: _c.setCrimeLocationInput,
                      onSafetyFactorChanged: _c.setPersonalSafetyFactor,
                      safetyDetail: _c.personalSafetyRiskResult,
                    ),
                  );
                case RiskCategory.digitalPrivacy:
                  return RiskCategoryDetailPage(
                    title: category.shortLabel,
                    body: DigitalPrivacyTab(
                      digitalLevels:
                          List<double>.from(_c.digitalFactorLevels),
                      onDigitalFactorChanged: _c.setDigitalFactor,
                      digitalDetail: _c.digitalRiskResult,
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('Personalized Risk Dashboard'),
            actions: const [
              ThemeToggleButton(),
              SizedBox(width: 4),
            ],
          ),
          body: SelectionArea(
            child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in RiskCategory.values) ...[
                            if (c != RiskCategory.values.first)
                              const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: () => _openCategoryPage(context, c),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(c.shortLabel),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Stack(
                        children: [
                          OverallTab(
                            overallScore: _c.overallRiskScore,
                            categoryScores: [
                              HomeCategoryScore(
                                label: 'Health',
                                score: _c.healthRiskScore,
                                category: RiskCategory.health,
                              ),
                              HomeCategoryScore(
                                label: 'Career',
                                score: _c.careerRiskScore,
                                category: RiskCategory.career,
                              ),
                              HomeCategoryScore(
                                label: 'Financial',
                                score: _c.financialRiskScore,
                                category: RiskCategory.financial,
                              ),
                              HomeCategoryScore(
                                label: 'Personal Safety',
                                score: _c.personalSafetyRiskScore,
                                category: RiskCategory.personalSafety,
                              ),
                              HomeCategoryScore(
                                label: 'Digital / Privacy',
                                score: _c.digitalPrivacyRiskScore,
                                category: RiskCategory.digitalPrivacy,
                              ),
                            ],
                            topDrivers: _c.topDrivers,
                            onOpenCategory: (c) => _openCategoryPage(context, c),
                          ),

                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton.extended(
                              onPressed: _loadingInsight ? null : _runInsight,
                              icon: _loadingInsight
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(
                                _loadingInsight ? 'Thinking…' : 'AI Insight',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
