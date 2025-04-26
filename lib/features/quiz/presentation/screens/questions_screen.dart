import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart'; // Pour faire vibrer, ajoute dans pubspec.yaml
import '../../data/questions.dart'; // Assure-toi que tes questions sont bien là

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late List<Map<String, dynamic>> _shuffledQuestions;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  String? _feedbackMessage;
  bool _showFeedback = false;
  int _roastCount = 0;
  bool _infiniteMode =
      true; // Change à false si tu veux revenir à l'accueil à la fin

  @override
  void initState() {
    super.initState();
    // Créer une copie modifiable des questions et des réponses
    _shuffledQuestions = List<Map<String, dynamic>>.from(questions)
        .map((q) => {
              'question': q['question'],
              'answers': List<Map<String, dynamic>>.from(q['answers']),
            })
        .toList();
    _shuffledQuestions.shuffle();
    for (var q in _shuffledQuestions) {
      (q['answers'] as List).shuffle(); // Shuffle les réponses
    }
    validateQuestions(_shuffledQuestions);
  }

  void _selectAnswer(int index) async {
    final message =
        _shuffledQuestions[_currentQuestionIndex]['answers'][index]['message'];

    setState(() {
      _selectedAnswerIndex = index;
      _feedbackMessage = message;
      _showFeedback = true;
      _roastCount++;
    });

    // Petite vibration pour accentuer le roast 😈
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 150);
    }
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _selectedAnswerIndex = null;

      if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
        _currentQuestionIndex++;
      } else if (_infiniteMode) {
        _shuffledQuestions.shuffle();
        _currentQuestionIndex = 0;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quiz terminé 🔥 Roasts encaissés: $_roastCount"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _shuffledQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '🔥 Roast ${_currentQuestionIndex + 1}/${_shuffledQuestions.length}'),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: Icon(_infiniteMode ? Icons.loop : Icons.stop),
            tooltip: _infiniteMode ? 'Mode Infini Activé' : 'Mode Normal',
            onPressed: () {
              setState(() {
                _infiniteMode = !_infiniteMode;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question
            Text(
              current['question'],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Réponses
            ...current['answers'].asMap().entries.map((entry) {
              int idx = entry.key;
              var answer = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(idx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAnswerIndex == idx
                        ? Colors.blue[800]
                        : Colors.grey[300],
                    foregroundColor: _selectedAnswerIndex == idx
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    answer['text'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedAnswerIndex == idx
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),

            // Feedback
            if (_showFeedback) ...[
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _feedbackMessage ?? "",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.orange[900],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < _shuffledQuestions.length - 1 ||
                          _infiniteMode
                      ? 'QUESTION SUIVANTE'
                      : 'TERMINER LE QUIZ',
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
    );
  }

  void validateQuestions(List<Map<String, dynamic>> questions) {
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final answers = q['answers'] as List;

      if (answers.length < 2) {
        debugPrint("❌ Question ${i + 1} n'a pas assez de réponses.");
      }

      for (int j = 0; j < answers.length; j++) {
        final a = answers[j];
        if (a['text'] == null || a['text'].toString().trim().isEmpty) {
          debugPrint(
              "❌ Réponse ${j + 1} de la question ${i + 1} a un texte vide.");
        }
        if (a['message'] == null || a['message'].toString().trim().isEmpty) {
          debugPrint(
              "❌ Réponse '${a['text']}' de la question ${i + 1} n'a pas de roast.");
        }
      }
    }
    debugPrint("✅ Validation terminée.");
  }
}
