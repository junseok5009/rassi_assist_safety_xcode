import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/user/naver_community_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../common/const.dart';
import '../../../../models/pg_data.dart';
import '../../../../models/tr_sns06.dart';
import '../../main/base_page.dart';
import '../../user/community_page.dart';
import '../page/recent_social_list_page.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_소셜분석

class StockHomeHomeTileSocialAnalyze extends StatelessWidget {
  StockHomeHomeTileSocialAnalyze({required this.sns06, Key? key}) : super(key: key);
  final AppGlobal appGlobal = AppGlobal();
  final Sns06 sns06;
  final List<SNS06ChartData> _listChartData = [];
  final String _socialPopupMsg = '라씨 매매비서는 메이저 증권 커뮤니티 참여 현황을 실시간으로 수집합니다.\n'
      '수집된 양을 이전기간과 비교하여 참여도의 증가와 감소를 수치화하여 참여 정도를 알려드립니다.\n'
      '커뮤니티 참여도가 높아지면 특별한 소식이 있을 수 있으니, 뉴스나 토론게시판을 꼭 확인해 보세요.';

  late final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    lineDashArray: const [4, 3],
    shouldAlwaysShow: false,
    tooltipAlignment: ChartAlignment.near,
    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    activationMode: ActivationMode.singleTap,
    markerSettings: const TrackballMarkerSettings(
      markerVisibility: TrackballVisibilityMode.visible,
      borderWidth: 0,
      width: 0,
      height: 0,
    ),
    builder: (BuildContext context, TrackballDetails trackballDetails) {
      int selectedIndex = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 0),
              blurStyle: BlurStyle.outer,
            )
          ],
        ),
        child: FittedBox(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    TStyle.getDateSlashFormat1(_listChartData[selectedIndex].td),
                    style: const TextStyle(
                      fontSize: 11,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    //'xValue => ${_data[trackballDetails.pointIndex!].x.toString()}',
                    '${TStyle.getMoneyPoint(_listChartData[selectedIndex].tp)}원',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                _listChartData[selectedIndex].cg == '1'
                    ? '조용조용'
                    : _listChartData[selectedIndex].cg == '2'
                        ? '수군수군'
                        : _listChartData[selectedIndex].cg == '3'
                            ? '왁자지껄'
                            : '폭발',
                style: const TextStyle(
                  fontSize: 13,
                  //color: Color(0xffFBD240),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  final List<PlotBand> _listPlotBand = [];

  @override
  Widget build(BuildContext context) {
    _initListData();
    if (sns06.listPriceChart.isEmpty) {
      return const SizedBox();
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    InkWell(
                      onTap: () {
                        CommonPopup.instance.showDialogTitleMsg(
                          context,
                          '소셜지수란?',
                          _socialPopupMsg,
                        );
                      },
                      splashColor: Colors.transparent,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '소셜분석',
                            style: TStyle.title18T,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Icon(
                            Icons.info_outline,
                            color: RColor.new_basic_text_color_grey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      child: const Row(
                        children: [
                          Text(
                            '표로 보기 ',
                            style: TextStyle(
                              fontSize: 14,
                              color: RColor.new_basic_text_color_grey,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: Color(0xff919191),
                            size: 16,
                          ),
                        ],
                      ),
                      onTap: () {
                        // 종목 최근 소셜지수 페이지
                        basePageState.callPageRouteUpData(
                          const RecentSocialListPage(),
                          PgData(
                            stockName: appGlobal.stkName,
                            stockCode: appGlobal.stkCode,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: UIStyle.boxNewBasicGrey10(),
                  child: Column(
                    children: [
                      const Text(
                        '커뮤니티 참여도',
                        style: TextStyle(
                          color: RColor.new_basic_text_color_strong_grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Container(
                            //margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              '${sns06.concernGrade}단계',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          _getConcernGradeText,
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (sns06.listPriceChart.isNotEmpty) _setChart(context),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xff5DD68D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      '  소셜지수',
                      style: TextStyle(
                        fontSize: 11,
                        color: RColor.new_basic_text_color_grey,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0x33ff5050),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      '  소셜지수(폭발)',
                      style: TextStyle(
                        fontSize: 11,
                        color: RColor.new_basic_text_color_grey,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      //color: Color(0xff6565FF),
                      decoration: const BoxDecoration(
                        color: RColor.chartTradePriceColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      '  주가',
                      style: TextStyle(
                        fontSize: 11,
                        color: RColor.new_basic_text_color_grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: UIStyle.boxRoundLine6(),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'N ',
                                style: TextStyle(color: RColor.naver, fontWeight: FontWeight.bold),
                              ),
                              Flexible(
                                child: Text(
                                  '토론 바로가기',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          basePageState.callPageRouteUpData(
                            NaverCommunityPage(),
                            PgData(stockCode: AppGlobal().stkCode, stockName: AppGlobal().stkName),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: UIStyle.boxRoundLine6(),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'TP ',
                                style: TextStyle(color: RColor.mainColor, fontWeight: FontWeight.bold),
                              ),
                              Flexible(
                                child: Text(
                                  '토론 바로가기',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          basePageState.callPageRouteUpData(
                            CommunityPage(),
                            PgData(
                                userId: AppGlobal().userId,
                                stockCode: AppGlobal().stkCode,
                                stockName: AppGlobal().stkName),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Container(
            color: RColor.new_basic_grey,
            height: 15.0,
          ),
        ],
      );
    }
  }

  Widget get _getConcernGradeText {
    String textValue = '';
    switch (sns06.concernGrade) {
      case '1':
        textValue = '조용조용';
        break;
      case '2':
        textValue = '수군수군';
        break;
      case '3':
        textValue = '왁자지껄';
        break;
      case '4':
        textValue = '폭발';
        break;
      default:
        textValue = '';
    }
    return Text(
      textValue,
      style: TStyle.title18T,
    );
  }

  Widget _setChart(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _findMinValue >= 100000 ? '단위:만원' : '단위:원',
            style: const TextStyle(
              fontSize: 11,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 240,
          margin: const EdgeInsets.only(
            top: 5,
          ),
          //color: Colors.amber,
          child: SfCartesianChart(
            enableAxisAnimation: true,
            plotAreaBorderWidth: 1,
            margin: EdgeInsets.zero,
            primaryXAxis: CategoryAxis(
              plotBands: _listPlotBand,
              axisLine: const AxisLine(
                width: 1.2,
                color: RColor.chartGreyColor,
              ),
              majorGridLines: const MajorGridLines(
                width: 0,
              ),
              majorTickLines: const MajorTickLines(
                width: 0,
              ),
              desiredIntervals: 3,
              labelPlacement: LabelPlacement.onTicks,
              axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                TStyle.getDateSlashFormat3(axisLabelRenderArgs.text),
                const TextStyle(
                  fontSize: 12,
                  color: RColor.greyBasic_8c8c8c,
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 5,
              axisLine: const AxisLine(
                color: Colors.white,
              ),
              axisLabelFormatter: (axisLabelRenderArgs) {
                return ChartAxisLabel(
                  axisLabelRenderArgs.value % 5 == 0
                      ? ''
                      : axisLabelRenderArgs.value == 1
                          ? '조용조용'
                          : axisLabelRenderArgs.value == 2
                              ? '수군수군'
                              : axisLabelRenderArgs.value == 3
                                  ? '왁자지껄'
                                  : '폭발',
                  const TextStyle(
                    fontSize: 13,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                );
              },
              majorGridLines: const MajorGridLines(
                width: 0,
              ),
              majorTickLines: const MajorTickLines(
                width: 0,
              ),
              minorTickLines: const MinorTickLines(
                width: 0,
              ),
            ),
            axes: <ChartAxis>[
              NumericAxis(
                name: 'yAxis',
                opposedPosition: true,
                anchorRangeToVisiblePoints: true,
                axisLine: const AxisLine(
                  width: 0,
                ),
                majorGridLines: const MajorGridLines(
                  color: RColor.chartGreyColor,
                  width: 0.6,
                  dashArray: [2, 2],
                ),
                majorTickLines: const MajorTickLines(
                  width: 0,
                ),
                rangePadding: ChartRangePadding.round,
                interval: _getInterval,
                axisLabelFormatter: (axisLabelRenderArgs) {
                  String value = axisLabelRenderArgs.text;
                  if (_findMinValue >= 100000) {
                    value = TStyle.getMoneyPoint((axisLabelRenderArgs.value / 10000).round().toString());
                  } else {
                    value = TStyle.getMoneyPoint(axisLabelRenderArgs.value.round().toString());
                  }
                  return ChartAxisLabel(
                    value,
                    const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  );
                },
              )
            ],
            trackballBehavior: _trackballBehavior,
            tooltipBehavior: TooltipBehavior(),
            series: [
              //SplineRangeAreaSeries
              AreaSeries<SNS06ChartData, String>(
                dataSource: _listChartData,
                xValueMapper: (item, index) => item.td,
                yValueMapper: (item, index) => int.parse(item.tp),
                //lowValueMapper: (SNS06ChartData item, _) => 0,
                //highValueMapper: (SNS06ChartData item, _) => int.parse(item.tp),
                yAxisName: 'yAxis',
                color: RColor.chartTradePriceColor.withOpacity(0.08),
                borderWidth: 1.4,
                borderColor: RColor.chartTradePriceColor,
                enableTooltip: true,
              ),
              LineSeries<SNS06ChartData, String>(
                dataSource: _listChartData,
                xValueMapper: (item, index) => item.td,
                yValueMapper: (item, index) => int.parse(item.cg),
                enableTooltip: false,
                pointColorMapper: (item, index) {
                  if ((int.tryParse(item.cg) ?? 0) == 4) {
                    return RColor.chartPink;
                  } else {
                    return RColor.chartGreen;
                  }
                },
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  width: 4,
                  height: 4,
                  //color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _initListData() {
    _listChartData.clear();
    _listChartData.addAll(sns06.listPriceChart);

    bool isStartBomb = false;
    int isStartBombIndex = 0;

    if (sns06.listPriceChart.isNotEmpty) {
      if (sns06.listPriceChart[0].cg == '4') {
        isStartBomb = true;
      } else {
        isStartBomb = false;
      }
      _listChartData.asMap().forEach(
        (index, item) {
          if (item.cg == '4') {
            if (!isStartBomb) {
              // 폭발 시작 index
              isStartBomb = true;
              isStartBombIndex = index;
            } else if (isStartBomb && index == _listChartData.length - 1) {
              _listPlotBand.add(
                PlotBand(
                  isVisible: true,
                  text: '폭발',
                  textAngle: 0,
                  verticalTextAlignment: TextAnchor.start,
                  verticalTextPadding: '0%',
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: RColor.chartRed1,
                  ),
                  start: isStartBombIndex,
                  end: index,
                  opacity: 0.55,
                  color: RColor.chartRed2,
                ),
              );
            }
          } else {
            if (isStartBomb) {
              isStartBomb = false;
              _listPlotBand.add(
                PlotBand(
                  isVisible: true,
                  text: '폭발',
                  textAngle: 0,
                  verticalTextAlignment: TextAnchor.start,
                  verticalTextPadding: '0%',
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: RColor.chartRed1,
                  ),
                  start: isStartBombIndex,
                  end: index - 1,
                  opacity: 0.55,
                  color: RColor.chartRed2,
                ),
              );
            }
          }
        },
      );
    }
  }

  double get _getInterval {
    double minValue = _findMinValue;
    double maxValue = _findMaxValue;
    // 최솟값과 최댓값을 이용하여 적절한 간격 계산

    if (_findMinValue == _findMaxValue) return _findMaxValue * 2;

    DLog.e('minValue : $minValue / maxValue : $maxValue');

    double range = maxValue - minValue;
    double interval = range / 4; // 예시로 5개의 간격으로 나눔
    double roundedInterval =
        //pow(10, (log(interval) / log(10)).floor()).toDouble();
        pow(10, (log(interval) / log(10))).toDouble();
    return (roundedInterval * ((range / 4) / roundedInterval).ceil()).toDouble();
  }

  double get _findMinValue {
    if (_listChartData.length < 2) {
      return 0;
    }
    var item = _listChartData.reduce((curr, next) => double.parse(curr.tp) == 0
        ? next
        : double.parse(next.tp) == 0
            ? curr
            : double.parse(curr.tp) < double.parse(next.tp)
                ? curr
                : next);
    return double.parse(item.tp);
  }

  double _getFindMinValue() {
    if (_listChartData.length < 2) {
      return 0;
    }
    var item = _listChartData.reduce((curr, next) => double.parse(curr.tp) == 0
        ? next
        : double.parse(next.tp) == 0
            ? curr
            : double.parse(curr.tp) < double.parse(next.tp)
                ? curr
                : next);
    return double.parse(item.tp);
  }

  double get _findMaxValue {
    if (_listChartData.length == 2) {
      return double.tryParse(_listChartData[0].tp) ?? 0;
    }
    var item = _listChartData.reduce(
      (curr, next) => double.parse(curr.tp) == 0
          ? next
          : double.parse(next.tp) == 0
              ? curr
              : double.parse(curr.tp) < double.parse(next.tp)
                  ? next
                  : curr,
    );
    return double.parse(item.tp);
  }
}
