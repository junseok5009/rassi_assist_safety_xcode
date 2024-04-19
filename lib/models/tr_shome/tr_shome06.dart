class TrShome06 {
  final String retCode;
  final String retMsg;
  final Shome06 retData;
  TrShome06({this.retCode='', this.retMsg='', this.retData = defShome06});
  factory TrShome06.fromJson(Map<String, dynamic> json) {
    return TrShome06(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defShome06
            : Shome06.fromJson(json['retData']));
  }
}

const defShome06 = Shome06();
class Shome06 {
  final String stockCode;
  final String stockName;
  final String updateDate;
  final String title;
  final String content;
  final String linkUrl;
  final String refMonth;

  const Shome06({
    this.stockCode = '',
    this.stockName = '',
    this.updateDate = '',
    this.title = '',
    this.content = '',
    this.linkUrl='',
    this.refMonth=''
  });

  factory Shome06.fromJson(Map<String, dynamic> json) {
    return Shome06(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      updateDate: json['updateDate'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      refMonth: json['refMonth'] ?? '',
    );
  }
}