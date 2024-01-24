import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';


/// 2020.09.02
/// 오늘의 이슈
class TrIssue03 {
  final String retCode;
  final String retMsg;
  final List<Issue03> listData;

  TrIssue03({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrIssue03.fromJson(Map<String, dynamic> json) {
    // var retData = json['retData'];
    // String strData = "$retData";
    // print(retData);
    var list = json['retData']['list_Issue'] as List;
    List<Issue03> rtList = list.map((i) => Issue03.fromJson(i)).toList();
    return TrIssue03(
        retCode: json['retCode'], retMsg: json['retMsg'], listData: rtList);
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
  final String avgFluctRate;
  final String issueStatus;

  Issue03({
    this.newsSn='',
    this.issueDttm='',
    this.issueSn='',
    this.keyword='',
    this.title='',
    this.content='',
    this.stockCode='',
    this.stockName='',
    this.avgFluctRate='',
    this.listStock = const [],
    this.issueStatus='',
  });

  factory Issue03.fromJson(Map<String, dynamic> json) {
    var listStock = json['list_Stock'] as List;
    List<Stock> stkList =
        listStock?.map((e) => Stock.fromJson(e))?.toList() ?? [];
    return Issue03(
      newsSn: json['newsSn'],
      issueDttm: json['issueDttm'],
      issueSn: json['issueSn'],
      keyword: json['keyword'],
      title: json['title'],
      content: json['content'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      avgFluctRate: json['avgFluctRate'] ?? '0',
      listStock: stkList,
      issueStatus: json['issueStatus'],
    );
  }
}

//화면구성
class TileIssue03 extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Issue03 item;
  final Color bColor;
  final Color tbColor;

  TileIssue03(this.item, this.bColor, this.tbColor);

  @override
  Widget build(BuildContext context) {
    int listLen;
    item.listStock.length > 3 ? listLen = 4 : listLen = item.listStock.length;

    return InkWell(
      // splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: 265,
        // height: 170,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: bColor,
            borderRadius: BorderRadius.all(const Radius.circular(17.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topDesc(),
            _bottomItem(context, listLen),
          ],
        ),
      ),
      onTap: () {
        basePageState.callPageRouteUpData(IssueViewer(),
            PgData(userId: '', pgSn: item.newsSn, pgData: item.issueSn));
      },
    );
  }

  Widget _topDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.keyword,
          style: TStyle.subTitle,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          item.title,
          style: TStyle.btnTextWht16,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          item.content,
          style: TStyle.btnSTextWht,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  //관련 부분
  Widget _bottomItem(BuildContext context, int len) {
    return Wrap(
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
          len, (index) => _relayStock(context, item.listStock[index])),
    );
  }

  //관련 종목
  Widget _relayStock(BuildContext context, Stock one) {
    int strLen;
    one.stockName.length > 5 ? strLen = 6 : strLen = one.stockName.length;
    return InkWell(
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: tbColor,
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Center(
          child: Text(
            one.stockName.substring(0, strLen),
            style: TStyle.btnTextWht15,
          ),
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          one.stockCode,
          one.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }
}

//화면구성
class TileChip extends StatelessWidget {
  final Issue03 item;
  final Color bColor;

  TileChip(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(
          item.keyword,
          style: TStyle.content15,
        ),
        backgroundColor: bColor,
      ),
      onTap: () {
        Navigator.of(context)
            .push(_createRoute(PgData(userId: '', pgSn: item.newsSn)));
      },
    );
  }
}

Route _createRoute(PgData pgData) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => IssueViewer(),
    settings: RouteSettings(arguments: pgData),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
