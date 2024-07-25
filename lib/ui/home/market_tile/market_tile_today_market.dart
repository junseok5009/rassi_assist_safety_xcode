import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_index/tr_index02.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_최상단 메인 이벤트 차트

class MarketTileTodayMarket extends StatelessWidget {
  static String TAG = 'MarketTileTodayMarket';

  const MarketTileTodayMarket({super.key, required this.index02});

  final Index02 index02;

  @override
  Widget build(BuildContext context) {
    double beforeTiKospi = double.parse(index02.kospi.priceIndex) - double.parse(index02.kospi.indexFluctuation);
    double beforeTiKosdaq = double.parse(index02.kosdaq.priceIndex) - double.parse(index02.kosdaq.indexFluctuation);
    double maxTiKospi = _findMaxTiChartData(isKospi: true);
    double maxTiKosdaq = _findMaxTiChartData(isKospi: false);
    double minTiKospi = _findMinTiChartData(isKospi: true);
    double minTiKosdaq = _findMinTiChartData(isKospi: false);

    return Container(
      width: double.infinity,
      height: 240,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: UIStyle.boxShadowBasic(20),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '코스피',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: UIStyle.boxRoundFullColor25c(
                          index02.marketTimeDiv == 'O' ? Colors.black : const Color(0xffABB0BB),
                        ),
                        child: Text(
                          index02.marketTimeDiv == 'B'
                              ? '예상'
                              : index02.marketTimeDiv == 'O'
                                  ? '장중'
                                  : index02.marketTimeDiv == 'C'
                                      ? '장마감'
                                      : '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 110,
                        //color: Colors.green,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          margin: EdgeInsets.zero,
                          primaryXAxis: const CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                            borderWidth: 0,
                            axisLine: AxisLine(width: 0),
                            majorGridLines: MajorGridLines(width: 0),
                            majorTickLines: MajorTickLines(
                              width: 0,
                            ),
                            plotOffset: 0,
                            labelStyle: TextStyle(
                              fontSize: 0,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            borderWidth: 0,
                            axisLine: const AxisLine(
                              width: 0,
                            ),
                            majorTickLines: const MajorTickLines(
                              width: 0,
                            ),
                            opposedPosition: true,
                            rangePadding: ChartRangePadding.none,
                            majorGridLines: const MajorGridLines(width: 0),
                            plotOffset: 2,
                            labelStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            decimalPlaces: 0,
                            isVisible: index02.marketTimeDiv != 'B',
                            minimum: index02.marketTimeDiv == 'B'
                                ? 0
                                : minTiKospi > beforeTiKospi
                                    ? beforeTiKospi
                                    : minTiKospi,
                            maximum: index02.marketTimeDiv == 'B'
                                ? 2
                                : maxTiKospi > beforeTiKospi
                                    ? maxTiKospi
                                    : beforeTiKospi,
                            plotBands: [
                              if (index02.marketTimeDiv != 'B')
                                PlotBand(
                                  isVisible: true,
                                  start: beforeTiKospi,
                                  end: beforeTiKospi,
                                  borderColor: RColor.greyMore_999999,
                                  borderWidth: 1.4,
                                  dashArray: const [3, 4],
                                  shouldRenderAboveSeries: true,
                                ),
                            ],
                          ),
                          enableAxisAnimation: false,
                          onMarkerRender: (markerArgs) {
                            if (index02.marketTimeDiv == 'B') {
                              markerArgs.markerWidth = 6;
                              markerArgs.markerHeight = 6;
                              markerArgs.color = RColor.grey_abb0bb;
                            } else {
                              int lastTpItemIndex = index02.kospi.listKosChart.indexWhere(
                                    (element) => element.ti.isEmpty,
                                  ) -
                                  1;
                              if (markerArgs.pointIndex == 0 ||
                                  (lastTpItemIndex > 0 && lastTpItemIndex == markerArgs.pointIndex) ||
                                  (lastTpItemIndex < 0 &&
                                      markerArgs.pointIndex == index02.kospi.listKosChart.length - 1)) {
                                markerArgs.markerWidth = 6;
                                markerArgs.markerHeight = 6;
                                markerArgs.color = index02.kospi.fluctuationRate.contains('-')
                                    ? const Color(0xff9eb3ff)
                                    : const Color(0xffFF9090);
                                markerArgs.shape = DataMarkerType.circle;
                              } else {
                                markerArgs.markerWidth = 0;
                                markerArgs.markerHeight = 0;
                              }
                            }
                          },
                          series: [
                            if (index02.marketTimeDiv == 'B')
                              LineSeries<int, int>(
                                dataSource: const [0, 1],
                                xValueMapper: (item, index) => index,
                                yValueMapper: (item, index) => 1,
                                color: RColor.grey_abb0bb,
                                markerSettings: const MarkerSettings(
                                  isVisible: true,
                                  color: RColor.grey_abb0bb,
                                  width: 0,
                                  height: 0,
                                  borderWidth: 0,
                                  shape: DataMarkerType.circle,
                                ),
                                dashArray: const [2, 4],
                                animationDuration: 1500,
                              )
                            else
                              AreaSeries<Index02KosChart, String>(
                                dataSource: index02.kospi.listKosChart,
                                xValueMapper: (item, index) => item.tt,
                                yValueMapper: (item, index) => double.tryParse(item.ti),
                                borderWidth: 1,
                                borderColor: index02.kospi.fluctuationRate.contains('-')
                                    ? const Color(0xff9eb3ff)
                                    : const Color(0xffFF9090),
                                gradient: LinearGradient(
                                  colors: [
                                    if (index02.kospi.fluctuationRate.contains('-'))
                                      const Color(0xffb4c3fa).withOpacity(0.4)
                                    else
                                      const Color(0xffeea0a0).withOpacity(0.4),
                                    const Color(0xffffffff),
                                  ],
                                  stops: const [
                                    0,
                                    1,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  color: index02.kospi.fluctuationRate.contains('-')
                                      ? const Color(0xff9eb3ff)
                                      : const Color(0xffFF9090),
                                  width: 0,
                                  height: 0,
                                  borderWidth: 0,
                                  shape: DataMarkerType.circle,
                                ),
                                borderDrawMode: BorderDrawMode.top,
                                animationDuration: 1500,
                                onRendererCreated: (ChartSeriesController controller) {
                                  SchedulerBinding.instance.addPostFrameCallback((_) {
                                    controller.isVisible = true;
                                    controller.animate();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    TStyle.getMoneyPoint(
                      index02.kospi.priceIndex,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        TStyle.getTriangleStringWithMoneyPoint(index02.kospi.indexFluctuation),
                        style: TextStyle(
                          //fontSize: 14,
                          color: TStyle.getMinusPlusColor(index02.kospi.fluctuationRate),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        TStyle.getPercentString(
                          index02.kospi.fluctuationRate,
                        ),
                        style: TextStyle(
                          //fontSize: 12,
                          color: TStyle.getMinusPlusColor(index02.kospi.fluctuationRate),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: UIStyle.boxShadowBasic(20),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '코스닥',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: UIStyle.boxRoundFullColor25c(
                          index02.marketTimeDiv == 'O' ? Colors.black : RColor.grey_abb0bb,
                        ),
                        child: Text(
                          index02.marketTimeDiv == 'B'
                              ? '예상'
                              : index02.marketTimeDiv == 'O'
                                  ? '장중'
                                  : index02.marketTimeDiv == 'C'
                                      ? '장마감'
                                      : '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 110,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          margin: EdgeInsets.zero,
                          primaryXAxis: const CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                            borderWidth: 0,
                            axisLine: AxisLine(width: 0),
                            majorGridLines: MajorGridLines(width: 0),
                            majorTickLines: MajorTickLines(
                              width: 0,
                            ),
                            plotOffset: 0,
                            labelStyle: TextStyle(
                              fontSize: 0,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(
                              width: 0,
                            ),
                            majorTickLines: const MajorTickLines(
                              width: 0,
                            ),
                            opposedPosition: true,
                            rangePadding: ChartRangePadding.none,
                            majorGridLines: const MajorGridLines(width: 0),
                            plotOffset: 2,
                            labelStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            decimalPlaces: 0,
                            isVisible: index02.marketTimeDiv != 'B',
                            minimum: index02.marketTimeDiv == 'B'
                                ? 0
                                : minTiKosdaq > beforeTiKosdaq
                                    ? beforeTiKosdaq
                                    : minTiKosdaq,
                            maximum: index02.marketTimeDiv == 'B'
                                ? 2
                                : maxTiKosdaq > beforeTiKosdaq
                                    ? maxTiKosdaq
                                    : beforeTiKosdaq,
                            plotBands: [
                              if (index02.marketTimeDiv != 'B')
                                PlotBand(
                                  isVisible: true,
                                  start: beforeTiKosdaq,
                                  end: beforeTiKosdaq,
                                  borderColor: RColor.greyMore_999999,
                                  borderWidth: 1.4,
                                  dashArray: const [3, 4],
                                  shouldRenderAboveSeries: true,
                                ),
                            ],
                          ),
                          enableAxisAnimation: false,
                          onMarkerRender: (markerArgs) {
                            if (index02.marketTimeDiv == 'B') {
                              markerArgs.markerWidth = 6;
                              markerArgs.markerHeight = 6;
                              markerArgs.color = RColor.grey_abb0bb;
                              //markerArgs.shape = DataMarkerType.circle;
                            } else {
                              int lastTpItemIndex = index02.kosdaq.listKosChart.indexWhere(
                                    (element) => element.ti.isEmpty,
                                  ) -
                                  1;
                              if (markerArgs.pointIndex == 0 ||
                                  (lastTpItemIndex > 0 && lastTpItemIndex == markerArgs.pointIndex) ||
                                  (lastTpItemIndex < 0 &&
                                      markerArgs.pointIndex == index02.kosdaq.listKosChart.length - 1)) {
                                markerArgs.markerWidth = 6;
                                markerArgs.markerHeight = 6;
                                markerArgs.color = index02.kosdaq.fluctuationRate.contains('-')
                                    ? const Color(0xff9eb3ff)
                                    : const Color(0xffFF9090);
                                //markerArgs.shape = DataMarkerType.circle;
                              } else {
                                markerArgs.markerWidth = 0;
                                markerArgs.markerHeight = 0;
                              }
                            }
                          },
                          series: [
                            if (index02.marketTimeDiv == 'B')
                              LineSeries<int, int>(
                                dataSource: const [0, 1],
                                xValueMapper: (item, index) => index,
                                yValueMapper: (item, index) => 1,
                                color: RColor.grey_abb0bb,
                                markerSettings: const MarkerSettings(
                                  isVisible: true,
                                  color: RColor.grey_abb0bb,
                                  width: 0,
                                  height: 0,
                                  borderWidth: 0,
                                  shape: DataMarkerType.circle,
                                ),
                                dashArray: const [2, 4],
                                animationDuration: 1500,
                              )
                            else
                              AreaSeries<Index02KosChart, String>(
                                dataSource: index02.kosdaq.listKosChart,
                                xValueMapper: (item, index) => item.tt,
                                yValueMapper: (item, index) => double.tryParse(item.ti),
                                borderWidth: 1,
                                borderColor: index02.kosdaq.fluctuationRate.contains('-')
                                    ? const Color(0xff9eb3ff)
                                    : const Color(0xffFF9090),
                                gradient: LinearGradient(
                                  colors: [
                                    if (index02.kosdaq.fluctuationRate.contains('-'))
                                      const Color(0xffb4c3fa).withOpacity(0.4)
                                    else
                                      const Color(0xffeea0a0).withOpacity(0.4),
                                    const Color(0xffffffff),
                                  ],
                                  stops: const [
                                    0,
                                    1,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  color: index02.kosdaq.fluctuationRate.contains('-')
                                      ? const Color(0xff9eb3ff)
                                      : const Color(0xffFF9090),
                                  width: 0,
                                  height: 0,
                                  borderWidth: 0,
                                  shape: DataMarkerType.circle,
                                ),
                                borderDrawMode: BorderDrawMode.top,
                                animationDuration: 1500,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    TStyle.getMoneyPoint(
                      index02.kosdaq.priceIndex,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        TStyle.getTriangleStringWithMoneyPoint(index02.kosdaq.indexFluctuation),
                        style: TextStyle(
                          //fontSize: 14,
                          color: TStyle.getMinusPlusColor(index02.kosdaq.fluctuationRate),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        TStyle.getPercentString(
                          index02.kosdaq.fluctuationRate,
                        ),
                        style: TextStyle(
                          //fontSize: 12,
                          color: TStyle.getMinusPlusColor(index02.kosdaq.fluctuationRate),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _findMaxTiChartData({required bool isKospi}) {
    List<Index02KosChart> listKosChart = [];
    if (isKospi) {
      listKosChart = index02.kospi.listKosChart;
    } else {
      listKosChart = index02.kosdaq.listKosChart;
    }
    final nonNullList = listKosChart.where((data) => double.tryParse(data.ti) != null).toList();
    if (nonNullList.isEmpty) {
      return -1;
    } else if (nonNullList.length == 1) {
      return 0;
    } else {
      Index02KosChart data = nonNullList.reduce(
        (curr, next) => (double.tryParse(curr.ti) ?? 0) > (double.tryParse(next.ti) ?? 0) ? curr : next,
      );
      return double.parse(data.ti);
    }
  }

  double _findMinTiChartData({required bool isKospi}) {
    List<Index02KosChart> listKosChart = [];
    if (isKospi) {
      listKosChart = index02.kospi.listKosChart;
    } else {
      listKosChart = index02.kosdaq.listKosChart;
    }
    final nonNullList = listKosChart.where((data) => double.tryParse(data.ti) != null).toList();
    if (nonNullList.isEmpty) {
      return -1;
    } else if (nonNullList.length == 1) {
      return 0;
    } else {
      Index02KosChart data = nonNullList.reduce(
        (curr, next) => (double.tryParse(curr.ti) ?? 0) > (double.tryParse(next.ti) ?? 0) ? next : curr,
      );
      return double.parse(data.ti);
    }
  }
}
