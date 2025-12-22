import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/dummy_data_service.dart';
import '../../models/steps_model.dart';
import '../../models/mood_model.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DummyDataService _dataService = DummyDataService();
  late StepsModel _todaySteps;
  late String _greeting;
  late String _motivationalMessage;
  int _screenTime = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _todaySteps = _dataService.getTodaySteps();
    _screenTime = _dataService.getScreenTime();
    _greeting = _getGreeting();
    _motivationalMessage = _dataService.getMotivationalMessage(_todaySteps.percentage);
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatScreenTime(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  String _getMoodBackground(String? moodLevel) {
    if (moodLevel == null) return 'appIcons/neutral.jpg';

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

  @override
  Widget build(BuildContext context) {
    final user = _dataService.getDummyUser();
    final todayMood = _dataService.getTodayMood();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Header with profile and settings
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Row(
                children: [
                // Profile Picture
                CircleAvatar(
                radius: 25,
                    backgroundColor: Color(0xFFC16200),
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '$_greeting, ${user.username}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                ),
                      // Settings Icon
                      IconButton(
                        icon: Icon(Icons.settings_outlined, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen()),
                          );
                        },
                      ),
                    ],
                    ),

                      SizedBox(height: 32),

                      // Steps Section
                      Text(
                        'Today\'s Steps',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildStepsCard(),

                      SizedBox(height: 24),

                      // Current Mood Section
                      Text(
                        'Current Mood',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildMoodCard(todayMood),

                      SizedBox(height: 24),

                      // Screen Time Section
                      Text(
                        'Screen Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildScreenTimeCard(),

                      SizedBox(height: 24),

                      // Motivational Message
                      Text(
                        'Daily Inspiration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildMotivationalCard(),
                    ],
                ),
            ),
        ),
    );
  }
  Widget _buildStepsCard() {
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
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
              '${_todaySteps.steps} / ${_todaySteps.targetSteps}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _todaySteps.percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${_todaySteps.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
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
                Text(
                  'Current Mood',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  mood != null
                      ? mood.moodLevel.substring(0, 1).toUpperCase() + mood.moodLevel.substring(1)
                      : 'Not set',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (mood != null)
              Image.asset(
                _getMoodIcon(mood.moodLevel),
                width: 50,
                height: 50,
              ),
          ],
        ),
      ),
    );
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
  Widget _buildScreenTimeCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('appIcons/screentime.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
              'Screen Time Today',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatScreenTime(_screenTime),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _motivationalMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}