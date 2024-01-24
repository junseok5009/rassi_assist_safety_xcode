import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest21.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest22.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/stock_home/page/loan_transaction_list_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../common/const.dart';
import '../../../../common/net.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/tr_invest/tr_invest23.dart';
import '../../main/base_page.dart';

/// 2023.03.16_HJS
/// 종목홈(개편)_홈_대차거래와 공매

class StockHomeHomeTileLoanTransaction extends StatefulWidget {
  static final GlobalKey<StockHomeHomeTileLoanTransactionState> globalKey =
      GlobalKey();

  StockHomeHomeTileLoanTransaction() : super(key: globalKey);

  @override
  State<StockHomeHomeTileLoanTransaction> createState() =>
      StockHomeHomeTileLoanTransactionState();
}

class StockHomeHomeTileLoanTransactionState
    extends State<StockHomeHomeTileLoanTransaction>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileLoanTransaction> {
  final AppGlobal _appGlobal = AppGlobal();

  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 주, true 이면 천주
  int _divIndex = 0; // 0 : 대차거래 / 1 : 공매 / 2 : 신용융자
  final List<String> _divTitles = ['3개월', '6개월', '1년'];

  // 대차거래
  final List<Invest21ChartData> _lendingListData = [];
  int _lendingDateClickIndex = 0;

  // 공매
  final List<Invest22ChartData> _sellingListData = [];
  int _sellingDateClickIndex = 0;

  // 신용융자
  final List<Invest23ChartData> _loanListData = [];
  int _loanDateClickIndex = 0;

  late TrackballBehavior _trackballBehavior;

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
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      shouldAlwaysShow: true,
      //tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
      //enable: true,
      tooltipAlignment: ChartAlignment.near,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      activationMode: ActivationMode.singleTap,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        //color: Colors.red.shade500.withOpacity(0.5),
        borderWidth: 0,
        width: 0,
        height: 0,
      ),
      //tooltipAlignment: ChartAlignment.center,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        format: 'point.x : point.y원',
      ),
      builder: (BuildContext context, TrackballDetails trackballDetails) {
        DLog.e('pointIndex : ${trackballDetails.pointIndex} / '
        //'point : ${trackballDetails.point} / '
        //'seriesIndex : ${trackballDetails.seriesIndex} / '
        //'trackballDetails.series?.name : ${trackballDetails.series?.name} /'
            '\n trackballDetails.groupingModeInfo?.currentPointIndices.toString() : ${trackballDetails.groupingModeInfo?.currentPointIndices[0]} / '
        //'\n trackballDetails.groupingModeInfo?.points.toString() : $trackballDetails.groupingModeInfo?.points.toString() / '
        //'\n trackballDetails.groupingModeInfo?.visibleSeriesIndices.toString() : ${trackballDetails.groupingModeInfo?.visibleSeriesIndices.toString()} / '
        //'\n trackballDetails.groupingModeInfo?.visibleSeriesList.toString() : ${trackballDetails.groupingModeInfo?.visibleSeriesList.toString()}'
            '');
        int selectedIndex = trackballDetails.groupingModeInfo?.currentPointIndices[0] ?? 0;
        return Container(
          width: 100,
          height: 100,
          color: Colors.black.withOpacity(0.1),
          child: Container(
            height: 80,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.amber.shade100.withOpacity(0.30),
              border: Border.all(
                color: Colors.green,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                 _divIndex == 0 ?
                 _lendingListData[selectedIndex].td :
                 _divIndex == 1 ?
                 _sellingListData[selectedIndex].td :
                 _loanListData[selectedIndex].tradeDate,
                ),
                Text(
                  _divIndex == 0 ?
                  _lendingListData[selectedIndex].tp :
                  _divIndex == 1 ?
                  _sellingListData[selectedIndex].tp :
                  _loanListData[selectedIndex].tradePrice,
                ),
                Text(
                  _divIndex == 0 ?
                  _lendingListData[selectedIndex].bl :
                  _divIndex == 1 ?
                  _sellingListData[selectedIndex].asv :
                  _loanListData[selectedIndex].volumeBalance,
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
              style: const TextStyle(
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
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
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
        primaryYAxis: NumericAxis(
          isVisible: false,
          majorGridLines: const MajorGridLines(
            width: 0,
          ),
          majorTickLines: const MajorTickLines(
            width: 0,
          ),
          minorTickLines: const MinorTickLines(
            width: 0,
          ),
          rangePadding: ChartRangePadding.round,
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'yAxis',
            opposedPosition: true,
            anchorRangeToVisiblePoints: true,
            axisLine: const AxisLine(
              width: 0,
            ),
            majorGridLines: const MajorGridLines(
              color: RColor.chartGreyColor,
              width: 1.5,
              dashArray: [2, 4],
            ),
            majorTickLines: const MajorTickLines(
              width: 0,
            ),
            rangePadding: ChartRangePadding.round,
            //interval: _getInterval,
            axisLabelFormatter: (axisLabelRenderArgs) {
              String value = axisLabelRenderArgs.text;
              if (_isRightYAxisUpUnit) {
                value = TStyle.getMoneyPoint(
                    (axisLabelRenderArgs.value / 1000).round().toString());
              } else {
                value = TStyle.getMoneyPoint(
                    axisLabelRenderArgs.value.round().toString());
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
        //trackballBehavior: _trackballBehavior,
        //tooltipBehavior: TooltipBehavior(),
        trackballBehavior: _trackballBehavior,
        series: _getSeries,
      ),
    );
  }

  dynamic get _getSeries {
    if (_divIndex == 0) {
      return [
        AreaSeries<Invest21ChartData, String>(
          dataSource: _lendingListData,
          xValueMapper: (item, index) => item.td,
          yValueMapper: (item, index) => int.parse(item.bl),
          yAxisName: 'yAxis',
          color: RColor.chartGreen.withOpacity(0.08),
          borderWidth: 1.4,
          borderColor: RColor.chartGreen,
          enableTooltip: true,
        ),
        LineSeries<Invest21ChartData, String>(
          dataSource: _lendingListData,
          xValueMapper: (item, index) => item.td,
          yValueMapper: (item, index) => int.parse(item.tp),
          color: RColor.chartTradePriceColor,
          width: 1.4,
          enableTooltip: false,
        ),
      ];
    } else if (_divIndex == 1) {
      return [
        AreaSeries<Invest22ChartData, String>(
          dataSource: _sellingListData,
          xValueMapper: (item, index) => item.td,
          yValueMapper: (item, index) => int.parse(item.asv),
          yAxisName: 'yAxis',
          color: RColor.chartGreen.withOpacity(0.08),
          borderWidth: 1.4,
          borderColor: RColor.chartGreen,
          enableTooltip: true,
        ),
        LineSeries<Invest22ChartData, String>(
          dataSource: _sellingListData,
          xValueMapper: (item, index) => item.td,
          yValueMapper: (item, index) => int.parse(item.tp),
          color: RColor.chartTradePriceColor,
          width: 1.4,
          enableTooltip: false,
          //selectionBehavior: _selectionBehavior,
          //initialSelectedDataIndexes: <int>[_initSelectBarIndex],
          xAxisName: 'xAxis',
        ),
      ];
    } else if (_divIndex == 2) {
      return [
        AreaSeries<Invest23ChartData, String>(
          dataSource: _loanListData,
          xValueMapper: (item, index) => item.tradeDate,
          yValueMapper: (item, index) => int.parse(item.volumeBalance),
          yAxisName: 'yAxis',
          color: RColor.chartGreen.withOpacity(0.08),
          borderWidth: 1.4,
          borderColor: RColor.chartGreen,
          enableTooltip: true,
        ),
        LineSeries<Invest23ChartData, String>(
          dataSource: _loanListData,
          xValueMapper: (item, index) => item.tradeDate,
          yValueMapper: (item, index) => int.parse(item.tradePrice),
          color: RColor.chartTradePriceColor,
          width: 1.4,
          enableTooltip: false,
        ),
      ];
    } else {
      return [];
    }
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
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 대차거래
    if (trStr == TR.INVEST21) {
      final TrInvest21 resData =
          TrInvest21.fromJsonWithIndex(jsonDecode(response.body));
      _lendingListData.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest21 invest21 = resData.retData;
        if (invest21.listChartData.isNotEmpty) {
          _lendingListData.addAll(
            List.from(invest21.listChartData.reversed),
          );
          _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
        }
        setState(() {});
      }
    }

    // NOTE 공매도
    else if (trStr == TR.INVEST22) {
      final TrInvest22 resData =
          TrInvest22.fromJsonWithIndex(jsonDecode(response.body));
      _sellingListData.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest22 invest22 = resData.retData;
        if (invest22.listChartData.isNotEmpty) {
          _sellingListData.addAll(
            invest22.listChartData,
          );
          _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
        }
      }
      setState(() {});
    }

    // NOTE 신용 융자
    else if (trStr == TR.INVEST23) {
      final TrInvest23 resData =
          TrInvest23.fromJsonWithIndex(jsonDecode(response.body));
      _loanListData.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest23 invest23 = resData.retData;
        if (invest23.listChartData.isNotEmpty) {
          _loanListData.addAll(
            List.from(invest23.listChartData.reversed),
          );
          _isRightYAxisUpUnit = _findAbsMaxValue >= 1000;
        }
      }
      setState(() {});
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
      return double.parse(item.bl).abs();
    }

    // 공매도
    else if (_divIndex == 1) {
      if (_sellingListData.length < 2) {
        return 0;
      }
      var item = _sellingListData.reduce((curr, next) =>
          double.parse(curr.asv).abs() > double.parse(next.asv).abs()
              ? curr
              : next);
      return double.parse(item.asv).abs();
    }

    // 공매도
    else if (_divIndex == 2) {
      if (_loanListData.length < 2) {
        return 0;
      }
      var item = _loanListData.reduce((curr, next) =>
          double.parse(curr.volumeBalance).abs() >
                  double.parse(next.volumeBalance).abs()
              ? curr
              : next);
      return double.parse(item.volumeBalance).abs();
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
