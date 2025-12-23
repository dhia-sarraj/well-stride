import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class HealthService {
  // Singleton pattern
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  /// All health data types we want to access
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.FLIGHTS_CLIMBED,
  ];

  /// Request health permissions
  Future<bool> requestPermissions() async {
    try {
      // Request activity recognition permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Request health data access
      final permissions = _types.map((type) => HealthDataAccess.READ).toList();
      final authorized = await _health.requestAuthorization(_types, permissions: permissions);

      return authorized;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Get steps for today
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  /// Get steps for a specific date range
  Future<int> getStepsInRange(DateTime start, DateTime end) async {
    try {
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      print('Error getting steps in range: $e');
      return 0;
    }
  }

  /// Get heart rate (most recent reading)
  Future<int?> getHeartRate() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));

      final data = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );

      if (data.isNotEmpty) {
        // Get the most recent heart rate reading
        final latestReading = data.last;
        return (latestReading.value as num).toInt();
      }
      return null;
    } catch (e) {
      print('Error getting heart rate: $e');
      return null;
    }
  }

  /// Get blood oxygen level (most recent reading)
  Future<int?> getBloodOxygen() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));

      final data = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.BLOOD_OXYGEN],
      );

      if (data.isNotEmpty) {
        final latestReading = data.last;
        return (latestReading.value as num).toInt();
      }
      return null;
    } catch (e) {
      print('Error getting blood oxygen: $e');
      return null;
    }
  }

  /// Get sleep hours for last night
  Future<double> getSleepHours() async {
    try {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 18, 0);

      final sleepData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED,],
      );

      if (sleepData.isEmpty) return 0;

      // Calculate total sleep duration in hours
      double totalMinutes = 0;
      for (var data in sleepData) {
        if (data.type == HealthDataType.SLEEP_ASLEEP) {
          totalMinutes += (data.value as num).toDouble();
        }
      }

      return totalMinutes / 60; // Convert to hours
    } catch (e) {
      print('Error getting sleep data: $e');
      return 0;
    }
  }

  /// Get distance walked today (in meters)
  Future<double> getDistanceToday() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.DISTANCE_DELTA],
      );

      if (data.isEmpty) return 0;

      double totalDistance = 0;
      for (var point in data) {
        totalDistance += (point.value as num).toDouble();
      }

      return totalDistance;
    } catch (e) {
      print('Error getting distance: $e');
      return 0;
    }
  }

  /// Get stairs/floors climbed today
  Future<int> getStairsClimbedToday() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.FLIGHTS_CLIMBED],
      );

      if (data.isEmpty) return 0;

      int totalFlights = 0;
      for (var point in data) {
        totalFlights += (point.value as num).toInt();
      }

      return totalFlights;
    } catch (e) {
      print('Error getting stairs: $e');
      return 0;
    }
  }

  /// Get calories burned today
  Future<int> getCaloriesToday() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types:[HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      if (data.isEmpty) return 0;

      double totalCalories = 0;
      for (var point in data) {
        totalCalories += (point.value as num).toDouble();
      }

      return totalCalories.toInt();
    } catch (e) {
      print('Error getting calories: $e');
      return 0;
    }
  }

  /// Get active minutes today
  Future<int> getActiveMinutesToday() async {
    try {
      final steps = await getTodaySteps();
      // Rough estimate: 100 steps = 1 active minute
      return (steps / 100).round();
    } catch (e) {
      print('Error calculating active minutes: $e');
      return 0;
    }
  }

  /// Comprehensive health data for today
  Future<Map<String, dynamic>> getTodayHealthData() async {
    try {
      final steps = await getTodaySteps();
      final distance = await getDistanceToday();
      final activeMinutes = await getActiveMinutesToday();
      final stairs = await getStairsClimbedToday();
      final calories = await getCaloriesToday();
      final heartRate = await getHeartRate();
      final oxygen = await getBloodOxygen();
      final sleep = await getSleepHours();

      return {
        'steps': steps,
        'distanceMeters': distance,
        'activeMinutes': activeMinutes,
        'stairsClimbed': stairs,
        'caloriesEstimated': calories,
        'heartRate': heartRate,
        'oxygenLevel': oxygen,
        'sleepHours': sleep,
        'source': Platform.isIOS ? 'AppleHealth' : 'GoogleFit',
      };
    } catch (e) {
      print('Error getting health data: $e');
      return {};
    }
  }
}