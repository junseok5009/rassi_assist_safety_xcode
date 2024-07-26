import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';

/// 2021.02.22
/// 월별(날짜별) 이슈 현황
class TrIssue02 {
  final String retCode;
  final String retMsg;
  List<IssueList> listData;

  TrIssue02({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue02.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrIssue02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: jsonList == null ? [] : (jsonList as List).map((i) => IssueList.fromJson(i)).toList(),
    );
  }
}

class IssueList {
  final String issueDate;
  final List<Issue02> listIssue;

  IssueList({this.issueDate='', this.listIssue = const []});

  factory IssueList.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Issue'];
    return IssueList(
      issueDate: json['issueDate'],
      listIssue: jsonList == null ? [] : (jsonList as List).map((i) => Issue02.fromJson(i)).toList(),
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
      issueDate: json['issueDate'] ?? '',
      issueSn: json['issueSn'],
      keyword: json['keyword'],
    );
  }
}

//화면구성
class TileChip2 extends StatelessWidget {
  final Issue02 item;
  final Color bColor;

  const TileChip2(this.item, this.bColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(item.keyword),
        backgroundColor: bColor,
      ),
      onTap: () {
        Navigator.pushNamed(context, IssueNewViewer.routeName, arguments: PgData(
          pgSn: item.newsSn,
          pgData: item.issueSn,
          data: item.keyword,
        ));
      },
    );
  }
}
