import 'package:rassi_assist/models/tr_search/tr_search01.dart';

class TrSearch08 {
  final String retCode;
  final String retMsg;
  final Search08 retData;

  TrSearch08({this.retCode='', this.retMsg='', this.retData = const Search08()});

  factory TrSearch08.fromJson(Map<String, dynamic> json) {
    return TrSearch08(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? const Search08() : Search08.fromJson(json['retData'])
    );
  }
}

class Search08 {
  final Search01 search01;
  final List<ChartData> listPriceChart;

  const Search08({this.search01 = const Search01(), this.listPriceChart = const [],});

  factory Search08.fromJson(Map<String, dynamic> json) {
    var list = json['list_PriceChart'] as List?;
    List<ChartData> listData = list == null ? [] : list.map((e) => ChartData.fromJson(e)).toList();
    return Search08(
        search01: Search01.fromJson(json['struct_Price']),
        listPriceChart: listData
    );
  }

}

class ChartData {
  final String td;  //날짜
  final String tt;  //시간
  final String tp;  //종가
  final String ec;  //이벤트

  ChartData({this.td='', this.tt='', this.tp='', this.ec='',});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
        td: json['td'] ?? '',
        tt: json['tt'] ?? '',
        tp: json['tp'] ?? '0',
        ec: json['ec'] ?? '0',
    );
  }

  @override
  String toString() {
    return '$td|$tt|$tp|$ec';
  }
}
