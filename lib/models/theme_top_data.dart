
///테마 객체
class ThemeTopData {
  final String themeCode;
  final String themeName;
  final String increaseRate;
  final List<StockTopData> listStock;

  ThemeTopData({
    this.themeCode = '',
    this.themeName = '',
    this.increaseRate = '',
    this.listStock = const [],
  });

  factory ThemeTopData.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockTopData>? rtList;
    if (list != null) rtList = list.map((i) => StockTopData.fromJson(i)).toList();

    return ThemeTopData(
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      listStock: list.map((i) => StockTopData.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$themeCode|$themeName|$increaseRate';
  }
}

//주간 상승률이 추가된 StockData
class StockTopData {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String increaseRate; //주간 상승률

  StockTopData({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.increaseRate = '',
  });

  factory StockTopData.fromJson(Map<String, dynamic> json) {
    return StockTopData(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$increaseRate';
  }
}
