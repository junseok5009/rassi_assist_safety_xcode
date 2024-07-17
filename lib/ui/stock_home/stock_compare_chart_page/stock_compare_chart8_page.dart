import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_52.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare06.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트8/9 (52주 최저가 : 8 or 최고가 : 9)

class StockCompareChart8Page extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트8';
  final int chartDiv; // 8 > 최고가  9 > 최저가
  final String groupCode;
  final String stockCode;

  const StockCompareChart8Page({
    Key? key,
    this.chartDiv = 8,
    this.groupCode = '',
    this.stockCode = '',
  }) : super(key: key);

  @override
  StockCompareChart8PageState createState() => StockCompareChart8PageState();
}

class StockCompareChart8PageState extends State<StockCompareChart8Page> {
  late SharedPreferences _prefs;
  String _userId = '';
  int chartDiv = 8;
  String _groupCode = '';
  String _stockCode = '';
  String chartDivName = '52주 최고가 대비 변동률';
  String baseDate = '';
  String stockName = ""; // 최
  List<Stock52> alStock = [];
  int _highLightIndex = 0;
  String _chartXaxisDataStr = "";
  String _chartDataStr = "";
  String _xAxisMaxValueStr = '0';

  final String _chartPlusColorStr = '#FD525A';
  final String _chartMinusColorStr = '#398AFF';

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
      StockCompareChart8Page.TAG_NAME,
    );
    _loadPrefData();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _groupCode = widget.groupCode;
      _stockCode = widget.stockCode;
    });

    _fetchPosts(
        TR.COMPARE06,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockGrpCd': _groupCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart8Page.TAG_NAME, "_fetchPosts()");
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
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(StockCompareChart8Page.TAG_NAME, "_parseTrData() // trStr : $trStr, ");
    // DEFINE TR.COMPARE06 52주 최고가 최저가 대비 변동률
    if (trStr == TR.COMPARE06) {
      final TrCompare06 resData = TrCompare06.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        DLog.d(StockCompareChart8Page.TAG_NAME, resData.retData.toString());
        DLog.d(StockCompareChart8Page.TAG_NAME, resData.retData.baseDate);
        setState(() {
          baseDate = resData.retData.baseDate;
          alStock.addAll(resData.retData.listStock52);
        });
      }
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    chartDiv = widget.chartDiv;
    if (chartDiv == 9) {
      chartDivName = '52주 최저가 대비 변동률';
    } else {
      chartDivName = '52주 최고가 대비 변동률';
    }

    return SafeArea(
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
          const SizedBox(
            height: 10,
          ),
          _makeChartView(),
          _makeListView(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _makeChartView() {
    _setChartData();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 240,
      child: Echarts(
        captureHorizontalGestures: true,
        //reloadAfterInit: true,
        extraScript: '''

        ''',
        option: '''
        {
          grid: { 
            left: 10,
            top: 30,
            right: 10,
            bottom: 20,
            containLabel: true,
          },
          label: {
            show : true,
            position: 'outside',
            formatter: function(d){
            return d.value + '%';
            },
          },
          tooltip: {
            trigger: 'item',
          },
          xAxis: { 
            type: 'category',
            data: $_chartXaxisDataStr,
            axisLabel : {
              margin: 10,
              padding: [5, 0, 0, 0],
              color: function(value, index) {
                  if (index == $_highLightIndex) {
                      return '#7774F7';
                  }
                  else {
                      return 'grey';
                  }
              },
              formatter : function(params,index){  
                if (${alStock.length} >= 5) {
                  return params.substring(0,1);
                }
                else if (${alStock.length} >= 3) {
                  return params.substring(0,4);
                } 
                else {
                  return params.substring(0,6);
                }
              },
            },
          },
          yAxis: [
            {
              type: 'value',
              //max: $_xAxisMaxValueStr,
              name: '(%)',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'left',
                verticalAlign: 'bottom',
                padding: [0, 0, 0, -20],
              },
            },
            {
              type: 'value',
             name: '전일종가기준',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
              },
            },
          ],
          series: {
            data: $_chartDataStr,
            type: 'bar',
            barWidth: '20%',
          },
        }
      ''',
      ),
    );
  }

  void _setChartData() {
    String tmpDataXaxis = '[';
    String tmpData = '[';

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];
      String chartData;
      String barColor = '';

      if (chartDiv == 9) {
        chartData = item.low52FluctRate;
      } else {
        chartData = item.top52FluctRate;
      }

      if (chartData.isNotEmpty && double.parse(chartData) > double.parse(_xAxisMaxValueStr)) {
        _xAxisMaxValueStr = chartData;
      }

      if (chartData.isEmpty) {
        chartData = '0';
      }

      if (chartData.contains('-')) {
        barColor = _chartMinusColorStr;
      } else {
        barColor = _chartPlusColorStr;
      }

      if (item.stockCode == _stockCode) {
        _highLightIndex = i;
      }

      tmpDataXaxis += "'${item.stockName}',";

      tmpData += '''
        { 
          value: $chartData,
          itemStyle: { color: '$barColor' },
          label: { fontSize: 10, fontWeight: 'bold' },
        }, 
        ''';
    }

    tmpDataXaxis += "]";
    tmpData += "]";

    _xAxisMaxValueStr = '${double.parse(_xAxisMaxValueStr) + 5.0}';
    _chartXaxisDataStr = tmpDataXaxis;
    _chartDataStr = tmpData;
  }

  Widget _makeListView() {
    String title = '';
    if (chartDiv == 9) {
      title = '52주 최저가';
    } else {
      title = '52주 최고가';
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: UIStyle.boxWeakGrey(6),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TStyle.commonTitle,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alStock.length,
            itemBuilder: (BuildContext context, int index) {
              return _makeListItemView(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _makeListItemView(int index) {
    String price = '';
    String date = '';
    bool isHigh = false;
    bool isLow = false;
    Stock52 item = alStock[index];

    TextStyle stockNameStyle;
    TextStyle stockPriceStyle;
    TextStyle dateStyle;

    if (chartDiv == 9) {
      price = TStyle.getMoneyPoint(item.low52Price);
      date = TStyle.getDateSlashFormat1(item.low52Date);
      if (item.low52Date == baseDate) {
        isLow = true;
      }
    } else {
      price = TStyle.getMoneyPoint(item.top52Price);
      date = TStyle.getDateSlashFormat1(item.top52Date);
      if (item.top52Date == baseDate) {
        isHigh = true;
      }
    }
    if (item.stockCode == _stockCode) {
      stockNameStyle = TStyle.commonPurple14;
      stockPriceStyle = TStyle.commonPurple14;
      dateStyle = TStyle.commonSPurple;
    } else {
      stockNameStyle = TStyle.content14;
      stockPriceStyle = TStyle.subTitle;
      dateStyle = TStyle.content12;
    }

    return Column(
      children: [
        const SizedBox(
          height: 6,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  item.stockName,
                  style: stockNameStyle,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$price원',
                  style: stockPriceStyle,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: dateStyle,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Visibility(
                    visible: isLow,
                    child: Image.asset(
                      'images/img_down_arrow_color.png',
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Visibility(
                    visible: isHigh,
                    child: Image.asset(
                      'images/img_up_arrow_color.png',
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
