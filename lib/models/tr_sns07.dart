

/// 커뮤니티 활동 급상승 조회 (지난 이력까지)
class TrSns07 {
  final String retCode;
  final String retMsg;
  final Sns07 retData;

  TrSns07({this.retCode='', this.retMsg='', this.retData = defSns07});

  factory TrSns07.fromJson(Map<String, dynamic> json) {
    return TrSns07(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      retData: json['retData'] == null
          ? defSns07
          : Sns07.fromJson(json['retData']),
    );
  }
}


const defSns07 = Sns07();
class Sns07 {
  final List<Sns07Elapsed> listTimeline;

  const Sns07({this.listTimeline = const [],});

  factory Sns07.fromJson(Map<String, dynamic> json) {
    var list = json['listTimeline'] as List;
    // List<Sns07Elapsed> rtList;
    // list == null
    //     ? rtList = null
    //     : rtList = list.map((i) => Sns07Elapsed.fromJson(i)).toList();

    return Sns07(
      listTimeline: list.map((i) => Sns07Elapsed.fromJson(i)).toList(),
      // listSns03: listSns,
    );
  }
}

class Sns07Elapsed {
  final String elapsedTmTx;
  final List<SnsStock> listData;

  Sns07Elapsed({this.elapsedTmTx='', this.listData = const [],});

  factory Sns07Elapsed.fromJson(Map<String, dynamic> json) {
    var list = json['listStock'] as List;
    // List<SnsStock> rtList;
    // list == null
    //     ? rtList = null
    //     : rtList = list.map((i) => SnsStock.fromJson(i)).toList();

    return Sns07Elapsed(
      elapsedTmTx: json['elapsedTmTx'] ?? '',
      listData: list.map((i) => SnsStock.fromJson(i)).toList(),
    );
  }
}

class SnsStock {
  final String stockCode;
  final String stockName;
  final String issueDttm;
  final String fluctuationRate;

  SnsStock({
    this.stockCode='',
    this.stockName='',
    this.issueDttm='',
    this.fluctuationRate='',
  });

  factory SnsStock.fromJson(Map<String, dynamic> json) {
    return SnsStock(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
    );
  }
}

