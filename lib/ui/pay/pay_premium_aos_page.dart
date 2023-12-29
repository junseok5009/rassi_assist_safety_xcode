import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:rassi_assist/ui/pay/premium_care_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.06
/// 프리미엄 계정 결제
class PayPremiumAosPage extends StatelessWidget {
  static const routeName = '/page_pay_premium';
  static const String TAG = "[PayPremiumAosPage]";
  static const String TAG_NAME = '프리미엄_계정결제';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: PayPremiumAosWidget(),
      ),
    );
  }
}

class PayPremiumAosWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PayPremiumAosState();
}

class PayPremiumAosState extends State<PayPremiumAosWidget> {
  var appGlobal = AppGlobal();
  var inAppBilling = PaymentAosService();
  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = ''; //현재 사용중인 상품은
  String _payMethod = '';
  String _pageTitle = '프리미엄 계정 가입';
  bool _isUpgradeOn = false;
  bool _isVisibleOnce = true;

  final List<String> _productLists = Platform.isAndroid
      ? [
          'ac_pr.a01',
          'ac_pr.m01',
        ]
      : [
          'ios.ac_pr.a01',
          'ios.ac_pr.m01',
        ];

  late IAPItem _pdItemSub;
  late IAPItem _pdItemOnce;
  String _priceSub = '';
  String _priceSingle = '';

  bool _isPaymentSingle = false; //단건결제이면 true
  bool _isPaymentSub = true; //구독결제이면 true

  bool statusCon = false; //결제모듈 연결상태
  bool _bProgress = false; //결제 완료 전까지 프로그래스
  bool _isTryPayment = false; //결제버튼을 눌렀다면 화면이 닫히고 화면갱신 (true 일때 화면 갱신)

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 1. 이미 결제된 상품 확인 (프리미엄일 경우 결제 불가)
  // 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PayPremiumAosPage.TAG_NAME);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      _initBillingState();
    });
  }

  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
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

  //결제 동작은 비동기적으로 구동되어서 초기화 작업이 필요
  Future<void> _initBillingState() async {
    //상품정보 요청
    _getProduct();

    //결제 상태 리스너
    statCallback = (status) {
      DLog.d(PayPremiumAosPage.TAG, '# statusCallback == $status');
      if (status == 'md_exit') {  //사용자 취소...
        setState(() {
          _bProgress = false;
        });
      } else if (status == 'pay_success') {
        _showDialogMsg('결제가 완료 되었습니다.', '확인');
      }
    };
    inAppBilling.addToProStatusChangedListeners(statCallback);

    //결제 에러 상태 리스너
    errCallback = (retStr) {
      _showDialogMsg(retStr, '확인');
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
        appBar: _setAppBar(),
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
                          const SizedBox(height: 10,),

                          _setBanner(),
                          const SizedBox(height: 15,),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            child: Text('결제 방식',
                              style: TStyle.commonTitle,
                            ),
                          ),
                          Visibility(
                            visible: _isVisibleOnce,
                            child: _setButtonSingle(),
                          ),
                          _setButtonSub(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 20,
                            ),
                            child: Text('★ 정기결제는 언제든 구독을 취소하실 수 있어요.',
                              style: TextStyle(fontSize: 13,),),),
                          const SizedBox(height: 15,),

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
                      padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          _isTryPayment = true;
                          DLog.d(PayPremiumAosPage.TAG, '결제 요청시 Prod : $_curProd');
                          if (_curProd.contains('ac_pr') || _curProd.contains('AC_PR')) {
                            commonShowToast(
                                '이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
                          } else {
                            DLog.d(PayPremiumAosPage.TAG, '프리미엄 결제 요청');
                            setState(() {
                              _bProgress = true;
                            });
                            if(Platform.isIOS) {
                              /*  if (_pdItemOnce != null && _isPaymentSingle) {
                              inAppBilling.requestStorePurchase(_pdItemOnce);
                            } else if (_pdItemSub != null && _isPaymentSub) {
                              inAppBilling.requestStorePurchase(_pdItemSub);
                            }*/
                            }
                            else if(Platform.isAndroid) {
                              if(_isUpgradeOn) {
                                inAppBilling.requestGStoreUpgrade(_productLists[0]);
                              } else if (_isPaymentSingle) {
                                inAppBilling.requestGStorePurchase(_productLists[1]);
                              } else if (_isPaymentSub) {
                                inAppBilling.requestGStorePurchase(_productLists[0]);
                              }
                            }
                          }
                        },
                        child: const Center(
                          child: Text(
                            '프리미엄 계정 시작하기',
                            style: TextStyle(
                              fontSize: 18,
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
                  child: Stack(
                    children: const [
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

  //단건 결제 버튼
  Widget _setButtonSingle() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!_isPaymentSingle) {
          setState(() {
            _isPaymentSub = false;
            _isPaymentSingle = true;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: _isPaymentSingle ? RColor.mainColor : RColor.lineGrey,
              width: 0.8),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 10,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(
          children: [

            Row(
              children: [
                Visibility(
                  visible: _isPaymentSingle,
                  child:  Image.asset('images/test_pay_icon_check_on.png',
                    height: 16,
                    fit: BoxFit.contain,),),
                Visibility(
                  visible: !_isPaymentSingle,
                  child:  Image.asset('images/test_pay_icon_check_off.png',
                    height: 16,
                    fit: BoxFit.contain,),),
              ],
            ),
            const SizedBox(width: 14,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1개월 단건결제',
                  style: TextStyle(fontSize: 15,),),
                const SizedBox(height: 6,),
                Text(
                  _priceSingle,
                  style: TStyle.title17,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //정기 결제 버튼
  Widget _setButtonSub() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!_isPaymentSub) {
          setState(() {
            _isPaymentSub = true;
            _isPaymentSingle = false;
          });
        }
      },
      child: Container(
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

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Visibility(
                        visible: _isPaymentSub,
                        child:  Image.asset('images/test_pay_icon_check_on.png',
                          height: 16, fit: BoxFit.contain,),),
                    Visibility(
                      visible: !_isPaymentSub,
                      child:  Image.asset('images/test_pay_icon_check_off.png',
                        height: 16, fit: BoxFit.contain,),),
                  ],
                ),
                const SizedBox(width: 10,),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '매월정기결제',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: RColor.mainColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(20)),
                          ),
                          child: const Text(
                            '추천상품',
                            style: TextStyle(color: Colors.white, fontSize: 13,),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Platform.isAndroid
                              ? _priceSingle
                              : _pdItemSub != null &&_pdItemSub.currency == 'KRW' ? '￦79,000' : '',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xff96918e),
                          ),
                        ),
                        const SizedBox(width: 4,),
                        Text(
                          _priceSub,
                          style: TStyle.title18T,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 10,),
                child: Text(
                  '20% 이상 할인!',
                  style: TextStyle(
                      color: RColor.sigBuy,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            //SizedBox(width: 1,),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _setAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(_pageTitle,
        style: TStyle.defaultTitle,
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () {
              if(_bProgress) {
                commonShowToast('결제가 진행중입니다.');
              }
              else if (_isTryPayment) {
                Navigator.of(context).pop();
              }
              else {
                Navigator.of(context).pop('cancel');
              }
            }),
        const SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  //상품 소개
  Widget _setTopDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(
          height: 20.0,
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10,),
            child: Text(
              '실시간 AI매매신호 무제한 이용부터\n'
                  '오직 나만을 위한 매도신호까지\n'
                  '모두 실시간 알림으로!',
              style: TStyle.title18T,
            )),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "혼자하는 투자가 어려우세요?\n"
                "대한민국 대표 AI의 전문적인 종목분석과 관리를 받아보세요.\n"
                "라씨 매매비서는 투자를 쉽게 만들어 드립니다.",
            style: TStyle.content14,
          ),
        ),
      ],
    );
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

  //결제 안내 - iOS
  Widget _setPayInfo() {
    return Container(
      color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("App Store 구매안내",
            style: TStyle.commonTitle,),
          SizedBox(height: 10.0,),

          Text(RString.pay_guide_i),
          SizedBox(height: 5.0,),
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
        children: const [
          Text(
            "안내",
            style: TStyle.commonTitle,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(RString.pay_guide_aos),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  //이용약관, 개인정보처리방침
  Widget _setTerms() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5.0,),

          _setSubTitle('이용약관 및 개인정보 취급방침'),
          const SizedBox(height: 10,),

          _setTermsText(),
          const SizedBox(height: 25,),
        ],
      ),
    );
  }

  Widget _setTermsText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Text('이용약관 보기',
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
        builder: (BuildContext dialogContext) {
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
                    Navigator.pop(dialogContext);
                    _goPreviousPage();
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
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Center(
                          child: Text(
                            btnText,
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _goPreviousPage();
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
    DLog.d(PayPremiumAosPage.TAG, '# 상품정보 요청');

    if(Platform.isAndroid) {
      DLog.d(PayPremiumAosPage.TAG, '##### Platform Android');

      try {
        final String result = await channel.invokeMethod('getProductList', {'pd_code': _productLists[0]});
        if(result.isNotEmpty) {
          _priceSub = result;
          DLog.d(PayPremiumAosPage.TAG, '##### 요청 결과 $result');
        }

        final String result2 = await channel.invokeMethod('getProductList', {'pd_code': _productLists[1]});
        if(result2.isNotEmpty) {
          _priceSingle = result2;
          DLog.d(PayPremiumAosPage.TAG, '##### 요청 결과 $result2');
        }

        setState(() {});

      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    }
    // ios
    else if(Platform.isIOS) {
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

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    // DEFINE 23.08.04 프리미엄 케어 서비스 추가
    Navigator.pop(context);
    basePageState.callPageRoute(const PremiumCarePage());
    /*Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop('complete'); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });*/
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayPremiumAosPage.TAG, '$trStr $json');

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
    DLog.d(PayPremiumAosPage.TAG, response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        DLog.d(PayPremiumAosPage.TAG, data.accountData.toString());

        if (data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatusAfterPayment();
          _curProd = accountData.productId;
          _payMethod = accountData.payMethod;
          if (accountData.prodName == '프리미엄') {
            //이미 프리미엄 계정으로 결제 화면 종료
          } else if (accountData.prodCode == 'AC_S3') {
            if(_payMethod == 'PM50'){ //인앱으로 결제한 경우
              _isUpgradeOn = true;
              _isPaymentSub = true;
              _isVisibleOnce = false;
              _pageTitle = '프리미엄 계정 업그레이드';
            }
          } else {
            //베이직 계정
          }
        } else {
          //회원정보 가져오지 못함
          AccountData().setFreeUserStatus();
        }
        setState(() {});
      } else {
        AccountData().setFreeUserStatus();
      }

      _fetchPosts(
          TR.PROM02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'viewPage': 'LPH1',
            'promoDiv': '',
          }));
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

}
