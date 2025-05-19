// Theme Notifier
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;


import 'package:splitwise/currency.dart';

class ThemeNotifier extends ChangeNotifier 
{
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    if (kIsWeb) {
      html.window.localStorage['themeMode'] =
          mode == ThemeMode.dark ? 'dark' : 'light';
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    }
  }

  Future<void> loadThemeMode() async {
    if (kIsWeb) {
      final storage = html.window.localStorage;
      if (storage.containsKey('themeMode')) {
        _themeMode =
            storage['themeMode'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode');
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    }
    notifyListeners();
  }
}
