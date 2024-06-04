import 'package:rassi_assist/models/tr_atom.dart';

/// 2022.01.10
/// 테마 전체리스트 조회
class TrTheme01 extends TrAtom {
  final List<Theme01> listData;

  TrTheme01({
    String retCode = '',
    String retMsg = '',
    this.listData = const [],
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme01.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Theme'] as List;
    // List<Theme01>? rtList;
    // list == null ? rtList = null : rtList = list.map((i) => Theme01.fromJson(i)).toList();

    return TrTheme01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Theme01.fromJson(i)).toList(),
    );
  }
}

class Theme01 {
  final String themeCode;
  final String themeName;
  final String totalCount;
  final String buyCount;
  final String holdCount;
  final String sellCount;
  final String waitCount;
  final String increaseRate;

  Theme01({
    this.themeCode = '',
    this.themeName = '',
    this.totalCount = '',
    this.buyCount = '',
    this.holdCount = '',
    this.sellCount = '',
    this.waitCount = '',
    this.increaseRate = '',
  });

  factory Theme01.fromJson(Map<String, dynamic> json) {
    return Theme01(
      themeCode: json['themeCode'],
      themeName: json['themeName'],
      totalCount: json['totalCount'],
      buyCount: json['buyCount'],
      holdCount: json['holdCount'],
      sellCount: json['sellCount'],
      waitCount: json['waitCount'],
      increaseRate: json['increaseRate'],
    );
  }
}