import 'package:flutter/material.dart';
import 'package:pocket_hisab/screens/home/widgets/salary_card.dart';
import 'package:pocket_hisab/screens/home/widgets/wallet_card_home.dart';
import 'package:pocket_hisab/screens/home/widgets/emi_card.dart';
import 'package:pocket_hisab/screens/home/widgets/saving_card.dart';
import 'package:pocket_hisab/screens/home/widgets/hisab_card.dart';
import 'package:pocket_hisab/screens/home/widgets/recent_transactions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.tabController});
  final TabController tabController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              crossAxisAlignment: .start,
              children: [
                /// salary card
                SalaryCard(),

                /// wallet card
                InkWell(
                  onTap: () {
                    tabController.animateTo(1);
                  },
                  child: WalletCardHome(),
                ),

                /// emi card
                EmiCard(),

                /// saving card
                SavingCard(),

                /// hisab card
                InkWell(
                  onTap: () {
                    tabController.animateTo(2);
                  },
                  child: HisabCard(),
                ),

                /// recent transactions
                RecentTransactions(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
