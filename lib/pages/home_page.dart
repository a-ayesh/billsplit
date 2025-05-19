// Home Page with Bottom Navigation
import 'package:flutter/material.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/pages/add_expense_page.dart';
import 'package:splitwise/pages/welcome_page.dart';
import 'package:splitwise/services/auth_services.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/tabs/account_tab.dart';
import 'package:splitwise/tabs/activity_tab.dart';
import 'package:splitwise/tabs/add_expense_tab.dart';
import 'package:splitwise/tabs/friends_tab.dart';
import 'package:splitwise/tabs/groups_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<Map<String, dynamic>> _balancesFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userFuture = AuthService().getCurrentUser();
    final user = await _userFuture;
    if (user != null) {
      _balancesFuture = DatabaseService().calculateBalances(user['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load user data'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data!;
        final List<Widget> pages = [
          FriendsTab(userId: user['id']),
          GroupsTab(userId: user['id']),
          AddExpenseTab(userId: user['id']),
          ActivityTab(userId: user['id']),
          AccountTab(user: user),
        ];

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
