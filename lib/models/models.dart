// ─── Mood Entry ─────────────────────────────────────────────────────────────
class MoodEntry {
  final String id;
  final int moodLevel; // 1-5 (1=Terrible, 5=Great)
  final String moodLabel;
  final String emoji;
  final DateTime date;
  final String? note;
  final List<String> emotions;

  MoodEntry({
    required this.id,
    required this.moodLevel,
    required this.moodLabel,
    required this.emoji,
    required this.date,
    this.note,
    this.emotions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moodLevel': moodLevel,
        'moodLabel': moodLabel,
        'emoji': emoji,
        'date': date.toIso8601String(),
        'note': note,
        'emotions': emotions,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'],
        moodLevel: json['moodLevel'],
        moodLabel: json['moodLabel'],
        emoji: json['emoji'],
        date: DateTime.parse(json['date']),
        note: json['note'],
        emotions: List<String>.from(json['emotions'] ?? []),
      );
}

// ─── Journal Entry ───────────────────────────────────────────────────────────
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
        'mood': mood,
        'tags': tags,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        date: DateTime.parse(json['date']),
        mood: json['mood'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}

// ─── DASS-21 Result ──────────────────────────────────────────────────────────
class Dass21Result {
  final String id;
  final DateTime date;
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final List<int> answers; // 21 answers (0-3)

  Dass21Result({
    required this.id,
    required this.date,
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    required this.answers,
  });

  String get depressionLevel {
    if (depressionScore <= 9) return 'Normal';
    if (depressionScore <= 13) return 'Ringan';
    if (depressionScore <= 20) return 'Sedang';
    if (depressionScore <= 27) return 'Berat';
    return 'Sangat Berat';
  }

  String get anxietyLevel {
    if (anxietyScore <= 7) return 'Normal';
    if (anxietyScore <= 9) return 'Ringan';
    if (anxietyScore <= 14) return 'Sedang';
    if (anxietyScore <= 19) return 'Berat';
    return 'Sangat Berat';
  }

  String get stressLevel {
    if (stressScore <= 14) return 'Normal';
    if (stressScore <= 18) return 'Ringan';
    if (stressScore <= 25) return 'Sedang';
    if (stressScore <= 33) return 'Berat';
    return 'Sangat Berat';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'depressionScore': depressionScore,
        'anxietyScore': anxietyScore,
        'stressScore': stressScore,
        'answers': answers,
      };

  factory Dass21Result.fromJson(Map<String, dynamic> json) => Dass21Result(
        id: json['id'],
        date: DateTime.parse(json['date']),
        depressionScore: json['depressionScore'],
        anxietyScore: json['anxietyScore'],
        stressScore: json['stressScore'],
        answers: List<int>.from(json['answers']),
      );
}

// ─── User Profile ────────────────────────────────────────────────────────────
class UserProfile {
  String name;
  String email;
  String? avatarEmoji;
  DateTime? birthDate;
  DateTime createdAt;

  UserProfile({
    required this.name,
    required this.email,
    this.avatarEmoji,
    this.birthDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarEmoji': avatarEmoji,
        'birthDate': birthDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'],
        email: json['email'],
        avatarEmoji: json['avatarEmoji'],
        birthDate:
            json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

// ─── Article ─────────────────────────────────────────────────────────────────
class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String emoji;
  final int readMinutes;
  final bool isPremium;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.emoji,
    required this.readMinutes,
    this.isPremium = false,
  });
}


// ─── Chat Message ─────────────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });
}
