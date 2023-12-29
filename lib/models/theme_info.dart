import 'package:rassi_assist/models/none_tr/stock/stock.dart';


///테마 객체
class ThemeInfo {
  final String themeCode;
  final String themeName;
  final String increaseRate;
  final List<Stock> listStock;

  ThemeInfo({
    this.themeCode = '',
    this.themeName = '',
    this.increaseRate = '',
    this.listStock = const [],
  });

  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<Stock>? rtList;
    if(list != null) rtList = list.map((i) => Stock.fromJson(i)).toList();

    return ThemeInfo(
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      listStock: list.map((i) => Stock.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$themeCode|$themeName|$increaseRate';
  }
}
