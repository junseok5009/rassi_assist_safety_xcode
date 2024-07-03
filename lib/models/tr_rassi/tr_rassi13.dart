import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tag_info.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

/// 2021.03.09
/// AI 속보 분석 리포트
class TrRassi13 {
  final String retCode;
  final String retMsg;
  final List<Rassi13> listData;
  final String reportDesc;

  TrRassi13({this.retCode = '', this.retMsg = '', this.listData = const [], this.reportDesc = ''});

  factory TrRassi13.fromJson(Map<String, dynamic> json) {
    var rlist = json['retData']['list_Rassiro'] as List;
    List<Rassi13> rtList = rlist.map((i) => Rassi13.fromJson(i)).toList();

    return TrRassi13(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
      reportDesc: json['retData'] == null ? '' : json['retData']['reportDesc'],
    );
  }
}

class Rassi13 {
  final String newsSn;
  final String title;
  final String newsCrtDate;
  final String issueDttm;
  final String elapsedTmTx;
  final String imageUrl;
  final String viewLinkYn;
  final List<Tag> listTag;
  final List<StockData> listStock;

  Rassi13({
    this.newsSn = '',
    this.title = '',
    this.newsCrtDate = '',
    this.issueDttm = '',
    this.elapsedTmTx = '',
    this.imageUrl = '',
    this.viewLinkYn = '',
    this.listTag = const [],
    this.listStock = const [],
  });

  factory Rassi13.fromJson(Map<String, dynamic> json) {
    var listT = json['list_Tag'] as List?;
    List<Tag> rtList;
    listT == null ? rtList = [] : rtList = listT.map((e) => Tag.fromJson(e)).toList();

    var listS = json['list_Stock'] as List?;
    List<StockData> rsList;
    listS == null ? rsList = [] : rsList = listS.map((e) => StockData.fromJson(e)).toList();

    return Rassi13(
      newsSn: json['newsSn'] ?? '',
      title: json['title'] ?? '',
      newsCrtDate: json['newsCrtDate'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      elapsedTmTx: json['elapsedTmTx'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      viewLinkYn: json['viewLinkYn'] ?? '',
      listTag: rtList,
      listStock: rsList,
    );
  }

  @override
  String toString() {
    return '$newsSn | $title | $listStock';
  }
}

//화면구성
class TileChipStock extends StatelessWidget {
  final appGlobal = AppGlobal();
  final StockData item;

  TileChipStock(
    this.item,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(
          item.stockName,
        ),
        backgroundColor: RColor.yonbora2,
      ),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }
}

//화면구성
class TileChipReport extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Rassi13 item;
  final String reportDiv;

  TileChipReport(
    this.item,
    this.reportDiv,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(
          item.listTag[0].tagName,
        ),
        backgroundColor: RColor.yonbora2,
      ),
      onTap: () {
        String stockCode;
        String stockName;
        if (item.listStock.length == 0) {
          stockCode = '';
          stockName = '';
        } else {
          stockCode = item.listStock[0].stockCode;
          stockName = item.listStock[0].stockName;
        }
        basePageState.callPageRouteNews(
          NewsViewer(),
          PgNews(
            stockCode: stockCode,
            stockName: stockName,
            newsSn: item.newsSn,
            createDate: item.newsCrtDate,
            reportDiv: reportDiv,
          ),
        );
      },
    );
  }
}

//화면구성
class TileRassi13 extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Rassi13 item;
  final String reportDiv;

  TileRassi13(this.item, this.reportDiv);

  @override
  Widget build(BuildContext context) {
    DLog.d('TrRassi13 TileRassi13', 'item : ${item.toString()}');
    String tagName;

    if (item.listTag != null && item.listTag.length > 0) {
      tagName = '#${item.listTag[0].tagName}';
    } else {
      tagName = '';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setReportInfo(tagName),
          _setRelayInfo(context, item.listStock),
          const SizedBox(height: 7),
          Container(
            color: Colors.black12,
            height: 1.2,
          ),
        ],
      ),
    );
  }

  Widget _setReportInfo(String tagName) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                  decoration: UIStyle.boxRoundLine25c(RColor.mainColor),
                  child: Text(
                    tagName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: RColor.mainColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  item.elapsedTmTx,
                  style: TStyle.purpleThinStyle(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TStyle.content16,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility(
                  visible: reportDiv == '0' &&
                      int.parse(DateTime.now().difference(DateTime.parse(item.newsCrtDate)).inDays.toString()) == 0,
                  child: Image.asset(
                    'images/main_icon_new_red_small.png',
                    height: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        String stockCode = '';
        String stockName = '';
        if (item.listStock.length > 0) {
          stockCode = item.listStock[0].stockCode;
          stockName = item.listStock[0].stockName;
        }
        basePageState.callPageRouteNews(
          const NewsViewer(),
          PgNews(
              stockCode: stockCode,
              stockName: stockName,
              newsSn: item.newsSn,
              createDate: item.newsCrtDate,
              reportDiv: reportDiv),
        );
      },
    );
  }

  Widget _setRelayInfo(BuildContext context, List<StockData> listStk) {
    return Container(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
      child: Wrap(
        spacing: 7.0,
        alignment: WrapAlignment.start,
        children: List.generate(
            listStk.length,
            (index) => InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    // decoration: UIStyle.boxRoundFullColor25c(RColor.bgWeakGrey),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TStyle.getLimitString(listStk[index].stockName, 7),
                          style: TStyle.contentGrey14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          TStyle.getPercentString(TStyle.getFixedNum(listStk[index].fluctuationRate)),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TStyle.getMinusPlusColor(
                              listStk[index].fluctuationRate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /*  Container(
                    padding: const EdgeInsets.all(1),
                    // color: RColor.bgWeakGrey,
                    child: Text(
                      TStyle.getLimitString(listStk[index].stockName, 7),
                      style: TStyle.puplePlainStyle(),
                    ),
                  ),*/
                  onTap: () {
                    //종목홈으로 이동
                    basePageState.goStockHomePage(
                      listStk[index].stockCode,
                      listStk[index].stockName,
                      Const.STK_INDEX_HOME,
                    );
                  },
                )),
      ),
    );
  }
}
