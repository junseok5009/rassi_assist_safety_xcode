import 'package:flutter/material.dart';


/// 메인 홈 탭 페이지 데이터
/// (추가) 포켓 탭이동
class PageNotifier with ChangeNotifier {
  int dstIndex = 0; //홈_홈탭
  int pktIndex = 0; //포켓탭

  void setPageData(int index,) {
    dstIndex = index;
    notifyListeners();
  }

  void setPocketTab(int index) {
    pktIndex = index;
    notifyListeners();
  }

  @override
  String toString() {
    return '$dstIndex|';
  }
}


