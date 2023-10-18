import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/stock_home/page/disclos_detail_page.dart';

import '../ui/main/base_page.dart';

class TrDisclos01 {
  final String retCode;
  final String retMsg;
  final Disclos01 retData;

  TrDisclos01({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defDisclos01
  });

  factory TrDisclos01.fromJson(Map<String, dynamic> json) {
    return TrDisclos01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] == null ? defDisclos01 : Disclos01.fromJson(json['retData']),
    );
  }
}

const defDisclos01 = Disclos01();

class Disclos01 {
  final String totalPageSize;
  final String currentPageNo;
  final List<Disclos> listDisclos;

  const Disclos01({
    this.totalPageSize = '',
    this.currentPageNo = '',
    this.listDisclos = const [],
  });

  factory Disclos01.fromJson(Map<String, dynamic> json) {
    var list =
        json['list_Disclosure'] == null ? [] : json['list_Disclosure'] as List;
    List<Disclos> dataList =
        list == null ? [] : list.map((i) => Disclos.fromJson(i)).toList();
    return Disclos01(
      totalPageSize: json['totalPageSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listDisclos: dataList,
    );
  }
}

class Disclos {
  final String newsSn;
  final String issueDate;
  final String title;
  final String stockCode;
  final String stockName;
  final String totalPageSize;
  final String currentPageNo;

  Disclos({
    this.newsSn = '',
      this.issueDate = '',
      this.title = '',
      this.stockCode = '',
      this.stockName = '',
      this.totalPageSize = '',
      this.currentPageNo = ''
  });

  bool isEmpty() {
    return [stockCode, stockName, issueDate, newsSn, issueDate].contains(null);
  }

  factory Disclos.fromJson(Map<String, dynamic> json) {
    return Disclos(
      newsSn: json['newsSn'] ?? '',
      issueDate: json['issueDate'] ?? '',
      title: json['title'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      totalPageSize: json['totalPageSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
    );
  }
}

Widget TileDisclos01(Disclos item) {
  return Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 15,
    ),
    child: InkWell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            item.title,
            style: TStyle.defaultContent,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            TStyle.getDateSFormat(item.issueDate),
            style: TStyle.textGrey14,
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: RColor.lineGrey,
          ),
        ],
      ),
      onTap: () {
        basePageState.callPageRouteUpData(
          DisclosDetailPage(),
          PgData(
            stockCode: item.stockCode,
            pgData: item.newsSn,
          ),
        );
      },
    ),
  );
}

Widget TileDisclos01ListItemView(Disclos item) {
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
      : InkWell(
          splashColor: Colors.deepPurpleAccent.withAlpha(30),
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
                Text(
                  item.title,
                  style: TStyle.content15,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  TStyle.getDateSlashFormat4(item.issueDate),
                  style: TStyle.newBasicGreyS15,
                ),
              ],
            ),
          ),
          onTap: () {
            basePageState.callPageRouteUpData(
                DisclosDetailPage(),
                PgData(
                  stockCode: item.stockCode,
                  pgData: item.newsSn,
                ));
          },
        );
}
