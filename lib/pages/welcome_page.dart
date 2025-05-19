// Welcome Page
import 'package:flutter/material.dart';
import 'package:splitwise/custom_clippers/diagonal_clipper.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/login_page.dart';
import 'package:splitwise/pages/sign_up_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      ClipPath(
                        clipper: DiagonalClipper(part: 1),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFF1CC29F),
                        ),
                      ),
                      ClipPath(
                        clipper: DiagonalClipper(part: 2),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Positioned(
                        left: 30,
                        top: 40,
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Splitwise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                // Sign up button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: 16),
                // Log in button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                  ),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: 24),
                // Terms and privacy
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Terms'),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Privacy Policy'),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Contact us'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
