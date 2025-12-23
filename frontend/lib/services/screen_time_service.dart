import 'package:usage_stats/usage_stats.dart';

class ScreenTimeService {
  Future<int> getTodayScreenTimeMinutes() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(hours: 24));

    final stats = await UsageStats.queryUsageStats(start, end);

    int totalMs = 0;
    for (final app in stats) {
      totalMs += int.tryParse(app.totalTimeInForeground ?? '0') ?? 0;
    }

    return (totalMs / 1000 / 60).round();
  }
}
