// Friends Tab
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/utils/currency_formatter.dart';

class FriendsTab extends StatefulWidget {
  final String userId;

  const FriendsTab({super.key, required this.userId});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  late Future<Map<String, dynamic>> _balancesFuture;
  late Future<List<Map<String, dynamic>>> _friendsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
    _friendsFuture = DatabaseService().getFriends(widget.userId);
  }

  Future<void> _searchAndAddFriend(String email) async {
    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      final user = await DatabaseService().getUserByEmail(email);

      if (user == null) {
        setState(() {
          _searchError = 'No user found with this email';
        });
        return;
      }

      if (user['id'] == widget.userId) {
        setState(() {
          _searchError = 'You cannot add yourself as a friend';
        });
        return;
      }

      await DatabaseService().addFriend(widget.userId, user['id']);

      setState(() {
        _searchController.clear();
        _loadData();
      });
    } catch (e) {
      setState(() {
        _searchError = 'An error occurred while adding friend';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<bool?> _removeFriend(Map<String, dynamic> friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
            'Are you sure you want to remove ${friend['name']} from your friends?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().removeFriend(widget.userId, friend['id']);
      setState(() {
        _loadData();
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by email',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchAndAddFriend(_searchController.text.trim());
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchAndAddFriend(value.trim());
            }
          },
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
            final userBalances = Map<String, Map<String, dynamic>>.fromEntries(
                (balances['userBalances'] as List)
                    .map((b) => MapEntry(b['userId'], b)));

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _friendsFuture,
              builder: (context, friendsSnapshot) {
                if (friendsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final friends = friendsSnapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_searchError.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _searchError,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),

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

                    if (friends.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No friends yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search for friends by their email address',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...friends.map((friend) {
                        final balance = userBalances[friend['id']];
                        final isOwed = balance?['type'] == 'owed';
                        final isSettled = balance?['type'] == 'settled';
                        final amount = balance?['amount'] ?? 0.0;

                        return Dismissible(
                          key: Key(friend['id']),
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
                          confirmDismiss: (_) => _removeFriend(friend),
                          child: ListTile(
                            leading: _buildFriendAvatar(friend),
                            title: Text(
                              friend['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(friend['email']),
                            trailing: isSettled
                                ? const Text('settled up')
                                : Text(
                                    isOwed
                                        ? 'owes you ${formatCurrency(amount)}'
                                        : 'you owe ${formatCurrency(amount)}',
                                    style: TextStyle(
                                      color: isOwed
                                          ? const Color(0xFF1CC29F)
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            onTap: () {
                              // Navigate to friend details
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFriendAvatar(Map<String, dynamic> friend) {
    return FutureBuilder<dynamic>(
      future: DatabaseService().getProfileImage(
        friend['id'],
        friend['profilePicture'],
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (kIsWeb) {
            return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.memory(
                  base64Decode(snapshot.data as String),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.file(
                  snapshot.data as File,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        }
        return CircleAvatar(
          backgroundColor: Colors
              .primaries[friend['name'].hashCode % Colors.primaries.length],
          child: Text(
            friend['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
