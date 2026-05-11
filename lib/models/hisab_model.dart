class HisabModel {
  final int? id;
  final int personId;
  final String? personName; // Optional, usually populated via JOIN
  final String type; // 'given' | 'borrowed'
  final double amount;
  final double amountPaid;
  final double remainingAmount;
  final String status; // 'pending' | 'settled'
  final String? note;
  final String createdAt;

  HisabModel({
    this.id,
    required this.personId,
    this.personName,
    required this.type,
    required this.amount,
    required this.amountPaid,
    required this.remainingAmount,
    required this.status,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'type': type,
      'amount': amount,
      'amount_paid': amountPaid,
      'remaining_amount': remainingAmount,
      'status': status,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory HisabModel.fromMap(Map<String, dynamic> map) {
    return HisabModel(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      personName: map['person_name'] as String?, // May come from JOIN
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      amountPaid: (map['amount_paid'] as num).toDouble(),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      status: map['status'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  HisabModel copyWith({
    int? id,
    int? personId,
    String? personName,
    String? type,
    double? amount,
    double? amountPaid,
    double? remainingAmount,
    String? status,
    String? note,
    String? createdAt,
  }) {
    return HisabModel(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
