import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/features/universities/data/services/recommendation_ai_service.dart';
import 'package:globaledu_ai/features/universities/domain/entities/recommendation_filters.dart';
import 'package:globaledu_ai/features/universities/domain/entities/university_recommendation.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class RecommendationState {
  const RecommendationState({
    this.status = RecommendationStatus.idle,
    this.results = const [],
    this.filters = const RecommendationFilters(),
    this.preferences,
    this.error,
  });

  final RecommendationStatus status;
  final List<UniversityRecommendation> results;
  final RecommendationFilters filters;
  final RecommendationPreferences? preferences;
  final String? error;

  bool get isLoading => status == RecommendationStatus.loading;
  bool get hasResults => status == RecommendationStatus.success && results.isNotEmpty;
  bool get hasError => status == RecommendationStatus.error;

  /// Returns results after applying filters/sort without re-calling AI.
  List<UniversityRecommendation> get filteredResults {
    var list = List<UniversityRecommendation>.from(results);

    // Filter by country
    if (filters.selectedCountries.isNotEmpty) {
      list = list
          .where((u) => filters.selectedCountries.contains(u.country))
          .toList();
    }

    // Filter by scholarship
    if (filters.scholarshipOnly) {
      list = list.where((u) => u.hasScholarship).toList();
    }

    // Sort
    switch (filters.sortBy) {
      case RecommendationSortBy.score:
        list.sort((a, b) => b.universityScore.compareTo(a.universityScore));
      case RecommendationSortBy.ranking:
        list.sort((a, b) => a.ranking.compareTo(b.ranking));
      case RecommendationSortBy.tuitionLow:
        // Sort by numeric tuition value extracted from string
        list.sort((a, b) => _extractNumber(a.estimatedTuition)
            .compareTo(_extractNumber(b.estimatedTuition)));
      case RecommendationSortBy.employmentRate:
        list.sort((a, b) => b.employmentRate.compareTo(a.employmentRate));
      case RecommendationSortBy.acceptanceProbability:
        list.sort(
            (a, b) => b.acceptanceProbability.compareTo(a.acceptanceProbability));
    }

    return list;
  }

  /// Unique countries in current results for filter chips.
  List<String> get availableCountries =>
      results.map((u) => u.country).toSet().toList()..sort();

  RecommendationState copyWith({
    RecommendationStatus? status,
    List<UniversityRecommendation>? results,
    RecommendationFilters? filters,
    RecommendationPreferences? preferences,
    String? error,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      results: results ?? this.results,
      filters: filters ?? this.filters,
      preferences: preferences ?? this.preferences,
      error: error ?? this.error,
    );
  }
}

enum RecommendationStatus { idle, loading, success, error }

double _extractNumber(String s) {
  final digits = RegExp(r'[\d,]+').firstMatch(s)?.group(0) ?? '0';
  return double.tryParse(digits.replaceAll(',', '')) ?? 0;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class RecommendationNotifier extends Notifier<RecommendationState> {
  @override
  RecommendationState build() => const RecommendationState();

  final _service = RecommendationAiService.instance;

  Future<void> generate(RecommendationPreferences prefs) async {
    state = state.copyWith(
      status: RecommendationStatus.loading,
      preferences: prefs,
      results: [],
      error: null,
    );

    try {
      final results = await _service.getRecommendations(prefs);
      state = state.copyWith(
        status: RecommendationStatus.success,
        results: results,
        // Reset filters when new results come in
        filters: const RecommendationFilters(),
      );
    } catch (e) {
      state = state.copyWith(
        status: RecommendationStatus.error,
        error: e.toString(),
      );
    }
  }

  void updateFilters(RecommendationFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void reset() {
    state = const RecommendationState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final recommendationProvider =
    NotifierProvider<RecommendationNotifier, RecommendationState>(
  RecommendationNotifier.new,
);
