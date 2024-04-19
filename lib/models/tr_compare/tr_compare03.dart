import '../none_tr/stock/stock_sales_info.dart';


/// [종목비교] TR_COMPARE03 _ 파싱 클래스
class TrCompare03 {
  final String retCode;
  final String retMsg;
  final Compare03 retData;

  TrCompare03({this.retCode = '', this.retMsg = '', this.retData = defCompare03});

  factory TrCompare03.fromJson(Map<String, dynamic> json) {
    return TrCompare03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare03 : Compare03.fromJson(json['retData']),
    );
  }
}

const defCompare03 = Compare03();

class Compare03 {
  final String baseDate;
  final List<StockSalesInfo> listStock;

  const Compare03({
    this.baseDate = '',
    this.listStock = const [],
  });

  factory Compare03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    return Compare03(
      baseDate: json['baseDate'] ?? '',
      listStock: jsonList == null ? [] : (jsonList as List).map((i) => StockSalesInfo.fromJson(i)).toList(),
    );
  }
}

