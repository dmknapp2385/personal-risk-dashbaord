import 'package:flutter/material.dart';

void main() {
  runApp(const RiskDashboardApp());
}

class RiskDashboardApp extends StatelessWidget {
  const RiskDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalized Risk Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Personalized Risk Dashboard'),
        actions: const [
          _HeaderPill(label: 'Credit'),
          _HeaderPill(label: 'Insurance'),
          _HeaderPill(label: 'Crime'),
          _HeaderPill(label: 'Climate'),
          SizedBox(width: 12),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _HeroCard(
                title: 'A modern risk assessment tool',
                subtitle:
                    'Calculate and explain risk across credit health, insurance gaps, crime trends, climate exposure, and more—so you can make faster, better-informed decisions.',
                bullets: const [
                  'Combine multiple signals into one view of risk',
                  'Make assumptions explicit and auditable',
                  'Track changes over time and compare scenarios',
                ],
              ),
              const SizedBox(height: 18),
              Text('What this dashboard can cover',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              _RiskGrid(
                isWide: isWide,
                children: const [
                  _RiskTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Credit risk',
                    body:
                        'Debt-to-income, utilization, delinquencies, stability signals, and scenario stress tests.',
                  ),
                  _RiskTile(
                    icon: Icons.shield_outlined,
                    title: 'Insurance gaps',
                    body:
                        'Coverage adequacy, deductible sensitivity, and gaps by asset, health, and liability categories.',
                  ),
                  _RiskTile(
                    icon: Icons.security_outlined,
                    title: 'Crime trends',
                    body:
                        'Local trend indicators, incident types, seasonality, and near-term risk outlook.',
                  ),
                  _RiskTile(
                    icon: Icons.public_outlined,
                    title: 'Climate exposure',
                    body:
                        'Heat, flood, wildfire, and storm exposure, plus resilience factors and time horizons.',
                  ),
                  _RiskTile(
                    icon: Icons.query_stats_outlined,
                    title: 'Portfolio view',
                    body:
                        'Aggregate risk across users, regions, or assets with drill-down, cohorts, and alerts.',
                  ),
                  _RiskTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & governance',
                    body:
                        'Role-based access patterns, transparent scoring, and explainable outputs for review.',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _NextStepsCard(
                title: 'Next steps',
                items: const [
                  'Connect data sources (CSV/API) and define a score model.',
                  'Add calculators per module (credit, insurance, crime, climate).',
                  'Create a results page with explainability and export.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.surfaceContainerHighest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar_outlined, color: cs.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.headlineSmall),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 14),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskGrid extends StatelessWidget {
  const _RiskGrid({required this.children, required this.isWide});
  final List<Widget> children;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 3 : 1;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.7 : 2.6,
      children: children,
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...items.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(t)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
