import 'package:flutter/material.dart';
import '../features/motivation/presentation/screens/motivation_screen.dart';
import '../features/quiz/presentation/screens/quiz_screen.dart'; // Import de QuizScreen
import '../features/game/presentation/screens/game_screen.dart'; // Import de la page de jeu

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/motivation':
        return MaterialPageRoute(builder: (_) => const MotivationScreen());
      case '/quiz': // Route pour le quiz
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      case '/game': // Nouvelle route pour le jeu
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
