class TrInvest03 {
  final String retCode;
  final String retMsg;
  final Invest03? retData;
  TrInvest03({this.retCode='', this.retMsg='', this.retData});
  factory TrInvest03.fromJson(Map<String, dynamic> json) {
    return TrInvest03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Invest03.fromJson(json['retData']),
    );
  }
}

class Invest03 {
  final String stockCode;
  final String stockName;
  final List<Invest03TimeLine>? listInvest03TimeLine;
  Invest03({
    this.stockCode='',
    this.stockName='',
    this.listInvest03TimeLine,
  });
  factory Invest03.fromJson(Map<String, dynamic> json) {
    var list = json['list_Timeline'] as List;
    List<Invest03TimeLine> dataList = list == null
        ? []
        : list.map((i) => Invest03TimeLine.fromJson(i)).toList();
    return Invest03(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      listInvest03TimeLine: dataList,
    );
  }
}

class Invest03TimeLine {
  final String tradeDate;
  final String buyVol;
  final String sellVol;
  final String netVol;
  final List<Invest03Organ>? listInvest03Organ;
  Invest03TimeLine({
    this.tradeDate='',
    this.buyVol='',
    this.sellVol='',
    this.netVol='',
    this.listInvest03Organ
  });
  factory Invest03TimeLine.fromJson(Map<String, dynamic> json) {
    var list = json['list_Organ'] as List;
    List<Invest03Organ> dataList = list == null
        ? []
        : list.map((i) => Invest03Organ.fromJson(i)).toList();
    return Invest03TimeLine(
      tradeDate: json['tradeDate'] ?? '',
      buyVol: json['buyVol'].toString() ?? '0',
      sellVol: json['sellVol'].toString() ?? '0',
      netVol: json['netVol'].toString() ?? '0',
      listInvest03Organ: dataList,
    );
  }
}

class Invest03Organ {
  final String tradeFlag;
  final String tradeVol;
  final String organName;
  Invest03Organ({this.tradeFlag='', this.tradeVol='', this.organName='',});
  factory Invest03Organ.fromJson(Map<String, dynamic> json) {
    return Invest03Organ(
      tradeFlag: json['tradeFlag'] ?? '',
      tradeVol: json['tradeVol'] ?? '0',
      organName: json['organName'] ?? '',
    );
  }
}

