
/// 2021.12.09 - JY
/// 이용중인 상품리스트 조회
// ()
class TrOrder04 {
  final String retCode;
  final String retMsg;
  final List<Order04>? listData;

  TrOrder04({this.retCode = '', this.retMsg = '', this.listData});

  factory TrOrder04.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Order04> rtList = list.map((i) => Order04.fromJson(i)).toList();

    return TrOrder04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class Order04 {
  final String title;
  final String stockCode;
  final String stockName;
  final String tradeDate;
  final String tradeTime;

  Order04({this.title = '', this.stockCode = '',
    this.stockName = '', this.tradeDate = '', this.tradeTime = ''});

  factory Order04.fromJson(Map<String, dynamic> json) {
    return Order04(
        title: json['title'],
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        tradeDate: json['tradeDate'],
        tradeTime: json['tradeTime']
    );
  }
}
