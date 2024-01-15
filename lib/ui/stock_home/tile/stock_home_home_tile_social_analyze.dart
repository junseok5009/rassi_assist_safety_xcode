import 'dart:math';

import 'package:rassi_assist/custom_lib/charts_common/common.dart' as charts_common;
import 'package:rassi_assist/custom_lib/charts_flutter_new//flutter.dart' as charts;
import 'package:rassi_assist/custom_lib/charts_flutter_new//text_element.dart'
    as charts_text_element;
import 'package:rassi_assist/custom_lib/charts_flutter_new//text_style.dart' as charts_text_style;
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/user/naver_community_page.dart';

import '../../../../common/const.dart';
import '../../../../models/pg_data.dart';
import '../../../../models/tr_sns06.dart';
import '../../main/base_page.dart';
import '../../user/community_page.dart';
import '../page/recent_social_list_page.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_소셜분석

class StockHomeHomeTileSocialAnalyze extends StatelessWidget {
  StockHomeHomeTileSocialAnalyze(this.sns06, {Key? key}) : super(key: key);
  final AppGlobal appGlobal = AppGlobal();
  final Sns06 sns06;
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 원, true 이면 만원
  String _socialGrade = '';
  final List<SNS06ChartData> _listChartData = [];
  final List<charts.TickSpec<num>> _tickSpecList = [];
  final List<charts.Series<SNS06ChartData, int>> _seriesListData = [];
  final List<charts.RangeAnnotationSegment> _optionListBombData = [];
  final List<int> _optionListBombSoloData = [];
  final List<int> _optionListBombLastData = [];
  final _secondaryMeasureAxisId = 'secondaryMeasureAxisId';
  final String _socialPopupMsg =
      '라씨 매매비서는 메이저 증권 커뮤니티 참여 현황을 실시간으로 수집합니다.\n'
      '수집된 양을 이전기간과 비교하여 참여도의 증가와 감소를 수치화하여 참여 정도를 알려드립니다.\n'
      '커뮤니티 참여도가 높아지면 특별한 소식이 있을 수 있으니, 뉴스나 토론게시판을 꼭 확인해 보세요.';

  @override
  Widget build(BuildContext context) {
    if (sns06 == null || sns06.listPriceChart.isEmpty) {
      return const SizedBox();
    } else {
      _initListData();
      switch (sns06.concernGrade) {
        case '1':
          _socialGrade = '조용조용';
          break;
        case '2':
          _socialGrade = '수군수군';
          break;
        case '3':
          _socialGrade = '왁자지껄';
          break;
        case '4':
          _socialGrade = '폭발';
          break;
        default:
          _socialGrade = '';
      }
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
                            context, '소셜지수란?', _socialPopupMsg);
                      },
                      splashColor: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
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
                      child: Row(
                        children: const [
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
                        basePageState.callPageRouteData(
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
                          Text(
                            _socialGrade,
                            style: TStyle.title18T,
                          ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'N ',
                                style: TextStyle(
                                    color: RColor.naver,
                                    fontWeight: FontWeight.bold),
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
                            PgData(
                                stockCode: AppGlobal().stkCode,
                                stockName: AppGlobal().stkName),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'TP ',
                                style: TextStyle(
                                    color: RColor.mainColor,
                                    fontWeight: FontWeight.bold),
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

  Widget _setChart(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _isRightYAxisUpUnit ? '단위:만원' : '단위:원',
            style: const TextStyle(
              fontSize: 11,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: charts.LineChart(
            _seriesListData,
            animate: false,
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                lineStyle: const charts.LineStyleSpec(
                  color: charts.Color.transparent,
                ),
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
              ),
              tickProviderSpec: const charts.StaticNumericTickProviderSpec(
                [
                  charts.TickSpec<num>(0),
                  charts.TickSpec<num>(1),
                  charts.TickSpec<num>(2),
                  charts.TickSpec<num>(3),
                  charts.TickSpec<num>(4),
                  charts.TickSpec<num>(5),
                ],
              ),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec((measure) {
                if (measure == 1) {
                  return '조용조용';
                } else if (measure == 2) {
                  return '수군수군';
                } else if (measure == 3) {
                  return '왁자지껄';
                } else if (measure == 4) {
                  return '폭발';
                } else {
                  return '';
                }
              }),
            ),
            domainAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(
                _tickSpecList,
              ),
              renderSpec: charts.SmallTickRendererSpec(
                minimumPaddingBetweenLabelsPx: 30,
                labelOffsetFromTickPx: 20,
                labelOffsetFromAxisPx: 12,
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            secondaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                // desiredTickCount: 4,
                zeroBound: false,
              ),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec((measure) {
                if (_isRightYAxisUpUnit) {
                  return TStyle.getMoneyPoint((measure! / 10000).round().toString());
                }
                return TStyle.getMoneyPoint(measure!.round().toString());
              }),
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                lineStyle: charts.LineStyleSpec(
                  dashPattern: const [2, 2],
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            behaviors: [
              charts.RangeAnnotation(
                _optionListBombData.cast<charts_common.AnnotationSegment<Object>>(),
              ),
              charts.LinePointHighlighter(
                symbolRenderer: CustomCircleSymbolRenderer(
                    MediaQuery.of(context)
                        .size
                        .width), // add this line in behaviours
              ),
            ],
            selectionModels: [
              charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  int? selectIndex = model.selectedDatum[0].index;
                  CustomCircleSymbolRenderer.sns06chartData =
                      _listChartData[selectIndex!];
                }
              })
            ],
            //defaultRenderer: new charts.LineRendererConfig(),
            customSeriesRenderers: [
              charts.PointRendererConfig(
                // ID used to link series to this renderer.
                radiusPx: 1.6,
                strokeWidthPx: 1.6,
                customRendererId: 'customPoint',
              ),
              charts.LineRendererConfig(
                customRendererId: 'areaLine',
                includeArea: true,
                layoutPaintOrder: 30,
                strokeWidthPx: 1.5,
                //areaOpacity: 0.3,
                includeLine: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _initListData() {
    _seriesListData.clear();
    _optionListBombData.clear();
    _optionListBombSoloData.clear();
    _optionListBombLastData.clear();
    _listChartData.clear();
    _listChartData.addAll(sns06.listPriceChart);
    _isRightYAxisUpUnit = _findMinValue >= 100000;

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
              _optionListBombData.add(
                charts.RangeAnnotationSegment(isStartBombIndex, index,
                    charts.RangeAnnotationAxisType.domain,
                    middleLabel: '폭발',
                    labelStyleSpec: charts.TextStyleSpec(
                      color: charts.Color.fromHex(code: '#FF5050'),
                      fontSize: 11,
                    ),
                    labelPosition: charts.AnnotationLabelPosition.margin,
                    color: const charts.Color(r: 255, g: 80, b: 80, a: 35),
                    labelDirection: charts.AnnotationLabelDirection.horizontal),
              );
            }
          } else {
            if (isStartBomb) {
              isStartBomb = false;
              _optionListBombData.add(
                charts.RangeAnnotationSegment(isStartBombIndex, index - 1,
                    charts.RangeAnnotationAxisType.domain,
                    middleLabel: '폭발',
                    labelStyleSpec: charts.TextStyleSpec(
                      color: charts.Color.fromHex(code: '#FF5050'),
                      fontSize: 11,
                    ),
                    labelPosition: charts.AnnotationLabelPosition.margin,
                    color: const charts.Color(r: 255, g: 80, b: 80, a: 35),
                    labelDirection: charts.AnnotationLabelDirection.horizontal),
              );
            }
          }
        },
      );

      for (var element in _optionListBombData) {
        if (element.startValue == element.endValue)
          _optionListBombSoloData.add(element.startValue);
        else
          _optionListBombLastData.add(element.endValue);
      }

      _seriesListData.clear();
      _seriesListData.addAll([
        charts.Series<SNS06ChartData, int>(
          id: '주가(원)',
          colorFn: (_, __) => charts.Color.fromHex(code: '#454A63'),
          domainFn: (SNS06ChartData xAxisItem, _) => xAxisItem.index,
          measureFn: (SNS06ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
          data: _listChartData,
        )
          ..setAttribute(charts.measureAxisIdKey, _secondaryMeasureAxisId)
          ..setAttribute(charts.rendererIdKey, 'areaLine'),
        charts.Series<SNS06ChartData, int>(
          id: '소셜지수',
          colorFn: (v1, v2) {
            //DLog.w('v1 : $v1 / v2 : $v2');
            if (v1.cg == '4') {
              return charts.Color.fromHex(code: '#FA8383');
            } else {
              return charts.Color.fromHex(code: '#5DD68D');
            }
          },
          domainFn: (SNS06ChartData xAxisItem, _) => xAxisItem.index,
          measureFn: (SNS06ChartData yAxisItem, _) => int.parse(yAxisItem.cg),
          data: _listChartData,
        )..setAttribute(charts.rendererIdKey, 'customPoint'),
        charts.Series<SNS06ChartData, int>(
          id: '소셜지수',
          colorFn: (v1, v2) {
            if (v1.cg == '4') {
              if (_optionListBombSoloData.isNotEmpty &&
                  _optionListBombSoloData.contains(v2)) {
                return charts.Color.fromHex(code: '#5DD68D');
              } else if (_optionListBombLastData.isNotEmpty &&
                  _optionListBombLastData.contains(v2)) {
                return charts.Color.fromHex(code: '#5DD68D');
              } else
                return charts.Color.fromHex(code: '#FA8383');
            } else {
              return charts.Color.fromHex(code: '#5DD68D');
            }
          },
          domainFn: (SNS06ChartData xAxisItem, _) => xAxisItem.index,
          measureFn: (SNS06ChartData yAxisItem, _) => int.parse(yAxisItem.cg),
          data: _listChartData,
        ),
      ]);

      _tickSpecList.clear();
      _tickSpecList.addAll([
        charts.TickSpec(
          _listChartData[0].index,
          label: TStyle.getDateSlashFormat3(_listChartData[0].td),
        ),
        charts.TickSpec(
          _listChartData[(_listChartData.length ~/ 3)].index,
          label: TStyle.getDateSlashFormat3(
              _listChartData[_listChartData.length ~/ 3].td),
        ),
        charts.TickSpec(
          _listChartData[(_listChartData.length ~/ 3) * 2].index,
          label: TStyle.getDateSlashFormat3(
              _listChartData[(_listChartData.length ~/ 3) * 2].td),
        ),
        charts.TickSpec(
          _listChartData.last.index,
          label: TStyle.getDateSlashFormat3(_listChartData.last.td),
        ),
      ]);
    }
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
}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  final double deviceWidth;

  CustomCircleSymbolRenderer(this.deviceWidth);

  static late SNS06ChartData sns06chartData;
  bool _isShow = false;
  double xPoint = 0;

  @override
  void paint(charts_common.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    if (_isShow) {
      _isShow = false;
    } else {
      _isShow = true;

      double minWidth = bounds.width + 80;
      int cgLength = sns06chartData.cg.length;
      int tpLength = sns06chartData.tp.length;
      int maxLength = cgLength >= tpLength ? cgLength : tpLength;
      if (maxLength > 6) {
        minWidth += 5 * (maxLength - 6);
      }

      xPoint = (deviceWidth / 2) > bounds.left
          ? bounds.left + 12
          : bounds.left - minWidth - 4;

      canvas.drawRect(
        Rectangle(xPoint, 0, minWidth, bounds.height + 62),
        fill: charts.Color(
          r: 102,
          g: 102,
          b: 102,
          a: 200,
        ),
      );
      var textStyle = charts_text_style.TextStyle();
      textStyle.color = charts.Color.white;
      textStyle.fontSize = 12;

      String color = '#5DD68D';
      String strTp = '${TStyle.getMoneyPoint(sns06chartData.tp)}원';
      String strValue = sns06chartData.cg == '1'
          ? '조용조용'
          : sns06chartData.cg == '2'
              ? '수군수군'
              : sns06chartData.cg == '3'
                  ? '왁자지껄'
                  : '폭발';

      if (sns06chartData.cg == '4') {
        //color = '#FF5050';
        color = '#5DD68D';
      }

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
            TStyle.getDateSlashFormat3(sns06chartData.td),
            style: textStyle),
        (xPoint + 8).round(),
        12.round(),
      );

      canvas.drawPoint(
        point: Point(xPoint + 12, 34),
        radius: 4,
        fill: charts.Color.fromHex(code: color),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strValue, style: textStyle),
        (xPoint + 20).round(),
        29.round(),
      );

      canvas.drawPoint(
        point: Point(xPoint + 12, 54),
        radius: 4,
        fill: charts.Color.fromHex(code: '#454A63'),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strTp, style: textStyle),
        (xPoint + 20).round(),
        50.round(),
      );
    }
  }
}
