import 'package:rassi_assist/models/none_tr/stock/stock.dart';

/// 2021.03.18
/// 지정 종목의 최근 이슈
class TrIssue06 {
  final String retCode;
  final String retMsg;
  final List<Issue06> listData;

  TrIssue06({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue06.fromJson(Map<String, dynamic> json) {
    var jsonData = json['retData'];
    var jsonList = json['retData']['list_Issue'];
    return TrIssue06(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: jsonData == null || jsonList == null ? [] : (jsonList as List).map((i) => Issue06.fromJson(i)).toList(),
    );
  }
}

class Issue06 {
  final String newsSn;
  final String issueDttm;
  final String title;
  final String issueSn;
  final String keyword;
  final String imageUrl;
  final List<Stock> stkList;

  Issue06({
    this.newsSn = '',
    this.issueDttm = '',
    this.title = '',
    this.issueSn = '',
    this.keyword = '',
    this.imageUrl = '',
    this.stkList = const [],
  });

  factory Issue06.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    return Issue06(
      newsSn: json['newsSn'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      title: json['title'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      stkList: jsonList == null ? <Stock>[] : (jsonList as List).map((i) => Stock.fromJson(i)).toList(),
    );
  }
}
