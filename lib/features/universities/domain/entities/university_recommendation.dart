/// Represents a single AI-generated university recommendation.
class UniversityRecommendation {
  const UniversityRecommendation({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
    required this.universityScore,
    required this.acceptanceProbability,
    required this.estimatedTuition,
    required this.livingExpenses,
    required this.scholarshipAvailability,
    required this.applicationDeadline,
    required this.ranking,
    required this.employmentRate,
    required this.major,
    required this.climate,
    required this.matchReason,
    required this.website,
    this.city = '',
  });

  final String id;
  final String name;
  final String country;
  final String flag;

  /// Overall AI match score 0–100
  final int universityScore;

  /// Acceptance probability 0–100 (percentage)
  final int acceptanceProbability;

  /// Annual tuition, e.g. "\$55,000"
  final String estimatedTuition;

  /// Annual living expenses, e.g. "\$18,000"
  final String livingExpenses;

  /// "Full", "Partial", "Merit-based", "Limited", "None"
  final String scholarshipAvailability;

  /// Deadline string, e.g. "Jan 15, 2026"
  final String applicationDeadline;

  /// World ranking number
  final int ranking;

  /// Graduate employment rate 0–100 (percentage)
  final int employmentRate;

  /// The matched program/major
  final String major;

  /// Climate description, e.g. "Temperate", "Mediterranean"
  final String climate;

  /// AI-generated explanation of why this university matches the student
  final String matchReason;

  /// University website URL
  final String website;

  final String city;

  /// Whether any scholarship is available
  bool get hasScholarship =>
      scholarshipAvailability != 'None' && scholarshipAvailability != 'Limited';

  /// Score colour category: high / medium / low
  String get scoreCategory {
    if (universityScore >= 80) return 'high';
    if (universityScore >= 60) return 'medium';
    return 'low';
  }

  factory UniversityRecommendation.fromJson(Map<String, dynamic> json) {
    return UniversityRecommendation(
      id: json['id'] as String? ?? UniqueKey._gen(),
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      flag: json['flag'] as String? ?? '🌍',
      universityScore: (json['universityScore'] as num?)?.toInt() ?? 0,
      acceptanceProbability:
          (json['acceptanceProbability'] as num?)?.toInt() ?? 0,
      estimatedTuition: json['estimatedTuition'] as String? ?? 'N/A',
      livingExpenses: json['livingExpenses'] as String? ?? 'N/A',
      scholarshipAvailability:
          json['scholarshipAvailability'] as String? ?? 'None',
      applicationDeadline: json['applicationDeadline'] as String? ?? 'N/A',
      ranking: (json['ranking'] as num?)?.toInt() ?? 999,
      employmentRate: (json['employmentRate'] as num?)?.toInt() ?? 0,
      major: json['major'] as String? ?? '',
      climate: json['climate'] as String? ?? '',
      matchReason: json['matchReason'] as String? ?? '',
      website: json['website'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );
  }
}

/// Tiny helper so entities don't depend on Flutter
class UniqueKey {
  static int _counter = 0;
  static String _gen() => 'uni_${_counter++}';
}
