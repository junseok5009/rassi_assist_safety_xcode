import 'dart:convert';
import 'dart:io';

import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/custom_lib/tripledes/block_cipher.dart';
import 'package:rassi_assist/custom_lib/tripledes/tripledes.dart';

class Net {
  // static const TR_BASE = "https://"+ Const.BASE +".thinkpool.com:56630/rassi_ios/";
  // static const TR_BASE = "https://"+ Const.BASE +".thinkpool.com:56620/rassi_and/";

  static final TR_BASE = Platform.isAndroid
      ? "https://" + Const.BASE + ".thinkpool.com:56620/rassi_and/"
      : "https://" + Const.BASE + ".thinkpool.com:56630/rassi_ios/";

  // static const TR_BASE = "https://rassiappdev.thinkpool.com:56630/rassi_ios/";
  // static const TR_BASE = "https://121.254.150.112:56630/rassi_ios";

  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  static const Map<String, String> think_headers = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
  };

  //네트워크 타임아웃 시간
  static const NET_TIMEOUT_SEC = 12;

  //DES Key
  static const THINK_KEY = "|olla.com|thinkpool.com|";

  //로그인
  static const THINK_LOGIN =
      "https://olla.thinkpool.com/user/api/ajax/callLoginAjax.do";

  //회원가입
  static const THINK_JOIN =
      "https://olla.thinkpool.com/user/api/ajax/userJoinProcAjax.do";

  //인증번호 요청
  static const THINK_CERT_NUM =
      "https://olla.thinkpool.com/user/api/ajax/sendSMSAuthNumAjax.do";

  //인증번호 확인
  static const THINK_CERT_CONFIRM =
      "https://olla.thinkpool.com/user/api/ajax/sendSMSAuthNumProcAjax.do";

  //아이디 중복체크
  static const THINK_CHECK_ID =
      "https://olla.thinkpool.com/user/api/ajax/callProcConfirmIdAjax.do";

  // 회원정보 변경 (마케팅 동의 여부 설정)
  static const THINK_EDIT_MARKETING =
      "https://olla.thinkpool.com/user/api/ajax/userEditProcAjax.do";

  //마케팅 동의 여부 정보
  static const THINK_INFO_MARKETING =
      "https://olla.thinkpool.com/user/api/ajax/userInfoProcAjax.do";

  //간편회원>일반회원 전환
  static const THINK_JOIN_CHANGE_REG =
      "https://olla.thinkpool.com/user/api/ajax/callProcJoinChangeReg.do";

  //SNS 회원 체크
  static const THINK_SNS_LOGIN =
      "https://olla.thinkpool.com//user/api/ajax/callProcChkSNSIDMemberAjax.do";

  //SNS 회원 가입
  static const THINK_SNS_JOIN =
      "https://olla.thinkpool.com/user/api/ajax/callSnsUserJoinAjax.do";

  //비밀번호 변경
  static const THINK_CH_PASS =
      "https://olla.thinkpool.com/user/api/ajax/callProcChgPassWdAjax.do";

  //전화번호 변경
  static const THINK_CH_PHONE =
      "https://olla.thinkpool.com/user/api/ajax/callChangeHpnoAjax.do";

  //회원탈퇴
  static const THINK_USER_CLOSE =
      "http://olla.thinkpool.com/user/api/ajax/callProcThinkDismissAjax.do";

  //씽크풀 게시판
  static const THINK_COMMUNITY = "http://olla.thinkpool.com/bbs/list/s_pub.do";

  //씽크풀 게시판(종목)
  static const THINK_COMMUNITY_STK =
      "http://olla.thinkpool.com/bbs/list/stock_bbs.do?code=";

  //씽크풀 게시판(종목)
  static const NAVER_COMMUNITY_STK =
      "https://m.stock.naver.com/domestic/stock/";

  //씽크풀 게시판_로그인
  static const THINK_COMMUNITY_AJAX =
      "http://olla.thinkpool.com/user/api/ajax/callLoginBridgeAjax.do";

  //씽크풀 로그인 체크 / 결제 완료 체크 (휴면 방지)
  static const THINK_CHECK_DAILY =
      "https://olla.thinkpool.com/user/api/ajax/getUserLoginChkAjax.do";

  //이용약관 22.08.09 수정 HJS
  static const AGREE_TERMS = "https://www.thinkpool.com/policy/service";

  //개인정보 처리방침
  static const AGREE_POLICY_INFO = "https://www.thinkpool.com/policy/privacy";

  //개인정보 수집 및 이용 약관
  static const AGREE_POLICY_INFO_2 =
      "https://files.thinkpool.com/rassi_signal/pr_s_pec_2024.html";

  //저작권 안내
  static const COPYRIGHT_INFO =
      "https://thinkpoolost.wixsite.com/moneybot/%EC%A0%80%EC%9E%91%EA%B6%8C-%EC%95%88%EB%82%B4";

  //자주 묻는 질문
  static const URL_FREQ_QA = "http://thinkpoolost.wixsite.com/moneybot/trasfaq";

  //1:1문의 (카카오톡)
  static const URL_KAKAO_QA = "http://pf.kakao.com/_swxiLxb/chat";

  //1:1문의 (네이버)
  static const URL_NAVER_QA = "https://talk.naver.com/W463TO";

  //AI 엔진 히스토리
  static const URL_ENGINE_VER =
      "http://thinkpoolost.wixsite.com/moneybot/%EB%A7%A4%EB%A7%A4%EB%B9%84%EC%84%9C-ai-%EB%B2%84%EC%A0%BC";

  //종목 로고 파일
  static const URL_IMG_LOGO =
      "http://files.thinkpool.com/radarstock/company_logo/logo_%s.jpg";

  //씽크풀 아이디 찾기
  static const URL_FIND_TP_ID =
      'https://sign.thinkpool.com/user/m/idInquiry.do';

  //씽크풀 비밀번호 찾기
  static const URL_FIND_TP_PW =
      'https://sign.thinkpool.com/user/m/pwInquiry.do';

  // ===== 결제 =====
  static const TR_BASE_PAY =
      'https://rassiapp.thinkpool.com:56610/rassi_pay/lgpay';
  static const TR_BASE_PAY_DEV =
      'https://rassiappdev.thinkpool.com:56610/rassi_pay/lgpay';
  static const TR_PAY_SINGLE = '/default/payReq.do';
  static const TR_PAY_SUB = '/auto/autoPayReq.do';
  static const TR_PAY_CANCEL = '/cancel/cancelReq.do';

  // 씽크풀 암호화
  static String getEncrypt(String data) {
    var blockCipher = BlockCipher(TripleDESEngine(), THINK_KEY);
    String encStr = blockCipher.encodeB64(data);
    return Uri.encodeQueryComponent(encStr,
        encoding: Encoding.getByName('utf-8')!);
  }

  // === TEST URL ===
  static const test_url_json = "https://jsonplaceholder.typicode.com/posts";
}

/// 서버전문
class TR {
  static const APP01 = "TR_APP01";
  static const APP02 = "TR_APP02";
  static const APP03 = "TR_APP03";
  static const ASK01 = "TR_ASK01";
  static const ASK02 = "TR_ASK02";
  static const NOTICE01 = "TR_NOTICE01";

  static const USER01 = "TR_USER01"; //회원계정 생성/탈퇴
  static const USER02 = "TR_USER02"; //회원정보 조회
  static const USER03 = "TR_USER03"; //기기정보 등록
  static const USER04 = "TR_USER04"; //회원의 상품정보 조회
  static const USER05 = "TR_USER05"; //에이전트 - 웰컴페이지 등록

  static const PUSH01 = "TR_PUSH01";
  static const PUSH02 = "TR_PUSH02";
  static const PUSH03 = "TR_PUSH03";
  static const PUSH04 = "TR_PUSH04";
  static const PUSH05 = "TR_PUSH05";
  static const PUSH06 = "TR_PUSH06";
  static const PUSH08 = "TR_PUSH08";
  static const PUSH_LIST01 = "TR_PUSHLIST01"; //알림 일자별 조회
  static const PUSH_LIST02 = "TR_PUSHLIST02"; //알림 분류별 조회

  static const POCK01 = "TR_POCK01"; //포켓 생성/변경/삭제
  static const POCK02 = "TR_POCK02"; //포켓 노출 순서 변경
  static const POCK03 = "TR_POCK03"; //포켓 리스트 조회
  static const POCK04 = "TR_POCK04"; //포켓 상세 조회
  static const POCK05 = "TR_POCK05"; //포켓 종목 등록/가격변경/삭제
  static const POCK06 = "TR_POCK06"; //포켓 종목 노출 순서 변경
  static const POCK07 = "TR_POCK07"; //현재 포켓 매매신호, 매매상태 조회
  static const POCK08 = "TR_POCK08"; //포켓 종목 신호 상태
  static const POCK09 = "TR_POCK09"; //나의 포켓 종목의 현황 조회
  static const POCK10 = "TR_POCK10"; //TODAY 나의 포켓의 종목별 현황 조회
  static const POCK11 = "TR_POCK11"; //TODAY 나의 포켓의 종목별 현황 개수 조회
  static const POCK12 = "TR_POCK12"; //3종목 알림 설정
  static const POCK13 = "TR_POCK13"; //나만의 매도 신호 조회
  static const POCK14 = "TR_POCK14"; //나만의 매도 신호 등록, 변경, 삭제
  static const POCK15 = "TR_POCK15"; //전체 포켓과 포켓의 종목 리스트 조회

  static const PROM01 = "TR_PROM01"; //관리자 추천 상품
  static const PROM02 = "TR_PROM02"; //상품 홍보/안내
  static const INDEX01 = "TR_INDEX01"; //오늘 지수(KOSPI, KOSDAQ)
  static const SHOME01 = "TR_SHOME01"; //종목 정보 조회
  static const SHOME02 = "TR_SHOME02"; //종목 타임라인
  static const SHOME03 = "TR_SHOME03"; //종목 최근 7일간 종목소식
  static const SHOME04 = "TR_SHOME04"; //종목 정보 및 주가 관련 상세 정보
  static const SHOME05 = "TR_SHOME05"; //기업 요약 정보 - 주요 지표 보기
  static const SHOME06 = "TR_SHOME06"; //오늘의 요약 - 챗 GPT 기업 개요
  static const SHOME07 = "TR_SHOME07"; //이 회사는요?

  static const KWORD01 = "TR_KWORD01"; //종목 키워드 리스트
  static const KWORD02 = "TR_KWORD02"; //키워드 관련 종목 리스트
  static const KWORD03 = "TR_KWORD03"; //네이버 인기종목 키워드

  static const TODAY01 = "TR_TODAY01"; //오늘의 종목
  static const TODAY02 = "TR_TODAY02"; //오늘 내 종목 소식
  static const TODAY02N = "TR_TODAY02N"; //오늘 내 종목 소식 [지정 포켓]
  static const TODAY04 = "TR_TODAY04"; //(땡정보) 지금 봐야 할 정보
  static const TODAY05 = "TR_TODAY05"; //(땡정보) 타임라인 라씨 데스크
  static const CATCH01 = "TR_CATCH01"; //캐치 간략 조회
  static const CATCH02 = "TR_CATCH02"; //캐치 상세 조회
  static const CATCH03 = "TR_CATCH03"; //캐치 목록 조회
  static const STKCATCH01 = "TR_STKCATCH01"; //큰손들의 종목캐치
  static const STKCATCH02 = "TR_STKCATCH02"; //성과 TOP 종목캐치
  static const STKCATCH03 = "TR_STKCATCH03"; //이 시간 종목캐치

  static const THEME01 = "TR_THEME01"; //테마 전체 조회
  static const THEME02 = "TR_THEME02"; //테마 검색
  static const THEME03 = "TR_THEME03"; //인기 검색 테마
  static const THEME04 = "TR_THEME04"; //테마 상세 조회
  static const THEME05 = "TR_THEME05"; //테마 주도주(종목) 조회
  static const THEME06 = "TR_THEME06"; //테마 주도주 이력 조회
  static const THEME07 = "TR_THEME07"; //
  static const THEME08 = "TR_THEME08"; //

  static const COMPARE01 = "TR_COMPARE01"; //종목비교 - HOT 종목그룹 조회
  static const COMPARE02 = "TR_COMPARE02"; //종목비교 - 종목그룹의 기업규모, 가치, 서장성, 변동성 조회
  static const COMPARE03 = "TR_COMPARE03"; //종목비교 - 배당 수익률 조회
  static const COMPARE04 = "TR_COMPARE04"; //종목비교 - 매출액 증가율 조회
  static const COMPARE05 = "TR_COMPARE05"; //종목비교 - 기간별 등락률 조회
  static const COMPARE06 = "TR_COMPARE06"; //종목비교 - 52주 변동률 조회
  static const COMPARE07 = "TR_COMPARE07"; //종목비교 - 지정 종목의 대표 종목그룹

  static const ISSUE01 = "TR_ISSUE01"; //이슈 키워드 조회(지정일)
  static const ISSUE02 = "TR_ISSUE02"; //이슈 키워드 조회(지정월)
  static const ISSUE03 = "TR_ISSUE03"; //이슈 리스트 조회
  static const ISSUE04 = "TR_ISSUE04"; //이슈 상세 조회
  static const ISSUE05 = "TR_ISSUE05"; //
  static const ISSUE06 = "TR_ISSUE06"; //
  static const ISSUE07 = "TR_ISSUE07"; //지정일 이슈, 관련 종목 매매신호 정보
  static const RASSI01 = "TR_RASSI01"; //라씨로 일반뉴스 리스트
  static const RASSI02 = "TR_RASSI02"; //라씨로 종목뉴스 리스트
  static const RASSI03 = "TR_RASSI03";
  static const RASSI04 = "TR_RASSI04";
  static const RASSI05 = "TR_RASSI05";
  static const RASSI06 = "TR_RASSI06";
  static const RASSI11 = "TR_RASSI11";
  static const RASSI12 = "TR_RASSI12";
  static const RASSI13 = "TR_RASSI13";
  static const RASSI14 = "TR_RASSI14";
  static const RASSI15 = "TR_RASSI15";
  static const RASSI16 = "TR_RASSI16";
  static const RASSI17 = "TR_RASSI17";

  static const SIGNAL01 = "TR_SIGNAL01"; //매매신호 상태
  static const SIGNAL02 = "TR_SIGNAL02"; //매매신호 성과
  static const SIGNAL03 = "TR_SIGNAL03"; //매매신호 종합보드
  static const SIGNAL04 = "TR_SIGNAL04"; //매매신호 추이, 지수 비교
  static const SIGNAL05 = "TR_SIGNAL05"; //당일 발생 매매신호 조회
  static const SIGNAL06 = "TR_SIGNAL06"; //당일 전종목 타임라인
  static const SIGNAL07 = "TR_SIGNAL07"; //매매신호 타임라인
  static const SIGNAL08 = "TR_SIGNAL08"; //Chart 및 투자수익금 조회
  static const SIGNAL09 = "TR_SIGNAL09"; //현재의 매매신호 현황
  static const SIGNAL23 = "TR_SIGNAL23"; //현재 매매신호 현황(for WEB)
  static const SEARCH01 = "TR_SEARCH01";
  static const SEARCH02 = "TR_SEARCH02";
  static const SEARCH03 = "TR_SEARCH03";
  static const SEARCH04 = "TR_SEARCH04";
  static const SEARCH05 = "TR_SEARCH05";
  static const SEARCH06 = "TR_SEARCH06";
  static const SEARCH08 = "TR_SEARCH08"; // 종목의 현재가 및 일별 종가 chart
  static const SEARCH09 = "TR_SEARCH09"; // 종목의 일별 이벤트 조회
  static const SEARCH10 = "TR_SEARCH10";
  static const SEARCH11 = "TR_SEARCH11";
  static const SEARCH12 = "TR_SEARCH12";

  static const DISCLOS01 = "TR_DISCLOS01"; // 공시 리시트 조회
  static const DISCLOS02 = "TR_DISCLOS02"; // 공시 리시트 상세 조회

  static const HONOR01 = "TR_HONOR01"; //승률(적중률) TOP
  static const HONOR02 = "TR_HONOR02"; //수익 발생(10% 이상) 횟수 TOP
  static const HONOR03 = "TR_HONOR03"; //누적 수익률 TOP
  static const HONOR04 = "TR_HONOR04"; //최대 수익률 TOP
  static const HONOR05 = "TR_HONOR05"; //평균 수익률 TOP

  //종목 조건별 검색
  static const FIND01 = "TR_FIND01";
  static const FIND02 = "TR_FIND02";
  static const FIND03 = "TR_FIND03";
  static const FIND04 = "TR_FIND04";
  static const FIND05 = "TR_FIND05";
  static const FIND06 = "TR_FIND06";
  static const FIND07 = "TR_FIND07";
  static const FIND08 = "TR_FIND08";
  static const FIND09 = "TR_FIND09";
  static const SNS01 = "TR_SNS01"; //소셜지수
  static const SNS02 = "TR_SNS02"; //소셜지수 일별 등급 조회
  static const SNS03 = "TR_SNS03"; //소셜지수 HOT 종목 조회
  static const SNS04 = "TR_SNS04"; //소셜지수 당일 히스토리
  static const SNS06 = "TR_SNS06"; //소셜지수 주가/글수/폭발 차트
  static const SNS07 = "TR_SNS07"; //

  static const ORDER01 = "TR_ORDER01"; //주문 내역 조회(연도별)
  static const ORDER02 = "TR_ORDER02"; //정기결제 목록 조회
  static const ORDER03 = "TR_ORDER03"; //캐시상품 주문내역 조회
  static const ORDER04 = "TR_ORDER04"; //현재 이용중인 주문상품(정기,단건) 리스트
  static const ORDER05 = "TR_ORDER05"; //주문 상세내역 조회
  static const INAPP01 = "TR_INAPP01";
  static const INAPP02 = "TR_INAPP02";
  static const INVEST01 = 'TR_INVEST01';
  static const INVEST02 = 'TR_INVEST02';
  static const INVEST03 = 'TR_INVEST03';
  static const INVEST21 = 'TR_INVEST21';
  static const INVEST22 = 'TR_INVEST22';
  static const INVEST23 = 'TR_INVEST23';
  static const INVEST24 = 'TR_INVEST24';
  static const REPORT01 = 'TR_REPORT01';
  static const REPORT02 = 'TR_REPORT02';
  static const REPORT03 = 'TR_REPORT03';
  static const REPORT04 = 'TR_REPORT04';

  static const QNA01 = "TR_QNA01"; //QNA 등록
  static const QNA02 = "TR_QNA02"; //QNA 목록 조회
  static const QNA03 = "TR_QNA03"; //QNA 상세 조회
  static const QNA04 = "TR_QNA04"; //QNA 문제 해결

  static const MGR_AGENT02 = 'TR_MGR_AGENT02';  // 에이전트 검색
  static const MGR_AGENT03 = 'TR_MGR_AGENT03';  // 에이전트 등록/변경

}

/// 서버전문 응답 코드
class RT {
  static const SUCCESS = "0000";
  static const NO_DATA = "0001";
  static const EXCEEDED_FREE_LOOK = "8021"; //무료 조회가능 종목수 초과
  static const ESSENTIAL_FIELD_MISSING = "0205"; //필수 입력 필드값 누락
  static const NOT_RASSI_USER = "0222"; // 등록된 회원이 아님 (TR_USER02 result)
  static const NOT_RASSI_USER_NEW = "1222"; // 등록된 회원이 아님 (TR_USER02 result)
}

/// 공통 네트워크를 위한 클래스
class NetManager {
  NetManager._();

  static final NetManager _netManager = NetManager._();

  //편하게 불러오기 위해 factory 로 가져온다.
  factory NetManager() => _netManager;

//TODO @@@@@
/*  Future<Signal08> fetchPost(String trStr, String json) async {
    DLog.d('NetManager', '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      // if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d('NetManager', 'ERR : TimeoutException (12 seconds)');
      // _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d('NetManager', 'ERR : SocketException');
      // _showDialogNetErr();
    }
  }*/

// static Database _database;
// //파일접근을 하게 되므로 Future 로 반환
// Future<Database> get database async {
//   if(_database != null) return _database;
//
//   _database = await initDB();
//   return _database;
// }
//
// initDB() async {
//   Directory docDirectory = await getApplicationDocumentsDirectory();
//   String path = join(docDirectory.path, Const.DB_NAME_TEST);
//
//   return openDatabase(
//     path,
//     version: 1,
//     onCreate: (db, versiong) async {
//       await db.execute('''
//       CREATE TABLE dogs(
//         id INTEGER PRIMARY KEY,
//         name TEXT,
//         age INTEGER
//       )
//       ''');
//     },
//     onUpgrade: (db, oldVersion, newVersion) {},
//   );
// }
}
