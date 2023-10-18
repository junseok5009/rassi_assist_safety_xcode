
/// 2020.09.07 - JY
/// 오늘의 내 종목 소식
class TrToday02 {
  final String retCode;
  final String retMsg;
  final List<Today02> listData;

  TrToday02({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrToday02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    // List<Today02> rtList;
    // list == null ? rtList = null : rtList = list.map((i) => Today02.fromJson(i)).toList();

    return TrToday02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => Today02.fromJson(i)).toList(),
    );
  }
}


class Today02 {
  final String pocketSn;
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String fluctRate;
  final String rassiroCount;
  final String sbCount;

  Today02({
    this.pocketSn='',
    this.stockCode='',
    this.stockName='',
    this.tradeFlag='',
    this.fluctRate='',
    this.rassiroCount='',
    this.sbCount=''
  });

  factory Today02.fromJson(Map<String, dynamic> json) {
    return Today02(
      pocketSn: json['pocketSn'],
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      fluctRate: json['fluctuationRate'],
      rassiroCount: json['rassiroCount'],
      sbCount: json['sbCount'],
    );
  }
}
