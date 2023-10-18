class TrReport02 {
  final String retCode;
  final String retMsg;
  final Report02 retData;

  TrReport02({this.retCode = '', this.retMsg = '', this.retData = defReport02});

  factory TrReport02.fromJson(Map<String, dynamic> json) {
    return TrReport02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null
          ? defReport02
          : Report02.fromJson(json['retData']),
    );
  }
}


const defReport02 = Report02();

class Report02 {
  final String selectDiv;
  final String reportTotal;
  final String reportMonth;
  final String reportComp;
  final List<Report02ChartData> listChartData;

  const Report02({
    this.selectDiv = '',
    this.reportTotal = '',
    this.reportMonth = '',
    this.reportComp = '',
    this.listChartData = const [],
  });

/*  Report02.empty(){
    this.selectDiv = '';
    this.reportTotal = '';
    this.reportMonth = '';
    this.reportComp = '';
    this.listChartData = [];
  }*/

  factory Report02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Report'] as List;
    List<Report02ChartData> dataList = list == null
        ? []
        : list.map((i) => Report02ChartData.fromJson(i)).toList();
    return Report02(
      //stockCode: json['stockCode'] ?? '',
      //stockName: json['stockName'] ?? '',
      selectDiv: json['selectDiv'] ?? '',     //
      reportTotal: json['reportTotal'] ?? '', // 리포트 발행 총건수
      reportMonth: json['reportMonth'] ?? '', // 이번 달 리포트 발행 개수
      reportComp: json['reportComp'] ?? '',   // 전월(분기) 대비 발행 비율
      listChartData: dataList,
    );
  }
}

class Report02ChartData {
  final String td;    // 날짜(YYYYMM) / 분기(YYYY/Q)
  final String rcb;   // buy 리포트 발행 개수
  final String rcs;   // sell 리포트 발행 개수
  final String rce;   // etc 리포트 발행 개수

  Report02ChartData({
    this.td = '', this.rcb = '', this.rcs = '', this.rce = ''});

  factory Report02ChartData.fromJson(Map<String, dynamic> json) {
    return Report02ChartData(
      td: json['td'] ?? '',
      rcb: json['rcb'] ?? '0',
      rcs: json['rcs'] ?? '0',
      rce: json['rce'] ?? '0',
    );
  }
}
