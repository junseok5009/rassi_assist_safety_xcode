import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue03.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi15.dart';
import 'package:rassi_assist/models/tr_sns03.dart';
import 'package:rassi_assist/models/tr_stk_catch03.dart';
import 'package:rassi_assist/models/tr_today/tr_today01.dart';
import 'package:rassi_assist/models/tr_today/tr_today05.dart';
import 'package:rassi_assist/models/tr_user02.dart';
import 'package:rassi_assist/models/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_ddinfo.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_hot_theme.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_mystock_status.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_today_signal.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_trading_stock.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/tr_compare/tr_compare01.dart';
import 'home_tile/home_tile_issue.dart';
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
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  var appGlobal = AppGlobal();
  var inAppBilling;
  late SharedPreferences _prefs;
  String _userId = '';
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  bool _isFirstTurn = true;

  // 땡정보
  String _token = '';
  String _dayCheckPush = '';
  String _dayCheckAD = '';
  String _todayString = '0000';

  // 라씨데스크(땡정보)
  Today05 _today05 = defToday05;

  // 라씨 매매비서의 매매종목은?
  final List<Today01Model> _listToday01Model = [];

  // 커뮤니티 활동 급상승

  // 라씨 매매비서가 캐치한 항목

  // 비교해서 더 좋은 찾기
  Compare01 _compare01 = defCompare01;

  // 지금, 마켓뷰는?

  final List<Issue03> _listIssue03 = [];

  bool bSelPktA = true,
      bSelPktB = false,
      bSelPktC = false,
      bSelPktD = false,
      bSelPktE = false;

  late SwiperController controller;
  final List<StkCatch03> _listCatch03 = []; //이 시간 종목캐치

  List<TagNew> _listTagN = []; //이 시간 추천태그
  final List<Sns03> _socialList = [];

  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';
  String deviceOsVer = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SliverHomeWidget.TAG_NAME,
    );
    _userId = appGlobal.userId;
    _loadPrefData();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _token = (await FirebaseMessaging.instance.getToken()) ?? '';
    _todayString = TStyle.getTodayString();
    _prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      DLog.d(SliverHomeWidget.TAG, 'Device Model : ${iosInfo.utsname.machine}');
      DLog.d(SliverHomeWidget.TAG, 'OS Ver : ${iosInfo.systemVersion}');
      deviceModel = iosInfo.utsname.machine!;
      deviceOsVer = iosInfo.systemVersion!;
    } else if (Platform.isAndroid) {
      inAppBilling = PaymentAosService();
    }

    if (_bYetDispose) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_PUSH) ?? '';
      _dayCheckAD = _prefs.getString(Const.PREFS_DAY_CHECK_AD_HOME) ?? '';
      appGlobal.userId = _userId;
      if (_userId != '') {
        _fetchPosts(
            TR.TODAY05,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    }
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 땡정보
              HomeTileDdinfo(_today05),

              const SizedBox(
                height: 10,
              ),

              // 라씨 매매비서의 매매종목은?
              HomeTileTradingStock(
                listToday01Model: _listToday01Model,
              ),

              _setPrTop(),
              const SizedBox(
                height: 10,
              ),

              // 오늘의 AI매매신호는?
              const HomeTileTodaySignal(),

              Container(
                margin: const EdgeInsets.only(
                  top: 20,
                  bottom: 10,
                ),
                color: const Color(
                  0xffF5F5F5,
                ),
                height: 13,
              ),

              // 내 종목 현황
              const HomeTileMystockStatus(),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(
                  0xffF5F5F5,
                ),
                height: 13,
              ),

              // 이 시간 핫 테마
              const HomeTileHotTheme(),

              // 커뮤니티 활동 급상승
              HomeTileSocial(_socialList),

              // 라씨 매매비서가 캐치한 항목
              const HomeTileStockCatch(),

              // 상단 프로모션
              _setPrHigh(),

              // 비교해서 더 좋은 찾기
              if (_compare01 != null) HomeTileStockCompareList(_compare01),

              // 지금, 마켓뷰는?
              // 이 시간 추천 태그
              _setIssueTag(),

              const SizedBox(
                height: 15.0,
              ),
              _setPrMid(),

              // 오늘의 이슈
              if (_listIssue03.isNotEmpty) HomeTileIssue(_listIssue03),
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
      visible: _listTagN != null && _listTagN.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 15.0,
            margin: const EdgeInsets.only(top: 25),
            color: RColor.new_basic_grey,
          ),
          _setSubTitle("이 시간 추천 태그"),
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: UIStyle.boxWithOpacityNew(),
            child: Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.center,
              children: List.generate(
                  _listTagN.length, (index) => TileChipTag(_listTagN[index])),
            ),
          ),
        ],
      ),
    );
  }

  //프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: _listPrTop.isNotEmpty,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          top: 10,
        ),
        height:
            appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        child: CardProm02(_listPrTop),
      ),
    );
  }

  //프로모션 - 상단
  Widget _setPrHigh() {
    return Visibility(
      visible: _listPrHgh.isNotEmpty,
      child: SizedBox(
        width: double.infinity,
        height:
            appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        child: CardProm02(_listPrHgh),
      ),
    );
  }

  //프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: _listPrMid.isNotEmpty,
      child: SizedBox(
        width: double.infinity,
        height:
            appGlobal.isTablet ? 120 : MediaQuery.of(context).size.width / 3.4,
        child: CardProm02(_listPrMid),
      ),
    );
  }

  //프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: _listPrLow.isNotEmpty,
      child: SizedBox(
        width: double.infinity,
        height:
            appGlobal.isTablet ? 260 : MediaQuery.of(context).size.width / 2,
        child: CardProm02(_listPrLow),
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
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
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
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
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '베이직 계정에서는 3종목까지\n추가가 가능합니다.',
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '종목추가와 포켓을 마음껏 이용할 수 있는\n프리미엄 계정으로 업그레이드 해보세요.',
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
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

  void _showMyBottomSheet(BuildContext context, Prom02 prItem, bool isImage) {
    CustomFirebaseClass.logEvtScreenView('배너_마케팅_팝업_홈');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          maxChildSize: 0.8,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                //===== 헤더
                // Container(
                //   padding: const EdgeInsets.all(10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text('', style: TStyle.defaultTitle,
                //         textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                //       InkWell(
                //         child: Icon(Icons.close, color: Colors.black,),
                //         onTap: () {
                //           Navigator.pop(context);
                //         },
                //       )
                //     ],
                //   ),
                // ),

                //===== 하단 내용부
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 25.0,
                      ),
                      Center(
                        child: Text(
                          prItem.title,
                          style: TStyle.defaultTitle,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),

                      // TXT 형식
                      Visibility(
                        visible: !isImage,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.only(
                              left: 15, right: 10, top: 10),
                          decoration: const BoxDecoration(
                            color: Color(0x55ccc9fe),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Html(
                            data: prItem.content,
                            style: {
                              "html": Style(
                                fontSize: FontSize(15.0),
                                textAlign: TextAlign.center,
                              ),
                            },
                          ),
                        ),
                      ),

                      // IMG 형식
                      Visibility(
                        visible: isImage,
                        child: Container(
                          child: _setNetImage(prItem.content),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),

                      Center(
                        child: MaterialButton(
                          child: Container(
                            width: 185,
                            height: 43,
                            decoration: UIStyle.roundBtnBox25(),
                            child: Center(
                              child: Text(
                                prItem.buttonTxt,
                                style: TStyle.btnTextWht16,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _goLandingPage(prItem);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),

                      // 오늘 그만보기 | 닫기
                      Container(
                        height: 1.0,
                        color: Colors.grey[300],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1)),
                              ),
                              child: MaterialButton(
                                child: const Text(
                                  '오늘 그만보기',
                                  style: TStyle.defaultContent,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _prefs.setString(
                                      Const.PREFS_DAY_CHECK_AD_HOME,
                                      _todayString);
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
                      Container(
                        height: 1.0,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //네트워크 이미지
  Widget _setNetImage(String sUrl) {
    if (sUrl != null || sUrl.isNotEmpty) {
      var img = Image.network(
        sUrl,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext? context, Object? exception, StackTrace? stackTrace) {
          return const Text(
            'No Image',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0x70444444),
            ),
          );
        },
      );
      return img;
    } else {
      //이 부분은 사용안됨
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'No Image',
            textAlign: TextAlign.center,
            style: TStyle.contentMGrey,
          )
        ],
      );
    }
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
        _navigateRefreshPayPromotion(
          context,
          Platform.isIOS
              ? PayPremiumPromotionPage()
              : PayPremiumPromotionAosPage(),
          PgData(data: 'ad5'),
        );
      } else if (prItem.linkPage == 'LPH8') {
        _navigateRefreshPayPromotion(
          context,
          Platform.isIOS
              ? const PayPremiumPromotionPage()
              : PayPremiumPromotionAosPage(),
          PgData(data: 'ad4'),
        );
      } else if (prItem.linkPage == 'LPH9') {
        _navigateRefreshPayPromotion(
          context,
          Platform.isIOS
              ? const PayPremiumPromotionPage()
              : PayPremiumPromotionAosPage(),
          PgData(data: 'ad3'),
        );
      } else if (prItem.linkPage == 'LPHA') {
        _navigateRefreshPayPromotion(
          context,
          Platform.isIOS
              ? const PayPremiumPromotionPage()
              : PayPremiumPromotionAosPage(),
          PgData(data: 'at1'),
        );
      } else if (prItem.linkPage == 'LPHB') {
        _navigateRefreshPayPromotion(
          context,
          Platform.isIOS
              ? const PayPremiumPromotionPage()
              : PayPremiumPromotionAosPage(),
          PgData(data: 'at2'),
        );
      } else {
        basePageState.goLandingPage(prItem.linkPage, '', '', '', '');
      }
    } else if (prItem.linkType == 'URL') {
      basePageState.goLandingPage(LD.web_page, prItem.linkPage, '', '', '');
    } else {}
  }

  //마케팅 팝업 (팝업 형식이 필요할때)
  void _showDialogMarketing(
      String title, String txtHtml, String btnText, String desUrl) {
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
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding:
                        const EdgeInsets.only(left: 15, right: 10, top: 10),
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
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                            border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 1)),
                          ),
                          child: MaterialButton(
                            child: const Text(
                              '오늘 그만보기',
                              style: TStyle.defaultContent,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _prefs.setString(
                                  Const.PREFS_DAY_CHECK_AD_HOME, _todayString);
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
          builder: (context) => WebPage(),
          settings: RouteSettings(
            arguments: PgData(pgData: desUrl),
          ),
        ));
  }

  navigateRefreshPay() async {
    final result = await Navigator.push(
      context,
      Platform.isIOS
          ? _createRoute(PayPremiumPage())
          : _createRoute(PayPremiumAosPage()),
    );
    if (result == 'cancel') {
      DLog.d(SliverHomeWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverHomeWidget.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  _navigateRefreshPayPromotion(
      BuildContext context, Widget instance, PgData pgData) async {
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

  //페이지 전환 에니메이션
  Route _createRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
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

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverHomeWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverHomeWidget.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  //비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각 / 전체 싱글스레트 기반도 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverHomeWidget.TAG, response.body);

    if (trStr == TR.TODAY05) {
      final TrToday05 resData = TrToday05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _today05 = resData.retData;
      } else {
        _today05 = defToday05;
      }
      setState(() {});
      _fetchPosts(
          TR.TODAY01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    else if (trStr == TR.TODAY01) {
      final TrToday01 resData = TrToday01.fromJson(jsonDecode(response.body));
      _listToday01Model.clear;
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
          TR.ISSUE03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.ISSUE03) {
      final TrIssue03 resData = TrIssue03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Issue03> list = resData.listData;

        setState(() {
          _listIssue03.clear();
          _listIssue03.addAll(list);
        });
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
          TR.STKCATCH03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //이 시간 종목캐치
    else if (trStr == TR.STKCATCH03) {
      _listCatch03.clear();
      final TrStkCatch03 resData =
          TrStkCatch03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          _listCatch03.addAll(resData.retData);
        }
      }

      _fetchPosts(
          TR.SNS03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '3',
          }));
    }

    //소셜 HOT
    else if (trStr == TR.SNS03) {
      _socialList.clear();
      final TrSns03 resData = TrSns03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.listData.isNotEmpty) {
          _socialList.addAll(resData.listData);
        }
      }

      setState(() {});

      _fetchPosts(
          TR.COMPARE01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.COMPARE01) {
      final TrCompare01 resData =
          TrCompare01.fromJson(jsonDecode(response.body));
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
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));

      /* resData.retCode = RT.SUCCESS;
      resData.retData.add(
        Prom02(
          promoSn: "261",
          viewPage: "LPE1",
          viewPosition: "HGH",
          promoDiv: "BANNER",
          contentType: "IMG",
          title: "테스트테스트",
          content:
              "http://files.thinkpool.com/rassiPrm/0106eldercall_F9EDD7.jpg",
          linkType: "APP",
          linkPage: "LPHA",
          popupBlockTime: "1D",
        ),
      );

      resData.retData.add(
        Prom02(
          promoSn: "261",
          viewPage: "LPE1",
          viewPosition: "TOP",
          promoDiv: "BANNER",
          contentType: "IMG",
          title: "테스트테스트",
          content:
              "http://files.thinkpool.com/rassiPrm/0106eldercall_F9EDD7.jpg",
          linkType: "APP",
          linkPage: "LPHA",
          popupBlockTime: "1D",
        ),
      );

      resData.retData.add(
        Prom02(
          promoSn: "261",
          viewPage: "LPE1",
          viewPosition: "MID",
          promoDiv: "BANNER",
          contentType: "IMG",
          title: "테스트테스트",
          content:
              "http://files.thinkpool.com/rassiPrm/0106eldercall_F9EDD7.jpg",
          linkType: "APP",
          linkPage: "LPHA",
          popupBlockTime: "1D",
        ),
      );

      resData.retData.add(
        Prom02(
          promoSn: "261",
          viewPage: "LPE1",
          viewPosition: "LOW",
          promoDiv: "BANNER",
          contentType: "IMG",
          title: "테스트테스트",
          content:
              "http://files.thinkpool.com/rassiPrm/0106eldercall_F9EDD7.jpg",
          linkType: "APP",
          linkPage: "LPHA",
          popupBlockTime: "1D",
        ),
      );*/
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          /*resData.retData.add(Prom02(promoSn: "261", viewPage: "LPE1", viewPosition: "", promoDiv: "POPUP", contentType: "IMG", title: "테스트테스트",
              content: "http://files.thinkpool.com/rassiPrm/0106eldercall_F9EDD7.jpg",
              linkType: "APP",
              linkPage: "LPHA",
              popupBlockTime: "1D",
            buttonTxt: '이동하기'
            ),);*/

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "HGH",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/app1_DBBD6F.png",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "HGH",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/9_1_B8E9FF.png",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "HGH",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/wb005_E6D9CD.jpg",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "TOP",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/soso_EFD9FF.jpg",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "TOP",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/st3_232327.png",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "MID",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/wb005_E6D9CD.jpg",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

          resData.retData.add(
            Prom02(
              promoSn: "328",
              viewPage: "LPB1",
              viewPosition: "MID",
              promoDiv: "BANNER",
              contentType: "IMG",
              title: "알림 설정 안내",
              content: "http://files.thinkpool.com/rassiPrm/app1_DBBD6F.png",
              linkType: "URL",
              linkPage:
                  "https://thinkpoolost.wixsite.com/moneybot/aosalarmsetting",
              popupBlockTime: "1D",
            ),
          );

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
            }
            if (item.promoDiv == 'POPUP') {
              if (item.contentType == 'TXT') {
                DLog.d('tag', '_dayCheckAD : $_dayCheckAD');
                DLog.d('tag', '_todayString : $_todayString');

                if (_dayCheckAD != _todayString) {
                  _showMyBottomSheet(context, item, false);
                }
              } else if (item.contentType == 'IMG') {
                if (_dayCheckAD != _todayString) {
                  _showMyBottomSheet(context, item, true);
                }
              }
            }
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

        if (data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatusAfterPayment();

          if (Platform.isAndroid) {
            if (appGlobal.isFreeUser) inAppBilling.requestPurchaseAsync();
          }
        } else {
          //회원정보 가져오지 못함
          const AccountData().setFreeUserStatus();
        }
        setState(() {});
      } else {
        const AccountData().setFreeUserStatus();
      }

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
                'pushToken': _token,
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
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token);
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
    final http.Response response =
        await http.post(url, headers: Net.think_headers, body: param);

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
