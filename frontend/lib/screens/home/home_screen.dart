import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/health_service.dart';
import '../../services/screen_time_service.dart';
import '../../services/dummy_data_service.dart';
import '../../models/user_model.dart';
import '../../models/steps_model.dart';
import '../../models/mood_model.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;

  const HomeScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final HealthService _healthService = HealthService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final DummyDataService _dummyService = DummyDataService();

  UserModel? _user;
  StepsModel? _todaySteps;
  String _motivationalQuote = '';
  int _screenTime = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Start with dummy data as fallback
    UserModel profile = _dummyService.getDummyUser();
    String quote = _dummyService.getRandomQuote();
    int screenTime = _dummyService.getScreenTime();

    try {
      // Fetch real profile from backend
      print('Fetching profile from backend...');
      final fetchedProfile = await _apiService.getProfile();

      if (fetchedProfile != null) {
        print('Profile fetched successfully: ${fetchedProfile.username}');
        profile = fetchedProfile;
      } else {
        print('No profile found in backend, using dummy data');
      }

      // Fetch quote from backend
      quote = await _apiService.getRandomQuote();
      print('Quote fetched: $quote');

      // Get screen time
      screenTime = await _screenTimeService.getTodayScreenTimeMinutes();
      if (screenTime <= 0) {
        screenTime = _dummyService.getScreenTime();
      }
      print('Screen time: $screenTime minutes');
    } catch (e) {
      print('Error loading profile/quote/screenTime: $e');
      // Will use dummy data already set above
    }

    setState(() {
      _user = profile;
      _motivationalQuote = quote;
      _screenTime = screenTime;
    });

    // Sync health data and steps
    await _syncHealthDataFromDevice();
    setState(() => _isLoading = false);
  }

  Future<void> _syncHealthDataFromDevice() async {
    try {
      print('Requesting health permissions...');
      final hasPermission = await _healthService.requestPermissions();

      if (!hasPermission) {
        print('Health permissions not granted, using dummy steps data');
        setState(() => _todaySteps = _dummyService.getTodaySteps());
        return;
      }

      print('Fetching health data from device...');
      final healthData = await _healthService.getTodayHealthData();

      final steps = int.tryParse(healthData['steps']?.toString() ?? '0') ?? 0;
      final activeMinutes = int.tryParse(healthData['activeMinutes']?.toString() ?? '0') ?? 0;
      final distanceMeters = double.tryParse(healthData['distanceMeters']?.toString() ?? '0.0') ?? 0.0;
      final stairsClimbed = int.tryParse(healthData['stairsClimbed']?.toString() ?? '0') ?? 0;
      final caloriesEstimated = int.tryParse(healthData['caloriesEstimated']?.toString() ?? '0') ?? 0;
      final source = healthData['source']?.toString() ?? 'device';

      print('Health data fetched - Steps: $steps, Active Minutes: $activeMinutes');

      // Changed: use goal instead of targetSteps
      final targetSteps = (_user?.goal ?? 10000);

      if (steps > 0) {
        // We have device step data, sync it to backend
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        print('Syncing $steps steps to backend for date: $today');

        try {
          await _apiService.updateSteps(
            date: today,
            stepCount: steps,
            goal: targetSteps,
            distanceMeters: distanceMeters,
            activeMinutes: activeMinutes,
            stairsClimbed: stairsClimbed,
            caloriesEstimated: caloriesEstimated,
            source: source,
          );
          print('Steps synced successfully');

          // Fetch updated steps from backend
          final updatedSteps = await _apiService.getTodaySteps();
          setState(() {
            _todaySteps = updatedSteps ??
                StepsModel(
                  date: DateTime.now(),
                  steps: steps,
                  targetSteps: targetSteps,
                  activeMinutes: activeMinutes,
                  distanceMeters: distanceMeters,
                  stairsClimbed: stairsClimbed,
                  caloriesEstimated: caloriesEstimated,
                );
          });
        } catch (e) {
          print('Error uploading steps to backend: $e');
          // Use local device data as fallback
          setState(() {
            _todaySteps = StepsModel(
              date: DateTime.now(),
              steps: steps,
              targetSteps: targetSteps,
              activeMinutes: activeMinutes,
              distanceMeters: distanceMeters,
              stairsClimbed: stairsClimbed,
              caloriesEstimated: caloriesEstimated,
            );
          });
        }
      } else {
        // No device step data, try to fetch from backend
        print('No device steps, fetching from backend...');
        try {
          final backendSteps = await _apiService.getTodaySteps();
          setState(() {
            _todaySteps = backendSteps ??
                StepsModel(
                  date: DateTime.now(),
                  steps: 0,
                  targetSteps: targetSteps,
                  activeMinutes: 0,
                  distanceMeters: 0.0,
                  stairsClimbed: 0,
                  caloriesEstimated: 0,
                );
          });
          print('Backend steps fetched: ${_todaySteps?.steps ?? 0}');
        } catch (e) {
          print('Error fetching backend steps: $e');
          setState(() {
            _todaySteps = StepsModel(
              date: DateTime.now(),
              steps: 0,
              targetSteps: targetSteps,
              activeMinutes: 0,
              distanceMeters: 0.0,
              stairsClimbed: 0,
              caloriesEstimated: 0,
            );
          });
        }
      }
    } catch (e) {
      print('Error syncing health data: $e');
      setState(() => _todaySteps = _dummyService.getTodaySteps());
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatScreenTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  String _getMoodBackground(String? moodLevel) {
    switch (moodLevel) {
      case 'happy':
        return 'appIcons/happybg.jpg';
      case 'calm':
        return 'appIcons/happy.jpg';
      case 'neutral':
        return 'appIcons/neutral.jpg';
      case 'sad':
        return 'appIcons/sadbg.jpg';
      case 'anxious':
        return 'appIcons/depressedbg.jpg';
      default:
        return 'appIcons/neutral.jpg';
    }
  }

  String _getMoodIcon(String moodLevel) {
    switch (moodLevel) {
      case 'happy':
        return 'appIcons/overjoyed.png';
      case 'calm':
        return 'appIcons/happy.png';
      case 'neutral':
        return 'appIcons/neutral.png';
      case 'sad':
        return 'appIcons/sad.png';
      case 'anxious':
        return 'appIcons/depressed.png';
      default:
        return 'appIcons/neutral.png';
    }
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

    final todayMood = _dummyService.getTodayMood();
    final greeting = _getGreeting();
    final username = _user?.username ?? 'User';
    final steps = _todaySteps?.steps ?? 0;
    final targetSteps = _todaySteps?.targetSteps ?? _user?.goal ?? 10000; // Changed
    final percentage = _todaySteps?.percentage ?? ((steps / targetSteps) * 100).clamp(0, 100);

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFFC16200),
                          backgroundImage: (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
                              ? NetworkImage(_user!.photoUrl!) : null,
                          child: (_user?.photoUrl == null || _user!.photoUrl!.isEmpty)
                              ? Text(
                            (_user?.username.isNotEmpty ?? false)
                                ? _user!.username[0].toUpperCase()
                                : 'U',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                              : null,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(DateTime.now()),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Text(
                              '$greeting, $username',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, size: 28),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              onThemeChanged: widget.onThemeChanged,
                            ),
                          ),
                        );
                        _loadData();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text('Today\'s Steps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildStepsCard(steps, targetSteps, percentage),
                SizedBox(height: 24),
                Text('Current Mood', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildMoodCard(todayMood),
                SizedBox(height: 24),
                Text('Screen Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildScreenTimeCard(),
                SizedBox(height: 24),
                Text('Daily Inspiration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildMotivationalCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsCard(int steps, int targetSteps, double percentage) {
    return Container(
      height: 180,
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
            colors: [
              Color.fromRGBO(0, 0, 0, 0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$steps / $targetSteps',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(MoodModel? mood) {
    String bgImage = _getMoodBackground(mood?.moodLevel);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(0, 0, 0, 0.5), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Current Mood', style: TextStyle(fontSize: 14, color: Colors.white70)),
                SizedBox(height: 4),
                Text(
                  mood != null
                      ? mood.moodLevel.substring(0, 1).toUpperCase() + mood.moodLevel.substring(1)
                      : 'Not set',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            if (mood != null)
              Image.asset(_getMoodIcon(mood.moodLevel), width: 50, height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage('appIcons/screentime.jpg'), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(0, 0, 0, 0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Screen Time Today', style: TextStyle(fontSize: 14, color: Colors.white70)),
            SizedBox(height: 4),
            Text(
              _formatScreenTime(_screenTime),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(76, 175, 80, 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _motivationalQuote.isNotEmpty ? _motivationalQuote : 'Keep pushing forward!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}