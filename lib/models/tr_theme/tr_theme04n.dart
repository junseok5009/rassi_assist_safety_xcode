import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/tr_atom.dart';


/// 2022.05.12
/// 테마 상세 조회 New
class TrTheme04N extends TrAtom {
  final Theme04N retData;

  TrTheme04N({
    String retCode = '',
    String retMsg = '',
    this.retData = defTheme04N,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme04N.fromJson(Map<String, dynamic> json) {
    return TrTheme04N(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Theme04N.fromJson(json['retData']),
    );
  }
}


const defTheme04N = Theme04N();

class Theme04N {
  final ThemeStu themeObj;
  final String periodMonth;
  final List<ChartTheme> listChart;

  const Theme04N({
    this.themeObj = defThemeStu,
    this.periodMonth = '',
    this.listChart = const [],
  });

  factory Theme04N.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<ChartTheme>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => ChartTheme.fromJson(i)).toList();

    return Theme04N(
      themeObj: ThemeStu.fromJson(json['struct_Theme']),
      periodMonth: json['periodMonth'] ?? '',
      listChart: list.map((i) => ChartTheme.fromJson(i)).toList(),
    );
  }
}


const defThemeStu = ThemeStu();

/// Theme struct
class ThemeStu {
  final String tradeDate;
  final String themeCode;
  final String themeName;
  final String themeDesc;

  final String themeIndex;
  final String increaseRate;
  final String themeStatus;
  final String elapsedDays;

  const ThemeStu({
    this.tradeDate = '', this.themeCode = '',
    this.themeName = '', this.themeDesc = '',
    this.themeIndex = '', this.increaseRate = '',
    this.themeStatus = '', this.elapsedDays = ''
  });

  factory ThemeStu.fromJson(Map<String, dynamic> json) {
    return ThemeStu(
      tradeDate: json['tradeDate'] ?? '',
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      themeDesc: json['themeDesc'] ?? '',

      themeIndex: json['themeIndex'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      themeStatus: json['themeStatus'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tradeDate| $themeCode| $themeName';
  }
}


