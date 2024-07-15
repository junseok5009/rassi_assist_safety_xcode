import 'package:rassi_assist/models/tr_issue/tr_issue02.dart';

/// 2024.07
/// 지정월의 일별 이슈 키워드 조회 (기존 Issue02는 호환성을 위해 그대로 두고)
class TrIssue02n {
  final String retCode;
  final String retMsg;
  final Issue02n retData;

  TrIssue02n({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defIssue02,
  });

  factory TrIssue02n.fromJson(Map<String, dynamic> json) {
    return TrIssue02n(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defIssue02 : Issue02n.fromJson(json['retData']),
    );
  }
}

const defIssue02 = Issue02n();

class Issue02n {
  final String issueSn;
  final String riseDays;
  final String fallDays;
  final String issueDays;
  final List<IssueDaily> listDaily;

  const Issue02n({
    this.issueSn = '',
    this.riseDays = '0',
    this.fallDays = '0',
    this.issueDays = '0',
    this.listDaily = const [],
  });

  factory Issue02n.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_DailyIssue'];
    return Issue02n(
      issueSn: json['issueSn'],
      riseDays: json['riseDays'] ?? '0',
      fallDays: json['fallDays'] ?? '0',
      issueDays: json['issueDays'] ?? '0',
      listDaily: jsonList == null ? [] : (jsonList as List).map((i) => IssueDaily.fromJson(i)).toList(),
    );
  }
}

//데일리 리스트
class IssueDaily {
  final String issueDate;
  final String issueCount;
  final String avgFluctRate;
  final List<Issue02> listIssue;

  IssueDaily({
    this.issueDate = '',
    this.issueCount = '',
    this.avgFluctRate = '',
    this.listIssue = const [],
  });

  factory IssueDaily.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Issue'];
    return IssueDaily(
      issueDate: json['issueDate'],
      issueCount: json['issueCount'] ?? '0',
      avgFluctRate: json['avgFluctRate'] ?? '',
      listIssue: jsonList == null ? [] : (jsonList as List).map((i) => Issue02.fromJson(i)).toList(),
    );
  }
}
