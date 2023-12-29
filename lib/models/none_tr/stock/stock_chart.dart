import 'package:rassi_assist/models/none_tr/chart_data.dart';

/// 종목정보 with 차트데이터
class StockChart {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String fluctuationAmt;
  final String increaseRate;
  final List<ChartData> listChart;

  StockChart({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.increaseRate = '',
    this.listChart = const [],
  });

  factory StockChart.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<ChartData> rtList;
    list == null ? rtList = const [] : rtList = list.map((i) => ChartData.fromJson(i)).toList();

    return StockChart(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      listChart: rtList,
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$fluctuationAmt';
  }
}
