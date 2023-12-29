import '../../sales_info.dart';

/// [종목비교] 차트 데이터 - STOCK 상위 CLASS
class StockSalesInfo {
  final String stockCode;
  final String stockName;
  final List<SalesInfo> listSalesInfo;

  StockSalesInfo({
    this.stockCode = '',
    this.stockName = '',
    this.listSalesInfo = const [],
  });

  factory StockSalesInfo.fromJson(Map<String, dynamic> json) {
    var jsonListSalesInfo = json['list_SalesInfo'] as List;
    List<SalesInfo> vListSalesInfo = [];
    if (jsonListSalesInfo != null) vListSalesInfo = jsonListSalesInfo.map((i) => SalesInfo.fromJson(i)).toList();
    return StockSalesInfo(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      listSalesInfo: vListSalesInfo,
    );
  }
}
