import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/stock_compare02.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트2 (PER : 2 or PBR : 3)

class StockCompareChart2Page extends StatelessWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트2or3';
  int _chartDiv = 2; // 2 > PER 3 > PBR
  String _stockCode = '';
  List<StockCompare02> _listStockCompare02 = [];

  String _chartDivName = ''; // 2 > PER // 3 > PBR
  String _chartDataStrStockName = "";
  String _chartDataStr = "";
  int _highLightIndex = 0;

  StockCompareChart2Page(int vChartDiv, String vStockCode,
      List<StockCompare02> vAlStockCompare02) {
    this._chartDiv = vChartDiv;
    this._stockCode = vStockCode;
    this._listStockCompare02.addAll(vAlStockCompare02);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: StockCompareChart2Page.TAG_NAME,
      screenClassOverride: StockCompareChart2Page.TAG_NAME,
    );

    if (_chartDiv == 3) {
      _chartDivName = 'PBR';
    } else {
      _chartDivName = 'PER';
    }

    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close),
              padding: EdgeInsets.zero,
              alignment: Alignment.topRight,
              color: Colors.black,
              constraints: BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          Text(
            _chartDivName,
            style: TStyle.title19T,
          ),
          _makeChartView(),
          _makeListView(),
          const SizedBox(height: 20,),
        ],
      ),
    );
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
          tooltip: {
            trigger: 'item',
          },
          grid: {
            left: 10,
            top: 40,
            right: 10,
            bottom: 10,
            containLabel: true,
          },
          xAxis: {
            type: 'category',
            data: $_chartDataStrStockName,
            axisLabel : {
              clickable:true,
              interval : 0,
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
                  if (${_listStockCompare02.length} >= 5) {
                      return params.substring(0,1);
                  }
                  else if (${_listStockCompare02.length} >= 3) {
                    return params.substring(0,4);
                  }
                  else {
                      return params.substring(0,4);
                  }
              },
            }
          },
          yAxis:
          [
            {
              type: 'value',
              name: '(배)',
              nameLocation: 'end',
              nameGap: 10,
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
                padding: [0, 0, 12, 0],
              },
            },
            {
              type: 'value',
              name: '전일종가기준',
              nameLocation: 'end',
              nameGap: 10,
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
                padding: [0, 0, 10, 0],
              },
            },
          ],
          series: [
            {
              data: $_chartDataStr,
              barWidth: '20%',
              type: 'bar',
               label: {
                show : true,
                fontWeight: 'bold',
                position: 'outside',
                formatter: function(d){
                  if(d.value == 0){
                    return '';
                  }else{
                    return d.value;
                  }
                 },
               },
            }
          ]
        }
      ''',
      ),
    );
  }

  void _setChartData() {
    String tmpDataStockName = '[';
    String tmpData = '[';
    for (int i = 0; i < _listStockCompare02.length; i++) {
      var item = _listStockCompare02[i];
      String vStockName = item.stockName;
      String vChartData = '';
      if (vStockName.length >= 4) {
        vStockName = vStockName.substring(0, 3);
      }
      if(_chartDiv == 3){
        vChartData = item.pbr;
      }else{
        vChartData = item.per;
      }
      if(vChartData.isEmpty){
        vChartData = '0';
      }
      tmpDataStockName += "'$vStockName', ";
      if (_stockCode == item.stockCode) {
        _highLightIndex = i;
        tmpData += '''
          {
            value: $vChartData,
            itemStyle: {color: '#7774F7',},
            label: {show: true, color: '#7774F7', },
          },
          ''';
      } else {
        tmpData += "{value: $vChartData, itemStyle: {color: '#000000',},}, ";
      }
    }
    tmpDataStockName += ']';
    tmpData += "]";
    _chartDataStrStockName = tmpDataStockName;
    _chartDataStr = tmpData;
    DLog.d(StockCompareChart2Page.TAG_NAME,
        '_chartDataStrStockName : $_chartDataStrStockName');
    DLog.d(StockCompareChart2Page.TAG_NAME, '_chartDataStr : $_chartDataStr');
  }

  Widget _makeListView() {
    String _data;
    TextStyle _stockNameStyle;
    TextStyle _stockDataStyle;
    return Container(
      decoration: UIStyle.boxWeakGrey(6),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 10,),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        itemCount: _listStockCompare02.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var _item = _listStockCompare02[index];
          if (_chartDiv == 3) {
            // PBR
            _data = _item.pbr;
          } else {
            _data = _item.per;
          }
          if (_data.isEmpty) {
            _data = '0';
          }
          if (_item.stockCode == _stockCode) {
            _stockNameStyle = TStyle.commonPurple14;
            _stockDataStyle = TStyle.commonPurple14;
          } else {
            _stockNameStyle = TStyle.content14;
            _stockDataStyle = TStyle.subTitle;
          }
          return Column(
            children: [
              SizedBox(height: 2,),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_item.stockName}',
                        style: _stockNameStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 75,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$_data배',
                          //'9099.99배',
                          style: _stockDataStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}