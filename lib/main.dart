import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Controllers
  Get.put(TransactionController());
  Get.put(WalletController());
  Get.put(SalaryController());
  Get.put(EmiController());
  Get.put(HisabController());
  Get.put(DashboardController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Khissu - Pocket Hisab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
