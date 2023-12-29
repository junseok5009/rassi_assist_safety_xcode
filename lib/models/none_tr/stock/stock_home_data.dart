import 'package:flutter/material.dart';

/// 종목홈 내부 데이터 (종목 하나의 데이터)
class StockHomeData with ChangeNotifier {
  String stockCode = '';
  String stockName = '';
  String currentPrice = '';
  String fluctuationTxt = '';
  String timeText = '';
  Color curColor = Colors.grey[500]!;
  String pocketSn = '';

  void setStockDefault(String stkCode, String stkName,) {
    stockCode = stkCode;
    stockName = stkName;

    notifyListeners();
  }

  void setStockData(String curPrice, String fluctTxt, String time, Color color, String pktSn) {
    currentPrice = curPrice;
    fluctuationTxt = fluctTxt;
    timeText = time;
    curColor = color;
    pocketSn = pktSn;

    notifyListeners();
  }

  @override
  String toString() {
    return '$stockName | $stockCode | $currentPrice | $pocketSn';
  }

}


