import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:confetti/confetti.dart'; // Ajoutez cette ligne dans pubspec.yaml

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late int _secretNumber;
  int? _userGuess;
  int _attempts = 0;
  String _message = 'Devinez entre 1 et 100';
  final TextEditingController _guessController = TextEditingController();
  bool _gameWon = false;
  bool _gameLost = false;
  final List<int> _guessHistory = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    _startNewGame();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      _secretNumber = _random.nextInt(100) + 1;
      _userGuess = null;
      _attempts = 0;
      _message = 'Devinez entre 1 et 100 (7 essais max)';
      _gameWon = false;
      _gameLost = false;
      _guessHistory.clear();
      _guessController.clear();
      _confettiController.stop();
    });
  }

  void _checkGuess() {
    if (_gameWon || _gameLost) return;

    final guess = int.tryParse(_guessController.text);

    if (guess == null || guess < 1 || guess > 100) {
      setState(() => _message = '❌ Entre 1 et 100 seulement !');
      _animationController.forward(from: 0);
      return;
    }

    setState(() {
      _userGuess = guess;
      _attempts++;
      _guessHistory.add(guess);
      _guessController.clear();
      _animationController.forward(from: 0);

      if (guess == _secretNumber) {
        _message = '🎉 Bravo ! $_secretNumber en $_attempts essais !';
        _gameWon = true;
        _confettiController.play();
      } else if (_attempts >= 7) {
        _message = '😢 Perdu ! Le nombre était $_secretNumber';
        _gameLost = true;
      } else if (guess < _secretNumber) {
        _message = '📈 Plus grand ! (Essai ${_attempts}/7)';
      } else {
        _message = '📉 Plus petit ! (Essai ${_attempts}/7)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nombre Mystère'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
            tooltip: 'Nouvelle partie',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Indicateur visuel animé
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _gameWon
                            ? Colors.green.shade100
                            : _gameLost
                                ? Colors.red.shade100
                                : Colors.amber.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gameWon
                              ? Colors.green
                              : _gameLost
                                  ? Colors.red
                                  : Colors.amber,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: _gameWon
                            ? const Text('🎯', style: TextStyle(fontSize: 60))
                            : _gameLost
                                ? const Text('💥',
                                    style: TextStyle(fontSize: 60))
                                : Text(
                                    _userGuess != null ? '$_userGuess' : '?',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Message du jeu avec emoji
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Champ de saisie (caché si partie terminée)
                  if (!_gameWon && !_gameLost) ...[
                    TextField(
                      controller: _guessController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _checkGuess,
                        ),
                      ),
                      onSubmitted: (_) => _checkGuess(),
                    ),

                    const SizedBox(height: 20),

                    // Bouton de validation
                    ElevatedButton(
                      onPressed: _checkGuess,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'VALIDER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Bouton de nouvelle partie après fin de jeu
                    ElevatedButton(
                      onPressed: _startNewGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: _gameWon ? Colors.green : Colors.red,
                      ),
                      child: Text(
                        _gameWon ? 'REJOUER 🎮' : 'REESSAYER 🔄',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Compteur d'essais
                  Text(
                    'Essais: $_attempts/7',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _attempts >= 5 ? Colors.red : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Historique des tentatives
                  if (_guessHistory.isNotEmpty) ...[
                    const Text(
                      'Vos tentatives :',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _guessHistory.map((guess) {
                        return Chip(
                          label: Text('$guess'),
                          avatar: Text(
                            guess == _secretNumber
                                ? '🎯'
                                : guess > _secretNumber
                                    ? '⬇️'
                                    : '⬆️',
                          ),
                          backgroundColor: guess == _secretNumber
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Confetti pour la victoire
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ],
      ),
    );
  }
}
