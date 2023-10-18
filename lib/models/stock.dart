
/// 공통 주식 데이터
class Stock {
  final String stockCode;
  final String stockName;

  const Stock({this.stockCode = '', this.stockName = ''});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName';
  }
}

