import 'package:rassi_assist/models/keyword.dart';

/// 2022.07.21 땡정보로 인한 수정 > 22.09.01 마켓뷰 개편 수정
class StockStatus {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String fluctuationAmt;
  final String bizOverview;
  final List<Keyword> listKeyword;

  // 24.07.15 마켓뷰 개편 추가
  final String tradeFlag;
  final String tradeDate;
  final String tradeTime;
  final String tradePrice;
  final String profitRate;
  final String elapsedDays;

  StockStatus({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.bizOverview = '',
    this.listKeyword = const [],
    this.tradeFlag = '',
    this.tradeDate = '',
    this.tradeTime = '',
    this.tradePrice = '',
    this.profitRate = '',
    this.elapsedDays = '',
  });

  factory StockStatus.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Keyword'];
    return StockStatus(
        stockCode: json['stockCode'] ?? '',
        stockName: json['stockName'] ?? '',
        currentPrice: json['currentPrice'] ?? '',
        fluctuationRate: json['fluctuationRate'] ?? '',
        fluctuationAmt: json['fluctuationAmt'] ?? '',
        bizOverview: json['bizOverview'] ?? '',
        listKeyword: jsonList == null ? [] : (jsonList as List).map((i) => Keyword.fromJson(i)).toList(),
        tradeFlag: json['tradeFlag'] ?? '',
        tradeDate: json['tradeDate'] ?? '',
        tradeTime: json['tradeTime'] ?? '',
        tradePrice: json['tradePrice'] ?? '',
        profitRate: json['profitRate'] ?? '',
        elapsedDays: json['elapsedDays'] ?? '');
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$fluctuationAmt|$bizOverview';
  }
}
