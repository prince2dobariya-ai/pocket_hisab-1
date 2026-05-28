import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/screens/emi/emi_screen.dart';
import 'package:pocket_hisab/screens/settings/monthly_archive_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/monthly_reset_dialog.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final resetCtrl = Get.find<MonthlyResetController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Savings section ─────────────────────────────────────────────
          _SectionHeader(title: 'Savings'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: const Text('Saving Max Limit'),
              trailing: Obx(
                () => TextButton(
                  onPressed: () {
                    _showEditDialog(
                      context,
                      'Edit Max Saving Limit',
                      settingsCtrl.maxSavingLimit.value,
                      (val) => settingsCtrl.setMaxSavingLimit(val),
                    );
                  },
                  child: Text(
                    settingsCtrl.maxSavingLimit.value.toStringAsFixed(0),
                  ),
                ),
              ),
            ),
          ),

          // ── Wallet section ─────────────────────────────────────────────
          _SectionHeader(title: 'Wallet'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: const Text('Wallet Max Limit'),
              trailing: Obx(
                () => TextButton(
                  onPressed: () {
                    _showEditDialog(
                      context,
                      'Edit Max Wallet Limit',
                      settingsCtrl.maxWalletLimit.value,
                      (val) => settingsCtrl.setMaxWalletLimit(val),
                    );
                  },
                  child: Text(
                    settingsCtrl.maxWalletLimit.value.toStringAsFixed(0),
                  ),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(
              () => ListTile(
                title: const Text('Cycle Start Day'),
                subtitle: Text(
                  'Your month starts on day ${settingsCtrl.cycleStartDay.value}',
                ),
                trailing: const Icon(Icons.calendar_month_rounded, size: 20),
                onTap: () {
                  _showDayPickerDialog(
                    context,
                    settingsCtrl.cycleStartDay.value,
                    (day) => settingsCtrl.setCycleStartDay(day),
                  );
                },
              ),
            ),
          ),

          // ── Management section ───────────────────────────────────────────
          _SectionHeader(title: 'Management'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () => Get.to(() => const EmiScreen()),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('EMI Management'),
              subtitle: const Text('Loans, instalments and progress'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),

          // ── Monthly Reset section ────────────────────────────────────────
          _SectionHeader(title: 'Monthly Cycle'),

          // View archive history
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history_rounded, color: AppColors.primary),
              ),
              title: const Text('Monthly Archive History'),
              subtitle: Obx(
                () => Text(
                  '${resetCtrl.totalCyclesArchived} cycle(s) archived',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.to(() => const MonthlyArchiveScreen()),
            ),
          ),

          // Manual reset
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.orange,
                ),
              ),
              title: const Text('Manual Monthly Reset'),
              subtitle: const Text(
                'Archive current cycle & start fresh',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await resetCtrl.triggerManualReset();
                await MonthlyResetDialog.show();
              },
            ),
          ),

          // Last reset info
          Obx(() {
            final latest = resetCtrl.latestArchive;
            if (latest == null) return const SizedBox.shrink();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: Colors.green.shade50,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  'Last Reset: ${latest.label}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  latest.walletKept
                      ? 'Wallet balance was kept'
                      : 'Wallet was reset to ₹0',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDayPickerDialog(
    BuildContext context,
    int currentDay,
    Function(int) onSave,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cycle Start Day'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == currentDay;
                return InkWell(
                  onTap: () {
                    onSave(day);
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    double currentValue,
    Function(double) onSave,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null && val > 0) {
                  onSave(val);
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please enter a valid amount');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 0, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
