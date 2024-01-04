
import 'package:firebase_analytics/firebase_analytics.dart';

class CustomFirebaseClass{
  CustomFirebaseClass._privateConstructor();
  static final fInstance = FirebaseAnalytics.instance;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  // DEFINE screen_view 이벤트
  static void logEvtScreenView(String screenName) async {
    await fInstance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // DEFINE 로그인 이벤트
  static Future<void> logEvtLogin(String loginPlatform) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'login',
      parameters: <String, dynamic>{
        'content_type': loginPlatform,
      },
    );
  }

  // DEFINE 회원가입 이벤트
  static Future<void> logEvtSignUp(String loginPlatform) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'sign_up',
      parameters: <String, dynamic>{
        'content_type': loginPlatform,
      },
    );
    await FirebaseAnalytics.instance.logEvent(
      name: 'sign_up_$loginPlatform',
      parameters: <String, dynamic>{
        'content_type': loginPlatform,
      },
    );
  }

  //FB 검색 종목 기록
  static Future<void> logEvtSignalInfoView(String stockName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'signal_info_view',
      parameters: <String, dynamic>{
        'stock_name': stockName,
        'stock_cnt': 1,
      },
    );
  }

  //FB 검색 결과 기록
  static Future<void> logEvtSearchStock(String stockName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_stock',
      parameters: <String, dynamic>{
        'stock_name': stockName,
        'stock_cnt': 1,
      },
    );
  }

  //FB 관심 종목 등록 : 23.03.03
  static Future<void> logEvtMyPocketAdd(String screenName, String stockName, String stockCode,) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'my_pocket_add',
      parameters: <String, dynamic>{
        'firebase_screen': screenName,
        'firebase_screen_class': screenName,
        'stock_name': stockName,
        'stock_code': stockCode,
      },
    );
  }

  static void setUserProperty(String name, String value) async {
    await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }

  // 홈_홈 화면 라씨데스크[땡정보] 클릭 이벤트
  static Future<void> logEvtDdInfo(String time,) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'click_ddinfo',
      parameters: <String, dynamic>{
        'time': time,
      },
    );
  }

  // 마켓뷰 화면_오늘의 이슈 클릭 이벤트
  static Future<void> logEvtTodayIssue(String keyword,) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'click_today_issue',
      parameters: <String, dynamic>{
        'keyword': keyword,
      },
    );
  }

}

class CustomFirebaseProperty {
  static const LOGIN_STATUS = 'login_status';
  static const SUBS_STATUS = 'subs_status';
  static const PAYING_PD = 'paying_product';
}