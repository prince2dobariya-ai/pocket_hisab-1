class TransactionModel {
  final int? id;
  final int walletId;
  final String type; // 'credit' | 'debit'
  final double amount;
  final String source; // e.g. Salary, Bonus, Other
  final String? note;
  final String createdAt;

  TransactionModel({
    this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.source,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'source': source,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      walletId: map['wallet_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      source: map['source'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  TransactionModel copyWith({
    int? id,
    int? walletId,
    String? type,
    double? amount,
    String? source,
    String? note,
    String? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
