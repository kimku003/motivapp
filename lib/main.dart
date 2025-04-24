import 'package:flutter/material.dart';
import 'dart:math' as math;

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
        brightness: Brightness.dark,
      ),
      home: const MotivationScreen(),
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
  final List<String> _motivationalQuotes = [
    "Crois en toi, et tout devient possible.",
    "Chaque jour est une nouvelle opportunité.",
    "Le succès commence par un seul pas.",
    "Ta seule limite, c'est toi.",
    "Le futur appartient à ceux qui croient en leurs rêves.",
    "La persévérance est la clé de la réussite.",
    "N'abandonne jamais ce qui te fait briller.",
  ];

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
