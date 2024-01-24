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
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi06.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi15.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2022.04.26
/// 라씨로 (시장총정리)태그 리스트 (추후에 new_tag_page로 통합)
class NewsTagSumPage extends StatelessWidget {
  static const routeName = '/page_news_tag_sum';
  static const String TAG = "[NewsTagSumPage]";
  static const String TAG_NAME = '시장정리용_태그_리스트';

  const NewsTagSumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),
      body: const NewsTagSumWidget(),
    );
  }
}

class NewsTagSumWidget extends StatefulWidget {
  const NewsTagSumWidget({super.key});

  @override
  State<StatefulWidget> createState() => NewsTagSumState();
}

class NewsTagSumState extends State<NewsTagSumWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true;     //true: 아직 화면이 사라지기 전

  // PgNews args;
  late String tagCode;

  bool isNoData = false;
  int _selectedIdx = 0;
  final List<TagNew> _tagList = [];
  final List<Rassiro> _newsList = [];

  late ScrollController _scrollController;
  int pageNum = 0;
  String pageSize = '10';

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';


  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NewsTagSumPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      if(deviceModel.contains('iPad')) {
        pageSize = '20';
      }

      _fetchPosts(TR.RASSI15, jsonEncode(<String, String>{
        'userId': _userId,
        'selectDiv': 'MKT',
      }));
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
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent
        && !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      _requestData();
    }
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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),);
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: _setCustomAppBar(),

      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.center,
              children: List.generate(_tagList.length, (index) =>
                  InkWell(
                    child: Chip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white),
                      ),
                      label: Text('#${_tagList[index].tagName}',
                          style: TextStyle(
                            color: index == _selectedIdx ? Colors.black : RColor.mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                      ),
                      backgroundColor: index == _selectedIdx
                          ? RColor.yonbora
                          : RColor.bgWeakGrey,
                    ),
                    onTap: (){
                      setState(() {
                        _selectedIdx = index;
                        tagCode = _tagList[index].tagCode;
                        pageNum = 0;
                      });
                      _newsList.clear();
                      _requestData();
                    },
                  )),
            ),
            const SizedBox(height: 15,),

            ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                return TileRassiroList(_newsList[index]);
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


  // 타이틀바(AppBar)
  PreferredSizeWidget _setCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('태그별 AI 속보 리스트', style: TStyle.commonTitle,),
                SizedBox(width: 55.0,),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            toolbarHeight: 50,
            elevation: 1,
          ),

        ],
      ),
    );
  }

  _requestData() {
    DLog.d(NewsTagSumPage.TAG, "tag code : $tagCode");
    if(tagCode != '') {
      _fetchPosts(TR.RASSI06, jsonEncode(<String, String>{
        'userId': _userId,
        'tagCode': tagCode,
        'pageNo': pageNum.toString(),
        'pageItemSize': pageSize,
      }));
    }
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 5.0,),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text('안내', style: TStyle.commonTitle,),
                  ),
                  const SizedBox(height: 25.0,),
                  const Text(RString.err_network, textAlign: TextAlign.center,),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,),),
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(NewsTagSumPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(NewsTagSumPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(NewsTagSumPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NewsTagSumPage.TAG, response.body);

    if(trStr == TR.RASSI15) {
      final TrRassi15 resData = TrRassi15.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        if(resData.listData != null && resData.listData.length > 0) {
          for(int i=0; i < resData.listData.length; i++) {
            _tagList.add(resData.listData[i]);
          }
        }

        if(_tagList.length > 0) {
          setState(() {
            tagCode = _tagList[0].tagCode;
          });
          _requestData();
        } else {
          isNoData = true;
          setState(() {});
        }
      }
    }

    if(trStr == TR.RASSI06) {
      final TrRassi06 resData = TrRassi06.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        isNoData = false;
        _newsList..addAll(resData.listData);
        setState(() {});
      }
      else if(resData.retCode == RT.NO_DATA) {
        if(_newsList.length == 0) isNoData = true;

        setState(() {});
      }
    }
  }

}