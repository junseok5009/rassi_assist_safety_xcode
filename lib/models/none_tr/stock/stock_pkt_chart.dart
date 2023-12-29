import 'package:rassi_assist/models/none_tr/chart_data.dart';

/// 종목정보 (포켓안에서) with 차트데이터
class StockPktChart {
  final String pocketSn;
  final String pocketName;
  final String stockCode;
  final String stockName;
  final String fluctuationAmt;
  final String fluctuationRate;
  final String listingYn;
  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final String myTradeFlag;
  final String sellPrice;
  final String sellDttm;
  final List<ChartData> listChart;

  StockPktChart({
    this.pocketSn = '',
    this.pocketName = '',
    this.stockCode = '',
    this.stockName = '',
    this.fluctuationAmt = '',
    this.fluctuationRate = '',
    this.listingYn = '',
    this.tradeFlag = '',
    this.tradeDttm = '',
    this.tradePrice = '',
    this.myTradeFlag = '',
    this.sellPrice = '',
    this.sellDttm = '',
    this.listChart = const [],
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
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      listingYn: json['listingYn'] ?? 'N',
      tradeFlag: json['tradeFlag'] ?? '',
      tradeDttm: json['tradeDttm'] ?? '',
      tradePrice: json['tradePrice'] ?? '',
      myTradeFlag: json['myTradeFlag'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      sellDttm: json['sellDttm'] ?? '',
      listChart: rtList,
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$fluctuationAmt|$fluctuationRate|';
  }
}
