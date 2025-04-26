import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late int _secretNumber;
  int? _userGuess;
  int _attempts = 0;
  String _message = 'Devinez entre 1 et 100 (7 essais max)';
  final TextEditingController _guessController = TextEditingController();
  bool _gameWon = false;
  bool _gameLost = false;
  final List<int> _guessHistory = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  final List<String> passiveMessages = [
    "🤷‍♂️ Peut-être que tu es meilleur en cuisine ?",
    "🙃 Essaie encore, tu finiras par faire un heureux hasard.",
    "😬 C’est pas grave, tout le monde ne peut pas être bon en chiffres.",
    "🧠 Je t'aurais aidé, mais j'aime te voir galérer.",
    "😅 C’est audacieux, comme choix.",
    "🫣 Tu veux un indice ? Ah... c’est dommage, y'en a pas."
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
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
        _confettiController.play(); // confettis ironiques rouges 😈
        Future.delayed(const Duration(milliseconds: 500), _showLossDialog);
      } else {
        bool useSarcasm = _random.nextBool();
        if (useSarcasm) {
          _message = passiveMessages[_random.nextInt(passiveMessages.length)];
        } else {
          _message = guess < _secretNumber
              ? '📈 Plus grand ! (Essai $_attempts/7)'
              : '📉 Plus petit ! (Essai $_attempts/7)';
        }
      }
    });
  }

  void _showLossDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Encore raté..."),
        content: const Text("Mais tu progresses... probablement."),
        actions: [
          TextButton(
            child: const Text("Je suppose que je réessaie..."),
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (_attempts >= 3 && !_gameWon && !_gameLost)
        ? Colors.grey.shade300
        : Colors.blue.shade100;

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
                  backgroundColor,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.4,
              numberOfParticles: 30,
              maxBlastForce: 15,
              minBlastForce: 5,
              gravity: 0.3,
              colors: _gameWon
                  ? [Colors.green, Colors.blue]
                  : [Colors.red, Colors.black],
            ),
          ),
        ],
      ),
    );
  }
}
