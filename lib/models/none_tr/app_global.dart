import 'package:flutter/foundation.dart';
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
  bool isOnPocket = false;
  String pktStockCode = '';
  String pktStockName = '';
  String pocketSn = '';       //포켓 기본 SN
  String pocketStkCode = '';  //포켓 선택된 종목
  int pocketTodayIndex = 0; //포켓Today sub index

  // 핸드폰 앱바 크기 (배터리, 시간 영역 부분)
  double deviceStatusBarHeight = 0;

  // 디바이스 width, height
  double deviceWidth = 0;
  double deviceHeight = 0;

  // 태블릿(큰 디스플레이)인지 구분
  bool isTablet = false;

  setLogoutStatus(){
    userId = '';
    pdCode = '';
    isPremium = false;
    isFreeUser = true;
    pageData = '';
    stkCode = '';
    stkName = '';
    tabIndex = 0;
  }

  // 앱의 view는 변경된 데이터를 얻기 위해 이것을 구독
  final ObserverList<Function(String)> _pageListeners = ObserverList<Function(String)>();

  // PageStatus Listeners를 구독할 수 있습니다.
  addPageStatusChangedListeners(Function callback) {
    isOnPocket = true;
    _pageListeners.add(callback as Function(String));
  }
  // PageStatus Listeners를 취소할 수 있습니다.
  removePageStatusChangedListeners(Function callback) {
    isOnPocket = false;
    _pageListeners.remove(callback as Function(String));
  }

  sendPageStatusRefresh(String status) {
    for (var callback in _pageListeners) {
      callback(status);
    }
  }


// [getter, setter 예시]
// String get userId => _userId;
// set userId(String id) => _userId = id;
}



