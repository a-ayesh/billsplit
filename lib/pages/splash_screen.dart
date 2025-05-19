// Splash Screen
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/home_page.dart';
import 'package:splitwise/pages/welcome_page.dart';
import 'package:splitwise/services/auth_services.dart';
import 'package:splitwise/services/databse_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static final _log = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    _log.info('Starting initialization...');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _log.info('Initializing database...');
      await DatabaseService().initializeDatabase();
      _log.info('Database initialized');

      _log.info('Checking login status...');
      final isLoggedIn = await AuthService().isLoggedIn();
      _log.info('Login status checked: $isLoggedIn');

      if (mounted) {
        _log.info('Navigating to next screen...');
        if (isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
        }
        _log.info('Navigation completed');
      }
    } catch (e) {
      _log.severe('Error during initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.info('Building splash screen');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text(
              'Splitwise',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFF1CC29F),
            ),
          ],
        ),
      ),
    );
  }
}
