import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare02.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare07.dart';

import '../../../../common/const.dart';
import '../../../../common/ui_style.dart';
import '../../../../models/pg_data.dart';
import '../../../models/none_tr/app_global.dart';
import '../../common/common_popup.dart';
import '../../main/base_page.dart';
import '../page/stock_compare_page.dart';

/// 2023.02.16_HJS
/// 종목홈(개편)_홈_종목비교 카드 + 시가총액/매출액/영업이익 차트

class StockHomeHomeTileStockCompare extends StatefulWidget {
  static final GlobalKey<StockHomeHomeTileStockCompareState> globalKey = GlobalKey();

  StockHomeHomeTileStockCompare() : super(key: globalKey);

  @override
  State<StockHomeHomeTileStockCompare> createState() => StockHomeHomeTileStockCompareState();
}

class StockHomeHomeTileStockCompareState extends State<StockHomeHomeTileStockCompare> {
  String _userId = '';
  final _appGlobal = AppGlobal();
  String _stockCode = '';
  String _stockName = '';

  StockGroup _stockGroup = StockGroup.empty(); // 종목비교 데이터 1
  Compare02 _compare02 = constCompare02; // 종목비교 데이터 2
  int _stockCompareDiv = 0; // 0 : 시가총액 / 1 : 매출액 / 2 : 영업이익
  final List<YearQuarterClass> _listYQClass = []; // 년도/쿼터 반영 종목 부분 리스트
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 억, true 이면 천억
  String _year = ''; // ~ 년도 + 분기 반영 종목 표기
  String _quarter = ''; // ~ 년도 + 분기 반영 종목 표기

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _stockCode = _appGlobal.stkCode;
    _stockName = _appGlobal.stkName;
    _stockCompareDiv = 0;
    _requestTrAll();
  }

  @override
  void initState() {
    super.initState();
    _userId = _appGlobal.userId;
    initPage();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _checkStockCompareViewVisible(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '종목비교',
                  style: TStyle.title18T,
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${TStyle.getPostWord(_stockName, '과', '와')} 같은 ',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _stockGroup.stockGrpNm,
                          style: const TextStyle(
                            fontSize: 16,
                            color: RColor.mainColor,
                          ),
                        ),
                        const Text(
                          ' 그룹에 속한',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '다른 종목들도 비교해 보세요.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                _setDivButtons(),
                const SizedBox(
                  height: 20,
                ),

                // 테이블 _ 하단 : 데이터 반영 기준일 + base data 표시
                Visibility(
                  visible: _compare02.listStock.isNotEmpty && _year.isNotEmpty && _quarter.isNotEmpty,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_year/${_quarter}Q반영 연환산',
                      style: const TextStyle(
                        fontSize: 11,
                        color: RColor.new_basic_text_color_grey,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: BarChart(
                    swapAnimationCurve: Curves.fastOutSlowIn,
                    swapAnimationDuration: const Duration(milliseconds: 1500),
                    BarChartData(
                      barTouchData: barTouchData,
                      titlesData: titlesData,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: barGroupsData,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: Colors.grey,
                          strokeWidth: 0.6,
                          dashArray: [2, 2],
                        ),
                        drawVerticalLine: false,
                      ),
                      alignment: BarChartAlignment.spaceAround,
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 0.00000001,
                            color: RColor.lineGrey,
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                _makeTableQuarterInfo(),

                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    // 종목비교 상세
                    basePageState.callPageRouteData(
                      StockComparePage(),
                      PgData(
                        stockName: _stockName,
                        stockCode: _stockCode,
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: UIStyle.boxRoundLine6(),
                    alignment: Alignment.center,
                    child: const Text(
                      '다른 기준의 비교보기',
                      style: TStyle.subTitle16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: RColor.new_basic_grey,
            height: 15.0,
          ),
        ],
      ),
    );
  }

  bool _checkStockCompareViewVisible() {
    return _stockGroup.stockGrpNm.isNotEmpty &&
        _stockGroup.stockGrpCd.isNotEmpty &&
        _compare02.listStockGroup.isNotEmpty &&
        _compare02.listStock.length > 1;
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
                  color: _stockCompareDiv == 0 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '시가총액',
                  style: _stockCompareDiv == 0
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_stockCompareDiv != 0) {
                setState(
                  () {
                    _stockCompareDiv = 0;
                    _compare02.listStock.sort(
                      (a, b) {
                        return double.parse(b.marketValue).compareTo(double.parse(a.marketValue));
                      },
                    );
                    _isRightYAxisUpUnit = _findMaxValue >= 1000;
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
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.4,
                    color: _stockCompareDiv == 1 ? Colors.black : RColor.lineGrey,
                  ),
                  vertical: BorderSide(
                    width: _stockCompareDiv == 1 ? 1.4 : 0,
                    color: _stockCompareDiv == 1 ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '매출액',
                  style: _stockCompareDiv == 1
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_stockCompareDiv != 1) {
                setState(() {
                  _stockCompareDiv = 1;
                  _compare02.listStock.sort(
                    (a, b) {
                      return double.parse(b.sales).compareTo(double.parse(a.sales));
                    },
                  );
                  _isRightYAxisUpUnit = _findMaxValue >= 1000;
                });
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
                border: Border.all(
                  width: 1.4,
                  color: _stockCompareDiv == 2 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '영업이익',
                  style: _stockCompareDiv == 2
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_stockCompareDiv != 2) {
                setState(() {
                  _stockCompareDiv = 2;
                  _compare02.listStock.sort(
                    (a, b) {
                      return double.parse(b.salesProfit).compareTo(double.parse(a.salesProfit));
                    },
                  );
                  _isRightYAxisUpUnit = _findMaxValue >= 1000;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _makeTableQuarterInfo() {
    // 테이블 _ 하단 : 종목 반영 년도 + 분기 표시

    List<StockCompare02> vAlStockCompare02 = [];
    vAlStockCompare02.addAll(_compare02.listStock);

    _listYQClass.clear();
    for (int i = 0; i < vAlStockCompare02.length; i++) {
      var item = vAlStockCompare02[i];
      if (item.latestQuarter.isNotEmpty) {
        String itemYear = item.latestQuarter.substring(0, 4);
        String itemQ = item.latestQuarter.substring(5);
        bool isSame = false;
        for (int k = 0; k < _listYQClass.length; k++) {
          if (itemYear == _listYQClass[k].year && itemQ == _listYQClass[k].quarter) {
            isSame = true;
            _listYQClass[k].listStockName.add(item.stockName);
            break;
          }
        }
        if (!isSame) {
          List<String> vListStockName = [item.stockName];
          _listYQClass.add(YearQuarterClass(itemYear, itemQ, vListStockName));
        }
      }
    }

    _listYQClass.sort((a, b) => b.quarter.compareTo(a.quarter));
    _listYQClass.sort((a, b) => b.year.compareTo(a.year));

    return Visibility(
      visible: vAlStockCompare02.isNotEmpty,
      child: Container(
        decoration: UIStyle.boxNewBasicGrey10(),
        padding: const EdgeInsets.all(20),
        child: TileYearQuarterListView(_listYQClass),
      ),
    );
  }

  _requestTrAll() async {
    // DEFINE 종목 비교
    _fetchPosts(
      TR.COMPARE07,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

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
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.COMPARE07) {
      final TrCompare07 resData = TrCompare07.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Compare07 compare07 = resData.retData;
        if (compare07.listStockGroup.isNotEmpty) {
          _stockGroup = compare07.listStockGroup[0];

          // DEFINE 종목 비교
          _fetchPosts(
            TR.COMPARE02,
            jsonEncode(
              <String, String>{
                'userId': _userId,
                'stockCode': _stockCode,
                'stockGrpCd': _stockGroup.stockGrpCd,
                'selectDiv': 'SCALE',
              },
            ),
          );
        } else {
          _stockGroup = StockGroup.empty();
        }
      } else {
        _stockGroup = StockGroup.empty();
      }
    }

    // NOTE 종목 비교 2 차트뷰
    else if (trStr == TR.COMPARE02) {
      _compare02 = constCompare02;
      _year = '';
      _quarter = '';
      final TrCompare02 resData = TrCompare02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _compare02 = resData.retData;
        _compare02.listStock.sort(
          (a, b) {
            return double.parse(b.marketValue).compareTo(double.parse(a.marketValue));
          },
        );

        _isRightYAxisUpUnit = _findMaxValue >= 1000;
        _year = _compare02.year;
        _quarter = _compare02.quarter;
      } else {
        _compare02 = constCompare02;
      }
      setState(() {});
    }
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 0,
          getTooltipColor: (group) => Colors.transparent,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              TStyle.getBillionUnitWithMoneyPointByDouble(
                rod.toY.round().toString(),
              ),
              TextStyle(
                color: rod.color == RColor.chartGreyColor ? RColor.new_basic_text_color_grey : rod.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    var item = _compare02.listStock[value.toInt()];
    final style = TextStyle(
      color: item.stockName == _stockName ? RColor.sigBuy : RColor.new_basic_text_color_grey,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 150.2,
      space: 20,
      child: Text(_compare02.listStock[value.toInt()].stockName, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: getTitles,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget rightTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    //var axisValue = _isRightYAxisUpUnit ? value.round() / 1000 : value.round();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        _isRightYAxisUpUnit
            ? '${(value.round() / 1000).floor()}'
            : TStyle.getMoneyPoint(
                value.round().toString(),
              ),
        style: const TextStyle(
          fontSize: 12,
          color: RColor.new_basic_text_color_grey,
        ),
      ),
    );
  }

  List<BarChartGroupData> get barGroupsData => List.generate(
        _compare02.listStock.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              width: 16,
              color: _compare02.listStock[index].stockCode == _stockCode ? RColor.sigBuy : RColor.chartGreyColor,
              toY: _stockCompareDiv == 0
                  ? double.parse(_compare02.listStock[index].marketValue)
                  : _stockCompareDiv == 1
                      ? double.parse(_compare02.listStock[index].sales)
                      : double.parse(_compare02.listStock[index].salesProfit),
              //borderRadius: BorderRadius.zero,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );

  double get _findMaxValue {
    if (_compare02.listStock.length < 2) {
      return 0;
    } else {
      if (_stockCompareDiv == 0) {
        var item = _compare02.listStock
            .reduce((curr, next) => double.parse(curr.marketValue) > double.parse(next.marketValue) ? curr : next);
        return double.parse(item.marketValue);
      } else if (_stockCompareDiv == 1) {
        var item = _compare02.listStock
            .reduce((curr, next) => double.parse(curr.sales) > double.parse(next.sales) ? curr : next);
        return double.parse(item.sales);
      } else if (_stockCompareDiv == 2) {
        var item = _compare02.listStock
            .reduce((curr, next) => double.parse(curr.salesProfit) > double.parse(next.salesProfit) ? curr : next);
        return double.parse(item.salesProfit);
      } else {
        return 0;
      }
    }
  }
}
