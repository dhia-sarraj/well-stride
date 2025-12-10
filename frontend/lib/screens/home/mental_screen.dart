import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/dummy_data_service.dart';
import '../../models/mood_model.dart';

class MentalScreen extends StatefulWidget {
  @override
  _MentalScreenState createState() => _MentalScreenState();
}

class _MentalScreenState extends State<MentalScreen> {
  final DummyDataService _dataService = DummyDataService();
  MoodModel? _todayMood;

  @override
  void initState() {
    super.initState();
    _todayMood = _dataService.getTodayMood();
  }

  void _openMoodTracker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodTrackerSheet(
        onMoodSelected: (mood) {
          setState(() {
            _todayMood = mood;
          });
        },
      ),
    );
  }

  void _openBreathingTimer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BreathingTimerScreen()),
    );
  }

  void _openMysteryBox() {
    showDialog(
      context: context,
      builder: (context) => MysteryBoxDialog(
        moodLevel: _todayMood?.moodLevel,
      ),
    );
  }

  String _getMoodIcon(String? moodLevel) {
    if (moodLevel == null) return 'appIcons/neutral.png';

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
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mental Wellness',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Track your emotional health',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 32),

              _buildMoodTrackerCard(),

              SizedBox(height: 16),

              _buildBreathingTimerCard(),

              SizedBox(height: 16),

              _buildMysteryBoxCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodTrackerCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: _openMoodTracker,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
                        'Mood Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'How are you feeling today?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    _getMoodIcon(_todayMood?.moodLevel),
                    width: 60,
                    height: 60,
                  ),
                ],
              ),

              Spacer(),

              if (_todayMood != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feeling: ${_todayMood!.moodLevel.substring(0, 1).toUpperCase()}${_todayMood!.moodLevel.substring(1)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_todayMood!.reasons.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _todayMood!.reasons.take(3).map((reason) {
                            return Chip(
                              label: Text(reason),
                              backgroundColor: Colors.white.withOpacity(0.3),
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tap to log your mood',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingTimerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _openBreathingTimer,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.air,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Breathing Timer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Calm your mind with guided breathing',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMysteryBoxCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _openMysteryBox,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage('appIcons/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mystery Box',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover an inspiring quote',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MOOD TRACKER BOTTOM SHEET
class MoodTrackerSheet extends StatefulWidget {
  final Function(MoodModel) onMoodSelected;

  MoodTrackerSheet({required this.onMoodSelected});

  @override
  _MoodTrackerSheetState createState() => _MoodTrackerSheetState();
}

class _MoodTrackerSheetState extends State<MoodTrackerSheet> {
  String? _selectedMoodLevel;
  List<String> _selectedReasons = [];
  TextEditingController _noteController = TextEditingController();

  final Map<String, String> moodIcons = {
    'happy': 'appIcons/overjoyed.png',
    'calm': 'appIcons/happy.png',
    'neutral': 'appIcons/neutral.png',
    'sad': 'appIcons/sad.png',
    'anxious': 'appIcons/depressed.png',
  };

  final Map<String, String> moodLabels = {
    'happy': 'Happy',
    'calm': 'Calm',
    'neutral': 'Neutral',
    'sad': 'Sad',
    'anxious': 'Anxious',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveMood() {
    if (_selectedMoodLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    MoodModel mood = MoodModel(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      emoji: '😊', // Not used anymore, but kept for compatibility
      moodLevel: _selectedMoodLevel!,
      reasons: _selectedReasons,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    widget.onMoodSelected(mood);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Mood selection with custom icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: moodIcons.entries.map((entry) {
                      bool isSelected = _selectedMoodLevel == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMoodLevel = entry.key;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFFC16200).withOpacity(0.2)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFFC16200)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Image.asset(
                                entry.value,
                                width: 40,
                                height: 40,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              moodLabels[entry.key]!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  if (_selectedMoodLevel != null) ...[
                    SizedBox(height: 40),

                    Text(
                      'What\'s contributing to this?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moodReasons.map((reason) {
                        bool isSelected = _selectedReasons.contains(reason);
                        return FilterChip(
                          label: Text(reason),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedReasons.add(reason);
                              } else {
                                _selectedReasons.remove(reason);
                              }
                            });
                          },
                          selectedColor: Color(0xFFC16200).withOpacity(0.3),
                          checkmarkColor: Color(0xFFC16200),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 32),

                    Text(
                      'Add a note (optional)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12),

                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write how you\'re feeling...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMood,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFC16200),
                      ),
                      child: Text(
                        'Save Mood',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BREATHING TIMER SCREEN - NEW DESIGN
class BreathingTimerScreen extends StatefulWidget {
  @override
  _BreathingTimerScreenState createState() => _BreathingTimerScreenState();
}

class _BreathingTimerScreenState extends State<BreathingTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isBreathingIn = true;
  Timer? _timer;
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startBreathing();
  }

  void _startBreathing() {
    _controller.forward();
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_isBreathingIn) {
        _controller.reverse();
        setState(() {
          _isBreathingIn = false;
        });
      } else {
        _controller.forward();
        setState(() {
          _isBreathingIn = true;
          _breathCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          children: [
            // Left side - Breathe In (Green)
            Expanded(
              child: Container(
                color: Color(0xFF93C47D),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: _isBreathingIn ? 150 * _animation.value : 75,
                        height: _isBreathingIn ? 150 * _animation.value : 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            width: _isBreathingIn ? 100 * _animation.value : 50,
                            height: _isBreathingIn ? 100 * _animation.value : 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Center(
                              child: Container(
                                width: _isBreathingIn ? 50 * _animation.value : 25,
                                height: _isBreathingIn ? 50 * _animation.value : 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Right side - Breathe Out (Orange)
            Expanded(
              child: Container(
                color: Color(0xFFE69138),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: !_isBreathingIn ? 150 * _animation.value : 75,
                        height: !_isBreathingIn ? 150 * _animation.value : 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            width: !_isBreathingIn ? 100 * _animation.value : 50,
                            height: !_isBreathingIn ? 100 * _animation.value : 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Center(
                              child: Container(
                                width: !_isBreathingIn ? 50 * _animation.value : 25,
                                height: !_isBreathingIn ? 50 * _animation.value : 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button at top
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),

          // Instructions at bottom
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _isBreathingIn ? 'Breathe In' : 'Breathe Out',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Breath Count: $_breathCount',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// MYSTERY BOX DIALOG
class MysteryBoxDialog extends StatefulWidget {
  final String? moodLevel;

  MysteryBoxDialog({this.moodLevel});

  @override
  _MysteryBoxDialogState createState() => _MysteryBoxDialogState();
}

class _MysteryBoxDialogState extends State<MysteryBoxDialog> {
  final DummyDataService _dataService = DummyDataService();
  bool _isRevealed = false;
  String _quote = '';

  @override
  void initState() {
    super.initState();
    _quote = widget.moodLevel != null
        ? _dataService.getMoodBasedQuote(widget.moodLevel!)
        : _dataService.getRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage('appIcons/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.3)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white,
              ),

              SizedBox(height: 24),

              Text(
                'Mystery Box',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 24),

              if (!_isRevealed) ...[
                Text(
                  'Tap to reveal your inspirational quote',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isRevealed = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFC16200),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    'Reveal Quote',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _quote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}