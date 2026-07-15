import 'package:get/get.dart';
import 'package:pocket_hisab/models/group_model.dart';
import 'package:pocket_hisab/models/group_expense_model.dart';
import 'package:pocket_hisab/services/database_service.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'dart:math';

class GroupController extends GetxController {
  final _db = DatabaseService();
  static const _groupsTable = 'groups';
  static const _groupMembersTable = 'group_members';
  static const _groupExpensesTable = 'group_expenses';
  static const _groupExpenseSplitsTable = 'group_expense_splits';

  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllGroups();
  }

  Future<void> fetchAllGroups() async {
    isLoading.value = true;
    try {
      final rows = await _db.getAll(_groupsTable);
      final List<GroupModel> loadedGroups = [];

      for (var row in rows) {
        final group = GroupModel.fromMap(row);

        // Fetch members
        final memberRows = await _db.rawQuery(
          'SELECT gm.*, COALESCE(p.person_name, gm.name) as name FROM group_members gm '
          'LEFT JOIN persons p ON gm.person_id = p.id '
          'WHERE gm.group_id = ?',
          [group.id],
        );

        group.members = memberRows.map((m) {
          return GroupMemberModel.fromMap(m);
        }).toList();

        // Fetch total expenses
        final expenseRows = await _db.rawQuery(
          'SELECT SUM(total_amount) as total FROM group_expenses WHERE group_id = ?',
          [group.id],
        );
        group.totalExpenses = (expenseRows.first['total'] as double?) ?? 0.0;

        loadedGroups.add(group);
      }
      groups.value = loadedGroups;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> createGroup(String name, List<String> memberNames) async {
    final groupId = await _db.insert(_groupsTable, {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });

    for (var memberName in memberNames) {
      int? personId;

      if (memberName.toLowerCase() != 'you') {
        final personRows = await _db.rawQuery(
          'SELECT id FROM persons WHERE LOWER(person_name) = ?',
          [memberName.toLowerCase()],
        );

        if (personRows.isNotEmpty) {
          personId = personRows.first['id'] as int;
        } else {
          personId = await _db.insert('persons', {
            'person_name': memberName,
            'created_at': DateTime.now().toIso8601String(),
          });
          if (Get.isRegistered<PersonController>()) {
            Get.find<PersonController>().fetchAll();
          }
        }
      }

      await _db.insert(_groupMembersTable, {
        'group_id': groupId,
        'person_id': personId,
        'name': memberName,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    await fetchAllGroups();
    return groupId;
  }

  Future<void> deleteGroup(int groupId) async {
    await _db.deleteWhere('hisab_transactions', 'group_id = ?', [groupId]);
    await _db.delete(_groupsTable, groupId);
    groups.removeWhere((g) => g.id == groupId);
  }

  Future<List<GroupExpenseModel>> getGroupExpenses(int groupId) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM $_groupExpensesTable WHERE group_id = ? ORDER BY id DESC',
      [groupId],
    );

    List<GroupExpenseModel> expenses = [];
    for (var row in rows) {
      final expense = GroupExpenseModel.fromMap(row);

      // Get splits
      final splitRows = await _db.rawQuery(
        'SELECT * FROM $_groupExpenseSplitsTable WHERE group_expense_id = ?',
        [expense.id],
      );
      expense.splits = splitRows
          .map((s) => GroupExpenseSplitModel.fromMap(s))
          .toList();
      expenses.add(expense);
    }
    return expenses;
  }

  Future<void> addGroupExpense({
    required int groupId,
    required String title,
    required double totalAmount,
    required int paidByMemberId,
    required Map<int, double> splits, // memberId -> amountOwed
  }) async {
    final expenseId = await _db.insert(_groupExpensesTable, {
      'group_id': groupId,
      'title': title,
      'total_amount': totalAmount,
      'paid_by_member_id': paidByMemberId,
      'created_at': DateTime.now().toIso8601String(),
    });

    for (var entry in splits.entries) {
      if (entry.value > 0) {
        await _db.insert(_groupExpenseSplitsTable, {
          'group_expense_id': expenseId,
          'member_id': entry.key,
          'amount_owed': entry.value,
        });
      }
    }

    await _syncSettlementsToHisab(groupId);
    await fetchAllGroups();
  }

  Future<void> _syncSettlementsToHisab(int groupId) async {
    final memberRows = await _db.rawQuery(
      'SELECT id, person_id, name FROM $_groupMembersTable WHERE group_id = ?',
      [groupId],
    );

    int? youMemberId;
    Map<int, int?> memberIdToPersonId = {};
    for (var row in memberRows) {
      int id = row['id'] as int;
      int? pId = row['person_id'] as int?;
      String name = row['name'] as String;
      memberIdToPersonId[id] = pId;
      if (name.toLowerCase() == 'you') {
        youMemberId = id;
      }
    }

    if (youMemberId == null) return;

    String groupName = "";
    final groupRows = await _db.rawQuery(
      'SELECT name FROM $_groupsTable WHERE id = ?',
      [groupId],
    );
    if (groupRows.isNotEmpty) {
      groupName = groupRows.first['name'] as String;
    }
    String noteStr = "Settlement ($groupName)";

    final debts = await calculateSimplifiedDebts(groupId);

    Map<int, Map<String, dynamic>> desiredTransactions = {};

    for (var debt in debts) {
      if (debt.creditorId == youMemberId) {
        int? personId = memberIdToPersonId[debt.debtorId];
        if (personId != null) {
          desiredTransactions[personId] = {
            'amount': debt.amount,
            'type': 'given',
          };
        }
      } else if (debt.debtorId == youMemberId) {
        int? personId = memberIdToPersonId[debt.creditorId];
        if (personId != null) {
          desiredTransactions[personId] = {
            'amount': debt.amount,
            'type': 'borrowed',
          };
        }
      }
    }

    final existingTxRows = await _db.rawQuery(
      'SELECT * FROM hisab_transactions WHERE group_id = ?',
      [groupId],
    );
    
    List<int> processedPersonIds = [];

    for (var row in existingTxRows) {
      int txId = row['id'] as int;
      int personId = row['person_id'] as int;
      double amountPaid = (row['amount_paid'] as num).toDouble();
      
      if (desiredTransactions.containsKey(personId)) {
        var desired = desiredTransactions[personId]!;
        double newAmount = desired['amount'] as double;
        String newType = desired['type'] as String;
        
        double remaining = newAmount - amountPaid;
        if (remaining < 0) remaining = 0;
        String status = remaining <= 0 ? 'settled' : 'pending';

        await _db.update('hisab_transactions', {
          'type': newType,
          'amount': newAmount,
          'remaining_amount': remaining,
          'status': status,
          'note': noteStr,
        }, txId);
        
        processedPersonIds.add(personId);
      } else {
        await _db.delete('hisab_transactions', txId);
      }
    }

    for (var entry in desiredTransactions.entries) {
      int personId = entry.key;
      if (!processedPersonIds.contains(personId)) {
        double newAmount = entry.value['amount'] as double;
        String newType = entry.value['type'] as String;

        await _db.insert('hisab_transactions', {
          'person_id': personId,
          'type': newType,
          'amount': newAmount,
          'amount_paid': 0.0,
          'remaining_amount': newAmount,
          'status': 'pending',
          'is_old': 0,
          'note': noteStr,
          'payment_type': 'Group Expense',
          'group_id': groupId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }

    if (Get.isRegistered<HisabController>()) {
      Get.find<HisabController>().fetchPersons();
      Get.find<HisabController>().fetchTransactions();
    }
    if (Get.isRegistered<PersonController>()) {
      Get.find<PersonController>().fetchAll();
    }
  }

  // Debt Simplification Algorithm
  Future<List<SimplifiedDebt>> calculateSimplifiedDebts(int groupId) async {
    final expenses = await getGroupExpenses(groupId);
    final Map<int, double> netBalances = {};

    for (var expense in expenses) {
      // The person who paid gets credit (+)
      netBalances[expense.paidByMemberId] =
          (netBalances[expense.paidByMemberId] ?? 0.0) + expense.totalAmount;

      // Everyone who owes gets debit (-)
      for (var split in expense.splits) {
        netBalances[split.memberId] =
            (netBalances[split.memberId] ?? 0.0) - split.amountOwed;
      }
    }

    List<GroupBalance> debtors = [];
    List<GroupBalance> creditors = [];

    netBalances.forEach((memberId, balance) {
      // We round to 2 decimal places to avoid floating point issues
      double roundedBalance = (balance * 100).roundToDouble() / 100;
      if (roundedBalance > 0.01) {
        creditors.add(
          GroupBalance(memberId: memberId, balance: roundedBalance),
        );
      } else if (roundedBalance < -0.01) {
        debtors.add(GroupBalance(memberId: memberId, balance: -roundedBalance));
      }
    });

    // Sort descending by amount to minimize transactions greedily
    debtors.sort((a, b) => b.balance.compareTo(a.balance));
    creditors.sort((a, b) => b.balance.compareTo(a.balance));

    List<SimplifiedDebt> simplifiedDebts = [];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      double amount = min(debtors[i].balance, creditors[j].balance);

      simplifiedDebts.add(
        SimplifiedDebt(
          debtorId: debtors[i].memberId,
          creditorId: creditors[j].memberId,
          amount: amount,
        ),
      );

      debtors[i] = GroupBalance(
        memberId: debtors[i].memberId,
        balance: debtors[i].balance - amount,
      );
      creditors[j] = GroupBalance(
        memberId: creditors[j].memberId,
        balance: creditors[j].balance - amount,
      );

      if (debtors[i].balance < 0.01) i++;
      if (creditors[j].balance < 0.01) j++;
    }

    return simplifiedDebts;
  }
}
