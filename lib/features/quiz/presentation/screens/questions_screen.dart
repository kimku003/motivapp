import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart'; // Pour faire vibrer, ajoute dans pubspec.yaml
import '../../data/questions.dart'; // Assure-toi que tes questions sont bien là
import '../../data/models/spicy_question_model.dart'; // Modèle de question épicée
import '../../data/services/spicy_quiz_service.dart'; // Service de quiz épicé

class QuestionsScreen extends StatefulWidget {
  final SpicyQuizService spicyQuizService;

  const QuestionsScreen({
    super.key,
    required this.spicyQuizService,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late List<SpicyQuestion> _questions;
  int _currentQuestionIndex = 0;
  String? _selectedMessage;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = questions.map((q) => SpicyQuestion.fromJson(q)).toList()
      ..shuffle();
    setState(() {});
  }

  void _selectAnswer(SpicyAnswer answer) {
    setState(() {
      _selectedMessage = answer.message;
      _showMessage = true;
    });

    // Vibration feedback
    Vibration.vibrate(duration: 150);

    // Delay before moving to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
          if (_currentQuestionIndex < _questions.length - 1) {
            _currentQuestionIndex++;
          } else {
            // Reset to start if at end
            _currentQuestionIndex = 0;
            _questions.shuffle();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Épicé 🌶️'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _questions[_currentQuestionIndex].question,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_showMessage)
              ..._questions[_currentQuestionIndex]
                  .answers
                  .map(
                    (answer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _selectAnswer(answer),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.purple,
                        ),
                        child: Text(answer.text),
                      ),
                    ),
                  )
                  .toList()
            else
              Card(
                color: Colors.purple.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _selectedMessage!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
