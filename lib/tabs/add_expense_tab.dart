import 'package:flutter/material.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/add_expense_page.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:uuid/uuid.dart';

class AddExpenseTab extends StatelessWidget {
  final String userId;

  const AddExpenseTab({super.key, required this.userId});

  void _showExpenseTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add an expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1CC29F)),
              title: const Text('With a friend'),
              subtitle: const Text('Split expenses with one person'),
              onTap: () {
                Navigator.pop(context);
                _showFriendSelectionDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF1CC29F)),
              title: const Text('In a group'),
              subtitle: const Text('Split expenses with multiple people'),
              onTap: () {
                Navigator.pop(context);
                _showGroupSelectionDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select friend'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().getFriends(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final friends = snapshot.data ?? [];

            if (friends.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No friends yet'),
                  SizedBox(height: 8),
                  Text(
                    'Add friends first to split expenses',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.primaries[
                          friend['name'].hashCode % Colors.primaries.length],
                      child: Text(
                        friend['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend['name'].toString()),
                    subtitle: Text(friend['email'].toString()),
                    onTap: () {
                      Navigator.pop(context);
                      // Create a temporary group for this friend
                      final tempGroup = {
                        'id': const Uuid().v4(),
                        'name': 'Individual expense',
                        'members': [
                          {'id': userId, 'balance': 0.0},
                          {'id': friend['id'].toString(), 'balance': 0.0},
                        ],
                      };
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExpensePage(
                            groupId: tempGroup['id'].toString(),
                            userId: userId,
                            isTemporaryGroup: true,
                            tempGroup: tempGroup,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showGroupSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select group'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().getGroupsByUserId(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No groups yet'),
                  SizedBox(height: 8),
                  Text(
                    'Create a group first to split expenses',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.primaries[
                            group['name'].toString().hashCode %
                                Colors.primaries.length],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          group['name']
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(group['name'].toString()),
                    subtitle:
                        Text('${(group['members'] as List).length} members'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExpensePage(
                            groupId: group['id'].toString(),
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add expenses'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Add a new expense',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Split expenses with friends or groups',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showExpenseTypeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add an expense'),
            ),
          ],
        ),
      ),
    );
  }
}

