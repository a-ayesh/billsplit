import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expense {
  final String description;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;

  Expense({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'splitBetween': splitBetween,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        description: json['description'],
        amount: json['amount'],
        paidBy: json['paidBy'],
        splitBetween: List<String>.from(json['splitBetween']),
        date: DateTime.parse(json['date']),
      );
}

class ExpenseNotifier extends ChangeNotifier {
  static final ExpenseNotifier _instance = ExpenseNotifier._internal();
  factory ExpenseNotifier() => _instance;
  ExpenseNotifier._internal();

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _saveExpenses();
  }

  Future<void> removeExpense(Expense expense) async {
    _expenses.remove(expense);
    notifyListeners();
    await _saveExpenses();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = _expenses.map((e) => e.toJson()).toList();
    await prefs.setString('expenses', jsonEncode(expensesJson));
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = jsonDecode(expensesJson);
      _expenses = decoded.map((e) => Expense.fromJson(e)).toList();
      notifyListeners();
    }
  }
} 