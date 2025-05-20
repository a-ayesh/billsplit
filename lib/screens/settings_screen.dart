import 'package:flutter/material.dart';
import 'package:splitwise/providers/theme_provider.dart';
import 'package:splitwise/providers/currency_provider.dart';
import 'package:splitwise/models/currency.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ThemeNotifier().themeMode == ThemeMode.dark,
              onChanged: (value) {
                ThemeNotifier().setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Currency'),
            trailing: DropdownButton<Currency>(
              value: CurrencyNotifier().currency,
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.code),
                );
              }).toList(),
              onChanged: (currency) {
                if (currency != null) {
                  CurrencyNotifier().setCurrency(currency);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 