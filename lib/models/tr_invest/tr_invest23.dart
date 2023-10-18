class TrInvest23 {
  final String retCode;
  final String retMsg;
  final Invest23 retData;

  TrInvest23({this.retCode='', this.retMsg='', this.retData = defInvest23});

  factory TrInvest23.fromJson(Map<String, dynamic> json) {
    return TrInvest23(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest23 : Invest23.fromJson(json['retData']),
    );
  }
  factory TrInvest23.fromJsonWithIndex(Map<String, dynamic> json) {
    return TrInvest23(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest23 : Invest23.fromJsonWithIndex(json['retData']),
    );
  }
}

const defInvest23 = Invest23();

class Invest23 {
  final String totalPageSize;
  final String currentPageNo;
  final String totalItemSize;
  final List<Invest23ChartData> listChartData;

  const Invest23({
    this.totalPageSize='',
    this.currentPageNo='',
    this.totalItemSize='',
    this.listChartData = const [],
  });

  factory Invest23.fromJson(Map<String, dynamic> json) {
    var list = json['list_Loan'] as List;
    List<Invest23ChartData> dataList = list == null
        ? []
        : list.map((i) => Invest23ChartData.fromJson(i)).toList();
    return Invest23(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }
  factory Invest23.fromJsonWithIndex(Map<String, dynamic> json) {
    var list = json['list_Loan'] as List;

    List<Invest23ChartData> dataList = list == null
        ? []
        : list.asMap().entries.map((e) =>  Invest23ChartData.fromJsonWithIndex(e.value, e.key)).toList();
    return Invest23(
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      totalItemSize: json['totalItemSize'] ?? '0',
      listChartData: dataList,
    );
  }
}

class Invest23ChartData {
  final String tradeDate;  // 날짜
  final String tradePrice; // 가격
  final String volumeNew;  // 신규 수량
  final String volumeRepay; // 상환 수량
  final String volumeBalance; // 잔고 수량
  final String creditRate; // 신용 공여율
  final String balanceRate; // 신용 잔고율
  final int index;
  Invest23ChartData({
    this.tradeDate='', this.tradePrice='', this.volumeNew='', this.volumeRepay='',
    this.volumeBalance='', this.creditRate='', this.balanceRate='', this.index=0
  });
  factory Invest23ChartData.fromJson(Map<String, dynamic> json) {
    return Invest23ChartData(
      tradeDate: json['tradeDate'] ?? '',
      tradePrice: json['tradePrice'] ?? '0',
      volumeNew: json['volumeNew'] ?? '0',
      volumeRepay: json['volumeRepay'] ?? '0',
      volumeBalance: json['volumeBalance'] ?? '0',
      creditRate: json['creditRate'] ?? '0',
      balanceRate: json['balanceRate'] ?? '0',
      index: 0,
    );
  }
  factory Invest23ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return Invest23ChartData(
      tradeDate: json['tradeDate'] ?? '',
      tradePrice: json['tradePrice'] ?? '0',
      volumeNew: json['volumeNew'] ?? '0',
      volumeRepay: json['volumeRepay'] ?? '0',
      volumeBalance: json['volumeBalance'] ?? '0',
      creditRate: json['creditRate'] ?? '0',
      balanceRate: json['balanceRate'] ?? '0',
      index: vIndex,
    );
  }
}
