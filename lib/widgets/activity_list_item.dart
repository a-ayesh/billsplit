// Activity List Item
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';

class ActivityListItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final String userId;

  const ActivityListItem({
    super.key,
    required this.activity,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(activity['timestamp']);
    final formattedDate =
        DateFormat('MMM d, yyyy \'at\' h:mm a').format(timestamp);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
          );
        }

        final userData = userSnapshot.data;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getRelatedData(),
          builder: (context, relatedSnapshot) {
            final relatedData = relatedSnapshot.data;

            return ListTile(
              leading: _buildLeadingIcon(),
              title: _buildTitle(context, userData, relatedData),
              subtitle: Text(formattedDate),
              onTap: () {
                // Show activity details
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    if (activity['userId'] != null) {
      return DatabaseService().getUserById(activity['userId']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getRelatedData() async {
    if (activity['type'] == 'expense_added' ||
        activity['type'] == 'expense_updated') {
      if (activity['groupId'] != null) {
        return DatabaseService().getGroupById(activity['groupId']);
      }
    } else if (activity['type'] == 'payment_recorded' ||
        activity['type'] == 'payment_received') {
      if (activity['relatedUserId'] != null) {
        return DatabaseService().getUserById(activity['relatedUserId']);
      }
    }
    return null;
  }

  Widget _buildLeadingIcon() {
    switch (activity['type']) {
      case 'expense_added':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt, color: Colors.green),
        );
      case 'payment_recorded':
      case 'payment_received':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.payments, color: Colors.blue),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.info, color: Colors.grey),
        );
    }
  }

  Widget _buildTitle(BuildContext context, Map<String, dynamic>? userData,
      Map<String, dynamic>? relatedData) {
    final isCurrentUser = activity['userId'] == userId;
    final userName = userData?['name'] ?? 'Unknown';
    final colorStyle = Theme.of(context).textTheme.bodyMedium;

    switch (activity['type']) {
      case 'expense_added':
        final groupName = relatedData?['name'] ?? 'a group';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' added '),
              TextSpan(
                text: activity['description'] ?? 'an expense',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' in '),
              TextSpan(
                text: groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      case 'payment_recorded':
        final relatedUserName = relatedData?['name'] ?? 'someone';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' recorded a payment from '),
              TextSpan(
                text: relatedUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      case 'payment_received':
        final relatedUserName = relatedData?['name'] ?? 'someone';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' paid '),
              TextSpan(
                text: relatedUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      default:
        return Text(
          isCurrentUser
              ? 'You performed an action'
              : '$userName performed an action',
        );
    }
  }
}

