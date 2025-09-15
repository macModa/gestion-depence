import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'transaction_card.dart';
import '../screens/add_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final tx = provider.transactions[index];
            return TransactionCard(
              transaction: tx,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(transactionToEdit: tx),
                  ),
                );
              },
              onDelete: () => provider.deleteTransaction(tx.id),
            );
          },
        );
      },
    );
  }
}