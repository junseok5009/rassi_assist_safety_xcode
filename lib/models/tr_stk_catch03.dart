import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2022.05.19
/// 이 시간 종목캐치
class TrStkCatch03 {
  final String retCode;
  final String retMsg;
  final List<StkCatch03> retData;

  TrStkCatch03({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrStkCatch03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<StkCatch03> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StkCatch03.fromJson(i)).toList();

    return TrStkCatch03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtList,
    );
  }
}

const defStkCatch03 = StkCatch03();
//
class StkCatch03 {
  final String contentDiv;
  final List<StockDiv> stkList;

  const StkCatch03({
    this.contentDiv = '',
    this.stkList = const [],
  });

  factory StkCatch03.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockDiv> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StockDiv.fromJson(i)).toList();

    return StkCatch03(
      contentDiv: json['contentDiv'],
      stkList: rtList,
    );
  }
}

class StockDiv {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String selectDiv;

  StockDiv({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.selectDiv = '',
  });

  factory StockDiv.fromJson(Map<String, dynamic> json) {
    return StockDiv(
      stockCode: json['stockCode'],
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      selectDiv: json['selectDiv'] ?? '',
    );
  }
}
