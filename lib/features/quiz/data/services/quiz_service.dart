import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question_model.dart';
import './quiz_cache_service.dart';

class QuizService {
  static const String _url =
      'https://raw.githubusercontent.com/kimku003/quotes/main/quizz_culture.json';

  final QuizCacheService _cacheService;

  QuizService(this._cacheService);

  Future<List<Question>> fetchQuestions() async {
    try {
      if (!_cacheService.shouldUpdate()) {
        final cachedQuestions = await _cacheService.getCachedQuestions();
        if (cachedQuestions != null) {
          print('Using cached quiz questions');
          return cachedQuestions;
        }
      }

      print('Fetching questions from $_url');
      final response = await http.get(Uri.parse(_url));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse as a List directly since the JSON is an array
        final List<dynamic> jsonList = json.decode(response.body);
        final questions = jsonList
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();

        // Cache the questions
        await _cacheService.cacheQuestions(questions);
        return questions;
      } else {
        // Try to use cached questions on error
        final cachedQuestions = await _cacheService.getCachedQuestions();
        if (cachedQuestions != null) {
          return cachedQuestions;
        }
        throw Exception(
            'Failed to load quiz questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchQuestions: $e');
      // Try to use cached questions on error
      final cachedQuestions = await _cacheService.getCachedQuestions();
      if (cachedQuestions != null) {
        return cachedQuestions;
      }
      throw Exception('Error fetching quiz questions: $e');
    }
  }

  // Fonction utilitaire pour mélanger les questions
  List<Question> shuffleQuestions(List<Question> questions, {int? limit}) {
    final shuffled = List<Question>.from(questions)..shuffle();
    if (limit != null && limit < shuffled.length) {
      return shuffled.take(limit).toList();
    }
    return shuffled;
  }

  // Fonction pour obtenir un sous-ensemble de questions pour un quiz
  Future<List<Question>> getQuizQuestions({int numberOfQuestions = 10}) async {
    final questions = await fetchQuestions();
    return shuffleQuestions(questions, limit: numberOfQuestions);
  }

  // Fonction pour vérifier une réponse
  bool checkAnswer(Question question, String userAnswer) {
    return question.reponse.toLowerCase() == userAnswer.toLowerCase();
  }

  // Fonction pour obtenir tous les indices mélangés (incluant la bonne réponse)
  List<String> getAllOptions(Question question) {
    return question.getAllOptions();
  }
}
