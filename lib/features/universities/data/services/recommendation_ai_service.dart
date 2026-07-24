import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/features/universities/domain/entities/recommendation_filters.dart';
import 'package:globaledu_ai/features/universities/domain/entities/university_recommendation.dart';

class RecommendationAiService {
  RecommendationAiService._();
  static final instance = RecommendationAiService._();

  /// Builds prompt and calls Firebase Cloud Function; returns parsed recommendations.
  Future<List<UniversityRecommendation>> getRecommendations(
    RecommendationPreferences prefs,
  ) async {
    final prompt = _buildPrompt(prefs);

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('chatWithAI');
      
      final response = await callable.call<Map<String, dynamic>>({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'maxTokens': 4000,
      });

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception('Cloud Function error: ${data['error'] ?? 'Unknown error'}');
      }

      final content = data['response'] as String;
      return _parseRecommendations(content);
      
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('Firebase Functions error: ${e.code} - ${e.message}', e, e.stackTrace);
      rethrow;
    } catch (e, st) {
      AppLogger.error('Recommendation AI error', e, st);
      rethrow;
    }
  }

  List<UniversityRecommendation> _parseRecommendations(String content) {
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final list = decoded['universities'] as List<dynamic>? ?? [];
      return list
          .map((e) => UniversityRecommendation.fromJson(
                e as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      debugPrint('Parse error: $e\nContent: $content');
      throw Exception('Failed to parse AI response');
    }
  }

  String _buildPrompt(RecommendationPreferences prefs) {
    final countriesPart = prefs.countries.isEmpty
        ? 'any country worldwide'
        : prefs.countries.join(', ');

    final climatesPart = prefs.climates.isEmpty
        ? 'any climate'
        : prefs.climates.join(', ');

    return '''
Student Profile for University Recommendation:

- **Preferred Countries:** $countriesPart
- **Annual Budget (tuition + living):** \$${prefs.budgetMin.toStringAsFixed(0)} – \$${prefs.budgetMax.toStringAsFixed(0)}
- **IELTS Score:** ${prefs.ieltsScore.toStringAsFixed(1)}
- **GPA:** ${prefs.gpa.toStringAsFixed(1)} / 4.0
- **Desired Major:** ${prefs.major.isEmpty ? 'Open to suggestions' : prefs.major}
- **Career Goals:** ${prefs.careerGoals.isEmpty ? 'Not specified' : prefs.careerGoals}
- **Preferred Climate:** $climatesPart
- **Wants to Work After Graduation:** ${prefs.workAfterGraduation ? 'Yes — prioritize countries with good post-study work visa options' : 'Not a priority'}

Generate 10 personalized university recommendations that best match this student. Return a JSON object in this exact format:

{
  "universities": [
    {
      "id": "unique_id",
      "name": "Full University Name",
      "country": "Country Name",
      "flag": "🇺🇸",
      "city": "City Name",
      "universityScore": 92,
      "acceptanceProbability": 75,
      "estimatedTuition": "\$55,000/year",
      "livingExpenses": "\$18,000/year",
      "scholarshipAvailability": "Merit-based",
      "applicationDeadline": "Jan 15, 2026",
      "ranking": 1,
      "employmentRate": 95,
      "major": "Computer Science",
      "climate": "Temperate",
      "matchReason": "Top CS program with strong AI research matching your career goals. IELTS requirement of 6.5+ aligns well. Generous merit scholarships available.",
      "website": "https://mit.edu"
    }
  ]
}

Rules:
- universityScore: 0-100 overall match considering all factors
- acceptanceProbability: realistic estimate based on IELTS/GPA vs university requirements
- scholarshipAvailability: one of "Full", "Partial", "Merit-based", "Need-based", "Limited", "None"
- employmentRate: realistic graduate employment rate percentage
- ranking: QS World University Ranking number
- Prioritize diversity across tiers (reach, match, safety schools)
- If work after graduation is important, prioritize UK (Graduate Route), Canada (PGWP), Australia (485), Germany
- Return exactly 10 universities
''';
  }

  static const _systemPrompt = '''
You are an expert international university admissions counselor with 20+ years of experience. 
You have deep knowledge of global university rankings, admission requirements, scholarships, and graduate employment statistics.
You always return valid JSON matching the exact schema requested. All data should be realistic and accurate as of 2025-2026.
Consider the student's full profile holistically when scoring and selecting universities.
''';
}
