import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class Game2Screen extends StatefulWidget {
  const Game2Screen({super.key});

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
      'hint': "Il court plus vite que votre frustration",
      'image': '🐆'
    },
    {
      'question': "Quelle est la capitale de la France ?",
      'correct': "Paris",
      'wrong': ["Londres", "Berlin", "Madrid", "Bruxelles", "Rome"],
      'hint': "La ville de l'amour... et de votre désespoir",
      'image': '🗼'
    },
    {
      'question': "2 + 2 = ?",
      'correct': "4",
      'wrong': ["22", "5", "3.99", "π", "🤔", "NaN", "∞"],
      'hint': "Même un calcul simple devient compliqué ici",
      'image': '🧮'
    },
    {
      'question': "Quelle est la couleur du cheval blanc d'Henri IV ?",
      'correct': "Blanc",
      'wrong': ["Noir", "Gris", "Transparent", "Arc-en-ciel", "Invisible"],
      'hint': "Pensez à la question... vraiment",
      'image': '🐎'
    },
    {
      'question': "Combien de doigts a une main normale ?",
      'correct': "5",
      'wrong': ["4", "6", "3.5", "Ça dépend", "42"],
      'hint': "Comptez les vôtres... si vous pouvez",
      'image': '✋'
    },
  ];

  int _currentQuestionIndex = 0;
  int _failedAttempts = 0;
  bool _showFeedback = false;
  bool _showFakeSuccess = false;
  bool _showCorrectAnswer = false;
  late AnimationController _animationController;
  late ConfettiController _confettiController;
  late ConfettiController _fakeConfettiController;
  final Random _random = Random();
  double _buttonScale = 1.0;
  bool _isButtonRotating = false;
  double _rotationAngle = 0;
  bool _isButtonShaking = false;
  final double _shakeOffset = 0;
  bool _showHint = false;
  bool _isAnswerCorrect = false;
  double _opacity = 1.0;
  final List<String> _sarcasticComments = [
    "Bravo... presque!",
    "C'était vraiment la pire réponse",
    "Tu vois ta vie défiler?",
    "Vous avez un don pour l'échec",
    "Même ma grand-mère ferait mieux",
    "Vous y êtes presque... non en fait pas du tout",
    "Continuez comme ça... si vous voulez échouer",
    "Toi tu es spécial(e)",
    "Tu devrais retourner à l'école",
    "C'est en mangeant qu'on devient... oh wait",
    "La réponse D... comme Débile",
    "Félicitations! ...de m'avoir déçu",
    "C'est pas faux... mais c'est pas vrai non plus",
    "Tu as réussi... à me faire perdre espoir",
    "C'était presque bien!",
    "On dirait mon neveu de 3 ans aurait fait mieux",
    "Si c'était un examen, tu serais un arbre maintenant",
    "La réponse était devant toi... comme tes chances de réussir",
    "Tu préfères qu'on parle d'autre chose?",
    "Je vais faire comme si je n'avais pas vu ça"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _fakeConfettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  List<Map<String, dynamic>> _getShuffledAnswers() {
    final currentQuestion = _questions[_currentQuestionIndex];
    List<String> wrongAnswers = List.from(currentQuestion['wrong'] ?? []);

    // Ajout de fausses réponses aléatoires pour certaines questions
    if (_random.nextDouble() < 0.3) {
      wrongAnswers.addAll([
        "Je ne sais pas",
        "Peut-être",
        "42",
        "Google it",
        "Demande à ta mère",
        "C'est pas faux",
        "🤷‍♂️"
      ]);
    }

    final answers = [
      {'text': currentQuestion['correct'] ?? "Inconnu", 'isCorrect': true},
      ...wrongAnswers.map((wrongAnswer) => {
            'text': wrongAnswer,
            'isCorrect': false,
          }),
    ];

    // Mélange plus agressif
    for (int i = 0; i < 5; i++) {
      answers.shuffle(_random);
    }

    return answers;
  }

  void _onAnswerTap(bool isCorrect) {
    if (isCorrect) {
      // 15% de chance de montrer un faux succès
      if (_random.nextDouble() < 0.15) {
        _showFakeCongratulations();
      } else {
        _moveCorrectAnswer();
      }
      _isAnswerCorrect = true;
    } else {
      _showSarcasticFeedback();
      _isAnswerCorrect = false;

      // 30% de chance que le bouton se mette à trembler
      if (_random.nextDouble() < 0.3) {
        _startShaking();
      }

      // 20% de chance que le bouton disparaisse
      if (_random.nextDouble() < 0.2) {
        _makeButtonDisappear();
      }
    }

    setState(() {
      _failedAttempts++;
      _showHint = _failedAttempts >= 2;
    });
  }

  void _showFakeCongratulations() {
    setState(() {
      _showFakeSuccess = true;
      _fakeConfettiController.play();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showFakeSuccess = false;
        _moveCorrectAnswer();
      });
    });
  }

  void _moveCorrectAnswer() {
    setState(() {
      _buttonScale = 0.8;
      _isButtonRotating = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _buttonScale = 1.0;
        _rotationAngle += pi / 2;
        _showCorrectAnswer = true;
      });
    });
  }

  void _startShaking() {
    setState(() {
      _isButtonShaking = true;
    });

    _animationController.reset();
    _animationController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isButtonShaking = false;
      });
      _animationController.stop();
    });
  }

  void _makeButtonDisappear() {
    setState(() {
      _opacity = 0.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _opacity = 1.0;
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
      _showCorrectAnswer = false;
      _showHint = false;
      _isButtonShaking = false;
      _opacity = 1.0;
      _animationController.reset();
    });
  }

  void _showCorrectAnswerDialog() {
    final correctAnswer =
        _questions[_currentQuestionIndex]['correct'] ?? "Inconnu";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("T'es vraiment nul(le)"),
        content: Text(
          "La réponse était: $correctAnswer",
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: const Text("Je suis triste"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final shuffledAnswers = _getShuffledAnswers();
    final sarcasticComment =
        _sarcasticComments[_random.nextInt(_sarcasticComments.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LE JEU LE PLUS FRUSTRANT'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 10,
        shadowColor: Colors.red.withOpacity(0.6),
        actions: [
          Tooltip(
            message: 'Niveau de frustration',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Badge(
                label: Text('$_failedAttempts'),
                backgroundColor:
                    _failedAttempts > 3 ? Colors.red : Colors.amber,
                largeSize: 28,
                child: Icon(
                  _failedAttempts > 5
                      ? Icons.sentiment_very_dissatisfied
                      : _failedAttempts > 3
                          ? Icons.sentiment_dissatisfied
                          : Icons.sentiment_neutral,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arrière-plan animé
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _failedAttempts > 3 ? Colors.red[100]! : Colors.blue[50]!,
                  _failedAttempts > 3 ? Colors.orange[100]! : Colors.green[50]!,
                ],
              ),
            ),
          ),

          // Contenu principal
          Column(
            children: [
              // Question avec indice moqueur
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentQuestion['image'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentQuestion['question'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        if (_showHint)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "💡 Indice: ${currentQuestion['hint']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final shakeOffset =
                                _isButtonShaking && !answer['isCorrect']
                                    ? _animationController.value *
                                        10 *
                                        sin(_animationController.value * 20)
                                    : 0;

                            return Transform(
                              transform: Matrix4.translation(
                                  vector.Vector3(shakeOffset.toDouble(), 0, 0))
                                ..rotateZ(
                                    answer['isCorrect'] && _isButtonRotating
                                        ? _rotationAngle
                                        : 0),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity:
                                    answer['isCorrect'] && _showCorrectAnswer
                                        ? 0.5
                                        : _opacity,
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale:
                                      answer['isCorrect'] ? _buttonScale : 1.0,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _onAnswerTap(answer['isCorrect']),
                                    style: _buttonStyle(
                                      answer['isCorrect']
                                          ? Colors.blue
                                          : Colors.blue,
                                      answer['isCorrect'] && _showCorrectAnswer,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
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
                    );
                  },
                ),
              ),

              // Feedback sarcastique
              if (_showFeedback)
                AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  offset: _showFeedback ? Offset.zero : const Offset(0, 1),
                  child: Center(
                    child: Card(
                      elevation: 10,
                      color: Colors.red[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                            const Icon(Icons.mood_bad,
                                size: 50, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Faux succès
              if (_showFakeSuccess)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showFakeSuccess ? 1.0 : 0.0,
                  child: Center(
                    child: Card(
                      elevation: 20,
                      color: Colors.amber[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'BRAVO ! ... NON JE DÉCONNE 😈',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Icon(
                              Icons.emoji_emotions,
                              size: 60,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "T'as vraiment cru que c'était fini?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Confettis (pour le faux succès)
          ConfettiWidget(
            confettiController: _fakeConfettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.red, Colors.blue, Colors.green],
            gravity: 0.1,
          ),

          // Confettis (pour les bonnes réponses)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.teal, Colors.lightGreen],
            gravity: 0.2,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _nextQuestion,
            backgroundColor: Colors.deepOrange,
            icon: const Icon(Icons.skip_next),
            label: const Text("Question suivante"),
            heroTag: "nextBtn",
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
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            backgroundColor: Colors.red,
            heroTag: "helpBtn",
            child: const Icon(Icons.help_outline),
          ),
          const SizedBox(height: 10),
          if (_failedAttempts > 2)
            FloatingActionButton.extended(
              onPressed: _showCorrectAnswerDialog,
              backgroundColor: Colors.purple,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text("Révéler la réponse"),
              heroTag: "revealBtn",
            ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, bool isDisabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: isDisabled ? Colors.grey : color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.4),
      elevation: 8,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _fakeConfettiController.dispose();
    super.dispose();
  }
}
