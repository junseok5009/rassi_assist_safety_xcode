import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 종목 검색 (종목명 또는 종목코드로 검색)
class TrSearch02 {
  final String retCode;
  final String retMsg;
  final List<Stock>? retData;

  TrSearch02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSearch02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Stock>? rtList;
    if (list != null) rtList = list.map((i) => Stock.fromJson(i)).toList();

    return TrSearch02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtList,
    );
  }
}

//화면구성 (사용안함)
class TileSearch02 extends StatelessWidget {
  final String userId;
  final Stock item;

  TileSearch02(this.userId, this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.stockName),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_SIGNAL,
        );
      },
    );
  }
}
