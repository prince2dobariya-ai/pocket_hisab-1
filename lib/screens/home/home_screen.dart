import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/screens/home/widgets/quick_actions.dart';
import 'package:pocket_hisab/screens/home/widgets/salary_card.dart';
import 'package:pocket_hisab/screens/home/widgets/saving_card.dart';
import 'package:pocket_hisab/screens/home/widgets/wallet_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .symmetric(horizontal: 16.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              crossAxisAlignment: .start,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    /// header
                    Text(
                      "Good Morning 👋",
                      style: TextStyle(fontSize: 22, fontWeight: .bold),
                    ),
                    Text(
                      DateFormat.yMMMM().format(DateTime.now()),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),

                /// salary card
                SalaryCard(),

                /// wallet card
                Row(
                  spacing: 12,
                  children: [
                    Expanded(child: WalletCard()),
                    Expanded(child: SavingCard()),
                  ],
                ),
                QuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
