import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock11.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi15.dart';
import 'package:rassi_assist/models/tr_today/tr_today01.dart';
import 'package:rassi_assist/models/tr_today/tr_today05.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_ddinfo.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_hot_theme.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_today_signal.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_trading_stock.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/promotion/promotion_page.dart';
import 'package:rassi_assist/ui/web/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/tr_compare/tr_compare01.dart';
import 'home_tile/home_tile_issue.dart';
import 'home_tile/home_tile_mystock_status_2.dart';
import 'home_tile/home_tile_social.dart';
import 'home_tile/home_tile_stock_catch.dart';
import 'home_tile/home_tile_stock_compare_list.dart';

/// 2022.04.12 메인_홈(sliver)
/// 2023.09.07 메인_홈 개편
class SliverHomeWidget extends StatefulWidget {
  static const routeName = '/page_home_sliver';
  static const String TAG = "[SliverHomeWidget]";
  static const String TAG_NAME = '홈_홈';
  static final GlobalKey<SliverHomeWidgetState> globalKey = GlobalKey();

  SliverHomeWidget({Key? key}) : super(key: globalKey);

  @override
  SliverHomeWidgetState createState() => SliverHomeWidgetState();
}

class SliverHomeWidgetState extends State<SliverHomeWidget> {
  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  var appGlobal = AppGlobal();
  var inAppBilling;
  late SharedPreferences _prefs;
  String _userId = '';
  bool _isFirstTurn = true;

  // 땡정보
  String? _token = '';
  String _dayCheckPush = '';
  String _dayCheckAD = '';
  String _todayString = '0000';

  // 라씨데스크(땡정보)
  Today05 _today05 = defToday05;

  // 라씨 매매비서의 매매종목은?
  final List<Today01Model> _listToday01Model = [];

  // 내 종목 현황
  Pock11 _pock11 = Pock11();

  // 비교해서 더 좋은 찾기
  Compare01 _compare01 = defCompare01;

  // 지금, 마켓뷰는?
  final List<Issue03> _listIssue03 = [];

  bool bSelPktA = true, bSelPktB = false, bSelPktC = false, bSelPktD = false, bSelPktE = false;

  late SwiperController controller;

  List<TagNew> _listTagN = []; //이 시간 추천태그

  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];
  final List<Prom02> _listPrPopup = [];

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceModel = '';
  String? deviceOsVer = '';

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SliverHomeWidget.TAG_NAME,
    );
    _userId = appGlobal.userId;
    addAutomaticKeepAlives = true;
    _loadPrefData().then((value) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_PUSH) ?? '';
      _dayCheckAD = _prefs.getString(Const.PREFS_DAY_CHECK_AD_HOME) ?? '';
      appGlobal.userId = _userId;
      _fetchPosts(
          TR.TODAY05,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    });
  }

  Future<void> _loadPrefData() async {
    _token = await FirebaseMessaging.instance.getToken();
    _todayString = TStyle.getTodayString();
    _prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      DLog.d(SliverHomeWidget.TAG, 'Device Model : ${iosInfo.utsname.machine}');
      DLog.d(SliverHomeWidget.TAG, 'OS Ver : ${iosInfo.systemVersion}');
      deviceModel = iosInfo.utsname.machine;
      deviceOsVer = iosInfo.systemVersion;
    } else if (Platform.isAndroid) {
      inAppBilling = PaymentAosService();
    }
  }

  bool addAutomaticKeepAlives = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RColor.bgBasic_fdfdfd,
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(addAutomaticKeepAlives: addAutomaticKeepAlives, [
              const SizedBox(
                height: 15,
              ),

              // 땡정보
              HomeTileDdinfo(
                today05: _today05,
              ),

              const SizedBox(
                height: 20,
              ),

              // 라씨의 종목은?
              HomeTileTradingStock(
                listToday01Model: _listToday01Model,
              ),

              _setPrTop(),
              const SizedBox(
                height: 10,
              ),

              // 오늘의 AI매매신호는?
              HomeTileTodaySignal(),

              CommonView.setDivideLine,

              // 내 종목 현황
              HomeTileMystockStatus2(
                _pock11,
              ),

              CommonView.setDivideLine,

              // 이 시간 핫 테마
              const HomeTileHotTheme(),

              CommonView.setDivideLine,

              // 커뮤니티 활동 급상승
              const HomeTileSocial(),

              CommonView.setDivideLine,

              // 라씨 매매비서가 캐치한 항목
              const HomeTileStockCatch(),

              // 상단 프로모션
              _setPrHigh(),

              CommonView.setDivideLine,

              // 비교해서 더 좋은 찾기
              HomeTileStockCompareList(_compare01),

              CommonView.setDivideLine,

              // 지금, 마켓뷰는?
              // 이 시간 추천 태그
              _setIssueTag(),

              _setPrMid(),

              CommonView.setDivideLine,

              // 오늘의 이슈
              if (_listIssue03.isNotEmpty) HomeTileIssue(listIssue03: _listIssue03),
              const SizedBox(
                height: 15.0,
              ),

              _setPrLow(),
            ]),
          ),
        ],
      ),
    );
  }

  //이 시간 추천 태그
  Widget _setIssueTag() {
    return Visibility(
      visible: _listTagN.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "이 시간 추천 태그",
              style: TStyle.defaultTitle,
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20, bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: UIStyle.boxShadowBasic(16),
              child: Wrap(
                spacing: 7.0,
                alignment: WrapAlignment.center,
                children: List.generate(_listTagN.length, (index) => TileChipTag(_listTagN[index])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: _listPrTop.isNotEmpty,
      child: Container(
        width: double.infinity,
        height: appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: CardProm02(_listPrTop),
      ),
    );
  }

  //프로모션 - 상단
  Widget _setPrHigh() {
    return Visibility(
      visible: _listPrHgh.isNotEmpty,
      child: Container(
        width: double.infinity,
        height: appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: CardProm02(_listPrHgh),
      ),
    );
  }

  //프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: _listPrMid.isNotEmpty,
      child: Container(
        width: double.infinity,
        height: appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: CardProm02(_listPrMid),
      ),
    );
  }

  //프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: _listPrLow.isNotEmpty,
      child: Container(
        width: double.infinity,
        height: appGlobal.isTablet ? 260 : MediaQuery.of(context).size.width / 2,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: CardProm02(_listPrLow),
      ),
    );
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  //마케팅 동의 BottomSheet
  void _setModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 1.0,
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 100.0,
              ),
              Image.asset(
                'images/rassibs_pk_icon_board_1_navy.png',
                height: 30,
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                '라씨 매매비서의 제안',
                style: TStyle.title18,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '설정하신 정보는 ......',
                style: TStyle.textSGrey,
              ),
              const SizedBox(
                height: 40,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: RColor.deepBlue),
                ),
                color: RColor.deepBlue,
                textColor: Colors.white,
                child: const Text('네, 좋아요.', style: TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  //프리미엄 가입하기 다이얼로그
  void showDialogPremium() {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                const Text(
                  '안내',
                  style: TStyle.title20,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '베이직 계정에서는 3종목까지\n추가가 가능합니다.',
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '종목추가와 포켓을 마음껏 이용할 수 있는\n프리미엄 계정으로 업그레이드 해보세요.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.deepBlue,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Center(
                        child: Text(
                          '프리미엄 가입하기',
                          style: TStyle.btnTextWht15,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    navigateRefreshPay();
                    // navigateRefreshPay(context, PayPremiumPage());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMyBottomSheet() {
    if (mounted) {
      CustomFirebaseClass.logEvtScreenView('배너_마케팅_팝업_홈');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet<dynamic>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext bc) {
              return Wrap(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: const Text(
                              '오늘 그만보기',
                              style: TextStyle(
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 1.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(bc);
                            _prefs.setString(
                              Const.PREFS_DAY_CHECK_AD_HOME,
                              _todayString,
                            );
                          },
                        ),
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.pop(bc);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: const Text(
                              'X  닫기',
                              style: TextStyle(
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 1.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: AppGlobal().isTablet
                        ? MediaQuery.of(context).size.width / 2
                        : MediaQuery.of(context).size.width / 1.219,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: _listPrPopup.length == 1
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: _setImgWidget(_listPrPopup[0]),
                          )
                        : Swiper(
                            itemCount: _listPrPopup.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                child: Stack(
                                  children: [
                                    _setImgWidget(_listPrPopup[index]),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          20,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: UIStyle.boxRoundFullColor25c(
                                          Colors.black.withOpacity(0.5),
                                        ),
                                        child: Text(
                                          '${index + 1} / ${_listPrPopup.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            });
      });
    }
  }

  // prom02 바텀시트
  Widget _setImgWidget(Prom02 item) {
    BoxFit boxFit = BoxFit.fill;
    int bgColorInteger = 0xffF3F4F8; // bgWeak
    if (AppGlobal().isTablet) {
      boxFit = BoxFit.fitHeight;
      try {
        int endSubStringInt = item.content.lastIndexOf('.');
        String linkColorCode = '0xff${item.content.substring(endSubStringInt - 6, endSubStringInt)}';
        bgColorInteger = int.parse(linkColorCode);
      } on FormatException {
        bgColorInteger = 0xffF3F4F8;
      } catch (_) {
        bgColorInteger = 0xffF3F4F8;
      }
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: Color(bgColorInteger),
        constraints: const BoxConstraints(
          minWidth: 1,
          minHeight: 1,
        ),
        child: CachedNetworkImage(
          imageUrl: item.content,
          fit: boxFit,
        ),
      ),
      onTap: () async {
        if (_listPrPopup.length == 1) {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 500), () {});
        }
        _goLandingPage(item);
      },
    );
  }

  //공통적으로 랜딩페이지를 이용하기 위한 코드
  void _goLandingPage(
    Prom02 prItem,
  ) {
    if (prItem.linkType == 'APP') {
      // 결제 페이지로 연결일 경우는 일단 따로 처리(결제 후 갱신 처리 필요)
      if (prItem.linkPage == 'LPH1') {
        navigateRefreshPay();
      } else if (prItem.linkPage == 'LPH7') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'ad5'),
        );
      } else if (prItem.linkPage == 'LPH8') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'ad4'),
        );
      } else if (prItem.linkPage == 'LPH9') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'ad3'),
        );
      } else if (prItem.linkPage == 'LPHA') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'at1'),
        );
      } else if (prItem.linkPage == 'LPHB') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'at2'),
        );
      } else if (prItem.linkPage == 'LPHE') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          Platform.isIOS ? PgData(data: 'am6d5') : PgData(data: 'new_6m_50'),
        );
      } else if (prItem.linkPage == 'LPHG') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'new_6m_70'),
        );
      } else if (prItem.linkPage == 'LPHF') {
        navigateRefreshPayPromotion(
          Platform.isIOS ? const PayPremiumPromotionPage() : const PayPremiumPromotionAosPage(),
          PgData(data: 'new_7d'),
        );
      } else if (prItem.linkPage.contains('LPQ')) {
        navigateRefreshPayPromotion(
          PromotionPage(
            promotionCode: prItem.linkPage,
          ),
          PgData(data: ''),
        );
      } else {
        basePageState.goLandingPage(prItem.linkPage, '', '', '', '');
      }
    } else if (prItem.linkType == LD.linkTypeUrl) {
      basePageState.goLandingPage(LD.linkTypeUrl, prItem.linkPage, prItem.title, '', '');
    } else if (prItem.linkType == LD.linkTypeOutLink) {
      basePageState.goLandingPage(LD.linkTypeOutLink, prItem.linkPage, '', '', '');
    } else {}
  }

  //마케팅 팝업 (팝업 형식이 필요할때)
  void _showDialogMarketing(String title, String txtHtml, String btnText, String desUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25), //전체 margin 동작
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    title,
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
                    decoration: const BoxDecoration(
                      color: Color(0x55ccc9fe),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Html(
                      data: txtHtml,
                      style: {
                        "html": Style(
                          fontSize: FontSize(15.0),
                          textAlign: TextAlign.center,
                        ),
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),

                  Center(
                    child: MaterialButton(
                      child: Container(
                        width: 185,
                        height: 40,
                        decoration: UIStyle.roundBtnBox25(),
                        child: Center(
                          child: Text(
                            btnText,
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _openWebView(desUrl);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),

                  // 오늘 그만보기 | 닫기
                  Container(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Colors.grey, width: 1)),
                          ),
                          child: MaterialButton(
                            child: const Text(
                              '오늘 그만보기',
                              style: TStyle.defaultContent,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _prefs.setString(Const.PREFS_DAY_CHECK_AD_HOME, _todayString);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: MaterialButton(
                          child: const Text(
                            '닫기',
                            style: TStyle.defaultContent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openWebView(String desUrl) {
    DLog.d(SliverHomeWidget.TAG, desUrl);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WebPage(),
          settings: RouteSettings(
            arguments: PgData(pgData: desUrl),
          ),
        ));
  }

  navigateRefreshPay() async {
    final result = await Navigator.push(
        context,
        Platform.isIOS
            ? CustomNvRouteClass.createRoute(const PayPremiumPage())
            : CustomNvRouteClass.createRoute(const PayPremiumAosPage()));
    if (result == 'cancel') {
      DLog.d(SliverHomeWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverHomeWidget.TAG, '*** navigateRefresh');
      requestTrUser04();
    }
  }

  navigateRefreshPayPromotion(Widget instance, PgData pgData) async {
    final result = await Navigator.push(
      context,
      _createRouteData(
        instance,
        RouteSettings(
          arguments: pgData,
        ),
      ),
    );
    if (result == 'cancel') {
      DLog.d(SliverHomeWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverHomeWidget.TAG, '*** navigateRefresh');
      requestTrUser04();
    }
  }

  // 23.01.26 JS 추가 > prom02 > tileprom02 (배너) 에서 결제하고 돌아오면 화면 갱신
  requestTrUser04() {
    _fetchPosts(
      TR.USER04,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );
  }

  reload() {
    _fetchPosts(
        TR.TODAY05,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
    if (HomeTileTodaySignal.globalKey.currentState != null) {
      var childCurrentState = HomeTileTodaySignal.globalKey.currentState;
      childCurrentState?.initPage();
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverHomeWidget.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverHomeWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverHomeWidget.TAG, 'ERR : SocketException');
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  //비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각 / 전체 싱글스레트 기반도 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverHomeWidget.TAG, response.body);

    // 라씨데스크
    if (trStr == TR.TODAY05) {
      _today05 = defToday05;
      final TrToday05 resData = TrToday05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _today05 = resData.retData;
      }
      setState(() {});
      _fetchPosts(
          TR.TODAY01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    // 라씨의 종목은?
    else if (trStr == TR.TODAY01) {
      final TrToday01 resData = TrToday01.fromJson(jsonDecode(response.body));
      _listToday01Model.clear();

      if (resData.retCode == RT.SUCCESS) {
        List<Today01> list = resData.listData;
        final List<Today01> listToday01SSIG = [];
        final List<Today01> listToday01BSIG = [];
        final List<Today01> listToday01HOLD = [];
        final List<Today01> listToday01ASK = [];
        if (list.isNotEmpty) {
          list.asMap().forEach((key, value) {
            switch (value.stockDiv) {
              case 'S_24_SIG':
                {
                  listToday01SSIG.add(value);
                  break;
                }
              case 'B_24_SIG':
                {
                  listToday01BSIG.add(value);
                  break;
                }
              case 'HOLD_TOP':
                {
                  listToday01HOLD.add(value);
                  break;
                }
              case 'ASK_TOP':
                {
                  listToday01ASK.add(value);
                  break;
                }
            }
          });
          if (listToday01SSIG.isNotEmpty) {
            _listToday01Model.add(
              Today01Model(
                listToday01SSIG[0].title,
                listToday01SSIG,
              ),
            );
          }
          if (listToday01BSIG.isNotEmpty) {
            _listToday01Model.add(
              Today01Model(
                listToday01BSIG[0].title,
                listToday01BSIG,
              ),
            );
          }

          if (listToday01HOLD.isNotEmpty) {
            _listToday01Model.add(
              Today01Model(
                listToday01HOLD[0].title,
                listToday01HOLD,
              ),
            );
          }
          if (listToday01ASK.isNotEmpty) {
            _listToday01Model.add(
              Today01Model(
                listToday01ASK[0].title,
                listToday01ASK,
              ),
            );
          }
        }
      }
      setState(() {});
      _fetchPosts(
          TR.POCK11,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    // 내 종목 현황
    else if (trStr == TR.POCK11) {
      final TrPock11 resData = TrPock11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pock11 = resData.retData;
        setState(() {});
      }
      _fetchPosts(
          TR.ISSUE03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    // 오늘의 이슈
    else if (trStr == TR.ISSUE03) {
      try {
        final TrIssue03 resData = TrIssue03.fromJson(jsonDecode(response.body));
        _listIssue03.clear();
        if (resData.retCode == RT.SUCCESS) {
          List<Issue03> list = resData.listData;

          setState(() {
            _listIssue03.addAll(list);
          });
        }
      } catch(e) {
        DLog.d(SliverHomeWidget.TAG, '[** Error **] parse issue03: $e');
      }

      _fetchPosts(
          TR.RASSI15,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': 'NEW',
          }));
    }

    //이 시간 추천 태그
    else if (trStr == TR.RASSI15) {
      final TrRassi15 resData = TrRassi15.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listTagN = resData.listData;

        setState(() {});
      }

      _fetchPosts(
          TR.COMPARE01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.COMPARE01) {
      final TrCompare01 resData = TrCompare01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _compare01 = resData.retData;
      }

      _fetchPosts(
          TR.PROM02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'viewPage': 'LPB1',
            'promoDiv': '',
          }));
    }

    //홍보
    else if (trStr == TR.PROM02) {
      _listPrTop.clear();
      _listPrHgh.clear();
      _listPrMid.clear();
      _listPrLow.clear();
      _listPrPopup.clear();
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));

      /*//테스트를 위한 데이터 입니다.
      resData.retCode = RT.SUCCESS;
      resData.retData.add(Prom02(
        title: 'dd',
        viewPosition: 'TOP',
        promoDiv: 'BANNER',
        contentType: 'IMG',
        linkType: 'APP',
        linkPage: 'LPQ1',
        content: 'http://files.thinkpool.com/rassiPrm/tips_FFFAED.jpg',
      ));*/

      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          for (int i = 0; i < resData.retData.length; i++) {
            Prom02 item = resData.retData[i];
            DLog.e('item : ${item.toString()}');
            if (item.promoDiv == 'BANNER') {
              if (item.viewPosition != '') {
                if (item.viewPosition == 'TOP') _listPrTop.add(item);
                if (item.viewPosition == 'HGH') _listPrHgh.add(item);
                if (item.viewPosition == 'MID') _listPrMid.add(item);
                if (item.viewPosition == 'LOW') _listPrLow.add(item);
              }
            } else if (item.promoDiv == 'POPUP' && item.contentType == 'IMG') {
              _listPrPopup.add(item);
            }
          }
          if (_listPrPopup.isNotEmpty && (_dayCheckAD != _todayString)) {
            _showMyBottomSheet();
            //_showMyBottomSheetOriginal(context, _listPrPopup[0], true,);
          }
        }

        setState(() {});
      }

      if (_isFirstTurn) {
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
        _isFirstTurn = false;
      }
    } else if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        DLog.d(SliverHomeWidget.TAG, data.accountData.toString());

        final AccountData accountData = data.accountData;
        accountData.initUserStatusAfterPayment();

        if (Platform.isAndroid) {
          if (appGlobal.isFreeUser) inAppBilling.requestPurchaseAsync();
        }
      } else {
        const AccountData().setFreeUserStatus();
      }
      setState(() {});
      //푸시 재등록 여부(개발모드에서 제외)
      if (!Const.isDebuggable) {
        if (_dayCheckPush != _todayString) {
          DLog.d(SliverHomeWidget.TAG, '하루 한번 호출~${appGlobal.isFreeUser}');
          _prefs.setString(Const.PREFS_DAY_CHECK_PUSH, _todayString);

          _fetchPosts(
              TR.USER02,
              jsonEncode(<String, String>{
                'userId': _userId,
              }));
        }
      }
    } else if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.pushValid == 'N') {
          //푸시 재등록
          _fetchPosts(
              TR.PUSH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'appEnv': 'EN20',
                'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                'pushToken': _token ?? '',
              }));
        }
      }

      //디바이스 정보 등록(일시적) 후 하루 한번 로그인 기록(씽크풀)
      String reqType = 'daily_login';
      String reqParam = "userid=" + Net.getEncrypt(_userId) + '&gb=olla';
      _requestThink(reqType, reqParam);
    }

    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token ?? '');
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }
    }
  }

  // 씽크풀 API 호출 param = 'userid=....
  void _requestThink(String reqType, String param) async {
    DLog.d(SliverHomeWidget.TAG, 'Login param : $param');
    // var url;
    // if(reqType == 'daily_login') {         //로그인 기록
    //   url = Uri.parse(Net.THINK_CHECK_DAILY);
    // } else if(reqType == 'deeplink') {       //
    //   url = Uri.parse(Net.THINK_CHECK_DAILY);
    // }

    String nUrl = '';
    if (reqType == 'daily_login') {
      nUrl = Net.THINK_CHECK_DAILY; //로그인 기록
    } else if (reqType == 'deeplink') {
      nUrl = Net.THINK_EDIT_MARKETING; //회원정보 갱신
    }

    var url = Uri.parse(nUrl);
    final http.Response response = await http.post(url, headers: Net.think_headers, body: param);

    DLog.d(SliverHomeWidget.TAG, '${response.statusCode}');
    DLog.d(SliverHomeWidget.TAG, response.body);

    // ----- Response -----
    if (reqType == 'daily_login') {
      //처음 설치후 디퍼드 딥링크가 있는지 확인
      bool installFirst = _prefs.getBool(Const.PREFS_FIRST_INSTALL_APP) ?? true;
      if (installFirst) {
        //처음 설치 했다면
        _prefs.setBool(Const.PREFS_FIRST_INSTALL_APP, false);
        // _getDeferredDeeplink();
      }
    } else if (reqType == 'deeplink') {}
  }
}
