import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/signal_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/login/intro_search_page.dart';
import 'package:rassi_assist/ui/login/join_phone_page.dart';
import 'package:rassi_assist/ui/login/join_pre_user_page.dart';
import 'package:rassi_assist/ui/login/join_route_page.dart';
import 'package:rassi_assist/ui/login/login_rassi_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/inapp_purchase_page.dart';
import 'package:rassi_assist/ui/pay/inapp_purchase_test.dart';
import 'package:rassi_assist/ui/pay/pay_manage_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos_n.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_page.dart';
import 'package:rassi_assist/ui/pay/pay_three_stock.dart';
import 'package:rassi_assist/ui/pay/premium_care_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_issue_page.dart';
import 'package:rassi_assist/ui/sub/notification_list.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_page.dart';
import 'package:rassi_assist/ui/test/halflayer/test_half_layer_main.dart';
import 'package:rassi_assist/ui/test/test_event_popup_page.dart';
import 'package:rassi_assist/ui/test/test_image_fit.dart';
import 'package:rassi_assist/ui/test/test_webview.dart';
import 'package:rassi_assist/ui/test/web_chart.dart';
import 'package:rassi_assist/ui/user/user_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/net.dart';
import '../common/common_appbar.dart';
import 'test_http_page.dart';
import 'test_popup_check.dart';

/// 테스트 페이지
class TestPage extends StatelessWidget {
  static const routeName = '/page_test';
  static const String TAG = "[TestPage]";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: TestWidget(),
    );
  }
}

class TestWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestState();
}

class TestState extends State<TestWidget> {
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = '';
  String _strIp = '';
  String _token = '';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();

    //Notification 알림 설정
    var androidSetting = const AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSetting =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    var initializationSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    _loadPrefData();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _strIp = await getLocalIpAddress(); //Local ip 확인
    _token = (await FirebaseMessaging.instance.getToken()) ?? '';

    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _curProd = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
    });

    DLog.d(TestPage.TAG, "delayed user id : $_userId");
  }

  @override
  Widget build(BuildContext context) {
    // final double itemHeight = (size.height) / 2;
    // final double itemWidth = size.width / 2;
    // DLog.d("### screenHeight : ", screenHeight.toString());

    //현재 컨텍스트의 테마에서 부분 변경할 내용을 변경한다.
    // final newTextTheme = Theme.of(context).textTheme.apply(
    //   bodyColor: Colors.pink,
    //   displayColor: Colors.pink,
    // );
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      backgroundColor: RColor.bgWeakGrey,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '라씨 매매비서의 TEST',
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              // 개발 페이지
              _setTitlePage('개발 페이지'),
              _setGridWidgetDevPage(),

              // 페이지 이동
              _setTitlePage('페이지 이동'),
              _setGridWidgetTestPage(),

              // 결제 페이지
              _setTitlePage('결제 페이지'),
              _setGridWidgetPayPage(),

              // 기타 페이지
              _setTitlePage('기타 페이지'),
              _setGridWidgetEtcPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setTitlePage(String vTitle) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: [
          const DottedLine(
            dashColor: Colors.black,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            vTitle,
            style: TStyle.title18T,
          ),
        ],
      ),
    );
  }

  // 개발 페이지 리스트 Colors.redAccent[100]),
  Widget _setGridWidgetDevPage() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // 하프레이어 + 웹뷰
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '하프레이어',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestHalfLayerMain()),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '배너이미지\n크기체크',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestImageFitPage()),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                'http test',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestHttpPage()),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '팝업 확인',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestPopupCheckPage()),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '이슈상세(사용x)',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              appGlobal.stkCode = '005930';
              appGlobal.stkName = '삼성전자';
              appGlobal.tabIndex = Const.STK_INDEX_HOME;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockIssuePage(),
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '프리미엄케어',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumCarePage(),
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '6시라씨데스크',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RassiDeskPage(),
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '인트로 페이지',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {

            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '웹뷰 테스트',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestWebview(),
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.redAccent[100],
              child: const Text(
                '이벤트팝업테스트',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestEventPopupPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 페이지 이동 리스트 Colors.blueAccent[100]
  Widget _setGridWidgetTestPage() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _setCallUpButton('회원정보', const UserInfoPage(), Colors.blueAccent[100]!),
        _setAButton('정기결제관리', PayManagePage.routeName, Colors.blueAccent[100]!),
        _setAButton('핫_테마', ThemeHotPage.routeName, Colors.blueAccent[100]!),
        _setJoinButton('가입정보', 'PRE', Colors.blueAccent[100]!),
        _setAButton('가입SSG', JoinPhonePage.routeName, Colors.blueAccent[100]!),
        _setJoinButton('joinKakao', 'KAKAO', Colors.blueAccent[100]!),
        _setJoinButton('joinApple', 'APPLE', Colors.blueAccent[100]!),
        _setAButton('Intro\nsearch', IntroSearchPage.routeName, Colors.blueAccent[100]!),
        _setJoinButton('가입경로', 'ROUTE', Colors.blueAccent[100]!),
        _setAButton('라씨\n로그인', RassiLoginPage.routeName, Colors.blueAccent[100]!),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blueAccent[100],
              child: const Text(
                '알림필터',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  _createPageRouteData(
                      NotiListPage(),
                      RouteSettings(
                        arguments: PgData(pgData: 'RN'),
                      )));
            },
          ),
        ),
        _setAButton(
            '알림설정N', NotificationSettingN.routeName, Colors.blueAccent[100]!),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blueAccent[100],
              child: const Text(
                '웹_메인',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                WebChartPage.routeName,
                arguments: PgData(
                  pgData:
                      'https://kiwoom.thinkpool.com?svcJoin=SS&customNo=999999905',
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blueAccent[100],
              child: const Text(
                '웹_마켓뷰',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                WebChartPage.routeName,
                arguments: PgData(
                  pgData: 'https://kiwoom.thinkpool.com/my-stock?svcJoin=SS&customNo=999999905',
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blueAccent[100],
              child: const Text(
                '웹_마이스탁',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                WebChartPage.routeName,
                arguments: PgData(
                  pgData: 'https://kiwoom.thinkpool.com/market-view?svcJoin=SS&customNo=999999905',
                ),
              );
            },
          ),
        ),
        _setAButton('웹뷰', WebChartPage.routeName, Colors.blueAccent[100]!),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blueAccent[100],
              child: const Text(
                '상용웹',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                WebChartPage.routeName,
                arguments: PgData(
                  pgData: 'https://kiwoom.thinkpool.com/',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 결제 페이지 리스트 Colors.green[200],
  Widget _setGridWidgetPayPage() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // 프리미엄 결제 (기존)
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '프리미엄\n결제',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              if (Platform.isIOS) {
                basePageState.callPageRouteUP(const PayPremiumPage());
              }
              if (Platform.isAndroid) {
                basePageState.callPageRouteUP(const PayPremiumAosPage());
              }
            },
          ),
        ),
        // 프리미엄 결제 new (android)
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[300],
              child: const Text(
                '프리미엄\n결제 New',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              if (Platform.isIOS) {
                basePageState.callPageRouteUP(const PayPremiumPage());
              }
              if (Platform.isAndroid) {
                basePageState.callPageRouteUP(const PayPremiumAosPage());
              }
            },
          ),
        ),
        // 3종목 결제
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '3종목\n결제',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              basePageState.callPageRouteUP(const PayThreeStock());
            },
          ),
        ),
        // 프리미엄 첫결제 30%
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '첫결제\n30%',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosPage(),
              PgData(data: 'ad3'),
            ),
          ),
        ),
        // 프리미엄 첫결제 40%
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '첫결제\n40%',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosPage(),
              PgData(data: 'ad4'),
            ),
          ),
        ),
        // 프리미엄 첫결제 50%
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '첫결제\n50%',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosPage(),
              PgData(data: 'ad5'),
            ),
          ),
        ),
        // 프리미엄 7일 무료체험
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '7일 무료체험',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosPage(),
              PgData(data: 'at1'),
            ),
          ),
        ),
        // 프리미엄 14일 무료체험
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '14일 무료체험',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosPage(),
              PgData(data: 'at2'),
            ),
          ),
        ),

        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '6개월 정기구독',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosNewPage(),
              PgData(data: 'new_6m'),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '6개월 정기구독(50%)',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosNewPage(),
              PgData(data: 'new_6m_50'),
            ),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                '1주일 이벤트',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => basePageState.callPageRouteUpData(
              Platform.isIOS
                  ? const PayPremiumPromotionPage()
                  : const PayPremiumPromotionAosNewPage(),
              PgData(data: 'new_7d'),
            ),
          ),
        ),


        Builder(
          builder: (context) => InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: Colors.green[200],
                child: const Text(
                  '프로모션 통합\n테스트 페이지',
                  style: TStyle.subTitle,
                ),
              ),
              onTap: () {
                basePageState.callPageRouteUpData(
                  Platform.isIOS
                      ? const PayPremiumPromotionPage()
                      : const PayPremiumPromotionAosPage(),
                  PgData(data: 'at2'),
                );
              }),
        ),

        // 프로모션?
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                'promo2\ncode',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => commonLaunchURL(
                'https://apps.apple.com/redeem?ctx=offercodes&id=1542866202&code=TEST202205'),
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.green[200],
              child: const Text(
                'promo\ncode',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () => commonLaunchURL(
                'https://apps.apple.com/redeem?ctx=offercodes&id=1542866202&code=CODETEST01'),
          ),
        ),

        //결제 테스트?
        _setAButton(
          '[인앱] in_app_purchase',
          InAppPurchase.routeName,
          Colors.green[200]!,
        ),
        _setAButton(
          '[인앱] flutter_inapp',
          InAppPurchaseTest.routeName,
          Colors.green[300]!,
        ),
      ],
    );
  }

  // 기타 페이지 리스트  color: Colors.yellow[300],
  Widget _setGridWidgetEtcPage() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'ID 변경',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              _showDialogId();
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'ATT',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              _requestAppTracking();
              DLog.d(TestPage.TAG, 'local ip : $_strIp');
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'IDFA',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              _requestIDFA();
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'notify',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              // 시뮬레이터 에서는 onSelectNotification 안되는듯, plugin 초기화 실패
              _showNotification(
                  111, 'title', 'content', 'JsonEncoder().convert(message)');
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'TOKEN\n확인',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              DLog.d(TestPage.TAG, _token);
              DLog.d(TestPage.TAG, _token);
              DLog.d(TestPage.TAG, _token);
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'Token\nRemove',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              DLog.d(TestPage.TAG, '## Saved Token remove');
              _prefs.setString(Const.PREFS_SAVED_TOKEN, '');
            },
          ),
        ),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                'Prefer\nRemove',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              DLog.d(TestPage.TAG, '## check days remove');
              _prefs.setString(Const.PREFS_DAY_CHECK_MY, '');
              _prefs.setString(Const.PREFS_DAY_CHECK_ASSIST, '');
            },
          ),
        ),
        _setLogout('Logout', Colors.yellow[300]!),
        Builder(
          builder: (context) => InkWell(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.yellow[300],
              child: const Text(
                '인코딩\n아이디확인',
                style: TStyle.subTitle,
              ),
            ),
            onTap: () {
              DLog.i('userid : $_userId / encodedUserId : ${Net.getEncrypt(_userId)}');
              DLog.i(Net.getEncrypt('01050091424'));
            },
          ),
        ),
      ],
    );
  }

  //확장 리스트형 메뉴
  Widget _setNewList() {
    return ListView.builder(
      itemCount: divList.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          width: double.infinity,
          decoration: UIStyle.boxRoundLine6(),
          child: ExpansionTile(
            title: Row(
              children: [
                const SizedBox(
                  width: 5.0,
                ),
                Text(
                  divList[i].subItemTitle,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: divList[i].childItem,
          ),
        );
      },
    );
  }

  //TODO : 이렇게 미리 만들어진 리스트 위젯은 context 가 얻어지지 않는듯
  List<TestInfo> divList = [
    TestInfo('회원정보', [
      InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: UIStyle.boxWeakGrey25(),
          child: const Center(
            child: Text(
              '아이디 변경',
              style: TStyle.subTitle16,
            ),
          ),
        ),
        onTap: () {
          // _showDialogId();
        },
      ),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: UIStyle.boxWeakGrey25(),
          child: const Center(
            child: Text(
              '회원정보',
              style: TStyle.subTitle16,
            ),
          ),
        ),
        onTap: () {
          basePageState.callPageRouteUP(const UserInfoPage());
        },
      ),
      const SizedBox(
        height: 10,
      ),
    ]), //200
    TestInfo('페이지', [
      InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: UIStyle.boxWeakGrey25(),
          child: const Center(
            child: Text(
              '종목홈',
              style: TStyle.subTitle16,
            ),
          ),
        ),
        onTap: () {
          // _setMoveStkHomeButton('000270', '기아', 0);
        },
      ),
      const SizedBox(
        height: 10,
      ),
    ]), //260
  ];

  Widget _setAButton(String name, String tRoute, Color color) {
    return Builder(
      builder: (context) => InkWell(
        child: Container(
          padding: const EdgeInsets.all(5),
          color: color,
          child: Text(
            name,
            style: TStyle.subTitle,
          ),
        ),
        onTap: () {
          if (tRoute != '') Navigator.pushNamed(context, tRoute);
        },
      ),
    );
  }

  Widget _setCallUpButton(String name, Widget widget, Color color) {
    return Builder(
      builder: (context) => InkWell(
        child: Container(
          padding: const EdgeInsets.all(5),
          color: color,
          child: Text(
            name,
            style: TStyle.subTitle,
          ),
        ),
        onTap: () {
          if (widget != null) basePageState.callPageRouteUP(widget);
        },
      ),
    );
  }

  Route _createPageRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
    );
  }

  Route _createPageRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
    );
  }

  //회원가입 버튼
  Widget _setJoinButton(String name, String _reqPos, Color color) {
    return Builder(
      builder: (context) => InkWell(
        child: Container(
          padding: const EdgeInsets.all(5),
          color: color,
          child: Text(
            name,
            style: TStyle.subTitle,
          ),
        ),
        onTap: () {
          if (_reqPos == 'ROUTE') {
            Navigator.pushNamed(
              context,
              JoinRoutePage.routeName,
              arguments: PgData(
                  userId: 'userId', pgData: 'email', pgSn: name, flag: 'NAVER'),
            );
          } else if (_reqPos == 'PRE') {
            Navigator.pushNamed(
              context,
              JoinPreUserPage.routeName,
              arguments: PgData(
                userId: 'developtest',
              ),
            );
          }
        },
      ),
    );
  }

  //ID 변경
  void _showDialogId() {
    final _idController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        //팝업에서 폰트 크기를 설정할 경우
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
          child: AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _setSubTitle('ID 변경'),
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
                  Container(
                    padding: const EdgeInsets.all(5),
                    // color: RColor.bgWeakGrey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text('', style: TStyle.commonTitle, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                        // const SizedBox(height: 7.0,),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          decoration: UIStyle.boxRoundLine6(),
                          child: TextField(
                            controller: _idController,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 170,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: RColor.deepBlue,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: const Center(
                          child: Text(
                            'ID 변경하기',
                            style: TStyle.btnTextWht15,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      String sId = _idController.text.trim();
                      if (sId.length == 0) {
                        // showToast('바꿀 아이디 비어있어요');
                      } else {
                        await setUserId(sId);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _setHeaderLine() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  //서브 항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
  }

  setUserId(String uId) async {
    CustomFirebaseClass.fInstance.logEvent(
      name: 'test_page_id_change',
      parameters: <String, dynamic>{
        'before_user_id': _userId,
        'after_user_id': uId,
      },
    );
    AppGlobal().setLogoutStatus();
    AppGlobal().userId = uId;
    await _prefs.setString(Const.PREFS_USER_ID, uId);

    Provider.of<UserInfoProvider>(context, listen: false).init();
    Provider.of<PocketProvider>(context, listen: false).setList();
    Provider.of<SignalProvider>(context, listen: false).setList();
  }

  void _getNaverInfo() async {
    NaverLoginResult result = await FlutterNaverLogin.logIn();
    DLog.d(TestPage.TAG, '####### NAVER ${result.account.name}');
  }

  //디바이스 정보
  void _getDeviceInfo() async {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    DLog.d(TestPage.TAG, '00000 : ${iosInfo.model}');
    DLog.d(TestPage.TAG, '11111 : ${iosInfo.name}');
    DLog.d(TestPage.TAG, '22222 : ${iosInfo.systemName}');
    DLog.d(TestPage.TAG, '44444 : ${iosInfo.localizedModel}');
    DLog.d(TestPage.TAG, '55555 : ${iosInfo.isPhysicalDevice}');
    DLog.d(TestPage.TAG, '66666 : ${iosInfo.identifierForVendor}');
    DLog.d(TestPage.TAG, '77777 : ${iosInfo.utsname.sysname}');
    DLog.d(TestPage.TAG, '88888 : ${iosInfo.utsname.nodename}');

    DLog.d(TestPage.TAG, '+++++ : ${iosInfo.systemVersion}');
    DLog.d(TestPage.TAG, '+++++ : ${iosInfo.utsname.machine}');
    DLog.d(TestPage.TAG, 'Current Product : $_curProd');
  }

  static Future<String> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface =
          interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface =
            interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) =>
              !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (ex) {
          return '';
        }
      }
    }
  }

  //로그아웃 잘 안되는듯
  void makeRoutePage({required BuildContext context, required Widget desPage}) {
    // statefull 에서 프리퍼런스 아이디 초기화
    //방법1
    // Navigator.popUntil(context, ModalRoute.withName(RassiLoginPage.routeName));
    //방법2
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => desPage),
      (route) => false,
    );
    //방법3
    // Navigator.of(context).pushNamedAndRemoveUntil(RassiLoginPage.routeName, (route) => false);
  }

  Widget _setLogout(String name, Color color) {
    return Builder(
      builder: (context) => InkWell(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          color: color,
          child: Text(
            name,
            style: TStyle.subTitle,
          ),
        ),
        onTap: () {
          makeRoutePage(context: context, desPage: const RassiLoginPage());
        },
      ),
    );
  }

  //Foreground 상태에서 Notification 등록
  Future<void> _showNotification(
      int pushSn, String title, String body, String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('think_android', 'think_android',
            channelDescription: 'think_android',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin
        .show(pushSn, title, body, platformChannelSpecifics, payload: payload);
  }

  //App Tracking Transparency (ATT 팝업 : 설치 후 한번만 노출됨)
  void _requestAppTracking() async {
    try {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } on PlatformException {
      DLog.d(TestPage.TAG, 'AppTracking request Exception');
    }
  }

  void _requestIDFA() async {
    try {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.authorized) {
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
        DLog.d(TestPage.TAG, 'IDFA => $uuid');
        // _showNotification(12347, 'IDFA', uuid, '');
        commonShowToast(uuid);
      }
    } on PlatformException {
      DLog.d(TestPage.TAG, 'AppTracking request Exception');
    }
  }

  /// https://apps.apple.com/us/app/라씨-매매비서/id1542866202
  /// https://apps.apple.com/kr/app/%EB%9D%BC%EC%94%A8-%EB%A7%A4%EB%A7%A4%EB%B9%84%EC%84%9C/id1542866202
  String getStoreUrl() {
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=packageName";
    } else if (Platform.isIOS)
      return "https://apps.apple.com/kr/app/%EB%9D%BC%EC%94%A8-%EB%A7%A4%EB%A7%A4%EB%B9%84%EC%84%9C/id1542866202";
    else
      return '';
  }

  //강제 업데이트 팝업
  void _showVersion() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Text('업데이트 알림',
                      style: TStyle.defaultTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(RString.need_to_app_update,
                      textAlign: TextAlign.center,
                      style: TStyle.defaultContent,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text('확인',
                              style: TStyle.btnTextWht16,
                              textScaleFactor: Const.TEXT_SCALE_FACTOR),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      commonLaunchURL(getStoreUrl());
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class TestInfo {
  final String subItemTitle;
  final List<Widget> childItem;

  TestInfo(this.subItemTitle, this.childItem);
}

/*class CustomAppBar extends PreferredSizeWidget {
  final Widget child;
  final double height;

  CustomAppBar({this.child, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      // color: Colors.orange,
      alignment: Alignment.center,
      child: child,
    );
  }
}*/
