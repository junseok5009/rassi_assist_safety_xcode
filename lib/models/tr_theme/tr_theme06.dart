import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2022.05.18
/// 테마 주도주 이력 조회
class TrTheme06 extends TrAtom {
  final Theme06 retData;

  TrTheme06({
    String retCode = '',
    String retMsg = '',
    this.retData = defTheme06,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme06.fromJson(Map<String, dynamic> json) {
    return TrTheme06(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] == null ? defTheme06 : Theme06.fromJson(json['retData']),
    );
  }
}

const defTheme06 = Theme06();

class Theme06 {
  final String totalPageSize;
  final String totalItemSize;
  final String currentPageNo;
  final List<TopCard> listCard;
  final List<ThemeStHistory> listTimeline;

  const Theme06({
    this.totalPageSize = '',
      this.totalItemSize = '',
      this.currentPageNo = '',
      this.listCard = const [],
      this.listTimeline = const [],
  });

  factory Theme06.fromJson(Map<String, dynamic> json) {
    var list = json['list_TopCard'] as List;
    List<TopCard>? rList;
    list == null
        ? rList = null
        : rList = list.map((i) => TopCard.fromJson(i)).toList();

    var tlist = json['list_Timeline'] as List;
    List<ThemeStHistory>? rtList;
    tlist == null
        ? rtList = null
        : rtList = tlist.map((i) => ThemeStHistory.fromJson(i)).toList();

    return Theme06(
      totalPageSize: json['totalPageSize'] ?? '',
      totalItemSize: json['totalItemSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listCard: list.map((i) => TopCard.fromJson(i)).toList(),
      listTimeline: tlist.map((i) => ThemeStHistory.fromJson(i)).toList(),
    );
  }
}

class TopCard {
  final String contentDiv;
  final String contentDesc;

  TopCard({this.contentDiv = '', this.contentDesc = ''});

  factory TopCard.fromJson(Map<String, dynamic> json) {
    return TopCard(
      contentDiv: json['contentDiv'] ?? '',
      contentDesc: json['contentDesc'] ?? '',
    );
  }
}

class ThemeStHistory {
  final String themeCode;
  final String themeName;
  final String increaseRate;
  final String elapsedDays;
  final String startDate;
  final String endDate;
  final List<StockData>? listStock;
  final List<ChartTheme>? listChart;

  ThemeStHistory({
    this.themeCode = '',
    this.themeName = '',
    this.increaseRate = '',
    this.elapsedDays = '',
    this.startDate = '',
    this.endDate = '',
    this.listStock,
    this.listChart,
  });

  factory ThemeStHistory.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockData>? stList;
    list == null
        ? stList = null
        : stList = list.map((i) => StockData.fromJson(i)).toList();

    var tlist = json['list_Chart'] as List;
    List<ChartTheme>? tmList;
    tlist == null
        ? tmList = null
        : tmList = tlist.map((i) => ChartTheme.fromJson(i)).toList();

    return ThemeStHistory(
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      listStock: stList,
      listChart: tmList,
    );
  }
}

//화면구성 - 테마상세페이지 - 주도주 히스토리
class TileTheme06 extends StatelessWidget {
  final TopCard item;

  const TileTheme06(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = '';
    if (item.contentDiv == '1') text = '주도주로 가장 많이 언급된 종목은?';
    if (item.contentDiv == '2') text = '기간 중 상승률이 가장 컸던 종목은?';
    if (item.contentDiv == '3') text = '가장 길었던 상승추세 기간은?';

    return InkWell(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          height: 150,
          margin:
              const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: UIStyle.boxRoundLine6(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TStyle.title18T,
              ),
              const SizedBox(
                height: 5,
              ),
              Html(
                data: item.contentDesc,
                style: {
                  "html": Style(
                    color: Colors.black,
                    fontSize: FontSize(15.0),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        // basePageState.callPageRouteUpData(ThemeHotViewer(),
        //     PgData(userId: '', pgSn: item.themeCode));
      },
    );
  }
}

//화면구성 테마주도주 리스트 (3종목씩 플리킹)
class TileTheme06List extends StatelessWidget {
  final ThemeStHistory tmHistory;

  const TileTheme06List(this.tmHistory, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rText;
    Color rColor;
    if (tmHistory.increaseRate.contains('-')) {
      rText = tmHistory.increaseRate;
      rColor = RColor.sigSell;
    } else {
      rText = '+${tmHistory.increaseRate}';
      rColor = RColor.sigBuy;
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${TStyle.getDateSFormat(tmHistory.startDate)}~'
                      '${TStyle.getDateSFormat(tmHistory.endDate)}',
                      style: TStyle.contentGrey14,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          tmHistory.elapsedDays,
                          style: TStyle.defaultTitle,
                        ),
                        const Text(
                          '일간',
                          style: TStyle.content14,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$rText%',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    color: rColor,
                  ),
                ),
              ],
            ),
          ),
          _setThemeBox(
              tmHistory.listStock![0],
              tmHistory.listStock![1],
              tmHistory.listStock![2]
          )
        ],
      ),
    );
  }

  Widget _setThemeBox(
    StockData item1,
    StockData item2,
    StockData item3,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Row(
          children: [
            if (item1 != null) _setInfoBox(item1),
            if (item2 != null) _setInfoBox(item2),
            if (item3 != null) _setInfoBox(item3),
          ],
        ),
      ),
    );
  }

  Widget _setInfoBox(
    StockData tItem,
  ) {
    String rText;
    Color rColor;
    if (tItem.fluctuationRate.contains('-')) {
      rText = tItem.fluctuationRate;
      rColor = RColor.sigSell;
    } else {
      rText = '+${tItem.fluctuationRate}';
      rColor = RColor.sigBuy;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: UIStyle.boxWeakGrey6(),
        child: InkWell(
          splashColor: Colors.deepPurpleAccent.withAlpha(30),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      tItem.stockName,
                      style: TStyle.subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      tItem.stockCode,
                      style: TStyle.textSGrey,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
                Text(
                  '$rText%',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: rColor,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            basePageState.goStockHomePage(
              tItem.stockCode,
              tItem.stockName,
              Const.STK_INDEX_HOME,
            );
          },
        ),
      ),
    );
  }
}
