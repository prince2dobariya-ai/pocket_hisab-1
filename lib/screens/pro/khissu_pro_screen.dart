import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/pro_controller.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class KhissuProScreen extends StatelessWidget {
  const KhissuProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final proCtrl = Get.find<ProController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Khissu Pro'),
      body: Obx(() {
        if (proCtrl.isPro.value) {
          return _buildProMemberView(context);
        }
        return _buildUpgradeView(context, proCtrl);
      }),
    );
  }

  Widget _buildProMemberView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.themePrimary.withAlpha(20),
                shape: .circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: context.themePrimary,
              ),
            ),
            const SizedBox(height: 32),
            const AppText("You're a Pro Member!", size: 18),
            const SizedBox(height: 12),
            AppText(
              "All premium features are unlocked.\nThank you for your support!",
              textAlign: .center,
              size: 14,
              fontWeight: .w500,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Explore Features",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeView(BuildContext context, ProController proCtrl) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond_rounded,
                    size: 64,
                    color: context.themePrimary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Upgrade to Pro",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E2C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Get the most out of Khissu with our premium features.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  _buildFeatureRow(
                    context,
                    Icons.fingerprint_rounded,
                    "App Lock",
                    "Face ID & Fingerprint",
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    context,
                    Icons.cloud_done_rounded,
                    "Cloud Backup",
                    "Auto-sync your data",
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    context,
                    Icons.insert_chart_rounded,
                    "PDF & Excel Reports",
                    "Advanced export options",
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    context,
                    Icons.dark_mode_rounded,
                    "Dark Mode",
                    "Beautiful AMOLED dark theme",
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    context,
                    Icons.color_lens_rounded,
                    "Custom Themes",
                    "Personalize with your favorite colors",
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(
                    context,
                    Icons.block_rounded,
                    "Zero Ads",
                    "No interruptions ever",
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomBar(context, proCtrl),
      ],
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: context.themePrimary, size: 26),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ProController proCtrl) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!proCtrl.isAvailable.value)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Store unavailable. Check Play Store.",
                style: TextStyle(color: Colors.red),
              ),
            )
          else if (proCtrl.products.isEmpty || proCtrl.purchasePending.value)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: proCtrl.buyPro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Get Pro for ${proCtrl.products.first.price}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: proCtrl.restorePurchases,
            child: const Text(
              "Restore Purchases",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
