// Groups Tab
import 'package:flutter/material.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/group_detail_page.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';

class GroupsTab extends StatefulWidget {
  final String userId;

  const GroupsTab({super.key, required this.userId});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;
  late Future<Map<String, dynamic>> _balancesFuture;
  late Future<List<Map<String, dynamic>>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _groupsFuture = DatabaseService().getGroupsByUserId(widget.userId);
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
    _friendsFuture = DatabaseService().getFriends(widget.userId);
  }

  void _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final friends = await DatabaseService().getFriends(widget.userId);

    if (friends.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add some friends first before creating a group'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final selectedFriends = <String>{};

    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create a new group'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g., Trip to Murree',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select friends to add:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...friends.map((friend) => CheckboxListTile(
                        title: Text(friend['name']),
                        subtitle: Text(friend['email']),
                        value: selectedFriends.contains(friend['id']),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedFriends.add(friend['id']);
                            } else {
                              selectedFriends.remove(friend['id']);
                            }
                          });
                        },
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a group name')),
                    );
                    return;
                  }

                  if (selectedFriends.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select at least one friend')),
                    );
                    return;
                  }

                  // Create list of all members including current user
                  final members = [
                    {
                      'id': widget.userId,
                      'balance': 0.0,
                      'role': 'admin',
                    },
                    ...selectedFriends.map((friendId) => {
                          'id': friendId,
                          'balance': 0.0,
                          'role': 'member',
                        }),
                  ];

                  final newGroup = {
                    'id': const Uuid().v4(),
                    'name': name,
                    'icon': null,
                    'createdAt': DateTime.now().toIso8601String(),
                    'createdBy': widget.userId,
                    'members': members,
                    'isSettled': false,
                  };

                  await DatabaseService().addGroup(newGroup);

                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    // Use the parent widget's setState to refresh the groups list
                    setState(() {
                      _loadData();
                    });
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<bool?> _deleteGroup(Map<String, dynamic> group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
            'Are you sure you want to delete "${group['name']}"? This will delete all associated expenses and cannot be undone.'),
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
      await DatabaseService().deleteGroup(group['id']);
      setState(() {
        _loadData();
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search functionality
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _showCreateGroupDialog();
              },
              child: const Text(
                'Create group',
                style: TextStyle(
                  color: Color(0xFF1CC29F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _balancesFuture,
          builder: (context, balanceSnapshot) {
            if (balanceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (balanceSnapshot.hasError) {
              return Center(child: Text('Error: ${balanceSnapshot.error}'));
            }

            final balances = balanceSnapshot.data!;
            final netBalance = balances['netBalance'] as double;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _groupsFuture,
              builder: (context, groupsSnapshot) {
                if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (groupsSnapshot.hasError) {
                  return Center(child: Text('Error: ${groupsSnapshot.error}'));
                }

                final groups = groupsSnapshot.data!;
                final settledGroups =
                    groups.where((g) => g['isSettled'] == true).toList();
                final activeGroups =
                    groups.where((g) => g['isSettled'] != true).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overall balance
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall, you are ${netBalance >= 0 ? 'owed' : 'owe'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatCurrency(netBalance),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: netBalance >= 0
                                  ? const Color(0xFF1CC29F)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    if (groups.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Icon(
                              Icons.group_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No groups yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a group with your friends to get started',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showCreateGroupDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create a group'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Active groups
                      ...activeGroups.map((group) {
                        final groupBalance =
                            _calculateGroupBalance(group, widget.userId);
                        final isOwed = groupBalance > 0;

                        return Dismissible(
                          key: Key(group['id']),
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
                          confirmDismiss: (_) => _deleteGroup(group),
                          child: ListTile(
                            leading: group['icon'] != null
                                ? Image.asset(group['icon'],
                                    width: 40, height: 40)
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.primaries[
                                          group['name'].hashCode %
                                              Colors.primaries.length],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        group['name']
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                            title: Text(
                              group['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${(group['members'] as List).length} members',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: groupBalance == 0
                                ? const Text('settled up')
                                : Text(
                                    isOwed
                                        ? 'you are owed\n${formatCurrency(groupBalance)}'
                                        : 'you owe\n${formatCurrency(groupBalance)}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: isOwed
                                          ? const Color(0xFF1CC29F)
                                          : Colors.orange,
                                    ),
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailPage(
                                    groupId: group['id'],
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),

                      if (settledGroups.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Settled groups',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...settledGroups.map((group) => ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    group['name'].substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                group['name'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              subtitle: Text(
                                '${(group['members'] as List).length} members • Settled',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GroupDetailPage(
                                      groupId: group['id'],
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ],
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _calculateGroupBalance(Map<String, dynamic> group, String userId) {
    final members = List<Map<String, dynamic>>.from(group['members']);
    final userMember = members.firstWhere((m) => m['id'] == userId,
        orElse: () => {'balance': 0.0});
    return userMember['balance'] ?? 0.0;
  }
}
