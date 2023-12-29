/// 테마 차트 데이터
class ChartTheme {
  final String tradeDate;
  final String tradeIndex;
  final String flag;
  final String isPeak;

  ChartTheme({this.tradeDate = '', this.tradeIndex = '', this.flag = '', this.isPeak = ''});

  factory ChartTheme.fromJson(Map<String, dynamic> json) {
    return ChartTheme(
      tradeDate: json['td'] ?? '',
      tradeIndex: json['ti'] ?? '',
      flag: json['fr'] ?? '',
      isPeak: json['isPeak'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tradeDate| $tradeIndex| $flag';
  }
}
