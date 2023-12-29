import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:charts_common/common.dart' as charts_common;
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:charts_flutter_new/src/text_element.dart'
    as charts_text_element;
import 'package:charts_flutter_new/src/text_style.dart' as charts_text_style;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/tr_report01.dart';

import '../../../common/const.dart';
import '../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';


/// 2023.02.21_HJS
/// 종목홈(개편)_홈_리포트분석_목표가
class ReportAnalyzeChart1Page extends StatefulWidget {
  //const ReportAnalyzeChart1Page({Key? key}) : super(key: key);
  static final GlobalKey<_ReportAnalyzeChart1PageState> globalKey = GlobalKey();

  ReportAnalyzeChart1Page() : super(key: globalKey);

  @override
  State<ReportAnalyzeChart1Page> createState() =>
      _ReportAnalyzeChart1PageState();
}

class _ReportAnalyzeChart1PageState extends State<ReportAnalyzeChart1Page> {
  //with AutomaticKeepAliveClientMixin<ReportAnalyzeChart1Page> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  bool _is6Month = true;
  String _isNoData = '';

  Report01 _report01 = defReport01;
  List<charts.Series<Report01ChartData, int>> _seriesList = [];
  final List<Report01ChartData> _listData = [];
  List<charts.TickSpec<num>> _tickSpecList = [];

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _is6Month = true;
    _requestTrReport01();
  }

  /*@override
  bool get wantKeepAlive => true;*/

  @override
  void initState() {
    super.initState();
    _requestTrReport01();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    if (_isNoData == 'Y' || _isNoData == 'N') {
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: _is6Month
                    ? UIStyle.boxNewSelectBtn1()
                    : UIStyle.boxNewUnSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '6개월',
                      style: TextStyle(
                        color: _is6Month
                            ? Colors.black
                            : RColor.btnUnSelectGreyText,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (!_is6Month) {
                        setState(() {
                          _is6Month = true;
                          _requestTrReport01();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: _is6Month
                    ? UIStyle.boxNewUnSelectBtn1()
                    : UIStyle.boxNewSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '1년',
                      style: TextStyle(
                        color: _is6Month
                            ? RColor.btnUnSelectGreyText
                            : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (_is6Month) {
                        setState(
                          () {
                            _is6Month = false;
                            _requestTrReport01();
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          _isNoData == 'Y' ? _setNoDataView() : _setDataView(),
        ],
      );
    } else {
      return const SizedBox(height: 100,);
    }
  }

  _initChartData() {
    _isRightYAxisUpUnit = _findMinValue >= 100000;
    _seriesList = [
      charts.Series<Report01ChartData, int>(
        id: '전체 증권사 목표주가 평균값',
        colorFn: (v1, __) {
          if (v1.agp == '0') {
            return charts.Color.fromHex(code: '#FF5050');
          } else {
            return charts.Color.fromHex(code: '#5DD68D');
          }
        },
        domainFn: (Report01ChartData xAxisItem, _) => xAxisItem.index!,
        measureFn: (Report01ChartData yAxisItem, _) =>
            yAxisItem.agp.isEmpty ? null : int.parse(yAxisItem.agp),
        data: _listData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
      charts.Series<Report01ChartData, int>(
        id: '주가',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Report01ChartData xAxisItem, _) => xAxisItem.index!,
        measureFn: (Report01ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
        data: _listData,
      )
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId')
        ..setAttribute(charts.rendererIdKey, 'areaLine'),
    ];
    _tickSpecList = [
      charts.TickSpec(
        _listData[0].index as num,
        label: TStyle.getDateSlashFormat3(_listData[0].td),
      ),
      charts.TickSpec(
        _listData[(_listData.length ~/ 3)].index as num,
        label: TStyle.getDateSlashFormat3(_listData[_listData.length ~/ 3].td),
      ),
      charts.TickSpec(
        _listData[(_listData.length ~/ 3) * 2].index as num,
        label: TStyle.getDateSlashFormat3(_listData[(_listData.length ~/ 3) * 2].td),
      ),
      charts.TickSpec(
        _listData.last.index as num,
        label: TStyle.getDateSlashFormat3(_listData.last.td),
      ),
    ];
    setState(() {});
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: RColor.new_basic_text_color_grey,
              ),
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                    fontSize: 18,
                    color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Text(
            '발행된 리포트가 없습니다.',
            style: TextStyle(
                fontSize: 14, color: RColor.new_basic_text_color_grey),
          ),
        ],
      ),
    );
  }

  Widget _setDataView() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
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
        Container(
          height: 240,
          color: Colors.transparent,
          child: charts.LineChart(
            _seriesList,
            animate: true,
            primaryMeasureAxis: const charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                zeroBound: false,
              ),
              renderSpec: charts.NoneRenderSpec(),
            ),
            secondaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                zeroBound: false,
              ),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec((measure) {
                if (_isRightYAxisUpUnit) {
                  return TStyle.getMoneyPoint((measure! / 10000).round().toString());
                  //return '$measure';
                }
                //return '$measure';
                return TStyle.getMoneyPoint(measure!.round().toString());
              }),
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                lineStyle: charts.LineStyleSpec(
                  dashPattern: [2, 2],
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            domainAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(
                _tickSpecList,
              ),
              renderSpec: charts.SmallTickRendererSpec(
                minimumPaddingBetweenLabelsPx: 30,
                labelOffsetFromTickPx: 20,
                labelOffsetFromAxisPx: 12,
                // Tick and Label styling here.
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                // Change the line colors to match text color.
                lineStyle: charts.LineStyleSpec(
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            customSeriesRenderers: [
              charts.LineRendererConfig(
                customRendererId: 'areaLine',
                includeArea: true,
                stacked: true,
                layoutPaintOrder: 1,
                strokeWidthPx: 1.5,
              ),
            ],
            behaviors: [
              charts.LinePointHighlighter(
                symbolRenderer: CustomCircleSymbolRenderer(
                  MediaQuery.of(context).size.width,
                ), // add this line in behaviours
              ),
            ],
            selectionModels: [
              charts.SelectionModelConfig(
                changedListener: (charts.SelectionModel model) {
                  if (model.hasDatumSelection) {
                    int? selectIndex = model.selectedDatum[0].index;
                    if(selectIndex != null) {
                      CustomCircleSymbolRenderer.report01chartData = _listData[selectIndex];
                    }
                  }
                },
              ),
            ],
          ),
        ),
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
              //color: Color(0xffFF5050),
              decoration: const BoxDecoration(
                color: Color(0xff5DD68D),
                shape: BoxShape.circle,
              ),
            ),
            //const SizedBox(width: 4,),
            const Text(
              '  목표가',
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
          height: 15,
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          decoration: UIStyle.boxNewBasicGrey10(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '목표가 대비 현재가',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report01.priceComp}%',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '목표가 평균',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${TStyle.getMoneyPoint(_report01.priceAvg)}',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최고',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${TStyle.getMoneyPoint(_report01.priceMax)}',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최저',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${TStyle.getMoneyPoint(_report01.priceMin)}',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  _requestTrReport01() {
    _fetchPosts(
      TR.REPORT01,
      jsonEncode(
        <String, String>{
          'userId': _appGlobal.userId,
          'stockCode': _appGlobal.stkCode,
          'selectDiv': _is6Month ? 'M6' : 'Y1',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.REPORT01) {
      _report01 = defReport01;
      _seriesList.clear();
      _listData.clear();
      _tickSpecList.clear();
      final TrReport01 resData = TrReport01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _report01 = resData.retData;
        if (_report01.priceAvg.isEmpty ||
            _report01.priceMin.isEmpty ||
            _report01.priceMax.isEmpty) {
          setState(() {
            _isNoData = 'Y';
          });
        } else {
          if (_report01.listChartData.length > 0) {
            _listData.addAll(_report01.listChartData);
            _isNoData = 'N';
            _initChartData();
          } else {
            setState(() {
              _isNoData = 'Y';
            });
          }
        }
      } else {
        setState(() {
          _isNoData = 'Y';
        });
      }
    }
  }

  double get _findMinValue {
    if (_listData.length < 2) {
      return 0;
    }

    var item = _listData.reduce((curr, next) {
      if (curr.agp.isEmpty) {
        return next;
      } else if (next.agp.isEmpty) {
        return curr;
      } else if (double.parse(curr.agp) <= double.parse(next.agp)) {
        return curr;
      } else {
        return next;
      }
    });
    return double.parse(item.agp);
  }
}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  final double deviceWidth;

  CustomCircleSymbolRenderer(this.deviceWidth);

  static late Report01ChartData report01chartData;
  bool _isShow = false;
  double xPoint = 0;

  @override
  void paint(charts_common.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx}
      ){
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
      int tpLength = report01chartData.tp.length;
      int agpLength =
          report01chartData.agp.isEmpty ? 0 : report01chartData.agp.length;
      int maxLength = tpLength >= agpLength ? tpLength : agpLength;
      if (maxLength > 6) minWidth += 5 * (maxLength - 6);

      xPoint = (deviceWidth / 2) > bounds.left
          ? bounds.left + 12
          : bounds.left - minWidth - 4;

      canvas.drawRect(
        Rectangle(
            xPoint,
            0,
            minWidth,
            report01chartData.agp.isEmpty
                ? bounds.height + 42
                : bounds.height + 62),
        fill: const charts.Color(
          r: 102,
          g: 102,
          b: 102,
          a: 200,
        ),
      );
      var textStyle = charts_text_style.TextStyle();
      textStyle.color = charts.Color.white;
      textStyle.fontSize = 12;

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
          TStyle.getDateSlashFormat3(report01chartData.td),
          style: textStyle,
        ),
        (xPoint + 8).round(),
        12.round(),
      );

      if (report01chartData.agp.isEmpty) {
        canvas.drawPoint(
          point: Point(xPoint + 12, 34),
          radius: 4,
          fill: charts.Color.fromHex(code: '#454A63'),
          stroke: charts.Color.white,
          strokeWidthPx: 1,
        );
        canvas.drawText(
          charts_text_element.TextElement(
            '${TStyle.getMoneyPoint(report01chartData.tp)}원',
            style: textStyle,
          ),
          (xPoint + 20).round(),
          30.round(),
        );
      } else {
        canvas.drawPoint(
          point: Point(xPoint + 12, 34),
          radius: 4,
          fill: charts.Color.fromHex(code: '#5DD68D'),
          stroke: charts.Color.white,
          strokeWidthPx: 1,
        );
        canvas.drawText(
          charts_text_element.TextElement(
            '${TStyle.getMoneyPoint(report01chartData.agp)}원',
            style: textStyle,
          ),
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
          charts_text_element.TextElement(
            '${TStyle.getMoneyPoint(report01chartData.tp)}원',
            style: textStyle,
          ),
          (xPoint + 20).round(),
          50.round(),
        );
      }
    }
  }
}
