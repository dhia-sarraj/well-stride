class MoodModel {
  final String id;
  final DateTime timestamp;
  final String emoji; // '😊', '😐', '😢', '😡', '😰'
  final String moodLevel; // 'happy', 'neutral', 'sad', 'angry', 'anxious'
  final List<String> reasons; // e.g., ['work', 'exercise', 'sleep']
  final String? note; // Optional user note

  MoodModel({
    required this.id,
    required this.timestamp,
    required this.emoji,
    required this.moodLevel,
    required this.reasons,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'emoji': emoji,
      'moodLevel': moodLevel,
      'reasons': reasons,
      'note': note,
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      emoji: json['emoji'],
      moodLevel: json['moodLevel'],
      reasons: List<String>.from(json['reasons']),
      note: json['note'],
    );
  }
}

// Mood options for selection
class MoodOption {
  final String emoji;
  final String label;
  final String level;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.level,
  });
}

final List<MoodOption> moodOptions = [
  MoodOption(emoji: '😊', label: 'Happy', level: 'happy'),
  MoodOption(emoji: '😌', label: 'Calm', level: 'calm'),
  MoodOption(emoji: '😐', label: 'Neutral', level: 'neutral'),
  MoodOption(emoji: '😔', label: 'Sad', level: 'sad'),
  MoodOption(emoji: '😰', label: 'Anxious', level: 'anxious'),
];

// Reason options
final List<String> moodReasons = [
  'Work',
  'Exercise',
  'Sleep',
  'Family',
  'Friends',
  'Health',
  'Weather',
  'Food',
  'Stress',
  'Relaxation',
];