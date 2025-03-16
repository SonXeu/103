class Transaction {
  final String? id;
  final String fabricId;
  final String transactionType; // "import" hoặc "export"
  final int quantity;
  final String note;
  final DateTime transactionDate;

  Transaction({
    this.id,
    required this.fabricId,
    required this.transactionType,
    required this.quantity,
    required this.note,
    required this.transactionDate,
  });

  factory Transaction.fromFirestore(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      fabricId: data['fabricId'],
      transactionType: data['transactionType'],
      quantity: data['quantity'],
      note: data['note'],
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fabricId': fabricId,
      'transactionType': transactionType,
      'quantity': quantity,
      'note': note,
      'transactionDate': transactionDate,
    };
  }
}
