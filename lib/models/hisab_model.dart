class HisabModel {
  final int? id;
  final int personId;
  final String? personName; // Optional, usually populated via JOIN
  final String type; // 'given' | 'borrowed'
  final double amount;
  final double amountPaid;
  final double remainingAmount;
  final String status; // 'pending' | 'settled'
  final bool isOld;
  final String? note;
  final String paymentType;
  final int? groupId;
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
    this.isOld = false,
    this.note,
    this.paymentType = 'Cash',
    this.groupId,
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
      'is_old': isOld ? 1 : 0,
      'note': note,
      'payment_type': paymentType,
      'group_id': groupId,
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
      isOld: map['is_old'] == 1,
      note: map['note'] as String?,
      paymentType: map['payment_type'] as String? ?? 'Cash',
      groupId: map['group_id'] as int?,
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
    bool? isOld,
    String? note,
    String? paymentType,
    int? groupId,
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
      isOld: isOld ?? this.isOld,
      note: note ?? this.note,
      paymentType: paymentType ?? this.paymentType,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
