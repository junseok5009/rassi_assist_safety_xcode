import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_sales_info.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare04.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트 5 매출액증가율 or 6 영업이익 증가율

class StockCompareChart5Dialog extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트5or6';
  String groupCode = '';
  String stockCode = '';
  int chartDiv = 5; //  // 2 > 매출액 증가율 3 > 영업이익 증가율

  StockCompareChart5Dialog(int vChartDiv, String vGroupCode, String vStockCode) {
    this.chartDiv = vChartDiv;
    this.groupCode = vGroupCode;
    this.stockCode = vStockCode;
  }

  @override
  StockCompareChart5DialogState createState() =>
      StockCompareChart5DialogState();
}

class StockCompareChart5DialogState extends State<StockCompareChart5Dialog> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _groupCode = '';
  int chartDiv = 5;
  String chartDivName = ''; // 5 > 매출액증가율 // 6 > 영업이익증가율
  String baseDate = '';
  List<StockSalesInfo> alStock = [];

  String _upChartDataStrYear = "";
  String _upChartDataStrCategory = "";
  String _upChartDataStr = "";

  String _dnChartDataStrYear = "";
  String _dnChartDataStrCategory = "";
  String _dnChartDataStr = "";

  String _stockCode = '';
  double _upYaxisMax = 0.0;
  double _upYaxisMin = 0.0;
  double _dnYaxisMax = 0.0;
  double _dnYaxisMin = 0.0;

  void onClickTv() {}

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockCompareChart5Dialog.TAG_NAME,
    );
    _loadPrefData();
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _groupCode = widget.groupCode;
      _stockCode = widget.stockCode;
    });

    _fetchPosts(
        TR.COMPARE04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockGrpCd': _groupCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart5Dialog.TAG_NAME, "_fetchPosts()");
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      Navigator.of(context).pop(null);
    } on SocketException catch (_) {
      Navigator.of(context).pop(null);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(StockCompareChart5Dialog.TAG_NAME,
        "_parseTrData() // trStr : $trStr, ");
    // DEFINE TR.COMPARE04 매출액 증가율 조회
    if (trStr == TR.COMPARE04) {
      final TrCompare04 resData =
          TrCompare04.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        setState(() {
          baseDate = resData.retData.baseDate;
          alStock.addAll(resData.retData.listStock);
          //stockCode = alStock[0].stockCode;
        });
      }
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    DLog.d(StockCompareChart5Dialog.TAG_NAME,
        "build() // _userId : ${_userId} / stockGrpCd : $_groupCode");
    chartDiv = widget.chartDiv;
    if (chartDiv == 6) {
      chartDivName = '영업이익증가율';
    } else {
      chartDivName = '매출액증가율';
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(25), //전체 margin 동작
      child: Container(
        width: double.infinity,
        // height: 250,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                color: Colors.black,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ),
            Text(
              chartDivName,
              style: TStyle.title19T,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: Wrap(
                spacing: 10.0,
                alignment: WrapAlignment.start,
                children: List.generate(
                  alStock.length,
                      (index) => _makeSelectStockBox(index),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _makeUpChartView(),
                    _makeDnChartView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onClickSelectBox(String selectStockCode) {
    setState(() {
      _stockCode = selectStockCode;
    });
  }

  Widget _makeSelectStockBox(int index) {
    var item = alStock[index];
    if (item.stockCode == _stockCode) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
        decoration: UIStyle.boxBtnSelectedMainColor6Cir(),
        child: Text(
          alStock[index].stockName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
        decoration: UIStyle.boxRoundLine6(),
        child: InkWell(
            onTap: () {
              _onClickSelectBox(item.stockCode);
            },
            child: Text(alStock[index].stockName)),
      );
    }
  }

  Widget _makeUpChartView() {
    _setUpChartData();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 240,
      child: Echarts(
        captureHorizontalGestures: true,
        reloadAfterInit: true,
        extraScript: '''

        ''',
        option: '''
        {
          grid: { 
            left: 0,
            top: 10,
            right: 0,
            bottom: 10,
            containLabel: true,
          },
          tooltip: {
            trigger: 'item',
          },
          xAxis: [
            { 
              type: 'category',
              data: $_upChartDataStrYear,
              axisLabel: {
                margin: 20,
              },
              //axisLabel : {
                //clickable:true,
                //interval : 0,
                //formatter : function(params,index){
                //    if (index % 2 != 0) {
                //        return '\\n\\n' + params;
                //    }
                //    else {
                //        return params;
                //    }
                //}
              //},
            },
            { 
              show : false,
              type: 'category',
              data: $_upChartDataStrCategory,
            },
          ],
          yAxis: [
            {
              type: 'value',
              name: '(%) 전년동기대비(1Q)',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'left',
                verticalAlign: 'bottom',
                padding: [0, 0, 0, -20],
              },
              max: $_upYaxisMax,
              min: $_upYaxisMin,
            },
            {
              type: 'value',
              name: '${TStyle.getDateSlashFormat2(baseDate)}',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
              },
            },
          ],
          series: $_upChartDataStr,
        }
      ''',
      ),
    );
  }

  void _setUpChartData() {
    String tmpDataYear = '[';
    String tmpDataCategory = '[';
    String tmpData = '[';
    int _lastYear = 0;

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];

      int smallLastYear = int.parse(item.listSalesInfo.last.year);
      if (_lastYear < smallLastYear) {
        _lastYear = smallLastYear;
      }

      String strSmallDataValue = '[';
      String tmpLineData = '[';

      int yearIndex = 0;
      double tmpYaxisMaxValue = 0.0;
      double tmpYaxisMinValue = 0.0;

      for (int k = 0; k < 4; k++) {
        tmpDataCategory += '0,';
        if (item.listSalesInfo.length > 0 &&
            yearIndex < item.listSalesInfo.length) {
          var smallItem = item.listSalesInfo[yearIndex];

          if (int.parse(smallItem.year) == (smallLastYear - 3 + k)) {
            String data = '';

            if (chartDiv == 6) {
              data = smallItem.profitRateQuart;
            } else {
              data = smallItem.salesRateQuart;
            }

            if (data.isEmpty) {
              data = '0';
            }

            strSmallDataValue += '$data,';
            tmpLineData += '[${i + (alStock.length * k)}, $data,],';
            if (data != '') {
              if (double.parse(data) > tmpYaxisMaxValue) {
                tmpYaxisMaxValue = double.parse(data);
              }
              if (double.parse(data) < tmpYaxisMinValue) {
                tmpYaxisMinValue = double.parse(data);
              }
            }

            yearIndex++;
          } else {
            strSmallDataValue += '0,';
            tmpLineData += '[0, 0],';
          }
        } else {
          strSmallDataValue += '0,';
          tmpLineData += '[0, 0],';
        }
      }

      strSmallDataValue += '],';
      tmpLineData += '],';

      if (_stockCode == item.stockCode) {
        tmpData += '''
        { 
        type: 'bar', itemStyle:{ color: '#7774F7', },
        label: {show : true, fontWeight: 'bold', position: 'outside', fontSize: 10, formatter: function(d){return d.value + '%';},},   
        name: '${item.stockName}',
        data: $strSmallDataValue
        },
        { 
          type: 'line',
          symbolSize: 0,
          xAxisIndex: 1,
          lineStyle: {
            color: 'grey',
            width: 1,
            type: 'dashed',
          },
          data: $tmpLineData
        }, 
        ''';

        if (tmpYaxisMaxValue > 0) {
          _upYaxisMax = tmpYaxisMaxValue + 10;
        } else if (tmpYaxisMaxValue < 0) {
          _upYaxisMax = tmpYaxisMaxValue - 10;
        }

        if (tmpYaxisMinValue < 0) {
          _upYaxisMin = tmpYaxisMinValue - 10;
        } else if (tmpYaxisMinValue > 0) {
          _upYaxisMin = 0;
        }
      } else {
        tmpData += '''
        { 
        type: 'bar', itemStyle:{ color: '#e1e2e5', }, 
        name: '${item.stockName}',
        data: $strSmallDataValue
        },
        ''';
      }
    }

    for (int q = 0; q < 4; q++) {
      //tmpDataYear += "'${_lastYear - 3 + q}(1Q)',";
      tmpDataYear += "'${_lastYear - 3 + q}',";
    }

    tmpDataYear += ']';
    tmpDataCategory += "]";
    tmpData += "]";

    _upChartDataStrYear = tmpDataYear;
    _upChartDataStrCategory = tmpDataCategory;
    _upChartDataStr = tmpData;

    DLog.d(StockCompareChart5Dialog.TAG_NAME,
        "_upChartDataStr : $_upChartDataStr");
  }

  Widget _makeDnChartView() {
    _setDnChartData();
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 240,
      child: Echarts(
        captureHorizontalGestures: true,
        reloadAfterInit: true,
        extraScript: '''

        ''',
        option: '''
        {
          grid: { 
            left: 0,
            top: 10,
            right: 0,
            bottom: 10,
            containLabel: true,
          },
          tooltip: {
            trigger: 'item',
          },
          xAxis: [
            { 
              type: 'category',
              data: $_dnChartDataStrYear,
              axisLabel : {
                clickable:true,
                interval : 0,
                margin: 20,
                //formatter : function(params,index){
                //    if (index % 2 != 0) {
                //        return '\\n\\n' + params;
                //    }
                //    else {
                //        return params;
                //    }
                //}
              }
            },
            { 
              show : false,
              type: 'category',
              data: $_dnChartDataStrCategory,
            },
          ],
          yAxis: [
            {
              type: 'value',
              name: '(%) 전년대비(연간)',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'left',
                verticalAlign: 'bottom',
                padding: [0, 0, 0, -20],
              },
              max: $_dnYaxisMax,
              min: $_dnYaxisMin,
            },
            {
              type: 'value',
              name: '${TStyle.getDateSlashFormat2(baseDate)}',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
              },
            },
          ],
          series: $_dnChartDataStr,
        }
      ''',
      ),
    );
  }

  void _setDnChartData() {
    String tmpDataYear = '[';
    String tmpDataCategory = '[';
    String tmpData = '[';
    int _lastYear = 0;

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];

      double tmpYaxisMaxValue = 0.0;
      double tmpYaxisMinValue = 0.0;

      int smallLastYear = int.parse(item.listSalesInfo.last.year);
      if (_lastYear < smallLastYear) {
        _lastYear = smallLastYear;
      }

      String strSmallDataValue = '[';
      String tmpLineData = '[';

      int yearIndex = 0;

      for (int k = 0; k < 4; k++) {
        tmpDataCategory += '0,';
        if (item.listSalesInfo.length > 0 &&
            yearIndex < item.listSalesInfo.length) {
          var smallItem = item.listSalesInfo[yearIndex];
          if (int.parse(smallItem.year) == (smallLastYear - 3 + k)) {
            String yearData;
            if (chartDiv == 6) {
              yearData = smallItem.profitRateYear;
            } else {
              yearData = smallItem.salesRateYear;
            }

            if(yearData.isEmpty){
              yearData = '0';
            }

            if (yearData != '') {
              if (double.parse(yearData) > tmpYaxisMaxValue) {
                tmpYaxisMaxValue = double.parse(yearData);
              }
              if (double.parse(yearData) < tmpYaxisMinValue) {
                tmpYaxisMinValue = double.parse(yearData);
              }
            }

            String first = "{ value: $yearData, itemStyle: { color:";
            String last = " }, },";
            String mainColor = "'#7774F7',";
            String subColor = "'#e1e2e5',";
            String opacity = "opacity: 0.5,";

            strSmallDataValue += first;
            if (_stockCode == item.stockCode) {
              strSmallDataValue += mainColor;
            } else {
              strSmallDataValue += subColor;
            }
            if (k == 3) {
              strSmallDataValue += opacity;
            }
            strSmallDataValue += last;

            tmpLineData += '[${i + (alStock.length * k)}, $yearData,],';

            yearIndex++;
          } else {
            strSmallDataValue +=
                "{value: 0, itemStyle: { color: '#e1e2e5', },},";
            tmpLineData += '[0, 0],';
          }
        } else {
          strSmallDataValue += "{value: 0, itemStyle: { color: '#e1e2e5', },},";
          tmpLineData += '[0, 0],';
        }
      }

      strSmallDataValue += '],';
      tmpLineData += '],';

      if (_stockCode == item.stockCode) {
        tmpData += '''
        { 
          type: 'bar',
          label: {
            show : true,
            fontWeight: 'bold',
            position: 'outside',
            fontSize: 10,
            formatter: function(d){
              return d.value + '%';
            },
          },
          name: '${item.stockName}',
          data: $strSmallDataValue
        },
        { 
          type: 'line',
          symbolSize: 0,
          xAxisIndex: 1,
          lineStyle: {
            color: 'grey',
            width: 1,
            type: 'dashed',
          },
          data: $tmpLineData
        }, 
        ''';

        if (tmpYaxisMaxValue > 0) {
          _dnYaxisMax = tmpYaxisMaxValue + 10;
        } else if (tmpYaxisMaxValue < 0) {
          _dnYaxisMax = tmpYaxisMaxValue - 10;
        }

        if (tmpYaxisMinValue < 0) {
          _dnYaxisMin = tmpYaxisMinValue - 10;
        } else if (tmpYaxisMinValue > 0) {
          _dnYaxisMin = 0;
        }
      } else {
        tmpData += '''
          { 
              type: 'bar',
              name: '${item.stockName}',
              data: $strSmallDataValue
          },
        ''';
      }
    }
    // for loop finish;

    for (int q = 0; q < 4; q++) {
      if (q == 3) {
        tmpDataYear += "'${_lastYear - 3 + q}\\n(연환산추정)',";
      } else {
        tmpDataYear += "'${_lastYear - 3 + q}',";
      }
    }

    tmpDataYear += ']';
    tmpDataCategory += "]";
    tmpData += "]";

    DLog.d(StockCompareChart5Dialog.TAG_NAME, "tmpDataYear : $tmpDataYear");
    DLog.d(StockCompareChart5Dialog.TAG_NAME,
        "tmpDataCategory : $tmpDataCategory");
    DLog.d(StockCompareChart5Dialog.TAG_NAME, "tmpData : $tmpData");

    _dnChartDataStrYear = tmpDataYear;
    _dnChartDataStrCategory = tmpDataCategory;
    _dnChartDataStr = tmpData;
  }
}
