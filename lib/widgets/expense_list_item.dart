
// Expense List Item
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/utils/currency_formatter.dart';

class ExpenseListItem extends StatelessWidget {
  final Map<String, dynamic> expense;
  final String userId;
  final Function()? onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.userId,
    this.onDelete,
  });

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
            'Are you sure you want to delete this expense? This will update all balances and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed == true) {
      await DatabaseService().deleteExpense(expense['id']);
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserPayer = expense['paidBy'] == userId;
    final date = DateTime.parse(expense['date']);
    final formattedDate = DateFormat('MMM d, yyyy').format(date);

    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseService().getUserById(expense['paidBy']),
      builder: (context, snapshot) {
        final payerName = snapshot.data?['name'] ?? 'Unknown';

        return Dismissible(
          key: Key(expense['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (_) async {
            final confirmed = await _confirmDelete(context);
            if (confirmed == true) {
              await DatabaseService().deleteExpense(expense['id']);
              onDelete?.call();
              return true;
            }
            return false;
          },
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense['category']),
                color: _getCategoryColor(expense['category']),
              ),
            ),
            title: Text(
              expense['description'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$formattedDate • ${isUserPayer ? 'You paid' : '$payerName paid'} PKR ${expense['amount'].toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrailingWidget(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _handleDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete expense',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Show expense details
            },
          ),
        );
      },
    );
  }

  Widget _buildTrailingWidget() {
    final splitWith = List<Map<String, dynamic>>.from(expense['splitWith']);
    final userSplit = splitWith.firstWhere(
      (split) => split['userId'] == userId,
      orElse: () => {'amount': 0.0},
    );

    final isUserPayer = expense['paidBy'] == userId;
    final userAmount = userSplit['amount'] ?? 0.0;

    if (isUserPayer) {
      final totalLent = expense['amount'] - userAmount;
      if (totalLent <= 0) return const Text('you paid');

      return Text(
        'you lent\n${formatCurrency(totalLent)}',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFF1CC29F),
        ),
      );
    } else {
      return Text(
        'you borrowed\nPKR ${userAmount.toStringAsFixed(2)}',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.orange,
        ),
      );
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'utilities':
        return Icons.lightbulb;
      case 'other':
        return Icons.category;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'accommodation':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'shopping':
        return Colors.teal;
      case 'utilities':
        return Colors.amber;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

