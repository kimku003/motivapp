class Question {
  final String question;
  final String reponse;
  final List<String> indices;

  Question({
    required this.question,
    required this.reponse,
    required this.indices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      reponse: json['reponse'] as String,
      indices: List<String>.from(json['indices'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'reponse': reponse,
        'indices': indices,
      };

  @override
  String toString() => reponse;

  // Méthode pour obtenir toutes les options mélangées
  List<String> getAllOptions() {
    final options = List<String>.from(indices);
    options.add(reponse);
    options.shuffle();
    return options;
  }
}

class QuizResponse {
  final List<Question> questions;
  final String lastUpdated;

  QuizResponse({
    required this.questions,
    required this.lastUpdated,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['last_updated'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'questions': questions.map((q) => q.toJson()).toList(),
        'last_updated': lastUpdated,
      };
}
