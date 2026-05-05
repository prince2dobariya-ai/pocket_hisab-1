class SalaryModel {
  final int? id;
  final double amount;
  final String month; // e.g. "May"
  final int year;
  final String createdAt;

  SalaryModel({
    this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'created_at': createdAt,
    };
  }

  factory SalaryModel.fromMap(Map<String, dynamic> map) {
    return SalaryModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as String,
      year: map['year'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  SalaryModel copyWith({
    int? id,
    double? amount,
    String? month,
    int? year,
    String? createdAt,
  }) {
    return SalaryModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
