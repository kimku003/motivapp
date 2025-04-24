import 'package:flutter/material.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': "Comment ça va ?",
      'answers': [
        {'text': "Super bien !", 'message': "Wow, quel optimisme contagieux !"},
        {
          'text': "Ça pourrait aller mieux",
          'message': "Un peu de narcissisme vous ferait du bien !"
        },
        {
          'text': "Je déteste ce quiz",
          'message': "Votre franchise est... dérangeante."
        },
      ],
    },
    {
      'question': "Quelle est votre couleur préférée ?",
      'answers': [
        {'text': "Bleu", 'message': "Comme le ciel parfait que vous méritez !"},
        {
          'text': "Rouge",
          'message': "Couleur puissante pour une personne exceptionnelle !"
        },
        {
          'text': "Noir",
          'message': "Profond et mystérieux, comme votre âme sublime."
        },
      ],
    },
    {
      'question': "Quel est votre plat préféré ?",
      'answers': [
        {'text': "Pizza", 'message': "Un choix divin pour un palais raffiné !"},
        {
          'text': "Sushi",
          'message': "Seuls les êtres supérieurs apprécient cette délicatesse."
        },
        {
          'text': "Je ne mange pas",
          'message':
              "Votre discipline est presque aussi impressionnante que votre beauté."
        },
      ],
    },
  ];

  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  String? _feedbackMessage;
  bool _showFeedback = false;

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _feedbackMessage =
          _questions[_currentQuestionIndex]['answers'][index]['message'];
      _showFeedback = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _selectedAnswerIndex = null;

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Quiz terminé - Vous êtes extraordinaire !"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Option: Revenir à l'écran d'accueil après un délai
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: Theme.of(context).textTheme.headline4?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Réponses
            ..._questions[_currentQuestionIndex]['answers']
                .asMap()
                .entries
                .map((entry) {
              int idx = entry.key;
              var answer = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(idx),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _selectedAnswerIndex == idx
                        ? Colors.blue[800]
                        : Colors.grey[200],
                    foregroundColor: _selectedAnswerIndex == idx
                        ? Colors.white
                        : Colors.black,
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

            // Feedback narcissique
            if (_showFeedback) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  _feedbackMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.orange[800],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Bouton Suivant
            if (_showFeedback) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
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
}
