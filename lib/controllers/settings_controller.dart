import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final RxDouble maxSavingLimit = 10000.0.obs;
  final RxDouble maxWalletLimit = 5000.0.obs;
  final RxInt cycleStartDay = 1.obs; // Default to 1st of month
  final RxBool appLockEnabled = false.obs;
  final RxString themeMode = 'system'.obs;
  final RxInt themeColorValue = 0xFF10B981.obs;
  final RxBool hasSeenQuickGuide = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    maxSavingLimit.value = prefs.getDouble('maxSavingLimit') ?? 10000.0;
    maxWalletLimit.value = prefs.getDouble('maxWalletLimit') ?? 5000.0;
    cycleStartDay.value = prefs.getInt('cycleStartDay') ?? 1;
    appLockEnabled.value = prefs.getBool('appLockEnabled') ?? false;
    themeMode.value = prefs.getString('themeMode') ?? 'system';
    themeColorValue.value = prefs.getInt('themeColorValue') ?? 0xFF10B981;
    hasSeenQuickGuide.value = prefs.getBool('hasSeenQuickGuide') ?? false;
  }

  Future<void> setHasSeenQuickGuide(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenQuickGuide', value);
    hasSeenQuickGuide.value = value;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appLockEnabled', enabled);
    appLockEnabled.value = enabled;
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    themeMode.value = mode;
  }

  Future<void> setThemeColorValue(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColorValue', colorValue);
    themeColorValue.value = colorValue;
  }

  Future<void> setCycleStartDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cycleStartDay', day);
    cycleStartDay.value = day;
  }

  Future<void> setMaxSavingLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('maxSavingLimit', limit);
    maxSavingLimit.value = limit;
  }

  Future<void> setMaxWalletLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('maxWalletLimit', limit);
    maxWalletLimit.value = limit;
  }
}
