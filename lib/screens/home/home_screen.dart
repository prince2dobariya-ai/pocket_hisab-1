import 'package:flutter/material.dart';
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
          padding: .symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              crossAxisAlignment: .start,
              children: [
                /// salary card
                SalaryCard(),

                /// saving card
                SavingCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
