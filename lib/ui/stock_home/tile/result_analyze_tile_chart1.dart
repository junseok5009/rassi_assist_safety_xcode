import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/ui_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/net.dart';
import '../../../common/tstyle.dart';
import '../../common/common_popup.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/tr_search/tr_search10.dart';

class ResultAnalyzeTileChart1 extends StatefulWidget {
  const ResultAnalyzeTileChart1({
    Key? key,
    required this.initIsQuart,
  }) : super(key: key);
  final bool initIsQuart;

  @override
  State<ResultAnalyzeTileChart1> createState() =>
      _ResultAnalyzeTileChart1State();
}

class _ResultAnalyzeTileChart1State extends State<ResultAnalyzeTileChart1>
    with AutomaticKeepAliveClientMixin<ResultAnalyzeTileChart1> {
  final _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';
  String _isNoData = '';

  // 기업의 실적 성적
  bool _isQuart = true;
  bool _isSalesPerformance = true;
  Search10Sales _confirmSearch10Sales = Search10Sales(); // empty 아니면 잠정실적 있는거
  final List<Search10Sales> _listData = [];
  final List<Search10Sales> _listDataTable = [];
  bool _chart1LeftYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 억, true 이면 천억
  bool _chart1RightYAxisUpUnit = false; // 차트 오른쪽 값의 단위가 false 이면 억, true 이면 천억

  String _chart1XAxisData = '[]';
  String _chart1YAxisData1 = '[]';
  String _chart1YAxisData2 = '[]';
  String _chart1BarYAxisData = '[]';

  String _chart2XAxisData = '[]';
  String _chart2YAxisData1 = '[]';
  String _chart2YAxisData2 = '[]';
  String _chart2YAxisData3 = '[]';
  final List<String> _tableTitleList = [' ', '매출액', '영업이익', '당기순이익'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            _isQuart = widget.initIsQuart;
            _requestTrSearch10();
          }),
        });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          _setInfoView(),
          const Text(
            '기업의 실적 성적',
            style: TStyle.title18T,
          ),
          const SizedBox(
            height: 15,
          ),
          _setDivButtons(),
          const SizedBox(
            height: 10,
          ),
          _setSubDivView(),
          const SizedBox(
            height: 10,
          ),
          _isNoData == 'Y'
              ? _setNoDataView()
              : _isNoData == 'N'
                  ? _setDataView()
                  : const SizedBox(
                      height: 100,
                    ),
        ],
      ),
    );
  }

  Widget _setInfoView() {
    if (_listData.isEmpty ||
        _confirmSearch10Sales.tradeDate.isEmpty ||
        _confirmSearch10Sales.sales.isEmpty) {
      return const SizedBox();
    }
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: UIStyle.boxNewBasicGrey10(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${_confirmSearch10Sales.tradeDate.substring(0, 4)}년 ${_confirmSearch10Sales.quarter}분기',
                    style: TStyle.subTitle16,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    '잠정실적',
                    style: TStyle.textMBuy,
                  )
                ],
              ),
              Text(
                '${TStyle.getDateSlashFormat3(_confirmSearch10Sales.issueDate)}발표',
                style: TStyle.contentGrey13,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '매출액',
                style: TextStyle(
                  fontSize: 16,
                  color: RColor.new_basic_text_color_strong_grey,
                ),
              ),
              _confirmSearch10Sales.sales.isEmpty
                  ? const Text(
                      '- ',
                      style: TStyle.commonTitle,
                    )
                  : Row(
                      children: [
                        Text(
                          TStyle.getComboUnitWithMoneyPointByDouble(
                            _confirmSearch10Sales.sales,
                          ),
                          style: TStyle.commonTitle,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _confirmSearch10Sales.salesIncRateYoY.isEmpty
                              ? ''
                              : '(YoY ${TStyle.getPercentString(_confirmSearch10Sales.salesIncRateYoY)})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TStyle.getMinusPlusColor(
                              _confirmSearch10Sales.salesIncRateYoY,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '영업이익',
                style: TextStyle(
                  fontSize: 16,
                  color: RColor.new_basic_text_color_strong_grey,
                ),
              ),
              _confirmSearch10Sales.salesProfit.isEmpty
                  ? const Text(
                      '- ',
                      style: TStyle.commonTitle,
                    )
                  : Row(
                      children: [
                        Text(
                          TStyle.getBillionUnitWithMoneyPointByDouble(
                            _confirmSearch10Sales.salesProfit,
                          ),
                          style: TStyle.commonTitle,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _confirmSearch10Sales.profitIncRateYoY.isEmpty
                              ? ''
                              : '(YoY ${TStyle.getPercentString(_confirmSearch10Sales.profitIncRateYoY)})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TStyle.getMinusPlusColor(
                                _confirmSearch10Sales.profitIncRateYoY),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '당기순이익',
                style: TextStyle(
                  fontSize: 16,
                  color: RColor.new_basic_text_color_strong_grey,
                ),
              ),
              _confirmSearch10Sales.netProfit.isEmpty
                  ? const Text(
                      '- ',
                      style: TStyle.commonTitle,
                    )
                  : Row(
                      children: [
                        Text(
                          TStyle.getBillionUnitWithMoneyPointByDouble(
                              _confirmSearch10Sales.netProfit),
                          style: TStyle.commonTitle,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _confirmSearch10Sales.netIncRateYoY.isEmpty
                              ? ''
                              : '(YoY ${TStyle.getPercentString(_confirmSearch10Sales.netIncRateYoY)})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TStyle.getMinusPlusColor(
                                _confirmSearch10Sales.netIncRateYoY),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _isSalesPerformance ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '매출 성적',
                  style: _isSalesPerformance
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (!_isSalesPerformance) {
                setState(
                  () {
                    _isSalesPerformance = true;
                    _initChart1Data();
                  },
                );
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
                border: Border.all(
                  width: 1.4,
                  color: !_isSalesPerformance ? Colors.black : RColor.lineGrey,
                ),
              ),
              child: Center(
                child: Text(
                  '수익성 흐름',
                  style: !_isSalesPerformance
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_isSalesPerformance) _isSalesPerformance = false;
              _initChart2Data();
            },
          ),
        ),
      ],
    );
  }

  Widget _setSubDivView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _isQuart ? Colors.white : RColor.btnUnSelectGreyBg,
            border: Border.all(
              width: 1.2,
              color: _isQuart ? Colors.black : RColor.btnUnSelectGreyStroke,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(
                5,
              ),
            ),
          ),
          child: InkWell(
            child: Center(
              child: Text(
                '분기',
                style: TextStyle(
                  color: _isQuart ? Colors.black : RColor.btnUnSelectGreyText,
                  fontSize: 15,
                ),
              ),
            ),
            onTap: () {
              if (!_isQuart) {
                _isQuart = true;
                _requestTrSearch10();
              }
            },
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
          decoration: BoxDecoration(
            color: _isQuart ? RColor.btnUnSelectGreyBg : Colors.white,
            border: Border.all(
              width: 1.2,
              color: _isQuart ? RColor.btnUnSelectGreyStroke : Colors.black,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(
                5,
              ),
            ),
          ),
          child: InkWell(
            child: Center(
              child: Text(
                '연간',
                style: TextStyle(
                  color: _isQuart ? RColor.btnUnSelectGreyText : Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            onTap: () {
              if (_isQuart) {
                _isQuart = false;
                _requestTrSearch10();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setChart1View() {
    // <div display="flex">\${marker}  \${seriesName}  ${_chart1LeftYAxisUpUnit ? '\${(value/1000).toFixed(1)}천억' : '\${value}억'}</div>
    var minValue = _findSalesMinValue;
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Echarts(
        //reloadAfterInit: true,
        extraScript: '''

        ''',
        option: '''
        {
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'cross'
                },
                formatter: function (params) {
                  let tooltip = `\${params[0].axisValue}`;
                  params.forEach(({ marker, seriesName, value }) => {
                    value = value || [0];
                    tooltip += `
                    <div display="flex">\${marker}  \${seriesName}  \${value}억</div>                                     
                    `;
                  });
                  return tooltip;
                },
            },
            legend: {
              top: 'bottom',
            },
            grid: {
                left: '12%',
                right: '12%',
                top: '15%',
                bottom: '20%',
            },
            xAxis: {
                type: 'category',
                data: $_chart1XAxisData,
                axisLine: {
                    show: true,
                    onZero: false,
                },
                axisLabel: {
                    fontSize: 9,
                },
            },
            yAxis: [
                {
                    type: 'value',
                    min: ${double.parse((minValue - (minValue * 0.15)).toStringAsFixed(0))},
                    axisLine: {
                        show: false,
                    },
                    splitLine: {
                        show: true,
                    },
                    name: "${_chart1LeftYAxisUpUnit ? '매출액(천억)' : '매출액(억)'}",
                    nameLocation: 'end',
                    //nameGap: 26,
                    nameTextStyle: {
                      align: 'center',
                      fontSize: 11,
                      color: '#8C8C8C',
                    },
                    axisLabel: {
                      formatter: function(value) {
                        if(value == '${double.parse((minValue - (minValue * 0.15)).toStringAsFixed(0))}'){
                          return '0';
                        }
                        return ${_chart1LeftYAxisUpUnit ? '(value/1000).toFixed(1)' : 'value'};
                        //return value;
                      },                     
                    }
                },
                {
                    type: 'value',
                    axisLine: {
                        show: false,
                    },
                    splitLine: {
                        show: false,
                    },
                    name: "${_chart1RightYAxisUpUnit ? '영업이익(천억)' : '영업이익(억)'}",
                    nameLocation: 'end',
                    nameTextStyle: {
                      align: 'center',
                      fontSize: 11,
                      color: '#8C8C8C',
                    },
                    axisLabel: {
                      formatter: function(value) {
                        return ${_chart1RightYAxisUpUnit ? 'value/1000' : 'value'};
                      },                     
                    }
                },
            ],
            series: [
                {
                    name: '매출액',
                    data: $_chart1BarYAxisData,
                    type: 'bar',
                    color: '#DCDFE2',
                    emphasis: {
                      itemStyle:{
                        color: '#DCDFE2',
                      }
                    },
                },
                {
                    name: '영업이익',
                    data: $_chart1YAxisData1,
                    type: 'line',
                    yAxisIndex: 1,
                    splitLine: {
                        show: false,
                    },
                    color: '#FF5050',
                },
                {
                    name: '당기순이익',
                    data: $_chart1YAxisData2,
                    type: 'line',
                    yAxisIndex: 1,
                    splitLine: {
                        show: false,
                    },
                    color: '#5DD68D',
                },
            ],
        }
        ''',
      ),
    );
  }

  Widget _setChart2View() {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Echarts(
        reloadAfterInit: true,
        extraScript: '''

        ''',
        option: '''
        {
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'cross',
                },                
                formatter: function (params) {
                  let tooltip = `\${params[0].axisValue}`;
            
                  params.forEach(({ marker, seriesName, value }) => {
                    value = value || [0];
                    tooltip += `
                    <div display="flex">\${marker}  \${seriesName}  \${value}%</div>
                    `;
                  });
                  return tooltip;
                },
            },
            legend: {
              top: 'bottom',
            },
            grid: {
                left: '5%',
                right: '12%',
                top: '10%',
                bottom: '26%',
            },
            xAxis: {
                type: 'category',
                data: $_chart2XAxisData,
                axisLine: {
                    show: true,
                    onZero: false,
                },
                axisLabel: {
                    fontSize: 9,
                },
            },
            yAxis: [
                {
                    type: 'value',
                    axisLine: {
                        show: false,
                    },
                    position: 'right',
                    splitLine: {
                        show: true,
                    },
                },
            ],
            series: [
                {
                    name: '매출액증감률',
                    data: $_chart2YAxisData1,
                    type: 'line',
                    splitLine: {
                        show: false,
                    },
                    color: '#FF5050',
                },
                {
                    name: '영업이익증감률',
                    data: $_chart2YAxisData2,
                    type: 'line',
                    splitLine: {
                        show: false,
                    },
                    color: '#5DD68D',
                },
                {
                    name: '당기순이익증감률',
                    data: $_chart2YAxisData3,
                    type: 'line',
                    splitLine: {
                        show: false,
                    },
                    color: '#5886FE',
                },
            ],
        }
        ''',
      ),
    );
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(
        top: 10,
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
                    fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _isQuart ? "분기 실적이 없습니다." : "연간 실적이 없습니다.",
            style: const TextStyle(
                fontSize: 14, color: RColor.new_basic_text_color_grey),
          ),
        ],
      ),
    );
  }

  Widget _setDataView() {
    return Column(
      children: [
        _isSalesPerformance ? _setChart1View() : _setChart2View(),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: List.generate(
              _listData.length + 1,
              (index) => _setTableRow(index),
            ),
          ),
        ),
      ],
    );
  }

  // 차트 1 아래 표
  _setTableRow(int row) {
    return TableRow(
      children: List.generate(
        4,
        (index) => _setTableView(row, index),
      ),
    );
  }

  _setTableView(int row, int column) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 1,
          color: row == 0 ? RColor.bgTableTextGrey : RColor.lineGrey,
        ),
        row == 0
            ? Container(
                color: RColor.bgTableGrey,
                alignment: Alignment.center,
                height: 32,
                child: _setTitleView(column),
              )
            : _setValueView(row - 1, column),
        Visibility(
          visible: _listData.length == row,
          child: Container(
            height: 1,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ],
    );
  }

  _setTitleView(int column) {
    return FittedBox(
      child: Text(
        _tableTitleList[column],
        style: const TextStyle(
          fontSize: 16,
          color: RColor.bgTableTextGrey,
        ),
      ),
    );
  }

  _setValueView(int row, int column) {
    String value = ' ';
    var item = _listDataTable[row];
    if (column == 0) {
      value = _isQuart ? '${item.year}/${item.quarter}Q' : item.year;
      return SizedBox(
        height: 50,
        child: Center(
          child: FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: RColor.bgTableTextGrey,
              ),
            ),
          ),
        ),
      );
    } else if (column == 1) {
      value = _listDataTable[row].sales.isEmpty
          ? '-'
          : TStyle.getBillionUnitWithMoneyPointByDouble(
              _listDataTable[row].sales);
      return SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
            ),
            Visibility(
              visible: item.salesIncRateYoY.isNotEmpty,
              child: Text(
                '(${TStyle.getPercentString(item.salesIncRateYoY)})',
              ),
            ),
          ],
        ),
      );
    } else if (column == 2) {
      value = _listDataTable[row].salesProfit.isEmpty
          ? '-'
          : TStyle.getBillionUnitWithMoneyPointByDouble(
              _listDataTable[row].salesProfit);
      return SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
            ),
            Visibility(
              visible: item.profitIncRateYoY.isNotEmpty,
              child: Text(
                '(${TStyle.getPercentString(item.profitIncRateYoY)})',
              ),
            ),
          ],
        ),
      );
    } else if (column == 3) {
      value = (_listDataTable[row].netProfit.isEmpty) ||
              (_listDataTable[row].confirmYn == 'N' && value == '0')
          ? '-'
          : TStyle.getBillionUnitWithMoneyPointByDouble(
              _listDataTable[row].netProfit);
      return SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value),
            Visibility(
              visible: item.netIncRateYoY.isNotEmpty
                  ? (_listDataTable[row].confirmYn == 'N' && value == '0')
                      ? false
                      : true
                  : false,
              child: Text(
                '(${TStyle.getPercentString(item.netIncRateYoY)})',
              ),
            ),
          ],
        ),
      );
    }
  }

  _initChart1Data() {
    _chart1LeftYAxisUpUnit = _findSalesAbsMaxValue >= 1000;
    _chart1RightYAxisUpUnit = _findSalesAndNetProfitMaxValue >= 1000;
    _chart1XAxisData = '[';
    _chart1BarYAxisData = '[';
    _chart1YAxisData1 = '[';
    _chart1YAxisData2 = '[';
    for (var element in _listData) {
      _chart1XAxisData += _isQuart
          ? "'${element.year.substring(2, 4)}/${element.quarter}Q',"
          : "'${element.year}',";
      _chart1BarYAxisData += "${element.sales.isEmpty ? 0 : element.sales},";
      _chart1YAxisData1 +=
          "${element.salesProfit.isEmpty ? 0 : element.salesProfit},";
      _chart1YAxisData2 +=
          "${element.netProfit.isEmpty ? 0 : element.netProfit},";
    }
    _chart1XAxisData += ']';
    _chart1BarYAxisData += ']';
    _chart1YAxisData1 += ']';
    _chart1YAxisData2 += ']';
    setState(() {});
  }

  _initChart2Data() {
    _chart2XAxisData = '[';
    _chart2YAxisData1 = '[';
    _chart2YAxisData2 = '[';
    _chart2YAxisData3 = '[';
    for (var element in _listData) {
      _chart2XAxisData += _isQuart
          ? "'${element.year.substring(2, 4)}/${element.quarter}Q',"
          : "'${element.year}',";
      _chart2YAxisData1 += "${element.salesIncRateYoY},";
      _chart2YAxisData2 += "${element.profitIncRateYoY},";
      _chart2YAxisData3 += "${element.netIncRateYoY},";
    }
    _chart2XAxisData += ']';
    _chart2YAxisData1 += ']';
    _chart2YAxisData2 += ']';
    _chart2YAxisData3 += ']';
    setState(() {});
  }

  // 매출액 최대값
  double get _findSalesMaxValue {
    if (_listData.length < 2) {
      return 0;
    }
    var item = _listData.reduce((curr, next) =>
        (double.tryParse(curr.sales) ?? 0) > (double.tryParse(next.sales) ?? 0)
            ? curr
            : next);
    return (double.tryParse(item.sales) ?? 0);
  }

  // 매출액 최소값
  double get _findSalesMinValue {
    if (_listData.length < 2) {
      return 0;
    }
    var item = _listData.reduce((curr, next) =>
        (double.tryParse(curr.sales) ?? 0) < (double.tryParse(next.sales) ?? 0)
            ? curr
            : next);
    return (double.tryParse(item.sales) ?? 0);
  }

  // 매출액 절대 최대값
  double get _findSalesAbsMaxValue {
    if (_listData.length < 2) {
      return 0;
    }
    var item = _listData.reduce((curr, next) =>
        (double.tryParse(curr.sales) ?? 0).abs() >
                (double.tryParse(next.sales) ?? 0).abs()
            ? curr
            : next);
    return (double.tryParse(item.sales) ?? 0).abs();
  }

  // 매출액 매출 성적 - 영업이익/당기순이익 중 최대값
  double get _findSalesAndNetProfitMaxValue {
    if (_listData.length < 2) {
      return 0;
    }
    var item1 = _listData.reduce(
      (curr, next) => (double.tryParse(curr.salesProfit) ?? 0) >
              (double.tryParse(next.salesProfit) ?? 0)
          ? curr
          : next,
    );
    var item2 = _listData.reduce(
      (curr, next) => (double.tryParse(curr.netProfit) ?? 0) >
              (double.tryParse(next.netProfit) ?? 0)
          ? curr
          : next,
    );
    return (double.tryParse(item1.salesProfit) ?? 0) >=
            (double.tryParse(item2.netProfit) ?? 0)
        ? (double.tryParse(item1.salesProfit) ?? 0)
        : (double.tryParse(item2.netProfit) ?? 0);
  }

  _requestTrSearch10() async {
    _fetchPosts(
      TR.SEARCH10,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _appGlobal.stkCode,
          'selectDiv': _isQuart ? 'QUART' : 'YEAR',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.w('$trStr $json');

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
    // NOTE 종목 실적 데이터 조회 ( 기업의 안정성 지표 )
    if (trStr == TR.SEARCH10) {
      final TrSearch10 resData = TrSearch10.fromJson(jsonDecode(response.body));
      _listData.clear();
      _listDataTable.clear();
      _isNoData = 'Y';
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.listSales.isNotEmpty) {
          //_listData.addAll(resData.retData.listSales);
          _confirmSearch10Sales = Search10Sales();
          for (var e in resData.retData.listSales) {
              if (e.sales.isNotEmpty ||
                  e.salesProfit.isNotEmpty ||
                  e.netProfit.isNotEmpty) {
                _listData.add(e);
              }
              if (_isQuart && e.confirmYn == 'N') {
                _confirmSearch10Sales = e;
              }
            }
          _listDataTable.addAll(
            List.from(
              _listData.reversed,
            ),
          );
          _isNoData = 'N';
          _isSalesPerformance ? _initChart1Data() : _initChart2Data();
        } else {
          setState(() {
            _confirmSearch10Sales = Search10Sales();
          });
        }
      } else {
        setState(() {
          _confirmSearch10Sales = Search10Sales();
        });
      }
    }
  }
}
