import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tag_info.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';


/// 2021.03.08
/// AI가 찾은 추천 정보 조회 (rassi11 obj 공유할수도 있을듯)
class TrRassi14 {
  final String retCode;
  final String retMsg;
  final List<Rassi14> listData;
  final List<TagEvent> listTag;

  TrRassi14({
    this.retCode = '',
    this.retMsg = '',
    this.listData = const [],
    this.listTag = const []
  });

  factory TrRassi14.fromJson(Map<String, dynamic> json) {
    var rlist = json['retData']['list_Rassiro'] as List;
    List<Rassi14> rtList = rlist.map((i) => Rassi14.fromJson(i)).toList();
    var tlist = json['retData']['list_NewsTag'] as List;
    List<TagEvent> tgList = tlist.map((i) => TagEvent.fromJson(i)).toList();

    return TrRassi14(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      listData: rtList,
      listTag: tgList,
    );
  }
}

class Rassi14 {
  final String newsSn;
  final String title;
  final String newsCrtDate;
  final String issueDttm;
  final String elapsedTmTx;
  final String imageUrl;
  final String viewLinkYn;
  final String totalPageSize;
  final String currentPageNo;
  final List<Tag> listTag;
  final List<Stock> listStock;

  Rassi14({
    this.newsSn = '',
      this.title = '',
      this.newsCrtDate = '',
      this.issueDttm = '',
      this.elapsedTmTx = '',
      this.imageUrl = '',
      this.viewLinkYn = '',
      this.totalPageSize = '',
      this.currentPageNo = '',
      this.listTag = const [],
      this.listStock = const [],
  });

  factory Rassi14.fromJson(Map<String, dynamic> json) {
    var listT = json['list_Tag'] as List;
    List<Tag> rtList = listT.map((e) => Tag.fromJson(e)).toList();
    var listS = json['list_Stock'] as List;
    List<Stock> rtListS = listS.map((e) => Stock.fromJson(e)).toList();

    return Rassi14(
      newsSn: json['newsSn'],
      title: json['title'],
      newsCrtDate: json['newsCrtDate'],
      issueDttm: json['issueDttm'],
      elapsedTmTx: json['elapsedTmTx'],
      imageUrl: json['imageUrl'],
      viewLinkYn: json['viewLinkYn'],
      totalPageSize: json['totalPageSize'],
      currentPageNo: json['currentPageNo'],
      listTag: rtList,
      listStock: rtListS,
    );
  }

  @override
  String toString() {
    return '$newsSn | $title';
  }
}

//화면구성
class TileRassi14 extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Rassi14 item;

  TileRassi14(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    String tagName;
    if (item.listTag != null && item.listTag.length > 0) {
      tagName = '#${item.listTag[0].tagName}';
    } else {
      tagName = '';
    }

    return Container(
      width: double.infinity,
      //height: 115,
      margin: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setNewsInfo(tagName),
          _setRelayInfo(context, item.listStock),
        ],
      ),
    );
  }

  Widget _setNewsInfo(String tagName) {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tagName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: RColor.bgSignal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.elapsedTmTx,
                  style: TStyle.textSGrey,
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              item.title,
              style: TStyle.content15,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      onTap: () {
        basePageState.callPageRouteNews(
          NewsViewer(),
          PgNews(
            stockCode: '',
            stockName: '',
            newsSn: item.newsSn,
            createDate: item.newsCrtDate,
          ),
        );
      },
    );
  }

  Widget _setRelayInfo(BuildContext context, List<Stock> listStk) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        bottom: 10,
        top: 6,
      ),
      child: Wrap(
        spacing: 7.0,
        alignment: WrapAlignment.start,
        children: List.generate(
            listStk.length,
            (index) => InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    decoration: UIStyle.boxRoundFullColor25c(RColor.bgWeakGrey),
                    child: Text(
                      TStyle.getLimitString(listStk[index].stockName, 7),
                      style: TStyle.subTitle,
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
                )),
      ),
    );
  }
}

class TagEvent {
  final String tagCode;
  final String tagName;
  final String tagEvent;

  TagEvent({
    this.tagCode = '',
    this.tagName = '',
    this.tagEvent = '',
  });

  factory TagEvent.fromJson(Map<String, dynamic> json) {
    return TagEvent(
      tagCode: json['tagCode'],
      tagName: json['tagName'],
      tagEvent: json['tagEvent'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tagCode|$tagName';
  }
}

//화면구성
class TileChip14 extends StatelessWidget {
  final TagEvent item;

  TileChip14(this.item);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
          label: Text(
            '#${item.tagName}',
            style: const TextStyle(
              color: RColor.mainColor,
            ),
          ),
          backgroundColor: RColor.bgWeakBora,
      ),
      onTap: () {
        //굳이 아래에서 올라오는 뷰는 필요없음
        basePageState.callPageRouteNews(NewsTagPage(),
            PgNews(tagCode: item.tagCode, tagName: item.tagName));
      },
    );
  }
}
