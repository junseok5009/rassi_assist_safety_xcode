import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_app/tr_app01.dart';
import 'package:rassi_assist/ui/login/intro_search_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 2020.08
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// 인트로
class IntroPage extends StatelessWidget {
  static const routeName = '/page_intro';
  static const String TAG = "[IntroPage]";
  static const String TAG_NAME = '앱_인트로';

  const IntroPage({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        brightness: Brightness.light,
        primaryColor: RColor.mainColor,
        // textTheme: TextTheme(
        //   headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold)
        // )
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            //<-- SEE HERE
            // Status bar color
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'NotoSansKR',
        brightness: Brightness.light,
        primaryColor: RColor.mainColor,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
        child: child!,
      ),
      home: Scaffold(
        body: IntroWidget(
          analytics: analytics,
          observer: observer,
        ),
      ),
      routes: routes,
    );
  }
}

class IntroWidget extends StatefulWidget {
  const IntroWidget({Key? key, required this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver? observer;

  @override
  State<StatefulWidget> createState() => IntroState();
}

class IntroState extends State<IntroWidget>
    with SingleTickerProviderStateMixin {
  var appGlobal = AppGlobal();
  static const platform = MethodChannel(Const.METHOD_CHANNEL_NAME);

  final String _appEnv =
      Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20
  final int _appVer = Platform.isIOS ? Const.VER_CODE : Const.VER_CODE_AOS;

  late SharedPreferences _prefs;
  String _userId = "";

  bool _initialized = false; //firebase 초기화
  bool _error = false; //firebase 에러
  bool _isSendTr = false; //2번 호출되는 내용 방지

  // late Uri _latestUri;
  // late StreamSubscription _sub;

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    initFlutterFire();
    super.initState();
    _loadPrefData();

    Future.delayed(Duration.zero, () async {
      AppGlobal().deviceStatusBarHeight = MediaQuery.of(context).padding.top;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var shortestSide = MediaQuery.of(context).size.shortestSide;
        AppGlobal().isTablet = shortestSide > 600;
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        if (info.model != null && info.model!.toLowerCase().contains("ipad")) {
          AppGlobal().isTablet = true;
        } else {
          AppGlobal().isTablet = false;
        }
      }
    });

    initDynamicLinks();
  }

  @override
  void dispose() {
    // _sub.cancel();
    DLog.d(IntroPage.TAG, 'dispose()');
    super.dispose();
  }

  //Firebase 초기화
  void initFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      _error = true;
    }
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();

    //TODO  TEST  TEST   TEST  TEST
    _prefs.setString(Const.PREFS_USER_ID, 'developtest');
    //TODO  TEST  TEST   TEST  TEST

    if (Platform.isAndroid) {
      DLog.d(IntroPage.TAG, '##### Platform Android');
      //Android Native 사용자를 위한 코드
      try {
        final String result = await platform.invokeMethod('getPrefUserId');

        if (result.isNotEmpty) {
          _prefs.setString(Const.PREFS_USER_ID, result);
          _userId = result;
        } else {
          _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
        }
      } on PlatformException {}
      DLog.d(IntroPage.TAG, '##### Platform Android ID: $_userId');
    } else {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    }

    setState(() {
      appGlobal.userId = _userId;
      _prefs.setString(Const.PREFS_DEVICE_ID, Uuid().v4());
    });
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      /*DLog.d('initDynamicLinks()',toastLength: Toast.LENGTH_LONG);
      Fluttertoast.showToast(msg: 'dynamicLinkData.link : ${dynamicLinkData.link}',toastLength: Toast.LENGTH_LONG);
      Fluttertoast.showToast(msg: 'dynamicLinkData.link.path : ${dynamicLinkData.link.path}',toastLength: Toast.LENGTH_LONG);*/
      //Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      debugPrint('onLink error');
      debugPrint(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final queryParams = _latestUri.queryParametersAll.entries.toList();
    // DLog.d(IntroPage.TAG, 'queryParams : $queryParams');

    if (_error) {
      DLog.d(IntroPage.TAG, '##### firebase initialize error');
      Future.delayed(const Duration(seconds: 3), () {
        DLog.d(IntroPage.TAG, 'goNextRoute err: $_userId');
        // _goNextRoute(_userId);
        _requestVersionCheck();
      });
    }

    if (_initialized) {
      if (!_isSendTr) {
        _isSendTr = true;
        DLog.d(IntroPage.TAG, 'firebase initialize complete');
        Future.delayed(const Duration(seconds: 3), () {
          DLog.d(IntroPage.TAG, 'goNextRoute init: $_userId');
          // _goNextRoute(_userId);
          _requestVersionCheck();
        });
      }
    }

    return setIntroUi();
  }

  Widget setIntroUi() {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0XFF7774F7),
        // textTheme: TextTheme(
        //   headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold)
        // )
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            //<-- SEE HERE
            // Status bar color
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0XFF7774F7),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
        child: child!,
      ),
      home: Scaffold(
        backgroundColor: RColor.mainColor,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 20 * 9,
                constraints: const BoxConstraints(
                  maxWidth: 200,
                ),
                child: Image.asset(
                  'images/icon_main_intro.png',
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '라씨 매매비서',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      routes: routes,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: widget.analytics),
      ],
    );
  }

  // 다음 페이지로 이동
  _goNextRoute(String userId) {
    if (userId != '') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const BasePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => IntroSearchPage()));
    }
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
                      // Navigator.pop(context);
                      commonLaunchURL(getStoreUrl());
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// https://apps.apple.com/us/app/라씨-매매비서/id1542866202
  /// https://apps.apple.com/kr/app/%EB%9D%BC%EC%94%A8-%EB%A7%A4%EB%A7%A4%EB%B9%84%EC%84%9C/id1542866202
  String getStoreUrl() {
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=packageName";
    } else if (Platform.isIOS) {
      return "https://apps.apple.com/kr/app/%EB%9D%BC%EC%94%A8-%EB%A7%A4%EB%A7%A4%EB%B9%84%EC%84%9C/id1542866202";
    } else {
      return '';
    }
  }

  //업데이트가 필요한 앱버전 비교
  void _compareVerCode(String? minVer) {
    var intVer = 0;
    if (minVer != null && minVer.length > 0) {
      intVer = int.parse(minVer);
      DLog.d(IntroPage.TAG, 'int version : $intVer');
    }

    //앱 버전이 서버에 설정된 최소버전보다 작다면 강제 업데이트
    if (_appVer < intVer) {
      DLog.d(IntroPage.TAG, '강제 업데이트 버전 : $minVer');
      _showVersion();
    } else {
      DLog.d(IntroPage.TAG, '일반적인 업데이트 버전 : $minVer');
      _goNextRoute(_userId);
    }
  }

  //앱 버전체크
  void _requestVersionCheck() {
    _fetchPosts(
        TR.APP01,
        jsonEncode(<String, String>{
          'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
          'appEnv': _appEnv,
        }));
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
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
                    height: 5.0,
                  ),
                  const Text(
                    '알림',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '확인',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(IntroPage.TAG, '$trStr $json');

    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(IntroPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(IntroPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각 ???
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(IntroPage.TAG, response.body);

    // 버전체크
    if (trStr == TR.APP01) {
      final TrApp01 resData = TrApp01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        DLog.d(IntroPage.TAG, 'APP01 => ${resData.resData.toString()}');
        _compareVerCode(resData.resData?.versionMin);
      } else {
        _goNextRoute(_userId);
      }
    }
  }

// _timerDelay() async {
//   // var duration = new Duration(seconds: 4);
//   // return new Timer(duration, _routeNext);
// }
//
// void _routeNext() {
//   Navigator.pushReplacement(context, MaterialPageRoute(
//       builder: (context) => HomePage()));
// }

/* TODO 추후에 아래 코드 테스트
  const delay = 3;
  widget.countdown = delay;

  StreamSubscription sub;
  sub = new Stream.periodic(const Duration(seconds: 1), (count) {
  setState(() => widget.countdown--);
  if(widget.countdown <= 0) {
    sub.cancel();
    Navigator.pushNamed(context, '/login');
  }
  });
   */
}
