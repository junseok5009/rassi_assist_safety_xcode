import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

import '../../../common/const.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/none_tr/stock/stock.dart';
import '../../../models/pg_data.dart';
import '../../../models/tr_pock/tr_pock10.dart';
import '../../main/base_page.dart';
import '../../news/issue_viewer.dart';

/// 2023.12
/// [포켓_TODAY - 상승/하락 타일]
class TileUpAndDown extends StatefulWidget {
  const TileUpAndDown(
    this.item,
    this.chartItem, {
    Key? key,
  }) : super(key: key);
  final StockPktChart item;
  final Pock10ChartModel chartItem;

  @override
  State<TileUpAndDown> createState() => _TileUpAndDownState();
}

class _TileUpAndDownState extends State<TileUpAndDown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 83,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //포켓명
                Container(
                  decoration: UIStyle.boxRoundFullColor25c(
                    const Color(0xffDCDFE2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(
                    TStyle.getLimitString(widget.item.pocketName, 10),
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                //종목명
                Text(
                  ' ${TStyle.getLimitString(widget.item.stockName, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //등락률
                  Text(
                    TStyle.getPercentString(
                      widget.item.fluctuationRate,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TStyle.getMinusPlusColor(
                        widget.item.fluctuationRate,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  //등락금액
/*                  Text(
                    TStyle.getTriangleStringWithMoneyPoint(widget.item.fluctuationAmt),
                    style: TextStyle(
                      color: TStyle.getMinusPlusColor(widget.item.fluctuationAmt),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),*/
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _setChartView(),
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
              lineTouchData: LineTouchData(
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
                  dotData: FlDotData(show: false),
                ),
              ],
              minY: widget.chartItem.chartYAxisMin,
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
            swapAnimationDuration: const Duration(milliseconds: 180),
            swapAnimationCurve: Curves.fastLinearToSlowEaseIn,
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

/// 2023.12
/// [포켓_TODAY - 매매신호 타일]
class TilePocketSig extends StatelessWidget {
  final StockPktChart item;

  const TilePocketSig(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 83,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                if (item.myTradeFlag == 'S') {
                  //나만의 매도신호는 나만의 매도 신호 탭으로 이동
                  DefaultTabController.of(context).animateTo(2);
                } else {
                  //매매신호는 해당 종목의 매매신호 탭으로 이동
                  basePageState.goStockHomePage(
                    item.stockCode,
                    item.stockName,
                    Const.STK_INDEX_SIGNAL,
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      item.myTradeFlag == 'S'
                          ? '나만의 매도신호'
                          : TStyle.getLimitString(item.pocketName, 10),
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Expanded(
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
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          if (Provider.of<UserInfoProvider>(context, listen: false)
              .isPremiumUser())
            _setSignalView(context)
          else if (Provider.of<UserInfoProvider>(context,
              listen: false)
              .is3StockUser() &&
              item.signalYn == 'Y')
            _setSignalView(context)
          else
            _setNoPremiumBlockView(context)

        ],
      ),
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

  _setSignalView(BuildContext context){
    return InkWell(
      onTap: () {
        if (item.myTradeFlag == 'S') {
          //나만의 매도신호는 나만의 매도 신호 탭으로 이동
          DefaultTabController.of(context).animateTo(2);
        } else {
          //매매신호는 해당 종목의 매매신호 탭으로 이동
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_SIGNAL,
          );
        }
      },
      child: Row(
        children: [
          _setBsInfo(),
          const SizedBox(width: 10,),
          _setBsIcon(),
        ],
      ),
    );
  }

  Widget _setBsInfo() {
    String mText;
    String mPrice;
    String mDttm;
    if (item.myTradeFlag == 'S') {
      mText = '매도가';
      mPrice = item.sellPrice;
      mDttm = item.sellDttm;
    } else if (item.tradeFlag == 'B') {
      mText = '매수가';
      mPrice = item.tradePrice;
      mDttm = item.tradeDttm;
    } else {
      mText = '매도가';
      mPrice = item.tradePrice;
      mDttm = item.tradeDttm;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          TStyle.getDtTimeFormat(mDttm),
          style: TStyle.contentGrey14,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              mText,
              style: TStyle.contentGrey14,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              TStyle.getMoneyPoint(mPrice),
              style: TStyle.defaultContent,
            ),
          ],
        )
      ],
    );
  }

  Widget _setBsIcon() {
    Color bColor;
    String sText;
    double rad;
    if (item.myTradeFlag == 'S') {
      sText = '나만의\n매도';
      bColor = RColor.purpleBasic_6565ff;
      rad = 10.0;
    } else if (item.tradeFlag == 'B') {
      sText = '오늘\n매수';
      bColor = RColor.sigBuy;
      rad = 25.0;
    } else {
      sText = '오늘\n매도';
      bColor = RColor.sigSell;
      rad = 25.0;
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bColor,
        borderRadius: BorderRadius.all(Radius.circular(rad)),
      ),
      child: Center(
        child: Text(
          sText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 2023.12
/// [포켓_TODAY - 종목 이슈 타일]
class TileStockIssue extends StatefulWidget {
  final StockIssueInfo item;

  const TileStockIssue(this.item, {Key? key}) : super(key: key);

  @override
  State<TileStockIssue> createState() => _TileStockIssue();
}

class _TileStockIssue extends State<TileStockIssue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 83,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.keyword,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xff111111),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    _issueStatusView(widget.item.avgFluctRate),
                  ],
                ),
                onTap: () {
                  basePageState.callPageRouteUpData(
                      const IssueViewer(),
                      PgData(
                          userId: '',
                          pgSn: widget.item.newsSn,
                          pgData: widget.item.issueSn));
                },
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                child: _relayStockView(context, widget.item.stockList.length),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _issueStatusView(String avgFluctRate) {
    if (avgFluctRate == '0' ||
        avgFluctRate == '0.0' ||
        avgFluctRate == '0.00') {
      return Text(
        '보합 ${TStyle.getPercentString(avgFluctRate)}',
        style: TStyle.contentGrey14,
      );
    }
    if (!avgFluctRate.contains('-')) {
      return Text(
        '상승중 ${TStyle.getPercentString(avgFluctRate)}',
        style: TextStyle(
          color: TStyle.getMinusPlusColor(avgFluctRate),
        ),
      );
    } else if (avgFluctRate.contains('-')) {
      return Text(
        '하락중 ${TStyle.getPercentString(avgFluctRate)}',
        style: TextStyle(
          color: TStyle.getMinusPlusColor(avgFluctRate),
        ),
      );
    } else {
      return Container();
    }
  }

  //관련 종목 부분
  Widget _relayStockView(BuildContext context, int len) {
    return Wrap(
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 7,
      alignment: WrapAlignment.end,
      children: List.generate(
          len, (index) => _relayStock(widget.item.stockList[index])),
    );
  }

  //관련 종목
  Widget _relayStock(Stock one) {
    int strLen;
    one.stockName.length > 5 ? strLen = 6 : strLen = one.stockName.length;
    return InkWell(
      child: Text(
        one.stockName.substring(0, strLen),
        style: const TextStyle(
          color: RColor.greyBasicStrong_666666,
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

/// 2023.12
/// [포켓_TODAY - 수급 타일]
class TileSupplyAndDemand extends StatefulWidget {
  final StockSupplyDemand item;

  const TileSupplyAndDemand(this.item, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TileSupplyAndDemandState();
}

class _TileSupplyAndDemandState extends State<TileSupplyAndDemand> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 83,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //종목정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  //종목명
                  Text(
                    ' ${TStyle.getLimitString(widget.item.stockName, 6)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.item.stockCode,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ],
              ),
              //포켓명
              Container(
                decoration: UIStyle.boxRoundFullColor25c(
                  const Color(0xffDCDFE2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  TStyle.getLimitString(widget.item.pocketName, 10),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),

          // 타이틀
          Text(
            widget.item.issueTitle,
            textAlign: TextAlign.start,
            style: TStyle.content14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 2023.12
/// [포켓_TODAY - 차트분석 타일]
class TileStockChart extends StatefulWidget {
  final StockSupplyDemand item;

  const TileStockChart(this.item, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TileStockChartState();
}

class _TileStockChartState extends State<TileStockChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 83,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //종목정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  //종목명
                  Text(
                    TStyle.getLimitString(widget.item.stockName, 6),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.item.stockCode,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ],
              ),
              //포켓명
              Container(
                decoration: UIStyle.boxRoundFullColor25c(
                  const Color(0xffDCDFE2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  TStyle.getLimitString(widget.item.pocketName, 10),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),

          // 타이틀
          Text(
            widget.item.issueTitle,
            textAlign: TextAlign.start,
            style: TStyle.content14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
