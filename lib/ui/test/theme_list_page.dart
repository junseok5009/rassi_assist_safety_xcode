import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme01.dart';
import 'package:rassi_assist/ui/sub/theme_search.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2022.01.05
/// (종목)테마 전체보기 (사용안함)
class ThemeListPage extends StatelessWidget {
  static const routeName = '/page_theme_list';
  static const String TAG = "[ThemeListPage]";
  static const String TAG_NAME = '테마전체보기';

  const ThemeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),
      body: const ThemeListWidget(),
    );
  }
}

class ThemeListWidget extends StatefulWidget {
  const ThemeListWidget({super.key});

  @override
  State<StatefulWidget> createState() => ThemeListState();
}

class ThemeListState extends State<ThemeListWidget> {
  late SharedPreferences _prefs;
  String _userId = "";

  String reqDiv = 'BUY';
  final List<Theme01> _dataList = [];
  ListSort selectSort = ListSort.SORT_A;
  late ScrollController _scrollController;
  int _pageNum = 0;


  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: ThemeListPage.TAG_NAME,
      screenClassOverride: ThemeListPage.TAG_NAME,);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      _requestData(true, reqDiv);
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  void _requestData(bool bInit, String div) {
    if(bInit) {
      _dataList.clear();
      _pageNum = 0;
    }

    _fetchPosts(TR.THEME01, jsonEncode(<String, String>{
      'userId': _userId,
      'sortDiv': div,
      'pageNo': _pageNum.toString(),
      'pageItemSize': '20',
    }));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent
        && !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData(false, reqDiv);
    }
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
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          itemCount: _dataList.length,
          itemBuilder: (context, index){
            return TileTheme01(_dataList[index]);
          },),
      ),
    );
  }

  // 타이틀바(AppBar)
  PreferredSizeWidget _setCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(155),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('테마 전체 보기', style: TStyle.commonTitle,),
                SizedBox(width: 55.0,),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            toolbarHeight: 50,
            elevation: 1,
          ),

          //테마 검색
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Divider(height: 1.0, color: RColor.lineGrey,),
              Container(
                width: double.infinity,
                height: 53,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('관심있는 테마를 찾아보세요', style: TStyle.defaultContent,),

                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                          side: const BorderSide(color: RColor.lineGrey)),
                      color: Colors.white,
                      textColor: Colors.black,
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('테마 검색', style: TStyle.defaultContent,),
                            SizedBox(width: 15.0,),
                            Icon(Icons.search, color: RColor.mainColor,),
                          ],
                        ),
                      ),
                      onPressed: (){    //테마 검색
                        _navigateSearchData(context, ThemeSearch(), PgData(pgSn: '',));
                      },
                    ),
                    // const SizedBox(width: 10,),
                  ],
                ),
              ),
              // Divider(height: 1.0, color: RColor.lineGrey,),
            ],
          ),

          //테마 정렬
          _setSortRadio(),
        ],
      ),
    );
  }

  //라디오 버튼 SET
  Widget _setSortRadio() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Radio(
                value: ListSort.SORT_A,
                groupValue: selectSort,
                activeColor: RColor.sigBuy,
                onChanged: (value){
                  setState(() {
                    selectSort = value!;
                    reqDiv = 'BUY';
                  });
                  _requestData(true, reqDiv);
                },
              ),
              const Text('신규 매수 신호 많은 순'),
            ],
          ),
          const SizedBox(width: 7.0,),

          Row(
            children: [
              Radio(
                value: ListSort.SORT_B,
                groupValue: selectSort,
                activeColor: RColor.sigBuy,
                onChanged: (value){
                  setState(() {
                    selectSort = value!;
                    reqDiv = 'TOP';
                  });
                  _requestData(true, reqDiv);
                },
              ),
              const Text('오늘 상승률 높은 순'),
            ],
          ),
          const SizedBox(width: 15.0,),

        ],
      ),
    );
  }

  //
  _navigateSearchData(BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, _createRouteData(instance, RouteSettings(arguments: pgData,)));
    if(result == 'cancel') {
      DLog.d(ThemeListPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(ThemeListPage.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
      //   'userId': _userId,
      //   'selectCount': '10',
      // }));
    }
  }
  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,);
      },
    );
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
                  child: const Icon(Icons.close, color: Colors.black,),
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
                  const Text(RString.err_network, textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text('확인', style: TStyle.btnTextWht16,
                            ),),
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
    DLog.d(ThemeListPage.TAG, trStr + ' ' +json);

    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(ThemeListPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(ThemeListPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeListPage.TAG, response.body);

    if(trStr == TR.THEME01) {
      final TrTheme01 resData = TrTheme01.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _dataList.addAll(resData.listData);
        // DLog.d(ThemeListPage.TAG, 'Data count : ${_dataList.length}');
        setState(() {});
      }
    }
  }

}


enum ListSort {SORT_A, SORT_B}