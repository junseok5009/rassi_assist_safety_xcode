import 'package:flutter/material.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';


/// 2021.02.22
/// 월별(날짜별) 이슈 현황
class TrIssue02 {
  final String retCode;
  final String retMsg;
  List<IssueList> listData;

  TrIssue02({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
/*    List<IssueList>? rtList;
    if(list == null) {
      rtList = null;
    } else {
      rtList  = list.map((i) => IssueList.fromJson(i)).toList();
    }*/

    return TrIssue02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => IssueList.fromJson(i)).toList(),
    );
  }
}


class IssueList {
  final String issueDate;
  List<Issue02> listIssue;

  IssueList({this.issueDate = '', this.listIssue = const []});

  factory IssueList.fromJson(Map<String, dynamic> json) {
    var list = json['list_Issue'] as List;

    return IssueList(
      issueDate: json['issueDate'],
      listIssue: list.map((i) => Issue02.fromJson(i)).toList(),
    );
  }
}


class Issue02 {
  final String newsSn;
  final String issueDate;
  final String issueSn;
  final String keyword;

  Issue02({
    this.newsSn = '',
    this.issueDate = '',
    this.issueSn = '',
    this.keyword = '',
  });

  factory Issue02.fromJson(Map<String, dynamic> json) {
    return Issue02(
      newsSn: json['newsSn'],
      issueDate: json['issueDate'],
      issueSn: json['issueSn'],
      keyword: json['keyword'],
    );
  }
}


//화면구성
class TileChip2 extends StatelessWidget {
  final Issue02 item;
  final Color bColor;

  TileChip2(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        label: Text(item.keyword),
        backgroundColor: bColor,
      ),
      onTap: (){
        //TODO @@@@@
/*        Navigator.of(context).push(UIStyle.createRoute(
            IssueViewer(),
            PgData(userId: '', pgSn: item.newsSn))
        );*/
      },
    );
  }
}
