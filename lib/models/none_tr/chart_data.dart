

/// 차트 데이터
class ChartData {
  final String tradeDate;
  final String tradePrc;
  final String flag;

  ChartData({this.tradeDate = '', this.tradePrc = '', this.flag = ''});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      tradeDate: json['td'],
      tradePrc: json['tp'],
      flag: json['tf'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tradeDate|$tradePrc|$flag';
  }

  Map<String, Object> toJson() {
    return {
      'td': tradeDate,
      'tp': tradePrc,
    };
  }


}