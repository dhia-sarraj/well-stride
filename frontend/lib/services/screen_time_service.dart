import 'package:usage_stats/usage_stats.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenTimeService {
  /// Request usage stats permission (Android only)
  Future<bool> requestPermission() async {
    try {
      // Check if we already have permission
      bool granted = await UsageStats.checkUsagePermission() ?? false;

      if (!granted) {
        print('Usage stats permission not granted, requesting...');
        // This will open the settings page for the user to grant permission
        // Note: grantUsagePermission() returns void, not bool
        await UsageStats.grantUsagePermission();

        // After requesting, check again if permission was granted
        granted = await UsageStats.checkUsagePermission() ?? false;
      }

      print('Usage stats permission granted: $granted');
      return granted;
    } catch (e) {
      print('Error requesting usage stats permission: $e');
      return false;
    }
  }

  Future<int> getTodayScreenTimeMinutes() async {
    try {
      // First check/request permission
      final hasPermission = await requestPermission();

      if (!hasPermission) {
        print('No usage stats permission, cannot get screen time');
        return 0;
      }

      final end = DateTime.now();
      final start = DateTime(end.year, end.month, end.day); // Start of today

      print('Querying usage stats from $start to $end');
      final stats = await UsageStats.queryUsageStats(start, end);

      if (stats == null || stats.isEmpty) {
        print('No usage stats found');
        return 0;
      }

      int totalMs = 0;
      for (final app in stats) {
        final timeStr = app.totalTimeInForeground ?? '0';
        final time = int.tryParse(timeStr) ?? 0;
        totalMs += time;
      }

      final minutes = (totalMs / 1000 / 60).round();
      print('Total screen time: $minutes minutes');
      return minutes;
    } catch (e) {
      print('Error getting screen time: $e');
      return 0;
    }
  }
}