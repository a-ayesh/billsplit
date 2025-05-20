import 'package:flutter/material.dart';
import 'package:splitwise/providers/expense_provider.dart';
import 'package:splitwise/utils/currency_formatter.dart';

class BalanceSummary extends StatelessWidget {
  const BalanceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExpenseNotifier(),
      builder: (context, child) {
        final expenses = ExpenseNotifier().expenses;
        final balances = <String, double>{};

        for (final expense in expenses) {
          final amountPerPerson = expense.amount / expense.splitBetween.length;
          
          // Add to paid by person
          balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;
          
          // Subtract from split between people
          for (final person in expense.splitBetween) {
            balances[person] = (balances[person] ?? 0) - amountPerPerson;
          }
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balances',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...balances.entries.map((entry) {
                  final amount = entry.value;
                  final color = amount > 0 ? Colors.green : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          formatCurrency(amount),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
} 