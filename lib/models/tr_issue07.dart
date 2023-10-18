

class TrIssue07 {
  final String retCode;
  final String retMsg;
  final List<Issue07> listData;

  TrIssue07({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue07.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    print(list.runtimeType);
    List<Issue07> rtList = list.map((i) => Issue07.fromJson(i)).toList();

    return TrIssue07(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class Issue07 {
  final String title;
  final String stockCode;
  final String stockName;
  final String tradeDate;
  final String tradeTime;

  Issue07({
    this.title = '',
    this.stockCode = '',
    this.stockName = '',
    this.tradeDate = '',
    this.tradeTime = ''
  });

  factory Issue07.fromJson(Map<String, dynamic> json) {
    return Issue07(
        title: json['title'],
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        tradeDate: json['tradeDate'],
        tradeTime: json['tradeTime']
    );
  }
}
