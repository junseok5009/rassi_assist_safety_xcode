import 'package:rassi_assist/models/stock.dart';


/// 2021.04.05
/// 키워드 관련 종목
class TrKWord02 {
  final String retCode;
  final String retMsg;
  final KWord02 retData;

  TrKWord02({this.retCode = '', this.retMsg = '', this.retData = defKWord02});

  factory TrKWord02.fromJson(Map<String, dynamic> json) {
    return TrKWord02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? defKWord02 : KWord02.fromJson(json['retData'])
    );
  }
}

const defKWord02 = KWord02();

class KWord02 {
  final String keyword;
  final List<Stock> listData;

  const KWord02({this.keyword = '', this.listData = const []});

  factory KWord02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    return KWord02(
      keyword: json['keyword'],
      listData: list == null ? <Stock>[] : list.map((e) => Stock.fromJson(e)).toList(),
    );
  }
}

