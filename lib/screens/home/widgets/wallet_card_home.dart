import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';

class WalletCardHome extends StatelessWidget {
  const WalletCardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.find<WalletController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Card(
      color: context.themePrimary.withAlpha(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final balance = walletCtrl.totalBalance;
          final maxLimit = settingsCtrl.maxWalletLimit.value;

          final percentage = maxLimit > 0
              ? (balance / maxLimit).clamp(0.0, 1.0)
              : 0.0;
          final displayPercent = (percentage * 100).toStringAsFixed(0);

          return Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: context.themePrimary,
                            size: 20,
                          ),
                          Text(
                            "Wallet Balance",
                            style: TextStyle(
                              color: context.themePrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyHelper.format(balance),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.wallet, color: context.themePrimary),
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: percentage,
                color: percentage < 0.8 ? context.themePrimary : Colors.orange,
                minHeight: 12,
                borderRadius: BorderRadius.circular(12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$displayPercent% Remaing',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Limit: ${CurrencyHelper.format(maxLimit)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
