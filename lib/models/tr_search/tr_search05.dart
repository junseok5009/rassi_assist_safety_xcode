import 'package:rassi_assist/models/stock.dart';


/// 2020.11.20
class TrSearch05 {
  final String retCode;
  final String retMsg;
  final List<Stock> listData;

  TrSearch05({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrSearch05.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Stock> rtList;
    list == null ? rtList = [] : rtList = list.map((i) => Stock.fromJson(i)).toList();

    return TrSearch05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}
