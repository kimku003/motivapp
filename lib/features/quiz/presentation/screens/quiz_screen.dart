import 'package:flutter/material.dart';
import 'questions_screen.dart';
import 'culture_quiz_screen.dart';
import '../../data/services/spicy_quiz_service.dart';
import '../../data/services/quiz_service.dart';

class QuizScreen extends StatelessWidget {
  final QuizService quizService;
  final SpicyQuizService spicyQuizService;

  const QuizScreen({
    super.key,
    required this.quizService,
    required this.spicyQuizService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeMessage(context),
              const SizedBox(height: 40),
              _buildGameButtons(context),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Mini-Jeux Quiz',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {},
          tooltip: 'Aide',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeMessage(context),
          const SizedBox(height: 40),
          _buildGameButtons(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          'Choisissez votre Quiz !',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Deux modes de jeu disponibles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGameButtons(BuildContext context) {
    return Column(
      children: [
        _buildGameCard(
          context,
          title: 'Quiz Sarcastique',
          description: 'Un quiz qui n\'a pas sa langue dans sa poche !',
          icon: Icons.mood,
          color: Colors.deepPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestionsScreen(
                  spicyQuizService: spicyQuizService,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildGameCard(
          context,
          title: 'Quiz de culture générale',
          description: 'Testez votre culture générale avec 100 questions !',
          icon: Icons.school,
          color: Colors.greenAccent[700]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CultureQuizScreen(quizService: quizService),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
