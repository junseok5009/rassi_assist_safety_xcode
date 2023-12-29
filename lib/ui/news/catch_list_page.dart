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
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_catch03.dart';
import 'package:rassi_assist/ui/common/common_date_picker.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.11.03
/// 캐치 리스트 (라씨 매매비서의 주간토픽)
class CatchListPage extends StatefulWidget {
  static const routeName = '/page_catch_list';
  static const String TAG = "[CatchListPage]";
  static const String TAG_NAME = '매매비서_캐치히스토리';

  const CatchListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CatchListPageState();
}

class CatchListPageState extends State<CatchListPage> {
  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  Color statColor = Colors.grey;

  final List<Catch03> _dataList = [];
  DateTime _dateTime = DateTime.now();
  final _dateFormat = DateFormat('yyyy');

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: CatchListPage.TAG_NAME,
      screenClassOverride: CatchListPage.TAG_NAME,
    );

    _loadPrefData().then(
      (value) => {
        if (_userId != '')
          {
            _requestTrCatch03(),
          }
      },
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(context, '라씨 매매비서의 주간토픽'),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.topRight,
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: CommonView.setDatePickerBtnView(
                  "${_dateFormat.format(_dateTime)}년",
                  () async {
                    //_showYearPicker();
                    await CommonDatePicker.showYearPicker(
                            context, _dateTime)
                        .then(
                      (value) {
                        if (value != null) {
                          _dateTime = value;
                          _requestTrCatch03();
                        }
                      },
                    );
                  },
                ),
              ),
              _dataList.isEmpty
                  ? Container(
                      margin: const EdgeInsets.all(15),
                      child: CommonView.setNoDataView(170, '주간토픽 데이터가 없습니다.'),
                    )
                  : Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          return TileCatch03(_dataList[index]);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _requestTrCatch03(){
    _fetchPosts(
      TR.CATCH03,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'issueYear': _dateFormat.format(_dateTime),
          'pageNo': '0',
          'pageItemSize': '60',
        },
      ),
    );
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(CatchListPage.TAG, '$trStr $json');

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
      DLog.d(CatchListPage.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(CatchListPage.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(CatchListPage.TAG, response.body);
    if (trStr == TR.CATCH03) {
      _dataList.clear();
      TrCatch03 resData = TrCatch03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS && resData.retData.isNotEmpty) {
        _dataList.addAll(resData.retData);
      }
      setState(() {});
    }
  }
}
