import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.05.13
/// 나의 포켓 종목의 현황 조회
class TrPock09 {
  final String retCode;
  final String retMsg;
  final Pock09? retData;

  TrPock09({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPock09.fromJson(Map<String, dynamic> json) {
    return TrPock09(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Pock09.fromJson(json['retData']),
    );
  }
}

class Pock09 {
  String selectDiv = '';
  String beforeOpening = '';
  String stockCount = '';
  String pocketSn = '';
  List<StockPktChart> stockList = [];
  List<StockPushInfo> pushList = [];

  Pock09({
    this.selectDiv = '',
    this.beforeOpening = '',
    this.stockCount = '',
    this.pocketSn = '',
    this.stockList = const [],
    this.pushList = const [],
  });

  factory Pock09.fromJson(Map<String, dynamic> json) {
    return Pock09(
      selectDiv: json['selectDiv'] ?? '',
      beforeOpening: json['beforeOpening'] ?? '',
      stockCount: json['stockCount'] ?? '0',
      pocketSn: json['pocketSn'] ?? '',
      stockList: json['list_Stock'] == null ? [] : (json['list_Stock'] as List).map((i) => StockPktChart.fromJson(i)).toList(),
      pushList: json['list_Push'] == null ? [] : (json['list_Push'] as List).map((i) => StockPushInfo.fromJson(i)).toList(),
    );
  }

  Pock09.emptyWithSelectDiv(String getSelectDiv) {
    selectDiv = getSelectDiv;
    stockList = [];
    pushList = [];
  }

  bool isEmpty() {
    if (selectDiv.isEmpty) {
      return true;
    } else {
      if ((selectDiv == 'UP' || selectDiv == 'DN' || selectDiv == 'TS') && (stockList.isNotEmpty)) {
        return false;
      } else if ((selectDiv == 'SB' || selectDiv == 'RN') && (pushList.isNotEmpty)) {
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
  final String newsCrtDate;
  final String newsSn;

  StockPushInfo({
    this.pushDiv2 = '',
    this.pushDiv2Name = '',
    this.pushDiv3 = '',
    this.stockCode = '',
    this.stockName = '',
    this.pushTitle = '',
    this.pushContent = '',
    this.regDttm = '',
    this.newsCrtDate = '',
    this.newsSn = '',
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
      newsCrtDate: json['newsCrtDate'] ?? '',
      newsSn: json['newsSn'] ?? '',
    );
  }

  @override
  String toString() {
    return '$pushTitle|$stockName|$regDttm|';
  }
}

// 홈_홈 - 상승, 하락 타일
/*class TileUpAndDown extends StatelessWidget {
  const TileUpAndDown(
    this.item,
    this.chartItem, {
    Key key,
  }) : super(key: key);
  final StockPktChart item;
  final Pock09ChartModel chartItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
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
                        ' ${item.stockName}',
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
                          TStyle.getPercentString(
                            item.fluctuationRate,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: TStyle.getMinusPlusColor(
                              item.fluctuationRate,
                            ),
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
                  y: chartItem.chartMarkLineYAxis - 0.000001,
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
            swapAnimationDuration: Duration(milliseconds: 2000),
            swapAnimationCurve: Curves.linear, // Optional

          ),
        ),
        Text(
          item.listingYn == 'Y' ? 'New' : '1 Month',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: Color(0xdd555555),
          ),
        ),
      ],
    );
  }

}*/

class TileUpAndDown extends StatefulWidget {
  const TileUpAndDown(
    this.item,
    this.chartItem, {
    Key? key,
  }) : super(key: key);
  final StockPktChart item;
  final Pock09ChartModel chartItem;

  @override
  State<TileUpAndDown> createState() => _TileUpAndDownState();
}

class _TileUpAndDownState extends State<TileUpAndDown> {
  /*Timer timer;
  int count = 3;
  Pock09ChartModel chartItem = Pock09ChartModel(
    listChartData: const [],
    chartLineColor: Colors.black,
    chartMarkLineYAxis: 2,
    chartYAxisMin: 0,
  );*/

  @override
  void initState() {
    super.initState();
    /*if (widget.chartItem.listChartData.length > 5) {
      Pock09ChartModel beforeChartItem = Pock09ChartModel(
        listChartData: widget.chartItem.listChartData.sublist(0, 3),
        chartYAxisMin: widget.chartItem.chartYAxisMin,
        chartMarkLineYAxis: widget.chartItem.chartMarkLineYAxis,
        chartLineColor: Colors.transparent,
      );
      chartItem = beforeChartItem;
      chartItem.chartLineColor = widget.chartItem.chartLineColor;
      timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
        setState(() {
          //beforeChartItem.listChartData.removeAt(0);
          beforeChartItem.listChartData
              .add(widget.chartItem.listChartData[count]);
          if (count == widget.chartItem.listChartData.length - 1) {
            timer.cancel();
            setState(() {});
          } else {
            count++;
          }
        });
      });
    } else {
      setState(() {
        chartItem = widget.chartItem;
      });
    }*/
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    //if (timer != null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),
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
                      widget.item.pocketName,
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
                          ' ${widget.item.stockName}',
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
                            TStyle.getPercentString(
                              widget.item.fluctuationRate,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: TStyle.getMinusPlusColor(
                                widget.item.fluctuationRate,
                              ),
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
      ),
    );
  }

  Widget _setChartView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 50,
          height: 38,
          alignment: Alignment.center,
          child: LineChart(
            LineChartData(
              lineTouchData: const LineTouchData(
                enabled: false,
              ),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: widget.chartItem.chartMarkLineYAxis - 0.000001,
                  //color: Colors.black.withOpacity(0.8),
                  strokeWidth: 1.5,
                  dashArray: [5, 2],
                ),
              ]),
              lineBarsData: [
                LineChartBarData(
                  color: widget.chartItem.chartLineColor,
                  spots: widget.chartItem.listChartData,
                  isCurved: true,
                  isStrokeCapRound: true,
                  barWidth: 1.5,
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
              minY: widget.chartItem.chartYAxisMin,
              //maxY: 10,
              titlesData: const FlTitlesData(
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
              gridData: const FlGridData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
            ),
            duration: const Duration(milliseconds: 180),
            curve: Curves.linear,
            //swapAnimationDuration: const Duration(milliseconds: 180),
            //swapAnimationCurve: Curves.fastLinearToSlowEaseIn,
            //swapAnimationCurve: Curves.linear, // Optional
          ),
        ),
        Text(
          widget.item.listingYn == 'Y' ? 'New' : '1 Month',
          style: const TextStyle(
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
  final List<FlSpot> listChartData;
  double chartYAxisMin;
  double chartMarkLineYAxis;
  Color? chartLineColor;

  Pock09ChartModel({
    this.listChartData = const [],
    this.chartYAxisMin = 0,
    this.chartMarkLineYAxis = 0,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
          ),
          const SizedBox(
            width: 5,
          ),
          if (Provider.of<UserInfoProvider>(context, listen: false)
              .isPremiumUser())
              _setBsInfo(item)
          else if (Provider.of<UserInfoProvider>(context,
              listen: false)
              .is3StockUser() &&
              item.signalYn == 'Y')
            _setBsInfo(item)
          else
            _setNoPremiumBlockView(context)
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

  // 프리미엄 아닐때 매매신호 리스트 아이템들
  _setNoPremiumBlockView(BuildContext context) {
    return InkWell(
      onTap: () async {
        String result = await CommonPopup.instance.showDialogPremium(context);
        if (result == CustomNvRouteResult.landPremiumPage) {
          basePageState.navigateAndGetResultPayPremiumPage();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset(
            'images/icon_lock_grey.png',
            height: 16,
          ),
          const Text(
            '프리미엄으로 업그레이드하시고\n지금 바로 확인해 보세요',
            style: TextStyle(
              fontSize: 12,
              color: RColor.greyMore_999999,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
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
            item.pushTitle,
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
