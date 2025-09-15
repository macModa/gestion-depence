import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? uid; // Sera set via l'utilisateur connecté

  FirestoreService({this.uid});

  // Ajouter une transaction
  Future<void> addTransaction(Transaction transaction) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(transaction.toMap());
  }

  // Récupérer les transactions
  Stream<List<Transaction>> getTransactions() {
    if (uid == null) return Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String id) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  // Mettre à jour (exemple basique)
  Future<void> updateTransaction(String id, Transaction updated) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(id)
        .update(updated.toMap());
  }
}