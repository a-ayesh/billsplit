import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/currency.dart';

class CurrencyNotifier extends ChangeNotifier {
  static final CurrencyNotifier _instance = CurrencyNotifier._internal();
  factory CurrencyNotifier() => _instance;
  CurrencyNotifier._internal();

  Currency _currency = currencies[0];
  Currency get currency => _currency;

  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    notifyListeners();

    if (kIsWeb) {
      html.window.localStorage['currency'] = currency.code;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency.code);
    }
  }

  Future<void> loadCurrency() async {
    if (kIsWeb) {
      final storage = html.window.localStorage;
      final currencyCode = storage['currency'] ?? 'PKR';
      _currency = currencies.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => currencies[0],
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString('currency') ?? 'PKR';
      _currency = currencies.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => currencies[0],
      );
    }
    notifyListeners();
  }
} 