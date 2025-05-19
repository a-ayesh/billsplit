// Activity Tab
import 'package:flutter/material.dart';
import 'package:splitwise/charts/expense_overview_chart.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:splitwise/widgets/activity_list_item.dart';

class ActivityTab extends StatefulWidget {
  final String userId;

  const ActivityTab({super.key, required this.userId});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  late Future<List<Map<String, dynamic>>> _activitiesFuture;
  late Future<Map<String, dynamic>> _balancesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _activitiesFuture = DatabaseService().getActivitiesByUserId(widget.userId);
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart),
                    const SizedBox(width: 8),
                    Text(
                      'Overview',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(
                      'Activity',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EXPENSE OVERVIEW',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _balancesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                                child: Text('Failed to load balance data')),
                          );
                        }

                        return ExpenseOverviewChart(balances: snapshot.data!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Activity Tab
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final activities = snapshot.data ?? [];

                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some expenses to see activity here',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ActivityListItem(
                        activity: activity,
                        userId: widget.userId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
