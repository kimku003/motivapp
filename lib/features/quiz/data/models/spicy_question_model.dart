class SpicyQuestion {
  final String question;
  final List<SpicyAnswer> answers;

  SpicyQuestion({
    required this.question,
    required this.answers,
  });

  factory SpicyQuestion.fromJson(Map<String, dynamic> json) {
    try {
      return SpicyQuestion(
        question: json['question']?.toString() ?? '',
        answers: (json['answers'] as List?)
                ?.map((a) => SpicyAnswer.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing SpicyQuestion: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'question': question,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
    } catch (e) {
      print('Error converting SpicyQuestion to JSON: $e');
      rethrow;
    }
  }
}

class SpicyAnswer {
  final String text;
  final String message;

  SpicyAnswer({
    required this.text,
    required this.message,
  });

  factory SpicyAnswer.fromJson(Map<String, dynamic> json) {
    try {
      return SpicyAnswer(
        text: json['text']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing SpicyAnswer: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'text': text,
        'message': message,
      };
    } catch (e) {
      print('Error converting SpicyAnswer to JSON: $e');
      rethrow;
    }
  }
}
