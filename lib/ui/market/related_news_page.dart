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
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi14.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2024.06
/// 관련 속보와 종목 모두 보기 (장중 투자자 동향 / 큰손 매매 / 시장 핫종목)
class RelatedNewsPage extends StatefulWidget {
  static const routeName = '/page_related_news';
  static const String TAG = "[RelatedNewsPage]";
  static const String TAG_NAME = '';
  static final GlobalKey<RelatedNewsPageState> globalKey = GlobalKey();

  RelatedNewsPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => RelatedNewsPageState();
}

class RelatedNewsPageState extends State<RelatedNewsPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  late PgData args;
  String tagCode = '';
  String tagName = '';
  String selectType = '';
  String typeTitle = '';

  bool isNoData = false;
  final List<TagEvent> _recomTagList = [];
  final List<Rassi14> _relayList = [];
  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(RelatedNewsPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (deviceModel!.contains('iPad')) {
        pageSize = '20';
      }
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      selectType = args.pgData;
      if (selectType == 'INVESTOR') typeTitle = '장중 투자자 동향';
      if (selectType == 'AGENCY') typeTitle = '큰손 매매';
      if (selectType == 'HOT_STOCK') typeTitle = '시장 핫종목';

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
        title: typeTitle,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            //관련 태그 리스트
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xffF5F5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('관련 태그', style: TStyle.content15,),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        _recomTagList.length,
                            (index) => TileTag14(
                          _recomTagList[index],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //관련 속보와 종목
            Stack(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _relayList.length,
                  itemBuilder: (context, index) {
                    return TileRassi14(_relayList[index]);
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
    if (selectType.isNotEmpty) {
      _fetchPosts(
          TR.RASSI14,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': selectType,
            'pageNo': pageNum.toString(),
            'pageItemSize': pageSize,
          }));
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(RelatedNewsPage.TAG, '$trStr $json');
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(RelatedNewsPage.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(RelatedNewsPage.TAG, response.body);

    if (trStr == TR.RASSI14) {
      final TrRassi14 resData = TrRassi14.fromJson(jsonDecode(response.body));
      isNoData = true;
      if (resData.retCode == RT.SUCCESS) {
        isNoData = false;
        if (pageNum == 0) {
          _recomTagList.clear();
          _recomTagList.addAll(resData.listTag);
          _relayList.clear();
        }
        _relayList.addAll(resData.listData);
      }
      setState(() {});
    }

  }
}
