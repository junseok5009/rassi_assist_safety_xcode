import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/stock_sales_info.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare03.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트4 배당수익률

class StockCompareChart4Dialog extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트4';
  String groupCode = '';
  String stockCode = '';

  StockCompareChart4Dialog(String vGroupCode, String vStockCode) {
    this.groupCode = vGroupCode;
    this.stockCode = vStockCode;
  }

  @override
  _StockCompareChart4DialogState createState() =>
      _StockCompareChart4DialogState();
}

class _StockCompareChart4DialogState extends State<StockCompareChart4Dialog> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _groupCode = '';
  String baseDate = '';
  List<StockSalesInfo> alStock = [];

  String _upChartDataStrYear = "";
  String _upChartDataStrCategory = "";
  String _upChartDataStr = "";
  String _stockCode = '';
  String stockName = '';
  int _itemClickIndex = 0;

  void onClickTv() {}

  @override
  void initState() {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: StockCompareChart4Dialog.TAG_NAME,
      screenClassOverride: StockCompareChart4Dialog.TAG_NAME,
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
        TR.COMPARE03,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockGrpCd': _groupCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart4Dialog.TAG_NAME, "_fetchPosts()");
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
    DLog.d(StockCompareChart4Dialog.TAG_NAME,
        "_parseTrData() // trStr : $trStr, ");
    // DEFINE TR.COMPARE03 배당 수익률 조회
    if (trStr == TR.COMPARE03) {
      final TrCompare03 resData =
      TrCompare03.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        DLog.d(StockCompareChart4Dialog.TAG_NAME, resData.retData.toString());

        setState(() {
          baseDate = resData.retData.baseDate;
          alStock.addAll(resData.retData.listStock);
          stockName = alStock[0].stockName;
        });
      }
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: IconButton(icon: Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
              const Text(
                '배당수익률',
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
              const SizedBox(height: 4,),
              _makeChartView(),
              _makeListView(),  // 배당금
            ],
          ),
        ),
      ),
    );
  }

  _onClickSelectBox(StockSalesInfo stock){
    setState(() {
      _stockCode = stock.stockCode;
      stockName = stock.stockName;
    });
  }

  Widget _makeSelectStockBox(int index) {
    var item = alStock[index];
    DLog.d(StockCompareChart4Dialog.TAG_NAME, '_makeSelectStockBox() item.stockName : ${item.stockName} / item.stockCode : ${item.stockCode} vs _stockCode : $_stockCode');
    if(item.stockCode == _stockCode){
      _itemClickIndex = index;
      return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: UIStyle.boxBtnSelectedMainColor6Cir(),
        child: Text(
          item.stockName,
          style: TStyle.btnTextWht14,
        ),
      );
    }else{
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: UIStyle.boxRoundLine6(),
        child: InkWell(
            onTap: (){
              _itemClickIndex = index;
              _onClickSelectBox(item);
            },
            child: Text(item.stockName)),
      );
    }
  }

  Widget _makeChartView() {
    _setChartData();
    return Container(
      margin: EdgeInsets.only(top: 20),
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
            top: 10,
            right: 10,
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
              axisLabel : {
                margin: 20,
              },
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
              name: '(%)    $stockName',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'left',
                verticalAlign: 'bottom',
                padding: [0, 0, 0, -20],
              },
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

  void _setChartData() {
    String tmpDataYear = '[';
    String tmpDataCategory = '[';
    String tmpData = '[';
    int _lastYear = int.parse(TStyle.getYearString()) -1 ;

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];

      String strSmallDataValue = '[';
      String tmpLineData = '[';

      int yearIndex = 0;

      for (int k = 0; k < 4; k++) {
        tmpDataCategory += '0,';
        if (item.listSalesInfo.length > 0 &&
            yearIndex < item.listSalesInfo.length) {
          var smallItem = item.listSalesInfo[yearIndex];
          if(smallItem.dividendYear.isEmpty){
            strSmallDataValue += '0,';
            //tmpLineData += '[0, 0],';
            tmpLineData += '[${ i + alStock.length * k }, 0],';
          }else{
            if (int.parse(smallItem.dividendYear) == (_lastYear - 3 + k)) {
              strSmallDataValue += '${smallItem.dividendRate},';
              tmpLineData +=
              '[${i + (alStock.length * k)}, ${smallItem.dividendRate},],';
              yearIndex++;
            } else {
              strSmallDataValue += '0,';
              //tmpLineData += '[0, 0],';
              tmpLineData += '[${ i + alStock.length * k }, 0],';
            }
          }
        } else {
          strSmallDataValue += '0,';
          //tmpLineData += '[0, 0],';
          tmpLineData += '[${ i + alStock.length * k }, 0],';
        }
      }

      strSmallDataValue += '],';
      tmpLineData += '],';

      if (_stockCode == item.stockCode) {
        tmpData += '''
        { 
        type: 'bar', itemStyle:{ color: '#7774F7', }, 
        label: {show : true, fontWeight: 'bold', position: 'outside', formatter: function(d){return d.value + '%';},},   
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
      tmpDataYear += "'${_lastYear - 3 + q}',";
    }

    tmpDataYear += ']';
    tmpDataCategory += "]";
    tmpData += "]";

    DLog.d(StockCompareChart4Dialog.TAG_NAME, "tmpDataYear : $tmpDataYear");
    DLog.d(StockCompareChart4Dialog.TAG_NAME,
        "tmpDataCategory : $tmpDataCategory");
    DLog.d(StockCompareChart4Dialog.TAG_NAME, "tmpData : $tmpData");

    _upChartDataStrYear = tmpDataYear;
    _upChartDataStrCategory = tmpDataCategory;
    _upChartDataStr = tmpData;
  }

  Widget _makeListView() {
    if(alStock.isEmpty){
      return SizedBox();
    }
    var _listSaleInfo = alStock[_itemClickIndex].listSalesInfo;
    return Visibility(
      visible: _listSaleInfo.length > 0,
      child: Container(
        decoration: UIStyle.boxWeakGrey(6),
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        //margin: EdgeInsets.only(left: 10,),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  alStock[_itemClickIndex].stockName,
                style: TStyle.textMainColor,),
                const SizedBox(width: 6,),
                const Text('주당배당금', style: TStyle.commonTitle,),
              ],
            ),
            const SizedBox(height: 6,),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _listSaleInfo.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var _item = _listSaleInfo[index];
                return Row(
                  children: [
                    Text(_item.dividendYear,
                      style: TStyle.content14,),
                    const SizedBox(width: 10,),
                    Text(' ${TStyle.getMoneyPoint(_item.dividendAmt)}',
                      style: TStyle.commonSTitle,),
                    const Text('원',
                      style: TStyle.content14,),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
