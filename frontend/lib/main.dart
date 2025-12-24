import 'package:flutter/material.dart';

// Import app theme
import 'utils/app_theme.dart';

// Import all screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/home/main_navigation.dart';

// This is the entry point of the app
void main() {
  runApp(WellStrideApp());
}

class WellStrideApp extends StatefulWidget {
  @override
  _WellStrideAppState createState() => _WellStrideAppState();
}

class _WellStrideAppState extends State<WellStrideApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void updateTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'WellStride',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/assessment': (context) => AssessmentScreen(),
        '/home': (context) => MainNavigation(onThemeChanged: updateTheme),
      },
    );
  }
}
