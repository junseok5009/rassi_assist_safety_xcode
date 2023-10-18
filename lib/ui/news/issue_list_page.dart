import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_issue02.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_date_picker.dart';
import '../common/common_popup.dart';

/// 2021.02.22
/// 날짜별 이슈 모두보기
class IssueListPage extends StatefulWidget {
  static const routeName = '/page_issue_list';
  static const String TAG = "[IssueListPage]";
  static const String TAG_NAME = '날짜별_이슈현황';

  const IssueListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IssueListPageState();
}

class IssueListPageState extends State<IssueListPage> {
  late SharedPreferences _prefs;
  String _userId = "";

  final List<IssueList> _dataList = [];
  DateTime _dateTime = DateTime.now();
  final _dateFormat = DateFormat('yyyyMM');

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: IssueListPage.TAG_NAME,
      screenClassOverride: IssueListPage.TAG_NAME,
    );

    _loadPrefData().then((value) {
      _requestData();
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  void _requestData() {
    _fetchPosts(
      TR.ISSUE02,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'issueMonth': _dateFormat.format(_dateTime),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.basic(context, '날짜별 이슈 현황'),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topRight,
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: CommonView.setDatePickerBtnView(
                  getDateYmFormat(
                    _dateFormat.format(_dateTime),
                  ),
                  () async {
                    await CommonDatePicker.showYearMonthPicker(
                            context, _dateTime)
                        .then((value) {
                      if (value != null) {
                        _dateTime = value;
                        _requestData();
                      }
                    });
                  },
                ),
              ),
              _dataList.isEmpty
                  ? Container(
                      margin: const EdgeInsets.all(
                        15.0,
                      ),
                      child: CommonView.setNoDataView(170, '이슈가 없습니다.'),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          return _buildListItem(
                              _dataList[index].issueDate,
                              _dataList[index].listIssue);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  //리스트
  Widget _buildListItem(String date, List<Issue02> subList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 15,
            top: 15,
          ),
          child: Row(
            children: [
              Image.asset(
                'images/rassi_itemar_icon_ar1.png',
                fit: BoxFit.cover,
                scale: 3,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                getDateMdFormat(date),
                style: const TextStyle(
                    fontSize: 13, color: Colors.deepOrangeAccent),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: UIStyle.boxRoundLine6(),
          child: Wrap(
            spacing: 7.0,
            alignment: WrapAlignment.center,
            children: List.generate(subList.length,
                (index) => TileChip2(subList[index], RColor.yonbora2)),
          ),
        ),
      ],
    );
  }

  //00월 00일
  String getDateMdFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(4, 6)}월 ${date.substring(6, 8)}일';
      return rtStr;
    }
    return '';
  }

  //2021년 00월
  String getDateYmFormat(String date) {
    String rtStr = '';
    if (date.length > 5) {
      rtStr = '${date.substring(0, 4)}년 ${date.substring(4, 6)}월';
      return rtStr;
    }
    return '';
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueListPage.TAG, '$trStr $json');

    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(IssueListPage.TAG, response.body);

    if (trStr == TR.ISSUE02) {
      final TrIssue02 resData = TrIssue02.fromJson(jsonDecode(response.body));
      _dataList.clear();
      if (resData.retCode == RT.SUCCESS && resData.listData.isNotEmpty) {
        _dataList.addAll(resData.listData);
      }
      setState(() {});
    }
  }
}
