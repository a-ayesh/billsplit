import 'package:flutter/material.dart';
import 'package:splitwise/notifiers/theme_notifier.dart';
import 'package:splitwise/pages/splash_screen.dart';

class SplitWiseApp extends StatelessWidget {
  const SplitWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Splitwise',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF1CC29F),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1CC29F),
              primary: const Color(0xFF1CC29F),
              secondary: const Color(0xFF8A2BE2),
              background: Colors.white,
            ),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CC29F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1CC29F),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1CC29F), width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primaryTextTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            primaryColor: const Color(0xFF1CC29F),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF1CC29F),
              primary: const Color(0xFF1CC29F),
              secondary: const Color(0xFF8A2BE2),
              background: const Color(0xFF121212),
            ),
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CC29F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1CC29F),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1CC29F), width: 2),
              ),
            ),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white24,
          ),
          themeMode: ThemeNotifier().themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}




