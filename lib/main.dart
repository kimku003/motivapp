import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'features/quiz/presentation/screens/quiz_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/game/presentation/screens/game2_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/motivation',
    );
  }
}

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final QuotesService _quotesService = QuotesService();
  List<Quote> _quotes = [];
  int _currentQuoteIndex = 0;
  QuoteMode _quoteMode = QuoteMode.motivation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final response = await _quotesService.fetchQuotes();
      setState(() {
        _quotes = response.quotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quotes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Quote> get _currentQuotes {
    return _quotes
        .where((quote) =>
            quote.category ==
            (_quoteMode == QuoteMode.motivation ? "motivational" : "spicy"))
        .toList();
  }

  void _changeQuote() {
    if (_currentQuotes.isNotEmpty) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _currentQuotes.length;
      });
    }
  }

  void _toggleQuoteMode() {
    setState(() {
      _quoteMode = _quoteMode == QuoteMode.motivation
          ? QuoteMode.spicy
          : QuoteMode.motivation;
      _currentQuoteIndex = 0;
    });
  }

  Color _getBackgroundColor() {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 18) {
      // Nuit
      return Colors.indigo.shade900;
    } else if (hour < 12) {
      // Matin
      return Colors.blue.shade800;
    } else {
      // Après-midi
      return Colors.purple.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    return Scaffold(
      body: GestureDetector(
        onTap: _changeQuote,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getBackgroundColor(),
                Color.lerp(
                  _getBackgroundColor(),
                  Colors.deepPurple,
                  0.7,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Particules flottantes en arrière-plan
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlesPainter(controller: _controller),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildRotatingIcon(),
                        const SizedBox(height: 30),
                        _buildQuoteCard(),
                        const SizedBox(height: 20),
                        _buildProgressIndicator(),
                        const SizedBox(height: 20),
                        _buildNavigationButtons(),
                        const SizedBox(height: 20),
                        _buildModeToggle(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 200,
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 10),
        onEnd: _changeQuote,
        builder: (BuildContext context, double value, Widget? child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _quoteMode == QuoteMode.motivation
                    ? Colors.blueAccent
                    : Colors.redAccent,
              ),
              minHeight: 10,
            ),
          );
        },
      ),
    );
  }

// Nouveau widget pour la carte de citation
  Widget _buildQuoteCard() {
    return Card(
      elevation: 10,
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    key: ValueKey<String>(_currentQuotes.isNotEmpty
                        ? _currentQuotes[_currentQuoteIndex].id
                        : ''),
                    children: [
                      // Citation en français
                      Text(
                        _currentQuotes.isNotEmpty
                            ? _currentQuotes[_currentQuoteIndex]
                                    .translations['fr'] ??
                                ''
                            : 'Aucune citation disponible',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Citation en anglais
                      Text(
                        _currentQuotes.isNotEmpty
                            ? _currentQuotes[_currentQuoteIndex]
                                    .translations['en'] ??
                                ''
                            : 'No quote available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Citation en coréen
                      Text(
                        _currentQuotes.isNotEmpty
                            ? _currentQuotes[_currentQuoteIndex]
                                    .translations['ko'] ??
                                ''
                            : '인용구 없음',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Auteurs dans les trois langues
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentQuotes.isNotEmpty
                                  ? "- ${_currentQuotes[_currentQuoteIndex].from['fr'] ?? ''}"
                                  : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _currentQuotes.isNotEmpty
                                  ? "- ${_currentQuotes[_currentQuoteIndex].from['en'] ?? ''}"
                                  : '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _currentQuotes.isNotEmpty
                                  ? "- ${_currentQuotes[_currentQuoteIndex].from['ko'] ?? ''}"
                                  : '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          child: Transform.scale(
            scale: 1 + math.sin(_controller.value * math.pi * 2) * 0.1,
            child: child,
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.1, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueAccent,
                Colors.purpleAccent,
              ],
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  AnimatedSwitcher _buildQuoteText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        _currentQuotes.isNotEmpty
            ? _currentQuotes[_currentQuoteIndex].translations['fr'] ?? ''
            : "Loading...",
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

  Widget _buildNavigationButton(String text, String routeName, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.white, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForRoute(routeName),
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRoute(String routeName) {
    switch (routeName) {
      case '/quiz':
        return Icons.quiz;
      case '/game':
        return Icons.gamepad;
      case '/game2':
        return Icons.sports_esports;
      default:
        return Icons.star;
    }
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

  Widget _buildModeToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _quoteMode == QuoteMode.motivation ? "Motivation" : "Spicy",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _toggleQuoteMode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _quoteMode == QuoteMode.motivation
                    ? Colors.blueAccent.withOpacity(0.7)
                    : Colors.redAccent.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _quoteMode == QuoteMode.motivation
                    ? Icons.emoji_emotions
                    : Icons.emoji_objects,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final AnimationController controller;

  _ParticlesPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random();
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      final offset = Offset(x, y + controller.value * 20 % size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

class QuotesService {
  static const String _url =
      'https://raw.githubusercontent.com/kimku003/quotes/main/quotes.json';

  Future<QuotesResponse> fetchQuotes() async {
    try {
      print('Fetching quotes from: $_url'); // Debug log

      final response = await http.get(Uri.parse(_url));
      print('Response status code: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debug log
        final decodedData = json.decode(response.body);
        return QuotesResponse.fromJson(decodedData);
      } else {
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quotes: $e'); // Debug log
      throw Exception('Error fetching quotes: $e');
    }
  }
}

class QuotesResponse {
  final String lastUpdated;
  final List<Quote> quotes;

  QuotesResponse({
    required this.lastUpdated,
    required this.quotes,
  });

  factory QuotesResponse.fromJson(Map<String, dynamic> json) {
    return QuotesResponse(
      lastUpdated: json['last_updated'] as String,
      quotes: (json['quotes'] as List)
          .map((quote) => Quote.fromJson(quote))
          .toList(),
    );
  }
}

class Quote {
  final String id;
  final Map<String, String> translations;
  final Map<String, String> from; // Changed from String to Map<String, String>
  final List<String> tags;
  final String category;

  Quote({
    required this.id,
    required this.translations,
    required this.from,
    required this.tags,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      translations: Map<String, String>.from(json['translations']),
      from: Map<String, String>.from(json['from']), // Parse from as a Map
      tags: List<String>.from(json['tags']),
      category: json['category'] as String,
    );
  }
}
