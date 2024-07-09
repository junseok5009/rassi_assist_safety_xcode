import 'dart:async';
import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
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
import 'package:rassi_assist/models/tr_issue/tr_issue05.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme04.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme05.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme06.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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

  final List<Issue05> _issueList = [];
  int pageNum = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      IssueCalendarPage.TAG_NAME,
    );
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
        // focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableGestures: AvailableGestures.horizontalSwipe,

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        // selectedDayPredicate: (day) {
        //   // Use `selectedDayPredicate` to determine which day is currently selected.
        //   // If this returns true, then `day` will be marked as selected.
        //
        //   // Using `isSameDay` is recommended to disregard
        //   // the time-part of compared DateTime objects.
        //   return isSameDay(_selectedDay, day);
        // },
        onDaySelected: (selectedDay, focusedDay) {
          // if (!isSameDay(_selectedDay, selectedDay)) {
          //   // Call `setState()` when updating the selected day
          //   setState(() {
          //     _selectedDay = selectedDay;
          //     _focusedDay = focusedDay;
          //   });
          // }
        },
        onFormatChanged: (format) {
          // if (_calendarFormat != format) {
          //   // Call `setState()` when updating calendar format
          //   setState(() {
          //     _calendarFormat = format;
          //   });
          // }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          // _focusedDay = focusedDay;
        },
      ),
    );
  }

  //이슈 관련 히스토리
  Widget _setIssueItem(Issue05 item) {
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
          // 'themeCode': _themeCode,
          'selectDiv': type, //SHORT: 단기강세TOP3, TREND: 추세주도주
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
        _issueList.addAll(resData.listData as Iterable<Issue05>);
        setState(() {});
      }
    }
  }
}
