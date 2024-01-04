import 'package:rassi_assist/models/tr_pock/tr_pock04.dart';

/// 종목정보 (포켓안에서) 나만의 매도신호 종목정보
class StockPktSignal {
  final String stockCode;
  final String stockName;
  final String myTradeFlag;
  final String buyPrice;
  final String buyRegDttm;
  final String sellPrice;
  final String sellDttm;
  final String profitRate;
  final String currentPrice;
  final String fluctuationAmt;
  final String fluctuationRate;
  final String tradingHaltYn;
  final String pocketSn;
  final String resultDiv;
  final List<ListTalk> listTalk;

  StockPktSignal({
    this.stockCode = '',
    this.stockName = '',
    this.myTradeFlag = '',
    this.buyPrice = '',
    this.buyRegDttm = '',
    this.sellPrice = '',
    this.sellDttm = '',
    this.profitRate = '',
    this.currentPrice = '',
    this.fluctuationAmt = '',
    this.fluctuationRate = '',
    this.tradingHaltYn = '',
    this.pocketSn = '',
    this.resultDiv = '',
    this.listTalk = const [],
  });

  factory StockPktSignal.fromJson(Map<String, dynamic> json) {
    var list = json['list_Talk'] as List<dynamic>?;
    List<ListTalk> rtList;
    if (list == null) {
      rtList = [];
    } else {
      rtList = list.map((i) => ListTalk.fromJson(i)).toList();
    }
    return StockPktSignal(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      myTradeFlag: json['myTradeFlag'] ?? '',
      buyPrice: json['buyPrice'] ?? '',
      buyRegDttm: json['buyRegDttm'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      sellDttm: json['sellDttm'] ?? '',
      profitRate: json['profitRate'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      tradingHaltYn: json['tradingHaltYn'] ?? 'N',
      pocketSn: json['pocketSn'] ?? '',
      resultDiv: json['resultDiv'] ?? '',
      listTalk: rtList,
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$fluctuationRate|';
  }
}
