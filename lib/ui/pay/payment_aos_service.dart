import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_inapp01.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2023.06
/// Android 결제 MethodChannel 을 이용한 연동
class PaymentAosService {
  static const String TAG = "[PaymentAosService] ";
  static PaymentAosService? _instance;
  factory PaymentAosService() => _instance ?? PaymentAosService._internal();

  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  //명명된 생성자 (private 으로 명명된 생성자)
  PaymentAosService._internal() {
    DLog.d(TAG, "PaymentAosService._internal()");
    _instance = this;
    _loadPrefData();
  }

  late SharedPreferences _prefs;
  String _pdId = '';

  /// logged in user's premium status
  bool _isProUser = false;

  bool get isProUser => _isProUser;
  String _userId = '';


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
          'ios.ac_pr.at2'
        ];

  /// 사용자가 앱을 닫을 때 호출
  void dispose() {
  }

  // TODO  이벤트 참여 사용자가 할인 상품 결제 할 경우 테스트
  // ?? 현재의 연결 상태 리턴
  // 3.사용 가능한 상품 요청
  // 4.상품 구매 요청

  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    DLog.d(PaymentAosService.TAG, '_loadPrefData() id : $_userId');
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    DLog.d(PaymentAosService.TAG, '_loadPrefData() id : $_userId');

    _initConnection();
    _setChannelListener();
  }

  /// 앱 시작시 호출하여 연결을 초기화 (유료 결제 고객이 아닐 경우 / 결제 시도 후 승인이 완료 되지 않은 경우)
  /// 과금 서버와 필요한 모든 데이터 가져오기
  void _initConnection() async {
    if(Platform.isAndroid) {
      DLog.d(PaymentAosService.TAG, 'InApp Init Connection');

      try {
        final String result = await channel.invokeMethod('initBillingClient');
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
  }

  /// 채널 리스너
  void _setChannelListener() async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'billing_ok') {
        String data = call.arguments;
        _handleBillingResponse(data);
        return "데이터 전달 완료"; // 데이터 처리 결과를 Android로 전달
      }
      else if (call.method == 'billing_response') {
        String data = call.arguments;
        _handleStoreCode(data);
        return "데이터 전달 완료"; // 데이터 처리 결과를 Android로 전달
      }
      else if (call.method == 'getFormatedPrice') {
        String data = call.arguments;
        // 전달받은 데이터 처리
        DLog.d(PaymentAosService.TAG, '# 상품정보 가격정보 => $data');
        return "데이터 전달 완료"; // 데이터 처리 결과를 Android로 전달
      }
      else if (call.method == 'getFormatedPrice') {
        String data = call.arguments;
        // 전달받은 데이터 처리
        DLog.d(PaymentAosService.TAG, '# 상품정보 가격정보 => $data');
        return "데이터 전달 완료"; // 데이터 처리 결과를 Android로 전달
      }

      //TODO 이부분은 꼭 필요한 것인지??
      throw MissingPluginException();
    });
  }


  // 앱의 view는 사용자의 프리미엄 상태가 변경될 때 알림을 받기 위해 이것을 구독
  final ObserverList<Function> _proStatusChangedListeners = ObserverList<Function(String)>();

  // 앱의 view는 구매의 오류를 얻기 위해 이것을 구독
  final ObserverList<Function> _errorListeners = ObserverList<Function(String)>();

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

  /// 구글플레이 결제 요청에 대한 승인 처리
  void _handleBillingResponse(String data) {
    DLog.d(PaymentAosService.TAG, '# 빌링_handleBillingResponse => $data');

    if(data != null) {
      Map<String, dynamic> json = jsonDecode(data);
      String productId = json['productId'];
      String orderId = json['orderId'];
      String purchaseToken = json['purchaseToken'];
      String isAutoPay = json['isAutoPay'];
      String paymentAmt = json['paymentAmt'];
      String currency = json['currency'];
      String inappMsg = json['inappMsg'];

      requestAosInApp01(productId, orderId, purchaseToken, isAutoPay, paymentAmt, currency, inappMsg);

      // Future.delayed(const Duration(seconds: 5), () {
      //   requestAosInApp01(productId, orderId, purchaseToken, isAutoPay, paymentAmt, currency, inappMsg);
      // });
    }
  }

  // error 코드에 따르는 에러 처리
  void _handleStoreCode(String data) {
    DLog.d(PaymentAosService.TAG, '# 빌링_handleStoreCode => $data');

    if(data != null) {
      Map<String, dynamic> json = jsonDecode(data);
      int resCode = json['res_code'];
      String strCode = json['str_code'];
      String codeMsg = json['code_msg'];
      String message = json['comment'];
      String storeStatus = json['store_status'];

      if (strCode == 'USER_CANCELED') {
        DLog.d(PaymentAosService.TAG, '# 빌링_사용자_취소');
        //사용자 취소일 경우 아무것도 안함
        commonShowToast('구매를 취소하셨습니다.');
        _callProStatusChangedListeners('md_exit');
      } else {
        _callErrorListeners(message);
      }
    }
  }

  // error 코드에 따르는 에러 처리
/*  void _handlePurchaseError(PurchaseResult purchaseError) {
    DLog.d(TAG, 'errCode : ${purchaseError.code}');
    DLog.d(TAG, 'resCode : ${purchaseError.responseCode}');

    if (purchaseError.code == 'E_USER_CANCELLED') {
      //사용자 취소일 경우 아무것도 안함
      commonShowToast('구매를 취소하셨습니다.');
      _callProStatusChangedListeners('md_exit');
    } else {
      _callErrorListeners(purchaseError.message);
    }
  }*/

  //구글플레이 상품 구매 요청
  void requestGStorePurchase(String pdCode) async {
    DLog.d(PaymentAosService.TAG, '# 상품구매요청 -> ${pdCode} |');

    _userId = AppGlobal().userId;
    _prefs.setBool(Const.PREFS_PAY_FINISHED, false);

    if(Platform.isAndroid) {
      DLog.d(PaymentAosService.TAG, '# 상품구매요청 -> channel');

      try {
        final String result = await channel.invokeMethod('startBillingProcess', {'pd_code': pdCode});
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
  }

  //구글플레이 상품 업그레이드 요청
  void requestGStoreUpgrade(String pdCode) async {
    DLog.d(PaymentAosService.TAG, '# 상품업그레이드요청 -> ${pdCode} |');

    _userId = AppGlobal().userId;
    _prefs.setBool(Const.PREFS_PAY_FINISHED, false);

    if(Platform.isAndroid) {
      DLog.d(PaymentAosService.TAG, '# 상품업그레이드요청 -> channel');

      try {
        final String result = await channel.invokeMethod('startBillingUpgrade', {'pd_code': pdCode});
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
  }

  //구매목록 처리
  void requestPurchaseAsync() async {
    if(Platform.isAndroid) {
      DLog.d(PaymentAosService.TAG, '# requestPurchaseAsync 요청 -> channel');

      try {
        await channel.invokeMethod('requestPurchasesAsync');
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
  }

  //구매 내역 가져오기 (TODO 결제는 되었지만 완전하게 finishTranscation 되지 않은 경우를 찾아서 finish)
  Future getPurchaseHistory() async {
    // List<PurchasedItem> items =
    // await FlutterInappPurchase.instance.getPurchaseHistory();
    // for (var item in items) {
    //   if (item.transactionStateIOS == TransactionState.purchased) {
    //     DLog.d(
    //         TAG,
    //         '\n${item.productId}\n'
    //             '${item.transactionId}\n'
    //             '${item.transactionDate}\n'
    //             '${item.originalTransactionIdentifierIOS}\n'
    //             '${item.transactionStateIOS}\n');
    //     _purchases.add(item);
    //   }
    // }
    //
    // if (_purchases.length > 0) {
    //   _purchasedTrId = _purchases[0].transactionId;
    //   requestInApp01(_purchases[0]);
    // } else {
    //   _prefs.setBool(Const.PREFS_PAY_FINISHED, true); //결제 완료상태
    //   _purchases.clear();
    //   _purchasedTrId = '';
    // }
  }

  // 결제 완료 고객 5년간 휴면회원 전환 방지
  void _requestThink() async {
    String param = 'userid=${Net.getEncrypt(_userId)}&gb=settle';
    DLog.d(TAG, 'param : $param');

    String nUrl = Net.THINK_CHECK_DAILY; //로그인/결제 휴면 방지
    var url = Uri.parse(nUrl);
    final http.Response response = await http.post(
      url,
      body: param,
      headers: Net.think_headers,
    );

    DLog.d(TAG, '씽크풀API: ${response.statusCode}');
    DLog.d(TAG, response.body);
  }

  //구매확인(구매승인 절차) - 영수증 검증 요청
  void requestAosInApp01(String pdCode, String orderId, String purchaseToken,
      String isSubs, String price, String currencyCode, String logMsg) {

    DLog.d(TAG, '# requestInApp01 ->');
    _pdId = pdCode;

    _fetchPosts(TR.INAPP01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'prodCode': pdCode,
          'productId': pdCode,
          'orderId': orderId,
          'purchaseToken': purchaseToken,
          'isAutoPay': isSubs,
          'paymentAmt': price,
          'currency': currencyCode,
          'svcDiv': Const.isDebuggable ? 'T' : 'S',
          'inappMsg': logMsg,
        }));
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PaymentAosService.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  //
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PaymentAosService.TAG, response.body);
    _callProStatusChangedListeners('md_exit');

    if (trStr == TR.INAPP01) {
      final TrInApp01 resData = TrInApp01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //단건 결제일 경우 소비 요청
        if(_pdId == 'ac_pr.m01') requestPurchaseAsync();

        //결제 검증 완료
        _prefs.setBool(Const.PREFS_PAY_FINISHED, true); //결제 완료상태
        _requestThink();

        _prefs.setString(Const.PREFS_CUR_PROD, _pdId); //사용중 상품코드 등록
        _callProStatusChangedListeners('pay_success');
      }
      //만료된 영수증
      else if (resData.retCode == 'I003') {
        DLog.d(TAG, '만료된 영수증');
        _callErrorListeners('이전에 만료된 영수증 데이터입니다.\n잠시후 다시 시도해주세요.');
      }
      //결제 승인 실패
      else {
        DLog.d(TAG, '결제 승인 실패');
        _callErrorListeners('결제 영수증 검증이 실패했습니다.\n잠시후 다시 시도해주세요.');
      }

      //중간값 초기화 정리
      _pdId = '';
      // _purchases.clear();
    }
  }

}
