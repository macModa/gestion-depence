import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/app_data.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TransactionCard({super.key, required this.transaction, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = transaction.type == 'income' ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        leading: Icon(getIconForCategory(transaction.category), color: color, size: 30),
        onTap: onTap,
        title: Text('${transaction.category}'),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${transaction.amount.toStringAsFixed(2)} €', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}