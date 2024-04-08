import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
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
import 'package:rassi_assist/ui/pay/payment_service.dart';
import 'package:rassi_assist/ui/pay/premium_care_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2022.05.01
/// 프리미엄 계정 결제
class PayPremiumPage extends StatefulWidget {
  static const routeName = '/page_pay_premium';
  static const String TAG = "[PayPremiumPage]";
  static const String TAG_NAME = '프리미엄_계정결제';

  const PayPremiumPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PayPremiumState();
}

class PayPremiumState extends State<PayPremiumPage> {
  var appGlobal = AppGlobal();
  var inAppBilling = PaymentService();

  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = ''; //현재 사용중인 상품은

  final List<String> _productLists = Platform.isAndroid
      ? [
          'ac_pr.a01',
          'ac_pr.m01',
        ]
      : [
          'ios.ac_pr.a01',
          'ios.ac_pr.m01',
        ];

  List<IAPItem> _items = [];

  late IAPItem _pdItemSub;
  late IAPItem _pdItemOnce;
  String _priceSub = '';
  String _priceSingle = '';

  // Agent, 단건, 구독 순서 변수
  final List _listDivPayment = [
    false,
    false,
    false,
  ];

  bool statusCon = false; //결제모듈 연결상태
  bool _bProgress = false; //결제 완료 전까지 프로그래스
  bool _isTryPayment = false; //결제버튼을 눌렀다면 화면이 닫히고 화면갱신 (true 일때 화면 갱신)

  // 1. 이미 결제된 상품 확인 (프리미엄일 경우 결제 불가)
  // 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 23.10.11 추가 구매 안내 문구 전문으로 가져오기
  final List<App03PaymentGuide> _listApp03 = [];

  // 23.10.13 프리미엄 결제 원래 가격 APP03 에서 가져오기
  String _originalPriceA01 = '';

  // 24.03.22 Agent 결제 추가
  bool _isAgent = false;

  @override
  void initState() {
    super.initState();
    _isAgent = Provider.of<UserInfoProvider>(context, listen: false)
            .getUser04
            .agentData.agentCode.isNotEmpty;
    CustomFirebaseClass.logEvtScreenView(
        PayPremiumPage.TAG_NAME + (_isAgent ? '_에이전트 : ' : ''));
    if (_isAgent) {
      setState(() {
        _listDivPayment[0] = true;
      });
    } else {
      setState(() {
        _listDivPayment[2] = true;
      });
    }

    _initBillingState();
    _loadPrefData().then((value) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? appGlobal.userId;
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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //결제 동작은 비동기적으로 구동되어서 초기화 작업이 필요
  Future<void> _initBillingState() async {
    //상품정보 요청
    _getProduct();

    //결제 상태 리스너
    statCallback = (status) async {
      if (status == 'md_exit') {
        setState(() {
          _bProgress = false;
        });
      } else if (status == 'pay_success') {
        var userInfoProvider =
            Provider.of<UserInfoProvider>(context, listen: false);
        await userInfoProvider.updatePayment();
        if (userInfoProvider.isPremiumUser() && mounted) {
          Navigator.popUntil(
            context,
            ModalRoute.withName('/base'),
          );
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PremiumCarePage()));
          CommonPopup.instance
              .showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
        } else {
          if (mounted) {
            Navigator.popUntil(
              context,
              ModalRoute.withName('/base'),
            );
            CommonPopup.instance
                .showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
          }
        }
      } else {
        Navigator.popUntil(
          context,
          ModalRoute.withName('/base'),
        );
      }
    };
    inAppBilling.addToProStatusChangedListeners(statCallback);

    //결제 에러 상태 리스너
    errCallback = (retStr) async {
      await CommonPopup.instance.showDialogBasicConfirm(context, '알림', retStr);
      if (mounted) {
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
    return Scaffold(
      appBar: CommonAppbar.simpleWithExit(
        context,
        '프리미엄 계정 가입',
        Colors.black,
        Colors.white,
        Colors.black,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
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
                      _isAgent ? _setAgentWidgets : _setNormalWidgets,
                      const SizedBox(
                        height: 15,
                      ),
                      _setPayInfo(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      _setTerms(),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _isAgent
                      ? (_listDivPayment[1] == true || _listDivPayment[2])
                      : true,
                  child: Container(
                    color: RColor.mainColor,
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: InkWell(
                      onTap: () async {
                        _isTryPayment = true;
                        if (_curProd.contains('ac_pr')) {
                          commonShowToast(
                              '이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
                        } else {
                          DLog.d(PayPremiumPage.TAG, '단건 결제 요청');
                          setState(() {
                            _bProgress = true;
                          });
                          if (_listDivPayment[1]) {
                            dynamic result = await inAppBilling
                                .requestStorePurchase(_pdItemOnce);
                            DLog.e('result : ${result.toString()}');
                          } else if (_listDivPayment[2]) {
                            dynamic result = await inAppBilling
                                .requestStorePurchase(_pdItemSub);
                            DLog.e('result : ${result.toString()}');
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
    );
  }

  //단건 결제 버튼
  Widget _setButtonAgent() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!_listDivPayment[0]) {
          setState(() {
            _listDivPayment[0] = true;
            _listDivPayment[1] = false;
            _listDivPayment[2] = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _listDivPayment[0] ? RColor.mainColor : RColor.lineGrey,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '12개월 무통장 결제',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
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

  //단건 결제 버튼
  Widget _setButtonSingle() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!_listDivPayment[1]) {
          setState(() {
            _listDivPayment[1] = true;
            _listDivPayment[0] = false;
            _listDivPayment[2] = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: _listDivPayment[1] ? RColor.mainColor : RColor.lineGrey,
              width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1개월 단건결제',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
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
        if (!_listDivPayment[2]) {
          setState(() {
            _listDivPayment[2] = true;
            _listDivPayment[0] = false;
            _listDivPayment[1] = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: _listDivPayment[2] ? RColor.mainColor : RColor.lineGrey,
              width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                      visible: _listDivPayment[2],
                      child: Image.asset(
                        'images/test_pay_icon_check_on.png',
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Visibility(
                      visible: !_listDivPayment[2],
                      child: Image.asset(
                        'images/test_pay_icon_check_off.png',
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
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
                        Visibility(
                          visible: !_isAgent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            margin: const EdgeInsets.only(
                              left: 14,
                            ),
                            decoration: const BoxDecoration(
                              color: RColor.mainColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: const Text(
                              '추천상품',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '￦${TStyle.getMoneyPoint(_originalPriceA01)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xff96918e),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
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
            const Text(
              '20% 이상 할인!',
              style: TextStyle(
                  color: RColor.sigBuy,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            //SizedBox(width: 1,),
          ],
        ),
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
              '실시간 AI매매신호 무제한 이용부터\n오직 나만을 위한 매도신호까지\n모두 실시간 알림으로!',
              style: TStyle.title18T,
            )),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "혼자하는 투자가 어려우세요?\n대한민국 대표 AI의 전문적인 종목분석과 관리를 받아보세요.\n라씨 매매비서는 투자를 쉽게 만들어 드립니다.",
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

  //결제 안내
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
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _listApp03.length,
            itemBuilder: (context, index) => Text(_listApp03[index].guideText),
          ),
          const SizedBox(
            height: 5.0,
          ),

          // InkWell(
          //   child: Text('프로모션 코드 입력', style: TStyle.ulTextPurple,),
          //   onTap: () => inAppBilling.showRedemptionSheet(),
          // ),
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

  //에이전트 결제 화면
  Widget get _setAgentWidgets {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '회원님을 위한 특별 할인 상품을 이용해 보세요.',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 15,
          ),
          _setButtonAgent(),
          const SizedBox(
            height: 15,
          ),
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
            ).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              horizontalTitleGap: 0.0,
              minLeadingWidth: 0,
              child: ExpansionTile(
                collapsedIconColor: Colors.black,
                iconColor: Colors.black,
                //expandedAlignment: Alignment.centerLeft,
                title: const Text(
                  '다른 결제 방식 선택하기',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onExpansionChanged: (expanded) {
                  if (!expanded) {
                    setState(() {
                      _listDivPayment[0] = true;
                      _listDivPayment[1] = false;
                      _listDivPayment[2] = false;
                    });
                  }
                },
                children: [
                  _setButtonSingle(),
                  const SizedBox(
                    height: 15,
                  ),
                  _setButtonSub(),
                  const SizedBox(
                    height: 15,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '★ 정기결제는 언제든 구독을 취소하실 수 있어요.',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //일반 결제 화면
  Widget get _setNormalWidgets {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제 방식',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 15,
          ),
          _setButtonSingle(),
          const SizedBox(
            height: 15,
          ),
          _setButtonSub(),
          const SizedBox(
            height: 15,
          ),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              '★ 정기결제는 언제든 구독을 취소하실 수 있어요.',
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //상품정보 가져오기
  Future _getProduct() async {
    DLog.d(PayPremiumPage.TAG, '# 상품정보 요청');

    // Set literals require Dart 2.2. Alternatively, use
    // `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
    /* const Set<String> _kIds = <String>{'ios.ac_pr.a01', 'ios.ac_pr.m01', 'ios.ac_pr.ad3', 'ios.ac_pr.at1'};
    final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    List<ProductDetails> products = response.productDetails;
    for (var item in products) {
      print('${item.toString()}');
      DLog.d(PayPremiumPage.TAG, 'id:${item.id} / price:${item.price} / rawPrice:${item.rawPrice} / currencyCode:${item.currencyCode} / title:${item.title} / description:${item.description}');

      //_items.add(item);
      */ /*if (item.productId == 'ios.ac_pr.m01') {
        _pdItemOnce = item;
        _priceSingle = item.localizedPrice;
      }
      if (item.productId == 'ios.ac_pr.a01') {
        _pdItemSub = item;
        _priceSub = item.localizedPrice;
      }*/ /*

    }*/

    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);

    for (var item in items) {
      //print('${item.toString()}');

      _items.add(item);
      if (item.productId == 'ios.ac_pr.m01') {
        _pdItemOnce = item;
        _priceSingle = item.localizedPrice!;
      }
      if (item.productId == 'ios.ac_pr.a01') {
        _pdItemSub = item;
        _priceSub = item.localizedPrice!;
      }
    }

    setState(() {
      _items = items;
    });
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayPremiumPage.TAG, '$trStr $json');

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
    DLog.d(PayPremiumPage.TAG, response.body);
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final AccountData accountData = resData.retData.accountData;
        accountData.initUserStatus();
        _fetchPosts(
            TR.APP03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      } else {
        Navigator.pop(context);
      }
    } else if (trStr == TR.APP03) {
      final TrApp03 resData = TrApp03.fromJson(jsonDecode(response.body));
      _originalPriceA01 = resData.retData!.stdPrice;
      _listApp03.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData!.listPaymentGuide.isNotEmpty) {
          _listApp03.addAll(resData.retData!.listPaymentGuide);
          setState(() {});
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
          if (_listPrBanner.isNotEmpty) prBanner = true;
          //if (_listPrHgh.length > 0) prHGH = true;
          //if (_listPrMid.length > 0) prMID = true;
          //if (_listPrLow.length > 0) prLOW = true;
        });
      }
    }
  }

  //상품금액 리턴
  String _getPaymentAmount(List<IAPItem> products, String prodId) {
    for (IAPItem item in products) {
      if (item.productId == prodId) {
        // if (item.introductoryPrice.isEmpty) {
        //   DLog.d(PaymentService.TAG, 'introductoryPrice.isEmpty');
        //   DLog.d(PaymentService.TAG, '${item.productId} / ${item.price}');
        //   return item.price;
        // } else {
        //   DLog.d(PaymentService.TAG, 'introductoryPrice.isNotEmpty');
        //   if (item.introductoryPriceNumberOfPeriodsIOS.isEmpty) {
        //     return item.price;
        //   } else {
        //     int integerIntroductoryPriceNumberOfPeriodsIOS =
        //         int.parse(item.introductoryPriceNumberOfPeriodsIOS);
        //     if (integerIntroductoryPriceNumberOfPeriodsIOS > 1) {
        //       DLog.d(PaymentService.TAG, '${item.productId} / 0');
        //       return '0';
        //     } else {
        //       String str = item.introductoryPrice;
        //       String intStr = str.replaceAll(new RegExp('[^0-9.]+'), '');
        //       DLog.d(PaymentService.TAG,
        //           '${item.productId} / ${item.price} / $intStr');
        //       return intStr;
        //     }
        //   }
        // }
      }
    }
    return '';
  }
}
