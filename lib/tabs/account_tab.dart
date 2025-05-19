// Account Tab
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitwise/currency.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/notifiers/currency_notifier.dart';
import 'package:splitwise/notifiers/theme_notifier.dart';
import 'package:splitwise/pages/edit_profile_page.dart';
import 'package:splitwise/pages/welcome_page.dart';
import 'package:splitwise/services/auth_services.dart';
import 'package:splitwise/services/databse_service.dart';

class AccountTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const AccountTab({super.key, required this.user});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool _notificationsEnabled = true;
  dynamic _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _showCurrencyPicker() async {
    final Currency? result = await showDialog<Currency>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: ListenableBuilder(
            listenable: CurrencyNotifier(),
            builder: (context, _) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currency = currencies[index];
                    return ListTile(
                      leading: Text(currency.symbol),
                      title: Text(currency.name),
                      subtitle: Text(currency.code),
                      selected:
                          currency.code == CurrencyNotifier().currency.code,
                      onTap: () {
                        Navigator.of(context).pop(currency);
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      await CurrencyNotifier().setCurrency(result);
    }
  }

  Future<void> _loadProfileImage() async {
    final image = await DatabaseService().getProfileImage(
      widget.user['id'],
      widget.user['profilePicture'],
    );
    if (mounted) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage == null) {
      return Text(
        widget.user['name'].substring(0, 1).toUpperCase(),
        style: const TextStyle(color: Colors.white),
      );
    }

    if (kIsWeb) {
      return ClipOval(
        child: Image.memory(
          base64Decode(_profileImage),
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        _profileImage,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListenableBuilder(
        listenable: ThemeNotifier(),
        builder: (context, child) {
          final isDark = ThemeNotifier().themeMode == ThemeMode.dark;
          return ListView(
            children: [
              // Profile Section
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade700,
                  child: _buildProfileImage(),
                ),
                title: Text(
                  widget.user['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.user['email']),
                trailing: const Icon(Icons.camera_alt),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: widget.user),
                    ),
                  );
                },
              ),
              const Divider(),

              // Settings Section
              ExpansionTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                children: [
                  // Currency
                  ListenableBuilder(
                    listenable: CurrencyNotifier(),
                    builder: (context, _) {
                      final currency = CurrencyNotifier().currency;
                      return ListTile(
                        leading: const Icon(Icons.currency_exchange),
                        title: const Text('Currency'),
                        subtitle: Text('${currency.code} - ${currency.name}'),
                        trailing: Text(
                          currency.symbol,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: _showCurrencyPicker,
                      );
                    },
                  ),
                  // Theme
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                        isDark ? 'Dark theme enabled' : 'Light theme enabled'),
                    value: isDark,
                    onChanged: (value) {
                      ThemeNotifier().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),

              // Preferences Section
              ExpansionTile(
                leading: const Icon(Icons.tune),
                title: const Text('Preferences'),
                children: [
                  // Notifications
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  // Default Split
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Default Split'),
                    subtitle: const Text('Equal split'),
                    onTap: () {
                      // Default split settings
                    },
                  ),
                  // Categories
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    subtitle: const Text('Manage expense categories'),
                    onTap: () {
                      // Categories settings
                    },
                  ),
                ],
              ),

              // Security Section
              ExpansionTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                children: [
                  // Change Password
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {
                      // Change password
                    },
                  ),
                  // Reset Password
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Reset Password'),
                    onTap: () {
                      // Reset password
                    },
                  ),
                  // Privacy Settings
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Settings'),
                    onTap: () {
                      // Privacy settings
                    },
                  ),
                  // Login Activity
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Login Activity'),
                    onTap: () {
                      // Login activity
                    },
                  ),
                ],
              ),

              // Help & Support Section
              ExpansionTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                children: [
                  // Contact Us
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Contact Us'),
                    subtitle: const Text('ask@billsplitter.com'),
                    onTap: () {
                      // Launch email client
                    },
                  ),
                  // FAQs
                  ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: const Text('FAQs'),
                    onTap: () {
                      // Show FAQs
                    },
                  ),
                  // Terms & Conditions
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms & Conditions'),
                    onTap: () {
                      // Show terms
                    },
                  ),
                  // Privacy Policy
                  ListTile(
                    leading: const Icon(Icons.policy),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      // Show privacy policy
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
