// ========== USER MODEL ==========
class UserModel {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String? avatar;
  final String role;
  final int totalPoints;
  final int quizzesTaken;
  final int correctAnswers;
  final double accuracy;
  final int xp;
  final int level;
  final int streak;
  final int longestStreak;
  final DateTime? lastPlayedAt;

  const UserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.avatar,
    required this.role,
    required this.totalPoints,
    required this.quizzesTaken,
    required this.correctAnswers,
    required this.accuracy,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastPlayedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        email: json['email'] ?? '',
        avatar: json['avatar'],
        role: json['role'] ?? 'user',
        totalPoints: json['total_points'] ?? 0,
        quizzesTaken: json['quizzes_taken'] ?? 0,
        correctAnswers: json['correct_answers'] ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        xp: json['xp'] ?? 0,
        level: json['level'] ?? 1,
        streak: json['streak'] ?? 0,
        longestStreak: json['longest_streak'] ?? 0,
        lastPlayedAt: json['last_played_at'] != null
            ? DateTime.tryParse(json['last_played_at'])
            : null,
      );

  int get xpForCurrentLevel => (level - 1) * 500;
  int get xpForNextLevel => level * 500;
  int get xpProgress => xp - xpForCurrentLevel;
  int get xpNeeded => xpForNextLevel - xpForCurrentLevel;
  double get xpPercent => xpNeeded > 0 ? (xpProgress / xpNeeded).clamp(0.0, 1.0) : 1.0;
}

// ========== FRIEND MODEL ==========
class FriendModel {
  final int friendshipId;
  final UserModel friend;
  final DateTime? since;

  const FriendModel({
    required this.friendshipId,
    required this.friend,
    this.since,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
        friendshipId: json['friendship_id'],
        friend: UserModel.fromJson(json['friend']),
        since: json['since'] != null ? DateTime.tryParse(json['since']) : null,
      );
}

class FriendRequest {
  final int id;
  final UserModel sender;
  final UserModel? receiver;
  final String status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.sender,
    this.receiver,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        id: json['id'],
        sender: json['sender'] != null
            ? UserModel.fromJson(json['sender'])
            : UserModel.fromJson({'id': 0, 'name': 'Unknown', 'email': ''}),
        receiver: json['receiver'] != null
            ? UserModel.fromJson(json['receiver'])
            : null,
        status: json['status'] ?? 'pending',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}

class UserSearchResult {
  final int id;
  final String name;
  final String? username;
  final String? avatar;
  final int level;
  final int xp;
  final int streak;
  final int totalPoints;
  final String? friendshipStatus;
  final int? friendshipId;
  final bool? isSender;

  const UserSearchResult({
    required this.id,
    required this.name,
    this.username,
    this.avatar,
    required this.level,
    required this.xp,
    required this.streak,
    required this.totalPoints,
    this.friendshipStatus,
    this.friendshipId,
    this.isSender,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      UserSearchResult(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        avatar: json['avatar'],
        level: json['level'] ?? 1,
        xp: json['xp'] ?? 0,
        streak: json['streak'] ?? 0,
        totalPoints: json['total_points'] ?? 0,
        friendshipStatus: json['friendship_status'],
        friendshipId: json['friendship_id'],
        isSender: json['is_sender'],
      );
}

// ========== CHALLENGE MODEL ==========
class ChallengeModel {
  final int id;
  final String code;
  final UserModel creator;
  final QuizModel quiz;
  final String mode;
  final String title;
  final String status;
  final DateTime? expiresAt;
  final int participantsCount;
  final List<ChallengeParticipant>? leaderboard;

  const ChallengeModel({
    required this.id,
    required this.code,
    required this.creator,
    required this.quiz,
    required this.mode,
    required this.title,
    required this.status,
    this.expiresAt,
    this.participantsCount = 0,
    this.leaderboard,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'],
        code: json['code'] ?? '',
        creator: json['creator'] != null
            ? UserModel.fromJson(json['creator'])
            : UserModel.fromJson({'id': 0, 'name': 'Unknown', 'email': ''}),
        quiz: json['quiz'] != null
            ? QuizModel.fromJson(json['quiz'])
            : QuizModel.fromJson({'id': 0, 'title': 'Unknown', 'difficulty': 'medium', 'time_limit': 30, 'total_questions': 0, 'play_count': 0}),
        mode: json['mode'] ?? 'classic',
        title: json['title'] ?? '',
        status: json['status'] ?? 'open',
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'])
            : null,
        participantsCount: json['participants_count'] ?? 0,
        leaderboard: json['leaderboard'] != null
            ? (json['leaderboard'] as List)
                .map((e) => ChallengeParticipant.fromJson(e))
                .toList()
            : null,
      );

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isOpen => status == 'open' && !isExpired;
}

class ChallengeParticipant {
  final int rank;
  final UserModel user;
  final double? score;
  final int? correctCount;
  final int? timeTaken;
  final DateTime? completedAt;

  const ChallengeParticipant({
    required this.rank,
    required this.user,
    this.score,
    this.correctCount,
    this.timeTaken,
    this.completedAt,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      ChallengeParticipant(
        rank: json['rank'] ?? 0,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'])
            : UserModel.fromJson({'id': 0, 'name': 'Unknown', 'email': ''}),
        score: (json['score'] as num?)?.toDouble(),
        correctCount: json['correct_count'],
        timeTaken: json['time_taken'],
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'])
            : null,
      );

  bool get hasCompleted => completedAt != null;
}

// ========== DAILY CHALLENGE MODEL ==========
class DailyChallengeModel {
  final int id;
  final QuizModel quiz;
  final DateTime challengeDate;
  final bool alreadyPlayed;
  final double? myScore;
  final String? myGrade;
  final int secondsUntilReset;

  const DailyChallengeModel({
    required this.id,
    required this.quiz,
    required this.challengeDate,
    required this.alreadyPlayed,
    this.myScore,
    this.myGrade,
    required this.secondsUntilReset,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) =>
      DailyChallengeModel(
        id: json['id'],
        quiz: QuizModel.fromJson(json['quiz']),
        challengeDate: DateTime.tryParse(json['challenge_date'] ?? '') ?? DateTime.now(),
        alreadyPlayed: json['already_played'] ?? false,
        myScore: (json['my_score'] as num?)?.toDouble(),
        myGrade: json['my_grade'],
        secondsUntilReset: json['seconds_until_reset'] ?? 86400,
      );
}

// ========== NOTIFICATION MODEL ==========
class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] ?? '',
        type: json['type'] ?? '',
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  bool get isRead => readAt != null;
  String get notifType => (data['type'] ?? type.split('\\').last) as String;
  String get message => (data['message'] ?? '') as String;
}

// ========== FRIEND ACTIVITY MODEL ==========
class FriendActivity {
  final int id;
  final UserModel user;
  final QuizModel quiz;
  final double score;
  final String? grade;
  final int pointsEarned;
  final DateTime? completedAt;

  const FriendActivity({
    required this.id,
    required this.user,
    required this.quiz,
    required this.score,
    this.grade,
    required this.pointsEarned,
    this.completedAt,
  });

  factory FriendActivity.fromJson(Map<String, dynamic> json) => FriendActivity(
        id: json['id'],
        user: UserModel.fromJson(json['user']),
        quiz: QuizModel.fromJson(json['quiz']),
        score: (json['score'] as num).toDouble(),
        grade: json['grade'],
        pointsEarned: json['points_earned'] ?? 0,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'])
            : null,
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
        slug: json['slug'] ?? '',
        description: json['description'],
        icon: json['icon'],
        color: json['color'] ?? '#7C3AED',
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
            ? CategoryModel.fromJson(
                Map<String, dynamic>.from(json['category']),
              )
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
        options:
            json['options'] != null ? List<String>.from(json['options']) : null,
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
        question: json['question'] ?? json['question_text'] ?? '',
        userAnswer: json['user_answer'],
        correctAnswer: json['correct_answer'],
        explanation: json['explanation'],
        isCorrect: json['is_correct'] ?? false,
        points: json['points'] ?? 0,
      );
}

class QuizAttemptResult {
  final int? attemptId;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final int timeTaken;
  final int pointsEarned;
  final int xpEarned;
  final String grade;
  final List<QuestionResult> results;

  const QuizAttemptResult({
    this.attemptId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeTaken,
    required this.pointsEarned,
    this.xpEarned = 0,
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
        pointsEarned: json['points_earned'] ?? 0,
        xpEarned: json['xp_earned'] ?? 0,
        grade: json['grade'] ?? 'F',
        results: (json['results'] as List)
            .map((r) => QuestionResult.fromJson(r))
            .toList(),
      );
}

// ========== GAME MODE ==========
enum GameMode {
  classic,
  survival,
  speed;

  String get label => switch (this) {
        classic => 'Classique',
        survival => 'Survie',
        speed => 'Speed Round',
      };

  String get apiValue => name;

  String get description => switch (this) {
        classic => 'Quiz standard avec timer global',
        survival => 'Une erreur et c\'est game over !',
        speed => '5 secondes par question, bonus XP ×1.5',
      };

  String get icon => switch (this) {
        classic => '🎮',
        survival => '❤️',
        speed => '⚡',
      };
}
