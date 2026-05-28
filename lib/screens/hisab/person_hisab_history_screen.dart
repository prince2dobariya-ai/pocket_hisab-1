import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class PersonHisabHistoryScreen extends StatelessWidget {
  final String personId;
  final String personName;

  const PersonHisabHistoryScreen({
    super.key,
    required this.personId,
    required this.personName,
  });

  @override
  Widget build(BuildContext context) {
    final hisabCtrl = Get.find<HisabController>();
    return Scaffold(
      appBar: CustomAppBar(title: personName.toUpperCase()),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final items = hisabCtrl.hisabs
                    .where((h) => h.personId.toString() == personId)
                    .toList();

                if (items.isEmpty) {
                  return const Center(child: Text("No history found"));
                }

                // Sort items by date (Oldest first for chat-like flow)
                items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                // Group items by date
                Map<String, List<HisabModel>> groupedItems = {};
                for (var item in items) {
                  String date = item.createdAt.split('T').first;
                  if (!groupedItems.containsKey(date)) {
                    groupedItems[date] = [];
                  }
                  groupedItems[date]!.add(item);
                }

                final sortedDates = groupedItems.keys.toList()
                  ..sort((a, b) => a.compareTo(b));

                return ListView.builder(
                  reverse: true,
                  padding: const .symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    String dateStr = sortedDates[index];
                    List<HisabModel> dayItems = groupedItems[dateStr]!;
                    return Column(
                      children: [
                        _buildDateDivider(dateStr),
                        ...dayItems.map((item) => _buildChatBubble(item)),
                      ],
                    );
                  },
                );
              }),
            ),
            _buildBottomSummary(hisabCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    String label;
    DateTime now = DateTime.now();
    if (dateStr == DateFormat('yyyy-MM-dd').format(now)) {
      label = "Today";
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildChatBubble(HisabModel item) {
    bool isGiven = item.type == 'given';
    Color themeColor = isGiven ? Colors.red : Colors.green;
    IconData icon = isGiven ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    // Extract time from createdAt if available, else use a placeholder
    String time = "08:00 AM";
    try {
      if (item.createdAt.contains('T')) {
        DateTime dt = DateTime.parse(item.createdAt);
        time = DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {}

    return Container(
      width: double.infinity,
      alignment: isGiven ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: themeColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  CurrencyHelper.format(item.amount),
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            if (item.note != null && item.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.note!,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(HisabController hisabCtrl) {
    return Obx(() {
      final items = hisabCtrl.hisabs
          .where((h) => h.personId.toString() == personId)
          .toList();

      double netBalance = 0;
      for (var h in items) {
        netBalance += (h.type == 'given' ? h.amount : -h.amount);
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisSize: .min,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Amount",
                  style: TextStyle(fontSize: 16, fontWeight: .bold),
                ),
                Text(
                  CurrencyHelper.format(netBalance.abs()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: .bold,
                    color: netBalance < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: _buildTransactionButton(
                    "Received",
                    Colors.green,
                    Icons.arrow_circle_down,
                    onTap: () {
                      Get.bottomSheet(
                        _AddPersonHisabBottomSheet(
                          personId: personId,
                          isBorrowed: true,
                          personName: personName,
                        ),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: .vertical(top: .circular(24)),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildTransactionButton(
                    "Given",
                    Colors.red,
                    Icons.arrow_circle_up,
                    onTap: () {
                      Get.bottomSheet(
                        _AddPersonHisabBottomSheet(
                          personId: personId,
                          isBorrowed: false,
                          personName: personName,
                        ),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: .vertical(top: .circular(24)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionButton(
    String label,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPersonHisabBottomSheet extends StatefulWidget {
  final String? personId;
  final bool? isBorrowed;
  final String? personName;

  const _AddPersonHisabBottomSheet({
    this.personId,
    this.isBorrowed,
    this.personName,
  });
  @override
  State<_AddPersonHisabBottomSheet> createState() =>
      _AddPersonHisabBottomSheetState();
}

class _AddPersonHisabBottomSheetState
    extends State<_AddPersonHisabBottomSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _dateController;

  late bool _isBorrowed;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _dateController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    );
    _isBorrowed = widget.isBorrowed ?? true;
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle for Borrowed vs Lent
          if (false)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: .circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBorrowed = true),
                      child: Container(
                        padding: const .symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isBorrowed
                              ? Colors.green.shade400
                              : Colors.transparent,
                          borderRadius: .circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Received (Borrowed)",
                            style: TextStyle(
                              color: _isBorrowed
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBorrowed = false),
                      child: Container(
                        padding: const .symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isBorrowed
                              ? Colors.red.shade400
                              : Colors.transparent,
                          borderRadius: .circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Given (Lent)",
                            style: TextStyle(
                              color: !_isBorrowed
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          CustomTextField(
            controller: _amountController,
            labelText: "Amount",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          const Text(
            "Note (Optional)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _noteController,
            labelText: 'What was this for?',
            maxLine: 3,
          ),
          const SizedBox(height: 24),
          CustomButton(
            title: _isBorrowed ? "Received" : "Given",
            color: _isBorrowed ? Colors.green.shade400 : Colors.red.shade400,
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

              final hisabCtrl = Get.find<HisabController>();
              final walletCtrl = Get.find<WalletController>();

              // Get or create person to get personId
              // final personId = await hisabCtrl.getOrCreatePerson(widget.personId);

              // Add Hisab
              final type = _isBorrowed ? 'borrowed' : 'given';
              await hisabCtrl.addHisab(
                HisabModel(
                  personId: int.parse(widget.personId.toString()),
                  personName: widget.personId,
                  type: type,
                  amount: amount,
                  note: _noteController.text.trim(),
                  createdAt: DateTime.now().toIso8601String(),
                  status: 'pending',
                  amountPaid: 0,
                  remainingAmount: amount,
                ),
              );

              // Affect Wallet
              if (walletCtrl.wallets.isNotEmpty) {
                final walletId = walletCtrl.wallets.first.id!;
                if (_isBorrowed) {
                  await walletCtrl.credit(
                    walletId: walletId,
                    amount: amount,
                    source: 'Hisab: ${widget.personName}',
                    note: 'Received from ${widget.personName}',
                  );
                } else {
                  await walletCtrl.debit(
                    walletId: walletId,
                    amount: amount,
                    source: 'Hisab: ${widget.personName}',
                    note: 'Given to ${widget.personName}',
                  );
                }
              } else {
                Get.snackbar(
                  "Info",
                  "Hisab recorded, but no wallet found to update balance.",
                );
              }

              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
