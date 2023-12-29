import 'package:flutter/material.dart';


/// 종목홈에 전달되는 종목 데이터
class StockTabData with ChangeNotifier {
  String stockCode = '';
  String stockName = '';
  String currentPrice = '';
  String fluctuationRate = '';
  String fluctuationAmt = '';
  int dstIndex = 0;


  void setStockData(String stkCode, String stkName, String curPrice,
      String fluctRate, String fluctAmt, int index) {
    stockCode = stkCode;
    stockName = stkName;
    currentPrice = curPrice;
    fluctuationRate = fluctRate;
    fluctuationAmt = fluctAmt;
    dstIndex = index;

    notifyListeners();
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$currentPrice';
  }

}


