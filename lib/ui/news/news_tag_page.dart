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
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi06.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.12.24
/// 라씨로 태그 리스트
class NewsTagPage extends StatefulWidget {
  static const routeName = '/page_news_tag';
  static const String TAG = "[NewsTagPage]";
  static const String TAG_NAME = '라씨로태그_리스트';
  static final GlobalKey<NewsTagPageState> globalKey = GlobalKey();

  NewsTagPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => NewsTagPageState();
}

class NewsTagPageState extends State<NewsTagPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  late PgNews args;
  String tagCode = '';
  String tagName = '';

  bool isNoData = false;
  final List<Rassiro> newsList = [];
  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NewsTagPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (deviceModel!.contains('iPad')) {
        pageSize = '20';
      }
      requestData();
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
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      requestData();
    } else {}
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      deviceModel = iosInfo?.model;
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgNews;
    tagCode = args.tagCode;
    tagName = args.tagName;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: CommonAppbar.basic(context, '태그별 AI 속보 리스트'),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                if (tagCode == "USRTAG") {
                  return TileRassiroFeatureList(newsList[index]);
                } else {
                  return TileRassiroList(newsList[index]);
                }
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
      ),
    );
  }

  requestData() {
    if (tagCode != null && tagCode != '') {
      _fetchPosts(
          TR.RASSI06,
          jsonEncode(<String, String>{
            'userId': _userId,
            'tagCode': tagCode,
            'pageNo': pageNum.toString(),
            'pageItemSize': pageSize,
          }));
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(NewsTagPage.TAG, '$trStr $json');
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
      DLog.d(NewsTagPage.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NewsTagPage.TAG, response.body);

    if (trStr == TR.RASSI06) {
      final TrRassi06 resData = TrRassi06.fromJson(jsonDecode(response.body));
      isNoData = true;
      if (resData.retCode == RT.SUCCESS) {
        isNoData = false;
        newsList.addAll(resData.listData);
      }
      setState(() {});
    }
  }
}
