import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_sales_info.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare03.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';

/// 2022.06. - JS
/// 종목홈_종목비교_차트4 배당수익률

class StockCompareChart4Page extends StatefulWidget {
  static const String TAG_NAME = '종목홈_종목비교_차트4';
  final String groupCode;
  final String stockCode;

  const StockCompareChart4Page({Key? key, this.groupCode = '', this.stockCode = ''}) : super(key: key);

  @override
  StockCompareChart4PageState createState() => StockCompareChart4PageState();
}

class StockCompareChart4PageState extends State<StockCompareChart4Page> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _groupCode = '';
  List<StockSalesInfo> alStock = [];

  String _upChartDataStrYear = "";
  String _upChartDataStrCategory = "";
  String _upChartDataStr = "";
  String _stockCode = '';
  String stockName = '';
  int _itemClickIndex = 0;

  final List<String> _listDividendYears = [];

  void onClickTv() {}

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockCompareChart4Page.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          DLog.e('$_userId / $_groupCode'),
          _fetchPosts(
              TR.COMPARE03,
              jsonEncode(<String, String>{
                'userId': _userId,
                'stockGrpCd': _groupCode,
              })),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _groupCode = widget.groupCode;
    _stockCode = widget.stockCode;
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(StockCompareChart4Page.TAG_NAME, "_fetchPosts()");
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
    DLog.w("_parseTrData(): $trStr / ${response.body}");
    // DEFINE TR.COMPARE03 배당 수익률 조회
    if (trStr == TR.COMPARE03) {
      final TrCompare03 resData = TrCompare03.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        DLog.d(StockCompareChart4Page.TAG_NAME, resData.retData.toString());

        setState(() {
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
          const Text(
            '배당수익률',
            style: TStyle.title19T,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            child: Wrap(
              spacing: 10.0,
              alignment: WrapAlignment.center,
              children: List.generate(
                alStock.length,
                (index) => _makeSelectStockBox(index),
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          _makeChartView(),
          const SizedBox(
            height: 10,
          ),
          _makeListView(), // 배당금
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  _onClickSelectBox(StockSalesInfo stock) {
    setState(() {
      _stockCode = stock.stockCode;
      stockName = stock.stockName;
    });
  }

  Widget _makeSelectStockBox(int index) {
    var item = alStock[index];
    if (item.stockCode == _stockCode) {
      _itemClickIndex = index;
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: UIStyle.boxBtnSelectedMainColor6Cir(),
        child: Text(
          item.stockName,
          style: TStyle.btnTextWht14,
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          _itemClickIndex = index;
          _onClickSelectBox(item);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          decoration: UIStyle.boxRoundLine6(),
          child: Text(item.stockName),
        ),
      );
    }
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
    int lastYear = int.parse(TStyle.getYearString()) - 1;

    for (int i = 0; i < alStock.length; i++) {
      var item = alStock[i];

      String strSmallDataValue = '[';
      String tmpLineData = '[';

      int yearIndex = 0;

      for (int k = 0; k < 4; k++) {
        tmpDataCategory += '0,';
        if (item.listSalesInfo.isNotEmpty && yearIndex < item.listSalesInfo.length) {
          var smallItem = item.listSalesInfo[yearIndex];
          if (smallItem.dividendYear.isEmpty) {
            strSmallDataValue += '0,';
            //tmpLineData += '[0, 0],';
            tmpLineData += '[${i + alStock.length * k}, 0],';
          } else {
            if (int.parse(smallItem.dividendYear) == (lastYear - 3 + k)) {
              strSmallDataValue += '${smallItem.dividendRate},';
              tmpLineData += '[${i + (alStock.length * k)}, ${smallItem.dividendRate},],';
              yearIndex++;
            } else {
              strSmallDataValue += '0,';
              //tmpLineData += '[0, 0],';
              tmpLineData += '[${i + alStock.length * k}, 0],';
            }
          }
        } else {
          strSmallDataValue += '0,';
          //tmpLineData += '[0, 0],';
          tmpLineData += '[${i + alStock.length * k}, 0],';
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
      tmpDataYear += "'${lastYear - 3 + q}',";
      _listDividendYears.add((lastYear - q).toString());
    }

    tmpDataYear += ']';
    tmpDataCategory += "]";
    tmpData += "]";

    /* DLog.d(StockCompareChart4Page.TAG_NAME, "tmpDataYear : $tmpDataYear");
    DLog.d(StockCompareChart4Page.TAG_NAME,
        "tmpDataCategory : $tmpDataCategory");
    DLog.d(StockCompareChart4Page.TAG_NAME, "tmpData : $tmpData");*/

    _upChartDataStrYear = tmpDataYear;
    _upChartDataStrCategory = tmpDataCategory;
    _upChartDataStr = tmpData;
  }

  Widget _makeListView() {
    if (alStock.isEmpty) {
      return const SizedBox();
    }

    int salesInfoListIndexCheck = 0;

    var listSaleInfo = alStock[_itemClickIndex].listSalesInfo;
    listSaleInfo.sort((a, b) {
      if (a.dividendYear.isEmpty) {
        return 1;
      } else if (b.dividendYear.isEmpty) {
        return 0;
      } else {
        return double.parse(b.dividendYear).compareTo(double.parse(a.dividendYear));
      }
    });
    return Container(
      decoration: UIStyle.boxWeakGrey(6),
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                alStock[_itemClickIndex].stockName,
                style: TStyle.textMainColor,
              ),
              const SizedBox(
                width: 6,
              ),
              const Text(
                '주당배당금',
                style: TStyle.commonTitle,
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          ListView.builder(
            shrinkWrap: true,
            //itemCount: _listSaleInfo.length,
            itemCount: 4,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              String year = _listDividendYears[index];
              String amt = '0';
              if (listSaleInfo.length > salesInfoListIndexCheck) {
                // 1개 이상
                if (listSaleInfo[salesInfoListIndexCheck].dividendYear == _listDividendYears[index]) {
                  //_salesInfoListIndexCheck++;
                  amt = listSaleInfo[salesInfoListIndexCheck++].dividendAmt;
                }
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
                            year,
                            style: TStyle.content14,
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
                              '${TStyle.getMoneyPoint(amt)}원',
                              style: TStyle.commonSTitle,
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
        ],
      ),
    );
  }
}
