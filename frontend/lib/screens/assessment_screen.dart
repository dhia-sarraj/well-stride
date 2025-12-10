import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AssessmentScreen extends StatefulWidget {
  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentPage = 0;
  final int _totalPages = 6;

  // Form data
  String _username = '';
  int _age = 25;
  double _weight = 70.0;
  String _weightUnit = 'kg';
  double _height = 170.0;
  String _heightUnit = 'cm';
  String _sex = 'Male';
  int _targetSteps = 10000;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndContinue();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveAndContinue() {
    print('Username: $_username');
    print('Age: $_age');
    print('Weight: $_weight $_weightUnit');
    print('Height: $_height $_heightUnit');
    print('Sex: $_sex');
    print('Target Steps: $_targetSteps');

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC16200),
      appBar: AppBar(
        backgroundColor: Color(0xFFC16200),
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousPage,
        )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildUsernamePage(),
                  _buildAgePage(),
                  _buildWeightPage(),
                  _buildHeightPage(),
                  _buildSexPage(),
                  _buildTargetStepsPage(),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFFC16200),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // USERNAME PAGE
  Widget _buildUsernamePage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "What should we call you?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          TextFormField(
            initialValue: _username,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.person_outline, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _username = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // AGE PAGE - Scroll Wheel Picker
  Widget _buildAgePage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "How old are you?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 60),
          Center(
            child: Container(
              height: 250,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _age - 13),
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _age = index + 13;
                  });
                },
                children: List<Widget>.generate(88, (index) {
                  int age = index + 13;
                  return Center(
                    child: Text(
                      '$age',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'years old',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // WEIGHT PAGE - Number Input with Unit Toggle
  Widget _buildWeightPage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "What's your weight?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                // Weight input
                Container(
                  width: 200,
                  child: TextFormField(
                    initialValue: _weight.toStringAsFixed(1),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.0',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _weight = double.tryParse(value) ?? _weight;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Unit toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUnitButton('kg', _weightUnit == 'kg', () {
                      setState(() {
                        if (_weightUnit == 'lbs') {
                          _weight = _weight * 0.453592; // Convert lbs to kg
                        }
                        _weightUnit = 'kg';
                      });
                    }),
                    SizedBox(width: 16),
                    _buildUnitButton('lbs', _weightUnit == 'lbs', () {
                      setState(() {
                        if (_weightUnit == 'kg') {
                          _weight = _weight * 2.20462; // Convert kg to lbs
                        }
                        _weightUnit = 'lbs';
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEIGHT PAGE - Slider with Unit Toggle
  Widget _buildHeightPage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "What's your height?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Text(
                  _heightUnit == 'cm'
                      ? '${_height.toStringAsFixed(0)}'
                      : '${(_height / 30.48).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _heightUnit,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 32),
                // Unit toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUnitButton('cm', _heightUnit == 'cm', () {
                      setState(() {
                        if (_heightUnit == 'ft') {
                          _height = _height * 30.48; // Convert ft to cm
                        }
                        _heightUnit = 'cm';
                      });
                    }),
                    SizedBox(width: 16),
                    _buildUnitButton('ft', _heightUnit == 'ft', () {
                      setState(() {
                        if (_heightUnit == 'cm') {
                          _height = _height / 30.48; // Convert cm to ft
                        }
                        _heightUnit = 'ft';
                      });
                    }),
                  ],
                ),
                SizedBox(height: 32),
                Slider(
                  value: _heightUnit == 'cm' ? _height : _height,
                  min: _heightUnit == 'cm' ? 120 : 4,
                  max: _heightUnit == 'cm' ? 220 : 7.5,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                  onChanged: (value) {
                    setState(() {
                      _height = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SEX PAGE
  Widget _buildSexPage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "What's your sex?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          _buildSexOption('Male', Icons.male),
          SizedBox(height: 16),
          _buildSexOption('Female', Icons.female),
          SizedBox(height: 16),
          _buildSexOption('Other', Icons.transgender),
        ],
      ),
    );
  }

  Widget _buildSexOption(String sex, IconData icon) {
    bool isSelected = _sex == sex;
    return InkWell(
      onTap: () {
        setState(() {
          _sex = sex;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Color(0xFFC16200) : Colors.white,
            ),
            SizedBox(width: 16),
            Text(
              sex,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Color(0xFFC16200) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARGET STEPS PAGE
  Widget _buildTargetStepsPage() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "What's your daily step goal?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Don't worry, you can change this later",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Text(
                  '${_targetSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'steps per day',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 32),
                Slider(
                  value: _targetSteps.toDouble(),
                  min: 5000,
                  max: 20000,
                  divisions: 30,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                  onChanged: (value) {
                    setState(() {
                      _targetSteps = (value / 500).round() * 500;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Unit toggle button
  Widget _buildUnitButton(String unit, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Color(0xFFC16200) : Colors.white,
          ),
        ),
      ),
    );
  }
}