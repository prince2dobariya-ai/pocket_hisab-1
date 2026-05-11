/// Snapshot of one completed salary cycle stored for historical reference.
class MonthlyArchiveModel {
  final int? id;
  final String month; // e.g. "April"
  final int year;
  final double salaryAmount;
  final double totalExpenses;
  final double totalAddedToSavings;
  final double totalAddedToWallet;
  final double walletBalanceAtReset;
  final double savingsBalanceAtReset;
  final bool walletKept; // was wallet balance carried over?
  final String createdAt;

  MonthlyArchiveModel({
    this.id,
    required this.month,
    required this.year,
    required this.salaryAmount,
    required this.totalExpenses,
    required this.totalAddedToSavings,
    required this.totalAddedToWallet,
    required this.walletBalanceAtReset,
    required this.savingsBalanceAtReset,
    required this.walletKept,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month': month,
      'year': year,
      'salary_amount': salaryAmount,
      'total_expenses': totalExpenses,
      'total_added_to_savings': totalAddedToSavings,
      'total_added_to_wallet': totalAddedToWallet,
      'wallet_balance_at_reset': walletBalanceAtReset,
      'savings_balance_at_reset': savingsBalanceAtReset,
      'wallet_kept': walletKept ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory MonthlyArchiveModel.fromMap(Map<String, dynamic> map) {
    return MonthlyArchiveModel(
      id: map['id'] as int?,
      month: map['month'] as String,
      year: map['year'] as int,
      salaryAmount: (map['salary_amount'] as num).toDouble(),
      totalExpenses: (map['total_expenses'] as num).toDouble(),
      totalAddedToSavings: (map['total_added_to_savings'] as num).toDouble(),
      totalAddedToWallet: (map['total_added_to_wallet'] as num).toDouble(),
      walletBalanceAtReset:
          (map['wallet_balance_at_reset'] as num).toDouble(),
      savingsBalanceAtReset:
          (map['savings_balance_at_reset'] as num).toDouble(),
      walletKept: (map['wallet_kept'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  MonthlyArchiveModel copyWith({
    int? id,
    String? month,
    int? year,
    double? salaryAmount,
    double? totalExpenses,
    double? totalAddedToSavings,
    double? totalAddedToWallet,
    double? walletBalanceAtReset,
    double? savingsBalanceAtReset,
    bool? walletKept,
    String? createdAt,
  }) {
    return MonthlyArchiveModel(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalAddedToSavings: totalAddedToSavings ?? this.totalAddedToSavings,
      totalAddedToWallet: totalAddedToWallet ?? this.totalAddedToWallet,
      walletBalanceAtReset: walletBalanceAtReset ?? this.walletBalanceAtReset,
      savingsBalanceAtReset:
          savingsBalanceAtReset ?? this.savingsBalanceAtReset,
      walletKept: walletKept ?? this.walletKept,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Human-readable label, e.g. "April 2025"
  String get label => '$month $year';
}
