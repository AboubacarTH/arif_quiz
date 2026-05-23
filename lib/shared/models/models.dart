// ========== USER MODEL ==========
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final int totalPoints;
  final int quizzesTaken;
  final int correctAnswers;
  final double accuracy;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.totalPoints,
    required this.quizzesTaken,
    required this.correctAnswers,
    required this.accuracy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatar: json['avatar'],
        totalPoints: json['total_points'] ?? 0,
        quizzesTaken: json['quizzes_taken'] ?? 0,
        correctAnswers: json['correct_answers'] ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      );
}

// ========== CATEGORY MODEL ==========
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String color;
  final int quizCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.color,
    required this.quizCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        description: json['description'],
        icon: json['icon'],
        color: json['color'] ?? '#6366f1',
        quizCount: json['quiz_count'] ?? 0,
      );
}

// ========== QUIZ MODEL ==========
class QuizModel {
  final int id;
  final String title;
  final String? description;
  final String difficulty;
  final int timeLimit;
  final int totalQuestions;
  final int playCount;
  final String? thumbnail;
  final CategoryModel? category;
  final double? averageScore;
  final int? pointsPerQuestion;

  const QuizModel({
    required this.id,
    required this.title,
    this.description,
    required this.difficulty,
    required this.timeLimit,
    required this.totalQuestions,
    required this.playCount,
    this.thumbnail,
    this.category,
    this.averageScore,
    this.pointsPerQuestion,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        difficulty: json['difficulty'] ?? 'medium',
        timeLimit: json['time_limit'] ?? 30,
        totalQuestions: json['total_questions'] ?? 0,
        playCount: json['play_count'] ?? 0,
        thumbnail: json['thumbnail'],
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        averageScore: (json['average_score'] as num?)?.toDouble(),
        pointsPerQuestion: json['points_per_question'],
      );
}

// ========== QUESTION MODEL ==========
class QuestionModel {
  final int id;
  final String text;
  final String type;
  final List<String>? options;
  final int points;
  final int order;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    required this.points,
    required this.order,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'],
        text: json['text'],
        type: json['type'] ?? 'multiple_choice',
        options: json['options'] != null
            ? List<String>.from(json['options'])
            : null,
        points: json['points'] ?? 10,
        order: json['order'] ?? 0,
      );
}

// ========== QUIZ RESULT MODEL ==========
class QuestionResult {
  final int questionId;
  final String question;
  final String? userAnswer;
  final String correctAnswer;
  final String? explanation;
  final bool isCorrect;
  final int points;

  const QuestionResult({
    required this.questionId,
    required this.question,
    this.userAnswer,
    required this.correctAnswer,
    this.explanation,
    required this.isCorrect,
    required this.points,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        questionId: json['question_id'],
        question: json['question'],
        userAnswer: json['user_answer'],
        correctAnswer: json['correct_answer'],
        explanation: json['explanation'],
        isCorrect: json['is_correct'] ?? false,
        points: json['points'] ?? 0,
      );
}

class QuizAttemptResult {
  final int attemptId;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final int timeTaken;
  final int pointsEarned;
  final String grade;
  final List<QuestionResult> results;

  const QuizAttemptResult({
    required this.attemptId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeTaken,
    required this.pointsEarned,
    required this.grade,
    required this.results,
  });

  factory QuizAttemptResult.fromJson(Map<String, dynamic> json) =>
      QuizAttemptResult(
        attemptId: json['attempt_id'],
        score: (json['score'] as num).toDouble(),
        correctCount: json['correct_count'],
        totalQuestions: json['total_questions'],
        timeTaken: json['time_taken'],
        pointsEarned: json['points_earned'],
        grade: json['grade'] ?? 'F',
        results: (json['results'] as List)
            .map((r) => QuestionResult.fromJson(r))
            .toList(),
      );
}
