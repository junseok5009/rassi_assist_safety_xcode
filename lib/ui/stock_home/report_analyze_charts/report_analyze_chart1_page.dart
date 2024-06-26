import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_report01.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/custom/CustomBoxShadow.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 2023.02.21_HJS
/// 종목홈(개편)_홈_리포트분석_목표가
class ReportAnalyzeChart1Page extends StatefulWidget {
  static final GlobalKey<ReportAnalyzeChart1PageState> globalKey = GlobalKey();

  ReportAnalyzeChart1Page() : super(key: globalKey);

  @override
  State<ReportAnalyzeChart1Page> createState() =>
      ReportAnalyzeChart1PageState();
}

class ReportAnalyzeChart1PageState extends State<ReportAnalyzeChart1Page> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  bool _is6Month = true;
  String _isNoData = '';

  Report01 _report01 = defReport01;
  final List<Report01ChartData> _listData = [];

  late TrackballBehavior _trackballBehavior;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _is6Month = true;
    _requestTrReport01();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
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
        int selectedIndex =
            trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              CustomBoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: FittedBox(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      TStyle.getDateSlashFormat1(_listData[selectedIndex].td),
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
                      '${TStyle.getMoneyPoint(_listData[selectedIndex].tp)}원',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  '목표가 : ${TStyle.getMoneyPoint(_listData[selectedIndex].agp)}원',
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
      return const SizedBox(
        height: 240,
      );
    }
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
                    fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
        _setChartView(),
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

  Widget _setChartView() {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: SfCartesianChart(
        enableAxisAnimation: true,
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
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
          desiredIntervals: 4,
          axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
            TStyle.getDateSlashFormat3(axisLabelRenderArgs.text),
            const TextStyle(
              fontSize: 12,
              color: RColor.greyBasic_8c8c8c,
            ),
          ),
        ),
        primaryYAxis: NumericAxis(
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
          //interval: _getInterval,
          axisLabelFormatter: (axisLabelRenderArgs) {
            String value = axisLabelRenderArgs.text;
            if (_isRightYAxisUpUnit) {
              value = TStyle.getMoneyPoint(
                  (axisLabelRenderArgs.value / 10000).round().toString());
            } else {
              value = TStyle.getMoneyPoint(
                  axisLabelRenderArgs.value.round().toString());
            }
            return ChartAxisLabel(
              value,
              const TextStyle(
                fontSize: 12,
                color: RColor.greyBasic_8c8c8c,
              ),
            );
          },
        ),
        trackballBehavior: _trackballBehavior,
        series: [
          AreaSeries<Report01ChartData, String>(
            dataSource: _listData,
            xValueMapper: (item, index) => item.td,
            yValueMapper: (item, index) => int.parse(item.tp),
            color: RColor.chartTradePriceColor.withOpacity(0.08),
            borderWidth: 1.4,
            borderColor: RColor.chartTradePriceColor,
            enableTooltip: true,
          ),
          LineSeries<Report01ChartData, String>(
            dataSource: _listData,
            xValueMapper: (item, index) => item.td,
            yValueMapper: (item, index) => int.tryParse(item.agp) ?? 0,
            color: RColor.chartGreen,
            width: 1.4,
            enableTooltip: false,
          ),
        ],
      ),
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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.REPORT01) {
      _report01 = defReport01;
      _listData.clear();
      final TrReport01 resData = TrReport01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _report01 = resData.retData;
        if (_report01.priceAvg.isEmpty ||
            _report01.priceMin.isEmpty ||
            _report01.priceMax.isEmpty) {
          _isNoData = 'Y';
        } else {
          if (_report01.listChartData.isNotEmpty) {
            _listData.addAll(_report01.listChartData);
            _isNoData = 'N';
            _isRightYAxisUpUnit = _findMinValue >= 100000;
          } else {
            _isNoData = 'Y';
          }
        }
      } else {
        _isNoData = 'Y';
      }
      setState(() {});
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
