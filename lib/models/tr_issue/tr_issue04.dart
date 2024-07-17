import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';


/// 2020.11.19
/// 이슈 상세 조회
class TrIssue04 {
  final String retCode;
  final String retMsg;
  final Issue04 retData;

  TrIssue04({this.retCode = '', this.retMsg = '', this.retData = const Issue04()});

  factory TrIssue04.fromJson(Map<String, dynamic> json) {
    var jsonData = json['retData'];
    return TrIssue04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonData == null ? const Issue04() :Issue04.fromJson(json['retData']),
    );
  }
}

class Issue04 {
  final IssueInfo issueInfo;
  final List<StockStatus> stkList;

  const Issue04({this.issueInfo = const IssueInfo(), this.stkList = const []});

  factory Issue04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    var jsonIssueStruct = json['struct_Issue'];
    return Issue04(
      issueInfo: jsonIssueStruct == null ? const IssueInfo() : IssueInfo.fromJson(jsonIssueStruct),
      stkList: jsonList == null ? [] : (jsonList as List).map((i) => StockStatus.fromJson(i)).toList(),
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
