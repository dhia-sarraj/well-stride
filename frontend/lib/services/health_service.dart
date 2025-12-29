import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rook_sdk_core/rook_sdk_core.dart';
import 'package:rook_sdk_samsung_health/rook_sdk_samsung_health.dart';
import 'dart:io' show Platform;

class HealthService {
  final Health _health = Health();

  // Add stress to your health types
  static final List<HealthDataType> _healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.FLIGHTS_CLIMBED,

    // Samsung stress data (available via Health Connect)
    HealthDataType.HEART_RATE_VARIABILITY_SDNN, // This is what Samsung uses for stress
  ];

  static final List<HealthDataAccess> _permissions = _healthTypes
      .map((type) => HealthDataAccess.READ)
      .toList();

  /// Request all health permissions
  Future<bool> requestPermissions() async {
    try {
      print('Requesting health permissions...');

      // Request Health Connect permissions
      bool granted = await _health.requestAuthorization(_healthTypes, permissions: _permissions);

      print('Health permissions granted: $granted');
      return granted;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Get stress level from Samsung Health via Health Connect
  /// Returns stress level 0-100 (0 = relaxed, 100 = very stressed)
  Future<int?> getStressLevel() async {
    try {
      print('Note: Stress measurement requires Samsung Health SDK integration');
      print('Health Connect does not yet support HRV data from Samsung devices');
      // Return null to show "Tap to measure" with explanation
      return null;
    } catch (e) {
      print('Error getting stress level: $e');
      return null;
    }
  }

  /// Convert HRV (SDNN) to stress level
  /// HRV ranges typically 20-200ms
  /// Higher HRV = More relaxed (lower stress)
  /// Lower HRV = More stressed (higher stress)
  int _calculateStressFromHRV(double hrv) {
    if (hrv >= 100) return 20;  // Very relaxed
    if (hrv >= 80) return 30;   // Relaxed
    if (hrv >= 60) return 40;   // Slightly relaxed
    if (hrv >= 50) return 50;   // Normal
    if (hrv >= 40) return 60;   // Slightly stressed
    if (hrv >= 30) return 70;   // Stressed
    if (hrv >= 20) return 80;   // Very stressed
    return 90;                   // Extremely stressed
  }

  /// Get today's health data (update to include stress)
  Future<Map<String, dynamic>> getTodayHealthData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Get all health data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _healthTypes,
        startTime: startOfDay,
        endTime: now,
      );

      print('Total health data points: ${healthData.length}');

      // Process the data
      int steps = 0;
      int activeMinutes = 0;
      double distanceMeters = 0;
      int stairsClimbed = 0;
      int caloriesEstimated = 0;
      double? heartRate;
      double? oxygenLevel;
      double? sleepHours;
      int? stressLevel;

      for (var data in healthData) {
        final value = double.tryParse(data.value.toString()) ?? 0;

        switch (data.type) {
          case HealthDataType.STEPS:
            steps += value.toInt();
            break;
          case HealthDataType.HEART_RATE:
            heartRate = value;
            break;
          case HealthDataType.BLOOD_OXYGEN:
            oxygenLevel = value;
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            caloriesEstimated = value.toInt();
            break;
          case HealthDataType.DISTANCE_DELTA:
            distanceMeters += value;
            break;
          case HealthDataType.FLIGHTS_CLIMBED:
            stairsClimbed += value.toInt();
            break;
          case HealthDataType.SLEEP_ASLEEP:
            final duration = data.dateTo.difference(data.dateFrom);
            sleepHours = duration.inMinutes / 60.0;
            break;
          case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
            stressLevel = _calculateStressFromHRV(value);
            break;
          default:
            break;
        }
      }

      return {
        'steps': steps,
        'activeMinutes': activeMinutes,
        'distanceMeters': distanceMeters,
        'stairsClimbed': stairsClimbed,
        'caloriesEstimated': caloriesEstimated,
        'heartRate': heartRate?.round(),
        'oxygenLevel': oxygenLevel?.round(),
        'sleepHours': sleepHours,
        'stressLevel': stressLevel, // NOW INCLUDED!
        'source': 'HealthConnect',
      };
    } catch (e) {
      print('Error getting health data: $e');
      return {};
    }
  }

  // Keep your existing methods for heart rate and blood oxygen
  Future<int?> getHeartRate() async {
    try {
      final now = DateTime.now();
      // Expanded time window: look at today's data
      final startOfToday = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> hrData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfToday,
        endTime: now,
      );

      print('Heart rate data points found: ${hrData.length}');
      if (hrData.isEmpty) return null;

      // Get the most recent reading
      final latestHR = hrData.last;
      return double.tryParse(latestHR.value.toString())?.round();
    } catch (e) {
      print('Error getting heart rate: $e');
      return null;
    }
  }

  Future<int?> getBloodOxygen() async {
    try {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(Duration(minutes: 5));

      List<HealthDataPoint> o2Data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: fiveMinutesAgo,
        endTime: now,
      );

      if (o2Data.isEmpty) return null;

      final latestO2 = o2Data.last;
      return double.tryParse(latestO2.value.toString())?.round();
    } catch (e) {
      print('Error getting blood oxygen: $e');
      return null;
    }
  }

  Future<void> debugHealthConnectStatus() async {
    print('=== Health Connect Debug ===');
    print('Has Activity Recognition: ${await Permission.activityRecognition.isGranted}');
    print('Has Location: ${await Permission.location.isGranted}');

    // Try to check Health Connect availability
    bool available = await _health.hasPermissions(_healthTypes, permissions: _permissions) ?? false;
    print('Health Connect available: $available');

    // List what permissions are granted
    for (var type in _healthTypes) {
      print('$type: checking...');
    }
  }
}