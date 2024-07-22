import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';

import '../none_tr/chart_data.dart';


/// 2020.11.19
/// 이슈 상세 조회
/// 24.07.19 마켓뷰 개편
class TrIssue04 {
  final String retCode;
  final String retMsg;
  Issue04 retData;

  TrIssue04({this.retCode = '', this.retMsg = '', Issue04? retData})
      : retData = retData ?? Issue04();

  factory TrIssue04.fromJson(Map<String, dynamic> json) {
    var jsonData = json['retData'];
    return TrIssue04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonData == null ? Issue04() :Issue04.fromJson(json['retData']),
    );
  }
}

class Issue04 {
  final IssueInfo issueInfo;
  final List<StockStatus> stkList;
  List<IssueTrend> listIssueTrend;
  List<TopStock> listTopStock;

  Issue04({this.issueInfo = const IssueInfo(), this.stkList = const [], this.listIssueTrend = const [], this.listTopStock = const [],});

  factory Issue04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    var jsonIssueStruct = json['struct_Issue'];
    var jsonListIssueTrend = json['list_IssueTrend'];
    var jsonListTopStock = json['list_TopStock'];
    return Issue04(
      issueInfo: jsonIssueStruct == null ? const IssueInfo() : IssueInfo.fromJson(jsonIssueStruct),
      stkList: jsonList == null ? [] : (jsonList as List).map((i) => StockStatus.fromJson(i)).toList(),
      listIssueTrend: jsonListIssueTrend == null ? [] : (jsonListIssueTrend as List).map((i) => IssueTrend.fromJson(i)).toList(),
      listTopStock: jsonListTopStock == null ? [] : (jsonListTopStock as List).map((i) => TopStock.fromJson(i)).toList(),
    );
  }

}

class IssueInfo {
  final String newsSn;
  final String issueDttm;
  final String title;
  final String content;
  final String issueSn;
  final String keyword;
  final String imageUrl;

  const IssueInfo({
    this.newsSn = '',
    this.issueDttm = '',
    this.title = '',
    this.content = '',
    this.issueSn = '',
    this.keyword = '',
    this.imageUrl = ''
  });

  factory IssueInfo.fromJson(Map<String, dynamic> json) {
    return IssueInfo(
      newsSn: json['newsSn'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  @override
  String toString() {
    return '$title|$newsSn|$keyword';
  }
}

class IssueTrend {
  final String issueDate;
  final String issueSn;
  final String keyword;
  final String searchTrend;

  const IssueTrend({
    this.issueDate = '',
    this.issueSn = '',
    this.keyword = '',
    this.searchTrend = '',
  });

  factory IssueTrend.fromJson(Map<String, dynamic> json) {
    return IssueTrend(
      issueDate: json['issueDate'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      searchTrend: json['searchTrend'] ?? '',
    );
  }
}

class TopStock {
  final String sc;
  final String sn;
  List<ChartData> listChart;

  TopStock({
    this.sc = '',
    this.sn = '',
    this.listChart = const [],
  });

  factory TopStock.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Chart'];
    return TopStock(
      sc: json['sc'] ?? '',
      sn: json['sn'] ?? '',
      listChart: jsonList == null ? [] : (jsonList as List).map((e) => ChartData.fromJson(e),).toList(),
    );
  }
}