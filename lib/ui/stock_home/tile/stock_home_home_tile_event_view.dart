import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search12.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_event_view_div_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_expanded_view.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/custom/CustomBoxShadow.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/stock_home/page/recent_social_list_page.dart';
import 'package:rassi_assist/ui/stock_home/page/result_analyze_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_disclos_list_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_issue_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';
import 'package:rassi_assist/ui/web/web_page.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_최상단 메인 이벤트 차트

class StockHomeHomeTileEventView extends StatefulWidget {
  static String TAG = 'StockHomeHomeTileEventView';
  static final GlobalKey<StockHomeHomeTileEventViewState> globalKey = GlobalKey();

  StockHomeHomeTileEventView() : super(key: globalKey);

  @override
  State<StockHomeHomeTileEventView> createState() => StockHomeHomeTileEventViewState();
}

class StockHomeHomeTileEventViewState extends State<StockHomeHomeTileEventView> {
  final _appGlobal = AppGlobal();
  String _userId = '';
  String _stockCode = '';
  String _stockName = '';
  bool _beforeOpening = false;
  bool _beforeChart = false;
  String _fluctuationRate = '0';
  ChartSeriesController? _chartAreaSeriesController;
  ChartSeriesController? _chartPreCloseSeriesController;

  // 1일 1개월 3개월..
  late StockHomeEventViewDivProvider _stockHomeEventViewDivProvider;
  final List<Search12DivModel> _listChartDateDivModel = Search12DivModel().getListDate();

  // 이슈발생, 커뮤니티, 시세특이, 공시발생
  int _eventDivSelectedIndex = 0;
  final List<Search12DivModel> _listEventChartDivModel = Search12DivModel().getListEvent();

  final List<String> _listEventMoreStr = ['종목이슈', '소셜지수', '자세한 차트', '공시 모아', '실적분석'];

  final List<Search12ChartData> _listChartData = [];
  String _commonChartPreClosePrice = '0';
  int _minTpChartDataIndex = -1;
  int _maxTpChartDataIndex = -1;

  late TrackballBehavior _trackballBehavior;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _userId = _appGlobal.userId;
    _stockCode = _appGlobal.stkCode;
    _stockName = _appGlobal.stkName;
    if (_stockHomeEventViewDivProvider.getIndex != 0) {
      _stockHomeEventViewDivProvider.setIndex(0);
    }
    _requestTrAll();
  }

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      lineDashArray: const [4, 3],
      shouldAlwaysShow: false,
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
        int selectedIndex = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        return Container(
          padding: const EdgeInsets.all(10),
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
                      _stockHomeEventViewDivProvider.getIndex == 0
                          ? '${_listChartData[selectedIndex].tt.substring(0, 2)}:${_listChartData[selectedIndex].tt.substring(2, 4)}'
                          : TStyle.getDateSlashFormat1(_listChartData[selectedIndex].td),
                      //TStyle.getDateSlashFormat1(_listChartData[selectedIndex].td),
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
                      '${TStyle.getMoneyPoint(_listChartData[selectedIndex].tp)}원',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (_stockHomeEventViewDivProvider.getIndex == 2 && _listChartData[selectedIndex].titleList.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxWidth: AppGlobal().deviceWidth - 200),
                    child: AutoSizeText(
                      _listChartData[selectedIndex].titleList.join('\n'),
                      maxLines: 2,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 5,
                        color: RColor.purpleBasic_6565ff,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    super.initState();
    _stockHomeEventViewDivProvider = Provider.of<StockHomeEventViewDivProvider>(
      context,
      listen: false,
    );
    initPage();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Column(
        children: [
          _setStockInfo(),
          Container(
            width: double.infinity,
            height: 250,
            color: RColor.bgBasic_fdfdfd,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    trackballBehavior: _trackballBehavior,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      plotOffset: 0,
                      interval: _stockHomeEventViewDivProvider.getIndex == 0 ? 8 : null,
                      plotBands: <PlotBand>[
                        if (_minTpChartDataIndex != -1 && _maxTpChartDataIndex != _minTpChartDataIndex)
                          PlotBand(
                            isVisible: true,
                            color: Colors.red,
                            start: _minTpChartDataIndex,
                            end: _minTpChartDataIndex,
                            associatedAxisEnd: int.parse(_listChartData[_minTpChartDataIndex].tp),
                            associatedAxisStart: int.parse(_listChartData[_minTpChartDataIndex].tp),
                            borderWidth: 10,
                            shouldRenderAboveSeries: true,
                            verticalTextPadding: '3%',
                            text: '최저\n${TStyle.getMoneyPoint(_listChartData[_minTpChartDataIndex].tp)}',
                            textAngle: 0,
                            textStyle: const TextStyle(
                              fontSize: 10,
                              color: RColor.bgSell,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            horizontalTextAlignment: _minTpChartDataIndex < _listChartData.length / 4
                                ? TextAnchor.start
                                : _minTpChartDataIndex > _listChartData.length / 4 * 3
                                    ? TextAnchor.end
                                    : TextAnchor.middle,
                            verticalTextAlignment: TextAnchor.end,
                          ),
                        if (_maxTpChartDataIndex != -1 && _minTpChartDataIndex != _maxTpChartDataIndex)
                          PlotBand(
                            isVisible: true,
                            start: _maxTpChartDataIndex,
                            end: _maxTpChartDataIndex,
                            associatedAxisEnd: int.parse(_listChartData[_maxTpChartDataIndex].tp),
                            associatedAxisStart: int.parse(_listChartData[_maxTpChartDataIndex].tp),
                            borderWidth: 0,
                            shouldRenderAboveSeries: true,
                            verticalTextPadding: '10%',
                            text: '최고\n${TStyle.getMoneyPoint(_listChartData[_maxTpChartDataIndex].tp)}',
                            textAngle: 0,
                            textStyle: const TextStyle(
                              fontSize: 10,
                              color: RColor.bgBuy,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            horizontalTextAlignment: _maxTpChartDataIndex < _listChartData.length / 8
                                ? TextAnchor.start
                                : _maxTpChartDataIndex > _listChartData.length / 8 * 7
                                    ? TextAnchor.end
                                    : TextAnchor.middle,
                            verticalTextAlignment: TextAnchor.start,
                          ),
                        // 09:20 데이터가 하나로, 최고 최저점이 같은 경우
                        if (_maxTpChartDataIndex != -1 &&
                            _minTpChartDataIndex != -1 &&
                            _minTpChartDataIndex == _maxTpChartDataIndex)
                          PlotBand(
                            isVisible: true,
                            start: _maxTpChartDataIndex,
                            end: _maxTpChartDataIndex,
                            associatedAxisEnd: int.parse(_listChartData[_maxTpChartDataIndex].tp),
                            associatedAxisStart: int.parse(_listChartData[_maxTpChartDataIndex].tp),
                            borderWidth: 0,
                            shouldRenderAboveSeries: true,
                            verticalTextPadding: '10%',
                            text: TStyle.getMoneyPoint(_listChartData[_maxTpChartDataIndex].tp),
                            textAngle: 0,
                            textStyle: const TextStyle(
                              fontSize: 10,
                              color: RColor.greyBasic_8c8c8c,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                            horizontalTextAlignment: TextAnchor.end,
                            verticalTextAlignment: TextAnchor.start,
                          ),
                        PlotBand(
                          isVisible: _stockHomeEventViewDivProvider.getIndex == 0 && !(_beforeOpening || _beforeChart),
                          associatedAxisStart: int.tryParse(_commonChartPreClosePrice) ?? 0,
                          associatedAxisEnd: int.tryParse(_commonChartPreClosePrice) ?? 0,
                          text: '전일종가 ${TStyle.getMoneyPoint(_commonChartPreClosePrice)}',
                          textAngle: 0,
                          textStyle: const TextStyle(
                            fontSize: 10,
                            color: RColor.greyBasic_8c8c8c,
                          ),
                          borderWidth: 0,
                          shouldRenderAboveSeries: true,
                          dashArray: const [3, 6],
                          verticalTextPadding: '1%',
                          horizontalTextAlignment: TextAnchor.end,
                          verticalTextAlignment: TextAnchor.end,
                        ),
                      ],
                      labelPlacement: LabelPlacement.onTicks,
                      labelStyle: const TextStyle(
                        fontSize: 10,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(
                        width: 0,
                      ),
                      majorTickLines: const MajorTickLines(
                        width: 0,
                      ),
                      opposedPosition: true,
                      rangePadding: ChartRangePadding.round,
                      majorGridLines: const MajorGridLines(width: 1),
                      plotOffset: 22,
                      axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                        TStyle.getMoneyPoint(axisLabelRenderArgs.text),
                        const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      decimalPlaces: 0,
                      // 소수점 안나오게
                      isVisible: !(_stockHomeEventViewDivProvider.getIndex == 0 && (_beforeOpening || _beforeChart)),
                      /*minimum: _stockHomeEventViewDivProvider.getIndex == 0
                          ? (double.tryParse(_commonChartPreClosePrice) ?? 0) >
                                  (double.tryParse(_findMinTpCommonItem.tp) ?? 0)
                              ? (double.tryParse(_findMinTpCommonItem.tp) ?? 0)
                              : (double.tryParse(_commonChartPreClosePrice) ?? 0)
                          : null,*/
                    ),
                    enableAxisAnimation: false,
                    onMarkerRender: (markerArgs) {
                      int lastTpItemIndex = _listChartData
                              .firstWhere(
                                (element) => element.tp.isEmpty,
                                orElse: () => Search12ChartData.empty(),
                              )
                              .index -
                          1;
                      if (markerArgs.pointIndex == 0 ||
                          (lastTpItemIndex > 0 && lastTpItemIndex == markerArgs.pointIndex) ||
                          (lastTpItemIndex < 0 && markerArgs.pointIndex == _listChartData.last.index)) {
                        if (_stockHomeEventViewDivProvider.getIndex == 2 &&
                            _listChartData[markerArgs.pointIndex!].ec.isNotEmpty &&
                            _listChartData[markerArgs.pointIndex!].ec != '0') {
                          markerArgs.shape = DataMarkerType.image;
                        } else {
                          markerArgs.markerWidth = 6;
                          markerArgs.markerHeight = 6;
                          markerArgs.color =
                              _fluctuationRate.contains('-') ? const Color(0xff9eb3ff) : const Color(0xffFF9090);
                          markerArgs.shape = DataMarkerType.circle;
                        }
                      } else if (markerArgs.pointIndex == _minTpChartDataIndex) {
                        markerArgs.markerWidth = 7;
                        markerArgs.markerHeight = 7;
                        markerArgs.shape = DataMarkerType.invertedTriangle;
                        markerArgs.color = RColor.sigSell;
                      } else if (markerArgs.pointIndex == _maxTpChartDataIndex) {
                        markerArgs.markerWidth = 7;
                        markerArgs.markerHeight = 7;
                        markerArgs.shape = DataMarkerType.triangle;
                        markerArgs.color = RColor.sigBuy;
                      } else if (_stockHomeEventViewDivProvider.getIndex == 2 &&
                          _listChartData[markerArgs.pointIndex!].ec.isNotEmpty &&
                          _listChartData[markerArgs.pointIndex!].ec != '0') {
                        markerArgs.shape = DataMarkerType.image;
                      } else {
                        markerArgs.markerWidth = 0;
                        markerArgs.markerHeight = 0;
                      }
                    },
                    series: [
                      AreaSeries<Search12ChartData, String>(
                        dataSource: _listChartData,
                        xValueMapper: (item, index) {
                          if (_stockHomeEventViewDivProvider.index == 0) {
                            String tt = item.tt;
                            if (tt.length >= 4) {
                              return '${tt.substring(0, 2)}:${tt.substring(2, 4)}';
                            } else {
                              return tt;
                            }
                          } else {
                            return TStyle.getDateSlashFormat1(item.td);
                          }
                        },
                        yValueMapper: (item, index) => int.tryParse(item.tp),
                        borderWidth: 1,
                        borderColor: _fluctuationRate.contains('-') ? const Color(0xff9eb3ff) : const Color(0xffFF9090),
                        gradient: LinearGradient(
                          colors: [
                            if (_fluctuationRate.contains('-'))
                              const Color(0xffb4c3fa).withOpacity(0.4)
                            else
                              const Color(0xffeea0a0).withOpacity(0.4),
                            const Color(0xffffffff),
                          ],
                          stops: const [
                            0,
                            1,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          color: _fluctuationRate.contains('-') ? const Color(0xff9eb3ff) : const Color(0xffFF9090),
                          width: 0,
                          height: 0,
                          borderWidth: 0,
                          shape: DataMarkerType.circle,
                        ),
                        borderDrawMode: BorderDrawMode.top,
                        animationDuration: 1500,
                        //animationDelay: 200,
                        onRendererCreated: (ChartSeriesController controller) {
                          _chartAreaSeriesController = controller;
                        },
                      ),
                      if (_stockHomeEventViewDivProvider.getIndex == 2)
                        LineSeries<Search12ChartData, String>(
                          dataSource: _listChartData,
                          xValueMapper: (item, index) => TStyle.getDateSlashFormat1(item.td),
                          yValueMapper: (item, index) => int.tryParse(item.tp),
                          color: Colors.transparent,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            width: _eventDivSelectedIndex == 0
                                ? 10
                                : _eventDivSelectedIndex == 1
                                    ? 11
                                    : _eventDivSelectedIndex == 2
                                        ? 10
                                        : _eventDivSelectedIndex == 3
                                            ? 16
                                            : 14,
                            height: _eventDivSelectedIndex == 0
                                ? 10
                                : _eventDivSelectedIndex == 1
                                    ? 11
                                    : _eventDivSelectedIndex == 2
                                        ? 10
                                        : _eventDivSelectedIndex == 3
                                            ? 16
                                            : 14,
                            shape: DataMarkerType.image,
                            image: AssetImage(_eventDivSelectedIndex == 0
                                ? 'images/icon_event_chart_0.png'
                                : _eventDivSelectedIndex == 1
                                    ? 'images/icon_event_chart_1.png'
                                    : _eventDivSelectedIndex == 2
                                        ? 'images/icon_event_chart_2.png'
                                        : _eventDivSelectedIndex == 3
                                            ? 'images/icon_event_chart_3.png'
                                            : _eventDivSelectedIndex == 4
                                                ? 'images/icon_event_chart_4.png'
                                                : 'images/icon_event_chart_0.png'),
                          ),
                        ),
                      if (_stockHomeEventViewDivProvider.getIndex == 0 &&
                          _commonChartPreClosePrice.isNotEmpty &&
                          _commonChartPreClosePrice != '0' &&
                          !(_beforeOpening || _beforeChart))
                        LineSeries<Search12ChartData, String>(
                          dataSource: _listChartData,
                          xValueMapper: (item, index) {
                            String tt = item.tt;
                            if (tt.length >= 4) {
                              return '${tt.substring(0, 2)}:${tt.substring(2, 4)}';
                            } else {
                              return tt;
                            }
                          },
                          yValueMapper: (item, index) => int.tryParse(_commonChartPreClosePrice) ?? 0,
                          width: 0,
                          color: Colors.transparent,
                          animationDuration: 2000,
                          trendlines: [
                            Trendline(
                              isVisible: true,
                              width: 1,
                              dashArray: [4, 3],
                              color: RColor.greyBasic_8c8c8c,
                            )
                          ],
                          onRendererCreated: (ChartSeriesController controller) {
                            _chartPreCloseSeriesController = controller;
                          },
                        ),
                    ],
                  ),
                ),
                if (_beforeOpening && _stockHomeEventViewDivProvider.getIndex == 0)
                  Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 28,
                    ),
                    child: const Text('장 시작 전 입니다.'),
                  )
                else if (_beforeChart && _stockHomeEventViewDivProvider.getIndex == 0)
                  Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 28,
                    ),
                    child: const Text(
                      '20분부터 업데이트 됩니다.\n(20분 지연)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  )
                else if (_stockHomeEventViewDivProvider.getIndex == 2 && _isEventExist)
                  Container(
                    alignment: Alignment.center,
                    //color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 28,
                    ),
                    child: Text(
                      '최근 3개월간 ${_listEventChartDivModel[_eventDivSelectedIndex].divName.replaceAll('\n', '')} 이벤트가 없습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ),

                /*Visibility(
                  visible: _beforeOpening &&
                      _stockHomeEventViewDivProvider.getIndex == 0,
                  child: Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(bottom: 30,),
                    child: const Text('장 시작 전 입니다.'),
                  ),
                ),*/
                /* Visibility(
                  visible: _stockHomeEventViewDivProvider.getIndex == 2 &&
                      _isEventExist,
                  child: Center(
                    child: Text(
                      '최근 3개월간 ${_listEventChartDivModel[_eventDivSelectedIndex].divName.replaceAll('\n', '')} 이벤트가 없습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 10.0,
              alignment: WrapAlignment.center,
              children: List.generate(
                _listChartDateDivModel.length,
                (index) => _setEventChartDateDivView(index),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          CommonExpandedView(
            expand: _stockHomeEventViewDivProvider.getIndex == 2,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  decoration: UIStyle.boxRoundFullColor6c(
                    RColor.greyBox_f5f5f5,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'EVENT를 선택 후 발생 시점을 차트에서 확인해 보세요.',
                    style: TextStyle(
                      fontSize: 13,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  child: Wrap(
                    spacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      _listEventChartDivModel.length,
                      (index) => _setEventDivView(index),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: UIStyle.boxRoundLine6(),
                    alignment: Alignment.center,
                    child: Text(
                      '${_listEventMoreStr[_eventDivSelectedIndex]} 보기',
                      //style: TStyle.subTitle16,
                    ),
                  ),
                  onTap: () {
                    switch (_eventDivSelectedIndex) {
                      case 0:
                        {
                          // make
                          basePageState.callPageRoute(
                            StockIssuePage(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                      case 1:
                        {
                          // 커뮤니티
                          basePageState.callPageRouteData(
                            const RecentSocialListPage(),
                            PgData(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                      case 2:
                        {
                          // 시세특이
                          Navigator.push(
                            context,
                            CustomNvRouteClass.createRouteData(
                              const WebPage(),
                              RouteSettings(
                                arguments: PgData(
                                  pgData: 'https://m.thinkpool.com/item/$_stockCode/chart',
                                ),
                              ),
                            ),
                          );
                          break;
                        }
                      case 3:
                        {
                          // 공시발생
                          basePageState.callPageRouteData(
                            const StockDisclosListPage(),
                            PgData(
                              stockName: AppGlobal().stkName,
                              stockCode: AppGlobal().stkCode,
                            ),
                          );
                          break;
                        }
                      case 4:
                        {
                          // 실적발표
                          basePageState.callPageRouteData(
                            const ResultAnalyzePage(),
                            PgData(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 종목정보 - 가격, 등락률, 서브정보들
  Widget _setStockInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        _stockName,
                        style: TStyle.title18T,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      _stockCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Consumer<StockInfoProvider>(
                builder: ((_, provider, child) {
                  if (provider.getIsMyStock) {
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: UIStyle.boxRoundLine6LineColor(
                          RColor.mainColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 17,
                              height: 17,
                              child: Image.asset(
                                'images/icon_my_pock_on.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              '포켓에서 삭제',
                              style: TextStyle(
                                fontSize: 13,
                                color: RColor.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        StockHomeTab.globalKey.currentState?.showDelStockPopupAndResult(
                          provider.getPockSn,
                        );
                      },
                    );
                  } else {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: UIStyle.boxRoundLine6LineColor(Colors.black),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 17,
                              height: 17,
                              child: Image.asset(
                                'images/icon_my_pock_off.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              '포켓에 넣기',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        StockHomeTab.globalKey.currentState?.showAddStockLayerAndResult();
                      },
                    );
                  }
                }),
              ),
            ],
          ),
          Consumer<StockInfoProvider>(
            builder: (_, provider, __) {
              if (provider.getIsLoading) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 71,
                  child: SkeletonLoader(
                    items: 1,
                    period: const Duration(seconds: 2),
                    highlightColor: Colors.grey[100]!,
                    direction: SkeletonDirection.ltr,
                    builder: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                      ),
                      alignment: Alignment.centerLeft,
                      //decoration: UIStyle.boxRoundLine6(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 2 / 5,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: 71,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            TStyle.getMoneyPoint(provider.getCurrentPrice),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                          const Text(
                            '원',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            provider.getTimeTxt,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: provider.getTradingHaltYn == 'N'
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        provider.getCurrentSubInfo,
                                        style: TextStyle(
                                          color: TStyle.getMinusPlusColor(
                                            provider.getFluctaionRate,
                                          ),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _stockHomeEventViewDivProvider.getIndex == 0
                                            ? ''
                                            : _stockHomeEventViewDivProvider.getIndex == 1
                                                ? '(1개월 수익률)'
                                                : _stockHomeEventViewDivProvider.getIndex == 2
                                                    ? '(3개월 수익률)'
                                                    : _stockHomeEventViewDivProvider.getIndex == 3
                                                        ? '(올해 수익률)'
                                                        : _stockHomeEventViewDivProvider.getIndex == 4
                                                            ? '(1년 수익률)'
                                                            : _stockHomeEventViewDivProvider.getIndex == 5
                                                                ? '(3년 수익률)'
                                                                : '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '0  0.00%',
                                        style: TextStyle(
                                          color: RColor.greyBasic_8c8c8c,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '거래정지',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: RColor.greyBasic_8c8c8c,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            width: 76,
                            child: IconButton(
                              icon: Image.asset('images/icon_chart1.png'),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.topRight,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                // 시세특이
                                Navigator.push(
                                  context,
                                  CustomNvRouteClass.createRouteData(
                                    const WebPage(),
                                    RouteSettings(
                                      arguments: PgData(
                                        pgData: 'https://m.thinkpool.com/item/$_stockCode/chart',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _setEventChartDateDivView(int index) {
    if (_stockHomeEventViewDivProvider.getIndex == index) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: UIStyle.boxRoundFullColor25c(
          RColor.greySliderBar_ebebeb,
        ),
        child: Text(
          _listChartDateDivModel[index].divName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );
    } else {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          _stockHomeEventViewDivProvider.setIndex(index);
          Provider.of<StockInfoProvider>(context, listen: false).postRequestDiv(
            _stockCode,
            _listChartDateDivModel[index].divCode,
          );
          _requestTrAll();
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Text(
            _listChartDateDivModel[index].divName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: index == 2 ? RColor.purpleBasic_6565ff : RColor.greyBasic_8c8c8c,
              fontWeight: index == 2 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    }
  }

  Widget _setEventDivView(int index) {
    if (_eventDivSelectedIndex == index) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Text(
          _listEventChartDivModel[index].divName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      );
    } else {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          _eventDivSelectedIndex = index;
          _requestTrAll();
          /* setState(() {
            _eventDivSelectedIndex = index;
            _requestTrAll();
          });*/
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            //color: RColor.greyBoxLine_c9c9c9,
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: RColor.greyBasic_8c8c8c,
              width: 1,
            ),
          ),
          child: Text(
            _listEventChartDivModel[index].divName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: RColor.greyBasic_8c8c8c,
              height: 1.2,
            ),
          ),
        ),
      );
    }
  }

  int get _findMaxTpChartDataIndex {
    final nonNullList = _listChartData.where((data) => double.tryParse(data.tp) != null).toList();
    if (nonNullList.isEmpty) {
      return -1;
    } else if (nonNullList.length == 1) {
      return 0;
    } else {
      return nonNullList
          .reduce(
            (curr, next) => (double.tryParse(curr.tp) ?? 0) > (double.tryParse(next.tp) ?? 0) ? curr : next,
          )
          .index;
    }
  }

  int get _findMinTpChartDataIndex {
    final nonNullList = _listChartData.where((data) => double.tryParse(data.tp) != null).toList();
    if (nonNullList.isEmpty) {
      return -1;
    } else if (nonNullList.length == 1) {
      return 0;
    } else {
      return nonNullList
          .reduce(
            (curr, next) => (double.tryParse(curr.tp) ?? 0) > (double.tryParse(next.tp) ?? 0) ? next : curr,
          )
          .index;
    }
  }

  bool get _isEventExist {
    //bool isEventExist = false;
    for (var item in _listChartData) {
      int eventCount = int.tryParse(item.ec) ?? 0;
      if (eventCount != 0) {
        return false;
      }
    }
    return true;
    //return isEventExist;
  }

  _requestTrAll() async {
    // DEFINE SEARCH12 차트

    var url = Uri.parse(Net.TR_BASE + TR.SEARCH12);
    try {
      final http.Response response = await http
          .post(
            url,
            body: jsonEncode(
              <String, String>{
                'userId': _userId,
                'stockCode': _stockCode,
                'selectDiv': _listChartDateDivModel[_stockHomeEventViewDivProvider.getIndex].divCode,
                if (_stockHomeEventViewDivProvider.getIndex == 2)
                  'menuDiv': _listEventChartDivModel[_eventDivSelectedIndex].divCode,
              },
            ),
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      final TrSearch12 resData = TrSearch12.fromJson(jsonDecode(response.body));
      _beforeOpening = false;
      _beforeChart = false;
      _fluctuationRate = '0';
      _listChartData.clear();
      _minTpChartDataIndex = -1;
      _maxTpChartDataIndex = -1;
      _chartAreaSeriesController?.isVisible = false;
      _chartPreCloseSeriesController?.isVisible = false;
      //setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      if (resData.retCode == RT.SUCCESS && resData.retData != null) {
        Search12 search12 = resData.retData!;
        _beforeOpening = search12.beforeOpening == 'Y';
        _beforeChart = search12.beforeChart == 'Y';
        _commonChartPreClosePrice = search12.basePrice;
        _fluctuationRate = search12.search01!.fluctuationRate;
        _listChartData.addAll(search12.listPriceChart);
        _minTpChartDataIndex = _findMinTpChartDataIndex;
        _maxTpChartDataIndex = _findMaxTpChartDataIndex;
        setState(() {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _chartAreaSeriesController?.isVisible = true;
            _chartPreCloseSeriesController?.isVisible = true;
            _chartAreaSeriesController?.animate();
            _chartPreCloseSeriesController?.animate();
          });
        });
      }
    } on TimeoutException catch (_) {
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }
}
