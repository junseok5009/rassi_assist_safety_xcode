
/// 우선 종목홈에서 공유하며 사용될 데이터
class StockData {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String fluctuationAmt;

  StockData({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$fluctuationAmt';
  }
}

