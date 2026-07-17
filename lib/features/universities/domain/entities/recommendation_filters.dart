/// User's input preferences for the recommendation engine.
class RecommendationPreferences {
  const RecommendationPreferences({
    this.countries = const [],
    this.budgetMin = 0,
    this.budgetMax = 80000,
    this.ieltsScore = 6.5,
    this.gpa = 3.0,
    this.major = '',
    this.careerGoals = '',
    this.climates = const [],
    this.workAfterGraduation = false,
  });

  final List<String> countries;
  final double budgetMin;
  final double budgetMax;
  final double ieltsScore;
  final double gpa;
  final String major;
  final String careerGoals;
  final List<String> climates;
  final bool workAfterGraduation;

  RecommendationPreferences copyWith({
    List<String>? countries,
    double? budgetMin,
    double? budgetMax,
    double? ieltsScore,
    double? gpa,
    String? major,
    String? careerGoals,
    List<String>? climates,
    bool? workAfterGraduation,
  }) {
    return RecommendationPreferences(
      countries: countries ?? this.countries,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      ieltsScore: ieltsScore ?? this.ieltsScore,
      gpa: gpa ?? this.gpa,
      major: major ?? this.major,
      careerGoals: careerGoals ?? this.careerGoals,
      climates: climates ?? this.climates,
      workAfterGraduation: workAfterGraduation ?? this.workAfterGraduation,
    );
  }

  bool get isValid => major.trim().isNotEmpty;
}

/// Sort options for the results screen.
enum RecommendationSortBy {
  score('Match Score'),
  ranking('World Ranking'),
  tuitionLow('Tuition: Low → High'),
  employmentRate('Employment Rate'),
  acceptanceProbability('Acceptance Rate');

  const RecommendationSortBy(this.label);
  final String label;
}

/// Filter/sort state applied to the results list without re-querying AI.
class RecommendationFilters {
  const RecommendationFilters({
    this.sortBy = RecommendationSortBy.score,
    this.selectedCountries = const [],
    this.scholarshipOnly = false,
  });

  final RecommendationSortBy sortBy;
  final List<String> selectedCountries;
  final bool scholarshipOnly;

  RecommendationFilters copyWith({
    RecommendationSortBy? sortBy,
    List<String>? selectedCountries,
    bool? scholarshipOnly,
  }) {
    return RecommendationFilters(
      sortBy: sortBy ?? this.sortBy,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      scholarshipOnly: scholarshipOnly ?? this.scholarshipOnly,
    );
  }
}
