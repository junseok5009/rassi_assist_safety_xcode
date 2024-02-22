

class TrSearch11 {
  final String retCode;
  final String retMsg;
  final Search11 retData;

  TrSearch11({this.retCode='', this.retMsg='', this.retData = defSearch11});

  factory TrSearch11.fromJson(Map<String, dynamic> json) {
    return TrSearch11(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defSearch11
            : Search11.fromJson(json['retData'],),);
  }
}

const defSearch11 = Search11();
class Search11 {
  final String stockCode;
  final List<Search11PerPbr> listPerPbr;
  final List<Search11Dividend> listDividend;

  const Search11({
    this.stockCode='',
    this.listPerPbr = const [],
    this.listDividend = const [],
  });

  factory Search11.fromJson(Map<String, dynamic> json) {
    var list1 = json['list_PerPbr'] as List;
    List<Search11PerPbr> listData1 =
    list1 == null ? [] : list1.map((e) => Search11PerPbr.fromJson(e)).toList();
    var list2 = (json['list_Dividend'] ?? []) as List;
    List<Search11Dividend> listData2 = list2 == null
        ? []
        : list2.map((e) => Search11Dividend.fromJson(e)).toList();
    return Search11(
      stockCode: json['stockCode'] ?? '',
      listPerPbr: listData1,
      listDividend: listData2,
    );
  }
}

class Search11PerPbr {
  String tradeDate='';
  String tradePrice='';
  String stockCode='';
  String eps='';
  String per='';
  String pbr='';
  Search11PerPbr({
    this.tradeDate='',
    this.tradePrice='',
    this.stockCode='',
    this.eps='',
    this.per='',
    this.pbr='',
  });

  Search11PerPbr.empty(){
    tradeDate = '';
    tradePrice = '';
    stockCode = '';
    eps = '';
    per = '';
    pbr = '';
  }

  factory Search11PerPbr.fromJson(Map<String, dynamic> json) {
    return Search11PerPbr(
      tradeDate: json['tradeDate'] ?? '',
      tradePrice: json['tradePrice'] ?? '0',
      stockCode: json['stockCode'] ?? '',
      eps: json['eps'] ?? '0',
      per: json['per'] == null || json['per'].toString().isEmpty ? '0' : json['per'],
      pbr: json['pbr'] == null || json['pbr'].toString().isEmpty ? '0' : json['pbr'],
    );
  }

  @override
  String toString() {
    return '$tradeDate|$tradePrice|$stockCode|$eps';
  }
}

class Search11Dividend {
  final String stockCode;
  final String dividendYear;
  final String dividendRate;
  final String dividendAmt;

  Search11Dividend({
    this.stockCode='',
    this.dividendYear='',
    this.dividendRate='',
    this.dividendAmt='',
  });

  factory Search11Dividend.fromJson(Map<String, dynamic> json) {
    return Search11Dividend(
      stockCode: json['stockCode'] ?? '',
      dividendYear: json['dividendYear'] ?? '',
      dividendRate: json['dividendRate'] ?? '',
      dividendAmt: json['dividendAmt'] ?? '',
    );
  }

  @override
  String toString() {
    return '$dividendYear|$dividendRate|$dividendAmt';
  }
}
