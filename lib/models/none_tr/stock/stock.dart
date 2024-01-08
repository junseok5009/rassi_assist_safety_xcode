/// 공통 주식 데이터
class Stock {
  final String stockCode;
  final String stockName;
  bool isDelete = false;

  Stock({
    this.stockCode = '',
    this.stockName = '',
  });

  Stock.change({
    required this.stockCode,
    required this.stockName,
    required this.isDelete,
  });

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

