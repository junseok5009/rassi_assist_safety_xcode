import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_app/tr_app03.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/custom_firebase_class.dart';
import '../../models/none_tr/app_global.dart';
import '../../models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';

/// 2020.12.17
/// 3종목 알림 결제 (현재는 AOS만 가능한 상품)
class PayThreeStock extends StatefulWidget {
  static const routeName = '/page_pay_three';
  static const String TAG = "[PayThreeStock]";
  static const String TAG_NAME = '3종목알림_결제';

  const PayThreeStock({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PayThreeState();
}

class PayThreeState extends State<PayThreeStock> {
  var appGlobal = AppGlobal();
  var inAppBilling = PaymentAosService();
  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  late SharedPreferences _prefs;
  String _userId = "";
  String _curProd = ''; //현재 사용중인 상품은

  bool statusCon = false; //결제모듈 연결상태

  final List<String> _productLists = Platform.isAndroid
      ? [
          'ac_s3.a01',
        ]
      : [
          'ios.ac_s3.a01',
        ];

  late IAPItem _pdItemSub;
  String _priceSub = '';
  bool _isPaymentSub = true; //구독결제이면 true
  bool _isTryPayment = false; //결제버튼을 눌렀다면 화면이 닫히고 화면갱신 (true 일때 화면 갱신)
  bool _bProgress = false;

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 23.10.11 추가 구매 안내 문구 전문으로 가져오기
  final List<App03PaymentGuide> _listApp03 = [];

  // TODO 1. 이미 결제된 상품 확인 (프리미엄일 경우 결제 불가)
  // TODO 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PayThreeStock.TAG_NAME);

    _loadPrefData().then((value) {
      _initBillingState();
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _curProd = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
      if (_userId == '') {
        Navigator.pop(context);
      } else {
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //결제 동작은 비동기적 구동 초기화 작업이 필요
  Future<void> _initBillingState() async {
    //상품정보 요청
    _getProduct();

    //결제 상태 리스너
    statCallback = (status) async {
      DLog.d(PayThreeStock.TAG, '# statusCallback == $status');
      if (status == 'md_exit') {
        setState(() {
          _bProgress = false;
        });
      } else if (status == 'pay_success') {
        var userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        await userInfoProvider.updatePayment();
        if(mounted){
          Navigator.pop(context);
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
        }
      }else{
        Navigator.pop(context);
      }
    };
    inAppBilling.addToProStatusChangedListeners(statCallback);

    //결제 에러 상태 리스너
    errCallback = (retStr) async {
      await CommonPopup.instance.showDialogBasicConfirm(context, '알림', retStr);
      if(context.mounted){
        Navigator.pop(context);
      }
    };
    inAppBilling.addToErrorListeners(errCallback);
  }

  @override
  void dispose() {
    inAppBilling.removeFromProStatusChangedListeners(statCallback);
    inAppBilling.removeFromErrorListeners(errCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CommonAppbar.simpleWithExit(
          context,
          '3종목 실시간 알림 결제',
          Colors.black,
          Colors.white,
          Colors.black,
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          _setTopDesc(),
                          const SizedBox(
                            height: 10,
                          ),

                          _setBanner(),
                          const SizedBox(
                            height: 15,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            child: Text(
                              '결제 방식',
                              style: TStyle.commonTitle,
                            ),
                          ),

                          _setButtonSub(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 20,
                            ),
                            child: Text(
                              '★ 정기결제는 언제든 구독을 취소하실 수 있어요.',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          //구매안내
                          Platform.isIOS ? _setPayInfo() : _setPayInfoAOS(),

                          ////이용약관, 개인정보처리방침(ios만 표시)
                          Platform.isIOS ? _setTerms() : Container(),
                        ],
                      ),
                    ),
                    Container(
                      color: RColor.mainColor,
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          _isTryPayment = true;
                          if (_curProd.contains('ac_s3')) {
                            commonShowToast(
                                '이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
                          } else {
                            DLog.d(PayThreeStock.TAG, '프리미엄 결제 요청');
                            setState(() {
                              _bProgress = true;
                            });
                            if (Platform.isIOS) {
                              // if (_pdItemSub != null && _isPaymentSub) {
                              //   inAppBilling.requestStorePurchase(_pdItemSub);
                              // }
                            } else if (Platform.isAndroid) {
                              if (_isPaymentSub) {
                                inAppBilling
                                    .requestGStorePurchase(_productLists[0]);
                                // inAppBilling.requestGStoreUpgrade(_productLists[0]);
                              }
                            }
                          }
                        },
                        child: const Center(
                          child: Text(
                            '3종목 실시간 알림 받기 시작하기',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                //Progress
                Visibility(
                  visible: _bProgress,
                  child: const Stack(
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: ModalBarrier(
                            dismissible: false, color: Colors.grey),
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_bProgress) {
      commonShowToast('결제가 진행중입니다.');
      return Future.value(false);
    }

    Navigator.pop(context);
    return Future.value(true);
  }

  //정기 결제 버튼
  Widget _setButtonSub() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: _isPaymentSub ? RColor.mainColor : RColor.lineGrey,
            width: 0.8),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
      //EdgeInsets.symmetric(vertical: 20, horizontal: 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '매월정기결제',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            _priceSub,
            style: TStyle.title18T,
          ),
        ],
      ),
    );
  }

  //상품 소개
  Widget _setTopDesc() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            child: Text(
              '꼭 필요한 종목에 대해서는\nAI매매신호를 실시간 알림으로 받아보세요!',
              style: TStyle.title18T,
            )),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "포켓에 등록한 3종목에 대해서 AI의 실시간 매매신호를 알려 드려요. 등록된 종목은 언제든 변경이 가능합니다.",
            style: TStyle.content14,
          ),
        ),
      ],
    );
  }

  //결제 안내 - iOS
  Widget _setPayInfo() {
    return Container(
      color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "App Store 구매안내",
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 10.0,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listApp03.length,
            itemBuilder: (context, index) => Text(_listApp03[index].guideText),
          ),
          const SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  //결제 안내 - android
  Widget _setPayInfoAOS() {
    return Container(
      color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "안내",
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 10.0,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listApp03.length,
            itemBuilder: (context, index) => Text(_listApp03[index].guideText),
          ),
          const SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  Widget _setTerms() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle('이용약관 및 개인정보 취급방침'),
          const SizedBox(
            height: 10,
          ),
          _setTermsText(),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  //이용약관, 개인정보처리방침
  Widget _setTermsText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: const Text(
              '이용약관 보기',
              style: TStyle.ulTextPurple,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPage(),
                    settings: RouteSettings(
                      arguments: PgData(pgData: Net.AGREE_TERMS),
                    ),
                  ));
            },
          ),
          const SizedBox(
            height: 7,
          ),
          InkWell(
            child: const Text(
              '개인정보 처리방침 보기',
              style: TStyle.ulTextPurple,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPage(),
                    settings: RouteSettings(
                      arguments: PgData(pgData: Net.AGREE_POLICY_INFO),
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //결제 완료시에만 사용 (결제 완료/실패 알림 -> 자동 페이지 종료)
  void _showDialogMsg(String message, String btnText) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    _goPreviousPage();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    message,
                    
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        // margin: const EdgeInsets.only(top: 20.0),
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Center(
                          child: Text(
                            btnText,
                            style: TStyle.btnTextWht16,
                            
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _goPreviousPage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //상품정보 가져오기
  Future _getProduct() async {
    DLog.d(PayThreeStock.TAG, '# 상품정보 요청');

    if (Platform.isAndroid) {
      DLog.d(PayThreeStock.TAG, '##### Platform Android');

      try {
        final String result = await channel
            .invokeMethod('getProductList', {'pd_code': _productLists[0]});
        if (result.isNotEmpty) {
          _priceSub = result;
          DLog.d(PayThreeStock.TAG, '##### 요청 결과 $result');
        }
        setState(() {});
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
    // ios
    else if (Platform.isIOS) {
      /*     List<IAPItem> items =
      await FlutterInappPurchase.instance.getProducts(_productLists);

      for (var item in items) {
        //print('${item.toString()}');
        _items.add(item);
        if (item.productId == 'ios.ac_pr.m01') {
          _pdItemOnce = item;
          _priceSingle = item.localizedPrice;
        }
        if (item.productId == 'ios.ac_pr.a01') {
          _pdItemSub = item;
          _priceSub = item.localizedPrice;
        }
      }

      setState(() {
        _items = items;
      });*/
    }
  }

  // 배너
  Widget _setBanner() {
    return Visibility(
      visible: prBanner,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrBanner),
      ),
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayThreeStock.TAG, '$trStr $json');

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
    DLog.d(PayThreeStock.TAG, response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.accountData != null) {
          final AccountData accountData = resData.retData.accountData;
          accountData.initUserStatus();
        } else {
          AccountData().setFreeUserStatus();
        }
        _fetchPosts(
            TR.APP03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    } else if (trStr == TR.APP03) {
      final TrApp03 resData = TrApp03.fromJson(jsonDecode(response.body));
      _listApp03.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData!.listPaymentGuide.isNotEmpty) {
          _listApp03.addAll(resData.retData!.listPaymentGuide);
          setState(() { });
        }
        _fetchPosts(
            TR.PROM02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'viewPage': 'LPH2',
              'promoDiv': '',
            }));
      }
    }

    //홍보
    else if (trStr == TR.PROM02) {
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          for (int i = 0; i < resData.retData.length; i++) {
            Prom02 item = resData.retData[i];
            if (item.promoDiv == 'BANNER') {
              if (item.viewPosition != '') {
                if (item.viewPosition == 'TOP') _listPrBanner.add(item);
                if (item.viewPosition == 'HGH') _listPrBanner.add(item);
                if (item.viewPosition == 'MID') _listPrBanner.add(item);
                //if (item.viewPosition == 'LOW') _listPrBanner.add(item);
              }
            }
          }
        }
        setState(() {
          if (_listPrBanner.length > 0) prBanner = true;
          //if (_listPrHgh.length > 0) prHGH = true;
          //if (_listPrMid.length > 0) prMID = true;
          //if (_listPrLow.length > 0) prLOW = true;
        });
      }
    }
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      DLog.d(PayThreeStock.TAG, '화면 종료');
      Navigator.of(context).pop(null); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });
  }
}
