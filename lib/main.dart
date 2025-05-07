import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/quiz/presentation/screens/quiz_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/game/presentation/screens/game2_screen.dart';
import 'features/quiz/data/services/quiz_cache_service.dart';
import 'features/quiz/data/services/quiz_service.dart';
import 'features/quiz/data/services/spicy_quiz_service.dart';
import 'features/quiz/data/services/spicy_quiz_cache_service.dart';
import 'features/quiz/presentation/screens/culture_quiz_screen.dart';
import 'features/motivation/presentation/screens/motivation_screen.dart';
import 'features/motivation/data/services/quotes_service.dart';
import 'features/motivation/data/services/quotes_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Services pour les citations
  final quotesCacheService = QuotesCacheService(prefs);
  final quotesService = QuotesService(quotesCacheService);

  // Services pour le quiz culture générale
  final quizCacheService = QuizCacheService(prefs);
  final quizService = QuizService(quizCacheService);

  // Services pour le quiz sarcastique
  final spicyQuizCacheService = SpicyQuizCacheService(prefs);
  final spicyQuizService =
      SpicyQuizService(spicyQuizCacheService); // Fixed this line

  runApp(MyApp(
    quotesService: quotesService,
    quizService: quizService,
    spicyQuizService: spicyQuizService,
  ));
}

class MyApp extends StatelessWidget {
  final QuotesService quotesService;
  final QuizService quizService;
  final SpicyQuizService spicyQuizService;

  const MyApp({
    super.key,
    required this.quotesService,
    required this.quizService,
    required this.spicyQuizService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Motivation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      home: MainNavigationScreen(
        quotesService: quotesService,
        quizService: quizService,
        spicyQuizService: spicyQuizService,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final QuotesService quotesService;
  final QuizService quizService;
  final SpicyQuizService spicyQuizService;

  const MainNavigationScreen({
    super.key,
    required this.quotesService,
    required this.quizService,
    required this.spicyQuizService,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                kBottomNavigationBarHeight -
                MediaQuery.of(context).padding.top,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                MotivationScreen(quotesService: widget.quotesService),
                QuizScreen(
                  quizService: widget.quizService,
                  spicyQuizService: widget.spicyQuizService,
                ),
                const GameScreen(),
                const Game2Screen(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Citations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Jeu 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Jeu 2',
          ),
        ],
      ),
    );
  }
}
