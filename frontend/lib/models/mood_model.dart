class MoodModel {
  final String? id;
  final DateTime timestamp;
  final String emoji;
  final String? reason; // Backend single reason field
  final String? note;
  final int? stepsAtTime;
  final DateTime? createdAt;

  // Derived property for internal use
  String get moodLevel {
    switch (emoji.toLowerCase()) {
      case 'happy':
        return 'happy';
      case 'calm':
        return 'calm';
      case 'neutral':
        return 'neutral';
      case 'sad':
        return 'sad';
      case 'anxious':
        return 'anxious';
      default:
        return 'neutral';
    }
  }

  // For backwards compatibility
  List<String> get reasons => reason != null ? [reason!] : [];

  MoodModel({
    this.id,
    required this.timestamp,
    required this.emoji,
    this.reason,
    this.note,
    this.stepsAtTime,
    this.createdAt,
  });

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      if (reason != null) 'reason': reason,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  /// Create from JSON (backend response)
  factory MoodModel.fromJson(Map<String, dynamic> json) {
    print('Parsing MoodModel from JSON: $json');

    return MoodModel(
      id: json['id'] ?? json['_id'],
      timestamp: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      emoji: json['emoji'] ?? 'Okay',
      reason: json['reason'],
      note: json['note'],
      stepsAtTime: _parseInt(json['stepsAtTime']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // Helper methods
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  MoodModel copyWith({
    String? id,
    DateTime? timestamp,
    String? emoji,
    String? reason,
    String? note,
    int? stepsAtTime,
    DateTime? createdAt,
  }) {
    return MoodModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      emoji: emoji ?? this.emoji,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      stepsAtTime: stepsAtTime ?? this.stepsAtTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Mood options for selection - Updated to match backend enum
class MoodOption {
  final String emoji;
  final String label;
  final String backendValue; // What we send to backend

  MoodOption({
    required this.emoji,
    required this.label,
    required this.backendValue,
  });
}

final List<MoodOption> moodOptions = [
  MoodOption(emoji: '😊', label: 'Happy', backendValue: 'Happy'),
  MoodOption(emoji: '😌', label: 'Calm', backendValue: 'Calm'),
  MoodOption(emoji: '😐', label: 'Neutral', backendValue: 'Neutral'),
  MoodOption(emoji: '😔', label: 'Sad', backendValue: 'Sad'),
  MoodOption(emoji: '😰', label: 'Anxious', backendValue: 'Anxious'),
];

// Reason options - Backend only accepts one reason - ADDED "Others"
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
  'Others',
];