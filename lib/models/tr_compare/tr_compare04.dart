import '../none_tr/stock/stock_sales_info.dart';


/// [종목비교] TR_COMPARE04 _ 파싱 클래스
class TrCompare04 {
  final String retCode;
  final String retMsg;
  final Compare04 retData;

  TrCompare04({this.retCode = '', this.retMsg = '', this.retData = defCompare04});

  factory TrCompare04.fromJson(Map<String, dynamic> json) {
    return TrCompare04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare04 : Compare04.fromJson(json['retData']),
    );
  }
}

const defCompare04 = Compare04();

class Compare04 {
  final String baseDate;
  final String quarter;
  final List<StockSalesInfo> listStock;

  const Compare04({
    this.baseDate = '',
    this.quarter = '',
    this.listStock = const [],
  });

  factory Compare04.fromJson(Map<String, dynamic> json) {
    var jsonStockList = json['list_Stock'] as List;
    List<StockSalesInfo> vStockList;
    if(jsonStockList != null) vStockList = jsonStockList.map((i) => StockSalesInfo.fromJson(i)).toList();

    return Compare04(
      baseDate: json['baseDate'],
      quarter: json['quarter'] ?? '',
      listStock: jsonStockList.map((i) => StockSalesInfo.fromJson(i)).toList(),
    );
  }
}

