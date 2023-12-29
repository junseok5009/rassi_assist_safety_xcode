import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트2 (PER : 2 or PBR : 3)

class StockCompareChart2Dialog extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트2or3';
  int chartDiv = 2; // 2 > PER 3 > PBR
  String stockCode = '';
  String baseDate = '';
  List<StockCompare02> alStockCompare02 = [];

  StockCompareChart2Dialog(int vChartDiv, String vStockCode, String vBaseDate,
      List<StockCompare02> vAlStockCompare02) {
    this.chartDiv = vChartDiv;
    this.stockCode = vStockCode;
    this.baseDate = vBaseDate;
    this.alStockCompare02.addAll(vAlStockCompare02);
  }

  @override
  _StockCompareChart2DialogState createState() =>
      _StockCompareChart2DialogState();
}

class _StockCompareChart2DialogState extends State<StockCompareChart2Dialog> {
  int chartDiv = 2;
  String chartDivName = ''; // 2 > PER // 3 > PBR
  String stockCode = '';
  String baseDate = '';
  List<StockCompare02> alStockCompare02 = [];
  String _chartDataStrStockName = "";
  String _chartDataStr = "";
  int _highLightIndex = 0;

  @override
  void initState() {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: StockCompareChart2Dialog.TAG_NAME,
      screenClassOverride: StockCompareChart2Dialog.TAG_NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    chartDiv = widget.chartDiv;
    if (chartDiv == 3) {
      chartDivName = 'PBR';
    } else {
      chartDivName = 'PER';
    }

    stockCode = widget.stockCode;
    baseDate = widget.baseDate;
    alStockCompare02 = widget.alStockCompare02;

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
                  icon: Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  constraints: BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
              Text(
                chartDivName,
                style: TStyle.title19T,
              ),
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
            top: 24,
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
              color: function(value, index) {
                  if (index == $_highLightIndex) {
                      return '#7774F7';
                  }
                  else {
                      return 'grey';
                  }
              },
              formatter : function(params,index){
                  if (${alStockCompare02.length} >= 5) {
                      return params.substring(0,1);
                  }
                  else if (${alStockCompare02.length} >= 3) {
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
              nameGap: 0,
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
                padding: [0, 0, 12, 0],
              },
            },
            {
              type: 'value',
              name: '${TStyle.getDateSlashFormat1(baseDate)} 기준',
              nameLocation: 'end',
              nameGap: 0,
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
    for (int i = 0; i < alStockCompare02.length; i++) {
      var item = alStockCompare02[i];
      String vStockName = item.stockName;
      /*if(vStockName.length >= 4){
        vStockName = vStockName.substring(0, 3);
      }*/
      tmpDataStockName += "'$vStockName', ";
      if (chartDiv == 3) {
        if (stockCode == item.stockCode) {
          _highLightIndex = i;
          tmpData += '''
          {
            value: ${item.pbr}, 
            itemStyle: {color: '#7774F7',},
            label: {show: true, color: '#7774F7', },
          }, 
          ''';
        } else {
          tmpData += "{value: ${item.pbr}, itemStyle: {color: '#000000',},}, ";
        }
      } else {
        if (stockCode == item.stockCode) {
          _highLightIndex = i;
          tmpData += '''
          {
            value: ${item.per}, 
            itemStyle: {color: '#7774F7',},
            label: {show: true, color: '#7774F7',},
          }, 
          ''';
        } else {
          tmpData += "{value: ${item.per}, itemStyle: {color: '#000000',},}, ";
        }
      }
    }
    tmpDataStockName += ']';
    tmpData += "]";
    _chartDataStrStockName = tmpDataStockName;
    _chartDataStr = tmpData;
    DLog.d(StockCompareChart2Dialog.TAG_NAME,
        '_chartDataStrStockName : $_chartDataStrStockName');
    DLog.d(StockCompareChart2Dialog.TAG_NAME, '_chartDataStr : $_chartDataStr');
  }

  Widget _makeListView() {
    String _data;
    TextStyle _stockNameStyle;
    TextStyle _stockDataStyle;
    return Container(
      decoration: UIStyle.boxWeakGrey(6),
      padding: const EdgeInsets.all(15),
      //margin: EdgeInsets.only(left: 10,),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: alStockCompare02.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var _item = alStockCompare02[index];
          if(chartDiv == 3){
            // PBR
            _data = _item.pbr;
          }else{
            _data = _item.per;
          }
          if(_data.isEmpty){
            _data = '0';
          }
          if(_item.stockCode == stockCode){
            _stockNameStyle = TStyle.commonPurple14;
            _stockDataStyle = TStyle.commonPurple14;
          }else{
            _stockNameStyle = TStyle.content14;
            _stockDataStyle = TStyle.subTitle;
          }
          return Row(
            children: [
              Text('${_item.stockName}', style: _stockNameStyle,),
              SizedBox(width: 10,),
              Text(_data, style: _stockDataStyle,),
            ],
          );
        },
      ),
    );
  }
}
