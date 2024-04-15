import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';

/// 텍스트 스타일
/// 폰트설정 ==========
class TStyle {
  static TextStyle baseTextStyle() {
    //폰트 설정만 하고
    return TextStyle();
  }

  static TextStyle headerTextStyle() {
    //나머지는 복사해서 ??
    return baseTextStyle().copyWith(
      color: Colors.white,
    );
  }

  static TextStyle puplePlainStyle() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }

  static TextStyle pupleRegularStyle() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      // fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }

  static TextStyle puplePlain17() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    );
  }

  static TextStyle purpleThinStyle() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      fontSize: 14,
    );
  }

  static TextStyle purpleThin15Style() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      fontSize: 15,
    );
  }

  static TextStyle purpleThin16Style() {
    return baseTextStyle().copyWith(
      color: RColor.mainColor,
      fontSize: 16,
    );
  }

  static TextStyle orangePlainStyle() {
    return baseTextStyle().copyWith(
      color: RColor.bgBuy,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
  }

  static const commonBigDesc = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  static const commonSPurple = TextStyle(
    //메인 컬러 작은.
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: RColor.mainColor,
  );

  static const commonPurple14 = TextStyle(
    //메인 컬러
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: RColor.mainColor,
  );

  static const title22 = TextStyle(
    //공통 타이틀 (bold)
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Color(0xff111111),
  );

  static const title22m = TextStyle(
    //공통 중간 타이틀
    fontWeight: FontWeight.w500,
    fontSize: 22,
    color: Color(0xff111111),
  );

  static const title20 = TextStyle(
    //공통 타이틀 (bold)
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xff111111),
  );

  static const title19 = TextStyle(
    //공통 중간 타이틀
    fontWeight: FontWeight.w500,
    fontSize: 19,
    color: Color(0xff111111),
  );

  static const title19T = TextStyle(
    //공통 중간 타이틀
    fontWeight: FontWeight.w600,
    fontSize: 19,
    color: Color(0xff111111),
  );

  static const title18 = TextStyle(
    //공통 중간 타이틀
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: Color(0xff111111),
  );

  static const title18T = TextStyle(
    //공통 중간 타이틀
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: RColor.blackTitle_141414,
  );

  //이용약관,

  static const title17 = TextStyle(
    //공통 타이틀 17 (bold)
    fontWeight: FontWeight.w700,
    fontSize: 17,
    color: Color(0xff111111),
  );

  static const defaultTitle = TextStyle(
    //공통 타이틀 17 (bold) , 기준 크기
    fontWeight: FontWeight.w700,
    fontSize: 17,
    color: Color(0xff111111),
  );

  static const commonTitle = TextStyle(
    //공통 소항목 타이틀 (bold)
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const commonTitle15 = TextStyle(
    //공통 타이틀 15 (bold)
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: Color(0xff111111),
  );

  static const commonSTitle = TextStyle(
    //공통 작은 타이틀 (bold)
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: Color(0xff111111),
  );

  static const subTitle16 = TextStyle(
    //좀 더 작은(리스트) 소항목 타이틀 (bold)
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const subTitle = TextStyle(
    //좀 더 작은(리스트) 소항목 타이틀 (bold)
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xff111111),
  );

  static const subSmallTitle = TextStyle(
    //좀 더 작은(리스트) 소항목 타이틀 (bold)
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Color(0xff111111),
  );

  static const content12 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Color(0xff111111),
  );

  static const content14 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Color(0xff111111),
  );

  static const content15 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Color(0xff111111),
  );

  static const content15T = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Color(0xff111111),
  );

  static const content16 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const defaultContent = TextStyle(
    //본문 내용 - 기준
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const content = TextStyle(
    //본문 내용 - 기준
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const content17 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w400,
    fontSize: 17,
    color: Color(0xff111111),
  );

  static const content16T = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Color(0xff111111),
  );

  static const content17T = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: Color(0xff111111),
  );

  static const content18T = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: Color(0xff111111),
  );

  static const contentGrey12 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: Color(0xff777777),
  );

  static const contentGrey13 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: Color(0xff777777),
  );

  static const contentGrey14 = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: RColor.greyBasicStrong_666666,
  );

  static const contentGreyTitle = TextStyle(
    //본문 내용
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: RColor.greyBasicStrong_666666,
  );

  static const contentSBLK = TextStyle(
    //본문 내용 - 뉴스리스트 타이틀
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: Color(0xff111111),
  );

  static const contentMGrey = TextStyle(
    //본문 내용 grey
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xff555555),
  );

  static const listItem = TextStyle(
    //본문 내용 - 기준
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Color(0xff111111),
  );


  static const homeDesc = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    // fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  static const homeDescSub = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 15,
    height: 2,
  );

  static const btnTextWht20 = TextStyle(
    //버튼 화이트 텍스트 20
    fontWeight: FontWeight.w800,
    fontSize: 20,
    color: Color(0xffEFEFEF),
  );

  static const btnTextWht19 = TextStyle(
    //버튼 화이트 텍스트 20
    fontWeight: FontWeight.w500,
    fontSize: 19,
    color: Colors.white,
  );

  static const btnTextWht18 = TextStyle(
    //버튼 화이트 텍스트 20
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: Colors.white,
  );

  static const btnTextWht17 = TextStyle(
    //버튼 화이트 텍스트 17
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: Color(0xffEFEFEF),
  );

  static const btnTextWht16 = TextStyle(
    //버튼 화이트 텍스트 16
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Colors.white,
  );

  static const btnTextWht15 = TextStyle(
    //버튼 화이트 텍스트 15
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: Colors.white,
  );

  static const btnTextWht14 = TextStyle(
    //버튼 화이트 텍스트 14
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xffEFEFEF),
  );

  static const btnTextWht13 = TextStyle(
    //버튼 화이트 텍스트 13
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: Color(0xffEFEFEF),
  );

  static const btnSTextWht = TextStyle(
    //내용 화이트 텍스트
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: Color(0xbbEFEFEF),
  );

  static const btnTextWht12 = TextStyle(
    //버튼 화이트 텍스트 12
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: Color(0xffEFEFEF),
  );

  static const btnSsTextWht = TextStyle(
    //버튼 화이트 텍스트 9
    fontWeight: FontWeight.w500,
    fontSize: 9,
    color: Color(0xffFFFFFF),
  );

  static const btnContentWht15 = TextStyle(
    //버튼 화이트 텍스트 15
    fontSize: 15,
    color: Colors.white,
  );

  static const btnContentWht16 = TextStyle(
    //버튼 화이트 텍스트 16
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Color(0xffEFEFEF),
  );

  static const text10LightGreyRegular = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: Color(0xff7a7979),
  );

  static const textSGrey = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: Color(0xdd555555),
  );

  static const textMGrey = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: Color(0xdd555555),
  );
  static const textGrey14S = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Color(0xff666666),
  );
  static const textGrey14 = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Color(0xdd555555),
  );
  static const textGrey15S = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: Color(0xff666666),
  );
  static const textGrey15 = TextStyle(
    //작은 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Color(0xdd555555),
  );
  static const textGreyDefault = TextStyle(
    //기본 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Color(0xdd555555),
  );
  static const textGrey18 = TextStyle(
    //중간 그레이 텍스트
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: Color(0xdd666666),
  );
  static const titleGrey = TextStyle(
    //그레이 타이틀
    fontWeight: FontWeight.w600,
    fontSize: 21,
    color: Color(0xdd555555),
  );
  static const textSGreen = TextStyle(
    //작은 밝은 그린 (마켓뷰 ~시간전)
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Color(0xff58ceb6),
  );
  static const text20Buy = TextStyle(
    //볼드 [매수] 컬러
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: RColor.sigBuy,
  );
  static const text12SBuy = TextStyle(
    //더 작은 [매수] 컬러
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: RColor.sigBuy,
  );
  static const text20Sell = TextStyle(
    //볼드 [매수] 컬러
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: RColor.sigSell,
  );
  static const textBBuy = TextStyle(
    //볼드 [매수] 컬러
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: RColor.sigBuy,
  );
  static const textBSell = TextStyle(
    //볼드 [매도] 컬러
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: RColor.sigSell,
  );
  static const textMainColor = TextStyle(
    //볼드 [매도] 컬러
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: RColor.mainColor,
  );
  static const textMainColor18 = TextStyle(
    // [매인] 컬러
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: RColor.mainColor,
  );

  static const textMBuy = TextStyle(
    //중간 [매수] 컬러
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: RColor.sigBuy,
  );
  static const textMSell = TextStyle(
    //중간 [매도] 컬러
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: RColor.sigSell,
  );
  static const textSBuy = TextStyle(
    //작은 [매수] 컬러
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: RColor.sigBuy,
  );
  static const textSSell = TextStyle(
    //작은 [매도] 컬러
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: RColor.sigSell,
  );

  static const newBasicGreyS15 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: RColor.new_basic_text_color_grey,
  );

  static const newBasicStrongGreyS15 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: RColor.new_basic_text_color_strong_grey,
  );

  static const newBasicStrongGreyS16 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: RColor.new_basic_text_color_strong_grey,
  );

  //밑줄 텍스트 버튼 (띄어쓰기 밑줄이 이상하게 들어감)
  static const wtText = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Colors.white60,
    decoration: TextDecoration.underline,
  );

  //밑줄 텍스트 버튼 (띄어쓰기 밑줄이 이상하게 들어감), grey
  static const ulTextGrey = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: RColor.greyBasic_8c8c8c,
    decoration: TextDecoration.underline,
  );

  static const ulTextGreySmall = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: Color(0xff333333),
    decoration: TextDecoration.underline,
  );

  //밑줄 텍스트 버튼 (띄어쓰기 밑줄이 이상하게 들어감), lite blue
  static const ulTextBlue = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  //밑줄 텍스트 버튼 (띄어쓰기 밑줄이 이상하게 들어감), grey
  static const ulTextPurple = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: RColor.mainColor,
    decoration: TextDecoration.underline,
  );

// cf. blod weight
// w100 Thin, the least thick
// w200 Extra-light
// w300 Light
// w400 Normal / regular / plain
// w500 Medium
// w600 Semi-bold
// w700 Bold
// w800 Extra-bold
// w900 Black, the most thick

  static String getTodayAllTimeString() {
    final df = DateFormat('yyyyMMddhhmmss');
    return df.format(DateTime.now());
  }

  //오늘 날짜 리턴
  static String getTodayString() {
    final df = DateFormat('yyyyMMdd');
    return df.format(DateTime.now());
  }

  //오늘 날짜 리턴 (2021-04-05)
  static String getDateString() {
    final df = DateFormat('yyyy-MM-dd');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //오늘 날짜 리턴 (2021-04-05)
  static String getTodayDateStringDot() {
    final df = DateFormat('yyyy.MM.dd');
    return df.format(DateTime.now());
  }

  //오늘 연도 리턴
  static String getYearString() {
    final df = DateFormat('yyyy');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //오늘 년월 리턴
  static String getYearMonthString() {
    final df = DateFormat('yyyyMM');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //오늘 월날 리턴
  static String getMonthDayString() {
    final df = DateFormat('MM/dd');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //현재 시간 리턴
  static String getTimeString() {
    final df = DateFormat('MMddhhmmss');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //현재 시간 리턴
  static String getTimeString1() {
    final df = DateFormat('HH:mm');
    // print(df.format(DateTime.now()));
    return df.format(DateTime.now());
  }

  //날짜 형식 표시
  static String getDateFormat(String date) {
    String rtStr = '';
    if (date.length > 8) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}  ${date.substring(8, 10)}:${date.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (2021.05.05)
  static String getDateSFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
      return rtStr;
    } else if (date.length > 5) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (21/05/05)
  static String getDateSlashFormat1(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(2, 4)}/${date.substring(4, 6)}/${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (2021/05/05)
  static String getDateSlashFormat2(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(0, 4)}/${date.substring(4, 6)}/${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (21.05.05)
  static String getDateSlashFormat3(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(2, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
      return rtStr;
    }
    return date;
  }

  //날짜 형식 표시 (2021.05.05)
  static String getDateSlashFormat4(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (2021년 05월 05일)
  static String getDateKorFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(0, 4)}년 ${date.substring(4, 6)}월 ${date.substring(6, 8)}일';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (05월 05일)
  static String getDateMdKorFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(4, 6)}월 ${date.substring(6, 8)}일';
      return rtStr;
    } else if (date.length == 4) {
      rtStr = '${date.substring(0, 2)}월 ${date.substring(2, 4)}일';
      return rtStr;
    }
    return '';
  }

  static String getWeekdayKor(String date) {
    if (date.length > 7) {
      int iDay = DateTime
          .parse(date)
          .weekday;
      if (iDay == 1) return '월요일';
      if (iDay == 2) return '화요일';
      if (iDay == 3) return '수요일';
      if (iDay == 4) return '목요일';
      if (iDay == 5) return '금요일';
      if (iDay == 6) return '토요일';
      if (iDay == 7) return '일요일';
    }
    return '';
  }

  static String getWeekdayEng(String date) {
    if (date.length > 7) {
      int iDay = DateTime
          .parse(date)
          .weekday;
      if (iDay == 1) return 'MON';
      if (iDay == 2) return 'TUE';
      if (iDay == 3) return 'WED';
      if (iDay == 4) return 'THU';
      if (iDay == 5) return 'FRI';
      if (iDay == 6) return 'SAT';
      if (iDay == 7) return 'SUN';
    }
    return '';
  }

  //날짜 시간 형식 표시 (2021.05.05  12:45)
  static String getDateTimeFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}   ${date.substring(8, 10)}:${date.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (01/01 15:00)
  static String getDateTdFormat(String date) {
    String rtStr = '';
    if (date.length > 8) {
      rtStr = '${date.substring(4, 6)}/${date.substring(6, 8)}  ${date.substring(8, 10)}:${date.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (01/01)
  static String getDateDivFormat(String date) {
    String rtStr = '';
    if (date.length >= 8) {
      rtStr = '${date.substring(4, 6)}/${date.substring(6, 8)}';
      return rtStr;
    }
    return date;
  }

  //날짜 형식 표시 (0101)
  static String getDateDivFormat2(String date) {
    String rtStr = '';
    if (date.length > 5) {
      rtStr = date.substring(4, 6) + date.substring(6, 8);
      return rtStr;
    }
    return '';
  }

  //날짜 형식 표시 (01.01)
  static String getDateDivFormat3(String date) {
    String rtStr = '';
    if (date.length > 5) {
      rtStr = '${date.substring(4, 6)}.${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  //시간 형식 표시 (20210203... -> 12:30)
  static String getDtTimeFormat(String tm) {
    String rtStr = '';
    if (tm.length >= 11) {
      rtStr = '${tm.substring(8, 10)}:${tm.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }

  //시간 형식 표시 (20210203... -> 12시)
  static String getDtTimeFormat1(String tm) {
    String rtStr = '';
    if (tm.length > 7) {
      rtStr = '${tm.substring(8, 10)}시';
      return rtStr;
    }
    return '';
  }

  //시간 형식 표시 (12:30)
  static String getTimeFormat(String tm) {
    String rtStr = '';
    if (tm.length > 3) {
      rtStr = '${tm.substring(0, 2)}:${tm.substring(2, 4)}';
      return rtStr;
    }
    return '';
  }

  //가격 형식 표시
  static String getMoneyPoint(String sText) {
    if (sText.isNotEmpty) {
      if (double.tryParse(sText) == null) {
        return sText;
      } else {
        var prc = double.parse(sText);
        return NumberFormat('###,###,###,###.###')
            .format(prc)
            .replaceAll(' ', '');
      }
      /*if(sText.contains('.')){
        var prc = double.parse(sText);
        return NumberFormat('###,###,###,###.###').format(prc).replaceAll(' ', '');
      }else{
        var prc = int.tryParse(sText);
        return NumberFormat('###,###,###,###').format(prc).replaceAll(' ', '');
      }*/
    }
    return '';
  }

  //가격 형식 표시 + 소수점 반영
  static String getMoneyPoint2(String sText) {
    if (sText.length > 0) {
      //var prc = int.parse(sText);
      if (sText.contains('.')) {
        return NumberFormat('###,###,###,###.##')
            .format(double.parse(sText))
            .replaceAll(' ', '');
      } else {
        return NumberFormat('###,###,###,###')
            .format(int.parse(sText))
            .replaceAll(' ', '');
      }
    }
    return '';
  }

  //소수점 2자리까지 표시
  static String getFixedNum(String sText) {
    if (sText.length > 0) {
      var dNum = double.parse(sText);
      if (dNum < 0) {
        //음수일 경우에 floor()에서 반올림 일어나 따로 처리
        var temp = (dNum * -100);
        temp = temp.floor() / -100;
        return temp.toString();
      } else {
        var temp = (dNum * 100);
        temp = temp.floor() / 100;
        return temp.toString();
      }
      // return NumberFormat('##0.0#').format(dNum).replaceAll(' ', '');  //자동 반올림이 일어남
    }
    return '';
  }

  //종목명 글자수 제한 표시
  static String getLimitString(String sName, int cnt) {
    if (sName.length > cnt) return sName.substring(0, cnt);
    return sName;
    }

  //rate(지수값)에 -가 아니면 +붙여주고 %
  static String getPercentString(String sName) {
    if (sName.isNotEmpty) {
      if (sName.contains('-')) {
        return '$sName%';
      } else if (sName == '0' || sName == '0.0' || sName == '0.00') {
        return '$sName%';
      } else {
        return '+$sName%';
      }
    } else {
      return sName;
    }
  }

  //값에 -면 ▼, +면 ▲ 붙여주고 값에는 콤마 찍어주기
  static String getTriangleStringWithMoneyPoint(String value) {
    if (value.isNotEmpty) {
      if (value.contains('-')) {
        return '▼${TStyle.getMoneyPoint(value.substring(1))}';
      } else if (value == '0' || value == '0.0' || value == '0.00') {
        return value;
      } else {
        return '▲${TStyle.getMoneyPoint(value)}';
      }
    } else {
      return value;
    }
  }

  /// 한글 조사 연결 (을/를,이/가,은/는,로/으로)
  /// 1. 종성에 받침이 있는 경우 '을/이/은/으로/과'
  /// 2. 종성에 받침이 없는 경우 '를/가/는/로/와'
  /// 3. '로/으로'의 경우 종성의 받침이 'ㄹㄹ' 인경우 '로'
  /// **/

  static String getPostWord(String vStr, String firstVal, String secondVal) {
    try {
      int laststr = vStr.codeUnitAt(vStr.length - 1);
      if ((laststr < 44032) || (laststr > 55203)) {
        return vStr;
      }
      int lastCharIndex = ((laststr - 44032) % 28);
      if (lastCharIndex > 0) {
        if ((firstVal == "으로") && (lastCharIndex == 8)) {
          vStr += secondVal;
        } else {
          vStr += firstVal;
        }
      } else {
        vStr += secondVal;
      }
    } catch (e) {}
    return vStr;
  }

  static String getJustPostWord(String vStr, String firstVal, String secondVal) {
    try {
      int laststr = vStr.codeUnitAt(vStr.length - 1);
      if ((laststr < 44032) || (laststr > 55203)) {
        return '';
      }
      int lastCharIndex = ((laststr - 44032) % 28);
      if (lastCharIndex > 0) {
        if ((firstVal == "으로") && (lastCharIndex == 8)) {
          return secondVal;
        } else {
          return firstVal;
        }
      } else {
        return secondVal;
      }
    } catch (e) {

    }
    return '';
  }

  // 0 = black
  static Color getMinusPlusColor(String sCount) {
    if (sCount.isNotEmpty) {
      double dCount = double.tryParse(sCount) ?? 0;
      if (dCount == 0) {
        return Colors.black;
      } else if (dCount < 0) {
        return RColor.sigSell;
      } else {
        return RColor.sigBuy;
      }
    } else {
      return Colors.black;
    }
  }

  // 박스에 사용하는 +-0 컬러, 0 = grey
  static Color getMinusPlusColorBox(String sCount) {
    if (sCount.isNotEmpty) {
      double dCount = double.tryParse(sCount) ?? 0;
      if (dCount == 0) {
        return RColor.greyBox_dcdfe2;
      } else if (dCount < 0) {
        return RColor.lightSell_2e70ff;
      } else {
        return RColor.sigBuy;
      }
    } else {
      return Colors.black;
    }
  }

  // getMinusPlusColorBox 와 함께 사용하는 텍스트 컬러, +- = 흰, 0 = 블랙
  static Color getIsZeroBlackNotWhite(String sCount) {
    if (sCount.isNotEmpty) {
      double dCount = double.tryParse(sCount) ?? 0;
      if (dCount == 0) {
        return Colors.black;
      } else {
        return Colors.white;
      }
    } else {
      return Colors.black;
    }
  }

  // 현재 날짜와 며칠 차이 나는지
  static int getDateDifferenceDyas(String date) {
    String rtStr = '';
    int difference = 0;
    var _toDay = DateTime.now();

    if (date.length > 8) {
      rtStr = date.substring(0, 8);
      difference =
          int.parse(_toDay
              .difference(DateTime.parse(rtStr))
              .inDays
              .toString());
    }
    return difference;
  }

  // double로 들어오는 거 억 / 조 + 콤마 붙여서 return
  static String getBillionUnitWithMoneyPointByDouble(String price) {
    String isMinus = '';
    if (price.contains('-')) {
      isMinus = '-';
      price = price.replaceAll('-', '');
    }
    if (double.tryParse(price) == null) {
      return price;
    } else {
      if (double.parse(price) > 10000) {
        return '$isMinus${TStyle.getMoneyPoint(
          (double.parse(price) / 10000).toStringAsFixed(1),
        )}조';
      } else {
        return '$isMinus${TStyle.getMoneyPoint(price)}억';
      }
    }
  }

  // double로 들어오는 거 (x조+x억) + 콤마 붙여서 return
  static String getComboUnitWithMoneyPointByDouble(String price) {
    String isMinus = '';
    if (price.contains('-')) {
      isMinus = '-';
      price = price.replaceAll('-', '');
    }
    if (double.tryParse(price) == null) {
      return price;
    } else {
      if (double.parse(price) > 10000) {
        String sPrice = '${(double.parse(price)) % 10000}';
        return '$isMinus${TStyle.getMoneyPoint(
          (double.parse(price) ~/ 10000).toString(),
        )}조 ${
            TStyle.getMoneyPoint(
                (double.parse(((double.parse(sPrice) / 100).toStringAsFixed(1))) * 100).toString()
            )
    }억';
    } else {
    return '$isMinus${TStyle.getMoneyPoint(price)}억';
    }
  }
  }

  static String removeSpecialCharacters(String input) {
    // 정규식을 사용하여 특수문자 제거
    // ^는 문자열의 시작을 의미하고, \w는 단어 문자(알파벳, 숫자, 밑줄)를 의미하며,
    // \s는 공백 문자를 의미합니다.
    // 따라서 [^\w\s]는 단어 문자와 공백 문자를 제외한 나머지 문자를 의미합니다.
    RegExp regExp = RegExp(r'[^\w\s]');

    // 정규식을 사용하여 특수문자를 빈 문자열로 대체
    return input.replaceAll(regExp, '');
  }

}
