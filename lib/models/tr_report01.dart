class TrReport01 {
  final String retCode;
  final String retMsg;
  final Report01 retData;

  TrReport01({this.retCode = '', this.retMsg = '', this.retData = defReport01});

  factory TrReport01.fromJson(Map<String, dynamic> json) {
    return TrReport01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null
          ? defReport01
          : Report01.fromJson(json['retData']),
    );
  }
}

const defReport01 = Report01();
class Report01 {
  final String stockCode;
  final String stockName;
  final String priceAvg;
  final String priceMax;
  final String priceMin;
  final String priceComp;
  final List<Report01ChartData> listChartData;

  const Report01({
    this.stockCode = '',
    this.stockName = '',
    this.priceAvg = '',
    this.priceMax = '',
    this.priceMin = '',
    this.priceComp = '',
    this.listChartData = const [],
  });

/*  Report01.empty(){
    this.stockCode = '';
    this.stockName = '';
    this.priceAvg = '';
    this.priceMax = '';
    this.priceMin = '';
    this.priceComp = '';
    this.listChartData = [];
  }*/

  factory Report01.fromJson(Map<String, dynamic> json) {
    var list = json['list_Report'] as List;
    List<Report01ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) => Report01ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Report01(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      priceAvg: json['priceAvg'] ?? '', // 목표가 평균
      priceMax: json['priceMax'] ?? '', // 목표가 최고
      priceMin: json['priceMin'] ?? '', // 목표가 최저
      priceComp: json['priceComp'] ?? '',// 목표가 평균 대비 현재가 비율
      listChartData: dataList,
    );
  }
}

class Report01ChartData {
  final String td; // 날짜
  final String tp; // 가격
  final String agp; // 일(월)별 주가 리스트
  final int? index;

  Report01ChartData({
    this.td = '', this.tp = '', this.agp = '', this.index});

  factory Report01ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return Report01ChartData(
      td: json['td'] ?? '',
      tp: (json['tp'] == null || json['tp'] == '') ? '0' : json['tp'],
        agp: (json['agp'] == null) ? '' : json['agp'],
        index: vIndex
    );
  }
}
