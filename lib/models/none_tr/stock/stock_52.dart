/// [종목비교] 차트 데이터 - 변동성 - 52주 ~~~

class Stock52 {
  final String stockCode;
  final String stockName;
  final String top52Date;
  final String top52Price;
  final String top52FluctRate;
  final String low52Date;
  final String low52Price;
  final String low52FluctRate;

  Stock52({
    this.stockCode = '',
    this.stockName = '',
    this.top52Date = '',
    this.top52Price = '',
    this.top52FluctRate = '',
    this.low52Date = '',
    this.low52Price = '',
    this.low52FluctRate = '',
  });

  factory Stock52.fromJson(Map<String, dynamic> json) {
    return Stock52(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      top52Date: json['top52Date'] ?? '',
      top52Price: json['top52Price'] ?? '',
      top52FluctRate: json['top52FluctRate'] ?? '',
      low52Date: json['low52Date'] ?? '',
      low52Price: json['low52Price'] ?? '',
      low52FluctRate: json['low52FluctRate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$top52Date|$top52Price|$top52FluctRate|$low52Date|$low52Price|$low52FluctRate';
  }
}
