import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

class QuizCacheService {
  static const String _cacheKey = 'cached_quiz_questions';
  static const String _lastUpdateKey = 'last_quiz_update';

  final SharedPreferences _prefs;

  QuizCacheService(this._prefs);

  Future<void> cacheQuestions(List<Question> questions) async {
    final String questionsJson = json.encode(
      questions.map((q) => q.toJson()).toList(),
    );

    await _prefs.setString(_cacheKey, questionsJson);
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<List<Question>?> getCachedQuestions() async {
    final String? cachedData = _prefs.getString(_cacheKey);
    if (cachedData == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();
    } catch (e) {
      print('Error reading cached questions: $e');
      return null;
    }
  }

  bool shouldUpdate() {
    final String? lastUpdate = _prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final difference = DateTime.now().difference(lastUpdateTime);
    return difference.inHours > 24;
  }
}
