import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue04.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_calendar_page.dart';
import 'package:rassi_assist/ui/market/issue_detail_stock_signal_page.dart';
import 'package:rassi_assist/ui/tiles/tile_related_stock.dart';
import 'package:rassi_assist/ui/web/inapp_webview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/none_tr/chart_data.dart';

/// 2024.07
/// 이슈 상세보기 (with 마켓뷰 개편)
class IssueNewViewer extends StatefulWidget {
  static const routeName = '/page_issue_calendar';
  static const String TAG = "[IssueCalendarPage] ";
  static const String TAG_NAME = '이슈상세보기';

  const IssueNewViewer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IssueNewViewerState();
}

class IssueNewViewerState extends State<IssueNewViewer> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _newsSn = '';
  String _issueSn = '';
  Issue04 _issue04 = Issue04();
  int _stkListPageNum = 2;

  final ScrollController _scrollController = ScrollController();
  late TrackballBehavior _trackballBehavior;

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
        int index = trackballDetails.groupingModeInfo?.currentPointIndices.first ?? 0;
        IssueTrend? itemIssueTrend;
        if (_issue04.listIssueTrend.isNotEmpty &&
            index < _issue04.listIssueTrend.length &&
            _issue04.listIssueTrend[index].searchTrend.isNotEmpty) {
          itemIssueTrend = _issue04.listIssueTrend[index];
        }
        ChartData? topStock0;
        if (_issue04.listTopStock.isNotEmpty &&
            _issue04.listTopStock.first.listChart.isNotEmpty &&
            index < _issue04.listTopStock.first.listChart.length &&
            _issue04.listTopStock.first.listChart[index].fr.isNotEmpty) {
          topStock0 = _issue04.listTopStock.first.listChart[index];
        }
        ChartData? topStock1;
        if (_issue04.listTopStock.length > 1 &&
            _issue04.listTopStock[1].listChart.isNotEmpty &&
            index < _issue04.listTopStock[1].listChart.length &&
            _issue04.listTopStock[1].listChart[index].fr.isNotEmpty) {
          topStock1 = _issue04.listTopStock[1].listChart[index];
        }
        ChartData? topStock2;
        if (_issue04.listTopStock.length == 3 &&
            _issue04.listTopStock[2].listChart.isNotEmpty &&
            index < _issue04.listTopStock[2].listChart.length &&
            _issue04.listTopStock[2].listChart[index].fr.isNotEmpty) {
          topStock2 = _issue04.listTopStock[2].listChart[index];
        }
        return Container(
          padding: const EdgeInsets.all(10),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      itemIssueTrend == null
                          ? topStock0 == null
                              ? topStock1 == null
                                  ? topStock2 == null
                                      ? ''
                                      : TStyle.getDateSlashFormat1(topStock2.tradeDate)
                                  : TStyle.getDateSlashFormat1(topStock1.tradeDate)
                              : TStyle.getDateSlashFormat1(topStock0.tradeDate)
                          : TStyle.getDateSlashFormat1(itemIssueTrend.issueDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ],
                ),
                if (itemIssueTrend != null)
                  Row(
                    children: [
                      Text(
                        '${_issue04.issueInfo.keyword} 검색추이',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        ' : ${TStyle.getMoneyPoint(itemIssueTrend.searchTrend)}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (topStock0 != null)
                  Row(
                    children: [
                      Text(
                        '${_issue04.listTopStock.first.sn} 등락률',
                        style: const TextStyle(
                          fontSize: 13,
                          color: RColor.chartGreen,
                        ),
                      ),
                      Text(
                        ' : ${TStyle.getPercentString(topStock0.fr)}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (topStock1 != null)
                  Row(
                    children: [
                      Text(
                        '${_issue04.listTopStock[1].sn} 등락률',
                        style: const TextStyle(
                          fontSize: 13,
                          color: RColor.chartYellow,
                        ),
                      ),
                      Text(
                        ' : ${TStyle.getPercentString(topStock1.fr)}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (topStock2 != null)
                  Row(
                    children: [
                      Text(
                        '${_issue04.listTopStock.last.sn} 등락률',
                        style: const TextStyle(
                          fontSize: 13,
                          color: RColor.chartPurple,
                        ),
                      ),
                      Text(
                        ' : ${TStyle.getPercentString(topStock2.fr)}',
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
      IssueNewViewer.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        DLog.d(IssueNewViewer.TAG, "delayed user id : $_userId");
        args = ModalRoute.of(context)!.settings.arguments as PgData;
        if (_newsSn.isEmpty) {
          _newsSn = args.pgSn;
          _issueSn = args.pgData;
        }
        if (_userId != '') {
          _fetchPosts(
              TR.ISSUE04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'newsSn': _newsSn,
                'issueSn': _issueSn,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.simpleWithExit(
        context,
        '${_issue04.issueInfo.keyword} 이슈 상세보기',
        Colors.black,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              _setRecentIssue,
              const SizedBox(height: 15),
              _setCalendarBanner,
              const SizedBox(height: 15),
              _setChart,
              const SizedBox(height: 15),
              _setRelatedStocks,
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // 최근 발생 이슈
  Widget get _setRecentIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가장 최근 발생된 이슈',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: UIStyle.boxWithOpacity16(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TStyle.getDateSlashFormat2(_issue04.issueInfo.issueDttm),
                      style: TStyle.textGrey14S,
                    ),
                    _issue04.issueInfo.issueDttm.isNotEmpty &&
                            _issue04.issueInfo.issueDttm.substring(0, 6) == TStyle.getYearMonthString()
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: UIStyle.boxRoundFullColor6c(RColor.mainColor),
                            child: const Text(
                              '오늘의 이슈',
                              style: TStyle.btnTextWht12,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _issue04.issueInfo.title,
                  style: TStyle.content16T,
                ),
                const SizedBox(height: 15),
                Html(
                  data: _issue04.issueInfo.content,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0),
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      lineHeight: LineHeight.percent(125),
                    ),
                    "a": Style(
                        //display: Display.none,
                        ),
                  },
                  onLinkTap: (url, attributes, element) {
                    Navigator.push(
                        context,
                        CustomNvRouteClass.createRouteSlow1(
                          InappWebviewPage(title: '', url: url!),
                        ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이슈 캘린더(히스토리) 연결 배너
  Widget get _setCalendarBanner {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (_issueSn.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IssueCalendarPage(),
              settings: RouteSettings(
                arguments: PgData(
                  pgData: _issueSn,
                  data: _issue04.issueInfo.keyword,
                ),
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: AppGlobal().isTablet ? 120 : 100,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xff353b6e),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(1, 1), //changes position of shadow
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_issue04.issueInfo.keyword}의 이슈 캘린더',
                    style: TStyle.btnTextWht16,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '해당 이슈의 히스토리를 확인해 보세요!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'images/icon_calendar1.png',
                width: 90,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _setChart {
    if (_issue04.listIssueTrend.isEmpty && _issue04.listTopStock.isEmpty) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이슈 검색추이 및 연관 종목 등락률',
              style: TStyle.defaultTitle,
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: double.infinity,
              height: 250,
              //color: Colors.green.withOpacity(0.3),
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                enableMultiSelection: false,
                margin: EdgeInsets.zero,
                primaryXAxis: CategoryAxis(
                    axisBorderType: AxisBorderType.withoutTopAndBottom,
                    plotOffset: 0,
                    axisLine: const AxisLine(
                      width: 1,
                      color: Colors.black,
                    ),
                    majorGridLines: const MajorGridLines(
                      width: 0,
                    ),
                    labelPlacement: LabelPlacement.onTicks,
                    majorTickLines: const MajorTickLines(
                      width: 1,
                      color: Colors.black,
                    ),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    axisLabelFormatter: (axisLabelRenderArgs) {
                      return ChartAxisLabel(
                        TStyle.getDateDivFormat(axisLabelRenderArgs.text),
                        const TextStyle(
                          fontSize: 10,
                          color: RColor.greyBasic_8c8c8c,
                        ),
                      );
                    }),
                primaryYAxis: NumericAxis(
                  rangePadding: ChartRangePadding.additional,
                  opposedPosition: true,
                  desiredIntervals: 10,
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
                      TStyle.getMoneyPoint(axisLabelRenderArgs.value.toStringAsFixed(2)),
                      const TextStyle(
                        fontSize: 10,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    );
                  },
                ),
                trackballBehavior: _trackballBehavior,
                selectionType: SelectionType.point,
                onMarkerRender: (markerArgs) {
                  markerArgs.markerWidth = 6;
                  markerArgs.markerHeight = 6;
                  if (markerArgs.seriesIndex == 0 &&
                      _issue04.listTopStock.isNotEmpty &&
                      (markerArgs.pointIndex == 0 ||
                          markerArgs.pointIndex == _issue04.listTopStock.first.listChart.length - 1)) {
                    markerArgs.color = RColor.chartGreen;
                  } else if (markerArgs.seriesIndex == 1 &&
                      _issue04.listTopStock.length > 1 &&
                      (markerArgs.pointIndex == 0 ||
                          markerArgs.pointIndex == _issue04.listTopStock[1].listChart.length - 1)) {
                    markerArgs.color = RColor.chartYellow;
                  } else if (markerArgs.seriesIndex == 2 &&
                      _issue04.listTopStock.length == 3 &&
                      (markerArgs.pointIndex == 0 ||
                          markerArgs.pointIndex == _issue04.listTopStock.last.listChart.length - 1)) {
                    markerArgs.color = RColor.chartPurple;
                  } else if (markerArgs.seriesIndex == 3 &&
                      (markerArgs.pointIndex == 0 || markerArgs.pointIndex == _issue04.listIssueTrend.length - 1)) {
                    markerArgs.color = Colors.red;
                  } else {
                    markerArgs.markerWidth = 0;
                    markerArgs.markerHeight = 0;
                  }
                },
                axes: [
                  NumericAxis(
                    name: 'yaxis1',
                    rangePadding: ChartRangePadding.additional,
                    plotOffset: 0,
                    desiredIntervals: 10,
                    axisLine: const AxisLine(
                      width: 0,
                    ),
                    majorGridLines: const MajorGridLines(
                      width: 0,
                    ),
                    majorTickLines: const MajorTickLines(
                      width: 0,
                    ),
                    axisLabelFormatter: (axisLabelRenderArgs) {
                      return ChartAxisLabel(
                        TStyle.getMoneyPoint(axisLabelRenderArgs.value.toStringAsFixed(2)),
                        const TextStyle(
                          fontSize: 10,
                          color: RColor.greyBasic_8c8c8c,
                        ),
                      );
                    },
                  ),
                ],
                series: [
                  if (_issue04.listTopStock.isNotEmpty && _issue04.listTopStock.first.listChart.isNotEmpty)
                    LineSeries<ChartData, String>(
                      dataSource: _issue04.listTopStock.first.listChart,
                      xValueMapper: (item, index) => item.tradeDate,
                      yValueMapper: (item, index) => double.tryParse(item.fr),
                      yAxisName: 'yaxis1',
                      color: RColor.chartGreen,
                      width: 1.2,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        color: RColor.grey_abb0bb,
                        width: 0,
                        height: 0,
                        borderWidth: 0,
                        shape: DataMarkerType.circle,
                      ),
                      animationDuration: 1500,
                    ),
                  if (_issue04.listTopStock.length > 1 && _issue04.listTopStock[1].listChart.isNotEmpty)
                    LineSeries<ChartData, String>(
                      dataSource: _issue04.listTopStock[1].listChart,
                      xValueMapper: (item, index) => item.tradeDate,
                      yValueMapper: (item, index) => double.tryParse(item.fr),
                      yAxisName: 'yaxis1',
                      color: RColor.chartYellow,
                      width: 1.2,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        color: RColor.grey_abb0bb,
                        width: 0,
                        height: 0,
                        borderWidth: 0,
                        shape: DataMarkerType.circle,
                      ),
                      animationDuration: 1500,
                    ),
                  if (_issue04.listTopStock.length == 3 && _issue04.listTopStock[2].listChart.isNotEmpty)
                    LineSeries<ChartData, String>(
                      dataSource: _issue04.listTopStock[2].listChart,
                      xValueMapper: (item, index) => item.tradeDate,
                      yValueMapper: (item, index) => double.tryParse(item.fr),
                      yAxisName: 'yaxis1',
                      color: RColor.chartPurple,
                      width: 1.2,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        color: RColor.grey_abb0bb,
                        width: 0,
                        height: 0,
                        borderWidth: 0,
                        shape: DataMarkerType.circle,
                      ),
                      animationDuration: 1500,
                    ),
                  if (_issue04.listIssueTrend.isNotEmpty)
                    LineSeries<IssueTrend, String>(
                      dataSource: _issue04.listIssueTrend,
                      xValueMapper: (item, index) => item.issueDate,
                      yValueMapper: (item, index) => double.tryParse(item.searchTrend),
                      color: Colors.red,
                      width: 1.8,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        color: RColor.grey_abb0bb,
                        width: 0,
                        height: 0,
                        borderWidth: 0,
                        shape: DataMarkerType.circle,
                      ),
                      animationDuration: 1500,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: Center(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    width: 10,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      if (_issue04.listIssueTrend.isEmpty) {
                        return const SizedBox();
                      } else {
                        return _setChartCircleInfo(color: Colors.red, name: _issue04.issueInfo.keyword);
                      }
                    } else if (index == 1) {
                      if (_issue04.listTopStock.isNotEmpty && _issue04.listTopStock.first.listChart.isNotEmpty) {
                        return _setChartCircleInfo(color: RColor.chartGreen, name: _issue04.listTopStock.first.sn);
                      } else {
                        return const SizedBox();
                      }
                    } else if (index == 2) {
                      if (_issue04.listTopStock.length > 1 && _issue04.listTopStock[1].listChart.isNotEmpty) {
                        return _setChartCircleInfo(color: RColor.chartYellow, name: _issue04.listTopStock[1].sn);
                      } else {
                        return const SizedBox();
                      }
                    } else if (index == 3) {
                      if (_issue04.listTopStock.length == 3 && _issue04.listTopStock.last.listChart.isNotEmpty) {
                        return _setChartCircleInfo(color: RColor.chartPurple, name: _issue04.listTopStock.last.sn);
                      } else {
                        return const SizedBox();
                      }
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _setChartCircleInfo({required Color color, required String name}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          '  $name',
          style: const TextStyle(
            fontSize: 11,
            color: RColor.new_basic_text_color_grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 관련 종목
  Widget get _setRelatedStocks {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '관련 종목들',
                style: TStyle.defaultTitle,
              ),
              Text(
                '(총 ${_issue04.stkList.length}종목)',
                style: TStyle.textGrey14S,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser()) {
              Navigator.pushNamed(
                context,
                IssueDetailStockSignalPage.routeName,
                arguments: PgNews(
                  tagName: _issue04.issueInfo.keyword,
                  newsSn: _newsSn,
                  issueSn: _issueSn,
                ),
              );
            } else {
              String result = await CommonPopup.instance.showDialogPremium(context);
              if (result == CustomNvRouteResult.landPremiumPage) {
                basePageState.navigateAndGetResultPayPremiumPage();
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              //vertical: 10,
            ),
            decoration: UIStyle.boxRoundFullColor6c(
              RColor.greyBox_f5f5f5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    '${_issue04.issueInfo.keyword} 관련 종목의 AI매매신호 한번에 보기',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 1,
                  ),
                ),
                const ImageIcon(
                  AssetImage('images/main_my_icon_arrow.png'),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              _issue04.stkList.length ~/ (10 * _stkListPageNum) > 0 ? 10 * _stkListPageNum : _issue04.stkList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return TileRelatedStock(_issue04.stkList[index]);
          },
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: _issue04.stkList.length ~/ (10 * _stkListPageNum) > 0,
          child: InkWell(
            onTap: () {
              setState(() {
                _stkListPageNum++;
              });
            },
            child: Center(
              child: Container(
                //width: 10,
                width: 150,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: UIStyle.boxRoundLine20(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "+관련 종목",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      " 더보기",
                      style: TStyle.puplePlainStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> synchronizeLists() async {
    /* List<List<ChartData>> chartDataLists = _issue04.listTopStock
        .where((topStock) => topStock.listChart.isNotEmpty)
        .map((topStock) => topStock.listChart)
        .toList();*/
    // 모든 날짜를 포함하는 Set을 생성합니다.
    Set<String> allDates = {
      //..._issue04.listIssueTrend.map((item) => item.issueDate),
      for (var stock in _issue04.listTopStock) ...stock.listChart.map((chart) => chart.tradeDate)
    };

    // 날짜 순서대로 정렬합니다.
    List<String> sortedDates = allDates.toList()..sort();

    // 각 리스트에 누락된 날짜를 채웁니다.
    _issue04.listIssueTrend = _fillMissingDatesInIssueTrend(sortedDates);
    if (_issue04.listTopStock.isNotEmpty && _issue04.listTopStock.first.listChart.isNotEmpty) {
      _issue04.listTopStock.first.listChart =
          _fillMissingDatesInChartData(_issue04.listTopStock.first.listChart, sortedDates);
    }
    if (_issue04.listTopStock.length > 1 && _issue04.listTopStock[1].listChart.isNotEmpty) {
      _issue04.listTopStock[1].listChart =
          _fillMissingDatesInChartData(_issue04.listTopStock[1].listChart, sortedDates);
    }
    if (_issue04.listTopStock.length == 3 && _issue04.listTopStock[2].listChart.isNotEmpty) {
      _issue04.listTopStock[2].listChart =
          _fillMissingDatesInChartData(_issue04.listTopStock[2].listChart, sortedDates);
    }

    // 검색추이 리스트에서 종목 리스트에 없는 날짜를 제거합니다.
    _issue04.listIssueTrend.removeWhere((item) => !sortedDates.contains(item.issueDate));
  }

  List<IssueTrend> _fillMissingDatesInIssueTrend(List<String> sortedDates) {
    Map<String, IssueTrend> dateToIssueTrend = {for (var item in _issue04.listIssueTrend) item.issueDate: item};
    return sortedDates.map((date) {
      return dateToIssueTrend[date] ??
          IssueTrend(
            issueDate: date,
            issueSn: '',
            keyword: '',
            searchTrend: '',
          ); // 누락된 날짜에 대한 IssueTrend 객체 생성
    }).toList();
  }

  List<ChartData> _fillMissingDatesInChartData(List<ChartData> list, List<String> sortedDates) {
    Map<String, ChartData> dateToChartData = {for (var item in list) item.tradeDate: item};
    return sortedDates.map((date) {
      return dateToChartData[date] ??
          ChartData(
            tradeDate: date,
            fr: '',
            vDateTime: DateTime.now(),
            flag: '',
            tradePrc: '',
          ); // 누락된 날짜에 대한 ChartData 객체 생성
    }).toList();
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueNewViewer.TAG, '$trStr $json');

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
      DLog.d(IssueNewViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueNewViewer.TAG, response.body);

    if (trStr == TR.ISSUE04) {
      final TrIssue04 resData = TrIssue04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _issue04 = resData.retData;
        _newsSn = _issue04.issueInfo.newsSn;
        _issueSn = _issue04.issueInfo.issueSn;
        if (_issue04.listIssueTrend.isNotEmpty && _issue04.listTopStock.isNotEmpty) {
          await synchronizeLists();
        }
      } else {
        _issue04 = Issue04();
      }
      setState(() {});
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void changeIssue(vNewsSn) {
    setState(() {
      _newsSn = vNewsSn;
      _issueSn = '';
    });

    _fetchPosts(
        TR.ISSUE04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'newsSn': _newsSn,
        }));
  }
}
