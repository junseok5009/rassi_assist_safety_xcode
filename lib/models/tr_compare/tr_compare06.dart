import '../stock_52.dart';


/// [종목비교] TR_COMPARE06 _ 파싱 클래스
class TrCompare06 {
  final String retCode;
  final String retMsg;
  final Compare06 retData;

  TrCompare06({this.retCode = '', this.retMsg = '', this.retData = defCompare06});

  factory TrCompare06.fromJson(Map<String, dynamic> json) {
    return TrCompare06(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defCompare06 : Compare06.fromJson(json['retData']),
    );
  }
}

const defCompare06 = Compare06();

class Compare06 {
  final String baseDate;
  final List<Stock52> listStock52;

  const Compare06({this.baseDate = '', this.listStock52 = const []});

  factory Compare06.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<Stock52>? rtList;
    if(list != null) rtList = list.map((i) => Stock52.fromJson(i)).toList();

    return Compare06(
      baseDate: json['baseDate'],
      listStock52: list.map((i) => Stock52.fromJson(i)).toList(),
    );
  }
}
