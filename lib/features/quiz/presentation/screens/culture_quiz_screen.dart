import 'package:flutter/material.dart';
import '../../data/services/quiz_service.dart';
import '../../data/models/question_model.dart';
import '../../data/questions.dart'; // Assurez-vous que le chemin est correct

class CultureQuizScreen extends StatefulWidget {
  final QuizService quizService;

  const CultureQuizScreen({
    super.key,
    required this.quizService,
  });

  @override
  State<CultureQuizScreen> createState() => _CultureQuizScreenState();
}

class _CultureQuizScreenState extends State<CultureQuizScreen> {
  bool _isLoading = true;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await widget.quizService.fetchQuestions();
      setState(() {
        _questions = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _checkAnswer(String selectedAnswer) {
    final isCorrect = widget.quizService.checkAnswer(
      _questions[_currentQuestionIndex],
      selectedAnswer,
    );

    if (isCorrect) {
      setState(() => _score++);
    }

    // Afficher le feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'Bonne réponse !' : 'Mauvaise réponse...',
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );

    // Passer à la question suivante
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz terminé !'),
        content: Text(
          'Votre score : $_score/${_questions.length}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              Navigator.of(context).pop(); // Retourner à l'écran précédent
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Culture Générale'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _questions[_currentQuestionIndex].question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  ..._questions[_currentQuestionIndex]
                      .getAllOptions()
                      .map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(option),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
    );
  }
}
