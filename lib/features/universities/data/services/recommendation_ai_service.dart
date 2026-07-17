import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:globaledu_ai/core/config/env_config.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/features/universities/domain/entities/recommendation_filters.dart';
import 'package:globaledu_ai/features/universities/domain/entities/university_recommendation.dart';
import 'package:http/http.dart' as http;

class RecommendationAiService {
  RecommendationAiService._();
  static final instance = RecommendationAiService._();

  final _baseUrl = 'https://api.openai.com/v1/chat/completions';
  String get _apiKey => EnvConfig.openAiApiKey;

  /// Builds prompt and calls OpenAI; returns parsed recommendations.
  Future<List<UniversityRecommendation>> getRecommendations(
    RecommendationPreferences prefs,
  ) async {
    final prompt = _buildPrompt(prefs);

    try {
      final body = jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 4000,
        'response_format': {'type': 'json_object'},
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        AppLogger.error('AI error ${response.statusCode}: ${response.body}');
        throw Exception('AI service error: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          json['choices'][0]['message']['content'] as String;

      return _parseRecommendations(content);
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
