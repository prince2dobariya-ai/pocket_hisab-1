import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/controllers/pro_controller.dart';
import 'package:pocket_hisab/screens/emi/emi_screen.dart';
import 'package:pocket_hisab/screens/settings/monthly_archive_screen.dart';
import 'package:pocket_hisab/screens/pro/khissu_pro_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
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
          // ── Security section (Pro Only) ──────────────────────────────
          _SectionHeader(title: 'Security'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(
              () => SwitchListTile(
                title: const Text('Biometric App Lock'),
                subtitle: const Text(
                  'Require Face ID / Fingerprint to open app',
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: Colors.redAccent,
                  ),
                ),
                value: settingsCtrl.appLockEnabled.value,
                onChanged: (val) async {
                  final proCtrl = Get.find<ProController>();
                  if (val && !proCtrl.isPro.value) {
                    Get.to(() => const KhissuProScreen());
                    return;
                  }

                  final localAuth = LocalAuthentication();
                  final bool canAuthenticateWithBiometrics =
                      await localAuth.canCheckBiometrics;
                  final bool canAuthenticate =
                      canAuthenticateWithBiometrics ||
                      await localAuth.isDeviceSupported();

                  if (!canAuthenticate) {
                    showCustomSnackbar(
                      'Error',
                      'Biometrics not supported or setup on this device.',
                    );
                    return;
                  }

                  try {
                    final didAuthenticate = await localAuth.authenticate(
                      localizedReason: 'Please authenticate to toggle App Lock',
                      biometricOnly: false,
                    );
                    if (didAuthenticate) {
                      settingsCtrl.setAppLockEnabled(val);
                    }
                  } catch (e) {
                    showCustomSnackbar('Error', 'Authentication failed: $e');
                  }
                },
              ),
            ),
          ),
          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(() {
              final proCtrl = Get.find<ProController>();
              final isPro = proCtrl.isPro.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dark_mode_rounded,
                        color: Colors.purple,
                      ),
                    ),
                    title: const Text('Theme Mode'),
                    subtitle: Text(
                      isPro
                          ? (settingsCtrl.themeMode.value == 'system'
                                ? 'System Default'
                                : (settingsCtrl.themeMode.value == 'dark'
                                      ? 'Dark Mode'
                                      : 'Light Mode'))
                          : 'Light (Pro Only)',
                    ),
                    trailing: isPro
                        ? const Icon(Icons.arrow_forward_ios, size: 16)
                        : const Icon(
                            Icons.lock_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                    onTap: () {
                      if (!isPro) {
                        Get.to(() => const KhissuProScreen());
                        return;
                      }

                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      Get.bottomSheet(
                        Container(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: MediaQuery.of(context).padding.bottom + 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.bottomSheetDark : AppColors.bottomSheet,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  width: 44,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const AppText(
                                    'Select Theme Mode',
                                    fontWeight: FontWeight.bold,
                                    size: 18,
                                  ),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    onPressed: () => Get.back(),
                                    icon: const Icon(Icons.close_rounded, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text('System Default'),
                                trailing:
                                    settingsCtrl.themeMode.value == 'system'
                                    ? Icon(
                                        Icons.check,
                                        color: context.themePrimary,
                                      )
                                    : null,
                                onTap: () {
                                  settingsCtrl.setThemeMode('system');
                                  Get.back();
                                },
                              ),
                              ListTile(
                                title: const Text('Light Mode'),
                                trailing:
                                    settingsCtrl.themeMode.value == 'light'
                                    ? Icon(
                                        Icons.check,
                                        color: context.themePrimary,
                                      )
                                    : null,
                                onTap: () {
                                  settingsCtrl.setThemeMode('light');
                                  Get.back();
                                },
                              ),
                              ListTile(
                                title: const Text('Dark Mode'),
                                trailing: settingsCtrl.themeMode.value == 'dark'
                                    ? Icon(
                                        Icons.check,
                                        color: context.themePrimary,
                                      )
                                    : null,
                                onTap: () {
                                  settingsCtrl.setThemeMode('dark');
                                  Get.back();
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.color_lens_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text('Accent Color'),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              const Color(0xFF10B981), // Green
                              const Color(0xFF3B82F6), // Blue
                              const Color(0xFF8B5CF6), // Purple
                              const Color(0xFFF59E0B), // Orange
                              const Color(0xFFEC4899), // Pink
                            ].map((color) {
                              final isSelected =
                                  settingsCtrl.themeColorValue.value ==
                                  color.value;
                              return GestureDetector(
                                onTap: () {
                                  if (!isPro && color.value != 0xFF10B981) {
                                    Get.to(() => const KhissuProScreen());
                                    return;
                                  }
                                  settingsCtrl.setThemeColorValue(color.value);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.themeTextDark
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: !isPro && color.value != 0xFF10B981
                                      ? const Icon(
                                          Icons.lock_rounded,
                                          size: 16,
                                          color: Colors.white70,
                                        )
                                      : (isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          // ── Savings section ─────────────────────────────────────────────
          _SectionHeader(title: 'Savings'),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.themeSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: context.themeSecondary,
                ),
              ),
              title: const Text('Saving Max Limit'),
              subtitle: Text('Set max saving limit'),
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
                  child: AppText(
                    settingsCtrl.maxSavingLimit.value.toStringAsFixed(0),
                    color: context.themeSecondary,
                    fontWeight: .bold,
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
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.themePrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: context.themePrimary,
                ),
              ),
              title: const Text('Wallet Max Limit'),
              subtitle: Text('Set max wallet limit'),
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
                  child: AppText(
                    settingsCtrl.maxWalletLimit.value.toStringAsFixed(0),
                    color: context.themeSecondary,
                    fontWeight: .bold,
                  ),
                ),
              ),
            ),
          ),

          // ── Monthly Reset section ────────────────────────────────────────
          _SectionHeader(title: 'Monthly Cycle'),

          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(
              () => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.themePrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: context.themePrimary,
                  ),
                ),
                title: const Text('Cycle Start Day'),
                subtitle: Text(
                  'Your month starts on day ${settingsCtrl.cycleStartDay.value}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                  color: context.themePrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history_rounded, color: context.themePrimary),
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
                          ? context.themePrimary
                          : context.themePrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : context.themePrimary,
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
                  showCustomSnackbar('Error', 'Please enter a valid amount');
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
