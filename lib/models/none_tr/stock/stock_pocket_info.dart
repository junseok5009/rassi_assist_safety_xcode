import 'package:rassi_assist/models/none_tr/stock/stock.dart';

/// 종목정보 (포켓안에서) with 차트데이터
class StockPocketInfo extends Stock {
  final String pocketSn;
  final String pocketName;
  final String stockCode;
  final String stockName;
  final String profitRate;
  final String fluctuationRate;
  final String tradeFlag;

  StockPocketInfo({
    this.pocketSn = '',
    this.pocketName = '',
    this.stockCode = '',
    this.stockName = '',
    this.profitRate = '',
    this.fluctuationRate = '',
    this.tradeFlag = '',
  });

  factory StockPocketInfo.fromJson(Map<String, dynamic> json) {
    return StockPocketInfo(
      pocketSn: json['pocketSn'] ?? '',
      pocketName: json['pocketName'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      profitRate: json['profitRate'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$pocketName|';
  }
}
