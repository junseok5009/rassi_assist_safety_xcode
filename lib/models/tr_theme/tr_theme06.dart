import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
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
      retData: json['retData'] == null ? defTheme06 : Theme06.fromJson(json['retData']),
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
    var jsonCardList = json['list_TopCard'];
    var jsonTimeLineList = json['list_Timeline'];
    return Theme06(
      totalPageSize: json['totalPageSize'] ?? '',
      totalItemSize: json['totalItemSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listCard: jsonCardList == null ? [] : (jsonCardList as List).map((i) => TopCard.fromJson(i)).toList(),
      listTimeline:
          jsonTimeLineList == null ? [] : (jsonTimeLineList as List).map((i) => ThemeStHistory.fromJson(i)).toList(),
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
  final List<StockData> listStock;
  final List<ChartTheme> listChart;

  ThemeStHistory({
    this.themeCode = '',
    this.themeName = '',
    this.increaseRate = '',
    this.elapsedDays = '',
    this.startDate = '',
    this.endDate = '',
    this.listStock = const [],
    this.listChart = const [],
  });

  factory ThemeStHistory.fromJson(Map<String, dynamic> json) {
    var jsonStockList = json['list_Stock'];
    var jsonChartList = json['list_Chart'];
    return ThemeStHistory(
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      listStock: jsonStockList == null ? [] : (jsonStockList as List).map((i) => StockData.fromJson(i)).toList(),
      listChart: jsonChartList == null ? [] : (jsonChartList as List).map((e) => ChartTheme.fromJson(e)).toList(),
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
          height: 164,
          padding: const EdgeInsets.all(15),
          decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                decoration: UIStyle.boxCustom(
                    bgColor: RColor.greyBox_f5f5f5, boxRadius: 6, lineColor: Colors.black, lineWidth: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: const Text(
                  '히스토리',
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              AutoSizeText(
                text,
                style: TStyle.title18T,
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: Html(
                  data: item.contentDesc,
                  style: {
                    "html": Style(
                      color: Colors.black,
                      fontSize: FontSize(15.0),
                    ),
                  },
                ),
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
  final ThemeStHistory item;

  const TileTheme06List(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: UIStyle.boxShadowBasic(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TStyle.getDateSlashFormat2(item.startDate)}~'
            '${TStyle.getDateSlashFormat2(item.endDate)}',
            style: TStyle.contentGrey14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${item.elapsedDays}일간',
                style: TStyle.title18T,
              ),
              Text(
                TStyle.getPercentString(item.increaseRate),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: TStyle.getMinusPlusColor(item.increaseRate),
                ),
              ),
            ],
          ),
          ListView.builder(
            itemCount: item.listStock.length,
            itemBuilder: (context, index) => _setInfoBox(index, item.listStock[index]),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    );
  }

  Widget _setInfoBox(
    int index,
    StockData tItem,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 18,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                '${index + 1}  ${tItem.stockName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            CommonView.setFluctuationRateBox(value: tItem.fluctuationRate),
          ],
        ),
        onTap: () {
          basePageState.goStockHomePage(
            tItem.stockCode,
            tItem.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }
}
