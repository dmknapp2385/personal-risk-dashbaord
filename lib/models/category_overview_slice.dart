/// One segment in a category overview bar (financial subcategory or single factor).
class CategoryOverviewBarSlice {
  const CategoryOverviewBarSlice({
    required this.title,
    required this.share,
    required this.riskScore,
    required this.factorLabels,
    required this.factorLevels,
  });

  final String title;
  final double share;
  final double riskScore;
  final List<String> factorLabels;
  final List<double> factorLevels;
}
