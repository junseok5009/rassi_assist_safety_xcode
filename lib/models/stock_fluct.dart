/// [종목비교] TR_COMPARE05 _ STOCK 클래스
class StockFluct {
  final String stockCode;
  final String stockName;
  final String fluctWeek1;
  final String fluctMonth1;
  final String fluctMonth3;
  final String fluctMonth6;
  final String fluctYear1;

  StockFluct({
    this.stockCode = '', this.stockName = '',
    this.fluctWeek1 = '', this.fluctMonth1 = '',
    this.fluctMonth3 = '', this.fluctMonth6 = '',
    this.fluctYear1 = '',
  });

  factory StockFluct.fromJson(Map<String, dynamic> json) {
    return StockFluct(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      fluctWeek1: json['fluctWeek1'] ?? '',
      fluctMonth1: json['fluctMonth1'] ?? '',
      fluctMonth3: json['fluctMonth3'] ?? '',
      fluctMonth6: json['fluctMonth6'] ?? '',
      fluctYear1: json['fluctYear1'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$fluctWeek1|$fluctMonth1|$fluctMonth3|$fluctMonth6|$fluctYear1';
  }
}

