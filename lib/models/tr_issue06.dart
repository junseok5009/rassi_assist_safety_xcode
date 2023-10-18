import 'package:flutter/material.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/stock.dart';


/// 2021.03.18
/// 지정 종목의 최근 이슈
class TrIssue06 {
  final String retCode;
  final String retMsg;
  final List<Issue06> listData;

  TrIssue06({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrIssue06.fromJson(Map<String, dynamic> json) {
    List<Issue06> rtList = [];
    if(json['retData'] != null) {
      var list = json['retData']['list_Issue'] as List;
      list == null ? rtList = [] : rtList = list.map((i) => Issue06.fromJson(i)).toList();
    }

    return TrIssue06(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class Issue06 {
  final String newsSn;
  final String issueDttm;
  final String title;
  final String issueSn;
  final String keyword;
  final String imageUrl;
  final List<Stock> stkList;

  Issue06({
    this.newsSn = '',
    this.issueDttm = '',
    this.title = '',
    this.issueSn = '',
    this.keyword = '',
    this.imageUrl = '',
    this.stkList = const [],
  });

  factory Issue06.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;

    return Issue06(
      newsSn: json['newsSn'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      title: json['title'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      stkList: list == null ? <Stock>[] : list.map((i) => Stock.fromJson(i)).toList(),
    );
  }
}


//화면구성
class ChipIssue extends StatelessWidget {
  final Stock item;

  ChipIssue(this.item,);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        label: Text(item.stockName, style: TStyle.puplePlainStyle(),),
        backgroundColor: Colors.white,
      ),
      onTap: (){
        //TODO
        DLog.d('#######', '${item.toString()}');
        // Provider.of<StockHome>(context, listen: false)
        //     .setStockData(item.stockCode, item.stockName, '', '', '', 0);
        // Navigator.push(context, new MaterialPageRoute(
        //   builder: (context) => StockHomeTab(),
        // ));
      },
    );
  }
}