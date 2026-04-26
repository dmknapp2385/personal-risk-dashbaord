/// Flat factor averages (0–1) for all five categories. Engines use the four
/// *other* norms as cross-signals to avoid circular dependence on their own output.
class AllCategoryPeerNorms {
  const AllCategoryPeerNorms({
    required this.financialNorm,
    required this.digitalNorm,
    required this.healthNorm,
    required this.careerNorm,
    required this.safetyNorm,
  });

  final double financialNorm;
  final double digitalNorm;
  final double healthNorm;
  final double careerNorm;
  final double safetyNorm;
}
