import 'dart:async';
import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme04.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme05.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme06.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 2022.04.22 - JY
/// (핫)테마 상세보기
class ThemeHotViewer extends StatefulWidget {
  static const routeName = '/page_theme_viewer';
  static const String TAG = "[ThemeHotViewer] ";
  static const String TAG_NAME = '테마_상세보기';

  const ThemeHotViewer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeHotViewerState();
}

class ThemeHotViewerState extends State<ThemeHotViewer> {
  late SharedPreferences _prefs;
  String _userId = "";
  String _themeCode = '';

  Theme04 _theme04Item = const Theme04();

  bool _isBearTheme = false;
  String _selDiv = '';

  // 현재 테마 주도주
  bool _isLeadingTop3 = true; // true : 단기 강세 TOP 3 <> false : 추세주도주
  late TrackballBehavior _trackballBehavior;
  final List<Theme05StockChart> _leadingStockList = [];

  // 테마 차트
  final List<ChartTheme> _listThemeChart = [];
  int _highestThemeChartListIndex = 0;
  int _lowestThemeChartListIndex = 0;
  late TrackballBehavior _trackballBehaviorTheme;
  int _themeDivIndex = 0; // 0 : 1개월 / 1 : 3개월 / 2 : 6개월 / 3 : 12개월
  final List<String> _themeDivTitles = ['1M', '3M', '6M', '1Y'];

  final List<TopCard> _tcList = [];
  final List<ThemeStHistory> _thList = [];

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
        Theme05ChartData? item1, item2, item3;
        bool isCandleDivMin = false;
        int index = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        if (_leadingStockList.isNotEmpty && index < _leadingStockList[0].listChart.length) {
          item1 = _leadingStockList[0].listChart[index];
          isCandleDivMin = _leadingStockList[0].candleDiv == 'MIN';
        }
        if (_leadingStockList.length >= 2 && index < _leadingStockList[1].listChart.length) {
          item2 = _leadingStockList[1].listChart[index];
        }
        if (_leadingStockList.length >= 3 && index < _leadingStockList[2].listChart.length) {
          item3 = _leadingStockList[2].listChart[index];
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2,),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item1 == null
                          ? ''
                          : isCandleDivMin
                              ? '${TStyle.getDateSlashFormat1(item1.td)}  ${item1.tt.substring(0, 2)}:${item1.tt.substring(2)}'
                              : TStyle.getDateSlashFormat1(item1.td),
                      style: const TextStyle(
                        fontSize: 11,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ],
                ),
                if (item1 != null)
                  Row(
                    children: [
                      _leadingStockChartCircleTrackBall(const Color(0xffFBD240)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _leadingStockList[0].stockName,
                        style: const TextStyle(
                          fontSize: 13,
                          //color: title == '매수' ? RColor.bgBuy : RColor.bgSell,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${TStyle.getMoneyPoint(
                          item1.tp,
                        )}원',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (item2 != null)
                  Row(
                    children: [
                      _leadingStockChartCircleTrackBall(const Color(0xff5DD68D)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _leadingStockList[1].stockName,
                        style: const TextStyle(
                          fontSize: 13,
                          //color: title == '매수' ? RColor.bgBuy : RColor.bgSell,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${TStyle.getMoneyPoint(item2.tp)}원',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (item3 != null)
                  Row(
                    children: [
                      _leadingStockChartCircleTrackBall(const Color(0xffaba5f1)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _leadingStockList[2].stockName,
                        style: const TextStyle(
                          fontSize: 13,
                          //color: title == '매수' ? RColor.bgBuy : RColor.bgSell,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${TStyle.getMoneyPoint(item3.tp)}원',
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
    _trackballBehaviorTheme = TrackballBehavior(
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
        ChartTheme? item;
        if (_listThemeChart.isNotEmpty && index < _listThemeChart.length) {
          item = _listThemeChart[index];
        }
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
                      item == null ? '' : TStyle.getDateSlashFormat1(item.tradeDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ],
                ),
                if (item != null)
                  Row(
                    children: [
                      _leadingStockChartCircleTrackBall(
                        RColor.chartGreen,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        TStyle.getMoneyPoint(item.tradeIndex),
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
      ThemeHotViewer.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
        _themeCode = args.pgSn;
        if (_themeCode.isEmpty) {
          Navigator.pop(context);
        }
        if (_userId != '') {
          _fetchPosts(
              TR.THEME05,
              jsonEncode(<String, String>{
                'userId': _userId,
                'themeCode': _themeCode,
                'selectDiv': 'SHORT', //SHORT: 단기강세TOP3, TREND: 추세주도주
              }));
          _fetchPosts(
              TR.THEME04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'themeCode': _themeCode,
                'periodMonth': '1',
              }));
          _fetchPosts(
              TR.THEME06,
              jsonEncode(<String, String>{
                'userId': _userId,
                'themeCode': _themeCode,
                'topStockYn': 'Y',
                'pageNo': '0',
                'pageItemSize': '5',
              }));
        }
      });
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
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 테마명
              Text(
                '${_theme04Item.themeObj.themeName} 테마',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // 전일비
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '전일대비 ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  CommonView.setFluctuationRateBox(value: _theme04Item.themeObj.increaseRate,),
                ],
              ),

              const SizedBox(
                height: 5,
              ),

              // 테마 설명
              _paddingView(
                child: Text(
                  _theme04Item.themeObj.themeDesc,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              // 테마 추세는 ?
              _paddingView(
                child: _setThemeStatus(),
              ),

              CommonView.setDivideLine,

              // 현재 테마 주도주
              _setLeadingStockView,

              CommonView.setDivideLine,

              //테마 지수 차트 (THEME04)
              _paddingView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '테마 차트',
                      style: TStyle.defaultTitle,
                    ),
                    Row(
                      children: [
                        Text(
                          '${_theme04Item.periodMonth}개월 동안',
                          style: const TextStyle(color: RColor.greyBasic_8c8c8c,
                          ),
                        ),
                        const SizedBox(width: 6,),
                        CommonView.setFluctuationRateBox(value: _theme04Item.periodFluctRate,),
                      ],
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 10.0,),
              _paddingView(child: _themeChart),

              const SizedBox(
                height: 10.0,
              ),

              _themeDateDivView,

              const SizedBox(
                height: 10.0,
              ),

              //테마주도주 히스토리 (THEME06)
              if (_tcList.isNotEmpty) _paddingView(child: _setCardHistory()),
              if (_thList.isEmpty)
                _paddingView(child: CommonView.setNoDataView(150, '히스토리 데이터가 없습니다.'))
              else
                ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                  itemCount: _thList.length,
                  itemBuilder: (context, index) {
                    return TileTheme06List(_thList[index]);
                  },
                ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 테마 추세는 ?
  Widget _setThemeStatus() {
    bool isBull = true;
    String status = '';
    String statusSub = '';
    String themeStatus = _theme04Item.themeObj.themeStatus;
    if (themeStatus == 'BULL') {
      isBull = true;
      status = '강세';
      statusSub = '추세';
    } else if (themeStatus == 'Bullish') {
      isBull = true;
      status = '강세';
      statusSub = '추세';
    } else if (themeStatus == 'BEAR') {
      isBull = false;
      status = '약세';
      statusSub = '추세';
    } else if (themeStatus == 'Bearish') {
      isBull = false;
      status = '약세';
      statusSub = '전환';
    }
    return InkWell(
      onTap: () => _showDialogDesc(RString.desc_hot_theme_index_pop),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: UIStyle.boxRoundFullColor16c(
          const Color(0xff353B6F),
        ),
        padding: const EdgeInsets.all(
          15,
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'images/icon_rassi_logo_white.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const ImageIcon(
                        AssetImage(
                          'images/rassi_icon_qu_bl.png',
                        ),
                        size: 20,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showDialogDesc(RString.desc_hot_theme_index_pop);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '라씨 매매비서가 분석한\n현재 테마 추세는?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            FittedBox(
              child: Container(
                //constraints: BoxConstraints(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBull ? RColor.bgBuy : RColor.bgSell,
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      status + statusSub,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      _theme04Item.themeObj.elapsedDays,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '일째',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  // ㅡㅡㅡ 현재 테마주도주 ㅡㅡㅡ
  Widget get _setLeadingStockView {
    return _paddingView(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              '현재 테마 주도주',
              style: TStyle.defaultTitle,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // 단기 강세 <> 이번 추세 주도주
          _setLeadingStockDivButtons,

          const SizedBox(
            height: 20,
          ),

          // 현재 테마 주도주 설명
          Text(
            _isLeadingTop3 ? RString.desc_theme_stock_short : RString.desc_theme_stock_trend,
            style: TStyle.textGrey15,
            textAlign: TextAlign.left,
          ),

          const SizedBox(
            height: 15,
          ),

          // 현재 테마 주도주 차트
          if (!_isBearTheme)
            if (_isLeadingTop3) _leadingStockTop3Chart else _leadingStockTrendsChart,
          if (!_isBearTheme)
            const SizedBox(
              height: 10,
            ),
          if (!_isBearTheme) _leadingStockChartCircleParent,

          _isBearTheme
              ? CommonView.setNoDataView(
                  150,
                  '테마 추세가 현재 약세일 경우\n주도주가 분석되지 않습니다.',
                )
              : ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _leadingStockList.length,
                  itemBuilder: (context, index) {
                    return TileTheme05(index, _leadingStockList[index], _selDiv);
                  },
                ),
        ],
      ),
    );
  }

  Widget get _setLeadingStockDivButtons {
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
                  color: !_isLeadingTop3 ? RColor.lineGrey : Colors.black,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '단기 강세 TOP3',
                  style: !_isLeadingTop3 ? const TextStyle(fontSize: 15, color: RColor.lineGrey) : TStyle.commonTitle15,
                ),
              ),
            ),
            onTap: () {
              if (!_isLeadingTop3) {
                setState(() {
                  _isLeadingTop3 = true;
                  _leadingStockList.clear();
                });
                _requestTheme05('SHORT');
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
                  color: !_isLeadingTop3 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '이번 추세 주도주',
                  style: !_isLeadingTop3
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_isLeadingTop3) {
                setState(() {
                  _isLeadingTop3 = false;
                  _leadingStockList.clear();
                });
              }
              _requestTheme05('TREND');
            },
          ),
        ),
      ],
    );
  }

  ChartAxis _leadingStockChartYAxis(String axisName) => NumericAxis(
        rangePadding: ChartRangePadding.round,
        opposedPosition: true,
        axisLine: const AxisLine(
          width: 0,
        ),
        majorGridLines: MajorGridLines(
          width: axisName.contains('1') ? 1 : 0,
        ),
        majorTickLines: const MajorTickLines(
          width: 0,
        ),
        desiredIntervals: 4,
        name: axisName,
        labelFormat: '',
        labelPosition: ChartDataLabelPosition.inside,
        labelStyle: const TextStyle(
          fontSize: 0,
        ),
      );

  Widget _paddingView({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: child,
      );

  Widget get _leadingStockTop3Chart {
    if (_leadingStockList.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        enableMultiSelection: false,
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
            axisBorderType: AxisBorderType.withoutTopAndBottom,
            axisLine: const AxisLine(
              width: 1,
              color: Colors.black,
            ),
            majorGridLines: const MajorGridLines(
              width: 0,
            ),
            majorTickLines: const MajorTickLines(
              width: 1,
              color: Colors.black,
            ),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            axisLabelFormatter: (axisLabelRenderArgs) {
              String labelDate = '';
              int index = axisLabelRenderArgs.value.toInt();
              if (_leadingStockList.isNotEmpty) {
                Theme05ChartData item = _leadingStockList[0].listChart[index];
                labelDate =
                    '${TStyle.getDateSlashFormat1(item.td)}\n${item.tt.substring(0, 2)}:${item.tt.substring(2)}';
              }
              return ChartAxisLabel(
                labelDate,
                const TextStyle(
                  fontSize: 10,
                  color: RColor.greyBasic_8c8c8c,
                ),
              );
            }),
        primaryYAxis: _leadingStockChartYAxis('yAxis1'),
        axes: [
          _leadingStockChartYAxis('yAxis2'),
          _leadingStockChartYAxis('yAxis3'),
        ],
        trackballBehavior: _trackballBehavior,
        selectionType: SelectionType.point,
        series: [
          if (_leadingStockList.isNotEmpty)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[0].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xffFBD240),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis1',
            ),
          if (_leadingStockList.length >= 2)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[1].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xff5DD68D),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis2',
            ),
          if (_leadingStockList.length >= 3)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[2].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xffaba5f1),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis3',
            ),
        ],
      ),
    );
  }

  Widget get _leadingStockTrendsChart {
    if (_leadingStockList.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        enableMultiSelection: false,
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
            axisBorderType: AxisBorderType.withoutTopAndBottom,
            axisLine: const AxisLine(
              width: 1,
              color: Colors.black,
            ),
            majorGridLines: const MajorGridLines(
              width: 0,
            ),
            majorTickLines: const MajorTickLines(
              width: 1,
              color: Colors.black,
            ),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            axisLabelFormatter: (axisLabelRenderArgs) {
              String labelDate = '';
              int index = axisLabelRenderArgs.value.toInt();
              if (_leadingStockList.isNotEmpty) {
                Theme05ChartData item = _leadingStockList[0].listChart[index];
                labelDate = _leadingStockList[0].candleDiv == 'MIN'
                    ? '${TStyle.getDateSlashFormat1(item.td)}\n${item.tt.substring(0, 2)}:${item.tt.substring(2)}'
                    : TStyle.getDateSlashFormat1(item.td);
              }
              return ChartAxisLabel(
                labelDate,
                const TextStyle(
                  fontSize: 10,
                  color: RColor.greyBasic_8c8c8c,
                ),
              );
            }),
        primaryYAxis: _leadingStockChartYAxis('yAxis1'),
        axes: [
          _leadingStockChartYAxis('yAxis2'),
          _leadingStockChartYAxis('yAxis3'),
        ],
        trackballBehavior: _trackballBehavior,
        selectionType: SelectionType.point,
        series: [
          if (_leadingStockList.isNotEmpty)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[0].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xffFBD240),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis1',
            ),
          if (_leadingStockList.length >= 2)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[1].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xff5DD68D),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis2',
            ),
          if (_leadingStockList.length >= 3)
            LineSeries<Theme05ChartData, int>(
              dataSource: _leadingStockList[2].listChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => int.parse(item.tp),
              color: const Color(0xffaba5f1),
              width: 1.4,
              enableTooltip: false,
              yAxisName: 'yAxis3',
            ),
        ],
      ),
    );
  }

  Widget get _leadingStockChartCircleParent {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_leadingStockList.isNotEmpty)
          _leadingStockChartCircle(
            _leadingStockList[0].stockName,
            const Color(0xffFBD240),
          ),
        if (_leadingStockList.length > 1)
          const SizedBox(
            width: 10,
          ),
        if (_leadingStockList.length > 1)
          _leadingStockChartCircle(_leadingStockList[1].stockName, const Color(0xff5DD68D)),
        if (_leadingStockList.length > 2)
          const SizedBox(
            width: 10,
          ),
        if (_leadingStockList.length > 2)
          _leadingStockChartCircle(_leadingStockList[02].stockName, const Color(0xffaba5f1)),
      ],
    );
  }

  Widget _leadingStockChartCircle(String stockName, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          //color: Color(0xffFF5050),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        //const SizedBox(width: 4,),
        Text(
          '  $stockName',
          style: const TextStyle(
            fontSize: 11,
            color: RColor.new_basic_text_color_grey,
          ),
        ),
      ],
    );
  }

  Widget _leadingStockChartCircleTrackBall(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ㅡㅡㅡ 현재 테마주도주 끝 ㅡㅡㅡ

  //차트 테마지수
  Widget get _themeChart {
    if (_listThemeChart.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        enableMultiSelection: false,
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
            axisBorderType: AxisBorderType.withoutTopAndBottom,
            axisLine: const AxisLine(
              width: 1,
              color: Colors.black,
            ),
            majorGridLines: const MajorGridLines(
              width: 0,
            ),
            majorTickLines: const MajorTickLines(
              width: 1,
              color: Colors.black,
            ),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            axisLabelFormatter: (axisLabelRenderArgs) {
              int index = axisLabelRenderArgs.value.toInt();
              return ChartAxisLabel(
                TStyle.getDateSlashFormat1(_listThemeChart[index].tradeDate),
                const TextStyle(
                  fontSize: 10,
                  color: RColor.greyBasic_8c8c8c,
                ),
              );
            }),
        primaryYAxis: NumericAxis(
          rangePadding: ChartRangePadding.round,
          opposedPosition: true,
          axisLine: const AxisLine(
            width: 0,
          ),
          majorGridLines: const MajorGridLines(
            width: 1,
          ),
          majorTickLines: const MajorTickLines(
            width: 0,
          ),
          axisLabelFormatter: (axisLabelRenderArgs) {
            return ChartAxisLabel(
              TStyle.getMoneyPoint(axisLabelRenderArgs.value.toString()),
              const TextStyle(
                fontSize: 10,
                color: RColor.greyBasic_8c8c8c,
              ),
            );
          },
        ),
        trackballBehavior: _trackballBehaviorTheme,
        selectionType: SelectionType.point,
        series: [
          if (_listThemeChart.isNotEmpty)
            LineSeries<ChartTheme, int>(
              dataSource: _listThemeChart,
              xValueMapper: (item, index) => index,
              yValueMapper: (item, index) => double.parse(item.tradeIndex),
              color: RColor.chartGreen,
              width: 1.4,
              enableTooltip: false,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                borderWidth: 1,
                borderColor: RColor.greyBoxLine_c9c9c9,
                color: Colors.white,
                opacity: 0.6,
                //labelAlignment: ChartDataLabelAlignment.top,
                textStyle: const TextStyle(
                  fontSize: 8,
                  color: Colors.black,
                ),
                showZeroValue: true,
                margin: EdgeInsets.zero,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  if (pointIndex == _highestThemeChartListIndex) {
                    //DLog.e('최고 index : $pointIndex');
                    //return '최고123';
                    //return '최고 ${TStyle.getMoneyPoint(datum.tradePrice)}원';
                    return Text(
                      '최고 ${TStyle.getMoneyPoint(_listThemeChart[pointIndex].tradeIndex)}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    );
                  } else if (pointIndex == _lowestThemeChartListIndex) {
                    //DLog.e('최저 index : $index');
                    //return '최저';
                    //return '최저 ${TStyle.getMoneyPoint(datum.tradePrice)}원';
                    return Text(
                      '최저 ${TStyle.getMoneyPoint(_listThemeChart[pointIndex].tradeIndex)}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    );
                  } else {
                    //DLog.e('기타 index : $index');
                    return const SizedBox();
                  }
                  //return Container(child: Text('${TStyle.getMoneyPoint(_listData[pointIndex].tradePrice)}원'),);
                },
                //overflowMode: OverflowMode.shift,
              ),
            ),
        ],
      ),
    );
  }

  Widget get _themeDateDivView {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              if (_themeDivIndex != index) {
                setState(() {
                  _themeDivIndex = index;
                });
                _requestTheme04(_themeDivIndex == 0
                    ? '1'
                    : _themeDivIndex == 1
                        ? '3'
                        : _themeDivIndex == 2
                            ? '6'
                            : _themeDivIndex == 3
                                ? '12'
                                : '1');
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
      decoration: (_themeDivIndex == index) ? UIStyle.boxNewSelectBtn2() : UIStyle.boxNewUnSelectBtn2(),
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 15,
      ),
      child: Text(
        _themeDivTitles[index],
        style: TextStyle(
          color: (_themeDivIndex == index) ? Colors.black : RColor.new_basic_text_color_grey,
          fontSize: 14,
          fontWeight: (_themeDivIndex == index) ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  //테마주도주 히스토리 (THEME06)
  Widget _setCardHistory() {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Swiper(
        controller: SwiperController(),
        pagination: _tcList.length < 2
            ? null
            : CommonSwiperPagenation.getNormalSpWithMargin2(
                6,
                0,
                RColor.purpleBasic_6565ff,
              ),
        itemCount: _tcList.length,
        itemBuilder: (BuildContext context, int index) {
          return TileTheme06(_tcList[index]);
        },
      ),
    );
  }

  //안내 다이얼로그
  void _showDialogDesc(String desc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'images/rassibs_img_infomation.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '안내',
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  desc,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestTheme04(String period) {
    _fetchPosts(
        TR.THEME04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'themeCode': _themeCode,
          'periodMonth': period,
        }));
  }

  void _requestTheme05(String type) {
    _fetchPosts(
        TR.THEME05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'themeCode': _themeCode,
          'selectDiv': type, //SHORT: 단기강세TOP3, TREND: 추세주도주
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(ThemeHotViewer.TAG, '$trStr $json');

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
      DLog.d(ThemeHotViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeHotViewer.TAG, response.body);

    if (trStr == TR.THEME04) {
      final TrTheme04 resData = TrTheme04.fromJson(jsonDecode(response.body));
      _theme04Item = const Theme04();
      if (resData.retCode == RT.SUCCESS) {
        DLog.d(ThemeHotViewer.TAG, resData.retData.themeObj.toString());

        _theme04Item = resData.retData;
        String themeStatus = _theme04Item.themeObj.themeStatus;

        if (themeStatus == 'BULL' || themeStatus == 'Bullish') {
          _isBearTheme = false;
        } else if (themeStatus == 'BEAR' || themeStatus == 'Bearish') {
          _isBearTheme = true;
        }
        _listThemeChart.clear();
        _listThemeChart.addAll(resData.retData.listChart);
        double maxTi = 0;
        double minTi = 0;
        resData.retData.listChart.asMap().forEach((index, element) {
          double price = double.parse(element.tradeIndex);
          if (index == 0) {
            maxTi = price;
            minTi = price;
            _highestThemeChartListIndex = 0;
            _lowestThemeChartListIndex = 0;
          }
          if (price > maxTi) {
            maxTi = price;
            _highestThemeChartListIndex = index;
          }
          if (price < minTi) {
            minTi = price;
            _lowestThemeChartListIndex = index;
          }
        });
        setState(() {});
      }
    }

    //현재 테마 주도주
    else if (trStr == TR.THEME05) {
      final TrTheme05 resData = TrTheme05.fromJson(jsonDecode(response.body));
      _leadingStockList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _leadingStockList.addAll(resData.retData.listStock);
        _selDiv = resData.retData.selectDiv;
      }
      setState(() {});
    }
    //테마주도주 히스토리
    else if (trStr == TR.THEME06) {
      final TrTheme06 resData = TrTheme06.fromJson(jsonDecode(response.body));
      _tcList.clear();
      _thList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _tcList.addAll(resData.retData.listCard);
        _thList.addAll(resData.retData.listTimeline);
      }
      setState(() {});
    }
  }
}
