import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../common/const.dart';
import '../../../../../common/net.dart';
import '../../../../../models/tr_report02.dart';
import '../../../models/none_tr/app_global.dart';

/// 2023.02.21_HJS
/// 종목홈(개편)_홈_리포트분석_발생트렌드
class ReportAnalyzeChart2Page extends StatefulWidget {
  const ReportAnalyzeChart2Page({Key? key}) : super(key: key);

  @override
  State<ReportAnalyzeChart2Page> createState() =>
      ReportAnalyzeChart2PageState();
}

class ReportAnalyzeChart2PageState extends State<ReportAnalyzeChart2Page>
    with AutomaticKeepAliveClientMixin<ReportAnalyzeChart2Page> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _isQuart = true;
  String _isNoData = '';

  Report02 _report02 = defReport02;
  final List<Report02ChartData> _listData = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestTrReport02();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                decoration: _isQuart
                    ? UIStyle.boxNewSelectBtn1()
                    : UIStyle.boxNewUnSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '분기',
                      style: TextStyle(
                        color: _isQuart
                            ? Colors.black
                            : RColor.btnUnSelectGreyText,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (!_isQuart) {
                        setState(() {
                          _isQuart = true;
                          _requestTrReport02();
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
                decoration: _isQuart
                    ? UIStyle.boxNewUnSelectBtn1()
                    : UIStyle.boxNewSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '월간',
                      style: TextStyle(
                        color: _isQuart
                            ? RColor.btnUnSelectGreyText
                            : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (_isQuart) {
                        setState(() {
                          _isQuart = false;
                          _requestTrReport02();
                        });
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
        height: 100,
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
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '단위:개수',
            style: TextStyle(
              fontSize: 11,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ),
        Container(
            width: double.infinity,
            height: 240,
            color: Colors.transparent,
            child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  //axisBorderType: AxisBorderType.withoutTopAndBottom,
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
                  axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                    _isQuart
                        ? '${axisLabelRenderArgs.text.substring(2)}Q'
                        : '${axisLabelRenderArgs.text.substring(2, 4)}/${axisLabelRenderArgs.text.substring(4)}',
                    const TextStyle(
                      fontSize: 10,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true,
                  //axisBorderType: AxisBorderType.withoutTopAndBottom,
                  //anchorRangeToVisiblePoints: true,
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
                  minorGridLines: const MinorGridLines(
                    width: 0,
                  ),
                  minorTickLines: const MinorTickLines(
                    width: 0,
                  ),
                  rangePadding: ChartRangePadding.none,
                  /*desiredIntervals: getMaxValue % 2 == 0
                      ? getMaxValue < 4
                          ? getMaxValue
                          : 4
                      : getMaxValue < 3
                          ? getMaxValue
                          : 3,*/
                  axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                    axisLabelRenderArgs.text,
                    const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ),
                series: <CartesianSeries>[
                  //기타
                  StackedColumnSeries<Report02ChartData, String>(
                    dataSource: _listData,
                    xValueMapper: (Report02ChartData data, _) => data.td,
                    yValueMapper: (Report02ChartData data, _) =>
                        int.parse(data.rce),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1),
                    ),
                    color: RColor.greyBox_dcdfe2,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      showZeroValue: false,
                      labelPosition: ChartDataLabelPosition.inside,
                      labelAlignment: ChartDataLabelAlignment.middle,
                      alignment: ChartAlignment.center,
                      overflowMode: OverflowMode.shift,
                      textStyle: TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ),
                  //매도
                  StackedColumnSeries<Report02ChartData, String>(
                    dataSource: _listData,
                    xValueMapper: (Report02ChartData data, _) => data.td,
                    yValueMapper: (Report02ChartData data, _) =>
                        int.parse(data.rcs),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1),
                    ),
                    color: RColor.lightBlue_5886fe,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      showZeroValue: false,
                      labelPosition: ChartDataLabelPosition.inside,
                      labelAlignment: ChartDataLabelAlignment.middle,
                      textStyle: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  //매수
                  StackedColumnSeries<Report02ChartData, String>(
                    dataSource: _listData,
                    xValueMapper: (Report02ChartData data, _) => data.td,
                    yValueMapper: (Report02ChartData data, _) =>
                        int.parse(data.rcb),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1),
                    ),
                    color: RColor.chartRed1,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      showZeroValue: false,
                      labelPosition: ChartDataLabelPosition.inside,
                      labelAlignment: ChartDataLabelAlignment.middle,
                      textStyle: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ])),
        const SizedBox(
          height: 5,
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
                color: Color(0xffFF5050),
                shape: BoxShape.circle,
              ),
            ),
            //const SizedBox(width: 4,),
            const Text(
              '  매수',
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
                color: Color(0xff5886FE),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              '  매도',
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
                color: Color(0xffDCDFE2),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              '  기타',
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
                  Text(
                    _isQuart ? '전분기 대비 발생' : '전월 대비 발생',
                    style: const TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report02.reportComp}%',
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
                    '총 발생 개수',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report02.reportTotal}개',
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
                  Text(
                    _isQuart ? '최근 분기 발생 개수' : '이번달 발생 개수',
                    style: const TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    _isQuart
                        ? '$_getLastQuartCount개'
                        : '${_report02.reportMonth}개',
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

  int get _getLastQuartCount {
    if (_isQuart) {
      int result = 0;
      result += int.parse(_report02.listChartData.last.rcb);
      result += int.parse(_report02.listChartData.last.rce);
      result += int.parse(_report02.listChartData.last.rcs);
      return result;
    } else {
      return 0;
    }
  }

  int get getMaxValue {
    int maxValue = 0;
    for (var item in _listData) {
      int sumValue = 0;
      sumValue +=
          int.parse(item.rcb) + int.parse(item.rcs) + int.parse(item.rce);
      if (sumValue > maxValue) {
        maxValue = sumValue;
      }
    }
    return maxValue;
  }

  _requestTrReport02() {
    _fetchPosts(
      TR.REPORT02,
      jsonEncode(
        <String, String>{
          'userId': _appGlobal.userId,
          'stockCode': _appGlobal.stkCode,
          'selectDiv': _isQuart ? 'QUART' : 'MONTH',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.w(trStr + ' ' + json);

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
    if (trStr == TR.REPORT02) {
      _report02 = defReport02;
      _listData.clear();
      final TrReport02 resData = TrReport02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _isNoData = 'N';
        _report02 = resData.retData;
        if (_report02.listChartData.isNotEmpty &&
            _report02.reportTotal != '0') {
          _listData.addAll(_report02.listChartData);
        } else {
          _isNoData = 'Y';
        }
      } else {
        _isNoData = 'Y';
      }
      setState(() {});
    }
  }
}
