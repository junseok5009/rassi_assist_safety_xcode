class TrInvest21 {
  final String retCode;
  final String retMsg;
  final Invest21 retData;

  TrInvest21({this.retCode='', this.retMsg='', this.retData = defInvest21});

  factory TrInvest21.fromJson(Map<String, dynamic> json) {
    return TrInvest21(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest21 : Invest21.fromJson(json['retData']),
    );
  }
  factory TrInvest21.fromJsonWithIndex(Map<String, dynamic> json) {
    return TrInvest21(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest21 : Invest21.fromJsonWithIndex(json['retData']),
    );
  }
}

const defInvest21 = Invest21();

class Invest21 {
  final String totalPageSize;
  final String currentPageNo;
  final String totalItemSize;
  final List<Invest21ChartData> listChartData;

  const Invest21({
    this.totalPageSize='',
    this.currentPageNo='',
    this.totalItemSize='',
    this.listChartData = const [],
  });

  factory Invest21.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<Invest21ChartData> dataList = list == null
        ? []
        : list.map((i) => Invest21ChartData.fromJson(i)).toList();
    return Invest21(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }

  factory Invest21.fromJsonWithIndex(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;

    List<Invest21ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) =>  Invest21ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Invest21(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }
}

class Invest21ChartData {
  final String td;  // 날짜
  final String tp;  // 가격
  final String tv; // 체결수량
  final String rv; // 상환수량
  final String bl; // 잔고
  final String ba; // 잔고금
  final int index;
  Invest21ChartData({
    this.td='', this.tp='', this.tv='',
    this.rv='', this.bl='', this.ba='', this.index=0
  });
  factory Invest21ChartData.fromJson(Map<String, dynamic> json) {
    return Invest21ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      tv: json['tv'] ?? '0',
      rv: json['rv'] ?? '0',
      bl: json['bl'] ?? '0',
      ba: json['ba'] ?? '0',
      index: 0,
    );
  }
  factory Invest21ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return Invest21ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      tv: json['tv'] ?? '0',
      rv: json['rv'] ?? '0',
      bl: json['bl'] ?? '0',
      ba: json['ba'] ?? '0',
      index: vIndex,
    );
  }
}
