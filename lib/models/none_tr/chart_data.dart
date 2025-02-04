/// 차트 데이터
class ChartData {
  final String tradeDate;
  final String tradePrc;
  final String flag;
  final String fr;
  final DateTime dateTime;

  ChartData({this.tradeDate = '', this.tradePrc = '', this.flag = '', this.fr = '',required DateTime vDateTime}) : dateTime = vDateTime;

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      tradeDate: json['td'],
      tradePrc: json['tp'],
      flag: json['tf'] ?? '',
      fr: json['fr'] ?? '',
      vDateTime: json['td'] == null ? DateTime.now() : DateTime.parse(json['td']),
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