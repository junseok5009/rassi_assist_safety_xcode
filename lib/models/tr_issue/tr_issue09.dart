import 'package:rassi_assist/models/tr_issue/tr_issue03.dart';

class TrIssue09 {
  final String retCode;
  final String retMsg;
  final Issue09 retData;

  TrIssue09({this.retCode = '', this.retMsg = '', this.retData = const Issue09(issueDate: '', listData: [])});

  factory TrIssue09.fromJson(Map<String, dynamic> json) {
    var jsonData = json['retData'];
    return TrIssue09(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonData == null ? const Issue09() : Issue09.fromJson(jsonData),
    );
  }
}

class Issue09 {
  final String issueDate;
  final List<Issue09TimeLapse> listData;
  const Issue09({this.issueDate = '', this.listData = const []});
  factory Issue09.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_TimeLapse'];
    return Issue09(
      issueDate: json['issueDate'],
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Issue09TimeLapse.fromJson(i)).toList(),
    );
  }
}

class Issue09TimeLapse {
  final String timeLapse;
  final String lastDataYn;
  final List<Issue03> listData;
  Issue09TimeLapse({this.timeLapse = '', this.lastDataYn = 'N', this.listData = const []});
  factory Issue09TimeLapse.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Issue'];
    return Issue09TimeLapse(
      timeLapse: json['timeLapse'],
      lastDataYn: json['lastDataYn'] ?? 'N',
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Issue03.fromJson(i)).toList(),
    );
  }
}

