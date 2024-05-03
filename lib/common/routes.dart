import 'package:flutter/material.dart';
import 'package:rassi_assist/ui/home/sliver_home_tab.dart';
import 'package:rassi_assist/ui/login/agent/agent_no_link_sign_up_page.dart';
import 'package:rassi_assist/ui/login/agent/agent_sign_up_page.dart';
import 'package:rassi_assist/ui/login/agent/agent_welcome_page.dart';
import 'package:rassi_assist/ui/login/intro_page.dart';
import 'package:rassi_assist/ui/login/intro_search_page.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:rassi_assist/ui/login/join_cert_num_page.dart';
import 'package:rassi_assist/ui/login/join_phone_page.dart';
import 'package:rassi_assist/ui/login/join_pre_user_page.dart';
import 'package:rassi_assist/ui/login/join_rassi_page.dart';
import 'package:rassi_assist/ui/login/login_division_page.dart';
import 'package:rassi_assist/ui/login/login_rassi_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/keyboard_page.dart';
import 'package:rassi_assist/ui/main/my_page.dart';
import 'package:rassi_assist/ui/main/notification_page.dart';
import 'package:rassi_assist/ui/news/catch_list_page.dart';
import 'package:rassi_assist/ui/news/issue_list_page.dart';
import 'package:rassi_assist/ui/news/news_list_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';
import 'package:rassi_assist/ui/pay/inapp_purchase_page.dart';
import 'package:rassi_assist/ui/pay/inapp_purchase_test.dart';
import 'package:rassi_assist/ui/pay/pay_cancel_page.dart';
import 'package:rassi_assist/ui/pay/pay_cancel_sub.dart';
import 'package:rassi_assist/ui/pay/pay_history_page.dart';
import 'package:rassi_assist/ui/pay/pay_manage_page.dart';
import 'package:rassi_assist/ui/pay/pay_test_page.dart';
import 'package:rassi_assist/ui/pay/pay_web_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_setting_page.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_tab.dart';
import 'package:rassi_assist/ui/signal/signal_all_page.dart';
import 'package:rassi_assist/ui/signal/signal_board_page.dart';
import 'package:rassi_assist/ui/signal/signal_hold_stock.dart';
import 'package:rassi_assist/ui/signal/signal_pop_list_page.dart';
import 'package:rassi_assist/ui/signal/signal_today_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_m_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_page.dart';
import 'package:rassi_assist/ui/signal/signal_wait_stock.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_company_overview_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';
import 'package:rassi_assist/ui/sub/ai_version_page.dart';
import 'package:rassi_assist/ui/sub/condition_page.dart';
import 'package:rassi_assist/ui/sub/notification_list.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:rassi_assist/ui/sub/report_page.dart';
import 'package:rassi_assist/ui/sub/social_list_page.dart';
import 'package:rassi_assist/ui/sub/stk_catch_big.dart';
import 'package:rassi_assist/ui/sub/stk_catch_top.dart';
import 'package:rassi_assist/ui/sub/theme_hot_page.dart';
import 'package:rassi_assist/ui/sub/theme_search.dart';
import 'package:rassi_assist/ui/test/notification_setting.dart';
import 'package:rassi_assist/ui/test/test_page.dart';
import 'package:rassi_assist/ui/test/theme_list_page.dart';
import 'package:rassi_assist/ui/test/theme_viewer.dart';
import 'package:rassi_assist/ui/test/web_chart.dart';
import 'package:rassi_assist/ui/user/community_page.dart';
import 'package:rassi_assist/ui/user/terms_page.dart';
import 'package:rassi_assist/ui/user/user_center_page.dart';
import 'package:rassi_assist/ui/user/user_info_page.dart';
import 'package:rassi_assist/ui/user/write_qna_page.dart';
import 'package:rassi_assist/ui/web/web_page.dart';
import 'package:rassi_assist/ui/web/web_viewer.dart';

import '../ui/sub/trade_intro_page.dart';

final routes = {
  BasePage.routeName: (BuildContext context) => const BasePage(),

  IntroPage.routeName: (BuildContext context) => const IntroPage(),
  IntroStartPage.routeName: (BuildContext context) => const IntroStartPage(),
  LoginDivisionPage.routeName: (BuildContext context) => LoginDivisionPage(),

  // 에이전트 회원가입
  AgentSignUpPage.routeName: (BuildContext context) => const AgentSignUpPage(),
  // 에이전트 웰컴
  AgentWelcomePage.routeName: (BuildContext context) => const AgentWelcomePage(),

  // 메인_홈
  '/main_home': (BuildContext context) => const SliverHomeTabWidget(),
  // 메인_포켓
  '/main_pocket': (BuildContext context) => SliverPocketTab(),

  // 메인_알림
  '/main_notification': (BuildContext context) => const NotificationPage(),

  // 메인_MY
  '/main_my': (BuildContext context) => MyPage(),

  // 종목홈_챗GPT기업개요
  StockCompanyOverviewPage.routeName: (
    BuildContext context,
  ) =>
      const StockCompanyOverviewPage(),

  // 종목홈_챗GPT기업개요
  AgentNoLinkSignUpPage.routeName: (
      BuildContext context,
      ) =>
  const AgentNoLinkSignUpPage(),

  MyPage.routeName: (BuildContext context) => MyPage(),
  KeyboardPage.routeName: (BuildContext context) => const KeyboardPage(),
  //SearchPage.routeName: (BuildContext context) => SearchPage(),
  //SearchStockPage.routeName: (BuildContext context) => SearchStockPage(),
  //StockCatchPage.routeName: (BuildContext context) => StockCatchPage(),

  //SignalPage.routeName: (BuildContext context) => SignalPage(),
  //MarketPageN.routeName: (BuildContext context) => MarketPageN(),
  NotificationPage.routeName: (BuildContext context) => const NotificationPage(),
  NotificationSetting.routeName: (BuildContext context) => NotificationSetting(),
  NotificationSettingN.routeName: (BuildContext context) => const NotificationSettingN(),
  NotiListPage.routeName: (BuildContext context) => NotiListPage(),

  TradeIntroPage.routeName: (BuildContext context) => const TradeIntroPage(),
  PocketSettingPage.routeName: (BuildContext context) => const PocketSettingPage(),
  ReportPage.routeName: (BuildContext context) => ReportPage(),
  ConditionPage.routeName: (BuildContext context) => const ConditionPage(),
  StkCatchBigPage.routeName: (BuildContext context) => const StkCatchBigPage(),
  StkCatchTopPage.routeName: (BuildContext context) => const StkCatchTopPage(),
  ThemeListPage.routeName: (BuildContext context) => const ThemeListPage(),
  ThemeViewer.routeName: (BuildContext context) => const ThemeViewer(),
  ThemeSearch.routeName: (BuildContext context) => ThemeSearch(),
  ThemeHotPage.routeName: (BuildContext context) => const ThemeHotPage(),

  IntroSearchPage.routeName: (BuildContext context) => const IntroSearchPage(),
  //LoginDivisionPage.routeName: (BuildContext context) => LoginDivisionPage(),
  RassiLoginPage.routeName: (BuildContext context) => const RassiLoginPage(),
  RassiJoinPage.routeName: (BuildContext context) => const RassiJoinPage(),
  //SsgJoinPage.routeName: (BuildContext context) => SsgJoinPage(),
  //JoinNaverPage.routeName: (BuildContext context) => JoinNaverPage(),
  //JoinKakaoPage.routeName: (BuildContext context) => JoinKakaoPage(),
  JoinPhonePage.routeName: (BuildContext context) => const JoinPhonePage(),
  JoinCertPage.routeName: (BuildContext context) => const JoinCertPage(),
  JoinPreUserPage.routeName: (BuildContext context) => const JoinPreUserPage(),

  SignalTopPage.routeName: (BuildContext context) => SignalTopPage(),
  SignalTodayPage.routeName: (BuildContext context) => const SignalTodayPage(),
  SignalBoardPage.routeName: (BuildContext context) => SignalBoardPage(),
  SignalPopListPage.routeName: (BuildContext context) => const SignalPopListPage(),
  SignalAllPage.routeName: (BuildContext context) => const SignalAllPage(),
  SignalMTopPage.routeName: (BuildContext context) => const SignalMTopPage(),
  SignalHoldPage.routeName: (BuildContext context) => SignalHoldPage(),
  SignalWaitPage.routeName: (BuildContext context) => SignalWaitPage(),

  // 23.04.18 종목 홈 개편
  StockHomeTab.routeName: (BuildContext context) => StockHomeTab(),

  SocialListPage.routeName: (BuildContext context) => const SocialListPage(),
  CatchListPage.routeName: (BuildContext context) => const CatchListPage(),
  NewsListPage.routeName: (BuildContext context) => const NewsListPage(),
  NewsViewer.routeName: (BuildContext context) => const NewsViewer(),
  IssueListPage.routeName: (BuildContext context) => const IssueListPage(),

  WebPage.routeName: (BuildContext context) => const WebPage(),
  WebViewer.routeName: (BuildContext context) => const WebViewer(),
  TermsPage.routeName: (BuildContext context) => TermsPage(),
  AiVersionPage.routeName: (BuildContext context) => const AiVersionPage(),
  UserInfoPage.routeName: (BuildContext context) => const UserInfoPage(),
  CommunityPage.routeName: (BuildContext context) => CommunityPage(),
  UserCenterPage.routeName: (BuildContext context) => const UserCenterPage(),
  WriteQnaPage.routeName: (BuildContext context) => const WriteQnaPage(),

  PayHistoryPage.routeName: (BuildContext context) => const PayHistoryPage(),
  PayManagePage.routeName: (BuildContext context) => PayManagePage(),
  PayWebPage.routeName: (BuildContext context) => const PayWebPage(),
  PayCancelPage.routeName: (BuildContext context) => PayCancelPage(),
  PaySubCancelPage.routeName: (BuildContext context) => const PaySubCancelPage(),
  PayTestPage.routeName: (BuildContext context) => PayTestPage(),
  //PayPremiumPage.routeName: (BuildContext context) => PayPremiumPage(),
  InAppPurchaseTest.routeName: (BuildContext context) => const InAppPurchaseTest(),
  InAppPurchase.routeName: (BuildContext context) => const InAppPurchase(),

  TestPage.routeName: (BuildContext context) => TestPage(),
  WebChartPage.routeName: (BuildContext context) => const WebChartPage(),
  // TestChart.routeName: (BuildContext context) => TestChart(),
  // EChartPage.routeName: (BuildContext context) => EChartPage(),
};

// 랜딩코드
class LD {
  // A 인트로

  // B 홈
  static const String main_home = "LPB1"; //홈_홈
  static const String main_signal = "LPB2"; //AI 매매신호
  static const String market_page = "LPB3"; //마켓뷰
  static const String signal_page1 = "LPB3";
  static const String signal_page2 = "LPB3";
  static const String signal_page3 = "LPB3";
  static const String signal_page4 = "LPB3";
  static const String today_signal = "LPB4"; //오늘 발생한 매매신호(매수)

  // C 매매비서 : 23.12.26 포켓 개편으로 인해 해당 랜딩은 다시 정의합니다.
  static const String main_assist = "LPC1"; //홈_매매비서(검색) > 23.12.26 포켓 개편 : 포켓
  static const String LPC2 = "LPC2"; //종목검색

  // D 알림
  static const String main_info = "LPD1"; //메인_알림

  // E MY
  static const String main_my = "LPE1"; //메인_MY켓
  static const String pocket_page = "LPE2"; //포켓 상세 > 23.12.26 포켓 개편 : 포켓으로 이동
  static const String pocket_add = "LPE4"; //포켓 종목 추가 > 23.12.26 포켓 개편 : 포켓으로 이동
  static const String pocket_setting = "LPE5"; //포켓 설정 > 23.12.26 포켓 개편 : 포켓으로 이동
  static const String pocket_board = "LPEF"; //포켓 보드 > 23.12.26 포켓 개편 : 포켓으로 이동
  static const String main_my_service_center_11_inquiry = "LPEB";
  static const String main_my_service_center_user_private = "LPEC";

  // F 종목홈
  static const String stk_home_main = "LPF1"; //종목홈 홈
  static const String stk_home_signal = "LPF2"; //종목홈 매매신호
  static const String stk_home_rassiro = "LPF3"; //종목홈 AI속보
  static const String stk_home_social = "LPF4"; //종목홈 소셜지수
  static const String stk_home_timeline = "LPF5"; //종목홈 종목소식
  static const String stk_home_news = "LPF6"; //종목홈 종목소식

  // G 종목
  static const String honor_winning_rate = "LPG1"; //성과TOP_적중률
  static const String condition_cur_b = "LPGA"; //조건별_매수후급등

  // H 결제 세부
  static const String payment_premium = "LPH1"; //프리미엄_계정결제
  static const String pay_three_stock = "LPH2"; //3종목알림 결제
  static const String payment_pl_ft50 = "LPH7"; //결제 프로모션 50%
  static const String payment_pl_ft40 = "LPH8"; //결제 프로모션 40%
  static const String payment_pl_ft30 = "LPH9"; //결제 프로모션 30%
  static const String payment_pl_day7 = "LPHA"; //결제 프로모션 7일 무료
  static const String payment_pl_day14 = "LPHB"; //결제 프로모션 14일 무료
  static const String payment_pl_6m_d50 = "LPHE"; //결제 프로모션 첫결제 6개월 50%
  static const String payment_pl_100won = "LPHF"; //1주일 100원 이벤트
  static const String payment_premium_with_6m = "LPHD"; //프리미엄_계정결제(6개월포함)

  // J 매매비서 캐치
  static const String catch_viewer = "LPJ1"; //캐치 상세보기
  static const String catch_list = "LPJ2"; //캐치 히스토리

  // L 종목캐치
  static const String main_catch = "LPL1"; //메인_종목캐치

  // P 포켓
  static const String pocket_today = "LPP1"; //포켓_TODAY ==
  static const String pocket_my = "LPP2"; //포켓_나의 포켓
  static const String pocket_signal = "LPP3"; //포켓_나만의 신호

  // ETC
  static const String linkTypeApp = "APP";
  static const String linkTypeUrl = "URL";
  static const String linkTypeOutLink = "OUTLINK";
}

// TODO 미완성 페이지 전환 에니메이션
/*class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return null;
  }
}*/

// TODO (삭제 예정)
class RouteStr {
  static const String PG_BASE = '/page_base';

  static const String PG_HOME = '/page_home';
  static const String PG_MARKET = '/page_market';
  static const String PG_SIGNAL = '/page_signal';

  static const String PG_INTRO = '/page_intro';
  static const String PG_RASSI_LOGIN = '/page_rassi_login';
  static const String PG_RASSI_JOIN = '/page_rassi_join';

  static const String PG_MY = '/page_my';
  static const String PG_SEARCH = '/page_search';

  static const String PG_TEST = '/page_test';
  static const String PG_CHART = '/page_chart';
}
