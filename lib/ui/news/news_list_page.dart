import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.11.03
/// 라씨로 리스트 / 홈_마켓뷰 이시간속보 더보기 > [AI 속보 분석 리포트]
// (종목코드 없으면 RASSI01, 종목코드 있으면 RASSI02)
class NewsListPage extends StatefulWidget {
  static const routeName = '/page_news_list';
  static const String TAG = "[NewsListPage]";
  static const String TAG_NAME = '이시간_AI속보_더보기';

  const NewsListPage({super.key});

  @override
  State<StatefulWidget> createState() => NewsListState();
}

class NewsListState extends State<NewsListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  String stkName = "";
  String stkCode = "";
  Color statColor = Colors.grey;

  final List<Rassiro> _newsList = [];
  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NewsListPage.TAG_NAME);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (deviceModel.contains('iPad')) {
        pageSize = '20';
      }

      PgNews? args = ModalRoute.of(context)!.settings.arguments as PgNews?;
      if (args != null) {
        stkName = args.stockName;
        stkCode = args.stockCode;
      }

      _requestData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //리스트뷰 하단 리스너
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      _requestData();
    } else {}
  }

  void _requestData() {
    // 아이패드 같은 경우에는 10개 이상의 리스트는 볼수 없다.
    debugPrint("stock code : $stkCode");
    if (stkCode.isNotEmpty) {
      _fetchPosts(
          TR.RASSI02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
            'pageNo': pageNum.toString(),
            'pageItemSize': pageSize,
          }));
    } else {
      _fetchPosts(
          TR.RASSI01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': pageNum.toString(),
            'pageItemSize': pageSize,
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: Scaffold(
        appBar: CommonAppbar.basic(
          buildContext: context,
          title: 'AI속보 분석리포트',
          elevation: 1,
        ),
        body: SafeArea(
          child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                return TileRassiroList(_newsList[index]);
              }),
        ),
      ),
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      deviceModel = iosInfo.model!;
    });
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(NewsListPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NewsListPage.TAG, response.body);

    if (trStr == TR.RASSI01) {
      final TrRassi01 resData = TrRassi01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _newsList.addAll(resData.listData as Iterable<Rassiro>);
        // DLog.d(NewsListPage.TAG, _newsList.length);
        setState(() {});
      }
    } else if (trStr == TR.RASSI02) {
      final TrRassi02 resData = TrRassi02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {}
    }
  }
}
