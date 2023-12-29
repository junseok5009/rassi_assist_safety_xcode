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
import 'package:rassi_assist/models/tr_invest/tr_invest21.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest22.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/stock_home/page/loan_transaction_list_page.dart';

import '../../../../common/const.dart';
import '../../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/tr_invest/tr_invest23.dart';
import '../../main/base_page.dart';

/// 2023.03.16_HJS
/// 종목홈(개편)_홈_대차거래와 공매

class StockHomeHomeTileLoanTransaction extends StatefulWidget {
  //const StockHomeHomeTileLoanTransaction({Key? key}) : super(key: key);
  static final GlobalKey<_StockHomeHomeTileLoanTransactionState> globalKey =
      GlobalKey();

  StockHomeHomeTileLoanTransaction() : super(key: globalKey);

  @override
  State<StockHomeHomeTileLoanTransaction> createState() =>
      _StockHomeHomeTileLoanTransactionState();
}

class _StockHomeHomeTileLoanTransactionState
    extends State<StockHomeHomeTileLoanTransaction>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileLoanTransaction> {
  final AppGlobal _appGlobal = AppGlobal();
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  int _divIndex = 0; // 0 : 대차거래 / 1 : 공매 / 2 : 신용융자
  final List<String> _divTitles = ['3개월', '6개월', '1년'];

  // 대차거래
  List<charts.Series<Invest21ChartData, int>> _seriesListLendingData =
      []; // 매매동향 - 외국인 / 기관 데이터
  final List<Invest21ChartData> _lendingListData = [];
  List<charts.TickSpec<int>> _lendingTickSpecList = [];
  int _lendingDateClickIndex = 0;

  // 공매
  List<charts.Series<Invest22ChartData, int>> _seriesListSellingData =
      []; // 누적매매
  final List<Invest22ChartData> _sellingListData = [];
  List<charts.TickSpec<num>> _sellingTickSpecList = [];
  int _sellingDateClickIndex = 0;

  // 신용융자
  List<charts.Series<Invest23ChartData, int>> _seriesListLoanData = [];
  final List<Invest23ChartData> _loanListData = [];
  List<charts.TickSpec<num>> _loanTickSpecList = [];
  int _loanDateClickIndex = 0;

  @override
  bool get wantKeepAlive => true;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _divIndex = 0;
    _lendingDateClickIndex = 0;
    _sellingDateClickIndex = 0;
    _loanDateClickIndex = 0;
    _requestTrInvest21();
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPage();
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
                  Text(
                    '대차거래·공매·신용',
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
                      basePageState.callPageRouteUP(
                        const LoanTransactionListPage(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              _setDivButtons(),
              const SizedBox(
                height: 15,
              ),
              _setDateView(),
              const SizedBox(
                height: 15,
              ),
              (_divIndex == 0 && _lendingListData.isNotEmpty) ||
                      (_divIndex == 1 && _sellingListData.isNotEmpty) ||
                      (_divIndex == 2 && _loanListData.isNotEmpty)
                  ? _setDataView()
                  : _setNoDataView(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
      ],
    );
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(
        top: 20,
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
            _divIndex == 0
                ? '대차거래 내역이 없습니다.'
                : _divIndex == 1
                    ? '공매도 내역이 없습니다.'
                    : _divIndex == 2
                        ? '신용융자 내역이 없습니다.'
                        : '데이터가 없습니다.',
            style: const TextStyle(
              fontSize: 14,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setDataView() {
    return Column(
      children: [
        _divIndex == 0
            ? _setLendingView()
            : _divIndex == 1
                ? _setSellingView()
                : _divIndex == 2
                    ? _setLoanView()
                    : const SizedBox(),
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
              decoration: const BoxDecoration(
                color: Color(0xff5DD68D),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              _divIndex == 0
                  ? '  대차잔고'
                  : _divIndex == 1
                      ? '  공매도량'
                      : _divIndex == 2
                          ? '  신용잔고'
                          : '',
              style: const TextStyle(
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
                  color: _divIndex == 0 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '대차거래',
                  style: _divIndex == 0
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 0) {
                setState(() {
                  _divIndex = 0;
                  _requestTrInvest21();
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
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.4,
                    color: _divIndex == 1 ? Colors.black : RColor.lineGrey,
                  ),
                  vertical: BorderSide(
                    width: _divIndex == 1 ? 1.4 : 0,
                    color: _divIndex == 1 ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '공매도 이평',
                  style: _divIndex == 1
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 1) {
                setState(() {
                  _divIndex = 1;
                  _requestTrInvest22();
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
                  color: _divIndex == 2 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '신용융자',
                  style: _divIndex == 2
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 2) {
                setState(() {
                  _divIndex = 2;
                  _requestTrInvest23();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setLendingView() {
    return Column(
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
        _setChartView(),
        //_setComboChartView(),
      ],
    );
  }

  Widget _setSellingView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                _showBottomSheetSellingInfo();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: RColor.new_basic_text_color_grey,
                      size: 16,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '공매도 이평 이란?',
                      style: TextStyle(
                        fontSize: 14,
                        color: RColor.new_basic_text_color_grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              _isRightYAxisUpUnit ? '단위:천주' : '단위:주',
              style: TextStyle(
                fontSize: 11,
                color: RColor.new_basic_text_color_grey,
              ),
            ),
          ],
        ),
        _setChartView(),
        //_setComboChartView(),
      ],
    );
  }

  Widget _setLoanView() {
    return Column(
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
        _setChartView(),
      ],
    );
  }

  Widget _setChartView() {
    return Container(
      height: 240,
      color: Colors.transparent,
      child: charts.LineChart(
        _divIndex == 0
            ? _seriesListLendingData
            : _divIndex == 1
                ? _seriesListSellingData
                : _divIndex == 2
                    ? _seriesListLoanData
                    : _seriesListLendingData,
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
            zeroBound: false,
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
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec((measure) {
            if (_isRightYAxisUpUnit) {
              return TStyle.getMoneyPoint((measure! / 1000).round().toString());
            }
            return TStyle.getMoneyPoint(measure!.round().toString());
          }),
        ),
        domainAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.StaticNumericTickProviderSpec(
            _divIndex == 0
                ? _lendingTickSpecList
                : _divIndex == 1
                    ? _sellingTickSpecList
                    : _loanTickSpecList,
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
              CustomRenderData customRendererData;
              if (_divIndex == 0) {
                var item = _lendingListData[selectIndex!];
                customRendererData = CustomRenderData(
                    tradeDate: item.td, tradePrice: item.tp, value: item.bl);
              } else if (_divIndex == 1) {
                var item = _sellingListData[selectIndex!];
                customRendererData = CustomRenderData(
                    tradeDate: item.td, tradePrice: item.tp, value: item.asv);
              } else {
                var item = _loanListData[selectIndex!];
                customRendererData = CustomRenderData(
                    tradeDate: item.tradeDate,
                    tradePrice: item.tradePrice,
                    value: item.volumeBalance);
              }
              CustomCircleSymbolRenderer.dataClass = customRendererData;
            }
          })
        ],
        customSeriesRenderers: [
          charts.LineRendererConfig(
            customRendererId: 'areaLine',
            includeArea: true,
            layoutPaintOrder: 1,
            //areaOpacity: 0.2,
            //includeLine: false,
          ),
        ],
        behaviors: [
          charts.LinePointHighlighter(
            symbolRenderer: CustomCircleSymbolRenderer(
              MediaQuery.of(context).size.width,
            ), // dd this line in behaviours
          ),
        ],
      ),
    );
  }

  Widget _setDateView() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              if (_divIndex == 0) {
                if (_lendingDateClickIndex != index) {
                  setState(() {
                    _lendingDateClickIndex = index;
                    _requestTrInvest21();
                  });
                }
              } else if (_divIndex == 1) {
                if (_sellingDateClickIndex != index) {
                  setState(() {
                    _sellingDateClickIndex = index;
                    _requestTrInvest22();
                  });
                }
              } else {
                if (_loanDateClickIndex != index) {
                  setState(() {
                    _loanDateClickIndex = index;
                    _requestTrInvest23();
                  });
                }
              }
            },
            child: _setDateInnerView(index),
          ),
        ),
      ),
    );
  }

  Widget _setDateInnerView(int index) {
    return Container(
      alignment: Alignment.center,
      decoration: (_divIndex == 0 && index == _lendingDateClickIndex) ||
              (_divIndex == 1 && index == _sellingDateClickIndex) ||
              (_divIndex == 2 && index == _loanDateClickIndex)
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
        _divTitles[index],
        style: TextStyle(
          color: (_divIndex == 0 && index == _lendingDateClickIndex) ||
                  (_divIndex == 1 && index == _sellingDateClickIndex) ||
                  (_divIndex == 2 && index == _loanDateClickIndex)
              ? Colors.black
              : RColor.new_basic_text_color_grey,
          fontSize: 14,
          fontWeight: (_divIndex == 0 && index == _lendingDateClickIndex) ||
                  (_divIndex == 1 && index == _sellingDateClickIndex) ||
                  (_divIndex == 2 && index == _loanDateClickIndex)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    );
  }

  _initLendingChartData() {
    //_isRightYAxisUpUnit = _findMaxValue >= 1000;
    _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
    _seriesListLendingData = [
      charts.Series<Invest21ChartData, int>(
        id: '주가',
        colorFn: (_, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Invest21ChartData xAxisItem, index) => index!,
        measureFn: (Invest21ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
        data: _lendingListData,
        strokeWidthPxFn: (datum, index) => 1.5,
      ),
      charts.Series<Invest21ChartData, int>(
        id: '잔고',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#5DD68D'),
        domainFn: (Invest21ChartData xAxisItem, index) => index!,
        measureFn: (Invest21ChartData yAxisItem, _) {
          return int.parse(yAxisItem.bl);
        },
        data: _lendingListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
    _lendingTickSpecList = [
      charts.TickSpec(
        0,
        label: TStyle.getDateSlashFormat3(_lendingListData[0].td),
      ),
      charts.TickSpec(
        _lendingListData.length ~/ 3,
        label: TStyle.getDateSlashFormat3(
            _lendingListData[_lendingListData.length ~/ 3].td),
      ),
      charts.TickSpec(
        _lendingListData.length ~/ 3 * 2,
        label: TStyle.getDateSlashFormat3(
            _lendingListData[(_lendingListData.length ~/ 3) * 2].td),
      ),
      charts.TickSpec(
        _lendingListData.length - 1,
        label: TStyle.getDateSlashFormat3(_lendingListData.last.td),
      ),
    ];

    setState(() {});
  }

  _initSellingChartData() {
    //_isRightYAxisUpUnit = _findMaxValue >= 1000;
    _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
    _seriesListSellingData = [
      charts.Series<Invest22ChartData, int>(
        id: '주가',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Invest22ChartData xAxisItem, index) => index!,
        measureFn: (Invest22ChartData yAxisItem, _) => int.parse(yAxisItem.tp),
        data: _sellingListData,
        strokeWidthPxFn: (datum, index) => 1.5,
      ),
      charts.Series<Invest22ChartData, int>(
        id: '공매도량',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#5DD68D'),
        domainFn: (Invest22ChartData xAxisItem, index) => index!,
        measureFn: (Invest22ChartData yAxisItem, _) => int.parse(yAxisItem.asv),
        data: _sellingListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
    _sellingTickSpecList = [
      charts.TickSpec(
        0,
        label: TStyle.getDateSlashFormat3(_sellingListData[0].td),
      ),
      charts.TickSpec(
        //_sellingListData[(_sellingListData.length ~/ 3)].index,
        _sellingListData.length ~/ 3,
        label: TStyle.getDateSlashFormat3(
            _sellingListData[_sellingListData.length ~/ 3].td),
      ),
      charts.TickSpec(
        //_sellingListData[(_sellingListData.length ~/ 3) * 2].index,
        _sellingListData.length ~/ 3 * 2,
        label: TStyle.getDateSlashFormat3(
            _sellingListData[(_sellingListData.length ~/ 3) * 2].td),
      ),
      charts.TickSpec(
        _sellingListData.length - 1,
        label: TStyle.getDateSlashFormat3(_sellingListData.last.td),
      ),
    ];
    setState(() {});
  }

  _initLoanChartData() {
    //_isRightYAxisUpUnit = _findMaxValue >= 1000;
    _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
    _seriesListLoanData = [
      charts.Series<Invest23ChartData, int>(
        id: '주가',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#454A63'),
        domainFn: (Invest23ChartData xAxisItem, index) => index!,
        measureFn: (Invest23ChartData yAxisItem, _) =>
            int.parse(yAxisItem.tradePrice),
        data: _loanListData,
        strokeWidthPxFn: (datum, index) => 1.5,
      ),
      charts.Series<Invest23ChartData, int>(
        id: '신용잔고',
        colorFn: (v1, __) => charts.Color.fromHex(code: '#5DD68D'),
        domainFn: (Invest23ChartData xAxisItem, index) => index!,
        measureFn: (Invest23ChartData yAxisItem, _) =>
            int.parse(yAxisItem.volumeBalance),
        data: _loanListData,
      )
        ..setAttribute(charts.rendererIdKey, 'areaLine')
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
    _loanTickSpecList = [
      charts.TickSpec(
        0,
        label: TStyle.getDateSlashFormat3(_loanListData[0].tradeDate),
      ),
      charts.TickSpec(
        //_sellingListData[(_sellingListData.length ~/ 3)].index,
        _loanListData.length ~/ 3,
        label: TStyle.getDateSlashFormat3(
            _loanListData[_loanListData.length ~/ 3].tradeDate),
      ),
      charts.TickSpec(
        //_sellingListData[(_sellingListData.length ~/ 3) * 2].index,
        _loanListData.length ~/ 3 * 2,
        label: TStyle.getDateSlashFormat3(
            _loanListData[(_loanListData.length ~/ 3) * 2].tradeDate),
      ),
      charts.TickSpec(
        _loanListData.length - 1,
        label: TStyle.getDateSlashFormat3(_loanListData.last.tradeDate),
      ),
    ];
    setState(() {});
  }

  _requestTrInvest21() async {
    _fetchPosts(
      TR.INVEST21,
      jsonEncode(
        <String, String>{
          'userId': _appGlobal.userId,
          'stockCode': _appGlobal.stkCode,
          'pageNo': '0',
          'pageItemSize': _lendingDateClickIndex == 0
              ? '60'
              : _lendingDateClickIndex == 1
                  ? '120'
                  : _lendingDateClickIndex == 2
                      ? '240'
                      : '60',
        },
      ),
    );
  }

  _requestTrInvest22() async {
    await Future.wait([
      _fetchPosts(
        TR.INVEST22,
        jsonEncode(
          <String, String>{
            'userId': _appGlobal.userId,
            'stockCode': _appGlobal.stkCode,
            'selectDiv': _sellingDateClickIndex == 0
                ? 'M3'
                : _sellingDateClickIndex == 1
                    ? 'M6'
                    : _sellingDateClickIndex == 2
                        ? 'Y1'
                        : 'M3',
          },
        ),
      ),
    ]);
  }

  _requestTrInvest23() async {
    await Future.wait([
      _fetchPosts(
        TR.INVEST23,
        jsonEncode(
          <String, String>{
            'userId': _appGlobal.userId,
            'stockCode': _appGlobal.stkCode,
            'pageNo': '0',
            'pageItemSize': _loanDateClickIndex == 0
                ? '60'
                : _loanDateClickIndex == 1
                    ? '120'
                    : _loanDateClickIndex == 2
                        ? '240'
                        : '60',
          },
        ),
      ),
    ]);
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.w(trStr + ' ' + json);

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
    // NOTE 대차거래
    if (trStr == TR.INVEST21) {
      final TrInvest21 resData =
          TrInvest21.fromJsonWithIndex(jsonDecode(response.body));
      _seriesListLendingData.clear();
      _lendingListData.clear();
      _lendingTickSpecList.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest21 invest21 = resData.retData;
        if (invest21.listChartData.isNotEmpty) {
          _lendingListData.addAll(
            List.from(invest21.listChartData.reversed),
          );
          _initLendingChartData();
        } else {
          setState(() {});
        }
      } else {
        setState(() {});
      }
    }

    // NOTE 공매도
    else if (trStr == TR.INVEST22) {
      final TrInvest22 resData =
          TrInvest22.fromJsonWithIndex(jsonDecode(response.body));
      _seriesListSellingData.clear();
      _sellingListData.clear();
      _sellingTickSpecList.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest22 invest22 = resData.retData;
        if (invest22.listChartData.length > 0) {
          _sellingListData.addAll(
            invest22.listChartData,
          );
          _initSellingChartData();
        } else {
          setState(() {});
        }
      } else {
        setState(() {});
      }
    }

    // NOTE 신용 융자
    else if (trStr == TR.INVEST23) {
      final TrInvest23 resData =
          TrInvest23.fromJsonWithIndex(jsonDecode(response.body));
      _seriesListLoanData.clear();
      _loanListData.clear();
      _loanTickSpecList.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest23 invest23 = resData.retData;
        if (invest23.listChartData.isNotEmpty) {
          _loanListData.addAll(
            List.from(invest23.listChartData.reversed),
          );
          _initLoanChartData();
        } else {
          setState(() {});
        }
      } else {
        setState(() {});
      }
    }
  }

  double get _findAbsMaxValue {
    // 대차거래
    if (_divIndex == 0) {
      if (_lendingListData.length < 2) {
        return 0;
      }
      var item = _lendingListData.reduce((curr, next) =>
          double.parse(curr.bl).abs() > double.parse(next.bl).abs()
              ? curr
              : next);
      return double.parse(item.bl).abs() ?? 0;
    }

    // 공매도
    else if(_divIndex == 1){
      if (_sellingListData.length < 2) {
        return 0;
      }
      var item = _sellingListData.reduce((curr, next) =>
          double.parse(curr.asv).abs() > double.parse(next.asv).abs()
              ? curr
              : next);
      return double.parse(item.asv).abs() ?? 0;
    }

    // 공매도
    else if(_divIndex == 2){
      if (_loanListData.length < 2) {
        return 0;
      }
      var item = _loanListData.reduce((curr, next) =>
      double.parse(curr.volumeBalance).abs() > double.parse(next.volumeBalance).abs()
          ? curr
          : next);
      return double.parse(item.volumeBalance).abs() ?? 0;
    }

    return 0;
  }

  _showBottomSheetSellingInfo() {
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
                        '공매도 이평 이란?',
                        style: TStyle.title18T,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                          '라씨매매비서의 공매도 차트는 공매도량에 이동평균선의 개념이 접목된 것으로 3개월 차트는 과거 3개월 공매도의 합, 6개월 차트는 6개월의 합, 12개월 차트는 12개월의 공매도 수량의 합을 일자별로 표시한 차트로 공매도의 기간별 추이를 파악할 수 있도록 작성된 차트입니다.'),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        '당일 공매도 데이터는 "표로 보기"에서 확인하실 수 있습니다.',
                      ),
                      const SizedBox(
                        height: 40,
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
}

class CustomRenderData {
  final String tradeDate;
  final String tradePrice;
  final String value;

  CustomRenderData({
    this.tradeDate = '',
    this.tradePrice = '',
    this.value = '',
  });
}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  static late CustomRenderData dataClass;
  bool _isShow = false;
  double xPoint = 0;
  final double deviceWidth;

  CustomCircleSymbolRenderer(this.deviceWidth);

  @override
  void paint(charts_common.ChartCanvas canvas, Rectangle<num> bounds, {
    List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx
  }) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    if (_isShow) {
      _isShow = false;
    } else {
      _isShow = true;

      int _overLength = 0;
      if (dataClass.value.length > 6) {
        _overLength = (dataClass.value.length - 5) * 3;
      }

      double minWidth = bounds.width + 80;
      xPoint = (deviceWidth / 2) > bounds.left
          ? bounds.left + 12
          : bounds.left - minWidth - 4;

      canvas.drawRect(
        Rectangle(
            xPoint, 0, bounds.width + 74 + _overLength, bounds.height + 62),
        fill: charts.Color(
          r: 102,
          g: 102,
          b: 102,
          a: 200,
        ),
      );

      var textStyle = charts_text_style.TextStyle();
      textStyle.color = charts.Color.white;
      textStyle.fontSize = 12;

      String color = '#5DD68D';
      String strTp = '${TStyle.getMoneyPoint(dataClass.tradePrice)}원';
      String strValue = TStyle.getMoneyPoint(dataClass.value);

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
            TStyle.getDateSlashFormat3(dataClass.tradeDate),
            style: textStyle),
        (xPoint + 8).round(),
        12.round(),
      );

      canvas.drawPoint(
        point: Point((xPoint + 12), 34),
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
        point: Point((xPoint + 12), 54),
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
