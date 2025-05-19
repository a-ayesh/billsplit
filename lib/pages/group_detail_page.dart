// Group Detail Page
import 'package:flutter/material.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/add_expense_page.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/widgets/expense_list_item.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String userId;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.userId,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late Future<Map<String, dynamic>?> _groupFuture;
  late Future<List<Map<String, dynamic>>> _expensesFuture;
  late Future<List<Map<String, dynamic>>> _simplifiedDebtsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _groupFuture = DatabaseService().getGroupById(widget.groupId);
    _expensesFuture = DatabaseService().getExpensesByGroupId(widget.groupId);
    _simplifiedDebtsFuture = DatabaseService().simplifyDebts(widget.groupId);
  }

  Future<bool?> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
            'Are you sure you want to delete this group? This will delete all associated expenses and cannot be undone.'),
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

    if (confirmed == true) {
      await DatabaseService().deleteGroup(widget.groupId);
      if (mounted) {
        Navigator.of(context).pop();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Text('Group');
            }
            return Text(snapshot.data!['name']);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await _deleteGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete group', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _groupFuture,
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupSnapshot.hasError || groupSnapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load group data'),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final group = groupSnapshot.data!;
          final members = List<Map<String, dynamic>>.from(group['members']);

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _expensesFuture,
            builder: (context, expensesSnapshot) {
              if (expensesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenses = expensesSnapshot.data ?? [];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _simplifiedDebtsFuture,
                builder: (context, debtsSnapshot) {
                  final simplifiedDebts = debtsSnapshot.data ?? [];

                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'EXPENSES'),
                            Tab(text: 'BALANCES'),
                          ],
                          labelColor: Color(0xFF1CC29F),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF1CC29F),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Expenses tab
                              expenses.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.receipt_long,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No expenses yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Add your first expense to get started',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddExpensePage(
                                                        groupId: widget.groupId,
                                                        userId: widget.userId,
                                                      ),
                                                    ),
                                                  )
                                                  .then((_) => setState(
                                                      () => _loadData()));
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add an expense'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: expenses.length,
                                      itemBuilder: (context, index) {
                                        final expense = expenses[index];
                                        return ExpenseListItem(
                                          expense: expense,
                                          userId: widget.userId,
                                          onDelete: () =>
                                              setState(() => _loadData()),
                                        );
                                      },
                                    ),

                              // Balances tab
                              ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  // Simplified debts
                                  if (simplifiedDebts.isNotEmpty) ...[
                                    const Text(
                                      'SIMPLIFIED BALANCES',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...simplifiedDebts.map((debt) {
                                      final isUserInvolved =
                                          debt['from']['id'] == widget.userId ||
                                              debt['to']['id'] == widget.userId;

                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              debt['from']['name'],
                                              style: TextStyle(
                                                fontWeight: isUserInvolved
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_right_alt),
                                            Text(
                                              debt['to']['name'],
                                              style: TextStyle(
                                                fontWeight: isUserInvolved
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          'PKR ${debt['amount'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: isUserInvolved
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            // color: isUserInvolved
                                            //     ? Colors.black
                                            //     : Colors.grey,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],

                                  const SizedBox(height: 16),

                                  // Individual balances
                                  const Text(
                                    'INDIVIDUAL BALANCES',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...members.map((member) {
                                    final balance = member['balance'] ?? 0.0;
                                    final isCurrentUser =
                                        member['id'] == widget.userId;

                                    if (isCurrentUser)
                                      return const SizedBox.shrink();

                                    return FutureBuilder<Map<String, dynamic>?>(
                                      future: DatabaseService()
                                          .getUserById(member['id']),
                                      builder: (context, userSnapshot) {
                                        final userName =
                                            userSnapshot.data?['name'] ??
                                                'Unknown';

                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.primaries[
                                                userName.hashCode %
                                                    Colors.primaries.length],
                                            child: Text(
                                              userName
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          title: Text(userName),
                                          trailing: Text(
                                            balance == 0
                                                ? 'settled up'
                                                : balance > 0
                                                    ? 'owes you PKR ${balance.abs().toStringAsFixed(2)}'
                                                    : 'you owe PKR ${balance.abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: balance == 0
                                                  ? Colors.grey
                                                  : balance > 0
                                                      ? const Color(0xFF1CC29F)
                                                      : Colors.orange,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => AddExpensePage(
                    groupId: widget.groupId,
                    userId: widget.userId,
                  ),
                ),
              )
              .then((_) => setState(() => _loadData()));
        },
        backgroundColor: const Color(0xFF1CC29F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
