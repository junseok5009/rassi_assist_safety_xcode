import 'package:flutter/material.dart';

import '../../common/const.dart';
import '../../common/tstyle.dart';
import '../../common/ui_style.dart';

/// Made hjs
/// 자주 쓰는 UI 관련 VIEW 클래스 입니다.

class CommonView {
  /* DEFINE
      공통으로 사용하는 뷰 클래스 입니다.
   */

  // 데이터 없음 뷰
  static Widget setNoDataView(double height, String msg) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: RColor.new_basic_text_color_grey,
              ),
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                    fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 14,
              color: RColor.new_basic_text_color_grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget setNoDataTextView(double height, String msg) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      child: Text(
        msg,
        style: const TextStyle(
          fontSize: 14,
          color: RColor.new_basic_text_color_grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 날짜 or 연도 등 선택하는 버튼
  static Widget setDatePickerBtnView(
    String dateTitle,
    void Function() onTap,
  ) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: FittedBox(
        child: Container(
          decoration: UIStyle.boxRoundLine6(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 7,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateTitle,
                style: TStyle.commonTitle15,
              ),
              const SizedBox(
                width: 10,
              ),
              Image.asset(
                'images/icon_arrow_up_down.png',
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 or 연도 등 선택하는 버튼
  static Widget setCalendarPickerBtnView(
      String dateTitle,
      void Function() onTap,
      ) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: FittedBox(
        child: Container(
          decoration: UIStyle.boxRoundLine8LineColor(RColor.greyBoxLine_c9c9c9),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 7,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/icon_calendar.png',
                height: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                dateTitle,
                style: TStyle.contentGreyTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 일반적인 () 더보기 버튼
  static Widget setBasicMoreRoundBtnView(
    List<Widget> widgetList,
    void Function() onTap,
  ) {
    return UnconstrainedBox(
      child: Align(
        alignment: Alignment.center,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            decoration: UIStyle.boxRoundLine20(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgetList,
            ),
          ),
        ),
      ),
    );
  }

  // 조금 작은 () 더보기 버튼
  static Widget setSmallMoreRoundBtnView(
    List<Widget> widgetList,
    void Function() onTap,
  ) {
    return UnconstrainedBox(
      child: Align(
        alignment: Alignment.center,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
            decoration: UIStyle.boxRoundLine20(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgetList,
            ),
          ),
        ),
      ),
    );
  }

  static Widget setConfirmBtnView(void Function() onTap,){
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: 180,
        height: 50,
        alignment: Alignment.center,
        decoration: UIStyle.boxRoundFullColor50c(
          RColor.purpleBasic_6565ff,
        ),
        child: const Text(
          '확인',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget setFluctuationRateBox({EdgeInsetsGeometry? marginEdgeInsetsGeometry, required String value, double? fontSize,}){
    if(value.isEmpty){
      return const SizedBox();
    }else{
      return Container(
        margin: marginEdgeInsetsGeometry ?? EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),
        decoration: UIStyle.boxRoundFullColor6c(TStyle.getMinusPlusColor(value)),
        child: Text(
          TStyle.getPercentString(TStyle.getFixedNum(value)),
          style: TextStyle(
            fontSize: fontSize ?? 16,
            color: Colors.white,
          ),
        ),
      );
    }

  }

  static Widget get setDivideLine => Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    color: const Color(
      0xffF5F5F5,
    ),
    height: 13,
  );

}
