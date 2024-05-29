import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_inapp01.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2022.04.20
/// https://ichi.pro/ko/fluttereseo-gudog-in-aeb-gumaeleul-guhyeonhaneun-bangbeob-137338297409674
/// 결제를 모듈 이용하기 위한 방법
class PaymentService {
  static const String TAG = "[PaymentService] ";
  static PaymentService? _instance;

  factory PaymentService() => _instance ?? PaymentService._internal();

  //명명된 생성자 (private 으로 명명된 생성자)
  PaymentService._internal() {
    DLog.d(TAG, "PaymentService._internal()");
    _instance = this;
    _loadPrefData();
  }

  late SharedPreferences _prefs;
  String _pdId = '';
  String _purchasedTrId = '';

  /// logged in user's premium status
  bool _isProUser = false;

  bool get isProUser => _isProUser;
  String _userId = '';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // 가져오려는 제품 ID 목록
  final List<String> _productIds = Platform.isAndroid
      ? [
          'ac_pr.a01',
          'ac_pr.m01',
        ]
      : [
          'ios.ac_pr.a01',
          'ios.ac_pr.m01',
          'ios.ac_pr.ad5',
          'ios.ac_pr.ad4',
          'ios.ac_pr.ad3',
          'ios.ac_pr.at1',
          'ios.ac_pr.at2',
          'ios.ac_pr.am6d0',
          'ios.ac_pr.am6d5',
        ];

  StreamSubscription<ConnectionResult>? _connectionSubscription;
  StreamSubscription<PurchasedItem?>? _purchaseUpdatedSubscription;
  StreamSubscription<PurchaseResult?>? _purchaseErrorSubscription;

  // 사용 가능한 모든 제품 목록
  List<IAPItem> _products = [];

  // 결제가 일어난 구매목록
  final List<PurchasedItem> _purchases = [];

  // 모든 과거 구매 목록
  List<PurchasedItem> _pastPurchases = [];

  // 앱의 view는 사용자의 프리미엄 상태가 변경될 때 알림을 받기 위해 이것을 구독
  final ObserverList<Function> _proStatusChangedListeners = ObserverList<Function(String)>();

  // 앱의 view는 구매의 오류를 얻기 위해 이것을 구독
  final ObserverList<Function> _errorListeners = ObserverList<Function(String)>();

  // TODO  이벤트 참여 사용자가 할인 상품 결제 할 경우 테스트
  // ?? 현재의 연결 상태 리턴
  // 3.사용 가능한 상품 요청
  // 4.상품 구매 요청

  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    DLog.d(PaymentService.TAG, '_loadPrefData() id : $_userId');
    DLog.d(PaymentService.TAG, '_loadPrefData() id : $_userId');
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    DLog.d(PaymentService.TAG, '_loadPrefData() id : $_userId');
    DLog.d(PaymentService.TAG, '_loadPrefData() id : $_userId');
    _initConnection();
  }

  /// 앱 시작시 호출하여 연결을 초기화
  /// 과금 서버와 필요한 모든 데이터 가져오기
  void _initConnection() async {
    var result = await FlutterInappPurchase.instance.initialize();
    _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      DLog.d(PaymentService.TAG, '[store connected]: $connected');
    });

    /// 새 업데이트가 ``purchaseUpdated`` 스트림에 도착하면 호출됩니다.
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((PurchasedItem? event) {
      DLog.d(PaymentService.TAG, '[purchaseUpdated 리스너]:');
      if (event != null) {
        if (Platform.isAndroid) {
          _handlePurchaseUpdateAndroid(event);
        } else {
          _handlePurchaseUpdateIOS(event);
        }
      }
    });

    /// 에러 코드에 따르는 에러 처리
    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((PurchaseResult? purchaseError) {
      DLog.d(PaymentService.TAG, '[purchaseError 리스너]:');
      DLog.d(TAG, 'errCode : ${purchaseError?.code}');
      DLog.d(TAG, 'resCode : ${purchaseError?.responseCode}');
      if (purchaseError?.code == 'E_USER_CANCELLED') {
        //사용자 취소일 경우 아무것도 안함
        commonShowToast('구매를 취소하셨습니다.');
        _callProStatusChangedListeners('md_exit');
      } else {
        String? msg = purchaseError?.message;
        if (msg != null) {
          _callErrorListeners(msg);
        }
      }
    });

    DLog.d(PaymentService.TAG, 'Connection result: $result');
    DLog.d(PaymentService.TAG, 'InApp Init Connection');

    _getItems();
  }

  /// 사용자가 앱을 닫을 때 호출
  void dispose() {
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription?.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription?.cancel();
      _purchaseErrorSubscription = null;
    }
    if (_connectionSubscription != null) {
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
    }
    FlutterInappPurchase.instance.finalize();
  }

  // view 는 이 방법을 사용하여 _proStatusChangedListeners를 구독할 수 있습니다.
  addToProStatusChangedListeners(Function callback) {
    _proStatusChangedListeners.add(callback);
  }

  // view는 이 방법을 사용하여 _proStatusChangedListeners로 취소할 수 있습니다.
  removeFromProStatusChangedListeners(Function callback) {
    _proStatusChangedListeners.remove(callback);
  }

  // view는 이 방법을 사용하여 _errorListeners를 구독할 수 있습니다.
  addToErrorListeners(Function callback) {
    _errorListeners.add(callback);
  }

  // view는 이 방법을 사용하여 _errorListeners로 취소할 수 있습니다.
  removeFromErrorListeners(Function callback) {
    _errorListeners.remove(callback);
  }

  // _proStatusChangedListeners의 모든 하위 구독자에게 알리려면 이 메서드를 호출하세요.
  void _callProStatusChangedListeners(String status) {
    _proStatusChangedListeners.forEach((Function callback) {
      callback(status);
    });
  }

  // _errorListeners의 모든 하위 구독자에게 알리려면 이 메서드를 호출하세요.
  void _callErrorListeners(String error) {
    _errorListeners.forEach((Function callback) {
      callback(error);
    });
  }

  //프로모션 코드 입력시트
  void showRedemptionSheet() {
    _prefs.setBool(Const.PREFS_PAY_FINISHED, false);
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
        _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    iosPlatformAddition.presentCodeRedemptionSheet();
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
    DLog.d(TAG, '### transactionState Update ### ${purchasedItem.transactionStateIOS.toString()}');
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.purchased:
        //프로그래스 false
        if (Const.isDebuggable) commonShowToast('### transactionState purchased ###');
        await _verifyAndFinishTransaction(purchasedItem);
        break;

      case TransactionState.purchasing:
        break;

      case TransactionState.restored:
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;

      case TransactionState.failed:
        _callErrorListeners("Transaction Failed");
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;

      case TransactionState.deferred:
        // Edit: This was a bug that was pointed out here
        // : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
        // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;

      default:
    }
  }

  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
    // 추후 안드로이드 까지 연동
  }

  /// 구매 상태가 성공일 때 이 메소드 호출
  /// 백엔드의 API를 호출하여 수신 확인 - 백엔드는 구매 토큰을 확인하기 위해 결제 서버의 API를 호출
  _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    try {
      requestInApp01(purchasedItem);
    } on Exception {
      _callErrorListeners("Something went wrong");
      return;
    }
  }

  // 스토어 상품 목록 요청
  Future<List<IAPItem>> get products async {
    if (_products == null) {
      await _getItems();
    }
    return _products;
  }

  // 스토어 상품 목록
  Future<void> _getItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(_productIds);
    _products = [];
    for (var item in items) {
      DLog.d(TAG, '# Store Item : ${item.productId}');
      _products.add(item);
    }
  }

  //앱스토어 상품 구매 요청
  Future<dynamic> requestStorePurchase(IAPItem item) async {
    DLog.d(PaymentService.TAG, '# 상품구매요청 -> ${item.productId} | ${item.price} |');

    _userId = AppGlobal().userId;
    await _prefs.setBool(Const.PREFS_PAY_FINISHED, false);

    DLog.d(TAG, 'ㅡㅡㅡㅡㅡ requestStorePurchase ㅡㅡㅡㅡㅡ');
    DLog.d(TAG, '|    userId : $_userId    |');
    DLog.d(TAG, '|    <공통>    |');
    DLog.d(TAG, '|    price : ${item.price}    |');
    DLog.d(TAG, '|    currency : ${item.currency}    |');
    DLog.d(TAG, '|    localizedPrice : ${item.localizedPrice}    |');
    DLog.d(TAG, '|    title : ${item.title}    |');
    DLog.d(TAG, '|    introductoryPrice : ${item.introductoryPrice}    |\n');
    DLog.d(TAG, '|    <ONLY IOS>    |');
    DLog.d(TAG, '|    subscriptionPeriodNumberIOS : ${item.subscriptionPeriodNumberIOS}    |');
    DLog.d(TAG, '|    subscriptionPeriodUnitIOS : ${item.subscriptionPeriodUnitIOS}    |');
    DLog.d(TAG, '|    introductoryPriceNumberIOS : ${item.introductoryPriceNumberIOS}    |');
    DLog.d(TAG, '|    introductoryPricePaymentModeIOS : ${item.introductoryPricePaymentModeIOS}    |');
    DLog.d(TAG, '|    introductoryPriceNumberOfPeriodsIOS : ${item.introductoryPriceNumberOfPeriodsIOS}    |');
    DLog.d(TAG, '|    introductoryPriceSubscriptionPeriodIOS : ${item.introductoryPriceSubscriptionPeriodIOS}    |');
    DLog.d(TAG, '|    discountsIOS : ${item.discountsIOS}    |');
    DLog.d(TAG, 'ㅡㅡㅡㅡㅡ requestStorePurchase ㅡㅡㅡㅡㅡ');

    var lggingInApp01Json = jsonEncode(<String, String>{
      'userId': _userId,
      'svcDiv': Const.isDebuggable ? 'T' : 'S',
      'paymentAmt': _getPaymentAmount(item.productId!) ?? '',
      'currency': _getPaymentCurrency(item.productId!) ?? '',
      'productId': item.productId ?? '',
      //'orgOrderId': item.originalTransactionIdentifierIOS ?? '',
      //'orderId': item.transactionId ?? '',
      //'purchaseToken': item.transactionReceipt ?? '',
      'inappMsg': 'ios_purchase_msg',
    });
    DLog.e('[PaymentService] lggingInApp01Json : ${lggingInApp01Json.toString()}');

    return await FlutterInappPurchase.instance.requestPurchase(item.productId ?? '');
  }

  //구매 내역 가져오기 (결제는 되었지만 완전하게 finishTranscation 되지 않은 경우를 찾아서 finish)
  Future getPurchaseHistory() async {
    List<PurchasedItem>? items = await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items ?? []) {
      if (item.transactionStateIOS == TransactionState.purchased) {
        DLog.d(
            TAG,
            '\n${item.productId}\n'
            '${item.transactionId}\n'
            '${item.transactionDate}\n'
            '${item.originalTransactionIdentifierIOS}\n'
            '${item.transactionStateIOS}\n');
        _purchases.add(item);
      }
    }

    if (_purchases.length > 0) {
      _purchasedTrId = _purchases[0].transactionId!;
      requestInApp01(_purchases[0]);
    } else {
      _prefs.setBool(Const.PREFS_PAY_FINISHED, true); //결제 완료상태
      _purchases.clear();
      _purchasedTrId = '';
    }
  }

  //구매목록 처리
  void requestPurchaseAsync() async {
    if (Platform.isAndroid) {}
  }

  // 결제 완료 고객 5년간 휴면회원 전환 방지
  void _requestThink() async {
    String param = "userid=" + Net.getEncrypt(_userId) + '&gb=settle';
    DLog.d(TAG, 'param : $param');

    String nUrl = Net.THINK_CHECK_DAILY; //로그인/결제 휴면 방지
    var url = Uri.parse(nUrl);
    final http.Response response = await http.post(
      url,
      body: param,
      headers: Net.think_headers,
    );

    DLog.d(TAG, '${response.statusCode}');
    DLog.d(TAG, response.body);
  }

  //구매확인(구매승인 절차) - 영수증 검증 요청
  void requestInApp01(PurchasedItem purchasedItem) {
    DLog.d(
        TAG,
        '# requestInApp01 ->'
        ' ${purchasedItem.productId} |'
        ' ${purchasedItem.transactionId} |'
        ' _getPaymentAmount : ${_getPaymentAmount(purchasedItem.productId!)} |'
        ' ${_getPaymentCurrency(purchasedItem.productId!)}');

    _pdId = purchasedItem.productId ?? '';
    _purchasedTrId = purchasedItem.transactionId ?? '';

    _fetchPosts(
        TR.INAPP01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'svcDiv': Const.isDebuggable ? 'T' : 'S',
          'paymentAmt': _getPaymentAmount(purchasedItem.productId!) ?? '',
          'currency': _getPaymentCurrency(purchasedItem.productId!) ?? '',
          'productId': purchasedItem.productId ?? '',
          'orgOrderId': purchasedItem.originalTransactionIdentifierIOS ?? '',
          'orderId': purchasedItem.transactionId ?? '',
          'purchaseToken': purchasedItem.transactionReceipt ?? '',
          'inappMsg': 'ios_purchase_msg',
        }));
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PaymentService.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PaymentService.TAG, response.body);
    _callProStatusChangedListeners('md_exit');

    if (trStr == TR.INAPP01) {
      final TrInApp01 resData = TrInApp01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //결제 검증 완료
        if (_purchasedTrId.isNotEmpty) {
          _finishTransaction(_purchasedTrId);
          _prefs.setBool(Const.PREFS_PAY_FINISHED, true); //결제 완료상태
          _requestThink();

          _prefs.setString(Const.PREFS_CUR_PROD, _pdId); //사용중 상품코드 등록
          _callProStatusChangedListeners('pay_success');
          _purchasedTrId = '';
        }
      }
      //만료된 영수증
      else if (resData.retCode == 'I003') {
        if (_purchasedTrId.isNotEmpty) {
          _finishTransaction(_purchasedTrId);
          DLog.d(TAG, '만료된 영수증');
          _callErrorListeners('이전에 만료된 영수증 데이터입니다.\n잠시후 다시 시도해주세요.');
          _purchasedTrId = '';
        }
      }
      //결제 승인 실패
      else {
        DLog.d(TAG, '결제 승인 실패');
        _callErrorListeners('결제 영수증 검증이 실패했습니다.\n잠시후 다시 시도해주세요.');
        _purchasedTrId = '';
      }

      //중간값 초기화 정리
      _pdId = '';
      _purchases.clear();
    }
  }

  void _finishTransaction(String transactionId) {
    DLog.d(TAG, '# finishTransaction -> $transactionId');
    FlutterInappPurchase.instance.finishTransactionIOS(transactionId);
  }

  //상품금액 리턴
  String? _getPaymentAmount(String prodId) {
    for (IAPItem item in _products) {
      if (item.productId == prodId) {
        if (item.introductoryPrice!.isEmpty) {
          DLog.d(PaymentService.TAG, 'introductoryPrice.isEmpty');
          DLog.d(PaymentService.TAG, '${item.productId} / ${item.price}');
          return item.price;
        } else {
          DLog.d(PaymentService.TAG, 'introductoryPrice.isNotEmpty');
          DLog.e(
              'item.introductoryPriceNumberOfPeriodsIOS.isEmpty : ${(item.introductoryPriceNumberOfPeriodsIOS?.isEmpty ?? true)} / '
              'AppGlobal().isAlreadyPromotionProductPayUser : ${AppGlobal().isAlreadyPromotionProductPayUser}');
          if ((item.introductoryPriceNumberOfPeriodsIOS?.isEmpty ?? true) ||
              AppGlobal().isAlreadyPromotionProductPayUser) {
            return item.price;
          } else {
            int integerIntroductoryPriceNumberOfPeriodsIOS =
                int.parse((item.introductoryPriceNumberOfPeriodsIOS ?? '0'));
            if (integerIntroductoryPriceNumberOfPeriodsIOS > 1) {
              return '0';
            } else {
              String str = item.introductoryPrice ?? '0';
              String intStr = str.replaceAll(RegExp('[^0-9.]+'), '');
              DLog.d(PaymentService.TAG, '${item.productId} / ${item.price} / $intStr');
              return intStr;
            }
          }
        }
      }
    }
    DLog.e('[${PaymentService.TAG} item.productId != prodId >>> prodId : ${prodId} / ');
    return '';
  }

  //통화코드 리턴
  String _getPaymentCurrency(String prodId) {
    for (IAPItem item in _products) {
      if (item.productId == prodId) return item.currency ?? '';
    }
    return '';
  }

  // iOS에서 이 메서드는 과거에 구매한 모든 항목을 반환합니다 (완료된 경우만). (사용안함)
  // iOS에서 이 방법의 또 다른 용도는 사용자가 장치를 변경하고 사용자가 구매를 복원하도록 허용한 다음
  // 이 메서드를 호출하는 것입니다. Android에서 이 메서드는 활성 구독만 반환합니다 (완료 및 완료되지 않은 둘 다).
  void _getPastPurchases() async {
    // iOS에서 과거 구매를 복원하려면 이것을 제거하십시오.
    if (Platform.isIOS) {
      return;
    }
    List<PurchasedItem>? purchasedItems = await FlutterInappPurchase.instance.getAvailablePurchases();

    _pastPurchases = [];
    _pastPurchases.addAll(purchasedItems ?? []);
  }
}
