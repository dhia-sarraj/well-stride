class StepsModel {
  final String? id;
  final DateTime date;
  final int steps;
  final int targetSteps;
  final int activeMinutes;
  final double? distanceMeters;
  final int? stairsClimbed;
  final int? caloriesEstimated;
  final String? source;
  final DateTime? syncedAt;
  final DateTime? createdAt;

  StepsModel({
    this.id,
    required this.date,
    required this.steps,
    required this.targetSteps,
    this.activeMinutes = 0,
    this.distanceMeters,
    this.stairsClimbed,
    this.caloriesEstimated,
    this.source,
    this.syncedAt,
    this.createdAt,
  });

  /// Calculate percentage of goal achieved
  double get percentage => (steps / targetSteps * 100).clamp(0, 100);

  /// Check if goal is reached
  bool get isGoalReached => steps >= targetSteps;

  /// Distance in kilometers
  double? get distanceKm => distanceMeters != null ? distanceMeters! / 1000 : null;

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'stepCount': steps,
      'goal': targetSteps,
      'activeMinutes': activeMinutes,
      if (distanceMeters != null) 'distanceMeters': distanceMeters,
      if (stairsClimbed != null) 'stairsClimbed': stairsClimbed,
      if (caloriesEstimated != null) 'caloriesEstimated': caloriesEstimated,
      if (source != null) 'source': source,
    };
  }

  /// Create from JSON (backend response)
  factory StepsModel.fromJson(Map<String, dynamic> json) {
    print('Parsing StepsModel from JSON: $json'); // Debug print

    return StepsModel(
      id: json['id'] ?? json['_id'],
      date: _parseDate(json['date']),
      steps: _parseInt(json['stepCount'] ?? json['steps']) ?? 0,
      targetSteps: _parseInt(json['goal'] ?? json['targetSteps']) ?? 10000,
      activeMinutes: _parseInt(json['activeMinutes']) ?? 0,
      distanceMeters: _parseDouble(json['distanceMeters']),
      stairsClimbed: _parseInt(json['stairsClimbed']),
      caloriesEstimated: _parseInt(json['caloriesEstimated']),
      source: json['source'],
      syncedAt: _parseDateTime(json['syncedAt']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // Helper methods
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

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

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Create a copy with updated fields
  StepsModel copyWith({
    String? id,
    DateTime? date,
    int? steps,
    int? targetSteps,
    int? activeMinutes,
    double? distanceMeters,
    int? stairsClimbed,
    int? caloriesEstimated,
    String? source,
    DateTime? syncedAt,
    DateTime? createdAt,
  }) {
    return StepsModel(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      targetSteps: targetSteps ?? this.targetSteps,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      stairsClimbed: stairsClimbed ?? this.stairsClimbed,
      caloriesEstimated: caloriesEstimated ?? this.caloriesEstimated,
      source: source ?? this.source,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}