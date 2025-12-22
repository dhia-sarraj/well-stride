import 'dart:math';
import '../models/user_model.dart';
import '../models/mood_model.dart';
import '../models/steps_model.dart';

class DummyDataService {
  // Singleton pattern (only one instance of this class)
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal();

  final Random _random = Random();

  // DUMMY USER DATA
  UserModel getDummyUser() {
    return UserModel(
      id: 'user_123',
      email: 'test@wellstride.com',
      username: 'FitJohn',
      age: 28,
      weight: 75.0,
      height: 175.0,
      sex: 'Male',
      targetSteps: 10000,
    );
  }

  // DUMMY STEPS DATA (Last 30 days)
  List<StepsModel> getDummyStepsHistory() {
    List<StepsModel> history = [];
    DateTime now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));

      // Generate random steps between 3000-15000
      int steps = 3000 + _random.nextInt(12000);
      int activeMinutes = (steps / 100).round(); // Rough estimate

      history.add(StepsModel(
        id: 'steps_$i',
        date: date,
        steps: steps,
        targetSteps: 10000,
        activeMinutes: activeMinutes,
      ));
    }

    return history;
  }

  // DUMMY MOOD DATA (Last 30 days)
  List<MoodModel> getDummyMoodHistory() {
    List<MoodModel> history = [];
    DateTime now = DateTime.now();

    List<String> moods = ['happy', 'calm', 'neutral', 'sad', 'anxious'];
    List<String> emojis = ['😊', '😌', '😐', '😔', '😰'];

    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));

      int moodIndex = _random.nextInt(moods.length);

      // Random reasons (1-3 reasons)
      List<String> allReasons = moodReasons;
      allReasons.shuffle();
      List<String> selectedReasons = allReasons.take(1 + _random.nextInt(3)).toList();

      history.add(MoodModel(
        id: 'mood_$i',
        timestamp: date,
        emoji: emojis[moodIndex],
        moodLevel: moods[moodIndex],
        reasons: selectedReasons,
        note: _random.nextBool() ? 'Feeling ${moods[moodIndex]} today' : null,
      ));
    }

    return history;
  }

  // TODAY'S STEPS
  StepsModel getTodaySteps() {
    return StepsModel(
      id: 'today',
      date: DateTime.now(),
      steps: 7234, // You can change this to test different percentages
      targetSteps: 10000,
      activeMinutes: 72,
    );
  }

  // TODAY'S MOOD (or null if not set yet)
  MoodModel? getTodayMood() {
    return MoodModel(
      id: 'mood_today',
      timestamp: DateTime.now(),
      emoji: '😊',
      moodLevel: 'happy',
      reasons: ['Exercise', 'Sleep', 'Weather'],
      note: 'Had a great workout!',
    );
  }

  // SCREEN TIME DATA (in minutes)
  int getScreenTime() {
    return 180 + _random.nextInt(240); // Between 3-7 hours
  }

  // HEALTH METRICS (for Fitness screen)
  Map<String, dynamic> getHealthMetrics() {
    return {
      'heartRate': 72 + _random.nextInt(20), // 72-92 bpm
      'oxygenLevel': 95 + _random.nextInt(5), // 95-99%
      'stressLevel': _random.nextInt(100), // 0-100
      'sleepHours': 6.0 + _random.nextDouble() * 3, // 6-9 hours
    };
  }

  // MOTIVATIONAL QUOTES (50 quotes for Mystery Box)
  List<String> motivationalQuotes = [
    "Every step forward is a step towards achieving something bigger and better.",
    "Your body can stand almost anything. It's your mind you have to convince.",
    "Take care of your body. It's the only place you have to live.",
    "The only bad workout is the one that didn't happen.",
    "Small progress is still progress.",
    "You are stronger than you think.",
    "Health is not about the weight you lose, but the life you gain.",
    "Your health is an investment, not an expense.",
    "The groundwork for all happiness is good health.",
    "Movement is a medicine for creating change in a person's physical, emotional, and mental states.",
    "A healthy outside starts from the inside.",
    "Success is the sum of small efforts repeated day in and day out.",
    "Don't stop when you're tired. Stop when you're done.",
    "The body achieves what the mind believes.",
    "Strive for progress, not perfection.",
    "You don't have to be great to start, but you have to start to be great.",
    "Fitness is not about being better than someone else. It's about being better than you used to be.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "Push yourself because no one else is going to do it for you.",
    "Great things never come from comfort zones.",
    "The only way to finish is to start.",
    "Your mind will quit a thousand times before your body will.",
    "Believe in yourself and all that you are.",
    "Today's pain is tomorrow's power.",
    "Wake up with determination. Go to bed with satisfaction.",
    "The harder you work, the luckier you get.",
    "Don't wish for it. Work for it.",
    "Discipline is choosing between what you want now and what you want most.",
    "Your health journey is a marathon, not a sprint.",
    "Every accomplishment starts with the decision to try.",
    "The secret of getting ahead is getting started.",
    "You are capable of amazing things.",
    "Focus on being productive instead of busy.",
    "Be stronger than your excuses.",
    "The difference between try and triumph is a little umph.",
    "Sweat is magic. Cover yourself in it daily to grant your wishes.",
    "A one-hour workout is only 4% of your day.",
    "You're only one workout away from a good mood.",
    "Make yourself a priority once in a while.",
    "Fitness is like marriage. You can't cheat on it and expect it to work.",
    "The only person you should try to be better than is the person you were yesterday.",
    "Take care of yourself from the inside out.",
    "Healthy habits are learned in the same way as unhealthy ones - through practice.",
    "The greatest wealth is health.",
    "Invest in your health today, or pay for your illness tomorrow.",
    "Your body hears everything your mind says. Stay positive.",
    "Health is a relationship between you and your body.",
    "When you feel like quitting, think about why you started.",
    "Don't count the days. Make the days count.",
    "The best project you'll ever work on is you.",
  ];

  String getRandomQuote() {
    return motivationalQuotes[_random.nextInt(motivationalQuotes.length)];
  }

  String getMoodBasedQuote(String moodLevel) {
    // Filter quotes based on mood (simplified version)
    if (moodLevel == 'sad' || moodLevel == 'anxious') {
      List<String> upliftingQuotes = [
        "You are stronger than you think.",
        "Every accomplishment starts with the decision to try.",
        "Believe in yourself and all that you are.",
        "Take care of yourself from the inside out.",
        "Tomorrow is a fresh start.",
      ];
      return upliftingQuotes[_random.nextInt(upliftingQuotes.length)];
    } else if (moodLevel == 'happy' || moodLevel == 'calm') {
      List<String> motivatingQuotes = [
        "Keep up the amazing work!",
        "You're doing great! Stay consistent.",
        "Your positive energy is contagious!",
        "Celebrate your progress today!",
        "You're on the right track!",
      ];
      return motivatingQuotes[_random.nextInt(motivatingQuotes.length)];
    }

    return getRandomQuote();
  }

  // MOTIVATIONAL MESSAGES based on step progress
  String getMotivationalMessage(double percentage) {
    if (percentage < 50) {
      List<String> messages = [
        "Let's get up and move! Every step counts.",
        "Time to lace up those shoes!",
        "Your journey starts with a single step.",
        "Get moving! Your body will thank you.",
      ];
      return messages[_random.nextInt(messages.length)];
    } else if (percentage < 100) {
      List<String> messages = [
        "You're almost there! Keep pushing!",
        "Great progress! Don't stop now!",
        "So close to your goal! You've got this!",
        "Amazing work! Just a bit more!",
      ];
      return messages[_random.nextInt(messages.length)];
    } else {
      List<String> messages = [
        "Great job today! You rocked it! 🎉",
        "Goal achieved! You're unstoppable!",
        "Fantastic! You crushed your goal today!",
        "Incredible work! Keep up the momentum!",
      ];
      return messages[_random.nextInt(messages.length)];
    }
  }
}