import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:syncfusion_flutter_charts/charts.dart';

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
  final List<Search11PerPbr> _listPerPbrData = [];
  late TrackballBehavior _trackballBehavior;

  // 기업의 배당 정보
  final List<Search11Dividend> _listDividendData = [];
  final List<String> _tableTitleList = ['', '주당배당금', '배당수익률'];

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      shouldAlwaysShow: false,
      lineDashArray: const [4, 3],
      lineWidth: 1,
      tooltipAlignment: ChartAlignment.near,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      activationMode: ActivationMode.singleTap,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        borderWidth: 0,
        width: 0,
        height: 0,
      ),
      builder: (BuildContext context, TrackballDetails trackballDetails) {
        int index =
            trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        var item = _listPerPbrData[index];
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              )
            ],
          ),
          child: FittedBox(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '${item.tradeDate.substring(2, 4)}/${item.tradeDate.substring(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      //'xValue => ${_data[trackballDetails.pointIndex!].x.toString()}',
                      '${TStyle.getMoneyPoint(item.tradePrice)}원',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _isPer ? 'PER' : 'PBR',
                      style: const TextStyle(
                        fontSize: 13,
                        //color: title == '매수' ? RColor.bgBuy : RColor.bgSell,
                      ),
                    ),
                    Text(
                      ' : ${_isPer ? item.per : item.pbr}배',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      ResultAnalyzePage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            PgData pgData =
                ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                pgData.stockCode.isNotEmpty &&
                pgData.stockName.isNotEmpty) {
              _stockName = pgData.stockName;
              _stockCode = pgData.stockCode;
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
        ((ModalRoute.of(context)!.settings.arguments) as PgData).booleanData;
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
            child: const Row(
              children: [
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
          _listPerPbrData.isNotEmpty
              ? Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                    SizedBox(
                      width: double.infinity,
                      height: 240,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        enableMultiSelection: false,
                        margin: const EdgeInsets.only(
                          bottom: 1,
                        ),
                        primaryXAxis: CategoryAxis(
                          //axisBorderType: AxisBorderType.withoutTopAndBottom,
                          axisLine: const AxisLine(
                            width: 1.2,
                            color: RColor.chartGreyColor,
                          ),
                          majorGridLines: const MajorGridLines(
                            width: 0,
                          ),
                          majorTickLines: const MajorTickLines(
                            width: 0,
                          ),
                          //desiredIntervals: 4,
                          //labelPlacement: LabelPlacement.onTicks,
                          axisLabelFormatter: (axisLabelRenderArgs) =>
                              ChartAxisLabel(
                            '${axisLabelRenderArgs.text.substring(2, 4)}/${axisLabelRenderArgs.text.substring(4)}',
                            const TextStyle(
                              fontSize: 11,
                              color: RColor.greyBasic_8c8c8c,
                            ),
                          ),
                          labelIntersectAction:
                              AxisLabelIntersectAction.multipleRows,
                          //desiredIntervals: 4,
                        ),
                        primaryYAxis: const NumericAxis(
                          rangePadding: ChartRangePadding.round,
                          isVisible: false,
                          axisLine: AxisLine(
                            width: 0,
                          ),
                          majorGridLines: MajorGridLines(
                            width: 0,
                          ),
                          majorTickLines: MajorTickLines(
                            width: 0,
                          ),
                        ),
                        trackballBehavior: _trackballBehavior,
                        axes: <ChartAxis>[
                          const CategoryAxis(
                            name: 'xAxis',
                            isVisible: false,
                            opposedPosition: true,
                          ),
                          NumericAxis(
                            name: 'yAxis',
                            opposedPosition: true,
                            anchorRangeToVisiblePoints: true,
                            rangePadding: ChartRangePadding.round,
                            axisLine: const AxisLine(
                              width: 0,
                            ),
                            majorGridLines: const MajorGridLines(
                              color: RColor.chartGreyColor,
                              width: 0.6,
                              dashArray: [2, 2],
                            ),
                            majorTickLines: const MajorTickLines(
                              width: 0,
                            ),
                            axisLabelFormatter: (axisLabelRenderArgs) =>
                                ChartAxisLabel(
                              axisLabelRenderArgs.text,
                              const TextStyle(
                                fontSize: 12,
                                color: RColor.greyBasic_8c8c8c,
                              ),
                            ),
                          )
                        ],
                        selectionType: SelectionType.point,
                        series: [
                          ColumnSeries<Search11PerPbr, String>(
                            dataSource: _listPerPbrData,
                            xValueMapper: (Search11PerPbr data, index) =>
                                data.tradeDate,
                            yValueMapper: (Search11PerPbr data, index) {
                              return _isPer
                                  ? double.parse(data.per)
                                  : double.parse(data.pbr);
                            },
                            /*  pointColorMapper: (Search11PerPbr data, index) {
                              if (index == _swipeIndex) {
                                return RColor.sigBuy;
                              } else {
                                return RColor.chartGreyColor;
                              }
                            },*/
                            color: RColor.chartGreyColor,
                            yAxisName: 'yAxis',
                            enableTooltip: true,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(1),
                            ),
                          ),
                          LineSeries<Search11PerPbr, String>(
                            dataSource: _listPerPbrData,
                            xValueMapper: (item, index) => index.toString(),
                            yValueMapper: (item, index) =>
                                int.parse(item.tradePrice),
                            color: RColor.chartTradePriceColor,
                            width: 1.4,
                            enableTooltip: false,
                            xAxisName: 'xAxis',
                          ),
                        ],
                      ),
                    ),
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
          _listDividendData.isNotEmpty
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
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setChart4View() {
    if (_listDividendData.isEmpty) {
      return const SizedBox(
        width: 1,
        height: 1,
      );
    }
    final lineBarsData = [
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
                    lineBarsData[0],
                    lineBarsData.indexOf(lineBarsData[0]),
                    lineBarsData[0].spots[index],
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
              lineBarsData: lineBarsData,
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
                fontSize: 14, color: RColor.new_basic_text_color_grey),
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
          child: Text('${TStyle.getMoneyPoint(item.dividendRate)}%'),
        ),
      );
    }
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
    String jsonSEARCH11 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': _stockCode,
      },
    );
    await Future.wait(
      [
        _fetchPosts(
          TR.SEARCH11,
          jsonSEARCH11,
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
        }
        if (resData.retData.listDividend.isNotEmpty) {
          _listDividendData.addAll(resData.retData.listDividend);
        }
      }
      setState(() {});
    }
  }
}
