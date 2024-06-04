import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/tr_atom.dart';


/// 2022.05.12
/// 테마 상세 조회
class TrTheme04 extends TrAtom {
  final Theme04 retData;

  TrTheme04({
    String retCode = '',
    String retMsg = '',
    this.retData = defTheme04N,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme04.fromJson(Map<String, dynamic> json) {
    return TrTheme04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Theme04.fromJson(json['retData']),
    );
  }
}


const defTheme04N = Theme04();

class Theme04 {
  final ThemeStu themeObj;
  final String periodMonth;
  final String periodFluctRate; // 24.05.30 기간 누적 변동률
  final List<ChartTheme> listChart;

  const Theme04({
    this.themeObj = const ThemeStu(),
    this.periodMonth = '',
    this.periodFluctRate = '',
    this.listChart = const [],
  });

  factory Theme04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Chart'];
    return Theme04(
      themeObj: json['struct_Theme'] == null ? const ThemeStu() : ThemeStu.fromJson(json['struct_Theme']),
      periodMonth: json['periodMonth'] ?? '',
      periodFluctRate: json['periodFluctRate'] ?? '',
      listChart: jsonList == null ? [] : (jsonList as List).map((i) => ChartTheme.fromJson(i)).toList(),
    );
  }
}

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


