
/// 2021.02.23
/// 최근 AI 매매신호 발생 현황
class TrSignal23 {
  final String retCode;
  final String retMsg;
  final Signal23? resData;

  TrSignal23({this.retCode = '', this.retMsg = '', this.resData});

  factory TrSignal23.fromJson(Map<String, dynamic> json) {
    return TrSignal23(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        resData: json['retData'] != null ? Signal23.fromJson(json['retData']) : null
    );
  }
}


class Signal23 {
  final List<SignalAnalysis>? listAns;
  final List<SigStockInfo>? listStk;

  Signal23({this.listAns, this.listStk,});

  factory Signal23.fromJson(Map<String, dynamic> json) {
    var list = json['list_SignalAnal'] as List;
    List<SignalAnalysis>? rtListAns;
    list == null ? rtListAns = null : rtListAns = list.map((i) => SignalAnalysis.fromJson(i)).toList();
    var list2 = json['list_Stock'] as List;
    List<SigStockInfo>? rtListStk;
    list2 == null ? rtListStk = null : rtListStk = list2.map((i) => SigStockInfo.fromJson(i)).toList();

    return Signal23(
      listAns: rtListAns,
      listStk: rtListStk,
    );
  }
}


class SignalAnalysis {
  final String analTarget;
  final String empValue;
  final String achieveText;
  final String periodMonth;
  final String beginDate;
  final String issueDate;

  SignalAnalysis({
    this.analTarget = '', this.empValue = '', this.achieveText = '',
    this.periodMonth = '', this.beginDate = '', this.issueDate = '',
  });

  factory SignalAnalysis.fromJson(Map<String, dynamic> json) {
    return SignalAnalysis(
      analTarget: json['analTarget'],
      empValue: json['empValue'],
      achieveText: json['achieveText'] ?? '',
      periodMonth: json['periodMonth'] ?? '',
      beginDate: json['beginDate'],
      issueDate: json['issueDate'],
    );
  }
}


class SigStockInfo {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final String profitRate;
  final String holdingDays;

  SigStockInfo({
    this.stockCode = '', this.stockName = '',
    this.tradeFlag = '', this.tradeDttm = '',
    this.tradePrice = '', this.profitRate = '',
    this.holdingDays = ''
  });

  factory SigStockInfo.fromJson(Map<String, dynamic> json) {
    return SigStockInfo(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDttm: json['tradeDttm'],
      tradePrice: json['tradePrice'],
      profitRate: json['profitRate'],
      holdingDays: json['holdingDays'],
    );
  }
}
