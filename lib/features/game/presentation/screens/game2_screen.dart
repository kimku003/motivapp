import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class Game2Screen extends StatefulWidget {
  const Game2Screen({Key? key}) : super(key: key);

  @override
  State<Game2Screen> createState() => _Game2ScreenState();
}

class _Game2ScreenState extends State<Game2Screen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': "Quel est l'animal le plus rapide ?",
      'correct': "Le guépard",
      'wrong': ["Le paresseux", "La tortue", "L'escargot"],
      'hint': "Il court plus vite que votre frustration"
    },
    {
      'question': "Quelle est la capitale de la France ?",
      'correct': "Paris",
      'wrong': ["Londres", "Berlin", "Madrid"],
      'hint': "La ville de l'amour... et de votre désespoir"
    },
    {
      'question': "2 + 2 = ?",
      'correct': "4",
      'wrong': ["22", "5", "3.99"],
      'hint': "Même un calcul simple devient compliqué ici"
    },
  ];

  int _currentQuestionIndex = 0;
  int _failedAttempts = 0;
  bool _showFeedback = false;
  bool _showFakeSuccess = false;
  late AnimationController _animationController;
  late ConfettiController _confettiController;
  final Random _random = Random();
  double _buttonScale = 1.0;
  bool _isButtonRotating = false;
  double _rotationAngle = 0;
  final List<String> _sarcasticComments = [
    "Bravo... presque!",
    "C'était vraiment la pire réponse",
    "tu vois ta vie",
    "Vous avez un don pour l'échec",
    "Même ma grand-mère ferait mieux",
    "Vous y êtes presque... non en fait pas du tout",
    "Continuez comme ça... si vous voulez échouer",
    "toi tu es bête",
    "Tu devrais retourner à l'école",
    "C'est dans manger tu es fort"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1), // Initialisation correcte
    );
  }

  List<Map<String, dynamic>> _getShuffledAnswers() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final answers = [
      {'text': currentQuestion['correct'], 'isCorrect': true},
      ...currentQuestion['wrong'].map((wrongAnswer) => {
            'text': wrongAnswer,
            'isCorrect': false,
          } as Map<String, dynamic>),
    ];
    answers.shuffle(_random);
    return answers.cast<Map<String, dynamic>>();
  }

  void _onAnswerTap(bool isCorrect) {
    if (isCorrect) {
      // 10% de chance de montrer un faux succès
      if (_random.nextDouble() < 0.1) {
        _showFakeCongratulations();
      } else {
        _moveCorrectAnswer();
      }
    } else {
      _showSarcasticFeedback();
    }
    setState(() {
      _failedAttempts++;
    });
  }

  void _showFakeCongratulations() {
    setState(() {
      _showFakeSuccess = true;
      _confettiController.play();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showFakeSuccess = false;
        _moveCorrectAnswer(); // Après le faux succès, la bonne réponse fuit quand même
      });
    });
  }

  void _moveCorrectAnswer() {
    setState(() {
      _buttonScale = 0.5;
      _isButtonRotating = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _buttonScale = 1.0;
        _rotationAngle += pi / 2;
      });
    });
  }

  void _showSarcasticFeedback() {
    setState(() {
      _showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showFeedback = false;
      });
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
      _failedAttempts = 0;
      _rotationAngle = 0;
      _isButtonRotating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final shuffledAnswers = _getShuffledAnswers();
    final sarcasticComment =
        _sarcasticComments[_random.nextInt(_sarcasticComments.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Jeu le Plus Frustrant du Monde'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Niveau de frustration',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Badge(
                label: Text('$_failedAttempts'),
                child: const Icon(Icons.mood_bad),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Question avec indice moqueur
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Indice: ${currentQuestion['hint']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Réponses avec animations
          Expanded(
            child: ListView.builder(
              itemCount: shuffledAnswers.length,
              itemBuilder: (context, index) {
                final answer = shuffledAnswers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () => _onAnswerTap(answer['isCorrect']),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: answer['isCorrect'] ? _buttonScale : 1.0,
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 500),
                        turns: answer['isCorrect'] && _isButtonRotating
                            ? _rotationAngle / (2 * pi)
                            : 0,
                        child: ElevatedButton(
                          onPressed: () => _onAnswerTap(answer['isCorrect']),
                          style: _buttonStyle(Colors.blue),
                          child: Text(
                            answer['text'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Feedback sarcastique
          if (_showFeedback)
            Center(
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sarcasticComment,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.mood_bad, size: 50, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ),

          // Faux succès
          if (_showFakeSuccess)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'BRAVO ! ... NON JE DÉCONNE 😈',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.emoji_emotions,
                    size: 60,
                    color: Colors.amber[400],
                  ),
                ],
              ),
            ),

          // Confettis (pour le faux succès)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.red, Colors.blue, Colors.green],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _nextQuestion,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.skip_next),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Non non, ce jeu est censé être impossible 😈",
                    style: TextStyle(color: Colors.red[200]),
                  ),
                  backgroundColor: Colors.grey[800],
                ),
              );
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.help),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose(); // Libération des ressources
    super.dispose();
  }
}
