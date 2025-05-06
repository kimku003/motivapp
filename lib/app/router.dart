import 'package:flutter/material.dart';
import '../features/motivation/presentation/screens/motivation_screen.dart';
import '../features/quiz/presentation/screens/quiz_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/motivation/data/services/quotes_service.dart';
import '../features/motivation/data/services/quotes_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Déclarez les variables late
late SharedPreferences sharedPreferences;
late QuotesCacheService quotesCacheService;
late QuotesService quotesService;

// Créez une fonction d'initialisation
Future<void> initializeServices() async {
  sharedPreferences = await SharedPreferences.getInstance();
  quotesCacheService = QuotesCacheService(sharedPreferences);
  quotesService = QuotesService(quotesCacheService);
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/motivation':
        return MaterialPageRoute(
            builder: (_) => MotivationScreen(quotesService: quotesService));
      case '/quiz':
        return MaterialPageRoute(builder: (_) => const QuizScreen());
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
