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

  StockStatus({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.bizOverview = '',
    this.listKeyword = const [],
  });

  factory StockStatus.fromJson(Map<String, dynamic> json) {
    var list = json['list_Keyword'] as List;
    List<Keyword> rtList;
    list == null ? rtList = [] : rtList = list.map((i) => Keyword.fromJson(i)).toList();

    return StockStatus(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      currentPrice: json['currentPrice'],
      fluctuationRate: json['fluctuationRate'],
      fluctuationAmt: json['fluctuationAmt'],
      bizOverview: json['bizOverview'],
      listKeyword: rtList,
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$fluctuationAmt|$bizOverview';
  }
}
