import 'package:flutter/material.dart';
import '../features/motivation/presentation/screens/motivation_screen.dart';
import '../features/quiz/presentation/screens/quiz_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/motivation/data/services/quotes_service.dart';
import '../features/motivation/data/services/quotes_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/quiz/data/services/quiz_service.dart';
import '../features/quiz/presentation/screens/questions_screen.dart';
import '../features/quiz/data/services/spicy_quiz_service.dart';
import '../features/quiz/data/services/spicy_quiz_cache_service.dart';
import '../features/quiz/data/services/quiz_cache_service.dart';

// Déclarez les variables late
late SharedPreferences sharedPreferences;
late QuotesCacheService quotesCacheService;
late QuotesService quotesService;
late QuizService quizService;
late SpicyQuizService spicyQuizService;

// Créez une fonction d'initialisation
Future<void> initializeServices() async {
  sharedPreferences = await SharedPreferences.getInstance();

  // Services pour les citations
  quotesCacheService = QuotesCacheService(sharedPreferences);
  quotesService = QuotesService(quotesCacheService);

  // Services pour le quiz culture générale
  final quizCacheService = QuizCacheService(sharedPreferences);
  quizService = QuizService(quizCacheService);

  // Services pour le quiz sarcastique
  spicyQuizService = SpicyQuizService(
    SpicyQuizCacheService(sharedPreferences),
  );
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/motivation':
        return MaterialPageRoute(
            builder: (_) => MotivationScreen(quotesService: quotesService));
      case '/quiz':
        return MaterialPageRoute(
            builder: (_) => QuizScreen(
                quizService: quizService, spicyQuizService: spicyQuizService));
      case '/game':
        return MaterialPageRoute(builder: (_) => const GameScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Page not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
