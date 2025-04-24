import 'package:flutter/material.dart';
import 'questions_screen.dart'; // Import de l'écran des questions

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      backgroundColor: Colors.grey[100], // Fond plus doux
    );
  }

  // Composant AppBar réutilisable
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Quiz Culture Générale',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      elevation: 2, // Ombre légère
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {}, // À implémenter
          tooltip: 'Aide',
        ),
      ],
    );
  }

  // Corps de la page
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeMessage(context),
          const SizedBox(height: 40),
          _buildStartButton(context),
        ],
      ),
    );
  }

  // Message de bienvenue
  Widget _buildWelcomeMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bienvenue au Quiz !',
          style: Theme.of(context).textTheme.headline4?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Testez vos connaissances avec 10 questions variées',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Bouton de démarrage
  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const QuestionsScreen()), // Navigation vers QuestionsScreen
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blueAccent, // Couleur principale
      ),
      child: const Text(
        'COMMENCER LE QUIZ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
