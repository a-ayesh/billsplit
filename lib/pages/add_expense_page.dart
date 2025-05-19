// Add Expense Tab
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:uuid/uuid.dart';

// Add Expense Page
class AddExpensePage extends StatefulWidget {
  final String groupId;
  final String userId;
  final bool isTemporaryGroup;
  final Map<String, dynamic>? tempGroup;

  const AddExpensePage({
    super.key,
    required this.groupId,
    required this.userId,
    this.isTemporaryGroup = false,
    this.tempGroup,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'other';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _members = [];
  final Map<String, double> _splitAmounts = {};
  String _splitMethod = 'equal';

  @override
  void initState() {
    super.initState();
    _loadGroupMembers();
  }

  Future<void> _loadGroupMembers() async {
    if (widget.isTemporaryGroup && widget.tempGroup != null) {
      setState(() {
        _members =
            List<Map<String, dynamic>>.from(widget.tempGroup!['members']);

        // Initialize split amounts
        const equalAmount = 0.0; // Will be calculated when amount is entered
        for (var member in _members) {
          _splitAmounts[member['id']] = equalAmount;
        }
      });
    } else {
      final group = await DatabaseService().getGroupById(widget.groupId);
      if (group != null) {
        setState(() {
          _members = List<Map<String, dynamic>>.from(group['members']);

          // Initialize split amounts
          const equalAmount = 0.0; // Will be calculated when amount is entered
          for (var member in _members) {
            _splitAmounts[member['id']] = equalAmount;
          }
        });
      }
    }
  }

  void _updateSplitAmounts() {
    if (_amountController.text.isEmpty) return;

    final totalAmount = double.tryParse(_amountController.text) ?? 0;

    if (_splitMethod == 'equal') {
      final perPersonAmount = totalAmount / _members.length;
      for (var member in _members) {
        _splitAmounts[member['id']] = perPersonAmount;
      }
    }
    // Other split methods would be implemented here

    setState(() {});
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Prepare split data
    final splitWith = _members.map((member) {
      return {
        'userId': member['id'],
        'amount': _splitAmounts[member['id']] ?? 0.0,
      };
    }).toList();

    // Create expense object
    final expense = {
      'id': const Uuid().v4(),
      'groupId': widget.groupId,
      'description': description,
      'amount': amount,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
      'paidBy': widget.userId,
      'splitWith': splitWith,
      'receiptUrl': null, // Would store image URL in a real app
      'notes': '',
      'createdAt': DateTime.now().toIso8601String(),
      'isIndividualExpense': widget.isTemporaryGroup,
    };

    // Save to database
    await DatabaseService().addExpense(expense);

    // Create activity record
    final activity = {
      'id': const Uuid().v4(),
      'type': 'expense_added',
      'userId': widget.userId,
      'groupId': widget.groupId,
      'expenseId': expense['id'],
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await DatabaseService().addActivity(activity);

    // Update balances
    if (!widget.isTemporaryGroup) {
      // Update group balances only for real groups
      final group = await DatabaseService().getGroupById(widget.groupId);
      if (group != null) {
        final members = List<Map<String, dynamic>>.from(group['members']);

        for (var i = 0; i < members.length; i++) {
          final member = members[i];
          final split = splitWith.firstWhere(
            (s) => s['userId'] == member['id'],
            orElse: () => {'amount': 0.0},
          );

          if (member['id'] == widget.userId) {
            // Current user paid
            member['balance'] =
                (member['balance'] ?? 0.0) + (amount - split['amount']);
          } else {
            // Other members
            member['balance'] = (member['balance'] ?? 0.0) - split['amount'];
          }
        }

        final updatedGroup = {
          ...group,
          'members': members,
        };

        await DatabaseService().updateGroup(updatedGroup);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner, Groceries, Rent',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'PKR ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (_) => _updateSplitAmounts(),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: [
                DropdownMenuItem(
                  value: 'food',
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text('Food & Drink'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'transport',
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text('Transportation'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'accommodation',
                  child: Row(
                    children: [
                      Icon(Icons.hotel, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      const Text('Accommodation'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'entertainment',
                  child: Row(
                    children: [
                      Icon(Icons.movie, color: Colors.pink.shade700),
                      const SizedBox(width: 8),
                      const Text('Entertainment'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'shopping',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.teal.shade700),
                      const SizedBox(width: 8),
                      const Text('Shopping'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'utilities',
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text('Utilities'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      const Text('Other'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            const Divider(),

            // Split method
            const Text(
              'SPLIT DETAILS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _splitMethod,
              decoration: const InputDecoration(
                labelText: 'Split method',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'equal',
                  child: Text('Split equally'),
                ),
                DropdownMenuItem(
                  value: 'exact',
                  child: Text('Split by exact amounts'),
                ),
                DropdownMenuItem(
                  value: 'percent',
                  child: Text('Split by percentages'),
                ),
                DropdownMenuItem(
                  value: 'shares',
                  child: Text('Split by shares'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _splitMethod = value;
                    _updateSplitAmounts();
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Members list
            ..._members.map((member) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: DatabaseService().getUserById(member['id']),
                builder: (context, snapshot) {
                  final userName = snapshot.data?['name'] ?? 'Unknown';
                  final isCurrentUser = member['id'] == widget.userId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.primaries[
                          userName.hashCode % Colors.primaries.length],
                      child: Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      isCurrentUser ? 'You' : userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'PKR ${(_splitAmounts[member['id']] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
  }
}
