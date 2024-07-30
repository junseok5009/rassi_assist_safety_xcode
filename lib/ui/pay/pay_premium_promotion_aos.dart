import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
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
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/pay/premium_care_page.dart';
import 'package:rassi_assist/ui/web/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/ui_style.dart';

/// 2023.06.23
/// 프리미엄 계정 결제 - 첫결제 30 40 50% 할인 상품 통합 페이지
// 계정결제	LPH1
// 계정결제_처음50할인	LPH7
// 계정결제_처음40할인	LPH8
// 계정결제_처음30할인	LPH9
// 계정결제_7일무료	LPHA
// 계정결제_14일무료	LPHB
// 6개월 정기구독 상품 -
// 6개월 정기구독 50% 할인 -
// 1주일 이벤트 특가 상품 -
class PayPremiumPromotionAosPage extends StatefulWidget {
  static const routeName = '/page_pay_premium_promotion';
  static const String TAG = "[PayPremiumPromotionAos]";

  const PayPremiumPromotionAosPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PayPremiumPromotionState();
}

class PayPremiumPromotionState extends State<PayPremiumPromotionAosPage> {
  static String TAG_NAME = '계정결제_?할인';
  static String VIEW_PAGE_CODE = 'LPH7';

  String pageCode = '';
  var appGlobal = AppGlobal();
  var inAppBilling = PaymentAosService();
  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = ''; //현재 사용중인 상품

  String _pageTitle = ''; // 프리미엄 계정 가입 (?)
  String _buttonTitle = ''; // (첫달) or (무료체험 x일 후)
  String _buyInfo = ''; //

  String _priceOnce = '';
  String _priceOriginal = '₩59,400';

  // late IAPItem _pdItem;
  String _vProductId = ''; //상품코드

  bool statusCon = false; //결제모듈 연결상태
  bool _bProgress = false; //결제 완료 전까지 프로그래스
  bool _isTryPayment = false; //결제버튼을 눌렀다면 화면이 닫히고 화면갱신 (true 일때 화면 갱신)

  // 1. 이미 결제된 상품 확인 (업그레이드 결제가 가능한 상품과 불가능한 상품)
  // 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 23.10.11 추가 구매 안내 문구 전문으로 가져오기
  final List<App03PaymentGuide> _listApp03 = [];

  @override
  void initState() {
    super.initState();

    _userId = appGlobal.userId;
    _loadPrefData().then((_) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? appGlobal.userId ?? '';
      Future.delayed(Duration.zero, () {
        PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
        if (args.data.isEmpty) {
          commonShowToast('잘못된 오류 입니다.');
          Navigator.pop(context);
        } else {
          pageCode = args.data;
          _initBillingState();
          _setFirebaseLog();
        }

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
    });
  }

  void _setFirebaseLog() {
    switch (pageCode) {
      case 'ad3':
        {
          TAG_NAME = '계정결제_30할인';
          VIEW_PAGE_CODE = 'LPH9';
          break;
        }
      case 'ad4':
        {
          TAG_NAME = '계정결제_40할인';
          VIEW_PAGE_CODE = 'LPH8';
          break;
        }
      case 'ad5':
        {
          TAG_NAME = '계정결제_50할인';
          VIEW_PAGE_CODE = 'LPH7';
          break;
        }
      case 'at1':
        {
          TAG_NAME = '계정 결제 7일 무료 체험 포함';
          VIEW_PAGE_CODE = 'LPHA';
          break;
        }
      case 'at2':
        {
          TAG_NAME = '계정 결제 14일 무료 체험 포함';
          VIEW_PAGE_CODE = 'LPHB';
          break;
        }
      case 'new_6m':
        {
          TAG_NAME = '계정 결제 6개월 정기 구독';
          VIEW_PAGE_CODE = 'LPHD';
          break;
        }
      case 'new_6m_50':
        {
          TAG_NAME = '계정 결제 6개월 50% 할인';
          VIEW_PAGE_CODE = 'LPHE';
          break;
        }
      case 'new_6m_70':
        {
          TAG_NAME = '계정 결제 6개월 75% 할인';
          VIEW_PAGE_CODE = 'LPHG';
          break;
        }
      case 'new_7d':
        {
          TAG_NAME = '프리미엄 계정(1주일)';
          VIEW_PAGE_CODE = 'LPHF';
          break;
        }
      default:
        {
          commonShowToast('허용하지 않은 접근입니다.');
          Navigator.pop(context);
        }
    }
    CustomFirebaseClass.logEvtScreenView(TAG_NAME);
    CustomFirebaseClass.logEvtPaySelect(payType: pageCode);
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
        var userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        await userInfoProvider.updatePayment().then((value) {
          Navigator.popUntil(
            context,
            ModalRoute.withName(BasePage.routeName),
          );
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '결제가 완료 되었습니다.');
          if (userInfoProvider.isPremiumUser()) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumCarePage()));
          }
        });
      } else {
        Navigator.popUntil(
          context,
          ModalRoute.withName(BasePage.routeName),
        );
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
    _setPayInfoText();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CommonAppbar.simpleWithExit(
          context,
          _pageTitle,
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
                          const SizedBox(height: 10.0),

                          _setBanner(),
                          const SizedBox(height: 15),

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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 20,
                            ),
                            child: Text(
                              _buyInfo,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          _setPayInfoAOS(),

                          ////이용약관, 개인정보처리방침(ios만 표시)
                          Platform.isIOS ? _setTerms() : Container(),
                        ],
                      ),
                    ),
                    Container(
                      color: RColor.mainColor,
                      height: 70,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: InkWell(
                        child: Center(
                          child: Text(
                            _buttonTitle,
                            style: const TextStyle(
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
                    )
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
        ),
      ),
    );
  }

  //프리미엄 구매 요청 시작하기
  void _requestPurchase() {
    DLog.d(PayPremiumPromotionAosPage.TAG, '결제 요청시 사용중인 pdCode : $_curProd');

    _isTryPayment = true;
    //프리미엄 사용자의 업그레이드 요청 (1개월 -> 6개월)
    if (_curProd.contains('ac_pr') || _curProd.contains('AC_PR')) {
      if (_curProd == 'ac_pr.am6d0' ||
          _curProd == 'ac_pr.am6d5' ||
          _curProd == 'ac_pr.am6d7' ||
          _curProd == 'ac_pr.mw1e1') {
        commonShowToast('이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
      } else {
        DLog.d(PayPremiumPromotionAosPage.TAG, '새로운 업그레이드 결제 요청');
        inAppBilling.requestGStoreUpgradeNew(_curProd, _vProductId);
      }
    }
    //3종목알림 업그레이드 요청
    else if (_curProd.contains('ac_s3') || _curProd.contains('AC_S3')) {
      if (_vProductId == 'ac_pr.a01') {
        // 1개월정기결제 기본 상품으로만 업그레이드 가능 (6개월상품 불가) , ac_pr.a01 상품만 가능 (할인상품은 할인 적용 불가)
        DLog.d(PayPremiumPromotionAosPage.TAG, '3종목알림 업그레이드 결제 요청');
        inAppBilling.requestGStoreUpgrade(_vProductId);
      } else {
        commonShowToast('업그레이드 결제를 이용할 수 없는 상품입니다. 고객센터에 문의해주세요.');
      }
    }
    //프로모션 결제 요청
    else {
      setState(() {
        _bProgress = true;
      });
      if (_vProductId.isNotEmpty) {
        inAppBilling.requestGStorePurchase(_vProductId);
      }
    }
  }

  Future<bool> _onWillPop() {
    if (_bProgress) {
      commonShowToast('결제가 진행중입니다.');
      return Future.value(false);
    }

    Navigator.pop(context);
    return Future.value(true);
  }

  void _setPayInfoText() {
    switch (pageCode) {
      case 'ad3':
        {
          _pageTitle = '프리미엄 계정 (30% 특별 할인)';
          _buttonTitle = '30% 할인 받으면서 프리미엄 계정 시작하기';
          _buyInfo = '★ 첫달 50% 할인혜택($_priceOnce)과 '
              '둘째달 부터는 23% 할인혜택($_priceOriginal)을 모두 드립니다.\n'
              '★ 정기결제는 언제든 구독을 취소하실 수 있어요.';
          break;
        }
      case 'ad4':
        {
          _pageTitle = '프리미엄 계정 (40% 특별 할인)';
          _buttonTitle = '40% 할인 받으면서 프리미엄 계정 시작하기';
          _buyInfo = '★ 첫달 50% 할인혜택($_priceOnce)과 '
              '둘째달 부터는 23% 할인혜택($_priceOriginal)을 모두 드립니다.\n'
              '★ 정기결제는 언제든 구독을 취소하실 수 있어요.';
          break;
        }
      case 'ad5':
        {
          _pageTitle = '프리미엄 계정 (50% 특별 할인)';
          _buttonTitle = '50% 할인 받으면서 프리미엄 계정 시작하기';
          _buyInfo = '★ 첫달 50% 할인혜택($_priceOnce)과 '
              '둘째달 부터는 23% 할인혜택($_priceOriginal)을 모두 드립니다.\n'
              '★ 정기결제는 언제든 구독을 취소하실 수 있어요.';
          break;
        }
      case 'at1':
        {
          _pageTitle = '프리미엄 계정 (7일 무료체험 포함)';
          _buttonTitle = '결제 부담 없이 무료체험 시작하기';
          _buyInfo = '★ 결제 부담없이 무료체험으로 먼저 만나보세요.\n'
              '★ 무료체험 기간 중 언제든 가입을 해지하실 수 있으며, 결제 전 계정을 해지하시면 요금이 부과되지 않습니다';
          break;
        }
      case 'at2':
        {
          _pageTitle = '프리미엄 계정 (14일 무료체험 포함)';
          _buttonTitle = '결제 부담 없이 무료체험 시작하기';
          _buyInfo = '★ 결제 부담없이 무료체험으로 먼저 만나보세요.\n'
              '★ 무료체험 기간 중 언제든 가입을 해지하실 수 있으며, 결제 전 계정을 해지하시면 요금이 부과되지 않습니다';
          break;
        }
      case 'new_6m':
        {
          _pageTitle = '프리미엄 계정 6개월 정기 구독';
          _buttonTitle = '프리미엄 6개월 정기 구독 시작하기';
          _buyInfo = '★ 정기결제는 언제든 구독을 해지하실 수 있습니다.\n'
              '★ 계정 가입';
          break;
        }
      case 'new_6m_50':
        {
          _pageTitle = '프리미엄 계정 (6개월 52% 특별 할인)';
          _buttonTitle = '52%이상 할인된 금액으로 프리미엄 시작하기';
          _buyInfo = '★ 첫 6개월간 50% 할인혜택(￦220,000)과 이후 6개월씩부터는 28% 할인혜택(￦330,000)을 모두 드립니다.';
          break;
        }
      case 'new_6m_70':
        {
          _pageTitle = '프리미엄 계정 (6개월 75% 특별 할인)';
          _buttonTitle = '75%이상 할인된 금액으로 프리미엄 시작하기';
          _buyInfo = '★ 첫 6개월간 75% 할인혜택(￦120,000)과 이후 6개월씩부터는 28% 할인혜택(￦330,000)을 모두 드립니다.';
          break;
        }
      case 'new_7d':
        {
          _pageTitle = '프리미엄 계정 100원 (1주일)';
          _buttonTitle = '딱, 100원으로 프리미엄 계정 시작하기';
          _buyInfo = '★ 100원으로 마음껏 프리미엄을 이용해 보세요.';
          break;
        }
    }
  }

  //상품 소개
  Widget _setTopDesc() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.0),
        Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            child: Text(
              '실시간 AI매매신호 무제한 이용부터'
              '\n오직 나만을 위한 매도신호까지'
              '\n모두 실시간 알림으로!',
              style: TStyle.title18T,
            )),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "혼자하는 투자가 어려우세요?"
            "\n대한민국 대표 AI의 전문적인 종목분석과 관리를 받아보세요."
            "\n라씨 매매비서는 투자를 쉽게 만들어 드립니다.",
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
                CustomNvRouteClass.createRouteData(
                  const WebPage(),
                  RouteSettings(
                    arguments: PgData(
                      pgData: Net.AGREE_TERMS,
                    ),
                  ),
                ),
              );
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
                CustomNvRouteClass.createRouteData(
                  const WebPage(),
                  RouteSettings(
                    arguments: PgData(
                      pgData: Net.AGREE_POLICY_INFO,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //정기 결제 버튼
  Widget _setButtonSub() {
    String priceType = '';
    String priceInfo1 = '';
    String priceInfo2 = '';
    String perText = '';
    bool isAt = false;
    bool isNew = false;
    bool onPrText = false;

    switch (pageCode) {
      case 'ad3':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(첫달)';
          priceInfo2 = '30% 특별 할인!';
          isAt = false;
          break;
        }
      case 'ad4':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(첫달)';
          priceInfo2 = '40% 특별 할인!';
          isAt = false;
          break;
        }
      case 'ad5':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(첫달)';
          priceInfo2 = '50% 특별 할인!';
          isAt = false;
          break;
        }
      case 'at1':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(무료체험 7일 후)';
          priceInfo2 = '무료체험 후 결제';
          isAt = true;
          break;
        }
      case 'at2':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(무료체험 14일 후)';
          priceInfo2 = '무료체험 후 결제';
          isAt = true;
          break;
        }

      case 'new_6m':
        {
          priceType = '매월정기결제';
          priceInfo1 = '(6개월 정기)';
          priceInfo2 = '6개월 정기 구독';
          isAt = false;
          break;
        }
      case 'new_6m_50':
        {
          priceType = '6개월씩 정기결제';
          priceInfo1 = '(6개월 이용)';
          priceInfo2 = '52% 이상!';
          perText = '(1달 약 36,600)';
          onPrText = true;
          isAt = false;
          break;
        }
      case 'new_6m_70':
        {
          priceType = '6개월씩 정기결제';
          priceInfo1 = '(6개월 이용)';
          priceInfo2 = '74% 이상!';
          perText = '';
          onPrText = true;
          isAt = false;
          break;
        }
      case 'new_7d':
        {
          priceType = '1주일 결제';
          priceInfo1 = '19200';
          priceInfo2 = '99%이상!';
          isAt = false;
          onPrText = true;
          isNew = true;
          break;
        }
    }

    return Container(
      decoration: UIStyle.boxSelectedLineMainColor(),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceType,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isNew
                          ? _setOrgPriceText(priceInfo1)
                          : Text(
                              priceInfo1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                      const SizedBox(width: 7),
                      Text(
                        isAt ? _priceOriginal : _priceOnce,
                        style: TStyle.title18T,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          onPrText
              ? _setPromotionText(priceInfo2, perText)
              : Text(
                  priceInfo2,
                  style: const TextStyle(
                    color: RColor.sigBuy,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ],
      ),
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
  Widget _setPromotionText(String desc, String perText) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
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
            ),
            perText.isEmpty
                ? const SizedBox(
                    width: 1,
                  )
                : Text(
                    perText,
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
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
    DLog.d(PayPremiumPromotionAosPage.TAG, '# 상품정보 요청');
    DLog.d(PayPremiumPromotionAosPage.TAG, '_getProduct() pageCode : $pageCode');
    List<String> _productLists = [];

    switch (pageCode) {
      case 'ad3':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.ad3'] : ['ios.ac_pr.ad3'];
          _vProductId = _productLists.first;
          break;
        }
      case 'ad4':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.ad4'] : ['ios.ac_pr.ad4'];
          _vProductId = _productLists.first;
          break;
        }
      case 'ad5':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.ad5'] : ['ios.ac_pr.ad5'];
          _vProductId = _productLists.first;
          break;
        }
      case 'at1':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.at1'] : ['ios.ac_pr.at1'];
          _vProductId = _productLists.first;
          break;
        }
      case 'at2':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.at2'] : ['ios.ac_pr.at2'];
          _vProductId = _productLists.first;
          break;
        }

      case 'new_6m':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.am6d0'] : [''];
          _vProductId = _productLists.first;
          break;
        }
      case 'new_6m_50':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.am6d5'] : [''];
          _vProductId = _productLists.first;
          break;
        }
      case 'new_6m_70':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.am6d7'] : [''];
          _vProductId = _productLists.first;
          break;
        }
      case 'new_7d':
        {
          _productLists = Platform.isAndroid ? ['ac_pr.mw1e1'] : [''];
          _vProductId = _productLists.first;
          break;
        }
    }

    if (Platform.isAndroid) {
      DLog.d(PayPremiumPromotionAosPage.TAG, '##### Platform Android 상품정보 요청');

      try {
        final String result = await channel.invokeMethod('getProductList', {'pd_code': _productLists[0]});
        if (result.isNotEmpty) {
          _priceOnce = result;
          DLog.d(PayPremiumPromotionAosPage.TAG, '##### 요청 결과 $result');
        }

        setState(() {});
      } on PlatformException catch (e) {}
      // DLog.d(PayPremiumPage.TAG, '##### Platform Android');
    } else if (Platform.isIOS) {}
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    // DEFINE 23.08.04 프리미엄 케어 서비스 추가
    Navigator.pop(context);
    //basePageState.callPageRoute(const PremiumCarePage());
    /*Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop('complete'); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });*/
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayPremiumPromotionAosPage.TAG, '$trStr $json');

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
    DLog.d(PayPremiumPromotionAosPage.TAG, response.body);
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        final AccountData accountData = data.accountData;
        accountData.initUserStatus();
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
          setState(() {});
        }
        _fetchPosts(
            TR.PROM02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'viewPage': VIEW_PAGE_CODE,
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
