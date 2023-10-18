import 'package:flutter/material.dart';
import 'package:rassi_assist/models/pocket.dart';


/// MY 포켓 리스트 TODO 전체적인 포켓 리스트를 담기 위한 .. 미완성
// with 와 extends 의 차이는?
class PocketList with ChangeNotifier {

  final List<PocketData> _items = [];

  // void setPocketData(String pocketSn, String pocketName, String seq,
  //     String pocketSize, String waitCnt, String holdCnt) {
  //   pktSn = pocketSn;
  //   pktName = pocketName;
  //   viewSeq = seq;
  //   pktSize = pocketSize;
  //   waitCount = waitCnt;
  //   holdCount = holdCnt;
  //
  //   notifyListeners();
  // }


  void add(PocketData item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  @override
  String toString() {
    return 'PocketSize : ${_items.length}';
  }
}


