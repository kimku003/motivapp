import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/spicy_question_model.dart';
import './spicy_quiz_cache_service.dart';

class SpicyQuizService {
  static const String _url =
      'https://raw.githubusercontent.com/kimku003/quotes/main/quiz_sarcastique.json';

  final SpicyQuizCacheService _cacheService;

  SpicyQuizService(this._cacheService);

  Future<List<SpicyQuestion>> fetchQuestions() async {
    try {
      // Vérifier le cache d'abord
      if (!_cacheService.shouldUpdate()) {
        final cachedQuestions = await _cacheService.getCachedQuestions();
        if (cachedQuestions != null) {
          print('Using cached spicy questions');
          return cachedQuestions;
        }
      }

      print('Fetching spicy questions from: $_url');
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        // Décode la réponse en tant que List
        final List<dynamic> jsonList = json.decode(response.body);

        // Convertit chaque élément en SpicyQuestion
        final questions = jsonList
            .map((json) => SpicyQuestion.fromJson(json as Map<String, dynamic>))
            .toList();

        // Met en cache les questions
        await _cacheService.cacheQuestions(questions);
        return questions;
      } else {
        throw Exception(
            'Failed to load spicy questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching spicy questions: $e');

      // Essaie d'utiliser le cache en cas d'erreur
      final cachedQuestions = await _cacheService.getCachedQuestions();
      if (cachedQuestions != null) {
        return cachedQuestions;
      }

      rethrow;
    }
  }
}
