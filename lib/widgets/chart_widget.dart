import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'dart:math';

class BarChartWidget extends StatelessWidget {
  final List<Transaction> transactions;

  const BarChartWidget({super.key, required this.transactions});

  // A list of colors to make the chart more vibrant.
  List<Color> get _barColors => const [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.pink,
        Colors.amber,
      ];

  @override
  Widget build(BuildContext context) {
    // Aggregate expenses by category.
    final Map<String, double> categoryTotals = {};
    for (var tx in transactions) {
      if (tx.type == 'expense') {
        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amount;
      }
    }

    // If there are no expenses, show a message.
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          'Aucune dépense à afficher.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // Sort categories by amount for a more organized chart.
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: _barColors[i % _barColors.length],
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // Add some padding to the top of the highest bar.
        maxY: (categoryTotals.values.reduce(max) * 1.2).ceilToDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = sortedEntries[group.x].key;
              final amount = rod.toY;
              return BarTooltipItem(
                '$category\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                        .format(amount),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  final category = sortedEntries[index].key;
                  // Truncate long category names.
                  final text = category.length > 10
                      ? '${category.substring(0, 8)}...'
                      : category;
                  return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: Text(text,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)));
                }
                return const Text('');
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) return const Text('');
                return Text('${value.toInt()}€',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.left);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              (categoryTotals.values.reduce(max) * 1.2).ceilToDouble() / 5,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.grey, strokeWidth: 0.5, dashArray: [5, 5]),
        ),
        barGroups: barGroups,
      ),
    );
  }
}