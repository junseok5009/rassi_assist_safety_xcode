class TrInvest01 {
  final String retCode;
  final String retMsg;
  final Invest01 retData;

  TrInvest01({this.retCode = '', this.retMsg = '', this.retData = defInvest01});

  factory TrInvest01.fromJson(Map<String, dynamic> json) {
    return TrInvest01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defInvest01 : Invest01.fromJson(json['retData']),
    );
  }
}

const defInvest01 = Invest01();

class Invest01 {
  final String stockCode;
  final String stockName;
  final String baseDate;
  final String frnHoldRate;
  final String totalPageSize;
  final List<Invest01ChartData> listChartData;

  const Invest01({
    this.stockCode = '',
    this.stockName = '',
    this.baseDate = '',
    this.frnHoldRate = '',
    this.listChartData = const [],
    this.totalPageSize = '',
  });

  factory Invest01.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<Invest01ChartData> dataList = list == null
        ? []
        : list.map((i) => Invest01ChartData.fromJson(i)).toList();
    return Invest01(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      baseDate: json['baseDate'] ?? '',
      frnHoldRate: json['frnHoldRate'] ?? '',
      totalPageSize: json['totalPageSize'] ?? '',
      listChartData: dataList,
    );
  }
}

class Invest01ChartData {
  final String td; // 날짜
  final String tp; // 가격
  final String fa; // 변동 금액(전일비)
  final String fv; // [외인] 순매매 수량
  final String fh; // [외인] 보유율(%)
  final String ov; // [기관] 순매매 수량
  final String pv; // [개인] 순매매 수량
  final String itv; // [투신] 순매매 수량
  final String rpv; // [연기금] 순매매 수량
  final String pev; // [사모펀드] 순매매 수량

  Invest01ChartData({
    this.td = '',
    this.tp = '',
    this.fa = '',
    this.fv = '',
    this.fh = '',
    this.ov = '',
    this.pv = '',
    this.itv = '',
    this.rpv = '',
    this.pev = ''
  });

  factory Invest01ChartData.fromJson(Map<String, dynamic> json) {
    return Invest01ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      fa: json['fa'] ?? '0',
      fv: json['fv'] ?? '0',
      fh: json['fh'] ?? '0',
      ov: json['ov'] ?? '0',
      pv: json['pv'] ?? '0',
      itv: json['itv'] ?? '0',
      rpv: json['rpv'] ?? '0',
      pev: json['pev'] ?? '0',
    );
  }
}
