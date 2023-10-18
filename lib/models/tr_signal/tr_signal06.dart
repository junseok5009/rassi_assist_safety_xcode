
/// 2020.10.06
/// 전종목 당일 매매신호 타임라인
class TrSignal06 {
  final String retCode;
  final String retMsg;
  final Signal06? retData;

  TrSignal06({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSignal06.fromJson(Map<String, dynamic> json) {
    return TrSignal06(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Signal06.fromJson(json['retData']),
    );
  }
}


class Signal06 {
  final String displayYn;
  final String honorCount;
  final List<TimeLineSig> listData;

  Signal06({this.displayYn = '', this.honorCount = '', this.listData = const []});

  factory Signal06.fromJson(Map<String, dynamic> json) {
    var list = json['list_Timeline'] as List;
    // List<TimeLineSig>? rtList;
    // list == null ? rtList = null : rtList = list.map((i) => TimeLineSig.fromJson(i)).toList();

    return Signal06(
        displayYn: json['displayYn'],
        honorCount: json['honorCount'],
        listData: list.map((i) => TimeLineSig.fromJson(i)).toList(),
    );
  }
}


class TimeLineSig {
  final String elapsedTmTx;
  final List<SignalSig> listData;

  TimeLineSig({this.elapsedTmTx = '', this.listData = const []});

  factory TimeLineSig.fromJson(Map<String, dynamic> json) {
    var list = json['list_Signal'] as List;
    List<SignalSig> listSig = list.map((e) => SignalSig.fromJson(e)).toList();

    return TimeLineSig(
      elapsedTmTx: json['elapsedTmTx'],
      listData: listSig,
    );
  }

  @override
  String toString() {
    return '$elapsedTmTx|';
  }
}

class SignalSig {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final String honorDiv;
  final String elapsedDays;

  SignalSig({
    this.stockCode = '', this.stockName = '',
    this.tradeFlag = '', this.tradeDttm = '',
    this.tradePrice = '', this.honorDiv = '',
    this.elapsedDays = ''
  });

  factory SignalSig.fromJson(Map<String, dynamic> json) {
    return SignalSig(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDttm: json['tradeDttm'],
      tradePrice: json['tradePrice'],
      honorDiv: json['honorDiv'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag|$tradeDttm|$tradePrice';
  }
}
