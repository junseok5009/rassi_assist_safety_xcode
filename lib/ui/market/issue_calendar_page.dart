import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue02n.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue05.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

/// 2024.07
/// 이슈 캘린더 이슈 히스토리
class IssueCalendarPage extends StatefulWidget {
  static const routeName = '/page_issue_calendar';
  static const String TAG = "[IssueCalendarPage] ";
  static const String TAG_NAME = '이슈캘린더';

  const IssueCalendarPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IssueCalendarState();
}

class IssueCalendarState extends State<IssueCalendarPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _issueSn = '';
  String _keyword = '';
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  String _focusedYearMonth = '';

  late DateTime _firstDay;
  late DateTime _lastDay;
  late Map<DateTime, List<IssueDaily>> eventSource;
  late LinkedHashMap<DateTime, List<IssueDaily>> mapIssueEvent;

  final List<Issue05> _issueList = [];
  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';

  String _strMonth = '';
  String _strIssDays = '0';
  String _strRiseDays = '0';
  String _strFallDays = '0';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(IssueCalendarPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _lastDay = _focusedDay.lastDayOfMonth();
    // DLog.d(IssueCalendarPage.TAG, _lastDay.toString());
    _firstDay = DateTime(_lastDay.year - 10, _lastDay.month, 1);

    // DLog.d(IssueCalendarPage.TAG, _firstDay.toString());
    _strMonth = _focusedDay.month.toString();

    eventSource = {};
    _updateCalendar();

    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        args = ModalRoute.of(context)!.settings.arguments as PgData;
        _issueSn = args.pgData;
        _keyword = args.data;

        if (_userId != '') {
          _focusedYearMonth = TStyle.getYearMonthString();

          _fetchPosts(
              TR.ISSUE02,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueMonth': _focusedYearMonth,
                'selectDiv': 'NEW',
                'issueSn': _issueSn,
              }));

          _fetchPosts(
              TR.ISSUE05,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueSn': _issueSn,
                'issueMonth': _focusedYearMonth,
                'pageNo': pageNum.toString(),
                'pageItemSize': '10',
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

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      _requestIssue05(_focusedYearMonth);
    } else {}
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            _setSubTitle('$_keyword 이슈 캘린더'),
            _setMonthlySummary(),
            _setIssueCalendar(),
            const SizedBox(height: 25),
            // _setSubTitle('이슈 히스토리'),
            // const SizedBox(height: 15),

            _issueList.isNotEmpty
                ? ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _issueList.length,
                    itemBuilder: (context, index) {
                      return _setIssueItem(_issueList[index]);
                    },
                  )
                : const Center(
              child: Text('발생된 이슈 히스토리가 없습니다.', style: TStyle.defaultContent,),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _setMonthlySummary() {
    return Visibility(
      visible: true,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              height: 1.3,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xff111111),
            ),
            children: [
              TextSpan(text: '$_strMonth월에는 '),
              TextSpan(
                text: _strIssDays,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: '번의 이슈가 발생하였으며, $_strRiseDays번 상승, $_strFallDays번 하락을 했습니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  //이슈 캘린더
  Widget _setIssueCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TableCalendar(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        locale: 'ko-KR',
        calendarFormat: _calendarFormat,
        availableGestures: AvailableGestures.horizontalSwipe,
        daysOfWeekHeight: 20,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            return Container();
          },
          defaultBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return _setIssueDays(events, '${day.day}');
          },
          todayBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return _setIssueDays(events, '${day.day}');
          },
        ),
        eventLoader: (day) {
          return _getEventsForDay(day);
        },
        onPageChanged: (focusedDay) async {
          DLog.d(IssueCalendarPage.TAG, 'Calendar page focusedDay: $focusedDay');

          if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser()) {
            _focusedDay = focusedDay;
            DLog.d(IssueCalendarPage.TAG, 'Calendar page changed to ${focusedDay.month}/${focusedDay.year}');
            _strMonth = focusedDay.month.toString();
            // DLog.d(IssueCalendarPage.TAG, 'Loading events for ${forcusedCal.month}/${forcusedCal.year}');
            _focusedYearMonth = focusedDay.year.toString() + focusedDay.month.toString().padLeft(2, '0');
            DLog.d(IssueCalendarPage.TAG, _focusedYearMonth);

            if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser()) {
              _requestData(_focusedYearMonth);
            }
          } else {
            setState(() {
              _focusedDay = DateTime.now();
            });
            String result = await CommonPopup.instance.showDialogPremium(context);
            if (result == CustomNvRouteResult.landPremiumPage) {
              basePageState.navigateAndGetResultPayPremiumPage();
            }
          }

        },
      ),
    );
  }

  void _loadEventsForMonth(DateTime datetime) async {
    _strMonth = datetime.month.toString();
    // DLog.d(IssueCalendarPage.TAG, 'Loading events for ${forcusedCal.month}/${forcusedCal.year}');
    _focusedYearMonth = datetime.year.toString() + datetime.month.toString().padLeft(2, '0');
    DLog.d(IssueCalendarPage.TAG, _focusedYearMonth);
    _requestData(_focusedYearMonth);
  }

  Widget _setIssueDays(List<IssueDaily> events, String day) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: events.isNotEmpty
          ? BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.blue.withOpacity(0.2),
              color: _getEventColor(events.first),
            )
          : null,
      child: Text(
        day,
        style: TextStyle(
          color: events.isNotEmpty ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Color _getEventColor(IssueDaily item) {
    Color infoColor = Colors.grey;
    if (item.avgFluctRate.contains('-')) {
      infoColor = RColor.sigSell;
    } else if (item.avgFluctRate == '0.00' || item.avgFluctRate.isEmpty) {
      infoColor = Colors.grey;
    } else {
      infoColor = RColor.sigBuy;
    }

    return infoColor;
  }

  List<IssueDaily> _getEventsForDay(DateTime day) {
    return mapIssueEvent[day] ?? [];
  }

  void _updateCalendar() {
    mapIssueEvent = LinkedHashMap<DateTime, List<IssueDaily>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventSource);
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  // eventSource를 업데이트하고 events를 갱신하는 메서드
  void updateEventSource(Map<String, List<IssueDaily>> newEventSource) {
    Map<DateTime, List<IssueDaily>> convertedMap = {};
    newEventSource.forEach((key, value) {
      DateTime dateTime = DateTime.parse(key);
      convertedMap[dateTime] = value;
    });

    setState(() {
      eventSource.addAll(convertedMap); /* = convertedMap;*/
      _updateCalendar();
    });
  }

  String dateTimeToString(DateTime date) {
    return '${date.year}  ${date.month.toString().padLeft(2, '0')}  ${date.day}';
  }

  //이슈 관련 히스토리
  Widget _setIssueItem(Issue05 item) {
    String flucStr = '';
    Color flucColor = Colors.grey;
    if (item.avgFluctRate.contains('-')) {
      flucStr = '⬇ 하락';
      flucColor = RColor.sigSell;
    } else if (item.avgFluctRate == '0.00') {
      flucStr = '보합';
      flucColor = Colors.grey;
    } else {
      flucStr = '⬆ 상승';
      flucColor = RColor.sigBuy;
    }

    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxWithOpacity16(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TStyle.getDateSlashFormat2(item.issueDttm),
                  style: const TextStyle(
                    //메인 컬러 작은.
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 2, 7, 2),
                  decoration: BoxDecoration(
                    color: flucColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    flucStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: TStyle.content16T,
            ),
            const SizedBox(height: 10),
            Html(
              data: item.content,
              style: {
                "body": Style(
                  fontSize: FontSize(16.0),
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  lineHeight: LineHeight.percent(125),
                ),
                "a": Style(
                  color: RColor.mainColor,
                ),
              },
              onLinkTap: (url, attributes, element) {
                commonLaunchURL(url!);
              },
            ),
          ],
        ),
      ),
      onTap: () {
        // _showDialogIssue(item.title, item.content);
      },
    );
  }

  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  void _requestData(String yearMonth) {
    _issueList.clear();
    pageNum = 0;

    _fetchPosts(
        TR.ISSUE02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': yearMonth,
          'selectDiv': 'NEW',
          'issueSn': _issueSn,
        }));

    _fetchPosts(
        TR.ISSUE05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueSn': _issueSn,
          'issueMonth': yearMonth,
          'pageNo': pageNum.toString(),
          'pageItemSize': '10',
        }));
  }

  void _requestIssue05(String yearMonth) {
    _fetchPosts(
        TR.ISSUE05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueSn': _issueSn,
          'issueMonth': yearMonth,
          'pageNo': pageNum.toString(),
          'pageItemSize': '10',
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueCalendarPage.TAG, '$trStr $json');

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
      DLog.d(IssueCalendarPage.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueCalendarPage.TAG, response.body);

    if (trStr == TR.ISSUE02) {
      final TrIssue02n resData = TrIssue02n.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _strIssDays = resData.retData.issueDays;
        _strRiseDays = resData.retData.riseDays;
        _strFallDays = resData.retData.fallDays;

        List<IssueDaily>? tmpList = resData.retData.listDaily;
        Map<String, List<IssueDaily>> groupedIssues = {};
        if (tmpList.isNotEmpty) {
          for (IssueDaily tmp in tmpList) {
            if (groupedIssues.containsKey(tmp.issueDate)) {
              groupedIssues[tmp.issueDate]!.add(tmp);
            } else {
              groupedIssues[tmp.issueDate] = [tmp];
            }
          }
        }
        // groupedIssues.forEach((key, value) {
        //   DLog.d(IssueCalendarPage.TAG, '$key: ${value.map((f) => f.title).toList()}');
        // });

        updateEventSource(groupedIssues);
      } else {
        _strIssDays = '0';
        _strRiseDays = '0';
        _strFallDays = '0';
        setState(() {});
      }
    }
    //
    else if (trStr == TR.ISSUE05) {
      final TrIssue05 resData = TrIssue05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Issue05>? tmpList = resData.listData;
        _issueList.addAll(tmpList as Iterable<Issue05>);
        // _issueList.addAll(resData.listData as Iterable<Issue05>);

        setState(() {});
      }
    }
  }
}
