class GroupExpenseModel {
  final int? id;
  final int groupId;
  final String title;
  final double totalAmount;
  final int paidByMemberId;
  final DateTime createdAt;

  // Transient
  List<GroupExpenseSplitModel> splits = [];

  GroupExpenseModel({
    this.id,
    required this.groupId,
    required this.title,
    required this.totalAmount,
    required this.paidByMemberId,
    required this.createdAt,
  });

  factory GroupExpenseModel.fromMap(Map<String, dynamic> map) {
    return GroupExpenseModel(
      id: map['id'],
      groupId: map['group_id'],
      title: map['title'],
      totalAmount: map['total_amount'],
      paidByMemberId: map['paid_by_member_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'total_amount': totalAmount,
      'paid_by_member_id': paidByMemberId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GroupExpenseSplitModel {
  final int? id;
  final int groupExpenseId;
  final int memberId;
  final double amountOwed;

  GroupExpenseSplitModel({
    this.id,
    required this.groupExpenseId,
    required this.memberId,
    required this.amountOwed,
  });

  factory GroupExpenseSplitModel.fromMap(Map<String, dynamic> map) {
    return GroupExpenseSplitModel(
      id: map['id'],
      groupExpenseId: map['group_expense_id'],
      memberId: map['member_id'],
      amountOwed: map['amount_owed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_expense_id': groupExpenseId,
      'member_id': memberId,
      'amount_owed': amountOwed,
    };
  }
}

class GroupBalance {
  final int memberId;
  final double balance; // positive = gets money, negative = owes money

  GroupBalance({required this.memberId, required this.balance});
}

class SimplifiedDebt {
  final int debtorId;
  final int creditorId;
  final double amount;

  SimplifiedDebt({
    required this.debtorId,
    required this.creditorId,
    required this.amount,
  });
}
