import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitwise/app.dart';
import 'package:splitwise/notifiers/currency_notifier.dart';
import 'package:splitwise/notifiers/theme_notifier.dart';
import 'package:splitwise/pages/splash_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:splitwise/currency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeNotifier().loadThemeMode();
  await CurrencyNotifier().loadCurrency();
  runApp(const SplitWiseApp());
}
