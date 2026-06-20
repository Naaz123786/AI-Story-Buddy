class QuizModel {
  const QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  final String question;
  final List<String> options;
  final String answer;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];
    if (rawOptions is! List) {
      throw const FormatException('Quiz options must be a list.');
    }

    return QuizModel(
      question: json['question'] as String,
      options: rawOptions.map((option) => option.toString()).toList(),
      answer: json['answer'] as String,
    );
  }

  bool isCorrect(String selected) => selected == answer;

  static const Map<String, dynamic> pipGearQuizJson = {
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  };

  static QuizModel get pipGearQuiz => QuizModel.fromJson(pipGearQuizJson);
}
