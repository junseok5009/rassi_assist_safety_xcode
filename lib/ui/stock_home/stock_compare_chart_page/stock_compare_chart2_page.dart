import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트2 (PER : 2 or PBR : 3)

class StockCompareChart2Page extends StatelessWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트2or3';
  int chartDiv = 2; // 2 > PER 3 > PBR
  String stockCode = '';
  final List<StockCompare02> _listStockCompare02 = [];

  late String _chartDivName = ''; // 2 > PER // 3 > PBR
  late String _chartDataStrStockName = "";
  late String _chartDataStr = "";
  late int _highLightIndex = 0;

  StockCompareChart2Page(
    List<StockCompare02> vAlStockCompare02, {
    Key? key,
    this.chartDiv = 2,
    this.stockCode = '',
  }) : super(key: key) {
    _listStockCompare02.addAll(vAlStockCompare02);
    if (chartDiv == 3) {
      _chartDivName = 'PBR';
    } else {
      _chartDivName = 'PER';
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomFirebaseClass.logEvtScreenView(
      StockCompareChart2Page.TAG_NAME,
    );
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
            _chartDivName,
            style: TStyle.title19T,
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
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      height: 240,
      child: Echarts(
        captureHorizontalGestures: true,
        //reloadAfterInit: true,
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
      if (chartDiv == 3) {
        vChartData = item.pbr;
      } else {
        vChartData = item.per;
      }
      if (vChartData.isEmpty) {
        vChartData = '0';
      }
      tmpDataStockName += "'$vStockName', ";
      if (stockCode == item.stockCode) {
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
    DLog.d(StockCompareChart2Page.TAG_NAME, '_chartDataStrStockName : $_chartDataStrStockName');
    DLog.d(StockCompareChart2Page.TAG_NAME, '_chartDataStr : $_chartDataStr');
  }

  Widget _makeListView() {
    String data;
    TextStyle stockNameStyle;
    TextStyle stockDataStyle;
    return Container(
      decoration: UIStyle.boxWeakGrey(6),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(
        top: 10,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        itemCount: _listStockCompare02.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var item = _listStockCompare02[index];
          if (chartDiv == 3) {
            // PBR
            data = item.pbr;
          } else {
            data = item.per;
          }
          if (data.isEmpty) {
            data = '0';
          }
          if (item.stockCode == stockCode) {
            stockNameStyle = TStyle.commonPurple14;
            stockDataStyle = TStyle.commonPurple14;
          } else {
            stockNameStyle = TStyle.content14;
            stockDataStyle = TStyle.subTitle;
          }
          return Column(
            children: [
              const SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.stockName,
                        style: stockNameStyle,
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
                          '$data배',
                          //'9099.99배',
                          style: stockDataStyle,
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
