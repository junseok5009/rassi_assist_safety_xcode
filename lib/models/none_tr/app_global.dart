import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:rassi_assist/common/d_log.dart';

/// Singleton 패턴을 이용한 공통 데이터 설정 [ 포켓리스트 / 유료사용자 여부 / 결제정보 / (사용중)상품코드 ..]
/// 설정된 데이터 최근 갱신일
/// https://dart.academy/creational-design-patterns-for-dart-and-flutter-singleton/
class AppGlobal {
  static AppGlobal? _instance;

  factory AppGlobal() => _instance ?? AppGlobal._internal();

  //명명된 생성자 (private 으로 명명된 생성자)
  AppGlobal._internal() {
    _instance = this;
    DLog.d("AppGlobal", "### Singleton Create~~");
  }

  var userId = '';
  var pdCode = '';
  bool isPremium = false;
  bool isFreeUser = true;
  var pageData = '';

  // IOS는 한 애플 계정당 프로모션 전제 상품 중 1회 적용 가능 / AOS는 한 구글 계정당 전체 상품 각 1회 적용 가능
  // 24.02.06 (Only IOS) 프로모션 결제를 한 적이 있는 유저 유무
  //List<String> purchaseHistoryList = [];
  bool isAlreadyPromotionProductPayUser = false;

  // 링크 타고 들어왔을 경우 여기에 넣어두어야 함
  PendingDynamicLinkData? pendingDynamicLinkData;

  //종목홈 일시적 전달 데이터
  String stkCode = '';
  String stkName = '';
  int tabIndex = 0;

  //종목홈_종목비교 일시적 전달 데이터
  String stockGrpCd = '';
  String stockGrpNm = '';

  //웹결제 데이터
  String payType = '';
  String pdSubDiv = '';
  String payAmount = '';
  String orderSn = '';
  String lgTid = '';
  String lgCancelAmt = '';

  //포켓 상태
  var pocketCnt = 1;
  String pktStockCode = '';
  String pktStockName = '';
  String pocketSn = ''; // MY - 포켓 기본 SN
  bool isSignalInfo = false; // MY - 현재가
  String pocketStkCode = ''; //포켓 선택된 종목
  int pocketTodayIndex = 0; //포켓Today sub index

  // 핸드폰 앱바 크기 (배터리, 시간 영역 부분)
  double deviceStatusBarHeight = 0;

  // 디바이스 width, height
  double deviceWidth = 0;
  double deviceHeight = 0;

  // 태블릿(큰 디스플레이)인지 구분
  bool isTablet = false;

  setLogoutStatus() {
    userId = '';
    pdCode = '';
    isPremium = false;
    isFreeUser = true;
    pageData = '';
    stkCode = '';
    stkName = '';
    tabIndex = 0;
  }

// [getter, setter 예시]
// String get userId => _userId;
// set userId(String id) => _userId = id;
}
