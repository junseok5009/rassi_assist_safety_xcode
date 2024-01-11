

import '../rassiro.dart';

/// 2023.06.28 - JS
/// 라씨 데스크
class TrRassi16 {
  final String retCode;
  final String retMsg;
  final Rassi16? retData;

  TrRassi16({this.retCode = '', this.retMsg = '', this.retData});

  factory TrRassi16.fromJson(Map<String, dynamic> json) {
    return TrRassi16(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Rassi16.fromJson(json['retData']),
    );
  }
}

class Rassi16 {
  final String menuDiv;
  final String menuName;
  final List<Rassi16Stock>? stockList;
  final List<Rassiro>? newsList;

  Rassi16({this.menuDiv = '', this.menuName = '', this.stockList, this.newsList});

  factory Rassi16.fromJson(Map<String, dynamic> json) {
    var list1 = json['list_Stock'] as List;
    List<Rassi16Stock> listData1 = list1.map((e) => Rassi16Stock.fromJson(e)).toList();
    var list2 = json['list_Rassiro'] as List;
    List<Rassiro> listData2 = list2.map((e) => Rassiro.fromJson(e)).toList();
    return Rassi16(
        menuDiv: json['menuDiv'],
        menuName: json['menuName'],
        stockList: listData1,
        newsList: listData2,
    );
  }
}

class Rassi16Stock{
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String fluctuationAmt;
  final String netVol;  // 외인/기관 순매매 수량
  final String netAmt;  // 외인/기관 순매매 금액
  final String afterHourClose;  // 시간외 종가
  final String afterHourVol;  // 시간외 거래수량
  final String afterHourFluctRate;  // 시간외 등락률
  final String afterHourFluctAmt;  // 시간외 등락액
  final String title; // 종목의 이슈 제목
  Rassi16Stock({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.netVol = '',
    this.netAmt = '',
    this.afterHourClose = '',
    this.afterHourVol = '',
    this.afterHourFluctRate = '',
    this.afterHourFluctAmt = '',
    this.title = '',
  });

  factory Rassi16Stock.fromJson(Map<String, dynamic> json) {
    return Rassi16Stock(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      netVol: json['netVol'] ?? '',
      netAmt: json['netAmt'] ?? '',
      afterHourClose: json['afterHourClose'] ?? '',
      afterHourVol: json['afterHourVol'] ?? '',
      afterHourFluctRate: json['afterHourFluctRate'] ?? '',
      afterHourFluctAmt: json['afterHourFluctAmt'] ?? '',
      title: json['title'] ?? '',
    );
  }

}

