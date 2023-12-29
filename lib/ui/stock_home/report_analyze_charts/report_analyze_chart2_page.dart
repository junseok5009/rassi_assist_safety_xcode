import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

import '../../../../../common/const.dart';
import '../../../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../../../models/tr_report02.dart';

/// 2023.02.21_HJS
/// 종목홈(개편)_홈_리포트분석_발생트렌드
class ReportAnalyzeChart2Page extends StatefulWidget {
  @override
  State<ReportAnalyzeChart2Page> createState() =>
      _ReportAnalyzeChart2PageState();
}

class _ReportAnalyzeChart2PageState extends State<ReportAnalyzeChart2Page>
    with AutomaticKeepAliveClientMixin<ReportAnalyzeChart2Page> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _isQuart = true;
  String _isNoData = '';

  Report02 _report02 = defReport02;
  List<charts.Series<Report02ChartData, String>> _seriesList = [];
  final List<Report02ChartData> _listData = [];
  final List<charts.TickSpec<String>> _tickSpecList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestTrReport02();
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
      return SizedBox(
        height: 100,
      );
    }
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: EdgeInsets.only(
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
          height: 240,
          color: Colors.transparent,
          child: charts.BarChart(
            _seriesList,
            animate: true,
            defaultInteractions: false,
            secondaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                zeroBound: true,
                //desiredTickCount: 5,
              ),
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
            domainAxis: charts.OrdinalAxisSpec(
              tickProviderSpec:
                  charts.StaticOrdinalTickProviderSpec(_tickSpecList),
              renderSpec: charts.SmallTickRendererSpec(
                //minimumPaddingBetweenLabelsPx: 30,
                //labelOffsetFromTickPx: 20,
                //labelOffsetFromAxisPx: 12,
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
            barGroupingType: charts.BarGroupingType.stacked,
            behaviors: [],
          ),
        ),
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
                    _isQuart
                        ? '전분기 대비 발생'
                        : '전월 대비 발생',
                    style: const TextStyle(
                      fontSize: 16,
                      color:
                      RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report02.reportComp}%',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
              const SizedBox(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 발생 개수',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                      RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report02.reportTotal}개',
                    style: TStyle.commonTitle,
                  ),
                ],
              ),
              const SizedBox(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isQuart
                        ? '최근 분기 발생 개수'
                        : '이번달 발생 개수',
                    style: const TextStyle(
                      fontSize: 16,
                      color:
                      RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    _isQuart
                        ? '${_getLastQuartCount()}개'
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

  int _getLastQuartCount() {
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

  _initChartData() {
    _seriesList = [
      charts.Series<Report02ChartData, String>(
        id: 'BUY',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#FF5050'),
        domainFn: (Report02ChartData xAxisItem, _) => xAxisItem.td,
        measureFn: (Report02ChartData yAxisItem, _) => int.parse(yAxisItem.rcb),
        data: _listData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
      charts.Series<Report02ChartData, String>(
        id: 'SELL',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#5886FE'),
        domainFn: (Report02ChartData xAxisItem, _) => xAxisItem.td,
        measureFn: (Report02ChartData yAxisItem, _) => int.parse(yAxisItem.rcs),
        data: _listData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
      charts.Series<Report02ChartData, String>(
        id: 'ETC',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#DCDFE2'),
        domainFn: (Report02ChartData xAxisItem, _) => xAxisItem.td,
        measureFn: (Report02ChartData yAxisItem, _) => int.parse(yAxisItem.rce),
        data: _listData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
    _listData.forEach((element) {
      _tickSpecList.add(
        charts.TickSpec(
          element.td,
          label: _formatterLableXAxis(element.td),
          style: charts.TextStyleSpec(
            fontSize: 10,
          ),
        ),
      );
    });
    setState(() {});
  }

  String _formatterLableXAxis(String domainAxis) {
    if (_isQuart) {
      if (domainAxis.isNotEmpty && domainAxis.length >= 6) {
        return domainAxis.substring(2, 4) + '/' + domainAxis.substring(5) + 'Q';
      } else {
        return domainAxis;
      }
    } else {
      if (domainAxis.isNotEmpty && domainAxis.length >= 6) {
        return domainAxis.substring(2, 4) + '/' + domainAxis.substring(4);
      } else {
        return domainAxis;
      }
    }
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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.REPORT02) {
      _report02 = defReport02;
      _seriesList.clear();
      _listData.clear();
      _tickSpecList.clear();
      final TrReport02 resData = TrReport02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _isNoData = 'N';
        _report02 = resData.retData;
        if (_report02.listChartData.length > 0 &&
            _report02.reportTotal != '0') {
          _listData.addAll(_report02.listChartData);
          _initChartData();
        } else {
          setState(() {
            _isNoData = 'Y';
          });
        }
      } else {
        setState(() {
          _isNoData = 'Y';
        });
      }
    }
  }
}
