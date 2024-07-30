import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest01.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest02.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/custom/CustomBoxShadow.dart';
import 'package:rassi_assist/ui/stock_home/page/trading_trends_by_date_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/const.dart';
import '../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';
import '../../main/base_page.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_투자자별(외국인/기관) 매매 동향 + 일자별 매매 동향 현황

class StockHomeHomeTileTradingTrends extends StatefulWidget {
  //const StockHomeHomeTileTradingTrends({Key? key}) : super(key: key);
  static final GlobalKey<StockHomeHomeTileTradingTrendsState> globalKey = GlobalKey();

  StockHomeHomeTileTradingTrends() : super(key: globalKey);

  @override
  State<StockHomeHomeTileTradingTrends> createState() => StockHomeHomeTileTradingTrendsState();
}

class StockHomeHomeTileTradingTrendsState extends State<StockHomeHomeTileTradingTrends> {
  final AppGlobal _appGlobal = AppGlobal();

  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  bool _isTrends = false; // true : 매매동향 / false : 누적매매
  int _isTrendsDiv = 0; // 0 : 외국인 / 1 : 기관 / 2 : 개인
  String _frnHoldRate = '0'; // 외국인 보유율 %
  String _accFrnVol = '0'; // 외국인 누적
  String _accOrgVol = '0'; // 기관 누적

  // 매매동향
  final List<Invest01ChartData> _trendsListData = [];

  // 누적매매
  final List<Invest02ChartData> _sumListData = [];
  int _sumDateClickIndex = 0;
  final List<String> sumDateDiveTitleList = ['3개월', '6개월', '1년'];

  late TrackballBehavior _sumTrackballBehavior;
  late TrackballBehavior _trendsTrackballBehavior;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _isTrends = false;
    _isTrendsDiv = 0;
    _sumDateClickIndex = 0;
    _requestTrAll();
  }

  @override
  void initState() {
    _sumTrackballBehavior = TrackballBehavior(
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
        int index = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        var item = _sumListData[index];
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              CustomBoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: FittedBox(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      TStyle.getDateSlashFormat1(item.td),
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
                      '${TStyle.getMoneyPoint(item.tp)}원',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '외국인',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xffFBD240),
                      ),
                    ),
                    Text(
                      ' : ${TStyle.getMoneyPoint(item.afv)}',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      const Text(
                        '기관',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff5DD68D),
                        ),
                      ),
                      Text(
                        ' : ${TStyle.getMoneyPoint(item.aov)}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    _trendsTrackballBehavior = TrackballBehavior(
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
        DLog.e('pointIndex : ${trackballDetails.pointIndex} / '
            'point : ${trackballDetails.point} / '
            'seriesIndex : ${trackballDetails.seriesIndex} / '
            'trackballDetails.series?.name : ${trackballDetails.series?.name} /'
            '\n trackballDetails.groupingModeInfo?.currentPointIndices.toString() : ${trackballDetails.groupingModeInfo?.currentPointIndices.toString()} / '
            '\n trackballDetails.groupingModeInfo?.points.toString() : $trackballDetails.groupingModeInfo?.points.toString() / '
            '\n trackballDetails.groupingModeInfo?.visibleSeriesIndices.toString() : ${trackballDetails.groupingModeInfo?.visibleSeriesIndices.toString()} / '
            '\n trackballDetails.groupingModeInfo?.visibleSeriesList.toString() : ${trackballDetails.groupingModeInfo?.visibleSeriesList.toString()}');
        int index = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        var item = _trendsListData[index];
        String title = '매도';
        if (_isTrendsDiv == 0 && int.parse(item.fv) > 0) {
          title = '매수';
        } else if (_isTrendsDiv == 1 && int.parse(item.ov) > 0) {
          title = '매수';
        } else if (_isTrendsDiv == 2 && int.parse(item.pv) > 0) {
          title = '매수';
        }
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              CustomBoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: FittedBox(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      TStyle.getDateSlashFormat1(item.td),
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
                      '${TStyle.getMoneyPoint(item.tp)}원',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: title == '매수' ? RColor.bgBuy : RColor.bgSell,
                      ),
                    ),
                    Text(
                      ' : ${_isTrendsDiv == 0 ? TStyle.getMoneyPoint(item.fv) : _isTrendsDiv == 1 ? TStyle.getMoneyPoint(item.ov) : TStyle.getMoneyPoint(item.pv)} 주',
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '투자자별 매매동향',
                    style: TStyle.title18T,
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    child: const Row(
                      children: [
                        Text(
                          '표로 보기 ',
                          style: TextStyle(
                            fontSize: 14,
                            color: RColor.new_basic_text_color_grey,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: Color(0xff919191),
                          size: 16,
                        ),
                      ],
                    ),
                    onTap: () {
                      // 일자별 매매동향 리스트 페이지
                      basePageState.callPageRouteUP(
                        const TradingTrendsByDatePage(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              _setTrendsDivButtons(),
              _isTrends ? _setTrendsView() : _setSumView(),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
      ],
    );
  }

  Widget _setTrendsDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                  color: _isTrends ? RColor.lineGrey : Colors.black,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '누적매매',
                  style: _isTrends ? const TextStyle(fontSize: 15, color: RColor.lineGrey) : TStyle.commonTitle15,
                ),
              ),
            ),
            onTap: () {
              if (_isTrends) {
                setState(() {
                  _isTrends = false;
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _isTrends ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '매매동향',
                  style: _isTrends
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (!_isTrends) {
                setState(() {
                  _isTrends = true;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setTrendsView() {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7,
            runSpacing: 5,
            children: [
              FittedBox(
                child: Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        if (_isTrendsDiv != 0) {
                          setState(() {
                            _isTrendsDiv = 0;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: _isTrendsDiv == 0 ? UIStyle.boxNewSelectBtn1() : UIStyle.boxNewUnSelectBtn1(),
                        child: Text(
                          '외국인',
                          style: _isTrendsDiv == 0
                              ? TStyle.commonTitle15
                              : const TextStyle(
                                  fontSize: 15,
                                  color: RColor.btnUnSelectGreyText,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        if (_isTrendsDiv != 1) {
                          setState(() {
                            _isTrendsDiv = 1;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: _isTrendsDiv == 1 ? UIStyle.boxNewSelectBtn1() : UIStyle.boxNewUnSelectBtn1(),
                        child: Text(
                          '기관',
                          style: _isTrendsDiv == 1
                              ? TStyle.commonTitle15
                              : const TextStyle(fontSize: 15, color: RColor.btnUnSelectGreyText),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        if (_isTrendsDiv != 2) {
                          setState(() {
                            _isTrendsDiv = 2;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: _isTrendsDiv == 2 ? UIStyle.boxNewSelectBtn1() : UIStyle.boxNewUnSelectBtn1(),
                        child: Text(
                          '개인',
                          style: _isTrendsDiv == 2
                              ? TStyle.commonTitle15
                              : const TextStyle(fontSize: 15, color: RColor.btnUnSelectGreyText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                child: Row(
                  children: [
                    const Text(
                      '외인 보유율 : ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '$_frnHoldRate%',
                      style: TextStyle(
                        color: (_frnHoldRate.isEmpty || _frnHoldRate == '0')
                            ? Colors.grey
                            : _frnHoldRate.contains('-')
                                ? RColor.sigSell
                                : RColor.sigBuy,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        if(_trendsListData.isEmpty)
          CommonView.setNoDataView(150, '매매동향 '
              '${_isTrendsDiv == 0 ? '외국인' : _isTrendsDiv == 1 ? '기관' : '개인'} '
              '내용이 없습니다.')
        else
          Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _isRightYAxisUpUnit ? '단위:천주' : '단위:주',
                  style: const TextStyle(
                    fontSize: 11,
                    color: RColor.new_basic_text_color_grey,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 240,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  enableMultiSelection: false,
                  primaryXAxis: CategoryAxis(
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
                    desiredIntervals: 4,
                    //labelPlacement: LabelPlacement.onTicks,
                    axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                      TStyle.getDateSlashFormat3(axisLabelRenderArgs.text),
                      const TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
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
                  trackballBehavior: _trendsTrackballBehavior,
                  axes: <ChartAxis>[
                    const CategoryAxis(
                      name: 'xAxis',
                      isVisible: false,
                      opposedPosition: true,
                      //labelPlacement: LabelPlacement.onTicks,
                    ),
                    NumericAxis(
                      name: 'yAxis',
                      opposedPosition: true,
                      anchorRangeToVisiblePoints: true,
                      rangePadding: ChartRangePadding.round,
                      //edgeLabelPlacement: EdgeLabelPlacement.shift,
                      //labelPlacement: LabelPlacement.onTicks,
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
                      axisLabelFormatter: (axisLabelRenderArgs) {
                        String value = axisLabelRenderArgs.text;
                        if (_isRightYAxisUpUnit) {
                          value = TStyle.getMoneyPoint((axisLabelRenderArgs.value / 1000).round().toString());
                        } else {
                          value = TStyle.getMoneyPoint(axisLabelRenderArgs.value.round().toString());
                        }
                        return ChartAxisLabel(
                          value,
                          const TextStyle(
                            fontSize: 12,
                            color: RColor.greyBasic_8c8c8c,
                          ),
                        );
                      },
                    )
                  ],
                  selectionType: SelectionType.point,
                  series: [
                    ColumnSeries<Invest01ChartData, String>(
                      dataSource: _trendsListData,
                      xValueMapper: (Invest01ChartData data, index) => data.td,
                      yValueMapper: (Invest01ChartData data, index) {
                        return _isTrendsDiv == 0
                            ? int.parse(data.fv)
                            : _isTrendsDiv == 1
                            ? int.parse(data.ov)
                            : int.parse(data.pv);
                      },
                      pointColorMapper: (Invest01ChartData data, index) {
                        if (_isTrendsDiv == 0) {
                          if (int.parse(data.fv) > 0) {
                            return RColor.chartRed1;
                          } else {
                            return RColor.lightBlue_5886fe;
                          }
                        } else if (_isTrendsDiv == 1) {
                          if (int.parse(data.ov) > 0) {
                            return RColor.chartRed1;
                          } else {
                            return RColor.lightBlue_5886fe;
                          }
                        } else {
                          if (int.parse(data.pv) > 0) {
                            return RColor.chartRed1;
                          } else {
                            return RColor.lightBlue_5886fe;
                          }
                        }
                      },
                      yAxisName: 'yAxis',
                      width: 0.4,
                      enableTooltip: true,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(1),
                      ),
                      //onRendererCreated: (controller) => _chartTrendsController = controller,
                    ),
                    LineSeries<Invest01ChartData, String>(
                      dataSource: _trendsListData,
                      xValueMapper: (item, index) => index.toString(),
                      yValueMapper: (item, index) => int.parse(item.tp),
                      color: RColor.chartTradePriceColor,
                      width: 1.4,
                      enableTooltip: false,
                      //selectionBehavior: _selectionBehavior,
                      //initialSelectedDataIndexes: <int>[_initSelectBarIndex],
                      xAxisName: 'xAxis',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    //color: Color(0xffFF5050),
                    decoration: const BoxDecoration(
                      color: Color(0xffFF5050),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    '  매수',
                    style: TextStyle(fontSize: 11, color: RColor.new_basic_text_color_grey),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xff5886FE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    '  매도',
                    style: TextStyle(fontSize: 11, color: RColor.new_basic_text_color_grey),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: RColor.chartTradePriceColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    '  주가',
                    style: TextStyle(fontSize: 11, color: RColor.new_basic_text_color_grey),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _setSumView() {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        _setSumDateView(),
        const SizedBox(
          height: 5,
        ),
        if(_sumListData.isEmpty)
          CommonView.setNoDataView(150, '누적매매 ${sumDateDiveTitleList[_sumDateClickIndex]} 내용이 없습니다.')
        else Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '외국인 ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  TStyle.getMoneyPoint(_accFrnVol),
                  style: TextStyle(
                    fontSize: 16,
                    color: TStyle.getMinusPlusColor(_accFrnVol),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  ' 기관 ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  TStyle.getMoneyPoint(_accOrgVol),
                  style: TextStyle(
                    fontSize: 16,
                    color: TStyle.getMinusPlusColor(_accOrgVol),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _isRightYAxisUpUnit ? '단위:천주' : '단위:주',
                style: const TextStyle(
                  fontSize: 11,
                  color: RColor.new_basic_text_color_grey,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 240,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                enableAxisAnimation: true,
                primaryXAxis: CategoryAxis(
                  axisBorderType: AxisBorderType.withoutTopAndBottom,
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
                  desiredIntervals: 4,
                  labelPlacement: LabelPlacement.onTicks,
                  axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                    TStyle.getDateSlashFormat3(axisLabelRenderArgs.text),
                    const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ),
                primaryYAxis: const NumericAxis(
                  rangePadding: ChartRangePadding.round,
                  isVisible: false,
                ),
                axes: <ChartAxis>[
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
                    axisLabelFormatter: (axisLabelRenderArgs) {
                      String value = axisLabelRenderArgs.text;
                      if (_isRightYAxisUpUnit) {
                        value = TStyle.getMoneyPoint((axisLabelRenderArgs.value / 1000).round().toString());
                      } else {
                        value = TStyle.getMoneyPoint(axisLabelRenderArgs.value.round().toString());
                      }
                      return ChartAxisLabel(
                        value,
                        const TextStyle(
                          fontSize: 12,
                          color: RColor.greyBasic_8c8c8c,
                        ),
                      );
                    },
                    numberFormat: NumberFormat.decimalPattern(), // 라벨의 형식 지정
                    // numberFormat: NumberFormat.simpleCurrency(locale: 'ko_KR', decimalDigits: 0,),
                    //rangePadding: ChartRangePadding.additional,
                    //maximumLabels: 4,
                  )
                ],
                trackballBehavior: _sumTrackballBehavior,
                tooltipBehavior: TooltipBehavior(),
                series: [
                  AreaSeries<Invest02ChartData, String>(
                    dataSource: _sumListData,
                    xValueMapper: (item, index) => item.td,
                    yValueMapper: (item, index) => int.parse(item.afv),
                    yAxisName: 'yAxis',
                    color: RColor.chartYellow.withOpacity(0.08),
                    borderWidth: 1.5,
                    borderColor: RColor.chartYellow,
                    enableTooltip: true,
                    animationDuration: 1500,
                    animationDelay: 0,
                  ),
                  AreaSeries<Invest02ChartData, String>(
                    dataSource: _sumListData,
                    xValueMapper: (item, index) => item.td,
                    yValueMapper: (item, index) => int.parse(item.aov),
                    yAxisName: 'yAxis',
                    color: RColor.chartGreen.withOpacity(0.08),
                    borderWidth: 1.5,
                    borderColor: RColor.chartGreen,
                    enableTooltip: true,
                    animationDuration: 1500,
                  ),
                  LineSeries<Invest02ChartData, String>(
                    dataSource: _sumListData,
                    xValueMapper: (item, index) => item.td,
                    yValueMapper: (item, index) => int.parse(item.tp),
                    color: RColor.chartTradePriceColor,
                    animationDuration: 1500,
                    width: 1.4,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  //color: Color(0xffFF5050),
                  decoration: const BoxDecoration(
                    color: Color(0xffFBD240),
                    shape: BoxShape.circle,
                  ),
                ),
                //const SizedBox(width: 4,),
                const Text(
                  '  외국인',
                  style: TextStyle(
                    fontSize: 11,
                    color: RColor.new_basic_text_color_grey,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xff5DD68D),
                    shape: BoxShape.circle,
                  ),
                ),
                const Text(
                  '  기관',
                  style: TextStyle(
                    fontSize: 11,
                    color: RColor.new_basic_text_color_grey,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  width: 7,
                  height: 7,
                  //color: Color(0xff6565FF),
                  decoration: const BoxDecoration(
                    color: RColor.chartTradePriceColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text(
                  '  주가',
                  style: TextStyle(
                    fontSize: 11,
                    color: RColor.new_basic_text_color_grey,
                  ),
                ),
              ],
            ),
          ],
        ),

      ],
    );
  }

  // 누적매매 - 1일 1주일 1개월 ...
  Widget _setSumDateView() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    if (_sumDateClickIndex != index) {
                      setState(() {
                        _sumDateClickIndex = index;
                      });
                      _fetchPosts(
                        TR.INVEST02,
                        jsonEncode(
                          <String, String>{
                            'userId': _appGlobal.userId,
                            'stockCode': _appGlobal.stkCode,
                            'selectDiv': index == 0
                                ? 'M3'
                                : index == 1
                                    ? 'M6'
                                    : index == 2
                                        ? 'Y1'
                                        : 'M3',
                          },
                        ),
                      );
                    }
                  },
                  child: _setSumDateInnerView(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 누적매매 - ...
  Widget _setSumDateInnerView(int index) {
    return Container(
      alignment: Alignment.center,
      decoration: index == _sumDateClickIndex ? UIStyle.boxNewSelectBtn2() : UIStyle.boxNewUnSelectBtn2(),
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 15,
      ),
      child: Text(
        sumDateDiveTitleList[index],
        style: TextStyle(
          color: index == _sumDateClickIndex ? Colors.black : RColor.btnUnSelectGreyText,
          fontSize: 14,
          fontWeight: index == _sumDateClickIndex ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  _requestTrAll() async {
    await Future.wait([
      _fetchPosts(
        TR.INVEST01,
        jsonEncode(
          <String, String>{
            'userId': _appGlobal.userId,
            'stockCode': _appGlobal.stkCode,
            'pageNo': '0',
            'pageItemSize': '30',
          },
        ),
      ),
      _fetchPosts(
        TR.INVEST02,
        jsonEncode(
          <String, String>{
            'userId': _appGlobal.userId,
            'stockCode': _appGlobal.stkCode,
            'selectDiv': 'M3',
          },
        ),
      ),
    ]);
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
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    } on SocketException catch (_) {
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 매매동향 - 외국인/기관
    if (trStr == TR.INVEST01) {
      final TrInvest01 resData = TrInvest01.fromJson(jsonDecode(response.body));
      _trendsListData.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest01 invest01 = resData.retData;
        _frnHoldRate = invest01.frnHoldRate;
        if (invest01.listChartData.isNotEmpty) {
          _trendsListData.addAll(List.from(invest01.listChartData.reversed));
          _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
        }
      }
      setState(() {});
    }

    // NOTE 누적매매
    else if (trStr == TR.INVEST02) {
      final TrInvest02 resData = TrInvest02.fromJsonWithIndex(jsonDecode(response.body));
      _sumListData.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest02 invest02 = resData.retData;
        _accFrnVol = invest02.accFrnVol;
        _accOrgVol = invest02.accOrgVol;
        //_accPsnVol = invest02.accPsnVol;
        if (invest02.listChartData.isNotEmpty) {
          _sumListData.addAll(invest02.listChartData);
          if (_sumListData[0].afv != '0') {
            _sumListData[0].afv = '0';
          }
          if (_sumListData[0].aov != '0') {
            _sumListData[0].aov = '0';
          }
          _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
        }
      }
      setState(() {});
    }
  }

  double get _findMaxValue {
    // 매매동향
    if (_isTrends) {
      if (_trendsListData.length < 2) {
        return 0;
      }

      //외국인
      if (_isTrendsDiv == 0) {
        var item = _trendsListData.reduce((curr, next) => double.parse(curr.fv) > double.parse(next.fv) ? curr : next);
        return double.parse(item.fv);
      }
      //기관
      else if (_isTrendsDiv == 1) {
        var item = _trendsListData.reduce((curr, next) => double.parse(curr.ov) > double.parse(next.ov) ? curr : next);
        return double.parse(item.ov);
      } else {
        var item = _trendsListData.reduce((curr, next) => double.parse(curr.pv) > double.parse(next.pv) ? curr : next);
        return double.parse(item.pv);
      }
    }

    // 누적매매
    else {
      if (_sumListData.length < 2) {
        return 0;
      }
      var itemAfv = _sumListData.reduce((curr, next) => double.parse(curr.afv) > double.parse(next.afv) ? curr : next);
      var itemAov = _sumListData.reduce((curr, next) => double.parse(curr.aov) > double.parse(next.aov) ? curr : next);

      return double.parse(itemAfv.afv) > double.parse(itemAov.aov)
          ? double.parse(itemAfv.afv)
          : double.parse(itemAov.aov);
    }
  }

  double get _findAbsMaxValue {
    // 매매동향
    if (_isTrends) {
      if (_trendsListData.length < 2) {
        return 0;
      }

      //외국인
      if (_isTrendsDiv == 0) {
        var item = _trendsListData
            .reduce((curr, next) => double.parse(curr.fv).abs() > double.parse(next.fv).abs() ? curr : next);
        return double.parse(item.fv).abs();
      }
      //기관
      else if (_isTrendsDiv == 1) {
        var item = _trendsListData
            .reduce((curr, next) => double.parse(curr.ov).abs() > double.parse(next.ov).abs() ? curr : next);
        return double.parse(item.ov).abs();
      } else {
        var item = _trendsListData
            .reduce((curr, next) => double.parse(curr.pv).abs() > double.parse(next.pv).abs() ? curr : next);
        return double.parse(item.pv).abs();
      }
    }

    // 누적매매
    else {
      if (_sumListData.length < 2) {
        return 0;
      }
      var itemAfv = _sumListData
          .reduce((curr, next) => double.parse(curr.afv).abs() > double.parse(next.afv).abs() ? curr : next);
      var itemAov = _sumListData
          .reduce((curr, next) => double.parse(curr.aov).abs() > double.parse(next.aov).abs() ? curr : next);
      return double.parse(itemAfv.afv).abs() > double.parse(itemAov.aov).abs()
          ? double.parse(itemAfv.afv).abs()
          : double.parse(itemAov.aov).abs();
    }
  }
}
