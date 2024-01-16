import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:charts_common/common.dart' as charts_common;
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:charts_flutter_new/src/text_element.dart'
    as charts_text_element;
import 'package:charts_flutter_new/src/text_style.dart' as charts_text_style;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search11.dart';
import 'package:rassi_assist/ui/stock_home/tile/result_analyze_tile_chart1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/d_log.dart';
import '../../../common/net.dart';
import '../../common/common_popup.dart';

/// 2023.03.24_HJS
/// 실적분석 상세 페이지
class ResultAnalyzePage extends StatefulWidget {
  static const String TAG = "[ResultAnalyzePage]";
  static const String TAG_NAME = '실적분석';

  const ResultAnalyzePage({Key? key}) : super(key: key);

  @override
  State<ResultAnalyzePage> createState() => _ResultAnalyzePageState();
}

class _ResultAnalyzePageState extends State<ResultAnalyzePage> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _stockCode = '';
  String _stockName = '';
  bool _initChart1IsQuart = true;

  // 기업의 안정성 지표
  bool _isPer = true;
  List<charts.Series<Search11PerPbr, String>> _chart3SeriesListData = [];
  final List<Search11PerPbr> _listPerPbrData = [];
  final List<Search11Dividend> _listDividendData = [];

  // 기업의 배당 정보
  final List<String> _tableTitleList = ['', '주당배당금', '배당수익률'];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      ResultAnalyzePage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            PgData pgData = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                pgData.stockCode != null &&
                pgData.stockCode.isNotEmpty &&
                pgData.stockName.isNotEmpty) {
              _stockName = pgData.stockName;
              _stockCode = pgData.stockCode;
              //_initChart1IsQuart = _pgData.booleanData ?? true;
              _requestTrSearch11();
            }
          }),
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
  }

  @override
  Widget build(BuildContext context) {
    _initChart1IsQuart =
        ((ModalRoute.of(context)!.settings.arguments) as PgData).booleanData ??
            true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _stockName.length > 8
              ? '${_stockName.substring(0, 8)} 실적분석'
              : '$_stockName 실적분석',
          style: TStyle.title18T,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: false,
        leadingWidth: 25,
      ),
      body: SafeArea(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 기업의 실적 성적
                  ResultAnalyzeTileChart1(initIsQuart: _initChart1IsQuart),
                  Container(
                    height: 35,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 15,
                          color: RColor.new_basic_grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // 기업의 안정성 지표
                  _setIndicatorsOfFirmStabilityView(),
                  Container(
                    height: 35,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 15,
                          color: RColor.new_basic_grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // 기업의 배당 정보
                  _setCorporateDividendInformationView(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 기업의 안정성 지표
  Widget _setIndicatorsOfFirmStabilityView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Row(
              children: const [
                Text(
                  '기업의 안정성 지표',
                  style: TStyle.title18T,
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.info_outline,
                  color: RColor.new_basic_text_color_grey,
                  size: 18,
                ),
              ],
            ),
            onTap: () {
              _showBottomSheetPerPbrInfo();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          _setDivButtons(),
          const SizedBox(
            height: 20,
          ),
          _listPerPbrData.length > 0
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '최근1년',
                          style: TextStyle(
                              fontSize: 11,
                              color: RColor.new_basic_text_color_grey),
                        ),
                        Text(
                          '(배)',
                          style: TextStyle(
                              fontSize: 11,
                              color: RColor.new_basic_text_color_grey),
                        ),
                      ],
                    ),
                    _setChart3View(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: RColor.chartGreyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          _isPer ? '  PER' : '  PBR',
                          style: const TextStyle(
                              fontSize: 11,
                              color: RColor.new_basic_text_color_grey),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 7,
                          height: 7,
                          //color: Color(0xff6565FF),
                          decoration: const BoxDecoration(
                            color: Color(0xff454A63),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text(
                          '  주가',
                          style: TextStyle(
                              fontSize: 11,
                              color: RColor.new_basic_text_color_grey),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      '* PER, PBR : 전일 보통주 수정주가 / 최근 분기 EPS, BPS',
                      style: TStyle.contentGrey12,
                    ),
                  ],
                )
              : _setNoDataView(_isPer ? 'PER 지표가 없습니다.' : 'PBR 지표가 없습니다.'),
        ],
      ),
    );
  }

  // 기업의 배당 정보
  Widget _setCorporateDividendInformationView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기업의 배당 정보',
            style: TStyle.title18T,
          ),
          _listDividendData.length > 0
              ? Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    _setChart4View(),
                    const SizedBox(
                      height: 20,
                    ),
                    Table(
                      children: List.generate(
                        _listDividendData.length + 1,
                        (index) => _setTableRow(index),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    _setNoDataView('기업의 배당 정보가 없습니다.'),
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
                  color: _isPer ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'PER',
                  style: _isPer
                      ? TStyle.commonTitle15
                      : const TextStyle(
                    fontSize: 15,
                    color: RColor.lineGrey,
                  ),
                ),
              ),
            ),
            onTap: () {
              if (!_isPer) {
                setState(
                  () {
                    _isPer = true;
                    _initChart3Data();
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
                  color: !_isPer ? Colors.black : RColor.lineGrey,
                ),
              ),
              child: Center(
                child: Text(
                  'PBR',
                  style: !_isPer
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_isPer) {
                setState(() {
                  _isPer = false;
                  _initChart3Data();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setChart3View() {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: charts.OrdinalComboChart(
        _chart3SeriesListData,
        animate: true,
        primaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            zeroBound: false,
          ),
          showAxisLine: false,
          renderSpec: charts.NoneRenderSpec(),
        ),
        secondaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec: const charts.BasicNumericTickProviderSpec(
              //desiredTickCount: 5,
              zeroBound: true,
            ),
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: charts.Color.fromHex(code: '#8C8C8C'),
              ),
              lineStyle: charts.LineStyleSpec(
                dashPattern: [2, 2],
                color: charts.Color.fromHex(code: '#DCDFE2'),
              ),
            )),
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            minimumPaddingBetweenLabelsPx: 30,
            labelOffsetFromTickPx: 20,
            labelOffsetFromAxisPx: 12,
            // Tick and Label styling here.
            labelStyle: charts.TextStyleSpec(
              fontSize: 10, // size in Pts.
              color: charts.Color.fromHex(code: '#8C8C8C'),
            ),
            // Change the line colors to match text color.
            lineStyle: charts.LineStyleSpec(
              //dashPattern: [2,2],
              color: charts.Color.fromHex(code: '#DCDFE2'),
            ),
          ),
        ),
        selectionModels: [
          charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  int? selectIndex = model.selectedDatum[0].index;
                  if(selectIndex != null) {
                    CustomCircleSymbolRenderer.search11perPbr = _listPerPbrData[selectIndex];
                  }
                  CustomCircleSymbolRenderer.isPer = _isPer;
                }
              })
        ],
        customSeriesRenderers: [
          charts.LineRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'line',
            layoutPaintOrder: 30,
            strokeWidthPx: 1.5,
          )
        ],
        behaviors: [
          charts.LinePointHighlighter(
            symbolRenderer: CustomCircleSymbolRenderer(
              MediaQuery.of(context).size.width,
            ), // add this line in behaviours
          ),
        ],
      ),
    );
  }

  Widget _setChart4View() {
    if (_listDividendData.length < 1) {
      return const SizedBox(
        width: 1,
        height: 1,
      );
    }
    final _lineBarsData = [
      LineChartBarData(
        showingIndicators: _getShowingIndicatorsIndexList,
        color: RColor.lineGrey,
        dashArray: [4, 2],
        spots: _listDividendData
            .asMap()
            .entries
            .map(
              (e) => FlSpot(
                e.key.toDouble(),
                double.parse(e.value.dividendRate),
              ),
            )
            .toList(),
        isCurved: false,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, p1, p2, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: index == _listDividendData.length - 1
                  ? RColor.mainColor
                  : RColor.lineGrey,
              strokeWidth: 0,
              //strokeColor: Colors.blue,
            );
          },
        ),
      ),
    ];
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(
          height: 80,
          child: LineChart(
            LineChartData(
              titlesData: _getChart4TitlesData,
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              backgroundColor: Colors.transparent,
              showingTooltipIndicators:
                  _getShowingIndicatorsIndexList.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    _lineBarsData[0],
                    _lineBarsData.indexOf(_lineBarsData[0]),
                    _lineBarsData[0].spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                enabled: false,
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: Colors.transparent,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: index == _listDividendData.length - 1
                              ? RColor.mainColor
                              : RColor.lineGrey,
                          strokeWidth: 0,
                          //strokeColor: Colors.brown,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  //tooltipRoundedRadius: 8,
                  tooltipPadding: EdgeInsets.zero,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        '${lineBarSpot.y.toString()}%',
                        TextStyle(
                          color: lineBarSpot.x.toInt() ==
                                  _listDividendData.length - 1
                              ? RColor.mainColor
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              //minY: _findMinTp.roundToDouble(),
              //maxY: _findMaxTp.roundToDouble() * 1.05,
              //baselineY: _findMinTp.roundToDouble(),
              lineBarsData: _lineBarsData,
            ),
          ),
        ),
      ),
    );
  }

  Widget _setNoDataView(String message) {
    return Container(
      width: double.infinity,
      height: 200,
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
            message,
            style: const TextStyle(
                fontSize: 14,
                color: RColor.new_basic_text_color_grey),
          ),
        ],
      ),
    );
  }

  List<int> get _getShowingIndicatorsIndexList {
    List<int> result = [];
    _listDividendData.asMap().forEach((key, value) {
      result.add(key);
    });
    return result;
  }

  FlTitlesData get _getChart4TitlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _chart4BottomTitleWidget,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget _chart4BottomTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      //angle: 150.2,
      //space: 20,
      child: Text(
        _listDividendData[value.toInt()].dividendYear,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  _setTableRow(int row) {
    return TableRow(
      children: List.generate(
        3,
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
            height: 32,
            alignment: Alignment.center,
            child: _setTitleView(column))
            : _setValueView(row - 1, column),
        Visibility(
          visible: _listDividendData.length == row,
          child: Container(
            height: 1,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ],
    );
  }

  _setTitleView(int column) {
    return Text(
      _tableTitleList[column],
      style: const TextStyle(
        fontSize: 16,
        color: RColor.bgTableTextGrey,
      ),
    );
  }

  _setValueView(int row, int column) {
    //var item = _listDividendData[row];
    var item = _listDividendData[_listDividendData.length - 1 - row];
    if (column == 0) {
      return SizedBox(
        height: 36,
        child: Center(
          child: Text(
            '${item.dividendYear}년',
            style: const TextStyle(
              fontSize: 14,
              color: RColor.bgTableTextGrey,
            ),
          ),
        ),
      );
    } else if (column == 1) {
      return SizedBox(
        height: 36,
        child: Center(
          child: Text(
            item.dividendAmt.isNotEmpty && item.dividendAmt != '0'
                ? '${TStyle.getMoneyPoint(item.dividendAmt)}원'
                : '0원',
          ),
        ),
      );
    } else if (column == 2) {
      return SizedBox(
        height: 36,
        child: Center(
          child: Text(
            '${TStyle.getMoneyPoint(item.dividendRate)}%'
          ),
        ),
      );
    }
  }

  _initChart3Data() {
    _chart3SeriesListData = [
      charts.Series<Search11PerPbr, String>(
        id: '주가',
        colorFn: (_, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Search11PerPbr xAxisItem, _) =>
            '${xAxisItem.tradeDate.substring(2, 4)}\'${xAxisItem.tradeDate.substring(4, 6)}',
        measureFn: (Search11PerPbr yAxisItem, _) =>
            int.parse(yAxisItem.tradePrice),
        data: _listPerPbrData,
      )..setAttribute(charts.rendererIdKey, 'line'),
      charts.Series<Search11PerPbr, String>(
        id: 'Per/Pbr',
        colorFn: (datum, index) => charts.Color.fromHex(code: '#DCDFE2'),
        domainFn: (Search11PerPbr xAxisItem, _) =>
            '${xAxisItem.tradeDate.substring(2, 4)}\'${xAxisItem.tradeDate.substring(4, 6)}',
        measureFn: (Search11PerPbr yAxisItem, _) {
          return _isPer
              ? double.tryParse(yAxisItem.per) == null
                  ? 0
                  : double.parse(yAxisItem.per)
              : double.tryParse(yAxisItem.pbr) == null
                  ? 0
                  : double.parse(yAxisItem.pbr);
        },
        data: _listPerPbrData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
  }

  _showBottomSheetPerPbrInfo() {
    // auto height 레이어
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            //horizontal: 10,
                          ), // 패딩 설정
                          constraints: const BoxConstraints(), // constraints
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'PER(주가수익비율)',
                        style: TStyle.title18T,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                          '주가가 그 회사 1주당 수익의 몇배가 되는가를 나타내는 지표로 주가를 1주당 순이익(EPS)로 나눈 것 입니다. 동종업계와 비교하여 저평가인지 고평가인지를 가늠해 볼 수 있으며, 성장주의 경우 높은 PER이 나올 수 있습니다.'),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'PBR(주가순자산비율)',
                        style: TStyle.title18T,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                          '현재 주가 1주당 순자산의 몇 배로 거래되고 있는지를 판단하는 지표 입니다. PBR은 개별 종목의 높고 낮음을 보기보다 동종업계의 평균과 비교하여 판단하는 것이 좋습니다.'),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _requestTrSearch11() async {
    String _jsonSEARCH11 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': _stockCode,
      },
    );
    await Future.wait(
      [
        _fetchPosts(
          TR.SEARCH11,
          _jsonSEARCH11,
        ),
      ],
    );
    setState(() {});
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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 기업의 배당 정보
    if (trStr == TR.SEARCH11) {
      final TrSearch11 resData = TrSearch11.fromJson(jsonDecode(response.body));
      _listPerPbrData.clear();
      _listDividendData.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.listPerPbr.isNotEmpty) {
          _listPerPbrData.addAll(resData.retData.listPerPbr);
          _initChart3Data();
        }
        if (resData.retData.listDividend.isNotEmpty) {
          _listDividendData.addAll(resData.retData.listDividend);
        }
      }
      setState(() {});
    }
  }
}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  final double deviceWidth;

  CustomCircleSymbolRenderer(this.deviceWidth);

  static late Search11PerPbr search11perPbr;
  static bool isPer = true;
  bool _isShow = false;
  double xPoint = 0;

  @override
  void paint(charts_common.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
        charts.Color? fillColor,
        charts.FillPatternType? fillPattern,
        charts.Color? strokeColor,
        double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    if (_isShow) {
      _isShow = false;
    } else {
      _isShow = true;

      double minWidth = bounds.width + 80;
      int valueLength =
      isPer ? search11perPbr.per.length : search11perPbr.pbr.length;
      if (valueLength > 6) {
        minWidth += 5 * (valueLength - 6);
      }

      xPoint = (deviceWidth / 2) > bounds.left
          ? bounds.left + 12
          : bounds.left - minWidth - 4;

      canvas.drawRect(
        Rectangle(xPoint, 0, minWidth, bounds.height + 62),
        fill: const charts.Color(
          r: 102,
          g: 102,
          b: 102,
          a: 200,
        ),
      );
      var textStyle = charts_text_style.TextStyle();
      textStyle.color = charts.Color.white;
      textStyle.fontSize = 12;

      String color = '#DCDFE2';
      String strTp = '${TStyle.getMoneyPoint(search11perPbr.tradePrice)}원';
      String strValue = '';

      if (isPer) {
        strValue = '${TStyle.getMoneyPoint(search11perPbr.per)}배';
      } else {
        strValue = '${TStyle.getMoneyPoint(search11perPbr.pbr)}배';
      }

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
            TStyle.getDateSFormat(search11perPbr.tradeDate),
            style: textStyle),
        (xPoint + 8).round(),
        12.round(),
      );

      canvas.drawPoint(
        point: Point(xPoint + 12, 34),
        radius: 4,
        fill: charts.Color.fromHex(code: color),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strValue, style: textStyle),
        (xPoint + 20).round(),
        29.round(),
      );

      canvas.drawPoint(
        point: Point(xPoint + 12, 54),
        radius: 4,
        fill: charts.Color.fromHex(code: '#6565FF'),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strTp, style: textStyle),
        (xPoint + 20).round(),
        50.round(),
      );
    }
  }
}
