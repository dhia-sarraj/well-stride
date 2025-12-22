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

// Main app widget
class WellStrideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App name (appears in task switcher)
      title: 'WellStride',

      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Starting screen when app opens
      initialRoute: '/',

      // All app routes (navigation paths)
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/assessment': (context) => AssessmentScreen(),
        '/home': (context) => MainNavigation(),
      },
    );
  }
}