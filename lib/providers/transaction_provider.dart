import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';

/// Defines the available date filters for transactions.
enum DateFilter { thisMonth, last30Days, all }

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _transactionSubscription;
  DateFilter _activeFilter = DateFilter.thisMonth; // Default filter

  DateFilter get activeFilter => _activeFilter;

  /// Returns a list of transactions based on the active filter.
  List<Transaction> get transactions {
    final now = DateTime.now();
    switch (_activeFilter) {
      case DateFilter.thisMonth:
        return _transactions
            .where((tx) =>
                tx.date.year == now.year && tx.date.month == now.month)
            .toList();
      case DateFilter.last30Days:
        return _transactions
            .where((tx) => tx.date.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
      case DateFilter.all:
      default:
        return _transactions;
    }
  }

  // This method is now called by ChangeNotifierProxyProvider in main.dart
  // whenever the user's authentication state changes.
  void init(String? uid) {
    // Cancel any existing subscription to avoid memory leaks.
    _transactionSubscription?.cancel();

    if (uid != null) {
      _firestoreService.uid = uid;
      _transactionSubscription = _firestoreService.getTransactions().listen((txs) {
        _transactions = txs;
        notifyListeners();
      });
    } else {
      // If user logs out, clear the transactions.
      _transactions = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up the subscription when the provider is disposed.
    _transactionSubscription?.cancel();
    super.dispose();
  }

  /// Sets the active date filter and notifies listeners to update the UI.
  void setFilter(DateFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _firestoreService.addTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _firestoreService.deleteTransaction(id);
  }

  Future<void> updateTransaction(String id, Transaction updated) async {
    await _firestoreService.updateTransaction(id, updated);
  }
}