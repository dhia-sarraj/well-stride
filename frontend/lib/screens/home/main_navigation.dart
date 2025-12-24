import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'fitness_screen.dart';
import 'mental_screen.dart';
import 'analysis_screen.dart';

class MainNavigation extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;

  const MainNavigation({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}


class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Start at index 1 (Home screen)

  final List<Widget> _screens = [
    FitnessScreen(),
    HomeScreen(),
    MentalScreen(),
    AnalysisScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mental',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
        ],
      ),
    );
  }
}