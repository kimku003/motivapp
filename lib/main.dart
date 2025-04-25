import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'features/motivation/data/quotes.dart'; // Import des citations
import 'features/quiz/presentation/screens/quiz_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/game/presentation/screens/game2_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Motivation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/motivation',
    );
  }
}

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({Key? key}) : super(key: key);

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentQuoteIndex = 0;
  QuoteMode _quoteMode = QuoteMode.motivation;

  List<String> get _currentQuotes =>
      _quoteMode == QuoteMode.motivation ? motivationalQuotes : spicyQuotes;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _currentQuotes.length;
    });
  }

  void _toggleQuoteMode() {
    setState(() {
      _quoteMode = _quoteMode == QuoteMode.motivation
          ? QuoteMode.spicy
          : QuoteMode.motivation;
      _currentQuoteIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _changeQuote,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade900, Colors.purple.shade900],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRotatingIcon(),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 40),
                _buildQuoteText(),
                const SizedBox(height: 40),
                const Text(
                  "Touchez l'écran pour changer de citation",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 40),
                _buildNavigationButtons(),
                const SizedBox(height: 20),
                _buildModeToggle(), // Ajouter un bouton ou un switch pour changer de mode
              ],
            ),
          ),
        ),
      ),
    );
  }

  AnimatedBuilder _buildRotatingIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 5),
          ],
        ),
        child: const Icon(Icons.star, color: Colors.white, size: 80),
      ),
    );
  }

  AnimatedSwitcher _buildQuoteText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        _currentQuotes[_currentQuoteIndex],
        key: ValueKey<int>(_currentQuoteIndex),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 10.0, color: Colors.white, offset: Offset(0, 0)),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  ElevatedButton _buildNavigationButton(
      String text, String routeName, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Column _buildNavigationButtons() {
    return Column(
      children: [
        _buildNavigationButton("Commencer un quiz", '/quiz', Colors.indigo),
        const SizedBox(height: 20),
        _buildNavigationButton("Jouer à un jeu", '/game', Colors.green),
        const SizedBox(height: 20),
        _buildNavigationButton("Jouer au second jeu", '/game2', Colors.orange),
      ],
    );
  }

  // Ajouter un bouton ou un switch pour changer de mode
  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _quoteMode == QuoteMode.motivation ? "Mode Motivation" : "Mode Spicy",
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: _toggleQuoteMode,
          icon: Icon(
            _quoteMode == QuoteMode.motivation ? Icons.star : Icons.warning,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}

enum QuoteMode { motivation, spicy }

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/motivation':
        return MaterialPageRoute(builder: (_) => const MotivationScreen());
      case '/quiz':
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      case '/game':
        return MaterialPageRoute(builder: (_) => const GameScreen());
      case '/game2':
        return MaterialPageRoute(builder: (_) => const Game2Screen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
    }
  }
}
