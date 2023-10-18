
/// 2020.10.06
/// 매매신호 종합보드
class TrSignal03 {
  final String retCode;
  final String retMsg;
  final Signal03? retData;

  TrSignal03({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSignal03.fromJson(Map<String, dynamic> json) {
    return TrSignal03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Signal03.fromJson(json['retData'])
    );
  }
}


class Signal03 {
  final Kospi kospi;
  final Kosdaq kosdaq;

  Signal03({this.kospi = defKospi, this.kosdaq = defKosdaq});

  factory Signal03.fromJson(Map<String, dynamic> json) {
    var kospiData = Kospi.fromJson(json['struct_Kospi']);
    var kosdaqData = Kosdaq.fromJson(json['struct_Kosdaq']);
    return Signal03(
        kospi: kospiData,
        kosdaq: kosdaqData,
    );
  }
}

const defKospi = Kospi();
const defKosdaq = Kosdaq();

class Kospi {
  final String marketType;
  final String tradeDate;
  final String tradeTime;
  final String totalCount;
  final String buyCount;
  final String sellCount;
  final String holdCount;
  final String waitCount;

  const Kospi({
    this.marketType = '', this.tradeDate = '',
    this.tradeTime = '', this.totalCount = '',
    this.buyCount = '', this.sellCount = '',
    this.holdCount = '', this.waitCount = ''
  });

  factory Kospi.fromJson(Map<String, dynamic> json) {
    return Kospi(
      marketType: json['marketType'] ?? '',
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      totalCount: json['totalCount'],
      buyCount: json['buyCount'],
      sellCount: json['sellCount'],
      holdCount: json['holdCount'],
      waitCount: json['waitCount'],
    );
  }

  @override
  String toString() {
    return 'KOSPI : $marketType|$totalCount|$tradeTime';
  }
}


class Kosdaq {
  final String marketType;
  final String tradeDate;
  final String tradeTime;
  final String totalCount;
  final String buyCount;
  final String sellCount;
  final String holdCount;
  final String waitCount;

  const Kosdaq({
    this.marketType = '', this.tradeDate = '',
    this.tradeTime = '', this.totalCount = '',
    this.buyCount = '', this.sellCount = '',
    this.holdCount = '', this.waitCount = ''
  });

  factory Kosdaq.fromJson(Map<String, dynamic> json) {
    return Kosdaq(
      marketType: json['marketType'] ?? '',
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      totalCount: json['totalCount'],
      buyCount: json['buyCount'],
      sellCount: json['sellCount'],
      holdCount: json['holdCount'],
      waitCount: json['waitCount'],
    );
  }

  @override
  String toString() {
    return 'KOSDAQ : $marketType|$totalCount|$tradeTime';
  }
}
