import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gif/gif.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/common_function_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_app/tr_app01.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 2020.08.
/// --- 수정 기록 ---
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// 인트로
class IntroPage extends StatelessWidget {
  static const String routeName = "/intro";
  static const String TAG = "[IntroPage]";
  static const String TAG_NAME = '앱_인트로';

  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: false,
        //Flutter 3.16 릴리즈 부터 Material3 기본적용
        fontFamily: 'NotoSansKR',
        brightness: Brightness.light,
        primaryColor: RColor.mainColor,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
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
      navigatorObservers: <NavigatorObserver>[CustomFirebaseClass.observer],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
        ),
        child: child!,
      ),
      home: const Scaffold(
        body: IntroWidget(),
      ),
      routes: routes,
    );
  }
}

class IntroWidget extends StatefulWidget {
  const IntroWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => IntroState();
}

class IntroState extends State<IntroWidget> with SingleTickerProviderStateMixin {
  final _appGlobal = AppGlobal();
  static const _androidChannel = MethodChannel(Const.METHOD_CHANNEL_NAME); //추후 삭제예정
  final MethodChannel _iosMethodChannel = const MethodChannel(Const.METHOD_CHANNEL_LINK_IOS);

  final String _appEnv = Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20
  final int _appVer = Platform.isIOS ? Const.VER_CODE : Const.VER_CODE_AOS;

  late SharedPreferences _prefs;
  String _userId = "";

  @override
  void initState() {
    super.initState();

    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () async {
        if (Platform.isIOS) {
          initIosDynamicLinks();
        } else if (Platform.isAndroid) {
          initAosDynamicLinks();
        }
        initDynamicLinks();
        _appGlobal.deviceWidth = MediaQuery.of(context).size.width;
        _appGlobal.deviceHeight = MediaQuery.of(context).size.height;
        _appGlobal.deviceStatusBarHeight = MediaQuery.of(context).padding.top;
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          var shortestSide = MediaQuery.of(context).size.shortestSide;
          _appGlobal.isTablet = shortestSide > 600;
        } else if (Platform.isIOS) {
          IosDeviceInfo info = await deviceInfo.iosInfo;
          if (info.model != null && info.model!.toLowerCase().contains("ipad")) {
            _appGlobal.isTablet = true;
          } else {
            _appGlobal.isTablet = false;
          }
        }
        _requestVersionCheck();
      });
    });
  }

  @override
  void dispose() {
    DLog.d(IntroPage.TAG, 'dispose()');
    super.dispose();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    // 카카오 로그인 - 디벨로퍼스 DLog.e(await KakaoSdk.origin);
    if (Platform.isAndroid) {
      DLog.d(IntroPage.TAG, '##### Platform Android');
      //Android Native 사용자를 위한 코드
      try {
        final String result = await _androidChannel.invokeMethod('getPrefUserId');
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

    _appGlobal.userId = _userId;
    _prefs.setString(Const.PREFS_DEVICE_ID, const Uuid().v4());
  }

  initIosDynamicLinks() async {
    _iosMethodChannel.setMethodCallHandler((call) async {
      /// ios에서 앱 이미 설치 된 상태에서 Back/fore ground 상태, 혹은 꺼져있는 상태에서 오픈되면 여기서 링크 받아짐.
      String content = call.method;
      FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(content)).then((value) async {
        // 여기에 들어오는 링크가 항상 앱 실행 딥링크라는 보장은 없음.
        Uri? linkUri = value?.link;
        if (linkUri != null) {
          _appGlobal.pendingDynamicLinkData = value;
          if (CommonFunctionClass.instance.isAgentLink(linkUri.toString())) {
            await _prefs.setString(Const.PREFS_DEEPLINK_URI, linkUri.toString());
          }
        }
        DLog.e('value.link : ${value != null ? value.link.toString() : 'null'} / value : ${value.toString()}');
      });
    });
  }

  initAosDynamicLinks() async {
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    /// aos에서 앱 설치된 상태, 링크로 앱 실행시 여기서 링크 값 받아짐.
    if (initialLink != null) {
      _appGlobal.pendingDynamicLinkData = initialLink;
      if (CommonFunctionClass.instance.isAgentLink(initialLink.link.toString())) {
        await _prefs.setString(Const.PREFS_DEEPLINK_URI, initialLink.link.toString());
      }
    }
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      /// ios에서 앱 설치안된 상태에서, 링크로 앱스토어에서 최초 설치 이후 링크 값은 여기서 받아짐.
      /// aos에서 앱 이미 설치 된 상태에서 Back/fore ground 상태에서 링크 받아짐. (꺼져있는 상태에서 오픈되면 안받아짐)

      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link : ${dynamicLinkData.link}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link.host : ${dynamicLinkData.link.host}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link.port : ${dynamicLinkData.link.port}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link.path : ${dynamicLinkData.link.path}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link.query : ${dynamicLinkData.link.query}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.link.fragment : ${dynamicLinkData.link.fragment}');
      DLog.d(IntroPage.TAG, '@@@ dynamicLinkData.utmParameters : ${dynamicLinkData.utmParameters.toString()}');
      _appGlobal.pendingDynamicLinkData = dynamicLinkData;
      if (CommonFunctionClass.instance.isAgentLink(dynamicLinkData.link.toString())) {
        await _prefs.setString(Const.PREFS_DEEPLINK_URI, dynamicLinkData.link.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final queryParams = _latestUri?.queryParametersAll?.entries?.toList();
    // DLog.d(IntroPage.TAG, 'queryParams : $queryParams');

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
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
        ),
        child: child!,
      ),
      home: Scaffold(
          backgroundColor: RColor.purpleBasic_6565ff,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  //textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '언제살까 언제팔까?\n주식 잘하는 방법\n\n',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '라씨 매매비서',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          //fontWeight: FontWeight.w600,
                          fontFamily: 'Godo',
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 20 * 9,
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                    ),
                    child: Gif(
                      autostart: Autostart.loop,
                      image: const AssetImage(
                        'images/gif_intro_main_logo.gif',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
      routes: routes,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: CustomFirebaseClass.analytics),
      ],
    );
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

  // 다음 페이지로 이동
  _goNextRoute(String userId) async {
    // 24.02.07 only ios 프로모션 결제 구입한 이력있는지 체크
    if (Platform.isIOS) {
      await FlutterInappPurchase.instance.initialize();

      try {
        List<PurchasedItem>? purchasedHistoryItemList = await FlutterInappPurchase.instance.getPurchaseHistory();

        List<IAPItem> getProductItemList = await FlutterInappPurchase.instance.getProducts([]);
        List<IAPItem> promotionProductList = [];

        for (var item in getProductItemList) {
          if (item.introductoryPrice != null && item.introductoryPrice!.isNotEmpty) {
            promotionProductList.add(item);
          }
        }
        AppGlobal().isAlreadyPromotionProductPayUser = purchasedHistoryItemList!.any((purchasedHistoryItem) =>
            promotionProductList
                .any((promotionProduct) => promotionProduct.productId == purchasedHistoryItem.productId));
        DLog.e('${IntroPage.TAG} / AppGlobal().isAlreadyPromotionProductPayUser : ${AppGlobal().isAlreadyPromotionProductPayUser}');
      } catch (err) {
        DLog.e('err1 : ${err.toString()}');
      }
    } else if (Platform.isAndroid) {
      // 추후 추가 예정
      /*var channel = const MethodChannel(Const.METHOD_CHANNEL_NAME);
      try {
        //final String result = await channel.invokeMethod('initBillingClient');
        final String purchasesJson = await channel.invokeMethod('getPurchaseHistory');
        if(purchasesJson.isEmpty){
          DLog.e('purchasesJson.isEmpty !!!!');
        }else{
          final List<dynamic> purchases = json.decode(purchasesJson);
          DLog.e('purchasesJson : ${purchases.toString()}');
          for(int a =0; a < purchases.length; a++){
            String aa = purchases[a]['productId'];
            _purchasedHistoryStringList.add(aa);
            DLog.e('productId : $aa');
          }
          setState(() {});
        }
      } catch (e) {
        throw Exception('Failed to get purchase history: $e');
      }*/
    }
    if (mounted) {
      if (userId != '') {
        Navigator.pushReplacementNamed(context, BasePage.routeName,
            result: MaterialPageRoute(builder: (context) => const BasePage()));
      } else {
        Navigator.pushReplacementNamed(
          context,
          IntroStartPage.routeName,
        );
      }
    }
  }

  //강제 업데이트 팝업
  void _showVersion(String url) {
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
                  const Text(
                    '업데이트 알림',
                    style: TStyle.defaultTitle,
                    textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                  ),
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
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                            textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Navigator.pop(context);
                      commonLaunchUrlAppOpen(url);
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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(IntroPage.TAG, 'ERR : SocketException');
      CommonPopup.instance.showDialogNetErr(context);
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

        var intVer = 0;
        var minVer = resData.resData!.versionMin;
        if (minVer != null && minVer.isNotEmpty) {
          intVer = int.parse(minVer);
          DLog.d(IntroPage.TAG, 'int version : $intVer');
        }

        //앱 버전이 서버에 설정된 최소버전보다 작다면 강제 업데이트
        if (_appVer < intVer) {
          DLog.d(IntroPage.TAG, '강제 업데이트 버전 : $minVer');
          _showVersion(resData.resData!.redirectUrl);
        } else {
          DLog.d(IntroPage.TAG, '일반적인 업데이트 버전 : $minVer');
          _goNextRoute(_userId);
        }
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
