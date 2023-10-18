import '../rassiro.dart';


/// 2023.08.23 - JS
/// 라씨 데스크 Rassi16 대체
class TrRassi17 {
  final String retCode;
  final String retMsg;
  final Rassi17 retData;

  TrRassi17({this.retCode = '', this.retMsg = '', this.retData = defRassi17});

  factory TrRassi17.fromJson(Map<String, dynamic> json) {
    return TrRassi17(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null
          ? defRassi17
          : Rassi17.fromJson(json['retData']),
    );
  }
}

const defRassi17 = Rassi17();

class Rassi17 {
  final String menuDiv;
  final String menuName;
  final List<Rassi17Stock> stockList;
  final List<Rassiro> newsList;

  const Rassi17({
    this.menuDiv = '',
    this.menuName = '',
    this.stockList = const [],
    this.newsList = const []
  });

  factory Rassi17.fromJson(Map<String, dynamic> json) {
    List<Rassi17Stock> listData1 = json['list_Stock'] == null
        ? []
        : (json['list_Stock'] as List).map((e) => Rassi17Stock.fromJson(e)).toList();
    List<Rassiro> listData2 = json['list_Rassiro'] == null
        ? []
        : (json['list_Rassiro'] as List).map((e) => Rassiro.fromJson(e)).toList();
    return Rassi17(
      menuDiv: json['menuDiv'],
      menuName: json['menuName'],
      stockList: listData1,
      newsList: listData2,
    );
  }
}

class Rassi17Stock{
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

  Rassi17Stock({
    this.stockCode='',
    this.stockName='',
    this.currentPrice='',
    this.fluctuationRate='',
    this.fluctuationAmt='',
    this.netVol='',
    this.netAmt='',
    this.afterHourClose='',
    this.afterHourVol='',
    this.afterHourFluctRate='',
    this.afterHourFluctAmt='',
    this.title='',
  });

  factory Rassi17Stock.fromJson(Map<String, dynamic> json) {
    return Rassi17Stock(
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

