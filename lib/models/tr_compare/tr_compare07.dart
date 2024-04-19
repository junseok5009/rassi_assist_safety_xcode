import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';


/// [종목비교] TR_COMPARE07 _ 파싱 클래스
class TrCompare07 {
  final String retCode;
  final String retMsg;
  final Compare07 retData;

  TrCompare07({this.retCode = '', this.retMsg = '', this.retData = defCompare07});

  factory TrCompare07.fromJson(Map<String, dynamic> json) {
    return TrCompare07(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare07 : Compare07.fromJson(json['retData']),
    );
  }
}

const defCompare07 = Compare07();

class Compare07 {
  final String stockCode;
  final String stockGrpYn;
  final List<StockGroup> listStockGroup;

  const Compare07({
    this.stockCode = '',
    this.stockGrpYn = '',
    this.listStockGroup = const []
  });

  factory Compare07.fromJson(Map<String, dynamic> json) {
    var list = json['list_StockGroup'] as List;

    return Compare07(
      stockCode: json['stockCode'],
      stockGrpYn: json['stockGrpYn'],
      listStockGroup: list.map((i) => StockGroup.fromJson(i)).toList(),
    );
  }
}
