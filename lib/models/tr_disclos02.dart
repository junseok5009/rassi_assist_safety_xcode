class TrDisclos02 {
  final String retCode;
  final String retMsg;
  final Disclos02? retData;

  TrDisclos02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrDisclos02.fromJson(Map<String, dynamic> json) {
    return TrDisclos02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Disclos02.fromJson(json['retData']),
    );
  }
}

class Disclos02 {
  final String newsSn;
  final String issueDate;
  final String title;
  final String content;
  final String stockCode;
  final String stockName;

  Disclos02({
    this.newsSn = '', this.issueDate = '', this.title = '',
    this.content = '', this.stockCode = '', this.stockName = '',});

  factory Disclos02.fromJson(Map<String, dynamic> json) {
    return Disclos02(
      newsSn: json['newsSn'] ?? '',
      issueDate: json['issueDate'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
    );
  }
}