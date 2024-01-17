import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/signal_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/inapp_webview_page.dart';
import 'package:rassi_assist/ui/main/my_page.dart';
import 'package:rassi_assist/ui/main/notification_page.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_tab.dart';
import 'package:rassi_assist/ui/signal/signal_today_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/common_class.dart';
import '../home/sliver_home_page.dart';
import '../home/sliver_home_tab.dart';
import '../signal/signal_top_m_page.dart';
import '../signal/signal_top_page.dart';
import '../stock_home/stock_home_tab.dart';

//하단 메인 네비게이션 구성
class BasePage extends StatefulWidget {
  static const routeName = '/page_base';
  static const String TAG = "[BasePage]";

  const BasePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => basePageState;
}

class BasePageState extends State<BasePage> {
/*  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'com.thinkpool.mobile.sinq.push', // id
      '라씨', // title
      description: '라씨 알림', // description
      importance: Importance.max);*/
  final StreamController<String> selectNotificationStream =
      StreamController<String>.broadcast();
  static const channel = MethodChannel(Const.METHOD_CHANNEL_PUSH);

  DateTime? currentPressTime;
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const SliverHomeTabWidget(),
    SliverPocketTab(),
    const NotificationPage(),
    MyPage(),
  ];

  var appGlobal = AppGlobal();

  //var inAppBilling = PaymentService();

  @override
  void initState() {
    super.initState();

    //시작시 포그라운드 푸시 받기 설정
    _setFcmForeground();

    // ===== 포그라운드 상태에서 받은 메시지 내용
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      debugPrint('foreground message =====>');
      if (message != null) {
        Map<String, dynamic> msgData = message.data;
        if (msgData != null) {
          //받은 메시지 내용 ios 로그표시만, android notification 생성
          DLog.d(BasePage.TAG, 'onMessage : ${msgData.toString()}');
          // setAndroidForegroundMessaging(message);
        }
      }
    });

    // ===== 앱이 종료된 상태에서 열릴때
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message){
      debugPrint('onBackgroundOpen =====>');
      if(message != null) {
        Map<String, dynamic> msgData = message.data;
        if (msgData != null) {
          debugPrint('onBackgroundOpen : ${msgData.toString()}');
          _onSelectNotification(msgData);
        }
      } else {
        // _getAndroidBackgroundMessage();
      }
    });

    // ===== 백그라운드 상태 / 포그라운드 상태  메시지 선택했을 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      debugPrint('onMessageOpen =====>');
      if (message != null) {
        Map<String, dynamic> msgData = message.data;
        if (msgData != null) {
          debugPrint('onMessageOpen : ${msgData.toString()}');
          _onSelectNotification(msgData);
        }
      }
    });

    // 안드로이드 채널 생성
    // NOTE 위의 FirebaseMessaging 설정보다 나중에 설정되어야 적용됨
    if (Platform.isAndroid) {
      _setFcmChannelListener();

      // flutter 라이브러리를 이용할 경우
      // _initAndroidNotificationChannel();
      // _configureSelectNotificationSubject();
    }

    // 23.12.01 포켓 프로바이더 데이터 셋팅
    Provider.of<UserInfoProvider>(context, listen: false).init();
    Provider.of<PocketProvider>(context, listen: false).setList();
    Provider.of<SignalProvider>(context, listen: false).setList();

    //_userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    //_userInfoProvider.addListener(listenPayFunction);
  }

  //시작시 포그라운드 푸시 받기 설정
  void _setFcmForeground() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  void dispose() {
    DLog.d(BasePage.TAG, '### BasePage dispose()');
    // didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: _setLayout(),
      ),
    );
  }

  //뒤로가기 2번 종료 (IOS 에서는 필요없고 android 에서만 필요)
  Future<bool> _onWillPop() {
    DateTime now = DateTime.now();
    if (currentPressTime == null || now.difference(currentPressTime ?? now) > const Duration(seconds: 2)) {
      currentPressTime = now;
      commonShowToast('한번 더 뒤로가기를 누르면 앱이 종료됩니다.');
      return Future.value(false);
    }
    // TODO ios 경우 따로 처리
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget _setLayout() {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // unselectedFontSize: 0.0,
        // selectedFontSize: 0.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
//        unselectedItemColor: Colors.grey[900],
        selectedItemColor: RColor.mainColor,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromRGBO(249, 249, 249, 1),
        items: <BottomNavigationBarItem>[
          _buildBottomNavigationItem(
              activeIconPath: 'images/base_tab_home_on.png',
              iconPath: 'images/base_tab_home_off.png'),
          _buildBottomNavigationItem(
              activeIconPath: 'images/base_tab_trade_on.png',
              iconPath: 'images/base_tab_trade_off.png'),
          _buildBottomNavigationItem(
              activeIconPath: 'images/base_tab_notice_on.png',
              iconPath: 'images/base_tab_notice_off.png'),
          _buildBottomNavigationItem(
              activeIconPath: 'images/base_tab_my_on.png',
              iconPath: 'images/base_tab_my_off.png'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationItem(
      {String? activeIconPath, required String iconPath}) {
    return BottomNavigationBarItem(
      activeIcon: activeIconPath == null
          ? null
          : ImageIcon(
              AssetImage(activeIconPath),
              size: 45,
            ),
      icon: ImageIcon(
        AssetImage(iconPath),
        size: 45,
      ),
      label: '',
      // title: Padding(padding: EdgeInsets.all(5),),    //또는 Container(height: 0.0)
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 채널 리스너
  void _setFcmChannelListener() async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'fcm_message') {
        String data = call.arguments;
        _handlePushMessage(data);
        return "데이터 전달 완료";
      }

      throw MissingPluginException();
    });
  }

  /// 푸시 메시지 처리
  void _handlePushMessage(String msg) {
    DLog.d(BasePage.TAG, '# 푸시_handlePushMessage => $msg');

    if (msg != null) {
      Map<String, dynamic> json = jsonDecode(msg);
      _onSelectNotification(json);
    }
  }

  //Notification 선택시 동작
  Future _onSelectNotification(Map<String, dynamic> message) async {
    try {
      // Map<String, dynamic> message = json.decode(payload);
      DLog.d(BasePage.TAG, 'onSelectNotification ~ ${message.toString()}');

      //final String div1 = message['pushDiv1'];
      //final String pushDiv1Name = message['pushDiv1Name'];
      final String linkPage = message['linkPage'];
      final String linkType = message['linkType']; // APP / URL / PAGE
      final String stockCode = message['stockCode'];
      final String stockName = message['stockName'];
      final String pushDiv3 = message['pushDiv3'] ?? '';
      //final String pushDiv2Name = message['pushDiv2Name'];
      //final String pushDate = message['pushDate'];
      final String pocketSn = message['pocketSn'] ?? '';

      DLog.d(BasePage.TAG, 'linkPage : $linkPage');
      DLog.d(BasePage.TAG, 'linkType : $linkType');
      DLog.d(BasePage.TAG, 'stockCode : $stockCode');
      DLog.d(BasePage.TAG, 'stockName : $stockName');

      goLandingPage(linkPage, stockCode, stockName, pushDiv3, pocketSn);
    } catch (e) {
      print(e);
    }
  }

  //다른 페이지에서도 호출됨
  goLandingPage(String landingCode, String stkCode, String stkName,
      String bsType, String pktSn) async {
    switch (landingCode) {
      // [홈_홈]
      case LD.main_home:
      // [홈_AI매매신호]
      case LD.main_signal:
      // [홈_종목캐치]
      case LD.main_catch:
      // [홈_마켓뷰]
      case LD.market_page:
        {
          int pageIndex = landingCode == LD.main_home
              ? 0
              : landingCode == LD.main_signal
                  ? 1
                  : landingCode == LD.main_catch
                      ? 2
                      : landingCode == LD.market_page
                          ? 3
                          : 0;
          if (SliverHomeWidget.globalKey.currentState == null) {
            Provider.of<PageNotifier>(context, listen: false).setPageData(pageIndex);
            setState(() {
              _selectedIndex = 0;
            });
          } else {
            DefaultTabController.of(SliverHomeWidget.globalKey.currentContext!).animateTo(pageIndex);
          }
          break;
        }
      // [오늘 발생한 매매신호(매수)]
      case LD.today_signal:
        {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          // 프리미엄 회원인지 아닌지 체크
          String? userCurProd0 = prefs.getString(Const.PREFS_CUR_PROD);
          if (userCurProd0!.isNotEmpty && userCurProd0.toUpperCase().contains('AC_PR') && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SignalTodayPage(),
                settings: RouteSettings(
                  arguments: PgData(
                    flag: 'B',
                  ),
                ),
              ),
            );
          } else {
            //홈_AI매매신호 == LPB2로
            if (SliverHomeWidget.globalKey.currentState == null) {
              Provider.of<PageNotifier>(context, listen: false).setPageData(1);
              setState(() {
                _selectedIndex = 0;
              });
            } else {
              DefaultTabController.of(SliverHomeWidget.globalKey.currentContext!).animateTo(1);
            }
          }
          break;
        }

      // [메인_종목검색] > (포켓 개편 이후) 포켓
      case LD.main_assist:
      // [메인_포켓_TODAY]
      case LD.pocket_today:
        {
          goPocketPage(Const.PKT_INDEX_TODAY, pktSn: pktSn);
          break;
        }

      // [메인_MY_포켓 상세보기] > (포켓 개편 이후) 포켓
      case LD.pocket_page:
      // [포켓 대시보드] > (포켓 개편 이후) 포켓
      case LD.pocket_board:
      //[메인_포켓_나의 포켓)]
      case LD.pocket_my:
        {
          goPocketPage(Const.PKT_INDEX_MY, pktSn: pktSn);
          break;
        }
      //[메인_포켓_나만의 신호]
      case LD.pocket_signal:
        {
          goPocketPage(Const.PKT_INDEX_SIGNAL, pktSn: pktSn);
          break;
        }
      case LD.main_info:
        {
          setState(() {
            _selectedIndex = 2;
          });
          break;
        }
      // [메인_MY]
      case LD.main_my:
        {
          setState(() {
            _selectedIndex = 3;
          });
          break;
        }
      // [종목홈_홈]
      case LD.stk_home_main:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_HOME);
          break;
        }
      // [종목홈_AI매매신호]
      case LD.stk_home_signal:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_SIGNAL);
          break;
        }
      // [종목홈_AI속보]
      case LD.stk_home_rassiro:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_HOME);
          break;
        }
      // [종목홈_소셜지수]
      case LD.stk_home_social:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_HOME);
          break;
        }
      // [종목홈_종목소식(타임라인)]
      case LD.stk_home_timeline:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_HOME);
          break;
        }
      // [종목홈_종목소식(타임라인)] 중복임 추후에 랜딩코드와 함께 통합해야함
      case LD.stk_home_news:
        {
          goStockHomePage(stkCode, stkName, Const.STK_INDEX_HOME);
          break;
        }
      case LD.LPC2:
        {
          Navigator.push(
            context,
            CustomNvRouteClass.createRoute(
              SearchPage.goStockHome(),
            ),
          );
          break;
        }
      // [성과TOP_적중률]
      case LD.honor_winning_rate:
        {
          Navigator.of(context).pushNamed(
            SignalTopPage.routeName,
            arguments: PgData(pgData: 'HIT'),
          );
          break;
        }
      // [조건별_매수후급]
      case LD.condition_cur_b:
        {
          basePageState.callPageRouteData(const SignalMTopPage(), PgData(pgData: 'CUR_B'));
          break;
        }
      // [계정결제_프리미엄]
      case LD.payment_premium:
        {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          // 프리미엄 회원인지 아닌지 체크
          String? userCurProd = prefs.getString(Const.PREFS_CUR_PROD);
          if (userCurProd!.isNotEmpty && userCurProd.toUpperCase().contains('AC_PR')) {
            if (SliverHomeWidget.globalKey.currentState != null) {
              SliverHomeWidget.globalKey.currentState?.navigateRefreshPay();
            } else {
              // 추후에 하긴 해야함.. 어떤 화면에서 푸시를 받을지 몰라서 갱신을 못해줌
            }
          }
          break;
        }
      // [인앱웹뷰페이지]
      case LD.linkTypeUrl:
        {
          // 인앱 웹뷰 페이지
          if (stkCode != null && stkCode.isNotEmpty) {
            String title = stkName ?? '';
            Navigator.push(
              context,
              Platform.isAndroid
                  ? CustomNvRouteClass.createRouteSlow1(
                      InappWebviewPage(title, stkCode),
                    )
                  : CustomNvRouteClass.createRoute(
                      InappWebviewPage(title, stkCode),
                    ),
            );
          }
          break;
        }
      // [외부링크]
      case LD.linkTypeOutLink:
        {
          // 외부 링크 실행
          if (stkCode != null && stkCode.isNotEmpty) {
            commonLaunchUrlAppOpen(stkCode);
          }
          break;
        }
    }
  }

  //종목홈 안떠있으면 닫지 않고 열기, 종목홈 떠있으면 닫고 종목홈 갱신시키기
  goStockHomePageCheck(BuildContext pageBuildContext, String stockCode, String stockName, int pageIdx) {
    appGlobal.stkCode = stockCode;
    appGlobal.stkName = stockName;
    appGlobal.tabIndex = pageIdx;
    if (StockHomeTab.globalKey.currentState == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockHomeTab(),
        ),
      );
    } else {
      Navigator.pop(pageBuildContext);
      StockHomeTab.globalKey.currentState?.refreshChild();
    }
  }

  //종목홈으로 이동 or 갱신
  Future<String?> goStockHomePage(String stockCode, String stockName, int pageIdx) async {
    appGlobal.stkCode = stockCode;
    appGlobal.stkName = stockName;
    appGlobal.tabIndex = pageIdx;
    String? result = CustomNvRouteResult.cancel;
    if (StockHomeTab.globalKey.currentState == null) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockHomeTab(),
        ),
      );
    } else {
      StockHomeTab.globalKey.currentState?.refreshChild();
    }
    return result;
  }

  //포켓탭으로 이동
  goPocketPage(int tabIndex, {int todayIndex = 0, String pktSn = '', bool isSignalInfo = false}) {
    appGlobal.isSignalInfo = isSignalInfo;
    if (tabIndex == Const.PKT_INDEX_TODAY) {
      appGlobal.pocketTodayIndex = todayIndex;
    } else if (tabIndex == Const.PKT_INDEX_MY) {
      appGlobal.pocketSn = pktSn;
    }
    if (SliverPocketTab.globalKey.currentState == null) {
      Provider.of<PageNotifier>(context, listen: false).setPocketTab(tabIndex);
      setState(() {
        _selectedIndex = 1;
      });
    } else {
      //TODO @@@@@
      // SliverPocketTab.globalKey.currentState?.refreshChildWithMoveTab(tabIndex, changePocketSn: pktSn,);
    }
  }

  // Navigator.pushNamed(context, SearchPage.routeName);
  callPageRoute(Widget instance) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => instance,
        ));
  }

  //아래에서 올라오는 페이지 전환
  callPageRouteUP(Widget instance) {
    Navigator.push(context, _createRoute(instance));
  }

  //아래에서 올라오는 페이지 전환
  callPageRouteUpData(Widget instance, PgData pgData) {
    Navigator.push(
        context,
        _createRouteData(
            instance,
            RouteSettings(
              arguments: pgData,
            )));
  }

  callPageRouteData(Widget instance, PgData pgData) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => instance,
          settings: RouteSettings(
            arguments: pgData,
          ),
        ));
  }

  //탭에서 뉴스 페이지로 전환
  callPageRouteNews(Widget instance, PgNews pgData) {
    Navigator.push(context, _createRouteData(instance, RouteSettings(arguments: pgData)));
  }

  //아래에서 올라오는 페이지 교체
  replacePageRouteUP(Widget instance) {
    Navigator.pushReplacement(context, _createRoute(instance));
  }

  //아래에서 올라오는 페이지 교체
  replacePageRouteUpData(Widget instance, PgData pgData) {
    Navigator.pushReplacement(
      context,
      _createRouteData(
        instance,
        RouteSettings(
          arguments: pgData,
        ),
      ),
    );
  }

  //아래에서 올라오는 뉴스 데이터 페이지 교체
  replacePageRouteUpNews(Widget instance, PgNews pgData) {
    Navigator.pushReplacement(
      context,
      _createRouteData(
        instance,
        RouteSettings(
          arguments: pgData,
        ),
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
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
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

  // 23.11.27
  // 베이스에서 글로벌하게 결제 연동
  // 종목홈 - 진행중
  // 홈 -
  // 포켓 -
  // 알림 -
  // 마이 -
  // etc
  navigateAndGetResultPayPremiumPage() async {
    final result = await Navigator.push(
      context,
      Platform.isIOS
          ? CustomNvRouteClass.createRoute(const PayPremiumPage())
          : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
    );
    if (result == 'cancel') {
    } else {
      if (StockHomeTab.globalKey.currentState != null) {
        var child = StockHomeTab.globalKey.currentState;
        child!.refreshChild();
      }
    }
  }

/*  void _initAndroidNotificationChannel() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //우선 Android만 초기설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid,);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            // if (notificationResponse.actionId == navigationActionId) {
            //   selectNotificationStream.add(notificationResponse.payload);
            // }
            break;
        }
      },
    );
  }

  // Android forground 푸시메시지를 노티피케이션 메시지로 전송
  setAndroidForegroundMessaging(RemoteMessage message) {
    if (Platform.isAndroid) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      Map<String, dynamic> msgData = message.data;

      if (msgData != null) {
        flutterLocalNotificationsPlugin.show(
          msgData['pushSn'] == null ? 0 : int.parse(msgData['pushSn']),
          msgData['pushTitle'],
          msgData['pushContent'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon,
              // other properties...
            ),
          ),
          payload: jsonEncode(msgData),
        );
      }
    }
  }*/

  //Android forground 에서 메시지 처리
  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String payload) async {
      DLog.d(BasePage.TAG, 'SelectNotification : $payload');

      try {
        Map<String, dynamic> result = jsonDecode(payload);
        _onSelectNotification(result);
      } catch (e) {
        debugPrint(e as String?);
      }
    });
  }

//Android backround 에서 생성된 notification 처리
/*void _getAndroidBackgroundMessage() async {
    if (Platform.isAndroid) {
      final NotificationAppLaunchDetails notificationDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationDetails?.didNotificationLaunchApp ?? false) {
        // 이전 알림으로 앱이 열렸을 때 처리할 작업을 수행합니다.
        debugPrint(
            '## getAndroidBackgroundMessage : ${notificationDetails.notificationResponse.payload}');

        if (notificationDetails.notificationResponse != null) {
          if (notificationDetails.notificationResponse.payload.isNotEmpty) {
            try {
              Map<String, dynamic> result =
              jsonDecode(notificationDetails.notificationResponse.payload);
              _onSelectNotification(result);
            } catch (e) {
              debugPrint(e);
            }
          }
        }
      }
    }
  }*/
}

//static ================================================================
BasePageState basePageState = BasePageState();
