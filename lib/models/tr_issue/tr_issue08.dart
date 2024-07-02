import 'package:rassi_assist/models/tr_issue/tr_issue02.dart';

class TrIssue08 {
  final String retCode;
  final String retMsg;
  final List<Issue08> listData;

  TrIssue08({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue08.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrIssue08(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: jsonList == null ? [] : (jsonList as List).map((i) => Issue08.fromJson(i)).toList(),
    );
  }
}

class Issue08 {
  final String issueDate;
  final String weekday;
  final String issueCount;
  final List<Issue02> listData;
  Issue08({this.issueDate = '', this.weekday = '', this.issueCount = '0', this.listData = const []});
  factory Issue08.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Issue'];
    return Issue08(
      issueDate: json['issueDate'],
      weekday: json['weekday'],
      issueCount: json['issueCount'] ?? '0',
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Issue02.fromJson(i)).toList(),
    );
  }
}


