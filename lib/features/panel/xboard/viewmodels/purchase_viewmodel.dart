import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/models/payment_method.dart';
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/services/purchase_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';

class PurchaseViewModel extends ChangeNotifier {
  final PurchaseService _purchaseService;
  List<Plan> _plans = [];
  String? _errorMessage;
  bool _isLoading = false;
  int select = -1;
  double? selectedPrice;
  String? selectedPeriod;
  List<PaymentMethod> paymentMethods = [];
  int method = 0;

  List<Plan> get plans => _plans;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  PurchaseViewModel({required PurchaseService purchaseService})
      : _purchaseService = purchaseService;

  // 每次调用时都重新加载数据
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    Future<void> loadOnce() async {
      _plans = await _purchaseService.fetchPlanData();
    }

    try {
      await loadOnce();
    } catch (e) {
      // 第一次失败时重试一次
      try {
        Timer(Duration(seconds: 1), () async {
          await loadOnce();
        });
      } catch (e2) {
        _errorMessage = e2.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedPrice(double? price, String? period) {
    selectedPrice = price;
    selectedPeriod = period;
    notifyListeners();
  }

  Future<void> fetchPaymentMethods() async {
    final accessToken = await getToken(); // 获取用户的token
    if (accessToken == null) return;

    Future<void> loadOnce() async {
      paymentMethods = await _purchaseService.getPaymentMethods(accessToken);
    }

    try {
      await loadOnce();
    } catch (_) {
      // 第一次失败时重试一次，如果仍然失败则放弃
      try {
        await loadOnce();
      } catch (_) {}
    }
  }
}
