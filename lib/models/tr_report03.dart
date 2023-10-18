class TrReport03 {
  final String retCode;
  final String retMsg;
  final Report03 retData;

  TrReport03({this.retCode = '', this.retMsg = '', this.retData = defReport03});

  factory TrReport03.fromJson(Map<String, dynamic> json) {
    return TrReport03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defReport03 : Report03.fromJson(json['retData']),
    );
  }
}

const defReport03 = Report03();

class Report03 {
  final String stockCode;
  final String stockName;
  final String reportTotal;   // 리포트 발행 총건수
  final String organName;     // 최다 리포트 발행 증권사
  final String organCount;    // 최다 리포트 발행 증권사의 건수
  final List<Report03ChartData> listChartData;  // 증권사별 발행 리스트

  const Report03({
    this.stockCode = '',
    this.stockName = '',
    this.reportTotal = '',
    this.organName = '',
    this.organCount = '',
    this.listChartData = const [],
  });

/*  Report03.empty(){
   stockCode = '';
   stockName = '';
   reportTotal = '';
   organName = '';
   organCount = '';
   listChartData = [];
  }*/

  factory Report03.fromJson(Map<String, dynamic> json) {
    var list = json['list_Report'] as List;
    List<Report03ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) => Report03ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Report03(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      reportTotal: json['reportTotal'] ?? '', // 목표가 평균
      organName: json['organName'] ?? '', // 목표가 최고
      organCount: json['organCount'] ?? '', // 목표가 최저
      listChartData: dataList,
    );
  }
}

class Report03ChartData {
  String organName;   // 리포트 발행 증권사
  String organCount;  // 리포트 발행 증권사의 건수
  final int? index;

  Report03ChartData({
    this.organName = '', this.organCount = '', this.index,
  });

  factory Report03ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex,) {
    return Report03ChartData(
      organName: json['organName'] ?? '',
      organCount: json['organCount'] ?? '0',
      index: vIndex,
    );
  }
}
