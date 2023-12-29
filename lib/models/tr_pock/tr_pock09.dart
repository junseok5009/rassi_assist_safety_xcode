import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';


/// 2022.05.13
/// 나의 포켓 종목의 현황 조회
class TrPock09 {
  final String retCode;
  final String retMsg;
  final Pock09 retData;

  TrPock09({this.retCode='', this.retMsg='', this.retData = defPock09});

  factory TrPock09.fromJson(Map<String, dynamic> json) {
    return TrPock09(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defPock09
            : Pock09.fromJson(json['retData']));
  }
}

const defPock09 = Pock09();

class Pock09 {
  final String selectDiv;
  final String beforeOpening;
  final String stockCount;
  final List<StockPktChart> stockList;
  final List<StockPushInfo> pushList;

  const Pock09({
    this.selectDiv='',
    this.beforeOpening='',
    this.stockCount='',
    this.stockList = const [],
    this.pushList = const [],
  });

  factory Pock09.fromJson(Map<String, dynamic> json) {
    return Pock09(
      selectDiv: json['selectDiv'] ?? '',
      beforeOpening: json['beforeOpening'] ?? '',
      stockCount: json['stockCount'] ?? '0',
      stockList: json['list_Stock'] == null
          ? []
          : (json['list_Stock'] as List)
              .map((i) => StockPktChart.fromJson(i))
              .toList(),
      pushList: json['list_Push'] == null
          ? []
          : (json['list_Push'] as List)
              .map((i) => StockPushInfo.fromJson(i))
              .toList(),
    );
  }

/*  Pock09.emptyWithSelectDiv(String getSelectDiv) {
    selectDiv = getSelectDiv;
    stockList = [];
    pushList = [];
  }*/

  bool isEmpty() {
    if (selectDiv.isEmpty) {
      return true;
    } else {
      if ((selectDiv == 'UP' || selectDiv == 'DN' || selectDiv == 'TS') &&
          (stockList.isNotEmpty)) {
        return false;
      } else if ((selectDiv == 'SB' || selectDiv == 'RN') &&
          (pushList.isNotEmpty)) {
        return false;
      } else {
        return true;
      }
    }
  }

  String getEmptyTitle() {
    if (selectDiv == 'UP') {
      return '내 포켓 종목 중\n오늘 상승한 종목이 없습니다.';
    } else if (selectDiv == 'DN') {
      return '내 포켓 종목 중\n오늘 하락한 종목이 없습니다.';
    } else if (selectDiv == 'TS') {
      return '내 포켓 종목 중\n오늘 매매신호가 발생한 종목이 없습니다.';
    } else if (selectDiv == 'SB') {
      return '내 포켓 종목 중\n오늘 발생한 시세/거래량/변동성 급변이 없습니다.';
    } else if (selectDiv == 'RN') {
      return '내 포켓 종목 중\n오늘 발생한 AI속보가 없습니다.';
    } else {
      return '';
    }
  }
}

// 포켓종목에 대한 푸시 정보
class StockPushInfo {
  final String pushDiv2;
  final String pushDiv2Name;
  final String pushDiv3;
  final String stockCode;
  final String stockName;
  final String pushTitle;
  final String pushContent;
  final String regDttm;

  StockPushInfo({
    this.pushDiv2='',
    this.pushDiv2Name='',
    this.pushDiv3='',
    this.stockCode='',
    this.stockName='',
    this.pushTitle='',
    this.pushContent='',
    this.regDttm='',
  });

  factory StockPushInfo.fromJson(Map<String, dynamic> json) {
    return StockPushInfo(
      pushDiv2: json['pushDiv2'] ?? '',
      pushDiv2Name: json['pushDiv2Name'] ?? '',
      pushDiv3: json['pushDiv3'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      pushTitle: json['pushTitle'] ?? '',
      pushContent: json['pushContent'] ?? '',
      regDttm: json['regDttm'] ?? '',
    );
  }

  @override
  String toString() {
    return '$pushTitle|$stockName|$regDttm|';
  }
}

// 홈_홈 - 상승, 하락 타일
class TileUpAndDown extends StatelessWidget {
  const TileUpAndDown(
    this.item,
    this.chartItem, {Key? key,}) : super(key: key);
  final StockPktChart item;
  final Pock09ChartModel chartItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: UIStyle.boxRoundFullColor25c(
                    const Color(0xffDCDFE2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(
                    item.pocketName,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.stockName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          TStyle.getPercentString(item.fluctuationRate,),
                          style: TextStyle(
                            fontSize: 16,
                            color: TStyle.getMinusPlusColor(item.fluctuationRate,),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _setChartView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setChartView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 50,
          height: 38,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                enabled: false,
              ),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: chartItem.chartMarkLineYAxis,
                  //color: Colors.black.withOpacity(0.8),
                  strokeWidth: 1.5,
                  dashArray: [5, 2],
                ),
              ]),
              lineBarsData: [
                LineChartBarData(
                  color: chartItem.chartLineColor,
                  spots: chartItem.listChartData,
                  isCurved: true,
                  isStrokeCapRound: true,
                  barWidth: 1.5,
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                  dotData: FlDotData(show: false),
                ),
              ],
              minY: chartItem.chartYAxisMin,
              //maxY: 10,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
            ),
            //swapAnimationDuration: Duration(milliseconds: 10000),
            //swapAnimationCurve: Curves.linear, // Optional
          ),
        ),
        const Text(
          '1 Month',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: Color(0xdd555555),
          ),
        ),
      ],
    );
  }
}

class Pock09ChartModel {
  final List<FlSpot>? listChartData;
  double? chartYAxisMin;
  double chartMarkLineYAxis;
  Color? chartLineColor;

  Pock09ChartModel({
    this.listChartData,
    this.chartYAxisMin,
    this.chartMarkLineYAxis=0.0,
    this.chartLineColor,
  });
}

// 홈_홈 - 매매신호 타일
class TilePocketSig extends StatelessWidget {
  final StockPktChart item;
  const TilePocketSig(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: UIStyle.boxRoundFullColor25c(
                  const Color(0xffDCDFE2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  item.pocketName,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.stockName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          _setBsInfo(item),
        ],
      ),
    );
  }

  Widget _setBsInfo(StockPktChart item) {
    Color bColor;
    String sText;
    String mText;
    if (item.tradeFlag == 'B') {
      sText = '오늘 매수';
      bColor = RColor.sigBuy;
      mText = '매수가';
    } else {
      sText = '오늘 매도';
      bColor = RColor.sigSell;
      mText = '매도가';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 90,
          height: 22,
          decoration: BoxDecoration(
            color: bColor,
            borderRadius: const BorderRadius.all(Radius.circular(7.0)),
          ),
          child: Center(
            child: Text(
              sText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              TStyle.getDtTimeFormat(item.tradeDttm),
              style: TStyle.contentGrey14,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              mText,
              style: TStyle.contentGrey14,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              TStyle.getMoneyPoint(item.tradePrice),
              style: TStyle.defaultContent,
            ),
          ],
        )
      ],
    );
  }
}

// 홈_홈 - 종목소식 타일 (Push 정보)
class TileStockPush extends StatelessWidget {
  final StockPushInfo item;
  const TileStockPush(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  item.stockName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xff111111),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                item.stockCode,
                                style: TStyle.contentGrey14,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          TStyle.getDtTimeFormat(item.regDttm),
                          style: TStyle.contentGrey14,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 26,
                decoration: UIStyle.boxRoundLine20(),
                child: Center(
                  child: Text(
                    item.pushDiv2Name,
                    style: TStyle.commonSPurple,
                  ),
                ),
              ),
            ],
          ),
          Text(
            item.pushContent.replaceAll('\n', ''),
            style: TStyle.contentGrey14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// 홈_홈 - AI속보 타일
class TileStockNews extends StatelessWidget {
  final StockPushInfo item;
  const TileStockNews(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //종목정보
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      TStyle.getLimitString(item.stockName, 8),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xff111111),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      item.stockCode,
                      style: TStyle.contentGrey14,
                    ),
                  ],
                ),
              ),

              Text(
                TStyle.getDtTimeFormat(item.regDttm),
                style: TStyle.contentGrey14,
              ),
            ],
          ),
          Text(
            item.pushContent.replaceAll('\n', ''),
            textAlign: TextAlign.start,
            style: TStyle.contentGrey14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
