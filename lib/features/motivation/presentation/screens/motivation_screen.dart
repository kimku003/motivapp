import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart'; // Pour les illustrations vectorielles
import '../../data/quotes.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({Key? key}) : super(key: key);

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentQuoteIndex = 0;
  final List<String> _motivationalQuotes = motivationalQuotes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeQuote() {
    setState(() {
      _currentQuoteIndex =
          (_currentQuoteIndex + 1) % _motivationalQuotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MotivationScreen is being displayed'); // Log pour confirmation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6), // Icône pour changer de thème
            onPressed: () {
              // Basculer entre les thèmes clair/sombre
              final brightness = Theme.of(context).brightness;
              final newBrightness = brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark;
              setState(() {
                ThemeMode mode = newBrightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light;
                // Appliquer le mode (nécessite un gestionnaire de thème global)
              });
            },
          ),
        ],
      ),
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
                // Affichage des SVG
                SvgPicture.asset(
                  'assets/images/hot-air-balloon-svgrepo-com.svg',
                  height: 150,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  'assets/images/tent-svgrepo-com.svg',
                  height: 150,
                ),
                const SizedBox(height: 60),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _motivationalQuotes[_currentQuoteIndex],
                    key: ValueKey<int>(_currentQuoteIndex),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.white,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
                Text('MotivationScreen is active'), // Texte temporaire
              ],
            ),
          ),
        ),
      ),
    );
  }
}
