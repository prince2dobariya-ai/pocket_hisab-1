import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/screens/add_wallet_money_screen.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.find<WalletController>();

    return InkWell(
      onTap: () {},
      child: Card(
        color: const Color.fromRGBO(227, 242, 253, 1),
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
        child: Padding(
          padding: .all(16.0),
          child: Column(
            spacing: 5,
            crossAxisAlignment: .start,
            children: [
              Row(
                spacing: 5,
                children: const [
                  Icon(Icons.account_balance_wallet),
                  Text("Wallet"),
                ],
              ),
              Obx(
                () => Text(
                  "₹${walletCtrl.totalBalance.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddWalletMoneyScreen(),
                    ),
                  );
                },
                child: const Text("+ Add Money"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
