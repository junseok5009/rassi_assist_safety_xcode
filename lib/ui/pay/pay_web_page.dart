import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_pay.dart';


/// 2021.09.24
/// 결제 웹 페이지
class PayWebPage extends StatelessWidget {
  static const routeName = '/page_pay_web';
  static const String TAG = "[PayWebPage]";
  static const String TAG_NAME = '결제웹뷰';

  const PayWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const PayWebWidget(),
      ),
    );
  }
}

class PayWebWidget extends StatefulWidget {
  const PayWebWidget({super.key});

  @override
  State<StatefulWidget> createState() => PayWebState();
}

class PayWebState extends State<PayWebWidget> {
  var appGlobal = AppGlobal();

  late PgPay args;
  String _userId = '';

  String PAY_BASE_URL = '';
  String _cst_platform = 'test';
  String _payType = '';
  String _pdCode = '';
  String _pdSubDiv = '';
  String _payAmount = '';
  String _orderSn = '';
  String _lgTid = '';
  String _lgCancelAmt = '';

  String _sUrl = Net.TR_BASE_PAY_DEV;
  String _baseUrl = '';
  String _postData = '';

  late InAppWebViewController _webViewController;
  final InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));


  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: PayWebPage.TAG_NAME,
      screenClassOverride: PayWebPage.TAG_NAME,);

    _userId = appGlobal.userId;
    _payType = appGlobal.payType;
    _pdCode = appGlobal.pdCode;
    _pdSubDiv = appGlobal.pdSubDiv;
    _payAmount = appGlobal.payAmount;
    _orderSn = appGlobal.orderSn;
    _lgTid = appGlobal.lgTid;
    _lgCancelAmt = appGlobal.lgCancelAmt;
    _setPostData(_payType);
  }

  _setPostData(String type) {
    if(Const.isDebuggable) {
      _cst_platform = 'test';
      _baseUrl = Net.TR_BASE_PAY_DEV;
    }
    else {
      _cst_platform = 'service';
      _baseUrl = Net.TR_BASE_PAY;
    }

    //단건 결제
    if(type == 'default') {
      _sUrl = _baseUrl + Net.TR_PAY_SINGLE;
      _postData =
          'CST_PLATFORM=$_cst_platform&USER_ID=$_userId&PROD_CODE=$_pdCode&PROD_SUBDIV=$_pdSubDiv&PAY_AMOUNT=$_payAmount&ORDER_CHAN=CH20';
    }
    //정기 결제
    else if(type == 'auto') {
      _sUrl = _baseUrl + Net.TR_PAY_SUB;
      _postData =
          'CST_PLATFORM=$_cst_platform&USER_ID=$_userId&PROD_CODE=$_pdCode&PROD_SUBDIV=$_pdSubDiv&PAY_AMOUNT=$_payAmount&ORDER_CHAN=CH20';
    }
    //취소 / 환불
    else if(type == 'close') {
      _sUrl = _baseUrl + Net.TR_PAY_CANCEL;
      _postData =
          'CST_PLATFORM=$_cst_platform&USER_ID=$_userId&ORDER_SN=$_orderSn&LGD_CANCELAMOUNT=$_lgCancelAmt&LGD_TID=$_lgTid&SVC_KEEP_YN=Y&NEXT_PAY_YN=N&APP_ENV=EN20';       //iOS 환경
    }
    DLog.d(PayWebPage.TAG, 'URL : ' + _sUrl);
    DLog.d(PayWebPage.TAG, 'PARAM : ' + _postData);
    _clearGlobalData();
  }

  void _clearGlobalData() {
    appGlobal.payType = '';
    appGlobal.pdCode = '';
    appGlobal.pdSubDiv = '';
    appGlobal.payAmount = '';
    appGlobal.orderSn = '';
    appGlobal.lgTid = '';
    appGlobal.lgCancelAmt = '';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop('cancel'),),
          const SizedBox(width: 10.0,),
        ],
      ),

      body: SafeArea(
        child: InAppWebView(
          initialOptions: _options,

          initialUrlRequest: URLRequest(
            url: Uri.parse(_sUrl),
            method: 'POST',
            body: Uint8List.fromList(utf8.encode(_postData)),
            headers: Net.think_headers,
          ),

          //js 에서 goPayPage 함수를 호출 했을 경우
          onWebViewCreated: (InAppWebViewController controller){
            controller.addJavaScriptHandler(handlerName: "goPayPage", callback: (res) {
              DLog.d(PayWebPage.TAG, '## goPayPage : ' + res.toString());
              if(res != null && res.length > 0) {
                parseResData(res[0]);
              }

              // return data to the JavaScript side!
              return {
                'aaa': 'bbb', 'ccc': 'ddd'
              };
            });

            controller.addJavaScriptHandler(handlerName: "showAppToast", callback: (args) {
              Fluttertoast.showToast(
                msg: 'toast message',
                toastLength: Toast.LENGTH_LONG,
              );
            });
          },
          // onLoadStart: (InAppWebViewController controller, Uri uri){
          //   DLog.d(PayWebPage.TAG, 'URI : ' + uri.toString());
          // },
          // onLoadStop: (InAppWebViewController controller, Uri uri){
          // },
          onJsAlert: (InAppWebViewController controller, JsAlertRequest request) async {
            DLog.d(PayWebPage.TAG, 'onJsAlert : ');
            //추후 메시지 보여주고 확인버튼 누를때 result.confirm() 웹페이지도 적용
            return JsAlertResponse();
          },
          onJsConfirm: (InAppWebViewController controller, JsConfirmRequest request) async {
            DLog.d(PayWebPage.TAG, 'onJsConfirm : ');
            //추후 메시지 보여주고 확인버튼 누를때 result.confirm() / 취소버튼은 result.cancel()
            return JsConfirmResponse();
          },
          onConsoleMessage: (InAppWebViewController controller, ConsoleMessage message){
            DLog.d(PayWebPage.TAG, 'Console message : ${message.message}');
          },
        ),
      ),
    );
  }

  void parseResData(String json) {
    Map<String, dynamic> item = jsonDecode(json);
    if(item['RESULT_CODE'] == '0000') {
      //결제 완료 or 환불 완료
      Navigator.of(context).pop('success');
    } else {
      //결제 오류 or 환불 오류
      Navigator.of(context).pop('fail');
    }
  }

}