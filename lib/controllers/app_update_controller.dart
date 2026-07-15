import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/foundation.dart';

class AppUpdateController extends GetxController {
  RxBool isUpdateAvailable = false.obs;
  AppUpdateInfo? updateInfo;

  @override
  void onInit() {
    super.onInit();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      if (!GetPlatform.isAndroid) return;
      
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        updateInfo = info;
        isUpdateAvailable.value = true;
      }
    } catch (e) {
      debugPrint("Error checking for update: $e");
    }
  }

  Future<void> performUpdate() async {
    try {
      if (updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint("Error performing update: $e");
    }
  }
}
