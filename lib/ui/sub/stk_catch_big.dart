import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:rassi_assist/models/tr_stk_catch01.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';

import '../home/sliver_stock_catch.dart';


/// 2022.01.27
/// 종목캐치 큰손 상세
class StkCatchBigPage extends StatefulWidget {
  static const routeName = '/page_stk_catch_big';
  static const String TAG = "[StkCatchBigPage]";
  static const String TAG_NAME = '큰손들의_종목캐치';

  const StkCatchBigPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StkCatchBigPageState();
}

class StkCatchBigPageState extends State<StkCatchBigPage> {
  var appGlobal = AppGlobal();
  String _userId = '';

  bool _bInitFirst = true;
  bool _isPushOnBig = true;
  int _iNewCount = 0;

  String _strDiv = '';
  final SwiperController _swiperBigController = SwiperController();
  final List<SwpBig> _swpBigList = [
    SwpBig('0', 'FRN', '라씨 매매비서와 외국인이\n함께 산 종목은?', 'images/img_foreigner.png'),
    SwpBig('1', 'ORG', '라씨 매매비서와 기관이\n함께 산 종목은?', 'images/img_inst.png'),
  ]; //외국인, 기관
  int _bigIndex = 0;

  final List<TimelineCatch> _listData = [];
  late ScrollController _scrollController;
  int _pageNum = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: StkCatchBigPage.TAG_NAME,
      screenClassOverride: StkCatchBigPage.TAG_NAME,
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _userId = appGlobal.userId;
    DLog.d(StkCatchBigPage.TAG, 'div code : ${appGlobal.pageData}');
    _strDiv = appGlobal.pageData;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_userId != '') {
        if (_strDiv == 'ORG')
          _swiperBigController.move(1);
        else
          _requestData(true, 'FRN');
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _requestData(bool bInit, String divStr) {
    if (bInit) {
      _listData.clear();
      _pageNum = 0;
      _iNewCount = 0;
    }

    _fetchPosts(
        TR.STKCATCH01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': divStr,
          'pageNo': _pageNum.toString(),
        }));
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData(false, _strDiv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.basicColorWithAction(
          context,
          '큰손들의 종목캐치',
          RColor.yonbora2,
          Colors.black,
          0,
          [
            _isPushOnBig ?
            IconButton(
              iconSize: 22,
              icon: const ImageIcon(
                AssetImage('images/rassibs_btn_icon.png'),
                color: RColor.jinbora,
              ),
              onPressed: () => _showDialogPushStatus(true, '종목 캐치'),
            ) :
            IconButton(
              iconSize: 22,
              icon: const ImageIcon(
                AssetImage('images/rassibs_btn_mute.png'),
                color: RColor.jinbora,
              ),
              onPressed: () => _showDialogPushStatus(false, '종목 캐치'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [_buildHeader(), _setListViewBuilder()],
          ),
        ),
      ),
    );
  }

  Widget _setListViewBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listData.length,
      itemBuilder: (context, index) {
        return _buildOneItem(
            _listData[index].tradeDate,
            _listData[index].sigList,
            _strDiv);
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 210,
              color: RColor.yonbora2,
            ),
            const SizedBox(
              height: 10,
            ),
            _setBigHSwiper(),

            // 새로운 매매 종목 알림
            Visibility(
              visible: _iNewCount > 0,
              child: _setNewStock(),
            ),
          ],
        ),
      ],
    );
  }

  // Swiper 큰손들의 종목캐치
  Widget _setBigHSwiper() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/logo_circle_icon.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      '&',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                        color: Color(0xffEFEFEF),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const SizedBox(
                      width: 73,
                      height: 70,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Text(
                  _swpBigList[_bigIndex].swpDesc,
                  style: TStyle.content17T,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 외국인/기관 아이콘 (Swiper부분)
          Row(
            children: [
              const Expanded(
                  child: SizedBox(
                width: 1,
                height: 120,
              )),
              Expanded(
                child: SizedBox(
                  // color: RColor.jinbora_tran,
                  height: 70,
                  child: Swiper(
                    controller: _swiperBigController,
                    loop: false,
                    autoplay: false,
                    itemCount: _swpBigList.length,
                    onIndexChanged: (int index) {
                      setState(() {
                        _bigIndex = index;
                      });
                      _requestData(true, _swpBigList[index].swpCode);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _getSwiperBhItem(index);
                    },
                  ),
                ),
              ),
            ],
          ),

          //좌우 스크롤 Arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset(
                  'images/main_jm_aw_l_g.png',
                  width: 70.0,
                ),
                onPressed: () {
                  _swiperBigController.previous(animation: true);
                },
              ),
              const SizedBox(
                height: 120,
                child: Text(''),
              ),
              IconButton(
                icon: Image.asset('images/main_jm_aw_r_g.png'),
                onPressed: () {
                  _swiperBigController.next(animation: true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Swiper 아이템 (큰손)
  Widget _getSwiperBhItem(int idx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 20.0,
        ),
        _setSelectImg(_swpBigList[_bigIndex].swpSn),
      ],
    );
  }

  //Swiper 이미지 선택
  Widget _setSelectImg(String strSn) {
    if (strSn == '0') {
      return Image.asset(
        'images/img_foreigner.png',
        height: 70,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        'images/img_inst.png',
        height: 70,
        fit: BoxFit.contain,
      );
    }
  }

  // 오늘 새로운 매수/매도 알림 영역
  Widget _setNewStock() {
    return Column(
      children: [
        //배경 Color
        const SizedBox(
          width: double.infinity,
          height: 165,
        ),

        Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Container(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: UIStyle.roundBtnBox25(),
              child: _setTileSigString(),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  // 오늘 새로운 알림
  Widget _setTileSigString() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '오늘 새로운  ',
          style: TStyle.btnContentWht16,
        ),
        const Text(
          '매수',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700, /*backgroundColor: stColor*/
          ),
        ),
        const Text(
          '  종목이 ',
          style: TStyle.btnContentWht16,
        ),
        Text(
          '$_iNewCount개',
          style: TStyle.btnTextWht17,
        ),
        const Text(
          ' 있습니다.',
          style: TStyle.btnContentWht16,
        ),
      ],
    );
  }

  //종목 리스트
  Widget _buildOneItem(String strDate, List<CatchSigInfo> subList, String div) {
    String sDate = '';
    Color sColor = Colors.black;
    if (strDate == TStyle.getTodayString()) {
      sDate = 'TODAY(${TStyle.getWeekdayKor(strDate)})';
      sColor = RColor.jinbora;
    } else {
      sDate =
          '${TStyle.getDateMdKorFormat(strDate)}(${TStyle.getWeekdayKor(strDate)})';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 15,
            top: 30,
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Text(
                sDate,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: sColor),
              ),
            ],
          ),
        ),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: subList.length,
          itemBuilder: (context, index) {
            return TileStkCatch01.gen(subList[index], div);
          },
        ),
      ],
    );
  }

  _navigateDataRefresh(
      BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(StkCatchBigPage.TAG, '*** ***');
    } else {
      DLog.d(StkCatchBigPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.PUSH04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //페이지 전환 에니메이션
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

  void _showDialogPushStatus(bool onoff, String title) {
    String imgPath = '';
    String descTxt = '';
    if (onoff) {
      imgPath = 'images/img_n_arlim_on.png';
      descTxt = ' 알림을\n수신중입니다.';
    } else {
      imgPath = 'images/img_n_arlim_off.png';
      descTxt = ' 알림을\n수신거부중입니다.';
    }

    showDialog(
        context: context,
        barrierDismissible: true,
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
                  Text(
                    '$title 알림 설정',
                    style: TStyle.title18T,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Image.asset(
                    imgPath,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  // const SizedBox(height: 5.0,),
                  // Text(armText, textAlign: TextAlign.center,),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    '$title' + descTxt,
                    style: const TextStyle(
                        color: RColor.mainColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Text(
                    '알림 ON/OFF는 알림 설정에서 하실 수 있습니다.',
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
                            '알림 설정 바로가기',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateDataRefresh(
                          context, const NotificationSettingN(), PgData(pgData: ''));
                    },
                  ),
                ],
              ),
            ),
          );
        });
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
    DLog.d(StkCatchBigPage.TAG, trStr + ' ' + json);

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
      DLog.d(StkCatchBigPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(StkCatchBigPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(StkCatchBigPage.TAG, response.body);

    if (trStr == TR.STKCATCH01) {
      final TrStkCatch01 resData =
          TrStkCatch01.fromJson(jsonDecode(response.body));
      _listData.clear();
      _iNewCount = 0;
      if (resData.retCode == RT.SUCCESS) {
        final retData = resData.retData;
        if(retData != null) {
          _strDiv = retData.selectDiv;
          if (retData.timeList.isNotEmpty) {
            _listData.addAll(retData.timeList);
            if (_listData[0].tradeDate == TStyle.getTodayString()) {
              //New 리스트의 갯수만 확인
              _iNewCount = _listData[0].sigList.length;
            }
          }

          setState(() {});
        }
      }

      if (_bInitFirst) {
        _fetchPosts(
            TR.PUSH04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    } else if (trStr == TR.PUSH04) {
      _bInitFirst = false;

      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Push04? item = resData.retData;
        if(item != null) {
          if (item.catchBighandYn == 'Y') {
            _isPushOnBig = true;
          } else {
            _isPushOnBig = false;
          }
          setState(() {});
        }

      }
    }
  }
}

class CountFlag {
  final String flag;
  final String count;

  CountFlag(this.flag, this.count);
}
