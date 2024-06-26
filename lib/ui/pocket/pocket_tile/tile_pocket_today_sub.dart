import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_tab.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../common/const.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/none_tr/chart_data.dart';
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
  bool _isChartVisible = false;
  Color _chartColor = RColor.greyMore_999999;
  ChartSeriesController? _chartController;
  double _animationDuration = 0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _chartController?.animate();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    int compareTradePrc = widget.item.listChart.first.tradePrc.compareTo(widget.item.listChart.last.tradePrc);
    _chartColor = compareTradePrc > 0
        ? RColor.bgSell
        : compareTradePrc < 0
            ? RColor.bgBuy
            : RColor.greyMore_999999;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.item.stockCode),
      onVisibilityChanged: (visibilityInfo) {
        if (!_isChartVisible && visibilityInfo.visibleFraction > 0.5) {
          _isChartVisible = true;
          if (_animationDuration != 1000) {
            setState(() {
              _animationDuration = 1000;
            });
          } else {
            _chartController?.animate();
          }
        }
        if (_isChartVisible && visibilityInfo.visibleFraction < 0.1) {
          _isChartVisible = false;
        }
      },
      child: Container(
        width: double.infinity,
        height: 83,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //포켓명
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        SliverPocketTab.globalKey.currentState
                            ?.refreshChildWithMoveTab(moveTabIndex: 1, changePocketSn: widget.item.pocketSn);
                      },
                      child: Container(
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
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  //종목명
                  Expanded(
                    child: Text(
                      widget.item.stockName,
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
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommonView.setFluctuationRateBox(value: widget.item.fluctuationRate, fontSize: 15,),
                  //등락률
                  /*Text(
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
                  ),*/
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            _setChartView(),
          ],
        ),
      ),
    );
  }

  Widget _setChartView() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 42,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            margin: EdgeInsets.all(
              1,
            ),
            primaryXAxis: const CategoryAxis(
              isVisible: false,
              rangePadding: ChartRangePadding.none,
              labelPlacement: LabelPlacement.onTicks,
            ),
            primaryYAxis: NumericAxis(
              //isVisible: false,
              labelStyle: TextStyle(
                fontSize: 0,
              ),
              axisLine: const AxisLine(
                width: 0,
              ),
              majorGridLines: const MajorGridLines(
                width: 0,
              ),
              majorTickLines: const MajorTickLines(
                width: 0,
              ),
              minorGridLines: const MinorGridLines(
                width: 0,
              ),
              minorTickLines: const MinorTickLines(
                width: 0,
              ),
              rangePadding: ChartRangePadding.none,
              edgeLabelPlacement: EdgeLabelPlacement.hide,
              plotOffset: 2,
              plotBands: [
                PlotBand(
                  isVisible: true,
                  start: int.parse(widget.item.listChart.first.tradePrc),
                  end: int.parse(widget.item.listChart.first.tradePrc),
                  color: Colors.black,
                  borderColor: Colors.black,
                  borderWidth: 1.4,
                  dashArray: const [3, 4],
                  shouldRenderAboveSeries: true,
                ),
              ],
            ),
            series: [
              SplineSeries<ChartData, String>(
                dataSource: widget.item.listChart,
                xValueMapper: (item, index) => item.tradeDate,
                yValueMapper: (item, index) => int.parse(item.tradePrc),
                color: _chartColor,
                width: 1.4,
                enableTooltip: false,
                animationDelay: 0,
                animationDuration: _animationDuration,
                onRendererCreated: (controller) => _chartController = controller,
              ),
            ],
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

  double get _findMaxTp {
    if (widget.item.listChart.isEmpty) {
      return 0;
    } else if (widget.item.listChart.length == 1) {
      return double.parse(widget.item.listChart[0].tradePrc);
    } else {
      var item = widget.item.listChart.reduce(
        (curr, next) => double.parse(curr.tradePrc) > double.parse(next.tradePrc) ? curr : next,
      );
      return double.parse(item.tradePrc);
    }
  }

  double get _findMinTp {
    if (widget.item.listChart.isEmpty) {
      return 0;
    } else if (widget.item.listChart.length == 1) {
      return double.parse(widget.item.listChart[0].tradePrc);
    } else {
      var item = widget.item.listChart.reduce(
        (curr, next) => double.parse(curr.tradePrc) > double.parse(next.tradePrc) ? next : curr,
      );
      return double.parse(item.tradePrc);
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (item.myTradeFlag == 'S') {
                      //나만의 매도신호는 나만의 매도 신호 탭으로 이동
                      basePageState.goPocketPage(
                        Const.PKT_INDEX_SIGNAL,
                      );
                    } else {
                      //매매신호는 나의포켓-매매신호 리스트로
                      basePageState.goPocketPage(
                        Const.PKT_INDEX_MY,
                        pktSn: item.pocketSn,
                        isSignalInfo: true,
                      );
                    }
                  },
                  child: Container(
                    decoration: UIStyle.boxRoundFullColor25c(
                      const Color(0xffDCDFE2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text(
                      item.myTradeFlag == 'S' ? '나만의 매도신호' : item.pocketName,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      //종목홈_ai매매신호탭
                      basePageState.goStockHomePage(
                        item.stockCode,
                        item.stockName,
                        Const.STK_INDEX_SIGNAL,
                      );
                    },
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
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser())
            _setSignalView()
          else if (Provider.of<UserInfoProvider>(context, listen: false).is3StockUser() && item.signalYn == 'Y')
            _setSignalView()
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

  _setSignalView() {
    return InkWell(
      onTap: () {
        if (item.myTradeFlag == 'S') {
          //나만의 매도신호는 나만의 매도 신호 탭으로 이동
          basePageState.goPocketPage(
            Const.PKT_INDEX_SIGNAL,
          );
        } else {
          //종목홈_ai매매신호탭
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
          const SizedBox(
            width: 10,
          ),
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
          Align(
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
                    const IssueViewer(), PgData(userId: '', pgSn: widget.item.newsSn, pgData: widget.item.issueSn));
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                //constraints: const BoxConstraints(maxWidth: 250),
                child: _relayStockView(context, widget.item.stockList.length),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _issueStatusView(String avgFluctRate) {
    double dValue = double.tryParse(avgFluctRate) ?? 0;
    return Row(
      children: [
        Text(
          '${dValue == 0 ? '보합' : dValue > 0 ? '상승중' : '하락중'} ',
          style: TextStyle(
            color: TStyle.getMinusPlusColor(avgFluctRate),
          ),
        ),
        const SizedBox(width: 4,),
        Text(
          TStyle.getPercentString(TStyle.getFixedNum(avgFluctRate)),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: TStyle.getMinusPlusColor(
                avgFluctRate,
            ),
          ),
        ),
      ],
    );

    if (avgFluctRate == '0' || avgFluctRate == '0.0' || avgFluctRate == '0.00') {
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
      children: List.generate(len, (index) => _relayStock(widget.item.stockList[index])),
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
              InkWell(
                onTap: () {
                  basePageState.goStockHomePage(
                    widget.item.stockCode,
                    widget.item.stockName,
                    Const.STK_INDEX_HOME,
                  );
                },
                child: Row(
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
              ),
              //포켓명
              InkWell(
                onTap: () {
                  basePageState.goPocketPage(
                    Const.PKT_INDEX_MY,
                    pktSn: widget.item.pocketSn,
                  );
                },
                child: Container(
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
              ),
            ],
          ),
          const SizedBox(
            height: 5,
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
              InkWell(
                onTap: () {
                  basePageState.goPocketPage(
                    Const.PKT_INDEX_MY,
                    pktSn: widget.item.pocketSn,
                  );
                },
                child: Container(
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
