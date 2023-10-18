import 'package:flutter/material.dart';


// const 는 컴파일 시점에 상수화 된다. final 은 런타임에 상수화 된다.(생성시 설정 가능)
class Const {
  static const bool isDebuggable = true;    //출시버전[false] / 개발버전[true]
  //static const BASE = "rassiapp";           //상용 서버
  static const BASE = "rassiappdev";        //개발 서버
  static const APP_VER = '1.1.3';          //TODO 빌드 번호 가져오는 방법
  static const VER_CODE = 43;
  static const bool isSkeletonLoader = true;

  /// android set
  static const APP_VER_AOS = '1.1.4';      //안드로이드 버전
  static const VER_CODE_AOS = 104;
  static const METHOD_CHANNEL_NAME = 'thinkpool.flutter.dev/channel_method';
  static const METHOD_CHANNEL_PUSH = 'thinkpool.flutter.dev/channel_method_push';

  static const PREFS_USER_ID = "rassi_id";
  static const PREFS_CUR_PROD = "current_product";    //현재 사용중인 상품 (TODO 하루 한번 갱신??)
  static const PREFS_DEVICE_ID = 'device_id';         //디바이스 아이디(UUID)
  static const PREFS_SAVED_TOKEN = 'push_token';      //FB Push token

  static const PREFS_FREE_SEARCH = 'limit_free_search';         //하루 무료 검색 5건
  static const PREFS_DAY_CHECK_PUSH = 'day_push_set_check';     //20210303
  static const PREFS_DAY_CHECK_AD_M = 'day_marketing_check';    //마케팅 동의 체크 20210303 [String]
  static const PREFS_DAY_CHECK_AD_HOME = 'day_check_ad_home';   //AD Popup home
  static const PREFS_FIRST_INSTALL_APP = 'first_install_app';   //설치 후 처음 home 화면 진입 [bool]

  static const PREFS_DAY_CHECK_MY = 'day_check_my';             //20210809  MY 페이지 한번 체크
  static const PREFS_DAY_CHECK_ASSIST = 'day_check_assist';     //20210809  매매비서 페이지 한번 체크

  static const PREFS_PAY_FINISHED = 'pay_finished';     //결제시도 후 결제가 완료되지 않았을때(InApp01): false / 그외에 true [bool]


  //딥링크 / 마케팅 / 가입경로
  //static const PREFS_DEFERRED_DEEPLINK = 'deferred_deeplink';   //디퍼드 딥링크
  static const PREFS_DEEPLINK_ROUTE = 'deeplink_route';         //딥링크 route
  static const PREFS_AD_DEEPLINK = 'ad_deeplink';               //딥링크
  static const PREFIX_ROUTE = 'deeplink_custom_path';           //prefix 가입경로
  static const PREFIX_PAGE = 'm_adtouch_custom_url';            //prefix 페이지경로
  //static const JOIN_ROUTE_YNR = 'OLLAYNR';                      //애드브릭스 YNR JoinRoute
  //static const PREFS_DEEPLINK_ORG = 'deeplink_org';             //디퍼드 딥링크 들어온 내용 그대로 저장(OLLAYNR_01)

  static const TEXT_SCALE_FACTOR = 1.0;
  static const HEIGHT_APP_BAR = 55.0;
  static const HEIGHT_PKT_ADD_CIRCLE = 220.0;         //포켓 종목 추가 Circle 높이

  static const int STK_INDEX_HOME = 0;                //종목홈_홈
  static const int STK_INDEX_SIGNAL = 1;              //AI 매매신호
  //static const int STK_INDEX_NEWS = 2;                //AI 속보 (라씨로 뉴스)
  //static const int STK_INDEX_KEYWORD = 3;             //키워드 & 이슈
  //static const int STK_INDEX_COMPARE = 4;             //종목비교
  //static const int STK_INDEX_SOCIAL = 5;              //소셜지수
  //static const int STK_INDEX_TIMELINE = 6;            //종목소식(타임라인)
  //static const int STK_INDEX_DISCLOS = 7;             //공시
  //static const int STK_INDEX_INFO = 8;                //종목정보

}

//컬러설정 ==========
class RColor {
  static const mainColor = Color(0XFF7774F7);   //메인 컬러
  static const deepBlue = Color(0xff3B3982);    //메인 어두운 블루
  static const deepStat = Color(0xff353c73);    //status bar 블루
  static const bgMyPage = Color(0xfff9fafc);
  static const bgWeakGrey = Color(0xffF3F4F8);
  static const bgTableGrey = Color(0xfff0f0f0);
  static const bgTableTextGrey = Color(0xff8c8c8c);
  static const lineGrey = Color(0xffd1d1d1);
  static const lineGrey2 = Color(0xffc4c4c4);
  static const lineGrey3 = Color(0xffe7e7e7);
  static const iconGrey = Color(0xff7a7979);
  static const new_basic_grey = Color(0xffF9F9F9);
  static const new_basic_box_grey = Color(0xfff1f1f1);
  static const new_basic_line_grey = Color(0xffdadada);
  static const new_basic_text_color_grey = Color(0xff8C8C8C);
  static const new_basic_text_color_strong_grey = Color(0xff606569);
  static const btnUnSelectGreyBg = Color(0xffF5F5F5);
  static const btnUnSelectGreyStroke = Color(0xffD2D2D2);
  static const btnUnSelectGreyText = Color(0xff999999);

  static const chartRedColor = Color(0xffFF5050);
  static const chartRedColordd = Color(0xfffa8383);
  static const chartGreyColor = Color(0xffDCDFE2);
  static const chartTradePriceColor = Color(0xff454A63);

  static const naver = Color(0xff3EC729);       //네이버 컬러
  static const kakao = Color(0xfffee500);       //카카오 컬러
  static const bgGoogle = Color(0xff4285f4);    //구글 로그인 컬러
  static const bgPink = Color(0xfff9c3e7);      //배경 핑크 영역
  static const bgWeakBora = Color(0xfff5f3ff);  //배경 옅은 보라
  static const bgSignal = Color(0xffa8a4fb);    //배경 주황 -> 보라 영역(Signal)
  static const bgBuy = Color(0xfffd7d7e);       //배경 주황 영역, 보유중 표시 (Signal)
  static const bgSell = Color(0xff6a87e8);      //배경 매도 영역,
  static const bgGrey = Color(0xffd5d5e1);      //관망중 표시 (Signal)
  static const yonbora = Color(0xffdfd4ff);     //연보라
  static const yonbora1 = Color(0xffe6e0ec);    //연보라1
  static const yonbora2 = Color(0xffccc9fe);    //연보라2
  static const yonbora3 = Color(0xffE9E9FF);    //연보라3
  static const jinbora = Color(0xff7774f7);     //진보라
  static const jinbora_tran = Color(0xb37774f7);//진보라(투명도 추가)
  static const btnAllView = Color(0xff2fccaf);  //모든 매매내역 보기
  static const sigBuy = Color(0xffFC525B);      //매수
  static const sigSell = Color(0xff6A86E7);     //매도
  static const sigHolding = Color(0xff2fccaf);  //보유중
  static const sigWatching = Color(0xff7d81a0); //관망중
  static const bgSolidSky = Color(0xffd5ebff);  //하늘색 (종목 추가)
  static const bgMustard = Color(0xffffcfa5);   //머스타드(겨자색)
  static const bgSkyBlue = Color(0xffd5ebff);   //배경 캐치 종목명
  static const bgBlueCatch = Color(0xff353c73); //배경 캐치 상세, 캐치 종목명 글자색, 이슈 상세 바탕색
  static const bgBlueIssueBtn = Color(0xff5f68b3); //이슈 상세 키워드 버튼 바탕색
  static const bgMintIssue = Color(0xffb3efd5); //배경 이슈 상세
  static const bgMintWeak = Color(0xfff0fafc);  //배경 매매신호 종합보드
  static const bgHolding = Color(0xff55e3a7);   //배경 보유중
  static const bgAiReport = Color(0xff011132);  //배경 분석리포트
  static const socialList = Color(0xffDE7A6B);  //소셜지수 리스트
  static const bgbora = Color(0xff7874F7);      //홈 시그널 보라
  static const orange = Color(0xfffbaf5d);      // 주황
  static const chartLineBasic = Color(0xff94b2ff);

  static const bgPayMonth = Color(0xffffeabd);  //단건 결제 버튼 배경
  static const bgPayYear = Color(0xffd5ebff);   //정기 결제 버튼 배경
  static const chartHighlighColor = Color(0xffe3e0f9);
  static const bubbleChartStrongRed = Color(0xfff95363);
  static const bubbleChartRed = Color(0xfff98f9b);
  static const bubbleChartWeakRed = Color(0xffffd0d0);
  static const bubbleChartStrongBlue = Color(0xff607fdc);
  static const bubbleChartBlue = Color(0xff8ca2dc);
  static const bubbleChartWeakBlue = Color(0xffb5c6f6);
  static const bubbleChartGrey = Color(0xffe3e3e3);
  static const bubbleChartTxtColorRed = Color(0xffc42b60);
  static const bubbleChartTxtColorGrey = Color(0xff6f6f6f);


  //HOME
  static const List<Color> todayText = [
    Color(0xffb29bff),
    Color(0xff76c2ff),
    Color(0xfffcb653),
    Color(0xff4ed79d),
    Color(0xffe091c9),
  ];
  //HOME
  static const List<Color> todayTextBack = [
    Color(0xffded4ff),
    Color(0xffd4ecff),
    Color(0xffffeabc),
    Color(0xffb4efd6),
    Color(0xfff8c3e6),
  ];
  //HOME
  static const List<Color> issueBack = [
    Color(0xff8d88cf),
    Color(0xffe091c9),
    Color(0xfff69383),
    Color(0xfffbb97c),
    Color(0xff82d0af),
    Color(0xff7eb1fc),
  ];
  //HOME
  static const List<Color> issueRelay = [
    Color(0xff6e68be),
    Color(0xffcf6db2),
    Color(0xffdd7b6b),
    Color(0xffe29651),
    Color(0xff59bb91),
    Color(0xff538ce1),
  ];

  //TRADE_ASSIST
  static const List<Color> assistBack = [
    Color(0xffd4ecff),
    Color(0xffded4ff),
    Color(0xfff8c3e6),
    Color(0xfffed4cd),
    Color(0xffffeabc),
    Color(0xffb4efd6),
  ];

  //마켓뷰
  static const List<Color> isuBack = [
    Color(0xff67efd7),
    Color(0xff4fb8b3),
    Color(0xff77ebd4),
    Color(0xff55e3a7),
    Color(0xff58ceb6),
    Color(0xffb3efd5),
  ];
}

//가입경로 ==========
enum JoinRoute {
  OLLATH,     //씽크풀
  OLLAF,      //파이낸셜
  OLLASC,     //SBS 고수외전
  OLLASBS,    //SBS 특집 AI 대 인간
  OLLARSRO,   //라씨로
  OLLAAS,     //플레이스토어
  OLLASH,     //인터넷검색
  OLLAAD,     //광고/홍보
  OLLAHTS,    //보도자료
  OLLAETC,    //기타
}

enum LoginPlatform {
  ssg,
  kakao,
  naver,
  apple,
  rassi,
  google,
  none, // logout
}

