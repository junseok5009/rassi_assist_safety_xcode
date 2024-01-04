import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search03.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/login/login_division_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/keyboard_page.dart';
import 'package:rassi_assist/ui/sub/trade_intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.10.14
/// --- 수정 기록 ---
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// Intro Search
class IntroSearchPage extends StatefulWidget {
  static const routeName = '/page_intro_search';
  static const String TAG = "[IntroSearchPage]";
  static const String TAG_NAME = '인트로_검색';

  @override
  State<StatefulWidget> createState() => IntroSearchPageState();
}

class IntroSearchPageState extends State<IntroSearchPage> {
  late SharedPreferences _prefs;
  List<Search03> _stkList = [];
  List<String> _searchList = []; //무료 5종목 검색
  String deepLinkData = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(IntroSearchPage.TAG_NAME);
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'in_intro_search');
    _loadPrefData().then(
      (value) => _fetchPosts(
        TR.SEARCH03,
        jsonEncode(<String, String>{
          'userId': 'RASSI_APP',
          'selectDiv': 'S',
          'selectCount': '5',
        }),
      ),
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _searchList = _prefs.getStringList(TStyle.getTodayString()) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.none(
          RColor.mainColor,
        ),
        body: SafeArea(
          child: ListView(
            children: [
              //상단 자세히보기 이미지
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.asset(
                    'images/rassibs_intro_bn_img_3_0807_bg.png',
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '라씨 매매비서는',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '전종목에 대한 AI매매신호를\n제공하는 진짜 매매비서입니다.',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '언제 살까? 언제 팔까? ',
                      style: TStyle.title18T,
                    ),
                    const Text(
                      '바로 확인해 보세요!',
                      style: TStyle.content15,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _setSearchBox(),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      '오늘의 인기종목',
                      style: TextStyle(
                        color: RColor.mainColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _setPopularStock(),
                    const SizedBox(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: const BoxDecoration(
                              color: RColor.mainColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '1초만에 라씨 매매비서 시작하기',
                                style: TStyle.btnTextWht15,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                                context, LoginDivisionPage.routeName);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //검색 Box
  Widget _setSearchBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: UIStyle.roundBtnLineBox(RColor.mainColor),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Flexible(
              child: Text(
                '종목명(초성, 중간어 지원) / 종목코드 검색',
                style: TStyle.textGrey15,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.search,
              size: 25,
              color: RColor.mainColor,
            ),
          ],
        ),
        onTap: () {
          _navigateRefresh(context, KeyboardPage());
        },
      ),
    );
  }

  //오늘의 인기 종목
  Widget _setPopularStock() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _stkList.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _stkList[index].stockName,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    _stkList[index].stockCode,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xdd555555),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              if (_searchList.length < 5 ||
                  _containListData(_searchList, _stkList[index].stockCode)) {
                //새로운 종목코드 라면 페이지에 임시 저장
                if (!_containListData(_searchList, _stkList[index].stockCode)) {
                  _searchList.add(_stkList[index].stockCode);
                }

                Navigator.push(
                  context,
                  _createRouteData(
                    const TradeIntroPage(),
                    RouteSettings(
                      arguments: PgData(
                        userId: '',
                        stockCode: _stkList[index].stockCode,
                        stockName: _stkList[index].stockName,
                      ),
                    ),
                  ),
                );
              } else {
                _showDialogLimit();
              }
            },
          );
        });
  }

  //리스트에서 해당 종목코드 있는지
  bool _containListData(List<String> sList, String newStr) {
    if (sList != null && sList.length > 0) {
      for (int i = 0; i < sList.length; i++) {
        if (sList[i] == newStr) return true;
      }
      return false;
    } else {
      return false;
    }
  }

  // 다음 페이지로 이동(사용안함: IntroSearch 에서 가입 없음)
  _goNextRoute(String userId) {
    if (userId != '') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const BasePage()));
    } else {}
  }

  //5종목 초과 검색시 알림
  void _showDialogLimit() {
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
                Image.asset(
                  'images/rassibs_iconimg_01.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '알림',
                  textAlign: TextAlign.center,
                  style: TStyle.title18,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '로그인 전 매매비서 / 매매신호 열람은 하루 5종목까지 무료로 제공됩니다.',
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
                      decoration: const BoxDecoration(
                        color: RColor.mainColor,
                        borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                      ),
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
      },
    );
  }

  _navigateRefresh(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(IntroSearchPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(IntroSearchPage.TAG, '*** navigateRefresh');
      _loadPrefList();
      DLog.d(IntroSearchPage.TAG, '*** ${_searchList.length}');
    }
  }

  _loadPrefList() {
    setState(() {
      _searchList.clear();
      _searchList = _prefs.getStringList(TStyle.getTodayString()) ?? [];
    });
  }

  //페이지 이동 에니메이션
  Route _createRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
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
                    padding:
                        EdgeInsets.only(top: 20, left: 10, right: 10),
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
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(
                              Radius.circular(20.0)),
                        ),
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
    DLog.d(IntroSearchPage.TAG, trStr + ' ' + json);

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
      DLog.d(IntroSearchPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(IntroSearchPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각 ???
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(IntroSearchPage.TAG, response.body);

    if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      DLog.d(IntroSearchPage.TAG, resData.retCode);

      if (resData.retCode == RT.SUCCESS) {
        final User02 data = resData.retData!;
        DLog.d(IntroSearchPage.TAG, data.toString());
        if (data.userId != '') {
          _prefs.setString(Const.PREFS_USER_ID, data.userId);
          //일단은 메인으로 이동, 나중에 푸시 등록
          DLog.d(IntroSearchPage.TAG, '로그인 완료~~~ 메인으로 이동');
          _goNextRoute(data.userId);
        } else {
          //매매비서 회원정보 생성
        }
      }
    } else if (trStr == TR.SEARCH03) {
      TrSearch03 resData = TrSearch03.fromJson(jsonDecode(response.body));
      _stkList = resData.retData!;
      setState(() {});
    }
  }
}
