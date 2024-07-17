import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_push/tr_push04.dart';
import 'package:rassi_assist/models/tr_stk_catch02.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';

import '../common/common_appbar.dart';
import '../home/sliver_stock_catch.dart';

/// 2022.02.08
/// 종목캐치 TOP 상세
class StkCatchTopPage extends StatefulWidget {
  static const routeName = '/page_stk_catch_top';
  static const String TAG = "[StkCatchTopPage]";
  static const String TAG_NAME = '성과TOP종목캐치';

  const StkCatchTopPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StkCatchTopPageState();
}

class StkCatchTopPageState extends State<StkCatchTopPage> {
  var appGlobal = AppGlobal();
  String _userId = '';

  bool _isPushOnTop = true;
  final List<CatchStock> _listData = [];
  final SwiperController _swiperTopController = SwiperController();
  final List<SwpTop> _swpTopList = [
    SwpTop('0', 'AVG', '적중률과 평균수익률이\n모두 높았던 종목은?', 'S'),
    SwpTop('1', 'SUM', '적중률과 누적수익률이\n모두 높았던 종목은?', 'S'),
    SwpTop('2', 'WIN', '적중률과 수익난 매매\n모두 높았던 종목은?', 'S'),
  ];
  int _topIndex = 0;
  String _strDiv = 'AVG';
  String _bsType = 'B';
  ListSort selectSort = ListSort.SORT_A;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StkCatchTopPage.TAG_NAME,
    );

    _userId = appGlobal.userId;
    _strDiv = appGlobal.pageData.isNotEmpty ? appGlobal.pageData : 'AVG';
    if (_userId != '') {
      if (_strDiv == 'AVG') {
        _requestStkCatch02('AVG', 'S');
      } else if (_strDiv == 'SUM') {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _swiperTopController.move(
            1,
            animation: true,
          );
        });
      } else if (_strDiv == 'WIN') {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _swiperTopController.move(
            2,
            animation: true,
          );
        });
      } else {
        _strDiv == 'AVG';
        _requestStkCatch02('AVG', 'S');
      }
    }
  }

  @override
  void dispose() {
    _swiperTopController?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
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
          '성과 TOP 종목캐치',
          RColor.yonbora2,
          Colors.black,
          0,
          [
            _isPushOnTop
                ? IconButton(
                    iconSize: 22,
                    icon: const ImageIcon(
                      AssetImage('images/rassibs_btn_icon.png'),
                      color: RColor.jinbora,
                    ),
                    onPressed: () => _showDialogPushStatus(true, '성과 TOP'),
                  )
                : IconButton(
                    iconSize: 22,
                    icon: const ImageIcon(
                      AssetImage('images/rassibs_btn_mute.png'),
                      color: RColor.jinbora,
                    ),
                    onPressed: () => _showDialogPushStatus(false, '성과 TOP'),
                  ),
          ],
        ),
        // ListView 는 스크롤할때마다 다시 렌더링 되어 Swiper 상태값이 초기화된다.
        // ListView 대신 Column 으로 감싸고 SingleChildScrollView 에 얹어서 해결
        body: SingleChildScrollView(
          child: Column(
            children: [
              // === 성과 TOP 종목캐치 ===
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    color: RColor.yonbora2,
                  ),
                  _setCatchTopSwiper(),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              AppGlobal().isPremium ? _setCatchTopList() : _setFreeView(),
            ],
          ),
        ),
      ),
    );
  }

  //swiper 성과 TOP 종목캐치
  Widget _setCatchTopSwiper() {
    bool bSelectA = (_swpTopList[_topIndex].selTab == 'S');

    return SizedBox(
      height: 235,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/main_hnr_win_trade.png',
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
                  height: 10.0,
                ),
                Text(
                  _swpTopList[_topIndex].swpDesc,
                  style: TStyle.content17T,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                _setSelectCatchTab(_topIndex, bSelectA),
              ],
            ),
          ),

          //성과TOP Swiper 부분
          Row(
            children: [
              const Expanded(
                child: SizedBox(
                  width: 1,
                  height: 90,
                ),
              ),
              Expanded(
                child: SizedBox(
                  // color: RColor.jinbora_tran,
                  height: 70,
                  child: Swiper(
                    controller: _swiperTopController,
                    loop: false,
                    itemCount: _swpTopList.length,
                    onIndexChanged: (int index) {
                      setState(() {
                        _listData.clear();
                        _strDiv = _swpTopList[index].swpCode;
                        _topIndex = index;
                      });
                      _requestStkCatch02(_strDiv, _swpTopList[index].selTab);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _getSwiperTopItem(_topIndex);
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
                  DLog.d(StkCatchTopPage.TAG,
                      'Swip index : ${_swiperTopController.event}');
                  _swiperTopController.previous(animation: true);
                },
              ),
              const SizedBox(
                height: 100,
                child: Text(''),
              ),
              IconButton(
                icon: Image.asset('images/main_jm_aw_r_g.png'),
                onPressed: () {
                  DLog.d(StkCatchTopPage.TAG,
                      'Swip index : ${_swiperTopController.index}');
                  _swiperTopController.next(animation: true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Swiper 아이템 (성과Top)
  Widget _getSwiperTopItem(int idx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 20.0,
        ),
        _setSelectTopImg(_swpTopList[idx].swpSn),
      ],
    );
  }

  Widget _setSelectTopImg(String strSn) {
    if (strSn == '0') {
      return Image.asset(
        'images/main_hnr_acc_ratio.png',
        height: 70,
        fit: BoxFit.contain,
      );
    } else if (strSn == '1') {
      return Image.asset(
        'images/main_hnr_max_ratio.png',
        height: 70,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        'images/main_hnr_avg_ratio.png',
        height: 70,
        fit: BoxFit.contain,
      );
    }
  }

  //성과 TOP 종목캐지 선택탭
  Widget _setSelectCatchTab(int idx, bool bSelectA) {
    bool bSelectB = !bSelectA;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: Container(
              height: 38,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(5),
              decoration: bSelectA
                  ? UIStyle.boxBtnSelectedSell()
                  : UIStyle.boxRoundLine20(),
              child: Center(
                child: Text(
                  '관망 상태',
                  style: bSelectA ? TStyle.btnTextWht15 : TStyle.commonTitle15,
                ),
              ),
            ),
            onTap: () {
              if (bSelectB) {
                setState(() {
                  _listData.clear();
                  _swpTopList[idx].selTab = 'S';
                  _bsType = 'S';
                });
                DLog.d(StkCatchTopPage.TAG, 'Select 관망상태');
                _requestStkCatch02(_strDiv, _bsType);
              }
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: Container(
              height: 38,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(5),
              decoration: bSelectB
                  ? UIStyle.boxBtnSelectedSell()
                  : UIStyle.boxRoundLine20(),
              child: Center(
                child: Text(
                  '최근 3일 매수',
                  style: bSelectB ? TStyle.btnTextWht15 : TStyle.commonTitle15,
                ),
              ),
            ),
            onTap: () {
              if (bSelectA) {
                setState(() {
                  _listData.clear();
                  _swpTopList[idx].selTab = 'B';
                  _bsType = 'B';
                });
                DLog.d(StkCatchTopPage.TAG, 'Select 최근 3일 매수');
                _requestStkCatch02(_strDiv, _bsType);
              }
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  // 캐치 TOP 종목 리스트
  Widget _setCatchTopList() {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: _listData.length,
        itemBuilder: (context, index) {
          return TileStkCatch02(_listData[index]);
        },
      ),
    );
  }

  Widget _setFreeView() {
    return Column(
      children: [
        _listData.isNotEmpty ? TileStkCatch02(_listData[0]) : _setFreeCard(),
        _setFreeCard(),
        _setFreeCard(),
        _setFreeCard(),
      ],
    );
  }

  //결제하지 않은 회원
  Widget _setFreeCard() {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 7,
        ),
        padding: const EdgeInsets.all(20.0),
        decoration: UIStyle.boxRoundLine6bgColor(
          Colors.white,
        ),
        child: Column(
          children: [
            Image.asset(
              'images/img_question_icon.png',
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 15.0,
            ),
            const Text(
              '프리미엄으로 업그레이드 하시고\n지금 모든 종목을 확인해 보세요.',
              style: TStyle.defaultContent,
            ),
          ],
        ),
      ),
      onTap: () {
        if (Platform.isIOS) {
          _navigateRefreshPay(PayPremiumPage());
        } else {
          _navigateRefreshPay(PayPremiumAosPage());
        }
      },
    );
  }

  void _requestStkCatch02(String tType, String flag) {
    DLog.d(StkCatchTopPage.TAG, '[$tType|$flag]');
    _fetchPosts(
        TR.STKCATCH02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': tType, //AVG|SUM|WIN
          'tradeFlag': flag, //B|S
        }));
  }

  _navigateDataRefresh(
      BuildContext context, Widget instance, PgData pgData) async {
    final result =
        await Navigator.push(context, CustomNvRouteClass.createRoute(instance));
    if (result == 'cancel') {
      DLog.d(StkCatchTopPage.TAG, '*** ***');
    } else {
      DLog.d(StkCatchTopPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.PUSH04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
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
                    '$title$descTxt',
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
                            
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateDataRefresh(context,
                          const NotificationSettingN(), PgData(pgData: ''));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _navigateRefreshPay(Widget instance) async {
    final result =
        await Navigator.push(context, CustomNvRouteClass.createRoute(instance));
    if (result == 'cancel') {
      DLog.d(SliverStockCatchWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverStockCatchWidget.TAG, '*** navigateRefresh');
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(StkCatchTopPage.TAG, '$trStr $json');

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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(StkCatchTopPage.TAG, response.body);

    if (trStr == TR.STKCATCH02) {
      final TrStkCatch02 resData =
          TrStkCatch02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        StkCatch02 topData = resData.retData;
        _listData..addAll(topData.stkList);
        setState(() {});
      }
    } else if (trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Push04 item = resData.retData;
        if (item.catchTopYn == 'Y')
          _isPushOnTop = true;
        else
          _isPushOnTop = false;

        setState(() {});
      }
    }
  }
}

enum ListSort { SORT_A, SORT_B }
