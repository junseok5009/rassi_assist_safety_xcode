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
import 'package:rassi_assist/models/none_tr/stock/stock_fluct.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare05.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트7 기가별등락률

class StockCompareChart7Dialog extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트7';
  String groupCode = '';
  String stockCode = '';

  StockCompareChart7Dialog(String vGroupCode, String vStockCode,
      {Key? key, this.groupCode = '', this.stockCode = ''})
      : super(key: key);

  @override
  StockCompareChart7DialogState createState() =>
      StockCompareChart7DialogState();
}

class StockCompareChart7DialogState extends State<StockCompareChart7Dialog> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _groupCode = '';
  String _stockCode = '';
  String _baseDate = '';
  List<String> alStrDays = ['1주일', '1개월', '3개월', '6개월', '1년'];
  int selectDaysBoxIndex = 0;
  List<StockFluct> alStock = [];
  int _highLightIndex = 0;
  String _chartDataStrCategory = "";
  String _chartDataStr = "";

  void onClickTv() {}

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockCompareChart7Dialog.TAG_NAME,
    );
    _loadPrefData();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();

    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _groupCode = widget.groupCode;
    _stockCode = widget.stockCode;

    _fetchPosts(
        TR.COMPARE05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockGrpCd': _groupCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart7Dialog.TAG_NAME, "_fetchPosts()");
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
    DLog.d(StockCompareChart7Dialog.TAG_NAME,
        "_parseTrData() // trStr : $trStr, ");
    // DEFINE TR.COMPARE05 기간별 등락율 조회
    if (trStr == TR.COMPARE05) {
      final TrCompare05 resData =
          TrCompare05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        setState(() {
          _baseDate = resData.retData.baseDate;
          alStock.addAll(resData.retData.listStockFluct);
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
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
              const Text(
                '기간별등락률',
                style: TStyle.title19T,
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10),
                width: double.infinity,
                child: Wrap(
                  spacing: 10.0,
                  alignment: WrapAlignment.start,
                  children: List.generate(
                    5,
                    (index) => _makeSelectStockBox(index),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _makeChartView(),
              _makeListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _makeSelectStockBox(int index) {
    if (selectDaysBoxIndex == index) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
        decoration: UIStyle.boxBtnSelectedMainColor6Cir(),
        child: Text(
          alStrDays[index],
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
            setState(() {
              selectDaysBoxIndex = index;
            });
          },
          child: Text(
            alStrDays[index],
          ),
        ),
      );
    }
  }

  Widget _makeChartView() {
    _setChartData();
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
          tooltip: {},
          label: {
            show : true,
            position: 'outside',
            formatter: function(d){
            return d.value + '%';
            },
          },
          grid: { 
            left: 5,
            top: 30,
            right: 5,
            bottom: 10,
            containLabel: true,
          },
          xAxis: {
            type: 'category',
            data: $_chartDataStrCategory,
            axisLabel : {
              margin: 10,
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
                  //if (index % 2 != 0) {
                  //    return '\\n\\n' + params;
                  //}
                  //else {
                  //    return params;
                  //}
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
              name: '${TStyle.getDateSlashFormat1(_baseDate)} 기준',
              nameLocation: 'end',
              nameTextStyle: {
                align: 'right',
                verticalAlign: 'bottom',
              },
            },
          ],  
          series: [
            {
              data: $_chartDataStr,
              type: 'bar',
              barWidth: '20%',
            }
          ]
        }
      ''',
      ),
    );
  }

  void _setChartData() {
    String tmpDataCategory = '[';
    String tmpData = '[';

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];
      var amountData = '';

      if (selectDaysBoxIndex == 0) {
        amountData = item.fluctWeek1;
      } else if (selectDaysBoxIndex == 1) {
        amountData = item.fluctMonth1;
      } else if (selectDaysBoxIndex == 2) {
        amountData = item.fluctMonth3;
      } else if (selectDaysBoxIndex == 3) {
        amountData = item.fluctMonth6;
      } else if (selectDaysBoxIndex == 4) {
        amountData = item.fluctYear1;
      }

      tmpDataCategory += "'${item.stockName}',";
      if (amountData.contains("-")) {
        tmpData +=
            "{ value: $amountData, itemStyle: { color: '#398AFF' }, label: {fontSize: 10, fontWeight: 'bold'},},";
      } else {
        tmpData +=
            "{ value: $amountData, itemStyle: { color: '#FD525A' }, label: {fontSize: 10, fontWeight: 'bold'},},";
      }
      if (item.stockCode == _stockCode) {
        _highLightIndex = i;
      }
    }

    tmpDataCategory += "]";
    tmpData += "]";

    _chartDataStrCategory = tmpDataCategory;
    _chartDataStr = tmpData;

    DLog.d(StockCompareChart7Dialog.TAG_NAME,
        "_chartDataStrCategory : $_chartDataStrCategory");
    DLog.d(StockCompareChart7Dialog.TAG_NAME, "_chartDataStr : $_chartDataStr");
  }

  Widget _makeListView() {
    String data = '';
    TextStyle stockNameStyle;
    TextStyle stockDataStyle;
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      decoration: UIStyle.boxWeakGrey(6),
      padding: const EdgeInsets.all(15),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: alStock.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var item = alStock[index];

          if(selectDaysBoxIndex == 0){
            // PBR
            data = item.fluctWeek1;
          }else if(selectDaysBoxIndex == 1){
            // PBR
            data = item.fluctMonth1;
          }else if(selectDaysBoxIndex == 2){
            // PBR
            data = item.fluctMonth3;
          }else if(selectDaysBoxIndex == 3){
            // PBR
            data = item.fluctMonth6;
          }else if(selectDaysBoxIndex == 4){
            // PBR
            data = item.fluctYear1;
          }
          if(data.isEmpty){
            data = '0';
          }
          if(item.stockCode == _stockCode){
            stockNameStyle = TStyle.commonPurple14;
            stockDataStyle = TStyle.commonPurple14;
          }else{
            stockNameStyle = TStyle.content14;
            stockDataStyle = TStyle.subTitle;
          }
          return Row(
            children: [
              Text(
                item.stockName,
                style: stockNameStyle,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                data,
                style: stockDataStyle,
              ),
            ],
          );
        },
      ),
    );
  }
}
