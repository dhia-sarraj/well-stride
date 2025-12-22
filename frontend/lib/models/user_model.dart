class UserModel {
  final String id;
  final String email;
  final String username;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String sex; // 'Male', 'Female'
  final int targetSteps;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.age,
    required this.weight,
    required this.height,
    required this.sex,
    required this.targetSteps,
  });

  // Convert to JSON (for saving to database later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'age': age,
      'weight': weight,
      'height': height,
      'sex': sex,
      'targetSteps': targetSteps,
    };
  }

  // Create from JSON (for reading from database later)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      age: json['age'],
      weight: json['weight'].toDouble(),
      height: json['height'].toDouble(),
      sex: json['sex'],
      targetSteps: json['targetSteps'],
    );
  }
}