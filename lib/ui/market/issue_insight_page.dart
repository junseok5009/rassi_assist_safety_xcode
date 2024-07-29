import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue10.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue11.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

/// 2024.07
/// 이슈 인사이트
class IssueInsightPage extends StatefulWidget {
  static const routeName = '/page_issue_insight';
  static const String TAG = "[IssueInsightPage] ";
  static const String TAG_NAME = '';

  const IssueInsightPage({super.key});

  @override
  State<StatefulWidget> createState() => IssueInsightState();
}

class IssueInsightState extends State<IssueInsightPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  final String yearMonth = TStyle.getYearMonthString();
  late DateTime _currentDate;
  String dateTitle = '';
  String _monthDesc = '';

  List<IssueGenMonth> _issMonthTopList = [];
  List<IssueTopDay> _issDayTopList = [];
  List<NewIssue> _newIssueList = [];
  List<IssueTrendCount> _listStackedColumn = [];
  List<KospiIndex> _listKospiData = [];
  List<KosdaqIndex> _listKosdaqData = [];

  String _trendTitle1 = '';
  String _trendTitle2 = '';
  String _trendContent1 = '';
  String _trendContent2 = '';
  String _upCountTrend = '';
  String _dnCountTrend = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(IssueInsightPage.TAG_NAME);

    _currentDate = DateTime.now();
    dateTitle = TStyle.getDateLongYmKorFormat(yearMonth);

    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        DLog.d(IssueInsightPage.TAG, "delayed user id : $_userId");
        // DLog.d(IssueInsightPage.TAG, "delayed subType : ${subType.name}");

        if (_userId != '') {
          _requestData(_getYearMonth(0));
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

  /// 다음달 +1, 이전달 -1
  String _getYearMonth(int index) {
    // if(_currentDate) ---> 마지막 이번달 체크 필요
    _currentDate = DateTime(_currentDate.year, _currentDate.month + index, 1);
    return DateFormat('yyyyMM').format(_currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.simpleWithExit(
        context,
        '이슈 인사이트',
        Colors.black,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              _setDateTitle,
              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
                child: Text(
                  _monthDesc,
                  style: TStyle.defaultContent,
                ),
              ),
              const SizedBox(height: 10),

              // 한달동안 많이 발섕한 이슈
              _setMonthTopIssue,
              const SizedBox(height: 10),
              _setMonthTopDesc,
              CommonView.setDivideLine,
              const SizedBox(height: 10),

              // 한달동안 이슈 트랜드
              _setMonthTrend,
              CommonView.setDivideLine,
              const SizedBox(height: 10),

              // 하루 동안 상승 랭킹
              _setDayTopIssue,
              const SizedBox(height: 25),

              // 새롭게 등장한 이슈
              _setNewIssueList,
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 2024년 7월
  Widget get _setDateTitle {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(),
          icon: Image.asset(
            'images/main_jm_aw_l_g.png',
            width: 18,
            height: 14,
          ),
          onPressed: () {
            _requestData(_getYearMonth(-1));
          },
        ),
        const SizedBox(width: 10),
        Text(
          dateTitle,
          style: TStyle.title22m,
        ),
        const SizedBox(width: 10),
        IconButton(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(),
          icon: Image.asset(
            'images/main_jm_aw_r_g.png',
            width: 18,
            height: 14,
          ),
          onPressed: () {
            _requestData(_getYearMonth(1));
          },
        ),
      ],
    );
  }

  // 한달동안 많이 발섕한 이슈
  Widget get _setMonthTopIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한달동안 가장 많이 발생했던 이슈는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('한달간 오늘의 이슈 등록 횟수가 가장 많았던 뜨거운 이슈를 살펴보세요'),
          const SizedBox(height: 15),

          //chart
          _setTreeMap,
          const SizedBox(height: 15),

          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _issMonthTopList.length > 10 ? 10 : _issMonthTopList.length,
            itemBuilder: (context, index) {
              return TileMonthTopIssue(_issMonthTopList[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget get _setMonthTopDesc {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: const [
            TextSpan(
              text: '① 입력하신 매수 가격에 맞춰 회원님만을 위한 매도 알고리즘이 설정됩니다.\n',
              style: TextStyle(
                fontSize: 13,
                color: RColor.greyMore_999999,
              ),
            ),
            TextSpan(
              text: '\n',
              style: TextStyle(
                fontSize: 5,
                color: RColor.greyMore_999999,
              ),
            ),
            TextSpan(
              text: '② 매수가는 ‘현재가 기준 +9%’이내 가격으로만 등록이 가능합니다.\n',
              style: TextStyle(
                fontSize: 13,
                color: RColor.greyMore_999999,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _setTreeMap {
    return SizedBox(
      width: double.infinity,
      height: 330,
      child: _issMonthTopList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SfTreemap(
              dataCount: _issMonthTopList.length > 23 ? 23 : _issMonthTopList.length,
              weightValueMapper: (int index) {
                return double.parse(_issMonthTopList[index].occurCount);
              },
              levels: <TreemapLevel>[
                TreemapLevel(
                  groupMapper: (int index) {
                    return _issMonthTopList[index].keyword;
                  },
                  labelBuilder: (BuildContext context, TreemapTile tile) {
                    return Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Text(
                        tile.group,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  tooltipBuilder: (BuildContext context, TreemapTile tile) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('''theme  : ${tile.group}\n횟수 : ${tile.weight}회''',
                          style: const TextStyle(color: Colors.black)),
                    );
                  },
                ),
              ],
            ),
    );
  }

  // 한달동안 이슈 트랜드
  Widget get _setMonthTrend {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한달동안의 이슈 트랜드는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('매월 1일부터 말일까지 발생된 이슈의 트랜드와 지수의 흐름도 함께 비교해 보세요'),
          const SizedBox(height: 15),

          //chart
          _setStackedColumn100,
          const SizedBox(height: 15),

          //상승/하락 이슈가 많았던 날
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    const Text(
                      '상승 이슈가\n많았던 날',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 73,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RColor.sigBuy,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_upCountTrend일',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: RColor.sigBuy,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    const Text(
                      '하락 이슈가\n많았던 날',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 73,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RColor.sigSell,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_dnCountTrend일',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: RColor.sigSell,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 25),

          Text(
            _trendTitle1,
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 10),
          Text(
            _trendContent1,
            style: TStyle.defaultContent,
          ),
          const SizedBox(height: 20),
          Text(
            _trendTitle2,
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 10),
          Text(
            _trendContent2,
            style: TStyle.defaultContent,
          ),
        ],
      ),
    );
  }

  Widget get _setStackedColumn100 {
    return SizedBox(
      height: 300,
      child: _listStackedColumn.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SfCartesianChart(
              margin: EdgeInsets.zero,
              // tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: CategoryAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  labelPlacement: LabelPlacement.onTicks,
                  interval: 1,
                  majorGridLines: const MajorGridLines(width: 0),
                  plotOffset: 10,
                  axisLabelFormatter: (axisLabelRenderArgs) {
                    return ChartAxisLabel(
                      TStyle.getDateDivFormat(axisLabelRenderArgs.text),
                      const TextStyle(
                        fontSize: 10,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    );
                  }),
              primaryYAxis: const NumericAxis(
                axisLine: AxisLine(width: 0),
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(color: Colors.transparent),
                isVisible: false,
              ),
              axes: const <ChartAxis>[
                NumericAxis(
                  name: 'KospiIndex',
                  opposedPosition: true,
                  interval: 50,
                  isVisible: false,
                ),
                NumericAxis(
                  name: 'KosdaqIndex',
                  opposedPosition: true,
                  interval: 50,
                  isVisible: false,
                ),
              ],
              series: <CartesianSeries>[
                StackedColumn100Series<IssueTrendCount, String>(
                  name: '상승이슈',
                  dataSource: _listStackedColumn,
                  xValueMapper: (IssueTrendCount data, _) => data.issueDate,
                  yValueMapper: (IssueTrendCount data, _) => double.parse(data.upCount),
                  color: RColor.bubbleChartRed,
                ),
                StackedColumn100Series<IssueTrendCount, String>(
                  name: '하락이슈',
                  dataSource: _listStackedColumn,
                  xValueMapper: (IssueTrendCount data, _) => data.issueDate,
                  yValueMapper: (IssueTrendCount data, _) => double.parse(data.downCount),
                  color: RColor.bubbleChartBlue,
                ),
                LineSeries<KospiIndex, String>(
                  name: '코스피',
                  dataSource: _listKospiData,
                  xValueMapper: (KospiIndex data, _) => data.tradeDate,
                  yValueMapper: (KospiIndex data, _) => double.parse(data.priceIndex),
                  color: RColor.chartTradePriceColor,
                  width: 1.2,
                  markerSettings: const MarkerSettings(isVisible: false),
                  yAxisName: 'KospiIndex',
                ),
                LineSeries<KosdaqIndex, String>(
                  name: '코스닥',
                  dataSource: _listKosdaqData,
                  xValueMapper: (KosdaqIndex data, _) => data.tradeDate,
                  yValueMapper: (KosdaqIndex data, _) => double.parse(data.priceIndex),
                  color: Colors.green,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: false),
                  yAxisName: 'KosdaqIndex',
                ),
              ],
              legend: const Legend(isVisible: true),
            ),
    );
  }

  // 하루에 크게 상승한 이슈
  Widget get _setDayTopIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이슈로 선정되고 하루 동안 크게 상승했던 이슈는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('이슈가 발생된 하루 동안 가장 상승폭이 컷던 이슈를 살펴 보세요.'),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _issDayTopList.length > 10 ? 10 : _issDayTopList.length,
            itemBuilder: (context, index) {
              return TileDayTopIssue(_issDayTopList[index]);
            },
          ),
        ],
      ),
    );
  }

  // 한달간 가장 많이 상승한 이슈는? => TODO 개발중???

  // 새롭게 등장한 이슈
  Widget get _setNewIssueList {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새롭게 등장한 이슈',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _newIssueList.length,
            itemBuilder: (context, index) {
              return TileNewIssue(_newIssueList[index]);
            },
          ),
        ],
      ),
    );
  }

  void _requestData(String sYearMonth) {
    dateTitle = TStyle.getDateLongYmKorFormat(sYearMonth);
    _monthDesc = '';
    _issMonthTopList.clear();
    _issDayTopList.clear();
    _newIssueList.clear();
    _listStackedColumn.clear();
    _listKospiData.clear();
    _listKosdaqData.clear();

    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
          'menuDiv': IssueDivType.OCCUR.name,
        }));

    //트랜드
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
          'menuDiv': IssueDivType.TREND.name,
        }));

    //일별 상승 랭킹
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
          'menuDiv': IssueDivType.UPDAY.name,
          'pageNo': '0',
          'pageItemSize': '10',
        }));

    //월별 상승 랭킹
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
          'menuDiv': IssueDivType.UPMON.name,
        }));

    //월별 신규 등록된 이슈
    _fetchPosts(
        TR.ISSUE10,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueInsightPage.TAG, '$trStr $json');

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
      DLog.d(IssueInsightPage.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueInsightPage.TAG, response.body);

    if (trStr == TR.ISSUE11) {
      final TrIssue11 resData = TrIssue11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue11 item = resData.retData;
        // DLog.d(IssueInsightPage.TAG, item.menuDiv);

        if (item.menuDiv == IssueDivType.OCCUR.name) {
          _monthDesc = item.content1;
          _issMonthTopList = item.listGenMonth;
        }
        if (item.menuDiv == IssueDivType.TREND.name) {
          _trendTitle1 = item.title1;
          _trendTitle2 = item.title2;
          _trendContent1 = item.content1;
          _trendContent2 = item.content2;
          _upCountTrend = item.upMaxDate;
          _dnCountTrend = item.dnMaxDate;
          _listStackedColumn = item.listIssueCount;
          _listKospiData = item.listKospiIndex;
          _listKosdaqData = item.listKosdaqIndex;
          // for (IssueTrendCount tt in _listStackedColumn) {
          //   DLog.w(tt.toString());
          // }
        }
        if (item.menuDiv == IssueDivType.UPDAY.name) {
          _issDayTopList = item.listDayTop;
        }

        setState(() {});
      }
    }
    //
    else if (trStr == TR.ISSUE10) {
      final TrIssue10 resData = TrIssue10.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue10? item = resData.retData;
        if (item != null) {
          _newIssueList = item.issueList;

          setState(() {});
        }
      }
    }
  }
}
