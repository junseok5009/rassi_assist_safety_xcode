import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tag_info.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

/// 2021.03.04
/// 이 시간 PICK 조회
class TrRassi11 {
  final String retCode;
  final String retMsg;
  final List<Rassi11> listData;

  TrRassi11({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi11.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Rassiro'] as List;
    List<Rassi11> rtList = list.map((i) => Rassi11.fromJson(i)).toList();

    return TrRassi11(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      listData: rtList,
    );
  }
}

class Rassi11 {
  final String newsSn;
  final String title;
  final String newsCrtDate;
  final String newsKeyword;
  final String issueDttm;
  final String elapsedTmTx;
  final String imageUrl;
  final String viewLinkYn;
  final String totalPageSize;
  final String currentPageNo;
  final List<Tag> listTag;
  final List<StockData> listStock;

  Rassi11({
    this.newsSn = '',
    this.title = '',
    this.newsCrtDate = '',
    this.newsKeyword = '',
    this.issueDttm = '',
    this.elapsedTmTx = '',
    this.imageUrl = '',
    this.viewLinkYn = '',
    this.totalPageSize = '',
    this.currentPageNo = '',
    this.listTag = const [],
    this.listStock = const [],
  });

  factory Rassi11.fromJson(Map<String, dynamic> json) {
    var listT = json['list_Tag'] as List<dynamic>?;
    List<Tag> rtList;
    listT == null ? rtList = [] : rtList = listT.map((e) => Tag.fromJson(e)).toList();
    var listS = json['list_Stock'] as List<dynamic>?;
    List<StockData> rtListS;
    listS == null ? rtListS = [] : rtListS = listS.map((e) => StockData.fromJson(e)).toList();

    return Rassi11(
      newsSn: json['newsSn'] ?? '',
      title: json['title'] ?? '',
      newsCrtDate: json['newsCrtDate'] ?? '',
      newsKeyword: json['newsKeyword'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      elapsedTmTx: json['elapsedTmTx'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      viewLinkYn: json['viewLinkYn'] ?? '',
      totalPageSize: json['totalPageSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listTag: rtList,
      listStock: rtListS,
    );
  }

  @override
  String toString() {
    return '$newsSn | $title';
  }
}

class TileRassi11 extends StatelessWidget {
  final Rassi11 item;

  const TileRassi11(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setTagList(),
              Text(
                item.elapsedTmTx,
                style: TStyle.contentGrey14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              basePageState.callPageRouteNews(
                const NewsViewer(),
                PgNews(
                  stockCode: '',
                  stockName: '',
                  newsSn: item.newsSn,
                  createDate: item.newsCrtDate,
                ),
              );
            },
            child: Text(
              item.title,
              style: TStyle.defaultContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
          _setStockList(context, item.listStock),
          Container(
            color: Colors.black12,
            height: 1.2,
          ),
        ],
      ),
    );
  }

  Widget _setTagList() {
    return Visibility(
      visible: item.listTag.isNotEmpty,
      child: Wrap(
        spacing: 7.0,
        alignment: WrapAlignment.start,
        children: List.generate(
          item.listTag.length,
          (index) => InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
              decoration: UIStyle.boxRoundLine25c(RColor.mainColor),
              child: Text(
                '#${item.listTag[index].tagName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: RColor.mainColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            onTap: () {
              //태그 리스트로 이동
              basePageState.callPageRouteNews(
                NewsTagPage(),
                PgNews(tagCode: item.listTag[index].tagCode, tagName: item.listTag[index].tagName),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _setStockList(BuildContext context, List<StockData> listStk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
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
                  const SizedBox(width: 4,),
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

// 접을수 있는 위젯
class TileRassi11N extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Rassi11 item;
  final Color bColor;
  final Color tbColor;
  final int index;

  TileRassi11N(this.index, this.item, this.bColor, this.tbColor);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
        initiallyExpanded: index == 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              //'${item.newsKeyword}_${TStyle.getDtTimeFormat1(item.issueDttm)}',
              item.newsKeyword,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              item.elapsedTmTx,
              style: const TextStyle(
                fontSize: 13,
                color: RColor.bgSignal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Container(
            height: 0.8,
            color: RColor.lineGrey,
          ),
          Container(
            margin: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    basePageState.callPageRouteNews(
                      const NewsViewer(),
                      PgNews(
                        stockCode: '',
                        stockName: '',
                        newsSn: item.newsSn,
                        createDate: item.newsCrtDate,
                      ),
                    );
                  },
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      //작은 그레이 텍스트
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xdd555555),
                    ),
                  ),
                ),
                _bottomDesc(context, item.listStock),
                _makeRelativeListTagView(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomDesc(BuildContext context, List<StockData> listStk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
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

  Widget _makeRelativeListTagView() {
    return Visibility(
      visible: item.listTag.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('images/rassibs_pk_icon_link.png', height: 18),
              const Text('  관련 태그'),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Wrap(
            spacing: 7.0,
            alignment: WrapAlignment.start,
            children: List.generate(
              item.listTag.length,
              (index) => InkWell(
                child: Text(
                  '#${item.listTag[index].tagName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: RColor.bgSignal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  //태그 리스트로 이동
                  //굳이 아래에서 올라오는 뷰는 필요없음
                  basePageState.callPageRouteNews(NewsTagPage(),
                      PgNews(tagCode: item.listTag[index].tagCode, tagName: item.listTag[index].tagName));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
