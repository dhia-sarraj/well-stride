import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wellstride/services/api_service.dart';

class AssessmentScreen extends StatefulWidget {
  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final ApiService _apiService = ApiService();

  int _currentPage = 0;
  final int _totalPages = 6;
  bool _isLoading = false;

  String _username = '';
  int _age = 25;

  /// Always stored in KG
  double _weightKg = 70.0;
  String _weightUnit = 'kg';

  /// Always stored in CM
  double _heightCm = 170.0;
  String _heightUnit = 'cm';

  String _sex = 'Male';
  int _targetSteps = 10000;

  @override
  void initState() {
    super.initState();
    _weightController.text = _weightKg.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndContinue();
    }
  }

  void _previousPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveAndContinue() async {
    if (_username.trim().isEmpty) {
      _showError("Username cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.createProfile(
        username: _username.trim(),
        age: _age,
        gender: _sex, // MUST be "Male" or "Female"
        height: _heightCm,
        weight: _weightKg,
      );

      await _apiService.updateStepGoal(_targetSteps);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC16200),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC16200),
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousPage,
        )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _progressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _usernamePage(),
                  _agePage(),
                  _weightPage(),
                  _heightPage(),
                  _sexPage(),
                  _stepsPage(),
                ],
              ),
            ),
            _nextButton(),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.white30,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_currentPage + 1}/$_totalPages',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFC16200),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
          _currentPage == _totalPages - 1
              ? 'Get Started'
              : 'Next',
        ),
      ),
    );
  }

  /// ---------- PAGES ----------

  Widget _usernamePage() => _pageWrapper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("What should we call you?"),
        TextField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Username'),
          onChanged: (v) => _username = v,
        ),
      ],
    ),
  );

  Widget _agePage() => _pageWrapper(
    Column(
      children: [
        _title("How old are you?"),
        SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 50,
            scrollController:
            FixedExtentScrollController(initialItem: _age - 13),
            onSelectedItemChanged: (i) => _age = i + 13,
            children: List.generate(
              88,
                  (i) => Center(
                child: Text(
                  '${i + 13}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 32),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _weightPage() => _pageWrapper(
    Column(
      children: [
        _title("What's your weight?"),
        TextField(
          controller: _weightController,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (v) {
            final value = double.tryParse(v);
            if (value != null) {
              _weightKg =
              _weightUnit == 'kg' ? value : value * 0.453592;
            }
          },
        ),
        _unitToggle(
          current: _weightUnit,
          options: const ['kg', 'lbs'],
          onSelect: (u) {
            if (_weightUnit != u) {
              if (u == 'lbs') {
                _weightController.text =
                    (_weightKg * 2.20462).toStringAsFixed(1);
              } else {
                _weightController.text =
                    _weightKg.toStringAsFixed(1);
              }
              _weightUnit = u;
              setState(() {});
            }
          },
        ),
      ],
    ),
  );

  Widget _heightPage() => _pageWrapper(
    Column(
      children: [
        _title("What's your height?"),
        Text(
          _heightUnit == 'cm'
              ? _heightCm.toStringAsFixed(0)
              : (_heightCm / 30.48).toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        Text(_heightUnit,
            style: const TextStyle(color: Colors.white70)),
        _unitToggle(
          current: _heightUnit,
          options: const ['cm', 'ft'],
          onSelect: (u) => setState(() => _heightUnit = u),
        ),
        Slider(
          value: _heightUnit == 'cm'
              ? _heightCm
              : _heightCm / 30.48,
          min: _heightUnit == 'cm' ? 120 : 4,
          max: _heightUnit == 'cm' ? 220 : 7.5,
          onChanged: (v) => setState(() {
            _heightCm = _heightUnit == 'cm' ? v : v * 30.48;
          }),
          activeColor: Colors.white,
          inactiveColor: Colors.white30,
        ),
      ],
    ),
  );

  Widget _sexPage() => _pageWrapper(
    Column(
      children: [
        _title("What's your sex?"),
        _sexOption('Male', Icons.male),
        const SizedBox(height: 16),
        _sexOption('Female', Icons.female),
      ],
    ),
  );

  Widget _stepsPage() => _pageWrapper(
    Column(
      children: [
        _title("Daily step goal"),
        Text(
          '$_targetSteps',
          style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        Slider(
          value: _targetSteps.toDouble(),
          min: 5000,
          max: 20000,
          divisions: 30,
          onChanged: (v) =>
              setState(() => _targetSteps = v.round()),
          activeColor: Colors.white,
          inactiveColor: Colors.white30,
        ),
      ],
    ),
  );

  /// ---------- HELPERS ----------

  Widget _pageWrapper(Widget child) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: child,
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Text(
      text,
      style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    ),
  );

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.white24,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _unitToggle({
    required String current,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((u) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(u),
            selected: current == u,
            onSelected: (_) => onSelect(u),
          ),
        );
      }).toList(),
    );
  }

  Widget _sexOption(String value, IconData icon) => GestureDetector(
    onTap: () => setState(() => _sex = value),
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _sex == value ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: _sex == value
                  ? const Color(0xFFC16200)
                  : Colors.white),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              color: _sex == value
                  ? const Color(0xFFC16200)
                  : Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}
