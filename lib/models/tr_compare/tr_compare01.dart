import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';

/// [종목비교] TR_COMPARE01 _ 파싱 클래스
class TrCompare01 {
  final String retCode;
  final String retMsg;
  final Compare01 retData;

  TrCompare01({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defCompare01,
  });

  factory TrCompare01.fromJson(Map<String, dynamic> json) {
    return TrCompare01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare01 : Compare01.fromJson(json['retData']),
    );
  }
}

const defCompare01 = Compare01(listData: []);

class Compare01 {
  final List<StockGroup> listData;

  const Compare01({this.listData = const []});

  factory Compare01.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_StockGroup'];
    return Compare01(
      listData: jsonList == null ? [] : (jsonList as List).map((i) => StockGroup.fromJson(i)).toList(),
    );
  }
}
