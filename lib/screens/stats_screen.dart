import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../services/pdf_service.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This widget is displayed within the body of HomeScreen's Scaffold,
    // so we return the content directly.
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.transactions.isEmpty) {
          return const Center(
            child: Text(
              'Aucune transaction pour afficher les statistiques.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Calculate totals for the summary
        double totalIncome = 0;
        double totalExpenses = 0;
        for (var tx in provider.transactions) {
          if (tx.type == 'income') {
            totalIncome += tx.amount;
          } else {
            totalExpenses += tx.amount;
          }
        }
        final double netBalance = totalIncome - totalExpenses;
        final currencyFormatter =
            NumberFormat.currency(locale: 'fr_FR', symbol: '€');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Résumé global',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Exporter en PDF',
                    onPressed: () {
                      String title;
                      switch (provider.activeFilter) {
                        case DateFilter.thisMonth:
                          title = 'Rapport de ${DateFormat.yMMMM('fr_FR').format(DateTime.now())}';
                          break;
                        case DateFilter.last30Days:
                          title = 'Rapport des 30 derniers jours';
                          break;
                        case DateFilter.all:
                          title = 'Rapport de toutes les transactions';
                          break;
                      }
                      PdfExportService.exportTransactionsPdf(title, provider.transactions);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                context,
                totalIncome: currencyFormatter.format(totalIncome),
                totalExpenses: currencyFormatter.format(totalExpenses),
                netBalance: currencyFormatter.format(netBalance),
                netBalanceColor: netBalance >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 32),
              Text(
                'Dépenses par catégorie',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250, // Increased height for better readability
                child: BarChartWidget(transactions: provider.transactions),
              ),
              const SizedBox(height: 32),
              Text(
                'Répartition des dépenses',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: PieChartWidget(transactions: provider.transactions),
              ),
            ],
          ),
        );
      },
    );
  }

  // A helper widget to build the summary card.
  Widget _buildSummaryCard(
    BuildContext context, {
    required String totalIncome,
    required String totalExpenses,
    required String netBalance,
    required Color netBalanceColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(
                icon: Icons.arrow_downward,
                color: Colors.green,
                label: 'Revenus totaux',
                amount: totalIncome),
            const Divider(height: 24),
            _buildSummaryRow(
                icon: Icons.arrow_upward,
                color: Colors.red,
                label: 'Dépenses totales',
                amount: totalExpenses),
            const Divider(height: 24),
            _buildSummaryRow(
                icon: Icons.account_balance_wallet,
                color: netBalanceColor,
                label: 'Solde net',
                amount: netBalance,
                isBold: true),
          ],
        ),
      ),
    );
  }

  // A helper widget for each row in the summary card.
  Widget _buildSummaryRow(
      {required IconData icon,
      required Color color,
      required String label,
      required String amount,
      bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ]),
        Text(amount,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color)),
      ],
    );
  }
}