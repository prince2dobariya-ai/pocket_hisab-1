class EmiModel {
  final int? id;
  final String name; // e.g. "Home Loan", "Car Loan"
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double monthlyAmount;
  final String startDate;
  final String endDate;
  final String status; // 'active' | 'completed'
  final String createdAt;
  final String? lastPaidAt;
  final int dueDayOfMonth; // e.g. 10 or 22 — the day each instalment is due

  EmiModel({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.monthlyAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.lastPaidAt,
    this.dueDayOfMonth = 1,
  });

  /// Computed: EMI due status label
  String get dueStatus {
    if (status == 'completed') return 'Completed';
    final now = DateTime.now();
    final dueThisMonth = DateTime(
      now.year,
      now.month,
      dueDayOfMonth.clamp(1, 28),
    );
    final diff = dueThisMonth
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) {
      return 'Due Today';
    } else if (diff < 0) {
      return 'Overdue';
    } else if (diff <= 5) {
      return 'Due in $diff days';
    } else {
      return 'Due on ${dueDayOfMonth}th';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'monthly_amount': monthlyAmount,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_at': createdAt,
      'last_paid_at': lastPaidAt,
      'due_day_of_month': dueDayOfMonth,
    };
  }

  factory EmiModel.fromMap(Map<String, dynamic> map) {
    return EmiModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      monthlyAmount: (map['monthly_amount'] as num).toDouble(),
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      lastPaidAt: map['last_paid_at'] as String?,
      dueDayOfMonth: (map['due_day_of_month'] as int?) ?? 1,
    );
  }

  EmiModel copyWith({
    int? id,
    String? name,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    double? monthlyAmount,
    String? startDate,
    String? endDate,
    String? status,
    String? createdAt,
    String? lastPaidAt,
    int? dueDayOfMonth,
  }) {
    return EmiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
    );
  }
}
