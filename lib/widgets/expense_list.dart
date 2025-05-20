import 'package:flutter/material.dart';
import 'package:splitwise/providers/expense_provider.dart';
import 'package:splitwise/utils/currency_formatter.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExpenseNotifier(),
      builder: (context, child) {
        final expenses = ExpenseNotifier().expenses;
        
        if (expenses.isEmpty) {
          return const Center(
            child: Text('No expenses yet'),
          );
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Dismissible(
              key: Key(expense.date.toIso8601String()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                ExpenseNotifier().removeExpense(expense);
              },
              child: Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(expense.description),
                  subtitle: Text(
                    'Paid by ${expense.paidBy} • ${expense.date.toString().split('.')[0]}',
                  ),
                  trailing: Text(
                    formatCurrency(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 