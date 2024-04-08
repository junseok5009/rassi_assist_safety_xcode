import 'package:rassi_assist/models/none_tr/stock/stock.dart';

/// 종목 검색 (종목명 또는 종목코드로 검색)
class TrSearch02 {
  final String retCode;
  final String retMsg;
  final List<Stock>? retData;

  TrSearch02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSearch02.fromJson(Map<String, dynamic> json) {
    var jsonRetData = json['retData'];
    return TrSearch02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonRetData == null
          ? []
          : (jsonRetData as List).map((i) => Stock.fromJson(i)).toList(),
    );
  }
}
