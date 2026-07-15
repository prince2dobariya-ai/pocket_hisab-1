import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/controllers/pro_controller.dart';
import 'package:pocket_hisab/screens/home/home_main.dart';
import 'package:pocket_hisab/screens/settings/app_lock_screen.dart';
import 'package:pocket_hisab/screens/onboarding/onboarding_screen.dart';
import 'package:pocket_hisab/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

  // Initialize Controllers
  Get.put(TransactionController());
  Get.put(WalletController());
  Get.put(SalaryController());
  Get.put(EmiController());
  Get.put(HisabController());
  Get.put(SavingController());
  Get.put(PersonController());
  Get.put(DashboardController());
  Get.put(SettingsController());
  Get.put(MonthlyResetController());
  Get.put(ProController());

  runApp(MyApp(showOnboarding: !onboardingDone));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settingsCtrl = Get.find<SettingsController>();
      final proCtrl = Get.find<ProController>();

      ThemeMode currentThemeMode = ThemeMode.light;
      if (proCtrl.isPro.value) {
        switch (settingsCtrl.themeMode.value) {
          case 'light':
            currentThemeMode = ThemeMode.light;
            break;
          case 'dark':
            currentThemeMode = ThemeMode.dark;
            break;
          default:
            currentThemeMode = ThemeMode.system;
        }
      }

      final themeColor = Color(settingsCtrl.themeColorValue.value);

      return GetMaterialApp(
        title: 'Khissu - Pocket Hisab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(themeColor),
        darkTheme: AppTheme.getDarkTheme(themeColor),
        themeMode: currentThemeMode,
        home: showOnboarding
            ? const OnboardingScreen()
            : Obx(() {
                if (settingsCtrl.appLockEnabled.value && proCtrl.isPro.value) {
                  return const AppLockScreen(child: HomeMain());
                }
                return const HomeMain();
              }),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1)),
            child: child!,
          );
        },
      );
    });
  }
}
