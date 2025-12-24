import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/health_service.dart';
import '../../services/dummy_data_service.dart';
import '../../models/steps_model.dart';
import '../../models/user_model.dart';

class FitnessScreen extends StatefulWidget {
  @override
  _FitnessScreenState createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  final ApiService _apiService = ApiService();
  final HealthService _healthService = HealthService();
  final DummyDataService _dummyService = DummyDataService();

  UserModel? _user;
  StepsModel? _todaySteps;
  Map<String, dynamic> _healthMetrics = {};

  bool _isLoading = true;
  bool _isLoadingHeartRate = false;
  bool _isLoadingOxygen = false;
  bool _isLoadingStress = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fitness: Loading data...');

      // Load user profile
      final profile = await _apiService.getProfile();
      print('Fitness: Profile loaded - Height: ${profile?.height}, Weight: ${profile?.weight}');

      // Load today's steps - allow null if not available
      StepsModel? steps;
      try {
        steps = await _apiService.getTodaySteps();
        print('Fitness: Steps loaded - ${steps?.steps ?? 0}');
      } catch (e) {
        print('Fitness: Steps not available, will use fallback: $e');
      }

      // Request health permissions and get data
      final hasPermission = await _healthService.requestPermissions();
      Map<String, dynamic> healthData = {};

      if (hasPermission) {
        healthData = await _healthService.getTodayHealthData();
        print('Fitness: Health data loaded: $healthData');
      } else {
        print('Fitness: Health permissions not granted, metrics will show "Tap to measure"');
      }

      setState(() {
        _user = profile ?? _dummyService.getDummyUser();
        _todaySteps = steps ?? _dummyService.getTodaySteps();
        _healthMetrics = healthData;
        _isLoading = false;
      });
    } catch (e) {
      print('Fitness: Error loading data: $e');
      // Use dummy data as fallback
      setState(() {
        _user = _dummyService.getDummyUser();
        _todaySteps = _dummyService.getTodaySteps();
        _healthMetrics = {};
        _isLoading = false;
      });
    }
  }

  String _getStepMessage() {
    if (_todaySteps == null) return "Let's get moving!";
    double percentage = _todaySteps!.percentage;
    if (percentage < 50) {
      return "Let's get up and move! 🚶";
    } else if (percentage < 100) {
      return "You're almost there! 💪";
    } else {
      return "Great job today! You rocked! 🎉";
    }
  }

  Future<void> _measureHeartRate() async {
    setState(() {
      _isLoadingHeartRate = true;
    });

    try {
      final heartRate = await _healthService.getHeartRate();
      setState(() {
        if (heartRate != null) {
          _healthMetrics['heartRate'] = heartRate;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Heart rate data not available')),
          );
        }
      });
    } catch (e) {
      print('Error measuring heart rate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access heart rate data')),
      );
    } finally {
      setState(() {
        _isLoadingHeartRate = false;
      });
    }
  }

  Future<void> _measureOxygen() async {
    setState(() {
      _isLoadingOxygen = true;
    });

    try {
      final oxygen = await _healthService.getBloodOxygen();
      setState(() {
        if (oxygen != null) {
          _healthMetrics['oxygenLevel'] = oxygen;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Oxygen level data not available')),
          );
        }
      });
    } catch (e) {
      print('Error measuring oxygen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access oxygen data')),
      );
    } finally {
      setState(() {
        _isLoadingOxygen = false;
      });
    }
  }

  Future<void> _measureStress() async {
    setState(() {
      _isLoadingStress = true;
    });

    try {
      final stressLevel = await _healthService.getStressLevel();
      setState(() {
        if (stressLevel != null) {
          _healthMetrics['stressLevel'] = stressLevel;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stress data not available. Make sure Samsung Health is synced.')),
          );
        }
      });
    } catch (e) {
      print('Error measuring stress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access stress data')),
      );
    } finally {
      setState(() {
        _isLoadingStress = false;
      });
    }
  }

  String _getSleepMessage(double hours) {
    if (hours < 6) {
      return "Try to get more sleep! 💤";
    } else if (hours < 7) {
      return "Almost there! Aim for 7-9 hours.";
    } else if (hours <= 9) {
      return "Great sleep! Well done! ✨";
    } else {
      return "That's a lot of sleep! 😴";
    }
  }

  double _calculateBMI() {
    if (_user == null) return 22.0;
    print('Calculating BMI - Height: ${_user!.height}, Weight: ${_user!.weight}');
    double heightInMeters = _user!.height / 100;
    double bmi = _user!.weight / (heightInMeters * heightInMeters);
    print('BMI calculated: $bmi');
    return bmi;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Color(0xFF3498DB);
    if (bmi < 25) return Color(0xFF4CAF50);
    if (bmi < 30) return Color(0xFFF39C12);
    return Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fitness',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your physical activity',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24),
                _buildStepsCard(),
                SizedBox(height: 24),
                _buildBMICard(),
                SizedBox(height: 24),
                Text(
                  'Health Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildHeartRateCard()),
                    SizedBox(width: 12),
                    Expanded(child: _buildOxygenCard()),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStressCard()),
                    SizedBox(width: 12),
                    Expanded(child: _buildSleepCard()),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    final steps = _todaySteps?.steps ?? 0;
    final targetSteps = _todaySteps?.targetSteps ?? _user?.goal ?? 10000;
    final percentage = _todaySteps?.percentage ?? 0.0;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('appIcons/steps.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Steps Today', style: TextStyle(fontSize: 16, color: Colors.white70)),
                      SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$steps',
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_walk, size: 32, color: Colors.white),
                ),
              ],
            ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${percentage.toStringAsFixed(0)}% of $targetSteps',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${(targetSteps - steps).clamp(0, targetSteps)} left',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getStepMessage(),
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    double bmi = _calculateBMI();
    String category = _getBMICategory(bmi);
    Color bmiColor = _getBMIColor(bmi);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Color(0xFF16213E) : Colors.white,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Mass Index',
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: bmiColor),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'kg/m²',
                            style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(color: bmiColor, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight:', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                      Text(
                        '${_user?.weight.toStringAsFixed(1) ?? "0.0"} kg',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Height:', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                      Text(
                        '${_user?.height.toStringAsFixed(0) ?? "0"} cm',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage('appIcons/happybg.jpg'), fit: BoxFit.cover),
      ),
      child: InkWell(
        onTap: _isLoadingHeartRate ? null : _measureHeartRate,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Heart Rate', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 8),
                  _isLoadingHeartRate
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                      : _healthMetrics['heartRate'] != null
                      ? Text(
                    '${_healthMetrics['heartRate']} bpm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                      : Text('Tap to measure', style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOxygenCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage('appIcons/neutral.jpg'), fit: BoxFit.cover),
      ),
      child: InkWell(
        onTap: _isLoadingOxygen ? null : _measureOxygen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.water_drop, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oxygen', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 8),
                  _isLoadingOxygen
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                      : _healthMetrics['oxygenLevel'] != null
                      ? Text(
                    '${_healthMetrics['oxygenLevel']}%',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                      : Text('Tap to measure', style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStressCard() {
    final stressLevel = _healthMetrics['stressLevel'];

    // Color based on stress level
    Color getStressColor(int? level) {
      if (level == null) return Colors.grey;
      if (level < 30) return Color(0xFF4CAF50); // Green - relaxed
      if (level < 50) return Color(0xFF8BC34A); // Light green - normal
      if (level < 70) return Color(0xFFFFC107); // Yellow - moderate
      if (level < 85) return Color(0xFFFF9800); // Orange - stressed
      return Color(0xFFE74C3C); // Red - very stressed
    }

    String getStressLabel(int? level) {
      if (level == null) return 'Unknown';
      if (level < 30) return 'Relaxed';
      if (level < 50) return 'Normal';
      if (level < 70) return 'Moderate';
      if (level < 85) return 'Stressed';
      return 'High';
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage('appIcons/sadbg.jpg'), fit: BoxFit.cover),
      ),
      child: InkWell(
        onTap: _isLoadingStress ? null : _measureStress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stress Level', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 8),
                  _isLoadingStress
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                      : stressLevel != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$stressLevel/100',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStressColor(stressLevel).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: getStressColor(stressLevel), width: 1),
                        ),
                        child: Text(
                          getStressLabel(stressLevel),
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                      : Text('Tap to measure', style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    final sleepHours = _healthMetrics['sleepHours'] ?? 0.0;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage('appIcons/overjoyed.jpg'), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.bedtime, color: Colors.white, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep', style: TextStyle(fontSize: 14, color: Colors.white70)),
                SizedBox(height: 8),
                sleepHours > 0
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${sleepHours.toStringAsFixed(1)}h',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getSleepMessage(sleepHours),
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                )
                    : Text('No data yet', style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}