class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String type; // 'income' ou 'expense'

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
}