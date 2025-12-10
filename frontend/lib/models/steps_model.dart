class StepsModel {
  final String id;
  final DateTime date;
  final int steps;
  final int targetSteps;
  final int activeMinutes;

  StepsModel({
    required this.id,
    required this.date,
    required this.steps,
    required this.targetSteps,
    this.activeMinutes = 0,
  });

  // Calculate percentage of goal achieved
  double get percentage => (steps / targetSteps * 100).clamp(0, 100);

  // Check if goal is reached
  bool get isGoalReached => steps >= targetSteps;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'targetSteps': targetSteps,
      'activeMinutes': activeMinutes,
    };
  }

  factory StepsModel.fromJson(Map<String, dynamic> json) {
    return StepsModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      targetSteps: json['targetSteps'],
      activeMinutes: json['activeMinutes'] ?? 0,
    );
  }
}