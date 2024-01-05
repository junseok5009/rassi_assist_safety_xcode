import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/theme_info.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme02.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/test/theme_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.07
/// 테마 검색
class ThemeSearch extends StatelessWidget {
  static const routeName = '/page_search_theme';
  static const String TAG = "[ThemeSearch]";
  static const String TAG_NAME = '테마검색';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: ThemeSearchWidget(),
      ),
    );
  }
}

class ThemeSearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ThemeSearchState();
}

class ThemeSearchState extends State<ThemeSearchWidget> {
  late SharedPreferences _prefs;
  String _userId = "";

  bool isSearching = false;
  final List<ThemeInfo> _listData = []; //검색어 입력하여 검색된 리스트

  bool isMyKeyword = true;
  final List<Stock> _recentMyList = [];
  bool recentEmpty = false; //최근 검색 종목이 없음

  @override
  void initState() {
    super.initState();

    _loadPrefData();

    //TODO 인기 테마는 추후에.
    // Future.delayed(Duration(milliseconds: 400), (){
    //   DLog.d(ThemeSearch.TAG, "delayed user id : " + _userId);
    //   if(_userId != '') {
    //     _fetchPosts(TR.THEME03,
    //         jsonEncode(<String, String>{
    //           'userId': _userId,
    //           // 'selectCount': '10',
    //         }));
    //   }
    // });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 110,
        child: Column(
          children: [
            AppBar(
              title: const Text(
                '테마검색',
                style: TStyle.title20,
              ),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              shadowColor: Colors.white,
              elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),

            //검색 box
            _setSearchField(),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 인기 검색어 ------------------------------------------
            Visibility(
              visible: false, //!isSearching,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setSubTitle('인기 검색 테마'),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Wrap(
                          spacing: 30.0,
                          runSpacing: 14.0,
                          children: List.generate(_recentMyList.length, (index) {
                            return InkWell(
                              child: Text(
                                _recentMyList[index].stockName,
                                style: TStyle.content15,
                              ),
                              onTap: () {},
                            );
                          }),
                        ),
                      ),

                      //최근 검색 종목이 없습니다.
                      Visibility(
                        visible: recentEmpty,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          child: const Text('최근 검색 종목이 없습니다.'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),

            // 유저 검색어 ------------------------------------------
            Visibility(
              visible: isSearching,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _listData.length,
                itemBuilder: (BuildContext context, index) => _tileSearch(_listData[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //검색 Box
  Widget _setSearchField() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: UIStyle.roundBtnLineBox(RColor.mainColor),
      child: Stack(
        children: [
          TextField(
            decoration: const InputDecoration.collapsed(hintText: '테마명을 입력하세요.'),
            controller: null,
            onChanged: (text) {
              if (text.length > 1) {
                _handleSubmit(text.toString());
              } else {
                setState(() {
                  isSearching = false;
                });
              }
            },
          ),
          const Positioned(
            right: 1.0,
            child: Icon(
              Icons.search,
              size: 22,
              color: RColor.mainColor,
            ),
          ),
        ],
      ),
    );
  }

  // 검색버튼 선택시 TODO 짧은 시간에 중복된 요청이 일어날 경우 처리는??
  void _handleSubmit(String keyword) {
    DLog.d(ThemeSearch.TAG, keyword.toString());

    _fetchPosts(
        TR.THEME02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'keyword': keyword,
          'selectCount': '20',
        }));
  }

  Widget _tileSearch(ThemeInfo item) {
    return ListTile(
      title: Text(item.themeName),
      onTap: () {
        basePageState.callPageRouteUpData(
          const ThemeViewer(),
          PgData(userId: '', pgSn: item.themeCode),
        );
      },
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: RColor.mainColor,
        ),
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
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
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(ThemeSearch.TAG, '$trStr $json');

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
      DLog.d(ThemeSearch.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(ThemeSearch.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeSearch.TAG, response.body);

    if (trStr == TR.THEME02) {
      final TrTheme02 resData = TrTheme02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        // List<ThemeStk> list = resData.retData;
        //
        // if(list != null && list.length > 0) {
        //   setState(() {
        //     _listData.clear();
        //     _listData.addAll(list);
        //     isSearching = true;
        //   });
        // } else {
        //   setState(() {
        //     _listData.clear();
        //     isSearching = false;
        //   });
        // }
      } else {
        //오류
        setState(() {
          isSearching = false;
        });
      }
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;

  CustomAppBar({
    required this.child,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      alignment: Alignment.center,
      child: child,
    );
  }
}
