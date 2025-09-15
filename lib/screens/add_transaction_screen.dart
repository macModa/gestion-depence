import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';
import '../models/app_data.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  String _category = 'Alimentation';
  String _type = 'expense';
  DateTime _date = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _isEditing = true;
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _category = tx.category;
      _type = tx.type;
      _date = tx.date;
    }
  }

  Future<void> _submitTransaction() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le montant doit être supérieur à zéro.'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (_isEditing) {
      final updatedTransaction = Transaction(
        id: widget.transactionToEdit!.id,
        amount: amount,
        category: _category,
        date: _date,
        type: _type,
      );
      await provider.updateTransaction(widget.transactionToEdit!.id, updatedTransaction);
      if (mounted) Navigator.of(context).pop();
    } else {
      final newTransaction = Transaction(
        id: '', // Auto-généré par Firestore
        amount: amount,
        category: _category,
        date: _date,
        type: _type,
      );
      await provider.addTransaction(newTransaction);
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction ajoutée !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier Transaction' : 'Ajouter Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Montant')),
            DropdownButton<String>(
              value: _category,
              isExpanded: true,
              items: appCategories.map((Category cat) {
                return DropdownMenuItem<String>(
                  value: cat.name,
                  child: Row(
                    children: [
                      Icon(cat.icon),
                      const SizedBox(width: 10),
                      Text(cat.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            DropdownButton<String>(
              value: _type,
              items: ['expense', 'income'].map((t) => DropdownMenuItem(value: t, child: Text(t.capitalize()))).toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            ListTile(
              title: Text(DateFormat('dd/MM/yyyy').format(_date)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ElevatedButton(onPressed: _submitTransaction, child: Text(_isEditing ? 'Mettre à jour' : 'Ajouter')),
          ],
        ),
      ),
    );
  }
}

// Extension helper pour capitalize
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}