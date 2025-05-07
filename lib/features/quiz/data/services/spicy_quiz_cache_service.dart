import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/spicy_question_model.dart';

class SpicyQuizCacheService {
  static const String _cacheKey = 'cached_spicy_quiz';
  static const String _lastUpdateKey = 'last_spicy_update';

  final SharedPreferences _prefs;

  SpicyQuizCacheService(this._prefs);

  Future<void> cacheQuestions(List<SpicyQuestion> questions) async {
    final questionsJson = json.encode(
      questions
          .map((q) => {
                'question': q.question,
                'answers': q.answers
                    .map((a) => {
                          'text': a.text,
                          'message': a.message,
                        })
                    .toList(),
              })
          .toList(),
    );

    await _prefs.setString(_cacheKey, questionsJson);
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<List<SpicyQuestion>?> getCachedQuestions() async {
    final cachedData = _prefs.getString(_cacheKey);
    if (cachedData == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => SpicyQuestion.fromJson(json)).toList();
    } catch (e) {
      print('Error reading cached spicy questions: $e');
      return null;
    }
  }

  bool shouldUpdate() {
    final lastUpdate = _prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    return DateTime.now().difference(lastUpdateTime).inHours > 24;
  }
}
