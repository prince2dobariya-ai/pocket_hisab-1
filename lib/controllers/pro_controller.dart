import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProController extends GetxController {
  final InAppPurchase _inAppPurchase = IAPConnection.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  var isPro = false.obs;
  var isAvailable = false.obs;
  var products = <ProductDetails>[].obs;
  var purchasePending = false.obs;

  final String _kProductId = 'khissu_pro_lifetime';
  bool _isMockMode = false;

  @override
  void onInit() {
    super.onInit();
    _loadProStatus();
    _initStoreInfo();
  }

  Future<void> _loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // One-time migration to clear any free premium status obtained from the mock mode bypass in version 26.7.13
    final hasResetMockPro = prefs.getBool('reset_mock_pro_v1') ?? false;
    if (!hasResetMockPro) {
      await prefs.setBool('is_pro', false);
      await prefs.setBool('reset_mock_pro_v1', true);
      isPro.value = false;
    } else {
      isPro.value = prefs.getBool('is_pro') ?? false;
    }
  }

  Future<void> _initStoreInfo() async {
    final bool available = await _inAppPurchase.isAvailable();

    if (available) {
      isAvailable.value = true;
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails({_kProductId});
      if (response.notFoundIDs.isEmpty && response.productDetails.isNotEmpty) {
        products.value = response.productDetails;
      }
    }

    // Fall back to Mock Mode if store is unavailable OR if the product doesn't exist yet (ONLY in debug mode)
    if (kDebugMode && (!available || products.isEmpty)) {
      _isMockMode = true;
      isAvailable.value = true;
      products.value = [
        ProductDetails(
          id: _kProductId,
          title: 'Khissu Pro (Mock)',
          description: 'Lifetime Pro Access',
          price: '₹ 49.00',
          rawPrice: 49.0,
          currencyCode: 'INR',
        ),
      ];
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (Object error) {
        purchasePending.value = false;
      },
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        purchasePending.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          purchasePending.value = false;
          showCustomSnackbar(
            'Error',
            'Failed to complete purchase. Please try again.',
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndDeliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(
    PurchaseDetails? purchaseDetails,
  ) async {
    isPro.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', true);
    purchasePending.value = false;

    // Use Future.microtask to avoid showCustomSnackbar issues while in a stream listener
    Future.microtask(
      () => showCustomSnackbar('Success', 'Welcome to Khissu Pro!'),
    );
  }

  Future<void> buyPro() async {
    if (_isMockMode) {
      purchasePending.value = true;
      await Future.delayed(const Duration(seconds: 2));
      _verifyAndDeliverProduct(null);
      return;
    }

    if (products.isEmpty) {
      showCustomSnackbar(
        'Error',
        'Product not available right now. Check your connection or Play Store setup.',
      );
      return;
    }
    final ProductDetails productDetails = products.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (_isMockMode) {
      showCustomSnackbar('Success', 'Mock restore complete.');
      _verifyAndDeliverProduct(null);
      return;
    }
    await _inAppPurchase.restorePurchases();
    showCustomSnackbar('Success', 'Purchase restore requested.');
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) => _instance = value;
  static InAppPurchase get instance => _instance ??= InAppPurchase.instance;
}
