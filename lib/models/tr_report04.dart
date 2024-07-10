import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/stock_home/page/recent_report_detail_page.dart';

import '../common/tstyle.dart';

class TrReport04 {
  final String retCode;
  final String retMsg;
  final Report04 retData;

  TrReport04({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defReport04
  });

  factory TrReport04.fromJson(Map<String, dynamic> json) {
    return TrReport04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] == null ? defReport04 : Report04.fromJson(json['retData']),
    );
  }
}


const defReport04 = Report04();

class Report04 {
  final String totalPageSize;
  final String currentPageNo;
  final List<Report04Report> listReport; // 증권사별 발행 리스트

  const Report04({
    this.totalPageSize = '',
    this.currentPageNo = '',
    this.listReport = const [],
  });

  factory Report04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Report'];
    return Report04(
      totalPageSize: json['totalPageSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listReport: jsonList == null ? [] : (jsonList as List).map((i) => Report04Report.fromJson(i)).toList(),
    );
  }
}

class Report04Report {
  final String stockCode;
  final String stockName;
  final String issueDate; // 발행 일자
  final String organName; // 리포트 발행 증권사
  final String opinion; // 매수/매도 의견
  final String goalPrice; // 목표 주가
  final String title; // 제목
  final String content; // 리포트 내용

  Report04Report({
    this.stockCode = '',
    this.stockName = '',
    this.issueDate = '',
    this.organName = '',
    this.opinion = '',
    this.goalPrice = '',
    this.title = '',
    this.content = '',
  });

  bool isEmpty() {
    return [stockCode, stockName, issueDate, title, content].contains(null);
  }

  factory Report04Report.fromJson(
    Map<String, dynamic> json,
  ) {
    return Report04Report(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      issueDate: json['issueDate'] ?? '',
      organName: json['organName'] ?? '',
      opinion: json['opinion'] ?? '',
      goalPrice: json['goalPrice'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class TileReport04ListItemView extends StatelessWidget {
  //const TileReport04ListItemView({Key? key}) : super(key: key);
  const TileReport04ListItemView(this.item, {super.key});

  final Report04Report item;

  @override
  Widget build(BuildContext context) {
    return item.isEmpty()
        ? Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Image.asset(
              'images/gif_ios_loading_large.gif',
              height: 20,
            ),
          )
        : Align(
            //width: double.infinity,
            alignment: Alignment.centerLeft,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: RColor.btnUnSelectGreyStroke,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          TStyle.getDateSlashFormat1(item.issueDate),
                          style: TStyle.newBasicGreyS15,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          item.stockName,
                          style: TStyle.commonTitle15,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      item.title,
                      style: TStyle.content15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              onTap: () {
                basePageState.callPageRouteUP(
                  RecentReportDetailPage(item),
                );
              },
            ),
          );
  }
}
