class TrInvest22 {
  final String retCode;
  final String retMsg;
  final Invest22 retData;

  TrInvest22({this.retCode = '', this.retMsg = '', this.retData = defInvest22});

  factory TrInvest22.fromJson(Map<String, dynamic> json) {
    return TrInvest22(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest22 : Invest22.fromJson(json['retData']),
    );
  }
  factory TrInvest22.fromJsonWithIndex(Map<String, dynamic> json) {
    return TrInvest22(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest22 : Invest22.fromJsonWithIndex(json['retData']),
    );
  }
}

const defInvest22 = Invest22();

class Invest22 {
  final String totalPageSize;
  final String currentPageNo;
  final String totalItemSize;
  final List<Invest22ChartData> listChartData;

  const Invest22({
    this.totalPageSize = '0',
    this.currentPageNo = '0',
    this.totalItemSize = '0',
    this.listChartData = const [],
  });

  factory Invest22.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List?;
    List<Invest22ChartData> dataList = list == null
        ? []
        : list.map((i) => Invest22ChartData.fromJson(i)).toList();
    return Invest22(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }
  factory Invest22.fromJsonWithIndex(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List?;
    List<Invest22ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) =>  Invest22ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Invest22(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }
}

class Invest22ChartData {
  final String td;  // 날짜
  final String tp;  // 가격
  final String tv; // 거래수량
  final String sv; // 공매수량
  final String asv; // 누적 공매수량
  final String sa; // 공매금액
  final String sr; // 매매비중
  final int index;
  Invest22ChartData({
    this.td='', this.tp='0', this.tv='0', this.sv='0',
    this.asv='0', this.sa='0', this.sr='0', this.index=0
  });
  factory Invest22ChartData.fromJson(Map<String, dynamic> json) {
    return Invest22ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      tv: json['tv'] ?? '0',
      sv: json['sv'] ?? '0',
      asv: json['asv'] ?? '0',
      sa: json['sa'] ?? '0',
      sr: json['sr'] ?? '0',
      index: 0,
    );
  }
  factory Invest22ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return Invest22ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      tv: json['tv'] ?? '0',
      sv: json['sv'] ?? '0',
      asv: json['asv'] ?? '0',
      sa: json['sa'] ?? '0',
      sr: json['sr'] ?? '0',
      index: vIndex,
    );
  }
}
