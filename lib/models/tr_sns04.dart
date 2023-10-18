
/// 2021.07.01
/// 당일 소셜지수 발생 히스토리
class TrSns04 {
  final String retCode;
  final String retMsg;
  final List<Sns04> listData;

  TrSns04({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrSns04.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Sns04> rtList;
    list == null ? rtList = const [] : rtList = list.map((i) => Sns04.fromJson(i)).toList();

    return TrSns04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList,
    );
  }
}

// TimeLine Sns
class Sns04 {
  final String issueTime;
  final List<SnsFlow> listData;
  final int subCount;

  Sns04({this.issueTime = '', this.listData = const [], this.subCount = 0});

  factory Sns04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<SnsFlow> listStk = list.map((e) => SnsFlow.fromJson(e)).toList();

    return Sns04(
      issueTime: json['issueTime'],
      listData: listStk,
      subCount: listStk.length,
    );
  }

  @override
  String toString() {
    return '$issueTime|';
  }
}

class SnsFlow {
  final String stockCode;
  final String stockName;
  final String elapsedTmTx;
  final String title;
  final String linkUrl;

  SnsFlow({this.stockCode = '', this.stockName = '', this.elapsedTmTx = '', this.title = '', this.linkUrl = ''});

  factory SnsFlow.fromJson(Map<String, dynamic> json) {
    return SnsFlow(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      elapsedTmTx: json['elapsedTmTx'],
      title: json['title'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$elapsedTmTx|$title|$linkUrl';
  }
}
