class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String? note;
  final String date;
  final String createdAt;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'note': note,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  ExpenseModel copyWith({
    int? id,
    String? category,
    double? amount,
    String? note,
    String? date,
    String? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
