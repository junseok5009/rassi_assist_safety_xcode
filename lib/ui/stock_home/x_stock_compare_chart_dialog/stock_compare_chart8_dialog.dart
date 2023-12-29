import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_52.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare06.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';


/// 2022.06. - JS
/// 종목홈_종목비교_차트8/9 (52주 최저가 : 8 or 최고가 : 9)
class StockCompareChart8Dialog extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트8';
  int chartDiv = 8; // 8 > 최고가  9 > 최저가
  String groupCode = '';
  String stockCode = '';


  StockCompareChart8Dialog(int vChartDiv, String vGroupCode, String vStockCode) {
    this.chartDiv = vChartDiv;
    this.groupCode = vGroupCode;
    this.stockCode = vStockCode;
  }

  @override
  _StockCompareChart8DialogState createState() =>
      _StockCompareChart8DialogState();
}

class _StockCompareChart8DialogState extends State<StockCompareChart8Dialog> {
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
  void initState() {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: StockCompareChart8Dialog.TAG_NAME,
      screenClassOverride: StockCompareChart8Dialog.TAG_NAME,
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
        TR.COMPARE06,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockGrpCd': _groupCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart8Dialog.TAG_NAME, "_fetchPosts()");
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
    DLog.d(StockCompareChart8Dialog.TAG_NAME,
        "_parseTrData() // trStr : $trStr, ");
    // DEFINE TR.COMPARE06 52주 최고가 최저가 대비 변동률
    if (trStr == TR.COMPARE06) {
      final TrCompare06 resData =
          TrCompare06.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        DLog.d(StockCompareChart8Dialog.TAG_NAME, resData.retData.toString());
        DLog.d(StockCompareChart8Dialog.TAG_NAME, resData.retData.baseDate);
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
        child: SingleChildScrollView(
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
              const SizedBox(height: 10,),
              _makeChartView(),
              _makeListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _makeChartView() {
    _setChartData();
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
              name: '${TStyle.getDateSlashFormat1(baseDate)} 기준',
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

      if (chartData.isNotEmpty &&
          double.parse(chartData) > double.parse(_xAxisMaxValueStr)) {
        _xAxisMaxValueStr = chartData;
      }

      if (chartData.contains('-')) {
        barColor = _chartMinusColorStr;
      } else {
        barColor = _chartPlusColorStr;
      }

      if(item.stockCode == _stockCode){
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

    String _title = '';
    if (chartDiv == 9) {
      _title = '52주 최저가';
    }else{
      _title = '52주 최고가';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: UIStyle.boxWeakGrey(6),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
              alignment: Alignment.center,
              child: Text(_title
              , style: TStyle.commonTitle,),),
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
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
    String _price = '';
    String _date = '';
    bool _isHigh = false;
    bool _isLow = false;
    Stock52 item = alStock[index];
    _date = TStyle.getDateSlashFormat1(item.low52Date);
    TextStyle _stockNameStyle;

    if (chartDiv == 9) {
      _price = TStyle.getMoneyPoint(item.low52Price);
      if (item.low52Date == baseDate) {
        _isLow = true;
      }
    } else {
      _price = TStyle.getMoneyPoint(item.top52Price);
      if (item.top52Date == baseDate) {
        _isHigh = true;
      }
    }
    if(item.stockCode == _stockCode){
      _stockNameStyle = TStyle.commonPurple14;
    }else{
      _stockNameStyle = TStyle.content14;
    }

    return Column(
      children: [
        SizedBox(height: 4,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.stockName,
              style: _stockNameStyle,
            ),
            Text(
              ' $_price',
              style: TStyle.subTitle,
            ),
            const Text(
              '원',
              style: TStyle.content14,
            ),
            Text(
              ' ($_date)',
              style: TStyle.content12,
            ),
            Visibility(
              visible: _isLow,
              child: Image.asset(
                'images/icon_low_price.png',
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
            Visibility(
              visible: _isHigh,
              child: Image.asset(
                'images/icon_high_price.png',
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
