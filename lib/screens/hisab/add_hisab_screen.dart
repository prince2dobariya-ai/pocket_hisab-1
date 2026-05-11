import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class AddHisabScreen extends StatefulWidget {
  final String? personName;
  final bool? isBorrowed;

  const AddHisabScreen({super.key, this.personName, this.isBorrowed});

  @override
  State<AddHisabScreen> createState() => _AddHisabScreenState();
}

class _AddHisabScreenState extends State<AddHisabScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final TextEditingController _dateController;

  late bool _isBorrowed;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _nameController = TextEditingController(text: widget.personName);
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
    _nameController.dispose();
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
    return Scaffold(
      appBar: const CustomAppBar(title: "Add Hisab"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle for Borrowed vs Lent
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBorrowed = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isBorrowed
                              ? Colors.green.shade400
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isBorrowed
                              ? Colors.red.shade400
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
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

            const Text(
              "Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "0.00",
                prefixIcon: const Icon(Icons.currency_rupee, size: 28),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Friend's Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter friend's name",
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Note (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What was this for?",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBorrowed
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final amountText = _amountController.text.trim();
                  final nameText = _nameController.text.trim();

                  if (amountText.isEmpty || nameText.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Please enter amount and friend's name",
                    );
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
                  final personId = await hisabCtrl.getOrCreatePerson(nameText);

                  // Add Hisab
                  final type = _isBorrowed ? 'borrowed' : 'given';
                  await hisabCtrl.addHisab(
                    HisabModel(
                      personId: personId,
                      personName: nameText,
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
                        source: 'Hisab: $nameText',
                        note: 'Borrowed from $nameText',
                      );
                    } else {
                      await walletCtrl.debit(
                        walletId: walletId,
                        amount: amount,
                        source: 'Hisab: $nameText',
                        note: 'Lent to $nameText',
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
                child: Text(
                  _isBorrowed ? "Save Borrowed" : "Save Lent",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
