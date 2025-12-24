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
      // Load user profile
      final profile = await _apiService.getProfile();

      // Load today's steps
      final steps = await _apiService.getTodaySteps();

      // Request health permissions and get data
      final hasPermission = await _healthService.requestPermissions();
      if (hasPermission) {
        final healthData = await _healthService.getTodayHealthData();
        setState(() {
          _healthMetrics = healthData;
        });
      } else {
        // Use dummy data if no permissions
        setState(() {
          _healthMetrics = _dummyService.getHealthMetrics();
        });
      }

      setState(() {
        _user = profile ?? _dummyService.getDummyUser();
        _todaySteps = steps ?? _dummyService.getTodaySteps();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading fitness data: $e');
      setState(() {
        _user = _dummyService.getDummyUser();
        _todaySteps = _dummyService.getTodaySteps();
        _healthMetrics = _dummyService.getHealthMetrics();
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
        }
      });
    } catch (e) {
      print('Error measuring heart rate: $e');
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
        }
      });
    } catch (e) {
      print('Error measuring oxygen: $e');
    } finally {
      setState(() {
        _isLoadingOxygen = false;
      });
    }
  }

  void _measureStress() async {
    setState(() {
      _isLoadingStress = true;
    });

    // Stress level is not available from health APIs
    // Using dummy data
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _healthMetrics['stressLevel'] = _dummyService.getHealthMetrics()['stressLevel'];
      _isLoadingStress = false;
    });
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
    double heightInMeters = _user!.height / 100;
    return _user!.weight / (heightInMeters * heightInMeters);
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
    final targetSteps = _todaySteps?.targetSteps ?? 10000;
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
                        '${targetSteps - steps} left',
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
                      : _healthMetrics['stressLevel'] != null
                      ? Text(
                    '${_healthMetrics['stressLevel']}/100',
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
            ),
          ],
        ),
      ),
    );
  }
}