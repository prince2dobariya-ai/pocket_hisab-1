import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateFormat('d/M/yyyy').format(DateTime.now()),
  );

  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Wallet';
  String? _selectedPerson;
  DateTime _selectedDateTime = DateTime.now();

  final List<_CategoryItem> _categories = [
    _CategoryItem(name: 'Food', icon: Icons.restaurant, color: Colors.orange),
    _CategoryItem(
      name: 'Transport',
      icon: Icons.directions_bus,
      color: Colors.blue,
    ),
    _CategoryItem(name: 'Rent', icon: Icons.home, color: Colors.purple),
    _CategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    _CategoryItem(name: 'Entertainment', icon: Icons.movie, color: Colors.red),
    _CategoryItem(name: 'Bills', icon: Icons.receipt, color: Colors.cyan),
    _CategoryItem(
      name: 'Medical',
      icon: Icons.medical_services,
      color: Colors.green,
    ),
    _CategoryItem(name: 'Friend', icon: Icons.person, color: Colors.indigo),
    _CategoryItem(name: 'Others', icon: Icons.category, color: Colors.blueGrey),
  ];

  final List<String> _paymentMethods = ['Wallet', 'Salary'];

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Wallet':
        return Icons.account_balance_wallet_rounded;
      case 'Salary':
        return Icons.payments_outlined;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkCard,
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: AppColors.darkBackground,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
        _dateController.text = DateFormat('d/M/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletCtrl = Get.find<WalletController>();
    final dashCtrl = Get.find<DashboardController>();
    final personCtrl = Get.find<PersonController>();

    final todayFormatted = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(_selectedDateTime);

    return Scaffold(
      appBar: const CustomAppBar(title: "Add Expense"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Calculator-Style Hero Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkCard, Colors.grey.shade900]
                        : [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Enter Amount".toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          CurrencyHelper.format(
                            0,
                          )[0], // Get local currency symbol
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: "0.00",
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Circular Category Scroll
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    "Select Category",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat.name;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat.name;
                            });
                          },
                          child: Container(
                            width: 76,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cat.color
                                        : cat.color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: cat.color.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : cat.color,
                                    size: 24,
                                  ),
                                ),
                                Text(
                                  cat.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // 3. Conditional Friend selector (Horizontal Avatars)
              if (_selectedCategory == 'Friend')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    const Text(
                      "Lent To (Select Friend)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() {
                      if (personCtrl.persons.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            spacing: 8,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.red,
                                size: 28,
                              ),
                              const Text(
                                "No friends active yet",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                "Add them under the Hisabs tab to record friend lent expenses.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: personCtrl.persons.length,
                          itemBuilder: (context, index) {
                            final friend = personCtrl.persons[index];
                            final isFriendSelected =
                                _selectedPerson == friend.personName;
                            final initial = friend.personName.trim().isNotEmpty
                                ? friend.personName.trim()[0].toUpperCase()
                                : 'F';

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPerson = friend.personName;
                                });
                              },
                              child: Container(
                                width: 72,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  spacing: 6,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isFriendSelected
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: isFriendSelected
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.indigo.shade50,
                                            child: Text(
                                              initial,
                                              style: TextStyle(
                                                color: isFriendSelected
                                                    ? AppColors.primary
                                                    : Colors.indigo.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isFriendSelected)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      friend.personName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isFriendSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isFriendSelected
                                            ? (isDark
                                                  ? Colors.white
                                                  : Colors.black87)
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),

              // 4. Date Picker Row Card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    "Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  "Selected Date",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  todayFormatted,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey.shade400,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 5. Payment Methods Selectable Cards
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Obx(() {
                    final walletBal = walletCtrl.totalBalance;
                    final salaryLeft = dashCtrl.salaryLeft;

                    return Row(
                      spacing: 12,
                      children: _paymentMethods.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        final methodBalance = method == 'Wallet'
                            ? walletBal
                            : salaryLeft;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : (isDark
                                          ? AppColors.darkCard
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : (isDark
                                                    ? Colors.grey.shade800
                                                    : Colors.grey.shade100),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getPaymentMethodIcon(method),
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.white70
                                                    : Colors.grey.shade700),
                                          size: 16,
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2,
                                    children: [
                                      Text(
                                        method,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        CurrencyHelper.format(methodBalance),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade500,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),

              // 6. Note (Optional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    "Note (Optional)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  CustomTextField(
                    labelText: 'Add a note (e.g. dinner with team)...',
                    controller: _noteController,
                    minLine: 3,
                    maxLine: 3,
                  ),
                ],
              ),

              // 7. Save Button
              Column(
                children: [
                  const SizedBox(height: 8),
                  CustomButton(
                    title: "Save Expense",
                    onTap: () async {
                      final amountText = _amountController.text.trim();
                      if (amountText.isEmpty) {
                        Get.snackbar("Error", "Please enter amount");
                        return;
                      }

                      final amount = double.tryParse(amountText);
                      if (amount == null || amount <= 0) {
                        Get.snackbar("Error", "Invalid amount entered");
                        return;
                      }

                      final txCtrl = Get.find<TransactionController>();
                      final walletCtrl = Get.find<WalletController>();
                      final hisabCtrl = Get.find<HisabController>();

                      // Validation for Friend category
                      if (_selectedCategory == 'Friend' &&
                          _selectedPerson == null) {
                        Get.snackbar("Error", "Please select a friend");
                        return;
                      }

                      // 1. Save expense to database
                      await txCtrl.addExpense(
                        ExpenseModel(
                          category: _selectedCategory,
                          amount: amount,
                          note: _noteController.text.trim(),
                          date: _dateController.text,
                          createdAt: DateTime.now().toIso8601String(),
                          paymentMethod: _selectedPaymentMethod,
                        ),
                      );

                      // 2. Record in Hisab if it's a friend expense
                      if (_selectedCategory == 'Friend') {
                        final personId = await hisabCtrl.getOrCreatePerson(
                          _selectedPerson!,
                        );
                        await hisabCtrl.addHisab(
                          HisabModel(
                            personId: personId,
                            personName: _selectedPerson!,
                            type: 'given',
                            amount: amount,
                            amountPaid: 0.0,
                            remainingAmount: amount,
                            status: 'pending',
                            note: _noteController.text.trim(),
                            createdAt: DateTime.now().toIso8601String(),
                          ),
                        );
                      }

                      // 3. Conditional deduction from Wallet
                      if (_selectedPaymentMethod == 'Wallet') {
                        if (walletCtrl.wallets.isNotEmpty) {
                          final walletId = walletCtrl.wallets.first.id!;
                          await walletCtrl.debit(
                            walletId: walletId,
                            amount: amount,
                            source: _selectedCategory == 'Friend'
                                ? 'Lent to $_selectedPerson'
                                : 'Expense: $_selectedCategory',
                            note: _noteController.text.trim().isNotEmpty
                                ? _noteController.text.trim()
                                : 'Paid via Wallet',
                          );
                        } else {
                          Get.snackbar(
                            "Info",
                            "Expense recorded, but no wallet found to update balance.",
                          );
                        }
                      }

                      Get.back();
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  _CategoryItem({required this.name, required this.icon, required this.color});
}
