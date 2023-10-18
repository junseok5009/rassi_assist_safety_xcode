class TrInvest02 {
  final String retCode;
  final String retMsg;
  final Invest02 retData;

  TrInvest02({this.retCode = '', this.retMsg = '', this.retData = defInvest02});

  factory TrInvest02.fromJson(Map<String, dynamic> json) {
    return TrInvest02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest02 : Invest02.fromJson(json['retData']),
    );
  }
  factory TrInvest02.fromJsonWithIndex(Map<String, dynamic> json) {
    return TrInvest02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest02 : Invest02.fromJsonWithIndex(json['retData']),
    );
  }
}

const defInvest02 = Invest02();

class Invest02 {
  final String stockCode;
  final String stockName;
  final String accFrnVol;
  final String accOrgVol;
  final String accPsnVol; // 개인
  final List<Invest02ChartData> listChartData;

  const Invest02({
    this.stockCode = '',
    this.stockName = '',
    this.accFrnVol = '',
    this.accOrgVol = '',
    this.accPsnVol = '',
    this.listChartData = const [],
  });

  factory Invest02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<Invest02ChartData> dataList = list == null
        ? []
        : list.map((i) => Invest02ChartData.fromJson(i)).toList();
    return Invest02(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      accFrnVol: json['accFrnVol'] ?? '',
      accOrgVol: json['accOrgVol'] ?? '',
      accPsnVol: json['accPsnVol'] ?? '',
      listChartData: dataList,
    );
  }
  factory Invest02.fromJsonWithIndex(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;

    List<Invest02ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) =>  Invest02ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Invest02(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      accFrnVol: json['accFrnVol'] ?? '',
      accOrgVol: json['accOrgVol'] ?? '',
      accPsnVol: json['accPsnVol'] ?? '',
      listChartData: dataList,
    );
  }
}

class Invest02ChartData {
  final String td; // 날짜
  final String tp; // 가격
  late final String afv; // [외인] 누적 수량
  late final String aov; // [기관] 누적 수량
  final String apv; // [개인] 누적 수량
  final int index;
  Invest02ChartData({this.td='', this.tp='', this.afv='', this.aov='', this.apv='', this.index=0});
  factory Invest02ChartData.fromJson(Map<String, dynamic> json) {
    return Invest02ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      afv: json['afv'] ?? '0',
      aov: json['aov'] ?? '0',
      apv: json['apv'] ?? '0',
      index: 0,
    );
  }
  factory Invest02ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return Invest02ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      afv: json['afv'] ?? '0',
      aov: json['aov'] ?? '0',
      apv: json['apv'] ?? '0',
      index: vIndex,
    );
  }
}
