/// 2023.08.07 - JS
/// HOT 테마 및 테마별 강세, 주도주 조회
class TrTheme08 {
  final String retCode;
  final String retMsg;
  final List<Theme08> retData;

  TrTheme08({
    this.retCode='',
    this.retMsg='',
    this.retData = const [],
  });

  factory TrTheme08.fromJson(Map<String, dynamic> json) {
    return TrTheme08(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] == null ? [] : (json['retData'] as List).map((i) => Theme08.fromJson(i)).toList(),
    );
  }
}

class Theme08 {
  final String themeCode;
  final String themeName;
  final String increaseRate;
  final String themeStatus;
  final List<Theme08Item> listToday;  // 오늘 강세 종목 리스트
  final List<Theme08Item> listTrend;  // 주도주 종목 리스트

  Theme08({
    this.themeCode='',
    this.themeName='',
    this.increaseRate='',
    this.themeStatus='',
    this.listToday = const [],
    this.listTrend = const [],
  });

  factory Theme08.fromJson(Map<String, dynamic> json) {
    return Theme08(
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '0',
      themeStatus: json['themeStatus'] ?? '',
      listToday : json['list_Today'] == null ? [] : (json['list_Today'] as List).map((i) => Theme08Item.fromJson(i)).toList(),
      listTrend : json['list_Trend'] == null ? [] : (json['list_Trend'] as List).map((i) => Theme08Item.fromJson(i)).toList(),
    );
  }
}

class Theme08Item {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationAmt;
  final String fluctuationRate;

  Theme08Item({this.stockCode='', this.stockName='',
    this.currentPrice='', this.fluctuationAmt='', this.fluctuationRate='',
  });

  factory Theme08Item.fromJson(Map<String, dynamic> json) {
    return Theme08Item(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      currentPrice: json['currentPrice'] ?? '0',
      fluctuationAmt: json['fluctuationAmt'] ?? '0',
      fluctuationRate: json['fluctuationRate'] ?? '0',
    );
  }
}
