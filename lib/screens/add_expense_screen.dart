import 'package:flutter/material.dart';
import 'package:splitwise/providers/expense_provider.dart';
import 'package:splitwise/utils/currency_formatter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidByController = TextEditingController();
  final _splitBetweenController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _paidByController.dispose();
    _splitBetweenController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        paidBy: _paidByController.text,
        splitBetween: _splitBetweenController.text.split(',').map((e) => e.trim()).toList(),
        date: DateTime.now(),
      );

      ExpenseNotifier().addExpense(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What was the expense for?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'How much was it?',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paidByController,
              decoration: const InputDecoration(
                labelText: 'Paid by',
                hintText: 'Who paid for this?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter who paid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _splitBetweenController,
              decoration: const InputDecoration(
                labelText: 'Split between',
                hintText: 'Who is splitting this? (comma separated)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter who is splitting';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
} 