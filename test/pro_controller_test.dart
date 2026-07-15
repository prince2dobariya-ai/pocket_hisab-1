import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pocket_hisab/controllers/pro_controller.dart';

class MockInAppPurchase implements InAppPurchase {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: identifiers.toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      true;

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async => true;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    IAPConnection.instance = MockInAppPurchase();
  });

  tearDown(() {
    Get.reset();
  });

  group('ProController Premium Logic & Migration Tests', () {
    test('Scenario 1: Fresh installation has premium set to false', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = Get.put(ProController());

      // Wait a microtask for async onInit methods to run
      await Future.delayed(Duration.zero);

      expect(controller.isPro.value, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_pro'), isFalse);
      expect(prefs.getBool('reset_mock_pro_v1'), isTrue);
    });

    test(
      'Scenario 2: Existing mock users get their premium status reset to false',
      () async {
        SharedPreferences.setMockInitialValues({'is_pro': true});

        final controller = Get.put(ProController());

        await Future.delayed(Duration.zero);

        expect(controller.isPro.value, isFalse);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('is_pro'), isFalse);
        expect(prefs.getBool('reset_mock_pro_v1'), isTrue);
      },
    );

    test(
      'Scenario 3: Real purchasers retain their premium status after reset has run',
      () async {
        SharedPreferences.setMockInitialValues({
          'is_pro': true,
          'reset_mock_pro_v1': true,
        });

        final controller = Get.put(ProController());

        await Future.delayed(Duration.zero);

        expect(controller.isPro.value, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('is_pro'), isTrue);
        expect(prefs.getBool('reset_mock_pro_v1'), isTrue);
      },
    );
  });
}
