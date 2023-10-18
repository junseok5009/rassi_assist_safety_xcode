import 'package:rassi_assist/models/stock_group.dart';


/// [종목비교] TR_COMPARE01 _ 파싱 클래스
class TrCompare01 {
  final String retCode;
  final String retMsg;
  final Compare01 retData;

  TrCompare01({this.retCode = '', this.retMsg = '', this.retData = defCompare01});

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
    var list = json['list_StockGroup'] as List;
    List<StockGroup>? rtList;
    if(list != null) rtList = list.map((i) => StockGroup.fromJson(i)).toList();

    return Compare01(
      listData: list.map((i) => StockGroup.fromJson(i)).toList(),
    );
  }
}

