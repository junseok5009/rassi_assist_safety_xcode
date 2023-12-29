///
class StockBell {
  final String stockCode;
  final String stockName;
  final String regDttm;
  final String sbCateg;
  final String sbCategName;
  final String title;
  final String content;

  StockBell({
    this.stockCode = '',
    this.stockName = '',
    this.regDttm = '',
    this.sbCateg = '',
    this.sbCategName = '',
    this.title = '',
    this.content = '',
  });

  factory StockBell.fromJson(Map<String, dynamic> json) {
    return StockBell(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      regDttm: json['regDttm'],
      sbCateg: json['sbCateg'],
      sbCategName: json['sbCategName'],
      title: json['title'],
      content: json['content'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$regDttm';
  }
}
