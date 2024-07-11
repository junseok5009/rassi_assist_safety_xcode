import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue05.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

/// 2024.07
/// 이슈 캘린더 이슈 히스토리
class IssueCalendarPage extends StatefulWidget {
  static const routeName = '/page_issue_calendar';
  static const String TAG = "[IssueCalendarPage] ";
  static const String TAG_NAME = '';

  const IssueCalendarPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IssueCalendarState();
}

class IssueCalendarState extends State<IssueCalendarPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _issueSn = '';
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<Issue05>> eventSource;
  late LinkedHashMap<DateTime, List<Issue05>> mapIssueEvent;

  final List<Issue05> _issueList = [];
  int pageNum = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      IssueCalendarPage.TAG_NAME,
    );

    eventSource = {};
    _updateCalendar();

    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        args = ModalRoute.of(context)!.settings.arguments as PgData;
        _issueSn = args.pgData;
        // if (_themeCode.isEmpty) {
        //   Navigator.pop(context);
        // }
        if (_userId != '') {
          _fetchPosts(
              TR.ISSUE05,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueSn': _issueSn,
                'pageNo': '0',
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
          children: [
            _setSubTitle('이슈 캘린더'),
            _setIssueCalendar(),
            const SizedBox(height: 25),
            _setSubTitle('이슈 히스토리'),
            const SizedBox(height: 15),
            ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: _issueList.length,
              itemBuilder: (context, index) {
                return _setIssueItem(_issueList[index]);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //이슈 캘린더
  Widget _setIssueCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 4, 16),
        lastDay: DateTime.utc(2024, 8, 31),
        focusedDay: DateTime.now(),
        locale: 'ko-KR',
        calendarFormat: _calendarFormat,
        availableGestures: AvailableGestures.horizontalSwipe,
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
                '${day.day}',
                style: TextStyle(
                  color: events.isNotEmpty ? Colors.white : Colors.black,
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
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
                '${day.day}',
                style: TextStyle(
                  color: events.isNotEmpty ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
        eventLoader: (day) {
          return _getEventsForDay(day);
        },
      ),
    );
  }

  Color _getEventColor(Issue05 item) {
    Color infoColor = Colors.grey;
    if (item.avgFluctRate.contains('-')) {
      infoColor = RColor.sigSell;
    } else if (item.avgFluctRate == '0.00') {
      infoColor = Colors.grey;
    } else {
      infoColor = RColor.sigBuy;
    }

    return infoColor;
  }

  List<Issue05> _getEventsForDay(DateTime day) {
    return mapIssueEvent[day] ?? [];
  }

  void _updateCalendar() {
    mapIssueEvent = LinkedHashMap<DateTime, List<Issue05>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventSource);
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  // eventSource를 업데이트하고 events를 갱신하는 메서드
  void updateEventSource(Map<String, List<Issue05>> newEventSource) {
    Map<DateTime, List<Issue05>> convertedMap = {};
    newEventSource.forEach((key, value) {
      DateTime dateTime = DateTime.parse(key);
      convertedMap[dateTime] = value;
    });

    setState(() {
      eventSource = convertedMap;
      _updateCalendar();
    });
  }

  //이슈 관련 히스토리
  Widget _setIssueItem(Issue05 item) {
    String flucStr = '';
    Color flucColor = Colors.grey;
    if (item.avgFluctRate.contains('-')) {
      flucStr = '하락';
      flucColor = RColor.sigSell;
    } else if (item.avgFluctRate == '0.00') {
      flucStr = '보합';
      flucColor = Colors.grey;
    } else {
      flucStr = '상승';
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
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
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

  void _requestIssue05(String type) {
    _fetchPosts(
        TR.ISSUE05,
        jsonEncode(<String, String>{
          'userId': _userId,
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

    if (trStr == TR.ISSUE05) {
      final TrIssue05 resData = TrIssue05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Issue05>? tmpList = resData.listData;
        _issueList.addAll(tmpList as Iterable<Issue05>);
        // _issueList.addAll(resData.listData as Iterable<Issue05>);

        Map<String, List<Issue05>> groupedIssues = groupBy(
          tmpList as Iterable<Issue05>,
          (item) => item.issueDttm.substring(0, 8),
        );

        // groupedIssues.forEach((key, value) {
        //   DLog.d(IssueCalendarPage.TAG, '$key: ${value.map((f) => f.title).toList()}');
        // });

        updateEventSource(groupedIssues);
      }
    }
  }

  Map<K, List<T>> groupBy<T, K>(Iterable<T> items, K Function(T) key) {
    return items.fold<Map<K, List<T>>>(
      {},
      (Map<K, List<T>> map, T element) {
        K keyValue = key(element);
        if (!map.containsKey(keyValue)) {
          map[keyValue] = [];
        }
        map[keyValue]!.add(element);
        return map;
      },
    );
  }
}

class CalendarEvent {
  String title;
  bool complete;
  String issueSn;
  String issueDttm;

  // String avgFluctRate;

  CalendarEvent(this.title, this.complete, this.issueSn, this.issueDttm);

  @override
  String toString() => title;
}
