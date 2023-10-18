import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/tr_inapp01.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2022.05.04
/// 백그라운드 처리 테스트
class TestService {
  static late TestService _instance;
  factory TestService() => _instance ?? TestService._internal();

  //명명된 생성자 (private 으로 명명된 생성자)
  TestService._internal() {
    _instance = this;
    DLog.d("TestService", "### TestService Create~~");
    _loadPrefData();
  }


  static const String TAG = "[TestService]";
  late SharedPreferences _prefs;

  bool _isProUser = false;
  bool get isProUser => _isProUser;

  String _userId = '';
  setUserId(String id) {
    _userId = id;
  }

  late StreamSubscription<PurchasedItem>? _purchaseUpdatedSubscription;

  // 앱의 view는 사용자의 프리미엄 상태가 변경될 때 알림을 받기 위해 이것을 구독
  final ObserverList<Function> _statusChangedListeners = ObserverList<Function(String)>();


  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    DLog.d(TAG, '_loadPrefData ');
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';

    initConnection();
  }

  void initConnection() async {
    DLog.d(TAG, 'userId : $_userId');
    // _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

    _callProStatusChangedListeners();
  }

  /// 사용자가 앱을 닫을 때 호출
  void dispose() {
    DLog.d(TAG, 'dispose ');
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription?.cancel();
      _purchaseUpdatedSubscription = null;
    }
  }


  // view 는 이 방법을 사용하여 _statusChangedListeners를 구독할 수 있습니다.
  addToStatusChangedListeners(Function callback) {
    _statusChangedListeners.add(callback);
  }
  // view는 이 방법을 사용하여 _statusChangedListeners로 취소할 수 있습니다.
  removeFromStatusChangedListeners(Function callback) {
    _statusChangedListeners.remove(callback);
  }


  // _proStatusChangedListeners의 모든 하위 구독자에게 알리려면 이 메서드를 호출하세요.
  void _callProStatusChangedListeners() {
    _statusChangedListeners.forEach((Function callback) {
      callback('ReAction');
    });
  }



}