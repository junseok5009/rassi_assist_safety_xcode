import '../none_tr/stock/stock_fluct.dart';

/// [종목비교] TR_COMPARE05 _ 파싱 클래스
class TrCompare05 {
  final String retCode;
  final String retMsg;
  final Compare05 retData;

  TrCompare05({this.retCode = '', this.retMsg = '', this.retData = defCompare05});

  factory TrCompare05.fromJson(Map<String, dynamic> json) {
    return TrCompare05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare05 : Compare05.fromJson(json['retData']),
    );
  }
}

const defCompare05 = Compare05();

class Compare05 {
  final String baseDate;
  final List<StockFluct> listStockFluct;

  const Compare05({this.baseDate = '', this.listStockFluct = const []});

  factory Compare05.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    return Compare05(
      baseDate: json['baseDate'] ?? '',
      listStockFluct: jsonList == null ? [] : (jsonList as List).map((i) => StockFluct.fromJson(i)).toList(),
    );
  }
}
