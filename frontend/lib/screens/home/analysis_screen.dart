import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/dummy_data_service.dart';
import '../../models/steps_model.dart';
import '../../models/mood_model.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final DummyDataService _dataService = DummyDataService();
  String _selectedPeriod = 'Week';

  late List<StepsModel> _stepsHistory;
  late List<MoodModel> _moodHistory;

  @override
  void initState() {
    super.initState();
    _stepsHistory = _dataService.getDummyStepsHistory();
    _moodHistory = _dataService.getDummyMoodHistory();
  }

  List<StepsModel> _getFilteredSteps() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Day':
        return [_stepsHistory.last];
      case 'Week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'Year':
        startDate = now.subtract(Duration(days: 365));
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _stepsHistory.where((s) => s.date.isAfter(startDate)).toList();
  }

  List<MoodModel> _getFilteredMoods() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Day':
        return [_moodHistory.last];
      case 'Week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'Year':
        startDate = now.subtract(Duration(days: 365));
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _moodHistory.where((m) => m.timestamp.isAfter(startDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your progress over time',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Day', 'Week', 'Month', 'Year'].map((period) {
                  bool isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Color(0xFFC16200)
                              : (isDark ? Color(0xFF16213E) : Colors.grey.shade200),
                          foregroundColor: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black),
                          elevation: isSelected ? 2 : 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStepsChart(isDark),
                    SizedBox(height: 20),
                    _buildMoodChart(isDark),
                    SizedBox(height: 20),
                    _buildCorrelationCard(isDark),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsChart(bool isDark) {
    List<StepsModel> data = _getFilteredSteps();

    return Card(
      elevation: 2,
      color: isDark ? Color(0xFF16213E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Steps Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Icon(Icons.directions_walk, color: Color(0xFFC16200)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Daily step count over $_selectedPeriod',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 5000,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              '${(value / 1000).toInt()}k',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 7 ? data.length / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length || value.toInt() < 0) {
                            return Text('');
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(data[value.toInt()].date),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                  minY: 0,
                  maxY: 20000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.steps.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Color(0xFFC16200),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFFC16200),
                            strokeWidth: 2,
                            strokeColor: isDark ? Color(0xFF16213E) : Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Color(0xFFC16200).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()} steps\n${DateFormat('MMM d').format(data[spot.x.toInt()].date)}',
                            TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart(bool isDark) {
    List<MoodModel> data = _getFilteredMoods();

    Map<String, double> moodValues = {
      'happy': 5.0,
      'calm': 4.0,
      'neutral': 3.0,
      'sad': 2.0,
      'anxious': 1.0,
    };

    return Card(
      elevation: 2,
      color: isDark ? Color(0xFF16213E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mood Trends',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Icon(Icons.mood, color: Color(0xFFF093FB)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Your emotional state over $_selectedPeriod',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Mood Level',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          String emoji = '';
                          switch (value.toInt()) {
                            case 5:
                              emoji = '😊';
                              break;
                            case 4:
                              emoji = '😌';
                              break;
                            case 3:
                              emoji = '😐';
                              break;
                            case 2:
                              emoji = '😔';
                              break;
                            case 1:
                              emoji = '😰';
                              break;
                            default:
                              return Text('');
                          }
                          return Text(emoji, style: TextStyle(fontSize: 16));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 7 ? data.length / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length || value.toInt() < 0) {
                            return Text('');
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(data[value.toInt()].timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          moodValues[entry.value.moodLevel] ?? 3.0,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Color(0xFFF093FB),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFFF093FB),
                            strokeWidth: 2,
                            strokeColor: isDark ? Color(0xFF16213E) : Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Color(0xFFF093FB).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String moodLabel = data[spot.x.toInt()].moodLevel;
                          return LineTooltipItem(
                            '${moodLabel.substring(0, 1).toUpperCase()}${moodLabel.substring(1)}\n${DateFormat('MMM d').format(data[spot.x.toInt()].timestamp)}',
                            TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationCard(bool isDark) {
    List<StepsModel> steps = _getFilteredSteps();
    List<MoodModel> moods = _getFilteredMoods();

    int totalSteps = steps.fold(0, (sum, s) => sum + s.steps);
    int avgSteps = totalSteps ~/ steps.length;

    int happyMoods = moods.where((m) => m.moodLevel == 'happy' || m.moodLevel == 'calm').length;
    double happyPercentage = (happyMoods / moods.length * 100);

    return Card(
      elevation: 2,
      color: isDark ? Color(0xFF16213E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights & Correlations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Key statistics from your data',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),

            _buildInsightRow(
              Icons.directions_walk,
              'Average Daily Steps',
              '${avgSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps',
              Color(0xFFC16200),
              isDark,
            ),

            SizedBox(height: 12),

            _buildInsightRow(
              Icons.mood,
              'Positive Mood Days',
              '${happyPercentage.toStringAsFixed(0)}% of days',
              Color(0xFF4CAF50),
              isDark,
            ),

            SizedBox(height: 12),

            _buildInsightRow(
              Icons.timeline,
              'Total Distance',
              '${((avgSteps * steps.length) * 0.000762).toStringAsFixed(1)} km',
              Color(0xFF2196F3),
              isDark,
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFC16200).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Color(0xFFC16200),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You tend to feel better on days with higher step counts! Keep moving to boost your mood.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}