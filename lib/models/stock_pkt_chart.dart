import 'package:rassi_assist/models/chart_data.dart';


/// 종목정보 (포켓안에서) with 차트데이터
class StockPktChart {
  final String pocketSn;
  final String pocketName;
  final String stockCode;
  final String stockName;
  final String fluctuationRate;

  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final List<ChartData> listChart;

  StockPktChart({
    this.pocketSn = '', this.pocketName = '',
    this.stockCode = '', this.stockName = '',
    this.fluctuationRate = '', this.tradeFlag = '',
    this.tradeDttm = '', this.tradePrice = '',
    this.listChart = const []
  });

  factory StockPktChart.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<ChartData> rtList;
    list == null ? rtList = [] : rtList = list.map((i) => ChartData.fromJson(i)).toList();

    return StockPktChart(
      pocketSn: json['pocketSn'] ?? '',
      pocketName: json['pocketName'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',

      tradeFlag: json['tradeFlag'] ?? '',
      tradeDttm: json['tradeDttm'] ?? '',
      tradePrice: json['tradePrice'] ?? '',
      listChart: rtList,
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$fluctuationRate|';
  }
}

