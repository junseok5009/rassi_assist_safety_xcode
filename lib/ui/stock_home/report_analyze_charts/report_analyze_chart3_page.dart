import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

import '../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/tr_report03.dart';

/// 2023.02.21_HJS
/// 종목홈(개편)_홈_리포트분석_발행증권사
class ReportAnalyzeChart3Page extends StatefulWidget {
  const ReportAnalyzeChart3Page({Key? key}) : super(key: key);
  @override
  State<ReportAnalyzeChart3Page> createState() =>
      ReportAnalyzeChart3PageState();
}

class ReportAnalyzeChart3PageState extends State<ReportAnalyzeChart3Page>
    with AutomaticKeepAliveClientMixin<ReportAnalyzeChart3Page> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _is1Year = true;
  String _isNoData = '';
  Report03 _report03 = defReport03;
  final List<Report03ChartData> _listData = [];
  String _chartListDataStr = '[]';
  int touchedIndex = -1;
  final List<String> _chartColorStringList = [
    '#FF5656',
    '#FF9882',
    '#F9E08A',
    '#88EEAA',
    '#43CCB0',
    '#009999'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _requestTrReport03();
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
                decoration: _is1Year
                    ? UIStyle.boxNewSelectBtn1()
                    : UIStyle.boxNewUnSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '1년',
                      style: TextStyle(
                        color: _is1Year
                            ? Colors.black
                            : RColor.btnUnSelectGreyText,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (!_is1Year) {
                        setState(() {
                          _is1Year = true;
                          _requestTrReport03();
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
                decoration: _is1Year
                    ? UIStyle.boxNewUnSelectBtn1()
                    : UIStyle.boxNewSelectBtn1(),
                child: Center(
                  child: InkWell(
                    child: Text(
                      '3년',
                      style: TextStyle(
                        color: _is1Year
                            ? RColor.btnUnSelectGreyText
                            : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      if (_is1Year) {
                        setState(
                          () {
                            _is1Year = false;
                            _requestTrReport03();
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
        Container(
          height: 240,
          child: Echarts(
            option: '''
              {
                tooltip: {
                  trigger: 'item'
                },
                legend: {
                  orient: 'vertical',
                  left: 'left',
                  //top: 'bottom',
                  show: false,
                  itemHeight: '10',
                  textStyle: {
                    fontSize: 10,
                  },
                },
                series: [
                  {
                    //name: 'Access From',
                    type: 'pie',
                    radius: '65%',
                    data: $_chartListDataStr,
                    emphasis: {
                      itemStyle: {
                        shadowBlur: 10,
                        shadowOffsetX: 0,
                        shadowColor: 'rgba(0, 0, 0, 0.5)'
                      }
                    }
                  }
                ]
              }
              ''',
          ),
        ),
        const SizedBox(
          height: 10,
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
                    '최다 리포트 발행',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report03.organName}(총 ${_report03.organCount}개)',
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
                    '총 발행 개수',
                    style: TextStyle(
                      fontSize: 16,
                      color: RColor.new_basic_text_color_strong_grey,
                    ),
                  ),
                  Text(
                    '${_report03.reportTotal}개',
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

  List<PieChartSectionData> showingSections() {
    return List.generate(
      _listData.length,
      (i) {
        const color1 = Colors.lime;
        const color3 = Colors.lightGreen;
        return PieChartSectionData(
          color: i % 2 == 0 ? color1 : color3,
          value: double.parse(_listData[i].organCount),
          title: '${_listData[i].organCount}건',
          titlePositionPercentageOffset: 3 / 5,
          radius: 100,
          //titlePositionPercentageOffset: 0.55,
        );
      },
    );
  }

  _requestTrReport03() {
    _fetchPosts(
      TR.REPORT03,
      jsonEncode(
        <String, String>{
          'userId': _appGlobal.userId,
          'stockCode': _appGlobal.stkCode,
          'selectDiv': _is1Year ? 'Y1' : 'Y3',
        },
      ),
    );
  }

  _initChartData() {
    _chartListDataStr = '[';
    _listData.asMap().forEach((key, item) {
      _chartListDataStr +=
          "{ value: ${int.parse(item.organCount)}, name: '${item.organName} ${item.organCount}개', itemStyle: {color: '${_chartColorStringList[key]}',}, },";
    });
    _chartListDataStr += ']';
    setState(() {});
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
    if (trStr == TR.REPORT03) {
      _report03 = defReport03;
      final TrReport03 resData = TrReport03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _isNoData = 'N';
        _report03 = resData.retData;
        _listData.clear();
        if (_report03.listChartData.length > 0 &&
            _report03.reportTotal != '0') {
          if (_report03.listChartData.length > 5) {
            _listData.addAll(_report03.listChartData.sublist(0, 5));
            var etcList = _report03.listChartData.sublist(5);
            int etcCount = 0;
            etcList.forEach((element) {
              etcCount += int.parse(element.organCount);
            });
            _listData.add(Report03ChartData(
              index: 5,
              organName: '기타',
              organCount: '$etcCount',
            ));
          } else {
            _listData.addAll(_report03.listChartData);
          }
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

class CustomLegendIndicator extends StatelessWidget {
  const CustomLegendIndicator({
    //super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    required this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
