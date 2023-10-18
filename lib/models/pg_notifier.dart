import 'package:flutter/material.dart';


/// 메인 홈 탭 페이지 데이터
class PageNotifier with ChangeNotifier {
  int dstIndex = 0;

  void setPageData(int index,) {
    dstIndex = index;
    notifyListeners();
  }

  @override
  String toString() {
    return '$dstIndex|';
  }
}


