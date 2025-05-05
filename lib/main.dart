import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/quiz/presentation/screens/quiz_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/game/presentation/screens/game2_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  runApp(const MyApp());
}

Future<void> initializeServices() async {
  final prefs = await SharedPreferences.getInstance();
  final cacheService = QuotesCacheService(prefs);
  // Additional service initialization can be added here
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
      onGenerateRoute: (settings) {
        return AppRouter.generateRoute(RouteSettings(
          name: settings.name,
        ));
      },
      initialRoute: '/motivation',
    );
  }
}

class MotivationScreen extends StatefulWidget {
  final QuotesService quotesService;

  const MotivationScreen({super.key, required this.quotesService});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
      final response = await widget.quotesService.fetchQuotes();
      setState(() {
        _quotes = response.quotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quotes: $e');
      setState(() {
        _isLoading = false;
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading quotes: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadQuotes,
        child: GestureDetector(
          onTap: _changeQuote,
        ),
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
    // Get the QuotesService from the settings arguments
    final args = settings.arguments as Map<String, dynamic>?;
    final quotesService = args?['quotesService'] as QuotesService?;

    switch (settings.name) {
      case '/motivation':
        return MaterialPageRoute(
          builder: (_) => MotivationScreen(
            quotesService: quotesService!,
          ),
        );
      default:
        throw Exception('Route not found: ${settings.name}');
    }
  }
}

class QuotesService {
  final QuotesCacheService cacheService;

  QuotesService(this.cacheService);

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
        cacheService.saveQuotes(response.body);
        return QuotesResponse.fromJson(decodedData);
      } else {
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quotes: $e'); // Debug log
      final cachedData = cacheService.getCachedQuotes();
      if (cachedData != null) {
        return QuotesResponse.fromJson(json.decode(cachedData));
      }
      throw Exception('Error fetching quotes: $e');
    }
  }
}

class QuotesCacheService {
  final SharedPreferences prefs;

  QuotesCacheService(this.prefs);

  void saveQuotes(String quotesJson) {
    prefs.setString('cached_quotes', quotesJson);
  }

  String? getCachedQuotes() {
    return prefs.getString('cached_quotes');
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
