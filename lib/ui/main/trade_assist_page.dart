import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_ask02.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.10.06
/// 매매비서(종목검색)
class TradeAssistPage extends StatefulWidget {
  static const routeName = '/page_trade_assist';
  static const String TAG = "[TradeAssistPage]";
  static const String TAG_NAME = '라씨매매비서_검색';

  const TradeAssistPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TradeAssistPageState();
}

class TradeAssistPageState extends State<TradeAssistPage> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _appEnv =
      Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = "";
  String _deviceId = '';
  String _preToken = '';
  String _genToken = '';
  String _todayString = '0000';
  String _dayCheckPush = '';

  List<StockAsk> askList = [];
  bool isNoAsk = false;

  //List<String> _wordList = [];
  //final List<Stock> _themeStkList = [];
  //bool _isEmptyTheme = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: TradeAssistPage.TAG_NAME,
      screenClassOverride: TradeAssistPage.TAG_NAME,
    );

    _loadPrefData();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _genToken = (await FirebaseMessaging.instance.getToken()) ?? '';
    _prefs = await SharedPreferences.getInstance();
    _todayString = TStyle.getTodayString();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _deviceId = _prefs.getString(Const.PREFS_DEVICE_ID) ?? '';
      _preToken = _prefs.getString(Const.PREFS_SAVED_TOKEN) ?? '';
      _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_ASSIST) ?? '';
      appGlobal.userId = _userId;
    });

    DLog.d(TradeAssistPage.TAG, "delayed user id : $_userId");
    DLog.d(TradeAssistPage.TAG, "delayed deviceId : $_deviceId");
    DLog.d(TradeAssistPage.TAG, "delayed saved token : $_preToken");

    if (_userId != '') {
      _fetchPosts(
          TR.SEARCH05,
          jsonEncode(<String, String>{
            'userId': _userId,
            'isMySearch': 'Y',
            'selectCount': '',
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.none(
        RColor.deepStat,
      ),
      body: ListView(
        children: [
          _setTopDesc(),
          const SizedBox(
            height: 10.0,
          ),

          _setSubTitle(
            "나의 최근 문의 종목",
          ),
          const SizedBox(height: 15,),
          Stack(
            children: [
              _setAskStock(context),
              Visibility(
                visible: isNoAsk,
                child: Container(
                  margin: const EdgeInsets.only(top: 40.0),
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  child: const Text('최근 문의 내역이 없습니다.'),
                ),
              )
            ],
          ),
          _setNewStockInfo(),

          /* const SizedBox(height: 25.0,),

          //포켓보드 이동 배너
          _setGoPocketBoard(),
          const SizedBox(height: 20.0,),*/

          //네이버 인기종목 키워드
          /*_setSubTitle('인기 종목 키워드'),
          const SizedBox(height: 5.0,),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.center,
              children: List.generate(_wordList.length, (index) =>
                  ChipKeyword(_wordList[index], RColor.yonbora2)),
            ),
          ),
          const SizedBox(height: 20.0,),*/

          /*
          //핫 테마 종목
          _setHotThemeList(),
          */
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  //상단 페이지 소개
  Widget _setTopDesc() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: RColor.deepStat,
          child: Column(
            children: [
              const SizedBox(
                height: 40.0,
              ),
              Image.asset(
                'images/icon_main_white.png',
                height: 50,
                fit: BoxFit.contain,
              ),
              const Text(
                'AI매매비서',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  fontSize: 12,
                  height: 2,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                '언제 살까? 언제 팔까? ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.7,
                  fontSize: 22,
                ),
              ),
              const Text(
                '바로 확인해 보세요!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  fontSize: 17,
                  height: 1.5
                ),
              ),
              const SizedBox(
                height: 60.0,
              ),
            ],
          ),
        ),
        //검색 Box
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 225.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: _setBoxDecoration(),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '어떤 종목이 궁금하신가요?',
                  style: TextStyle(
                    fontSize: 15,
                    color: RColor.new_basic_text_color_strong_grey,
                  ),
                ),
                Icon(
                  Icons.search,
                  size: 28,
                  color: RColor.deepStat,
                ),
              ],
            ),
            onTap: () {
/*              _navigateSearchData(
                  context,
                  SearchPage(),
                  PgData(
                    pgSn: '',
                  ));*/
            },
          ),
        ),
      ],
    );
  }

  //포켓보드 이동 배너
  Widget _setGoPocketBoard() {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 130,
        color: RColor.bgWeakGrey,
        child: Image.network(
          'http://files.thinkpool.com/pnc/rassi/img_banner_board.jpg',
          fit: BoxFit.contain,
        ),
      ),
      onTap: () {
        // //포켓보드로 이동
        // Navigator.pushNamed(
        //   context,
        //   PocketBoard.routeName,
        //   arguments: PgData(
        //     pgSn: '',
        //   ),
        // );
      },
    );
  }

  //문의한 종목
  Widget _setAskStock(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: askList.length,
          itemBuilder: (context, index) {
            return TileAsk02(askList[index], RColor.assistBack[index % 6]);
          }),
    );
  }

  //문의한 종목 설명
  Widget _setNewStockInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 10,),
      padding: const EdgeInsets.all(10.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('내 문의 종목의 새로운 소식을 확인해 보세요!'),
          const Text('새로운 소식이 있는 경우 '),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'N',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Color(0xffEFEFEF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Text(' 아이콘이 표시 됩니다.'),
        ],
      ),
    );
  }

  //핫 테마 리스트
  /*Widget _setHotThemeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _setSubTitle(
          "핫 테마의 종목들",
        ),
        _isEmptyTheme
            ? Container(
                margin: const EdgeInsets.all(
                  15,
                ),
                child: CommonView.setNoDataView(150, '핫 테마 종목이 없습니다.'),
              )
            : _setHotThemeStock(),
      ],
    );
  }*/

  //핫 테마 종목
  /*Widget _setHotThemeStock() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _themeStkList.length,
          itemBuilder: (context, index) {
            return TileHotTheme(
                _themeStkList[index], RColor.assistBack[index % 6]);
          }),
    );
  }*/

  _navigateSearchData(
      BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(
        context,
        _createRouteData(
            instance,
            RouteSettings(
              arguments: pgData,
            )));
    if (result == 'cancel') {
      DLog.d(TradeAssistPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(TradeAssistPage.TAG, '*** navigateRefresh');
      //TODO
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

  //푸시 토큰 재생성 체크
  void _checkPushToken() {
    //푸시 재등록 여부(개발모드에서 제외)
    if (!Const.isDebuggable) {
      if (_dayCheckPush != _todayString) {
        DLog.d(TradeAssistPage.TAG, 'preToken: $_preToken');
        DLog.d(TradeAssistPage.TAG, 'genToken: $_genToken');
        DLog.d(TradeAssistPage.TAG, '하루 푸시체크 $_todayString');
        _prefs.setString(Const.PREFS_DAY_CHECK_ASSIST, _todayString);

        if (_preToken != _genToken) {
          DLog.d(TradeAssistPage.TAG, '푸시 재등록 PUSH01');
          _fetchPosts(
              TR.PUSH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'appEnv': _appEnv,
                'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                'pushToken': _genToken,
              }));
        }
      }
    }
  }

  //소항목 타이틀
  Widget _setSubTitle(
    String subTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  BoxDecoration _setBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color(0xff353c73),
        width: 1.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
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
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.boxBtnSelected20(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
    DLog.d(TradeAssistPage.TAG, '$trStr $json');

    // var url = Uri.parse(Net.TR_BASE_android + trStr); //NOTE ***[TEST]***
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
      DLog.d(TradeAssistPage.TAG, 'TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(TradeAssistPage.TAG, 'SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(TradeAssistPage.TAG, response.body);

    if (trStr == TR.SEARCH05) {
      final TrAsk02 resData = TrAsk02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<StockAsk>? data = resData.retData;
        isNoAsk = false;
        setState(() {
          askList = data!;
        });
      } else if (resData.retCode == RT.NO_DATA) {
        if (askList.isEmpty) isNoAsk = true;

        setState(() {});
      }

      _checkPushToken();

      /* _fetchPosts(TR.KWORD03, jsonEncode(<String, String>{
        'userId': _userId,
      }));*/
    }

    //인기 종목 키워드(네이버)
    /* else if(trStr == TR.KWORD03) {
      final TrKWord03 resData = TrKWord03.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        setState(() {
          _wordList = resData.retData;
        });
      }

      _fetchPosts(TR.THEME07, jsonEncode(<String, String>{
        'userId': _userId,
        'selectCount': '3',
      }));


    }*/

    /* else if(trStr == TR.THEME07) {
      final TrTheme07 resData = TrTheme07.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {

        if(resData.retData != null) {
          List<ThemeInfo> tempList = resData.retData.listData;
          if(tempList != null && tempList.length > 0) {
            for(int i=0; i < tempList.length; i++){
              _themeStkList..addAll(tempList[i].listStock);
            }
          }
        }
        _isEmptyTheme = false;
        setState(() {});
      }
      else {
        setState(() {
          _isEmptyTheme = true;
        });
      }

    }*/

    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _genToken);
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }
    }
    // else if(trStr == TR.CATCH01) {
    //   final TrCatch01 resData = TrCatch01.fromJson(jsonDecode(response.body));
    //   if(resData.retCode == RT.SUCCESS) {
    //     setState(() {
    //       _catchWeek = resData.retData.issueTmTx;
    //       _catchTitle = resData.retData.title;
    //       _catchSn = resData.retData.catchSn;
    //     });
    //   }
    //
    //   if(resData.retCode == RT.SUCCESS) {
    //     if(resData.retData.listStock.length > 4) {
    //       _catchStkList = resData.retData.listStock.sublist(0, 4);
    //     } else {
    //       _catchStkList = resData.retData.listStock;
    //     }
    //     setState(() {
    //       _catchTitle = resData.retData.title;
    //       _catchSn = resData.retData.catchSn;
    //     });
    //   }
    //
    //   _checkPushToken();
    // }
  }
}
