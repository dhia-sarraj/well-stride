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
    return StepsModel(
      id: json['id'] ?? json['_id'],
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      steps: json['stepCount'] ?? json['steps'] ?? 0,
      targetSteps: json['goal'] ?? json['targetSteps'] ?? 10000,
      activeMinutes: json['activeMinutes'] ?? 0,
      distanceMeters: json['distanceMeters']?.toDouble(),
      stairsClimbed: json['stairsClimbed'],
      caloriesEstimated: json['caloriesEstimated'],
      source: json['source'],
    );
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
    );
  }
}