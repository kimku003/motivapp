import 'package:flutter/material.dart';
import 'dart:math';

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
      'wrong': ["Le paresseux", "La tortue", "L'escargot"]
    },
    {
      'question': "Quelle est la capitale de la France ?",
      'correct': "Paris",
      'wrong': ["Londres", "Berlin", "Madrid"]
    },
    {
      'question': "2 + 2 = ?",
      'correct': "4",
      'wrong': ["22", "5", "3.99"]
    },
  ];

  int _currentQuestionIndex = 0;
  int _failedAttempts = 0;
  bool _showFeedback = false;
  late AnimationController _animationController;
  final Random _random = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<Map<String, dynamic>> _getShuffledAnswers() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final List<Map<String, dynamic>> answers = [
      {'text': currentQuestion['correct'], 'isCorrect': true},
      ...currentQuestion['wrong'].map((wrongAnswer) => {
            'text': wrongAnswer,
            'isCorrect': false,
          } as Map<String, dynamic>), // Cast explicite
    ];
    answers.shuffle(_random); // Mélange des réponses
    return answers;
  }

  void _moveCorrectAnswer() {
    setState(() {
      _failedAttempts++;
    });
  }

  void _showTemporaryFeedback() {
    setState(() {
      _showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showFeedback = false;
      });
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
      _failedAttempts = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final shuffledAnswers = _getShuffledAnswers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Bouton Insaisissable'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Nombre d\'essais infructueux',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text('$_failedAttempts'),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Question
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Text(
              currentQuestion['question'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Réponses mélangées
          ...shuffledAnswers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;

            return Positioned(
              left: _random.nextDouble() *
                  (MediaQuery.of(context).size.width - 150),
              top:
                  150.0 + index * 80.0, // Espacement vertical entre les boutons
              child: ElevatedButton(
                onPressed: () {
                  if (answer['isCorrect']) {
                    _moveCorrectAnswer();
                  } else {
                    _showTemporaryFeedback();
                  }
                },
                style: _buttonStyle(Colors.blue), // Style uniforme
                child: Text(
                  answer['text'],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),

          // Feedback
          if (_showFeedback)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'HAHA ! Essaye encore !',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.sentiment_very_dissatisfied,
                    size: 60,
                    color: Colors.red[400],
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextQuestion,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.skip_next),
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
    super.dispose();
  }
}
