import 'package:rassi_assist/models/rassiro.dart';


/// 2020.12.24
/// 라씨로 태그별 뉴스 리스트 조회
class TrRassi06 {
  final String retCode;
  final String retMsg;
  final List<Rassiro> listData;

  TrRassi06({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi06.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Rassiro'] as List;
    List<Rassiro> rtList = list.map((i) => Rassiro.fromJson(i)).toList();

    return TrRassi06(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}

