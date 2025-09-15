import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class PieChartWidget extends StatefulWidget {
  final List<Transaction> transactions;

  const PieChartWidget({super.key, required this.transactions});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  // A list of colors to make the chart more vibrant.
  List<Color> get _pieColors => const [
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
    final Map<String, double> categoryTotals = {};
    double totalExpenses = 0;

    for (var tx in widget.transactions) {
      if (tx.type == 'expense') {
        categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
        totalExpenses += tx.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      // The parent screen already shows a message for no transactions,
      // so we can return an empty container here.
      return const SizedBox.shrink();
    }

    final pieChartSections = <PieChartSectionData>[];
    int i = 0;
    for (var entry in categoryTotals.entries) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 90.0 : 80.0;
      final percentage = (entry.value / totalExpenses) * 100;

      pieChartSections.add(
        PieChartSectionData(
          color: _pieColors[i % _pieColors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      i++;
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 20,
              sections: pieChartSections,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          children: List.generate(categoryTotals.length, (index) {
            return _Indicator(
              color: _pieColors[index % _pieColors.length],
              text: categoryTotals.keys.elementAt(index),
            );
          }),
        ),
      ],
    );
  }
}

/// A helper widget to create the legend items for the pie chart.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
      ],
    );
  }
}