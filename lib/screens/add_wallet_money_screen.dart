import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/models/wallet_model.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class AddWalletMoneyScreen extends StatefulWidget {
  const AddWalletMoneyScreen({super.key});

  @override
  State<AddWalletMoneyScreen> createState() => _AddWalletMoneyScreenState();
}

class _AddWalletMoneyScreenState extends State<AddWalletMoneyScreen> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController(text: "Salary");
  final walletCtrl = Get.find<WalletController>();

  WalletModel? _selectedWallet;

  @override
  void initState() {
    super.initState();
    // Auto-select the first wallet if available
    if (walletCtrl.wallets.isNotEmpty) {
      _selectedWallet = walletCtrl.wallets.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Add to Wallet"),
      body: Obx(() {
        final wallets = walletCtrl.wallets;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount (e.g. 5000)",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Wallet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (wallets.isEmpty)
                const Text(
                  "No wallets found. A 'Main Wallet' will be created automatically.",
                  style: TextStyle(color: Colors.grey),
                )
              else
                DropdownButtonFormField<WalletModel>(
                  value: _selectedWallet,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: wallets
                      .map(
                        (w) => DropdownMenuItem(
                          value: w,
                          child: Text(w.walletName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWallet = value;
                    });
                  },
                ),
              const SizedBox(height: 24),
              const Text(
                "Source",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _sourceController.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Salary', 'Bonus', 'Other']
                    .map(
                      (source) =>
                          DropdownMenuItem(value: source, child: Text(source)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _sourceController.text = value;
                  }
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final amountText = _amountController.text.trim();
                    if (amountText.isEmpty) {
                      Get.snackbar('Error', 'Please enter amount');
                      return;
                    }
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      Get.snackbar('Error', 'Invalid amount entered');
                      return;
                    }

                    int targetWalletId;
                    if (wallets.isEmpty) {
                      // Create a default wallet if none exist
                      final newWallet = WalletModel(
                        walletName: "Main Wallet",
                        balance: 0.0,
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      await walletCtrl.addWallet(newWallet);
                      // Since addWallet fetches and updates the list asynchronously,
                      // we get the first one which should be the newly added one.
                      // Actually, addWallet inserts at index 0 immediately.
                      targetWalletId = walletCtrl.wallets.first.id!;
                    } else {
                      if (_selectedWallet == null) {
                        Get.snackbar('Error', 'Please select a wallet');
                        return;
                      }
                      targetWalletId = _selectedWallet!.id!;
                    }

                    await walletCtrl.credit(
                      walletId: targetWalletId,
                      amount: amount,
                      source: _sourceController.text,
                      note: "Added from ${_sourceController.text}",
                    );

                    Get.back();
                  },
                  child: const Text(
                    "Add Money",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
