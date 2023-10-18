import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:charts_common/common.dart' as charts_common;
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:charts_flutter_new/src/text_element.dart'
    as charts_text_element;
import 'package:charts_flutter_new/src/text_style.dart' as charts_text_style;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest01.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest02.dart';
import 'package:rassi_assist/ui/stock_home/page/trading_trends_by_date_page.dart';

import '../../../common/const.dart';
import '../../../common/net.dart';
import '../../../models/app_global.dart';
import '../../main/base_page.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_투자자별(외국인/기관) 매매 동향 + 일자별 매매 동향 현황

class StockHomeHomeTileTradingTrends extends StatefulWidget {
  //const StockHomeHomeTileTradingTrends({Key? key}) : super(key: key);
  static final GlobalKey<_StockHomeHomeTileTradingTrendsState> globalKey = GlobalKey();
  StockHomeHomeTileTradingTrends() : super(key: globalKey);
  @override
  State<StockHomeHomeTileTradingTrends> createState() => _StockHomeHomeTileTradingTrendsState();
}

class _StockHomeHomeTileTradingTrendsState extends State<StockHomeHomeTileTradingTrends>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileTradingTrends> {
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  final AppGlobal _appGlobal = AppGlobal();
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  bool _isTrends = false; // true : 매매동향 / false : 누적매매
  int _isTrendsDiv = 0; // 0 : 외국인 / 1 : 기관 / 2 : 개인
  String _frnHoldRate = '0'; // 외국인 보유율 %
  String _accFrnVol = '0'; // 외국인 누적
  String _accOrgVol = '0'; // 기관 누적

  // 매매동향
  List<charts.Series<Invest01ChartData, String>> _seriesListTrendsData =
      []; // 매매동향 - 외국인 / 기관 데이터
  final List<Invest01ChartData> _trendsListData = [];
  List<charts.TickSpec<String>> _trendsTickSpecList = [];

  // 누적매매
  List<charts.Series<Invest02ChartData, int>> _seriesListSumData = []; // 누적매매
  final List<Invest02ChartData> _sumListData = [];
  List<charts.TickSpec<num>> _sumTickSpecList = [];
  int _sumDateClickIndex = 0;
  final List<String> sumDateDiveTitleList = ['3개월', '6개월', '1년'];

  @override
  bool get wantKeepAlive => true;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _isTrends = false;
    _isTrendsDiv = 0;
    _sumDateClickIndex = 0;
    _requestTrAll();
  }

  @override
  void initState() {
    super.initState();
    initPage();
  }


  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    child: Row(
                      children: const [
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
                        TradingTrendsByDatePage(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              _setTrendsDivButtons(),
              _isTrends
                  ? _setTrendsView()
                  : _setSumView(),
            ],
          ),
        ),
        const SizedBox(height: 10,),
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
                  style: _isTrends
                      ? const TextStyle(fontSize: 15, color: RColor.lineGrey)
                      : TStyle.commonTitle15,
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
                        decoration: _isTrendsDiv == 0
                            ? UIStyle.boxNewSelectBtn1()
                            : UIStyle.boxNewUnSelectBtn1(),
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
                        margin: const EdgeInsets.only(left: 5, right: 5,),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: _isTrendsDiv == 1
                            ? UIStyle.boxNewSelectBtn1()
                            : UIStyle.boxNewUnSelectBtn1(),
                        child: Text(
                          '기관',
                          style: _isTrendsDiv == 1
                              ? TStyle.commonTitle15
                              : const TextStyle(
                              fontSize: 15,
                              color: RColor.btnUnSelectGreyText),
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
                        decoration: _isTrendsDiv == 2
                            ? UIStyle.boxNewSelectBtn1()
                            : UIStyle.boxNewUnSelectBtn1(),
                        child: Text(
                          '개인',
                          style: _isTrendsDiv == 2
                              ? TStyle.commonTitle15
                              : const TextStyle(
                              fontSize: 15,
                              color: RColor.btnUnSelectGreyText),
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
        Container(
          height: 240,
          color: Colors.transparent,
          child: charts.OrdinalComboChart(
            _seriesListTrendsData,
            animate: true,
            primaryMeasureAxis: const charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                //desiredTickCount: 2,
                zeroBound: false,
              ),
              showAxisLine: false,
              renderSpec: charts.NoneRenderSpec(),
            ),
            secondaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                  //desiredTickCount: 5,
                  //zeroBound: true,
                  ),
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                lineStyle: charts.LineStyleSpec(
                  dashPattern: const [2, 2],
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec((measure) {
                if (_isRightYAxisUpUnit) {
                  return TStyle.getMoneyPoint((measure! / 1000).round().toString());
                }
                return TStyle.getMoneyPoint(measure?.round().toString());
              }),
            ),
            domainAxis: charts.OrdinalAxisSpec(
              tickProviderSpec: charts.StaticOrdinalTickProviderSpec(
                _trendsTickSpecList,
              ),
              renderSpec: charts.SmallTickRendererSpec(
                minimumPaddingBetweenLabelsPx: 30,
                labelOffsetFromTickPx: 20,
                labelOffsetFromAxisPx: 12,
                // Tick and Label styling here.
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                // Change the line colors to match text color.
                lineStyle: charts.LineStyleSpec(
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            selectionModels: [
              charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  int? selectIndex = model.selectedDatum[0].index;
                  CustomCircleSymbolRenderer.invest01ChartData =
                      _trendsListData[selectIndex!];
                  CustomCircleSymbolRenderer.isTrendsDiv = _isTrendsDiv;
                }
              })
            ],
            customSeriesRenderers: [
              charts.LineRendererConfig(
                // ID used to link series to this renderer.
                customRendererId: 'line',
                layoutPaintOrder: 30,
                strokeWidthPx: 1.5,
              ),
            ],
            behaviors: [
              charts.LinePointHighlighter(
                symbolRenderer: CustomCircleSymbolRenderer(
                  MediaQuery.of(context).size.width,
                ), // add this line in behaviours
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
              style: TextStyle(
                  fontSize: 11, color: RColor.new_basic_text_color_grey),
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
              style: TextStyle(
                  fontSize: 11, color: RColor.new_basic_text_color_grey),
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
              style: TextStyle(
                  fontSize: 11, color: RColor.new_basic_text_color_grey),
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
          height: 10,
        ),
        _setSumDateView(),
        const SizedBox(
          height: 5,
        ),
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
          height: 240,
          child: charts.LineChart(
            _seriesListSumData,
            animate: true,
            primaryMeasureAxis: const charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                //desiredTickCount: 2,
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
                  dashPattern: const [2, 2],
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec((measure) {
                if (_isRightYAxisUpUnit) {
                  return TStyle.getMoneyPoint((measure! / 1000).round().toString());
                } else {
                  return TStyle.getMoneyPoint(measure!.round().toString());
                }
              }),
            ),
            domainAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(
                _sumTickSpecList,
              ),
              renderSpec: charts.SmallTickRendererSpec(
                minimumPaddingBetweenLabelsPx: 30,
                labelOffsetFromTickPx: 20,
                labelOffsetFromAxisPx: 12,
                // Tick and Label styling here.
                labelStyle: charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.Color.fromHex(code: '#8C8C8C'),
                ),
                // Change the line colors to match text color.
                lineStyle: charts.LineStyleSpec(
                  color: charts.Color.fromHex(code: '#DCDFE2'),
                ),
              ),
            ),
            selectionModels: [
              charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  int? selectIndex = model.selectedDatum[0].index;
                  CustomCircleSymbolRendererSum.invest02ChartData =
                      _sumListData[selectIndex!];
                }
              })
            ],
            customSeriesRenderers: [
              charts.LineRendererConfig(
                customRendererId: 'areaLine',
                includeArea: true,
                //areaOpacity: 0.2,
                layoutPaintOrder: 0,
                //stacked: true,
              ),
            ],
            behaviors: [
              charts.LinePointHighlighter(
                symbolRenderer: CustomCircleSymbolRendererSum(
                    MediaQuery.of(context)
                        .size
                        .width,
                ), // add this line in behaviours
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
              width: 8,
              height: 8,
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
      decoration: index == _sumDateClickIndex
          ? UIStyle.boxNewSelectBtn2()
          : UIStyle.boxNewUnSelectBtn2(),
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
          color: index == _sumDateClickIndex
              ? Colors.black
              : RColor.btnUnSelectGreyText,
          fontSize: 14,
          fontWeight:
              index == _sumDateClickIndex ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  _initTrendsChartData() {
    //_isRightYAxisUpUnit = _findMaxValue >= 1000;
    _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
    _seriesListTrendsData = [
      charts.Series<Invest01ChartData, String>(
        id: '주가',
        colorFn: (_, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Invest01ChartData xAxisItem, _) => xAxisItem.td,
        measureFn: (Invest01ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
        data: _trendsListData,
      )..setAttribute(charts.rendererIdKey, 'line'),
      charts.Series<Invest01ChartData, String>(
        id: '매수/매도',
        colorFn: (v1, __) {
          if (_isTrendsDiv == 0) {
            if (int.parse(v1.fv) > 0) {
              return charts.Color.fromHex(code: '#FF5050');
            } else {
              return charts.Color.fromHex(code: '#5886FE');
            }
          } else if (_isTrendsDiv == 1) {
            if (int.parse(v1.ov) > 0) {
              return charts.Color.fromHex(code: '#FF5050');
            } else {
              return charts.Color.fromHex(code: '#5886FE');
            }
          } else {
            if (int.parse(v1.pv) > 0) {
              return charts.Color.fromHex(code: '#FF5050');
            } else {
              return charts.Color.fromHex(code: '#5886FE');
            }
          }
        },
        domainFn: (Invest01ChartData xAxisItem, _) => xAxisItem.td,
        measureFn: (Invest01ChartData yAxisItem, _) {
          return _isTrendsDiv == 0
              ? int.parse(yAxisItem.fv)
              : _isTrendsDiv == 1
                  ? int.parse(yAxisItem.ov)
                  : int.parse(yAxisItem.pv);
        },
        data: _trendsListData,
      )..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
    _trendsTickSpecList = [
      charts.TickSpec(
        // Value must match the domain value.
        _trendsListData[0].td,
        // Optional label for this tick, defaults to domain value if not set.
        //label: TStyle.getDateSFormat(_trendsListData[0].td),
        label: TStyle.getDateSlashFormat3(_trendsListData[0].td),
        // The styling for this tick.
        /*style: new charts.TextStyleSpec(
                          color: new charts.Color(r: 0, g: 0, b: 0),),*/
      ),
      charts.TickSpec(
        _trendsListData[(_trendsListData.length ~/ 3)].td,
        //label: TStyle.getDateSFormat(_trendsListData[_trendsListData.length ~/ 3].td),
        label: TStyle.getDateSlashFormat3(_trendsListData[_trendsListData.length ~/ 3].td),
        //style: charts.TextStyleSpec(),
      ),
      charts.TickSpec(
        _trendsListData[(_trendsListData.length ~/ 3) * 2].td,
        //label: TStyle.getDateSFormat(_trendsListData[(_trendsListData.length ~/ 3) * 2].td),
        label: TStyle.getDateSlashFormat3(_trendsListData[(_trendsListData.length ~/ 3) * 2].td),
      ),
      charts.TickSpec(
        _trendsListData.last.td,
        //label: TStyle.getDateSFormat(_trendsListData.last.td),
        label: TStyle.getDateSlashFormat3(_trendsListData.last.td),
      ),
    ];
    setState(() {});
  }

  _initSumChartData() {
    //_isRightYAxisUpUnit = _findMaxValue >= 1000;
    _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
    _seriesListSumData = [
      charts.Series<Invest02ChartData, int>(
        id: '기관',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#5DD68D'),
        domainFn: (Invest02ChartData xAxisItem, _) => xAxisItem.index,
        measureFn: (Invest02ChartData yAxisItem, _) => int.parse(yAxisItem.aov),
        data: _sumListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
      charts.Series<Invest02ChartData, int>(
        id: '외국인',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#FBD240'),
        domainFn: (Invest02ChartData xAxisItem, _) => xAxisItem.index,
        measureFn: (Invest02ChartData yAxisItem, _) => int.parse(yAxisItem.afv),
        data: _sumListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
     /* new charts.Series<Invest02ChartData, int>(
        id: '개인',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#FFFF65'),
        domainFn: (Invest02ChartData xAxisItem, _) => xAxisItem.index,
        measureFn: (Invest02ChartData yAxisItem, _) => int.parse(yAxisItem.apv),
        data: _sumListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),*/

      charts.Series<Invest02ChartData, int>(
        id: '주가',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Invest02ChartData xAxisItem, _) => xAxisItem.index,
        measureFn: (Invest02ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
        data: _sumListData,
        strokeWidthPxFn: (datum, index) => 1.5,
        //네dashPatternFn: (datum, index) => [4,2],
      )
      //..setAttribute(charts.rendererIdKey, 'areaLine'),
    ];
    _sumTickSpecList = [
      charts.TickSpec(
        _sumListData[0].index,
        //label: TStyle.getDateSFormat(_sumListData[0].td),
        label: TStyle.getDateSlashFormat3(_sumListData[0].td),
      ),
      charts.TickSpec(
        _sumListData[(_sumListData.length ~/ 3)].index,
        //label: TStyle.getDateSFormat(_sumListData[_sumListData.length ~/ 3].td),
        label: TStyle.getDateSlashFormat3(_sumListData[_sumListData.length ~/ 3].td),
      ),
      charts.TickSpec(
        _sumListData[(_sumListData.length ~/ 3) * 2].index,
        //label: TStyle.getDateSFormat(_sumListData[(_sumListData.length ~/ 3) * 2].td),
        label: TStyle.getDateSlashFormat3(_sumListData[(_sumListData.length ~/ 3) * 2].td),
      ),
      charts.TickSpec(
        _sumListData.last.index,
        //label: TStyle.getDateSFormat(_sumListData.last.td),
        label: TStyle.getDateSlashFormat3(_sumListData.last.td),
      ),
    ];
    setState(() {});
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

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 매매동향 - 외국인/기관
    if (trStr == TR.INVEST01) {
      final TrInvest01 resData = TrInvest01.fromJson(jsonDecode(response.body));
      _seriesListTrendsData.clear();
      _trendsListData.clear();
      _trendsTickSpecList.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest01 invest01 = resData.retData;
        _frnHoldRate = invest01.frnHoldRate;
        if (invest01.listChartData.length > 0) {
          _trendsListData.addAll(List.from(invest01.listChartData.reversed));
          _initTrendsChartData();
        } else {
          setState(() { });
        }
      } else {
        setState(() { });
      }
    }

    // NOTE 누적매매
    else if (trStr == TR.INVEST02) {
      final TrInvest02 resData =
          TrInvest02.fromJsonWithIndex(jsonDecode(response.body));
      _seriesListSumData.clear();
      _sumListData.clear();
      _sumTickSpecList.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest02 invest02 = resData.retData;
        _accFrnVol = invest02.accFrnVol;
        _accOrgVol = invest02.accOrgVol;
        //_accPsnVol = invest02.accPsnVol;
        if (invest02.listChartData.length > 0) {
          _sumListData.addAll(invest02.listChartData);
          if (_sumListData[0].afv != '0') {
            _sumListData[0].afv = '0';
          }
          if (_sumListData[0].aov != '0') {
            _sumListData[0].aov = '0';
          }
          _initSumChartData();
        } else {
          setState(() {});
        }
      } else {
        setState(() {});
      }
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
        var item = _trendsListData.reduce((curr, next) =>
            double.parse(curr.fv) > double.parse(next.fv) ? curr : next);
        return double.parse(item.fv);
      }
      //기관
      else if (_isTrendsDiv == 1) {
        var item = _trendsListData.reduce((curr, next) =>
            double.parse(curr.ov) > double.parse(next.ov) ? curr : next);
        return double.parse(item.ov);
      } else {
        var item = _trendsListData.reduce((curr, next) =>
            double.parse(curr.pv) > double.parse(next.pv) ? curr : next);
        return double.parse(item.pv);
      }
    }

    // 누적매매
    else {
      if (_sumListData.length < 2) {
        return 0;
      }
      var itemAfv = _sumListData.reduce((curr, next) =>
          double.parse(curr.afv) > double.parse(next.afv) ? curr : next);
      var itemAov = _sumListData.reduce((curr, next) =>
          double.parse(curr.aov) > double.parse(next.aov) ? curr : next);

      return double.parse(itemAfv.afv) > double.parse(itemAov.aov)
          ? double.parse(itemAfv.afv)
          : double.parse(itemAov.aov);
    }
  }

  double get _findAbsMaxValue{
    // 매매동향
    if (_isTrends) {
      if (_trendsListData.length < 2) {
        return 0;
      }

      //외국인
      if (_isTrendsDiv == 0) {
        var item = _trendsListData.reduce((curr, next) =>
        double.parse(curr.fv).abs() > double.parse(next.fv).abs() ? curr : next);
        return double.parse(item.fv).abs();
      }
      //기관
      else if (_isTrendsDiv == 1) {
        var item = _trendsListData.reduce((curr, next) =>
        double.parse(curr.ov).abs() > double.parse(next.ov).abs() ? curr : next);
        return double.parse(item.ov).abs();
      } else {
        var item = _trendsListData.reduce((curr, next) =>
        double.parse(curr.pv).abs() > double.parse(next.pv).abs() ? curr : next);
        return double.parse(item.pv).abs();
      }
    }

    // 누적매매
    else {
      if (_sumListData.length < 2) {
        return 0;
      }
      var itemAfv = _sumListData.reduce((curr, next) =>
      double.parse(curr.afv).abs() > double.parse(next.afv).abs() ? curr : next);
      var itemAov = _sumListData.reduce((curr, next) =>
      double.parse(curr.aov).abs() > double.parse(next.aov).abs() ? curr : next);
      return double.parse(itemAfv.afv).abs() > double.parse(itemAov.aov).abs()
          ? double.parse(itemAfv.afv).abs()
          : double.parse(itemAov.aov).abs();
    }
  }

}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  final double deviceWidth;

  CustomCircleSymbolRenderer(this.deviceWidth);

  static late Invest01ChartData invest01ChartData;
  static int isTrendsDiv = 0;
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
      int fvLength = invest01ChartData.fv.length;
      int ovLength = invest01ChartData.ov.length;
      int pvLength = invest01ChartData.pv.length;
      int maxLength = (fvLength >= ovLength && fvLength >= pvLength)
          ? fvLength
          : (ovLength >= pvLength)
              ? ovLength
              : pvLength;
      if (maxLength > 6) {
        minWidth += 5 * (maxLength - 6);
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

      String color = '#FC525B';
      String strTp = '${TStyle.getMoneyPoint(invest01ChartData.tp)}원';
      String strValue = '';

      if (isTrendsDiv == 0) {
        if (int.parse(invest01ChartData.fv) < 0) {
          color = '#5886FE';
        }
        strValue = '${TStyle.getMoneyPoint(invest01ChartData.fv)}K';
      } else if (isTrendsDiv == 1) {
        if (int.parse(invest01ChartData.ov) < 0) {
          color = '#5886FE';
        }
        strValue = '${TStyle.getMoneyPoint(invest01ChartData.ov)}K';
      } else if (isTrendsDiv == 2) {
        if (int.parse(invest01ChartData.pv) < 0) {
          color = '#5886FE';
        }
        strValue = '${TStyle.getMoneyPoint(invest01ChartData.pv)}K';
      }

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
            TStyle.getDateSlashFormat3(invest01ChartData.td),
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
        fill: charts.Color.fromHex(code: '#454A63'),
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

class CustomCircleSymbolRendererSum extends charts_common.CircleSymbolRenderer {
  CustomCircleSymbolRendererSum(this.deviceWidth);

  static late Invest02ChartData invest02ChartData;
  double _xPoint = 0;
  final double deviceWidth;
  final List<charts.Color> _listSymbolColor = [
    charts.Color.fromHex(code: '#FBD240'),
    charts.Color.fromHex(code: '#5DD68D'),
    //charts.Color.fromHex(code: '#FFFF65'),
    charts.Color.fromHex(code: '#454A63'),
  ];
  List<String> _listValue = [];

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

    double minWidth = bounds.width + 80;
    int afvLength = invest02ChartData.afv.length;
    int aovLength = invest02ChartData.aov.length;
    //int apvLength = invest02ChartData.apv.length;
    int maxLength = (afvLength >= aovLength) ? afvLength : aovLength;
    if (maxLength > 6) {
      minWidth += 5 * (maxLength - 5);
    }

    _xPoint = (deviceWidth / 2) > bounds.left
        ? bounds.left + 12
        : bounds.left - minWidth - 4;

    canvas.drawRect(
      Rectangle(_xPoint, 0, minWidth, bounds.height + 84),
      fill: const charts.Color(
        r: 102,
        g: 102,
        b: 102,
        a: 80,
      ),
    );
    var textStyle = charts_text_style.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontSize = 12;

    _listValue = [
      '${TStyle.getMoneyPoint(invest02ChartData.afv)}원',
      '${TStyle.getMoneyPoint(invest02ChartData.aov)}원',
      //'${TStyle.getMoneyPoint(invest02ChartData.apv)}원',
      '${TStyle.getMoneyPoint(invest02ChartData.tp)}원',
    ];

    // 날짜
    canvas.drawText(
      charts_text_element.TextElement(
          TStyle.getDateSlashFormat3(invest02ChartData.td),
          style: textStyle),
      (_xPoint + 8).round(),
      12.round(),
    );

    for (int i = 0; i < 3; i++) {
      canvas.drawPoint(
        point: Point(_xPoint + 12, 34 + (20 * i)),
        radius: 4,
        fill: _listSymbolColor[i],
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(_listValue[i], style: textStyle),
        (_xPoint + 20).round(),
        29 + (20 * i),
      );
    }
  }
}
