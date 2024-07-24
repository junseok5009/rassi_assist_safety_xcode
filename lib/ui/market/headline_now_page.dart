import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi11.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi14.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2024.06
/// 이 시각 헤드라인
class HeadlineNowPage extends StatefulWidget {
  static const routeName = '/page_headline_now';
  static const String TAG = "[HeadlineNowPage]";
  static const String TAG_NAME = '';
  static final GlobalKey<HeadlineNowState> globalKey = GlobalKey();

  HeadlineNowPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => HeadlineNowState();
}

class HeadlineNowState extends State<HeadlineNowPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  late PgData args;
  String tagCode = '';
  String tagName = '';

  bool isNoData = false;
  final List<Rassi11> _pickTagList = []; //이 시간 PICK
  final List<Rassi14> _relayList = [];
  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(HeadlineNowPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (deviceModel!.contains('iPad')) {
        pageSize = '20';
      }
      // args = ModalRoute.of(context)!.settings.arguments as PgData;

      _requestData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      _requestData();
    } else {}
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    deviceModel = iosInfo.model;
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
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '이 시각 헤드라인',
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            //관련 속보와 종목
            const SizedBox(height: 10),
            Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pickTagList.length,
                  itemBuilder: (context, index) {
                    return TileRassi11(
                      item: _pickTagList[index],
                      visibleDividerLine: true,
                    );
                  },
                ),
                Visibility(
                  visible: isNoData,
                  child: Container(
                    margin: const EdgeInsets.only(top: 40.0),
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    child: const Text('해당 태그 관련 뉴스는 아직 발생되지 않았습니다.'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _requestData() {
    _fetchPosts(
        TR.RASSI11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'pageNo': pageNum.toString(),
          'pageItemSize': pageSize,
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(HeadlineNowPage.TAG, '$trStr $json');
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(HeadlineNowPage.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(HeadlineNowPage.TAG, response.body);

    if (trStr == TR.RASSI14) {
      final TrRassi14 resData = TrRassi14.fromJson(jsonDecode(response.body));
      isNoData = true;
      if (resData.retCode == RT.SUCCESS) {
        isNoData = false;
        if (pageNum == 0) {
          // _recomTagList.clear();
          // _recomTagList.addAll(resData.listTag);
          _relayList.clear();
        }
        _relayList.addAll(resData.listData);
      }
      setState(() {});
    }

    //이 시각 헤드라인 (라씨로 PICK)
    if (trStr == TR.RASSI11) {
      final TrRassi11 resData = TrRassi11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pickTagList.addAll(resData.listData);
        setState(() {});
      }
    }
  }
}
