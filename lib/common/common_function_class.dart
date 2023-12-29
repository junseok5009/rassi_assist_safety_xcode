


/* DEFINE
      공통으로 사용하는 util 함수 클래스 모음집입니다.
   */
import 'package:flutter/material.dart';

class CommonFunctionClass {

  CommonFunctionClass._privateConstructor();
  static final CommonFunctionClass instance = CommonFunctionClass._privateConstructor();

  Size getSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    } else {
      return const Size(0, 0);
    }
  }

}