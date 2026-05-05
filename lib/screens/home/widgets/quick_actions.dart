import 'package:flutter/material.dart';
import 'package:pocket_hisab/screens/expense/add_expense_screen.dart';
import 'package:pocket_hisab/screens/add_wallet_money_screen.dart';
import 'package:pocket_hisab/screens/hisab/hisab_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            _buildActionItem(
              context,
              icon: Icons.add,
              label: 'Add Expense',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
            ),

            _buildActionItem(
              context,
              icon: Icons.calendar_month,
              label: 'Add EMI',
              onTap: () {
                // TODO: Implement Add EMI Screen
              },
            ),

            _buildActionItem(
              context,
              icon: Icons.wallet,
              label: 'Add Wallet',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddWalletMoneyScreen(),
                  ),
                );
              },
            ),

            _buildActionItem(
              context,
              icon: Icons.account_balance,
              label: 'Hisab',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HisabScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
