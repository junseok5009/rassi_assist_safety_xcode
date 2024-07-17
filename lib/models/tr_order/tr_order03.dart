
/// 2020.12.08
/// 캐시 내역
class TrOrder03 {
  final String retCode;
  final String retMsg;
  final List<Order03>? listData;

  TrOrder03({this.retCode = '', this.retMsg = '', this.listData});

  factory TrOrder03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Order03> rtList = list.map((i) => Order03.fromJson(i)).toList();

    return TrOrder03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class Order03 {
  final String title;
  final String stockCode;
  final String stockName;
  final String tradeDate;
  final String tradeTime;

  Order03({this.title = '', this.stockCode = '', this.stockName = '', this.tradeDate = '', this.tradeTime = ''});

  factory Order03.fromJson(Map<String, dynamic> json) {
    return Order03(
        title: json['title'],
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        tradeDate: json['tradeDate'],
        tradeTime: json['tradeTime']
    );
  }
}
