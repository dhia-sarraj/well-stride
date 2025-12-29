import 'package:usage_stats/usage_stats.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenTimeService {
  // List of system/background apps to exclude from screen time
  static const List<String> _excludedPackages = [
    'android',
    'com.android.systemui',
    'com.samsung.android.incallui',
    'com.sec.android.app.launcher', // Home launcher
    'com.google.android.permissioncontroller',
    'com.android.settings',
    'com.google.android.packageinstaller',
    'com.android.intentresolver',
    'com.google.android.providers.media.module',
    'com.samsung.android.providers.media',
    'com.android.providers.',
    'com.google.android.networkstack',
    'com.google.android.ext.services',
    'com.samsung.android.app.aodservice',
    'com.sec.android.daemonapp',
    'com.samsung.android.mcfserver',
    'com.samsung.android.mcfds',
    'com.sec.android.app.volumemonitorprovider',
    'com.samsung.android.vexfwk.service',
    'com.android.location.fused',
    'com.sec.epdg',
    'com.facebook.services',
    'com.facebook.system',
    'com.facebook.appmanager',
    'com.microsoft.appmanager',
    'com.google.android.gms',
    'com.samsung.android.samsungpassautofill',
    'com.samsung.android.authfw',
    'com.sec.android.diagmonagent',
    'com.samsung.ipservice',
    'com.sec.sve',
    'com.sec.imsservice',
    'com.samsung.android.fmm',
    'com.samsung.android.scs',
    'com.samsung.klmsagent',
  ];

  /// Request usage stats permission (Android only)
  Future<bool> requestPermission() async {
    try {
      // Check if we already have permission
      bool granted = await UsageStats.checkUsagePermission() ?? false;

      if (!granted) {
        print('Usage stats permission not granted, requesting...');
        await UsageStats.grantUsagePermission();
        granted = await UsageStats.checkUsagePermission() ?? false;
      }

      print('Usage stats permission granted: $granted');
      return granted;
    } catch (e) {
      print('Error requesting usage stats permission: $e');
      return false;
    }
  }

  /// Check if a package should be excluded from screen time calculation
  bool _shouldExcludePackage(String packageName) {
    // Check if package starts with any excluded prefix
    for (final excluded in _excludedPackages) {
      if (packageName.startsWith(excluded)) {
        return true;
      }
    }
    return false;
  }

  Future<int> getTodayScreenTimeMinutes() async {
    try {
      final hasPermission = await requestPermission();

      if (!hasPermission) {
        print('No usage stats permission, cannot get screen time');
        return 0;
      }

      final end = DateTime.now();
      final start = DateTime(end.year, end.month, end.day);

      print('Querying usage stats from $start to $end');
      final stats = await UsageStats.queryUsageStats(start, end);

      if (stats == null || stats.isEmpty) {
        print('No usage stats found');
        return 0;
      }

      int totalMs = 0;
      int excludedMs = 0;

      for (final app in stats) {
        final timeStr = app.totalTimeInForeground ?? '0';
        final time = int.tryParse(timeStr) ?? 0;

        if (time > 0) {
          if (_shouldExcludePackage(app.packageName ?? '')) {
            excludedMs += time;
            print('Excluded: ${app.packageName}, Time: ${time}ms');
          } else {
            totalMs += time;
            print('Counted: ${app.packageName}, Time: ${time}ms');
          }
        }
      }

      print('Total included screen time in ms: $totalMs');
      print('Total excluded (system) time in ms: $excludedMs');

      final minutes = (totalMs / (1000 * 60)).round();
      print('Total screen time: $minutes minutes (${(minutes / 60).toStringAsFixed(1)} hours)');
      return minutes;
    } catch (e) {
      print('Error getting screen time: $e');
      return 0;
    }
  }
}