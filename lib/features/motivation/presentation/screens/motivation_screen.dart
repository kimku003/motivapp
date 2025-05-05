import 'package:flutter/material.dart';
import 'dart:math' as math;
//import '../../data/quotes.dart'; // Import des citations

// Ensure the Quote class is defined or imported correctly
import '../../data/models/quote_model.dart'; // Adjust the path to where the Quote class is defined
import '../../data/services/quotes_service.dart'; // Import du service de citations

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

// Enum pour définir le mode de citation
enum QuoteMode { motivation, spicy }

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
      print('Quotes loaded: ${response.quotes.length}'); // Debug log
      setState(() {
        _quotes = response.quotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadQuotes: $e'); // Debug log
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Quote> get _currentQuotes {
    final filtered = _quotes
        .where((quote) =>
            quote.category ==
            (_quoteMode == QuoteMode.motivation ? "motivational" : "spicy"))
        .toList();
    print('Filtered quotes: ${filtered.length}'); // Debug log
    return filtered;
  }

  // Fonction pour changer de citation
  void _changeQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _currentQuotes.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              colors: [
                Colors.indigo.shade900,
                Colors.purple.shade900,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
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
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 40),

                // Toggle Buttons pour changer entre motivation et spicy
                ToggleButtons(
                  isSelected: [
                    _quoteMode == QuoteMode.motivation,
                    _quoteMode == QuoteMode.spicy,
                  ],
                  onPressed: (index) {
                    setState(() {
                      _quoteMode = QuoteMode.values[index];
                      _currentQuoteIndex = 0; // Reset index
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: Colors.deepPurpleAccent,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Motivation"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Roast doux"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Affichage de la citation avec animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Card(
                          color: Colors.black.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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

                                // Auteur dans les trois langues
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
                                            ? "- ${_currentQuotes[_currentQuoteIndex].from[2] ?? ''}" // Assuming '2' is the correct integer key for 'fr'
                                            : '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _currentQuotes.isNotEmpty
                                            ? "- ${_currentQuotes[_currentQuoteIndex].from[1] ?? ''}" // Assuming '1' is the correct integer key for 'en'
                                            : '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        _currentQuotes.isNotEmpty
                                            ? "- ${_currentQuotes[_currentQuoteIndex].from[0] ?? ''}" // Assuming '0' is the correct key
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
                const SizedBox(height: 40),
                Text(
                  "Touchez l'écran pour changer de citation",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Boutons pour navigation
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/quiz');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Commencer un quiz",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/game');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Jouer à un jeu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/game2');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Jouer au second jeu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
