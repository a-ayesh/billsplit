import 'package:flutter/material.dart';
import 'package:splitwise/providers/theme_provider.dart';
import 'package:splitwise/providers/currency_provider.dart';
import 'package:splitwise/screens/add_expense_screen.dart';
import 'package:splitwise/screens/settings_screen.dart';
import 'package:splitwise/widgets/expense_list.dart';
import 'package:splitwise/widgets/balance_summary.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splitwise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const BalanceSummary(),
          const Expanded(child: ExpenseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 