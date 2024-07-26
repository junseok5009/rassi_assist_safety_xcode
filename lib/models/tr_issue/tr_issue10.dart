import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';

/// 2024.07
/// 지정월의 신규 발생 이슈
class TrIssue10 {
  final String retCode;
  final String retMsg;
  final Issue10? retData;

  TrIssue10({this.retCode = '', this.retMsg = '', this.retData});

  factory TrIssue10.fromJson(Map<String, dynamic> json) {
    return TrIssue10(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Issue10.fromJson(json['retData']),
    );
  }
}

class Issue10 {
  final String issueCount;
  final List<NewIssue> issueList;

  Issue10({this.issueCount = '', this.issueList = const []});

  factory Issue10.fromJson(Map<String, dynamic> json) {
    var list = json['list_Issue'] == null ? [] : (json['list_Issue'] as List);
    List<NewIssue> rtList = list.map((i) => NewIssue.fromJson(i)).toList();

    return Issue10(
      issueCount: json['issueCount'] ?? '',
      issueList: rtList,
    );
  }
}

class NewIssue {
  final String newsSn;
  final String issueDate;
  final String issueSn;
  final String keyword;
  final String title;
  final String issueStatus;
  final String avgFluctRate;
  final List<Stock> stockList;

  NewIssue({
    this.newsSn = '',
    this.issueDate = '',
    this.issueSn = '',
    this.keyword = '',
    this.title = '',
    this.issueStatus = '',
    this.avgFluctRate = '',
    this.stockList = const [],
  });

  factory NewIssue.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] == null ? [] : (json['list_Stock'] as List);
    List<Stock> rtList = list.map((i) => Stock.fromJson(i)).toList();
    return NewIssue(
      newsSn: json['newsSn'] ?? '',
      issueDate: json['issueDate'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      title: json['title'] ?? '',
      issueStatus: json['issueStatus'] ?? '',
      avgFluctRate: json['avgFluctRate'] ?? '',
      stockList: rtList,
    );
  }

  @override
  String toString() {
    return '$keyword | $avgFluctRate';
  }
}

//
class TileNewIssue extends StatelessWidget {
  final NewIssue item;

  const TileNewIssue(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxWithOpacity16(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.keyword,
              style: TStyle.defaultTitle,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
              child: Text(
                item.title,
                style: TStyle.defaultContent,
              ),
            ),
            const SizedBox(height: 10),
            _setStockList(context, item.stockList),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          IssueNewViewer.routeName,
          arguments: PgData(
            pgSn: item.newsSn,
            pgData: item.issueSn,
            data: item.keyword,
          ),
        );
      },
    );
  }

  Widget _setStockList(BuildContext context, List<Stock> listStk) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        alignment: WrapAlignment.start,
        children: List.generate(
          listStk.length,
              (index) => InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              // decoration: UIStyle.boxRoundFullColor25c(RColor.bgWeakGrey),
              child: Text(
                TStyle.getLimitString(listStk[index].stockName, 7),
                style: TStyle.content14n,
              ),
            ),
            onTap: () {
              //종목홈으로 이동
              basePageState.goStockHomePage(
                listStk[index].stockCode,
                listStk[index].stockName,
                Const.STK_INDEX_HOME,
              );
            },
          ),
        ),
      ),
    );
  }
}
