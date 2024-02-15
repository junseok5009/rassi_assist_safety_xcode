import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';

/// UI 스타일
///
class UIStyle {
  /// DEFINE 개편 이후
  // 기본적인 그림자 있는 박스
  static BoxDecoration boxShadowBasic(double radius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 2), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxShadowColor(double radius, Color bgColor) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 2), //changes position of shadow
        )
      ],
    );
  }

  //옅은 회색 라운드 배경 (Solid)
  static BoxDecoration boxWeakGrey(double rad) {
    return BoxDecoration(
      color: RColor.bgWeakGrey,
      borderRadius: BorderRadius.all(Radius.circular(rad)),
    );
  }

  //옅은 회색 라운드 배경 (Solid)
  static BoxDecoration boxWeakGrey6() {
    return const BoxDecoration(
      color: RColor.bgWeakGrey,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    );
  }

  //옅은 회색 라운드 배경 (Solid)
  static BoxDecoration boxWeakGrey10() {
    return const BoxDecoration(
      color: RColor.bgWeakGrey,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }

  //옅은 회색 라운드 배경 (Solid)
  static BoxDecoration boxWeakGreyLeft6() {
    return const BoxDecoration(
      color: RColor.bgWeakGrey,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      ),
    );
  }

  //옅은 회색 라운드 배경 (Solid)
  static BoxDecoration boxWeakGrey25() {
    return const BoxDecoration(
      color: RColor.bgWeakGrey,
      borderRadius: BorderRadius.all(Radius.circular(25)),
    );
  }

  //새로운 회색
  static BoxDecoration boxNewBasicGrey10() {
    return const BoxDecoration(
      color: RColor.new_basic_box_grey,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }

  // new 선택된 네모 버튼 1
  static BoxDecoration boxNewSelectBtn1() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        width: 1.2,
        color: RColor.btnUnSelectGreyStroke,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(5),
      ),
    );
  }

  // new 선택 안된 네모 버튼 1
  static BoxDecoration boxNewUnSelectBtn1() {
    return BoxDecoration(
      color: RColor.btnUnSelectGreyBg,
      border: Border.all(
        width: 1.2,
        color: RColor.btnUnSelectGreyStroke,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(5),
      ),
    );
  }

  // new 선택된 동그라미 버튼 2
  static BoxDecoration boxNewSelectBtn2() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        width: 1.2,
        color: RColor.btnUnSelectGreyStroke,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
    );
  }

  // new 선택 안된 동그라미 버튼 2
  static BoxDecoration boxNewUnSelectBtn2() {
    return BoxDecoration(
      color: RColor.btnUnSelectGreyBg,
      border: Border.all(
        width: 1.2,
        color: RColor.btnUnSelectGreyStroke,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
    );
  }

  //BOX 라운드 보더 라인 (Line)
  static BoxDecoration boxRoundLine() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.lineGrey,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    );
  }

  static BoxDecoration boxRoundLine6() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.lineGrey,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    );
  }

  static BoxDecoration boxRoundLine6bgColor(Color bgColor) {
    return BoxDecoration(
      color: bgColor,
      border: Border.all(
        color: RColor.greyBoxLine_c9c9c9,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    );
  }

  static BoxDecoration boxRoundLine6LineColor(Color lineColor) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: lineColor,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    );
  }

  static BoxDecoration boxSelectedLineMainColor() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.mainColor,
        width: 2.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
    );
  }

  static BoxDecoration boxUnSelectedLineMainGrey() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.greyBasic_8c8c8c,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
    );
  }

  static BoxDecoration boxRoundLine8bgColor(Color bgColor) {
    return BoxDecoration(
      color: bgColor,
      border: Border.all(
        color: RColor.greyBoxLine_c9c9c9,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  static BoxDecoration boxRoundLine8LineColor(Color lineColor) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: lineColor,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  //BOX 라운드 보더 라인 (Line)
  static BoxDecoration boxRoundLine15() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: RColor.lineGrey,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    );
  }

  //BOX 라운드 보더 라인 (Line)
  static BoxDecoration boxRoundLine17() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: RColor.lineGrey,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(17.0)),
    );
  }

  //BOX 라운드 보더 라인 (Line)
  static BoxDecoration boxRoundLine20() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: RColor.lineGrey,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 라운드 보더 라인 Color (Line)
  static BoxDecoration boxRoundLine10c(Color selColor) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: selColor,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    );
  }

  static BoxDecoration boxRoundLine25c(Color selColor) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: selColor,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(25.0)),
    );
  }

  static BoxDecoration boxRoundFullColor6c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    );
  }

  static BoxDecoration boxRoundFullColor8c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  static BoxDecoration boxRoundFullColor10c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    );
  }

  static BoxDecoration boxRoundFullColor16c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    );
  }

  static BoxDecoration boxRoundFullColor25c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(25.0)),
    );
  }

  static BoxDecoration boxRoundFullColor50c(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
    );
  }

  //BOX 라운드 보더 라인(가입경로) (Line)
  static BoxDecoration boxSelectedLine12() {
    return BoxDecoration(
      // color: Colors.white,
      border: Border.all(
        color: RColor.purpleBasic_6565ff,
        width: 1.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    );
  }

  //Box 선택된 버튼 상태(가입경로) (Solid)
  static BoxDecoration boxSelectedPurple() {
    return const BoxDecoration(
      color: RColor.purpleBasic_6565ff,
      borderRadius: BorderRadius.all(Radius.circular(25)),
    );
  }

  //BOX 선택된 버튼 상태(마켓뷰)
  static BoxDecoration boxBtnSelected() {
    return BoxDecoration(
      color: RColor.purpleBasic_6565ff,
      border: Border.all(
        color: RColor.lineGrey,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    );
  }

  //BOX 선택된 버튼 상태(마켓뷰)
  static BoxDecoration boxBtnSelected20() {
    return BoxDecoration(
      color: RColor.purpleBasic_6565ff,
      border: Border.all(
        color: RColor.lineGrey,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택된 버튼 상태(오늘 발생한 매수신호)
  static BoxDecoration boxBtnSelectedBuy() {
    return BoxDecoration(
      color: RColor.bgBuy,
      border: Border.all(
        color: RColor.bgBuy,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택되지 않은 버튼 상태(오늘 발생한 매수신호)
  static BoxDecoration boxBtnUnSelectedBuy() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.bgBuy,
        width: 2.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택된 버튼 상태(오늘 발생한 매도신호)
  static BoxDecoration boxBtnSelectedSell() {
    return BoxDecoration(
      color: RColor.bgSell,
      border: Border.all(
        color: RColor.bgSell,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택되지 않은 버튼 상태(오늘 발생한 매도신호)
  static BoxDecoration boxBtnUnSelectedSell() {
    return BoxDecoration(
      border: Border.all(
        color: RColor.bgSell,
        width: 2.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택된 버튼 상태(나의 포켓 종목 현황)
  static BoxDecoration boxBtnSelectedJin() {
    return BoxDecoration(
      color: RColor.jinbora,
      border: Border.all(
        color: RColor.jinbora,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //BOX 선택된 버튼 상태(종목비교_차트)
  static BoxDecoration boxBtnSelectedMainColor6Cir() {
    return BoxDecoration(
      color: RColor.mainColor,
      border: Border.all(
        color: RColor.jinbora,
        width: 0.8,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
    );
  }

  //탭바 버튼 선택된 버튼 상태
  static BoxDecoration boxBtnSelectedTab() {
    return const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: RColor.mainColor,
          width: 3.0,
        ),
      ),
    );
  }

  //circle 선택된 버튼 상태
  static BoxDecoration circleBtnSelected() {
    return BoxDecoration(
      color: RColor.bgWeakGrey,
      shape: BoxShape.circle,
      border: Border.all(
        color: RColor.jinbora,
        width: 2.0,
      ),
    );
  }

  //circle 기본 버튼 상태
  static BoxDecoration circleBtnDefault() {
    return const BoxDecoration(
      color: RColor.bgGrey,
      shape: BoxShape.circle,
    );
  }

  //circle 선택된 버튼 상태
  static BoxDecoration circleBtnBasic(Color bgColor, Color lineColor) {
    return BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: lineColor,
        width: 1.0,
      ),
    );
  }

  //배경 이미지를 blur 처리
  static BoxDecoration boxWithblur() {
    return const BoxDecoration(
      color: Color(0xbb121212),
    );
  }

  //배경 이미지를 blur 처리 round
  static BoxDecoration boxWithblurR() {
    return const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      color: Color(0xbb121212),
    );
  }

  static BoxDecoration boxWithOpacity() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 3), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxWithOpacityNew() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 4,
          blurRadius: 6,
          offset: const Offset(0, 3), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxWithOpacityListItem() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 4,
          blurRadius: 5,
          offset: const Offset(0, 3), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxWithOpacityColor(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 4,
          blurRadius: 7,
          offset: const Offset(0, 3), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxWithOpacityPurple() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurpleAccent.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1), //changes position of shadow
        )
      ],
    );
  }

  static BoxDecoration boxWithOpacity16() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(1, 1), //changes position of shadow
        )
      ],
    );
  }

  //다이얼로그 둥근 모서리
  static RoundedRectangleBorder borderRoundedDialog() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  //기본형 라운드 버튼
  static BoxDecoration roundBtnStBox() {
    return const BoxDecoration(
      color: RColor.mainColor,
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //기본형 라운드 버튼 color change
  static BoxDecoration roundBtnStBoxColor(Color _vColor) {
    return BoxDecoration(
      color: _vColor,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  //라운드 버튼
  static BoxDecoration roundBtnBox(Color selColor) {
    return BoxDecoration(
      color: selColor,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  static BoxDecoration roundBtnBox25() {
    return const BoxDecoration(
      color: RColor.mainColor,
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
    );
  }

  //라운드 버튼 (Line)
  static BoxDecoration roundBtnLineBox(Color selColor) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: selColor,
        width: 0.9,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    );
  }

  // 시그널 카드 (종목홈[홈], 종목홈[ai매매신호], 포켓뷰 등 )
  static BoxDecoration boxSignalCard() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: RColor.lineGrey2,
        width: 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
    );
  }

  static BoxDecoration simpleBlackBox() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: Colors.black,
        width: 1.2,
      ),
    );
  }

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
      fontSize: 14,
    );
  }

  static TextStyle orangePlainStyle() {
    return baseTextStyle().copyWith(
      color: RColor.bgBuy,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
  }
}
