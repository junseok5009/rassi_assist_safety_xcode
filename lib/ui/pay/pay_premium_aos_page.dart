import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_app/tr_app03.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/pay/premium_care_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/ui_style.dart';

/// 2024.02
/// 프리미엄 계정 결제 new
class PayPremiumAosPage extends StatefulWidget {
  static const routeName = '/page_pay_premium';
  static const String TAG = "[PayPremiumAosPage]";
  static const String TAG_NAME = '프리미엄_계정결제';

  const PayPremiumAosPage({super.key});

  @override
  State<StatefulWidget> createState() => PayPremiumAosState();
}

class PayPremiumAosState extends State<PayPremiumAosPage> {
  var appGlobal = AppGlobal();
  var inAppBilling = PaymentAosService();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;


  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = ''; //현재 사용중인 상품은
  String _payMethod = '';
  bool _isUpgradeOn = false;
  bool _isFirstBtn = true;

  final List<String> _productLists = Platform.isAndroid
      ? [
          'ac_pr.a01',
          'ac_pr.am6d0',
          'ac_pr.m01',
        ]
      : [
          'ios.ac_pr.a01',
          'ios.ac_pr.m01',
        ];

  String _priceSingle = '';
  String _priceSub = '';
  String _priceLongSub = '';

  bool _isPaymentSingle = false;  //단건결제이면 true
  bool _isPaymentSub = true;      //1개월 구독결제이면 true
  bool _isLongTermSub = false;    //6개월 구독결제이면 true

  bool statusCon = false; //결제모듈 연결상태
  bool _bProgress = false; //결제 완료 전까지 프로그래스

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 23.10.11 추가 구매 안내 문구 전문으로 가져오기
  final List<App03PaymentGuide> _listApp03 = [];
  // 23.10.13 프리미엄 결제 원래 가격 APP03 에서 가져오기
  String _originalPriceA01 = '';

  // NOTE 1. 이미 결제된 상품 확인 (프리미엄일 경우 결제 불가)
  // NOTE 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PayPremiumAosPage.TAG_NAME);

    _loadPrefData().then((value) {
      _initBillingState();
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? appGlobal.userId ?? '';
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

    _initStoreInfo().then((value) => {
      for(ProductDetails tmp in _products) {
        DLog.d('Inapp',
            '*****************\n'
            '${tmp.title}\n'
            '${tmp.id}\n'
            '${tmp.price}\n'
            '${tmp.rawPrice}\n'
            '${tmp.description}\n'
            '*****************'),
        if(tmp.id == 'ac_pr.a01'){
          _priceSub = tmp.price
        },
        if(tmp.id == 'ac_pr.am6d0') {
          _priceLongSub = tmp.price
        },
        if(tmp.id == 'ac_pr.m01') {
          _priceSingle = tmp.price
        }
      },
      setState(() { })
    });
  }

  // in_app_purchase 모듈 초기화 & 상품정보 가져오기
  Future<void> _initStoreInfo() async {
    DLog.d('Inapp', '=> initStoreInfo');
    final bool isAvailable = await _inAppPurchase.isAvailable();
    DLog.d('Inapp', '#1 isAvailable $isAvailable');
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final ProductDetailsResponse productDetailResponse =
      await _inAppPurchase.queryProductDetails(_productLists.toSet());
    if (productDetailResponse.error != null) {
      DLog.d('Inapp', '#2 productDetailResponse.error');
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }
    if (productDetailResponse.productDetails.isEmpty) {
      DLog.d('Inapp', '#3 productDetails.isEmpty');
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    DLog.d('Inapp', '#4 product isAvailable');
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchasePending = false;
      _loading = false;
    });
  }

  //저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //결제 동작은 비동기적으로 구동되어서 초기화 작업이 필요
  Future<void> _initBillingState() async {
    //상품정보 요청
    // _getProduct();

    //결제 상태 리스너
    statCallback = (status) async {
      DLog.d(PayPremiumAosPage.TAG, '# statusCallback == $status');
      if (status == 'md_exit') {
        //사용자 취소...
        setState(() {
          _bProgress = false;
        });
      } else if (status == 'pay_success') {
        var userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        await userInfoProvider.updatePayment();
        if (userInfoProvider.isPremiumUser() && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PremiumCarePage()),
          );
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
        } else {
          Navigator.pop(context);
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
        }
      } else {
        Navigator.pop(context);
      }
    };
    inAppBilling.addToProStatusChangedListeners(statCallback);

    //결제 에러 상태 리스너
    errCallback = (retStr) async {
      await CommonPopup.instance.showDialogBasicConfirm(context, '알림', retStr);
      if (context.mounted) {
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
          '프리미엄 계정 가입',
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
                          const SizedBox(height: 10),
                          _setBanner(),
                          const SizedBox(height: 15),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            child: Text(
                              '결제 방식을 선택하세요',
                              style: TStyle.commonTitle,
                            ),
                          ),
                          const SizedBox(height: 15),

                          //결제 선택
                          _setButtonSelect(),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 20,
                            ),
                            child: Text(
                              _isFirstBtn ? '★ 정기결제는 언제든 구독을 취소하실 수 있습니다.' : '',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //구매안내
                          Platform.isIOS ? _setPayInfo() : _setPayInfoAOS(),
                          //이용약관, 개인정보처리방침(ios만 표시)
                          Platform.isIOS ? _setTerms() : Container(),
                        ],
                      ),
                    ),

                    //프리미엄 계정 시작하기
                    Container(
                      color: RColor.mainColor,
                      height: 70,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: InkWell(
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
                        onTap: () {
                          _requestPurchase();
                        },
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
                        child: ModalBarrier(dismissible: false, color: Colors.grey),
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

  //프리미엄 구매 요청 시작하기
  void _requestPurchase() {
    DLog.d(PayPremiumAosPage.TAG, '결제 요청시 사용중인 pdCode : $_curProd');

    if (_curProd.contains('ac_pr') || _curProd.contains('AC_PR')) {
      commonShowToast('이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
    } else {
      DLog.d(PayPremiumAosPage.TAG, '프리미엄 결제 요청');
      setState(() {
        _bProgress = true;
      });

      if (_isUpgradeOn) {
        //3종목 -> 1개월정기(ac_pr.a01)
        inAppBilling.requestGStoreUpgrade(_productLists[0]);
      }
      else if (_isPaymentSingle) {
        //ac_pr.m01
        inAppBilling.requestGStorePurchase(_productLists[2]);
      }
      else if (_isPaymentSub) {
        //ac_pr.a01
        inAppBilling.requestGStorePurchase(_productLists[0]);
      }
      else if (_isLongTermSub) {
        //ac_pr.am6d0
        inAppBilling.requestGStorePurchase(_productLists[1]);
      }
    }

/*    // 새로운 업그레이드 과정은 보류
    if(_curProd.isEmpty) {
      if (_isUpgradeOn) {
        //3종목 -> 1개월정기(ac_pr.a01)
        inAppBilling.requestGStoreUpgrade(_productLists[0]);
      }
      else if (_isPaymentSingle) {
        //ac_pr.m01
        inAppBilling.requestGStorePurchase(_productLists[2]);
      }
      else if (_isPaymentSub) {
        //ac_pr.a01
        inAppBilling.requestGStorePurchase(_productLists[0]);
      }
      else if (_isLongTermSub) {
        //ac_pr.am6d0
        inAppBilling.requestGStorePurchase(_productLists[1]);
      }
    }
    //새로운 업그레이드
    else if(_curProd == 'ac_s3.a01' || _curProd == 'ac_pr.a01'
        || _curProd == 'ac_pr.m01' || _curProd == 'ac_pr.mw1e1') {
      inAppBilling.requestGStoreUpgradeNew(_curProd, 'ac_pr.am6d0');
    }*/

  }

  //결제 선택 버튼
  Widget _setButtonSelect() {
    return Column(
      children: [
        //단건결제
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: _isPaymentSingle
                ? UIStyle.boxSelectedLineMainColor()
                : UIStyle.boxUnSelectedLineMainGrey(),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Visibility(
                          visible: _isPaymentSingle,
                          child: Image.asset(
                            'images/icon_circle_check_y.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Visibility(
                          visible: !_isPaymentSingle,
                          child: Image.asset(
                            'images/icon_circle_check_n.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '1개월 단건결제',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _priceSingle,
                          style: TStyle.title18T,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _isPaymentSingle = true;
              _isPaymentSub = false;
              _isLongTermSub = false;
            });
          },
        ),

        // 1개월 정기결제
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: _isPaymentSub
                ? UIStyle.boxSelectedLineMainColor()
                : UIStyle.boxUnSelectedLineMainGrey(),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Visibility(
                          visible: _isPaymentSub,
                          child: Image.asset(
                            'images/icon_circle_check_y.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Visibility(
                          visible: !_isPaymentSub,
                          child: Image.asset(
                            'images/icon_circle_check_n.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '매월 정기결제',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              decoration: const BoxDecoration(
                                color: RColor.mainColor,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: const Text(
                                '추천상품',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _setOrgPriceText(_originalPriceA01),
                            const SizedBox(width: 7),
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
                Visibility(
                  visible: _isPaymentSub,
                  child: _setPromotionText('22% 이상!'),
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _isPaymentSub = true;
              _isLongTermSub = false;
              _isPaymentSingle = false;
            });
          },
        ),

        // 6개월 정기결제
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: _isLongTermSub
                ? UIStyle.boxSelectedLineMainColor()
                : UIStyle.boxUnSelectedLineMainGrey(),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Visibility(
                          visible: _isLongTermSub,
                          child: Image.asset(
                            'images/icon_circle_check_y.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Visibility(
                          visible: !_isLongTermSub,
                          child: Image.asset(
                            'images/icon_circle_check_n.png',
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '6개월씩 정기결제',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _setOrgPriceText('462000'),
                            const SizedBox(width: 7),
                            Text(
                              _priceLongSub,
                              style: TStyle.title18T,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: _isLongTermSub,
                  child: _setPromotionText('28% 이상!'),
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _isPaymentSingle = false;
              _isPaymentSub = false;
              _isLongTermSub = true;
            });
          },
        ),
      ],
    );
  }

  //기존가 표시
  Widget _setOrgPriceText(String prc) {
    return Text(
      '￦${TStyle.getMoneyPoint(prc)}',
      style: const TextStyle(
        decoration: TextDecoration.lineThrough,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: Color(0xff96918e),
      ),
    );
  }

  //할인률 강조 문구
  Widget _setPromotionText(String desc) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 8,
              ),
              decoration: const BoxDecoration(
                color: RColor.sigBuy,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: const Text(
                '할인율',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              desc,
              style: const TextStyle(
                color: RColor.sigBuy,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
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
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
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

  //이용약관, 개인정보처리방침
  Widget _setTerms() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5.0,
          ),
          _setSubTitle('이용약관 및 개인정보 취급방침'),
          const SizedBox(
            height: 10,
          ),
          _setTermsText(),
          const SizedBox(
            height: 25,
          ),
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
            child: const Text(
              '이용약관 보기',
              style: TStyle.ulTextPurple,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebPage(),
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
                    builder: (context) => const WebPage(),
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
          accountData.initUserStatus();
          _curProd = accountData.productId;
          _payMethod = accountData.payMethod;
          if (accountData.prodName == '프리미엄') {
            //이미 프리미엄 계정으로 결제 화면 종료
          }
          else if (accountData.prodCode == 'AC_S3') {
            if (_payMethod == 'PM50') {
              //인앱으로 결제한 경우
              _isUpgradeOn = true;
              _isPaymentSub = true;
            }
          } else {
            //베이직 계정
          }
        } else {
          //회원정보 가져오지 못함
          const AccountData().setFreeUserStatus();
        }
        setState(() {});
      } else {
        const AccountData().setFreeUserStatus();
      }

      _fetchPosts(
          TR.APP03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
    //
    else if (trStr == TR.APP03) {
      final TrApp03 resData = TrApp03.fromJson(jsonDecode(response.body));
      _originalPriceA01 = resData.retData!.stdPrice;
      _listApp03.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData!.listPaymentGuide.isNotEmpty) {
          _listApp03.addAll(resData.retData!.listPaymentGuide);
        }
        _fetchPosts(
            TR.PROM02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'viewPage': 'LPH1',
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
}
