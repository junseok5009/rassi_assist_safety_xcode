import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';

/// 2020.09.02
/// 오늘의 이슈
class TrIssue03 {
  final String retCode;
  final String retMsg;
  final List<Issue03> listData;

  TrIssue03({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData']['list_Issue'];
    return TrIssue03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Issue03.fromJson(i)).toList(),
    );
  }
}

class Issue03 {
  final String newsSn;
  final String issueDttm;
  final String issueSn;
  final String keyword;
  final String title;
  final String content;
  final String stockCode;
  final String stockName;
  final List<Stock> listStock;
  String avgFluctRate;
  final String issueStatus;

  Issue03({
    this.newsSn = '',
    this.issueDttm = '',
    this.issueSn = '',
    this.keyword = '',
    this.title = '',
    this.content = '',
    this.stockCode = '',
    this.stockName = '',
    this.avgFluctRate = '',
    this.listStock = const [],
    this.issueStatus = '',
  });

  factory Issue03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    return Issue03(
      newsSn: json['newsSn'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      avgFluctRate: json['avgFluctRate'] ?? '0',
      listStock: jsonList == null ? [] : (jsonList as List).map((e) => Stock.fromJson(e)).toList(),
      issueStatus: json['issueStatus'] ?? '',
    );
  }
}

class Issue03TodayHeadWidget extends StatelessWidget {
  const Issue03TodayHeadWidget({required this.issue03, required this.isShowFluctRate, super.key});
  final bool isShowFluctRate;
  final Issue03 issue03;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 46),
      child: Ink(
        width: double.infinity,
        decoration: UIStyle.boxShadowColor(16, RColor.greyBox_f5f5f5),
        //padding: const EdgeInsets.all(15),
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              IssueNewViewer.routeName,
              arguments: PgData(
                pgSn: issue03.newsSn,
                pgData: issue03.issueSn,
                data: issue03.keyword,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      issue03.keyword,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Visibility(
                      visible: isShowFluctRate,
                      child: Text(
                        TStyle.getPercentString(issue03.avgFluctRate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: TStyle.getMinusPlusColor(issue03.avgFluctRate),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      issue03.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 20,
                  child: ListView.builder(
                    itemCount: issue03.listStock.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            basePageState.goStockHomePage(
                              issue03.listStock[index].stockCode,
                              issue03.listStock[index].stockName,
                              0,
                            );
                          },
                          child: Text(
                            issue03.listStock[index].stockName,
                            style: const TextStyle(
                              color: RColor.mainColor,
                            ),
                          )),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
