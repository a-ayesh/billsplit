// Expense Overview Chart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseOverviewChart extends StatelessWidget {
  final Map<String, dynamic> balances;

  const ExpenseOverviewChart({
    super.key,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    final userBalances =
        List<Map<String, dynamic>>.from(balances['userBalances']);
    final owedBalances =
        userBalances.where((b) => b['type'] == 'owed').toList();
    final oweBalances = userBalances.where((b) => b['type'] == 'owe').toList();

    // Sort balances by amount
    owedBalances
        .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
    oweBalances
        .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    // Take top 5 for each category
    final topOwed = owedBalances.take(5).toList();
    final topOwe = oweBalances.take(5).toList();

    // Calculate total amounts
    final totalOwed =
        owedBalances.fold<double>(0, (sum, b) => sum + (b['amount'] as num));
    final totalOwe =
        oweBalances.fold<double>(0, (sum, b) => sum + (b['amount'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1CC29F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Color(0xFF1CC29F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'you are owed',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PKR ${totalOwed.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1CC29F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'you owe',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PKR ${totalOwe.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Charts
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // You are owed
            if (topOwed.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top owed by',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: topOwed.isEmpty
                              ? 10
                              : (topOwed.first['amount'] * 1.2),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Format large numbers with K suffix
                                  String formattedValue;
                                  if (value >= 1000) {
                                    formattedValue =
                                        '${(value / 1000).toStringAsFixed(0)}K';
                                  } else {
                                    formattedValue = value.toInt().toString();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      'PKR $formattedValue',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 60,
                                interval: (topOwed.first['amount'] / 4)
                                    .roundToDouble(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= topOwed.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      topOwed[value.toInt()]['name']
                                          .toString()
                                          .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: topOwed.first['amount'] / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups: List.generate(
                            topOwed.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: topOwed[index]['amount'],
                                  color: const Color(0xFF1CC29F),
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                    bottom: Radius.circular(0),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: topOwed.first['amount'] * 1.2,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (topOwed.isNotEmpty && topOwe.isNotEmpty)
              const SizedBox(width: 24),
            // You owe
            if (topOwe.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top you owe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: topOwe.isEmpty
                              ? 10
                              : (topOwe.first['amount'] * 1.2),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Format large numbers with K suffix
                                  String formattedValue;
                                  if (value >= 1000) {
                                    formattedValue =
                                        '${(value / 1000).toStringAsFixed(0)}K';
                                  } else {
                                    formattedValue = value.toInt().toString();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      'PKR $formattedValue',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 60,
                                interval: (topOwe.first['amount'] / 4)
                                    .roundToDouble(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= topOwe.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      topOwe[value.toInt()]['name']
                                          .toString()
                                          .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: topOwe.first['amount'] / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups: List.generate(
                            topOwe.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: topOwe[index]['amount'],
                                  color: Colors.orange,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                    bottom: Radius.circular(0),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: topOwe.first['amount'] * 1.2,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

