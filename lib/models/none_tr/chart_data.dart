

import 'package:intl/intl.dart';

/// 차트 데이터
class ChartData {
  final String tradeDate;
  final String tradePrc;
  final String flag;
  final DateTime dateTime;

  ChartData({this.tradeDate = '', this.tradePrc = '', this.flag = '', required DateTime vDateTime}) : dateTime = vDateTime;

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      tradeDate: json['td'],
      tradePrc: json['tp'],
      flag: json['tf'] ?? '',
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