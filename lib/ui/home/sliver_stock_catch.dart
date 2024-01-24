import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_find/tr_find01.dart';
import 'package:rassi_assist/models/tr_find/tr_find07.dart';
import 'package:rassi_assist/models/tr_find/tr_find09.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:rassi_assist/models/tr_stk_catch01.dart';
import 'package:rassi_assist/models/tr_stk_catch02.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_m_page.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:rassi_assist/ui/sub/stk_catch_big.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sub/condition_page.dart';
import '../sub/stk_catch_top.dart';

/// 2022.04.20
/// 홈_종목캐치(sliver)
class SliverStockCatchWidget extends StatefulWidget {
  static const routeName = '/page_stockcatch_sliver';
  static const String TAG = "[SliverStockCatchWidget] ";
  static const String TAG_NAME = '홈_종목캐치';

  static final GlobalKey<SliverStockCatchWidgetState> globalKey = GlobalKey();

  SliverStockCatchWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverStockCatchWidgetState();
}

class SliverStockCatchWidgetState extends State<SliverStockCatchWidget> {
  final _appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = '';
  bool _bInitFirst = true;

  final SwiperController _swiperBigController = SwiperController();
  final SwiperController _swiperTopController = SwiperController();
  final List<SwpBig> _swpBigList = [
    SwpBig('0', 'FRN', '라씨 매매비서와 외국인이\n함께 산 종목은?', 'images/img_foreigner.png'),
    SwpBig('1', 'ORG', '라씨 매매비서와 기관이\n함께 산 종목은?', 'images/img_inst.png'),
  ]; //외국인, 기관
  final List<SwpTop> _swpTopList = [
    SwpTop('0', 'AVG', '적중률과 평균수익률이\n모두 높았던 종목은?', 'S'),
    SwpTop('1', 'SUM', '적중률과 누적수익률이\n모두 높았던 종목은?', 'S'),
    SwpTop('2', 'WIN', '적중률과 수익난 매매횟수가\n모두 높았던 종목은?', 'S'),
  ];

  bool _isPushOnBig = true;
  bool _isPushOnTop = true;
  final List<CatchSigInfo> _stkCatchBigList = []; //큰손 리스트
  int _bigIndex = 0;
  String _bigDiv = '';
  final List<CatchStock> _stkCatchTopList = []; //TOP 리스트
  int _topIndex = 0;
  String _topDiv = 'AVG';
  String _bsType = 'B';

  final List<Find01> _listFind01 = [];
  final List<Find07> _listFind07 = [];
  final List<Find09> _listFind09 = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverStockCatchWidget.TAG_NAME);
    _userId = _appGlobal.userId;
    _loadPrefData().then((_) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _fetchPosts(
          TR.STKCATCH01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': 'FRN',
          }));
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            SingleChildScrollView(
              child: Column(
                children: [
                  // ===== 큰손들 종목캐치 =====
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        color: RColor.yonbora2,
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          _setBigHeader(),
                          _appGlobal.isPremium
                              ? _setBigHList()
                              : Column(
                                  children: [
                                    _stkCatchBigList.isNotEmpty
                                        ? TileStkCatch01M.gen(
                                            _stkCatchBigList[0],
                                            _bigDiv,
                                          )
                                        : _setFreeCard(),
                                    _setFreeCard(),
                                    _setFreeCard(),
                                    _setFreeCard(),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),

                  //_setMoreButton('+ 함께 산 ', 'catch_big', '종목 더보기'),
                  CommonView.setBasicMoreRoundBtnView(
                    [
                      Text(
                        "+ 함께 산",
                        style: TStyle.puplePlainStyle(),
                      ),
                      const Text(
                        " 종목 더보기",
                        style: TStyle.commonSTitle,
                      ),
                    ],
                    () {
                      _appGlobal.pageData = _bigDiv;
                      Navigator.pushNamed(context, StkCatchBigPage.routeName,
                          arguments: PgData(pgSn: ''));
                    },
                  ),

                  const SizedBox(
                    height: 40.0,
                  ),

                  // ===== 성과 TOP 종목캐치 =====
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 350,
                        color: RColor.yonbora2,
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          _setCatchTopSwiper(),
                          const SizedBox(
                            height: 10,
                          ),
                          _appGlobal.isPremium
                              ? _setCatchTopList(context)
                              : Column(
                                  children: [
                                    _stkCatchTopList.isNotEmpty
                                        ? TileStkCatch02(_stkCatchTopList[0])
                                        : _setFreeCard(),
                                    _setFreeCard(),
                                    _setFreeCard(),
                                    _setFreeCard(),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  CommonView.setBasicMoreRoundBtnView(
                    [
                      Text(
                        "+ 성과TOP종목",
                        style: TStyle.puplePlainStyle(),
                      ),
                      const Text(
                        " 더보기",
                        style: TStyle.commonSTitle,
                      ),
                    ],
                    () {
                      switch (_topIndex) {
                        case 0:
                          _appGlobal.pageData = 'AVG';
                          break;
                        case 1:
                          _appGlobal.pageData = 'SUM';
                          break;
                        case 2:
                          _appGlobal.pageData = 'WIN';
                          break;
                        default:
                          _appGlobal.pageData = 'AVG';
                      }
                      Navigator.pushNamed(
                        context,
                        StkCatchTopPage.routeName,
                        arguments: PgData(pgSn: ''),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),

                  // === 조건탐색캐치 ===
                  Container(
                    color: RColor.bgWeakGrey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          '조건 탐색 캐치',
                          style: TStyle.defaultTitle,
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        _setSubTitleMore("최근 3일 매수 후 급등 종목",
                            RString.desc_find_01_sub, 'CUR_B'),
                        _setTopRising(context),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _setSubTitleMore("평균 보유 기간이 짧은 종목",
                            RString.desc_find_07_sub, 'SHT_S'),
                        _setFind07List(context),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _setSubTitleMore("주간 토픽 중 최근 매수 종목",
                            RString.desc_find_09_sub, 'TPC_S'),
                        _setFind09List(context),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '다양한 조건으로\n다른 종목들도 찾아보세요',
                                style: TStyle.commonTitle15,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  /* child: _setMoreButton(
                                  '→ 조건 ', 'condition', '모두 보기'),*/
                                  child: CommonView.setBasicMoreRoundBtnView(
                                    [
                                      Text(
                                        "→ 조건 ",
                                        style: TStyle.puplePlainStyle(),
                                      ),
                                      const Text(
                                        " 모두 보기",
                                        style: TStyle.commonSTitle,
                                      ),
                                    ],
                                    () {
                                      Navigator.pushNamed(
                                        context,
                                        ConditionPage.routeName,
                                        arguments: PgData(pgSn: ''),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        )
      ],
    );
  }

  // 큰손들의 종목캐치
  Widget _setBigHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  height: 1.0,
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  '큰손들의 종목 캐치',
                  style: TStyle.defaultTitle,
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: RColor.purpleBasic_6565ff,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'images/icon_rassi_logo_white.png',
                        fit: BoxFit.contain,
                      ),
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
                    //Swiper 영역
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
                  _swpBigList[_bigIndex].swpDesc,
                  style: TStyle.content18T,
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
                  height: 180,
                ),
              ),
              Expanded(
                child: SizedBox(
                  // color: RColor.jinbora_tran,
                  height: 70,
                  child: Swiper(
                    controller: _swiperBigController,
                    loop: false,
                    itemCount: _swpBigList.length,
                    onIndexChanged: (int index) {
                      setState(() {
                        _stkCatchBigList.clear();
                        _bigIndex = index;
                      });
                      _fetchPosts(
                          TR.STKCATCH01,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                            'selectDiv': _swpBigList[index].swpCode,
                          }));
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
                  DLog.d(SliverStockCatchWidget.TAG,
                      'Swip index : ${_swiperBigController.event}');
                  _swiperBigController.previous(animation: true);
                },
              ),
              const SizedBox(
                height: 175,
                child: Text(''),
              ),
              IconButton(
                icon: Image.asset('images/main_jm_aw_r_g.png'),
                onPressed: () {
                  DLog.d(SliverStockCatchWidget.TAG,
                      'Swip index : ${_swiperBigController.index}');
                  _swiperBigController.next(animation: true);
                },
              ),
            ],
          ),

          //알림 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: _isPushOnBig,
                child: IconButton(
                  iconSize: 22,
                  icon: const ImageIcon(
                    AssetImage('images/rassibs_btn_icon.png'),
                    color: RColor.jinbora,
                  ),
                  onPressed: () => _selectDialogPush(true, '종목 캐치'),
                ),
              ),
              Visibility(
                visible: !_isPushOnBig,
                child: IconButton(
                  iconSize: 22,
                  icon: const ImageIcon(
                    AssetImage('images/rassibs_btn_mute.png'),
                    color: RColor.jinbora,
                  ),
                  onPressed: () => _selectDialogPush(false, '종목 캐치'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectDialogPush(bool onoff, String title) {
    _appGlobal.isPremium
        ? _showDialogPushStatus(onoff, title)
        : _showDialogPremium();
  }

  //Swiper 아이템 (큰손)
  Widget _getSwiperBhItem(int idx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 20.0,
        ),
        _setSelectImg(_swpBigList[idx].swpSn),
      ],
    );
  }

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

  // 큰손들 종목 리스트
  Widget _setBigHList() {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: _stkCatchBigList.length,
        itemBuilder: (context, index) {
          return TileStkCatch01M.gen(_stkCatchBigList[index], _bigDiv);
        },
      ),
    );
  }

  //swiper 성과 TOP 종목캐치
  Widget _setCatchTopSwiper() {
    bool bSelectA = (_swpTopList[_topIndex].selTab == 'S');
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const Text(
                  '성과 TOP 종목 캐치',
                  style: TStyle.defaultTitle,
                ),
                const SizedBox(
                  height: 15,
                ),
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
                  style: TStyle.content18T,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 15.0,
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
                height: 170,
              )),
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
                        _stkCatchTopList.clear();
                        _topDiv = _swpTopList[index].swpCode;
                        _topIndex = index;
                      });
                      _requestStkCatch02(_topDiv, _swpTopList[index].selTab);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _getSwiperTopItem(index);
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
                  DLog.d(SliverStockCatchWidget.TAG,
                      'Swip index : ${_swiperTopController.event}');
                  _swiperTopController.previous(animation: true);
                },
              ),
              const SizedBox(
                height: 170,
              ),
              IconButton(
                icon: Image.asset('images/main_jm_aw_r_g.png'),
                onPressed: () {
                  DLog.d(SliverStockCatchWidget.TAG,
                      'Swip index : ${_swiperTopController.index}');
                  _swiperTopController.next(animation: true);
                },
              ),
            ],
          ),

          //성과 TOP 알림 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: _isPushOnTop,
                child: IconButton(
                  iconSize: 22,
                  icon: const ImageIcon(
                    AssetImage('images/rassibs_btn_icon.png'),
                    color: RColor.jinbora,
                  ),
                  onPressed: () => _selectDialogPush(true, '성과 TOP'),
                ),
              ),
              Visibility(
                visible: !_isPushOnTop,
                child: IconButton(
                  iconSize: 22,
                  icon: const ImageIcon(
                    AssetImage('images/rassibs_btn_mute.png'),
                    color: RColor.jinbora,
                  ),
                  onPressed: () => _selectDialogPush(false, '성과 TOP'),
                ),
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
        _setSelectTopImg(_swpTopList[_topIndex].swpSn),
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

  //성과 TOP 종목캐치 선택탭
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
                  _stkCatchTopList.clear();
                  _swpTopList[idx].selTab = 'S';
                  _bsType = 'S';
                });
                _requestStkCatch02(_topDiv, _bsType);
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
                  _stkCatchTopList.clear();
                  _swpTopList[idx].selTab = 'B';
                  _bsType = 'B';
                });
                DLog.d(SliverStockCatchWidget.TAG, 'Select 최근 3일 매수');
                _requestStkCatch02(_topDiv, _bsType);
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

  //성과 TOP 종목 리스트
  Widget _setCatchTopList(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: _stkCatchTopList.length,
        itemBuilder: (context, index) {
          return TileStkCatch02(_stkCatchTopList[index]);
        },
      ),
    );
  }

  // 소항목 타이틀 (+ 더보기)
  Widget _setSubTitleMore(String subTitle, String desc, String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subTitle,
                style: TStyle.commonTitle15,
              ),
              InkWell(
                child: SizedBox(
                  height: 16,
                  child: Image.asset(
                    'images/rassi_icon_more_pink.gif',
                    height: 15,
                  ),
                ),
                onTap: () {
                  if (type == 'CUR_B') {
                    // FIND01 - 3일내에 매수 후 급등
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'CUR_B') {
                    // FIND01 - 3일내에 매수 후 급등
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'HIT_H') {
                    // FIND02 - 적중률 높은 최근 매수
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'HIT_W') {
                    // FIND03 - 적중률 높은 최근 관망
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'AVG_H') {
                    // FIND04 - 평균수익률 높은 최근 매수
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'AVG_W') {
                    // FIND05 - 평균수익률 높은 관망
                    basePageState.callPageRouteData(
                        const SignalMTopPage(), PgData(pgData: type));
                  } else if (type == 'SHT_S') {
                    // FIND07 - 평균보유 기간이 찗은 종목
                    if (_appGlobal.isPremium) {
                      basePageState.callPageRouteData(
                          const SignalMTopPage(), PgData(pgData: type));
                    } else {
                      _showDialogPremium();
                    }
                  } else if (type == 'TPC_S') {
                    // FIND09 - 주간 토픽중 최근 매수 종목
                    if (_appGlobal.isPremium) {
                      basePageState.callPageRouteData(
                          const SignalMTopPage(), PgData(pgData: type));
                    } else {
                      _showDialogPremium();
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            desc,
            style: TStyle.textGrey15,
          ),
        ],
      ),
    );
  }

  // Find01 - 최근 매수 급등 종목
  Widget _setTopRising(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: _listFind01.length,
          itemBuilder: (context, index) {
            return TileFind01(_listFind01[index]);
          }),
    );
  }

  // Find07 - 평균보유기간이 짧은 종목
  Widget _setFind07List(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: _listFind07.length,
          itemBuilder: (context, index) {
            return TileFind07(_listFind07[index]);
          }),
    );
  }

  // FIND09 - 주간 토픽중 최근 매수 종목
  Widget _setFind09List(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: _listFind09.length,
          itemBuilder: (context, index) {
            return TileFind09(_listFind09[index]);
          }),
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
          _navigateRefreshPay(context, const PayPremiumPage());
        } else {
          _navigateRefreshPay(context, const PayPremiumAosPage());
        }
      },
    );
  }

  // 데이터 없음
  Widget _setNoDataCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        height: 200,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 7.0, bottom: 7.0),
        padding: const EdgeInsets.all(10.0),
        decoration: UIStyle.boxWithOpacity(),
        child: const Text(
          '발생한 종목이 없습니다.',
          style: TStyle.content17T,
        ),
      ),
    );
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

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(SliverStockCatchWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverStockCatchWidget.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.USER04,
      //     jsonEncode(<String, String>{
      //       'userId': _userId,
      //     }));
    }
  }

  _navigateDataRefresh(
      BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(SliverStockCatchWidget.TAG, '*** ***');
    } else {
      DLog.d(SliverStockCatchWidget.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.PUSH04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //프리미엄 가입하기 다이얼로그
  void _showDialogPremium() {
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
                Image.asset(
                  'images/rassibs_img_infomation.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '안내',
                  style: TStyle.title20,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '매매비서 프리미엄에서\n이용할 수 있는 정보입니다.',
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '프리미엄으로 업그레이드 하시고 더 완벽하게 이용해 보세요.',
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.deepBlue,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Center(
                        child: Text(
                          '프리미엄 가입하기',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (Platform.isIOS) {
                      _navigateRefreshPay(context, const PayPremiumPage());
                    } else {
                      _navigateRefreshPay(context, const PayPremiumAosPage());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestStkCatch02(String tType, String flag) {
    DLog.d(SliverStockCatchWidget.TAG, '[$tType|$flag]');
    _fetchPosts(
        TR.STKCATCH02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': tType, //AVG|SUM|WIN
          'tradeFlag': flag, //B|S
        }));
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

  reload() {
    _fetchPosts(
        TR.STKCATCH01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': 'FRN',
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverStockCatchWidget.TAG, '$trStr $json');

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
      DLog.d(SliverStockCatchWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverStockCatchWidget.TAG, 'ERR : SocketException');
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverStockCatchWidget.TAG, response.body);

    if (trStr == TR.STKCATCH01) {
      _stkCatchBigList.clear();
      final TrStkCatch01 resData =
          TrStkCatch01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        StkCatch01 scData = resData.retData;
        _bigDiv = scData.selectDiv;
        if (scData.timeList.isNotEmpty) {
          if (scData.timeList[0].sigList.length > 4) {
            _stkCatchBigList.addAll(scData.timeList[0].sigList.getRange(0, 5));
          } else {
            _stkCatchBigList.addAll(scData.timeList[0].sigList);
            int len = scData.timeList[0].sigList.length;
            //목록이 5개가 안될 경우 이전 날짜에서 가져와서 채운다.
            if (scData.timeList.length > 1) {
              int subLen = scData.timeList[1].sigList.length;
              if (subLen > 0 && subLen > (4 - len)) {
                _stkCatchBigList
                    .addAll(scData.timeList[1].sigList.getRange(0, 5 - len));
              } else {
                _stkCatchBigList.addAll(scData.timeList[1].sigList);
              }
            }
          }
        }
        setState(() {});
      }

      if (_bInitFirst) {
        _requestStkCatch02('AVG', 'S');
      }
    } else if (trStr == TR.STKCATCH02) {
      _stkCatchTopList.clear();
      final TrStkCatch02 resData =
          TrStkCatch02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        StkCatch02 topData = resData.retData;
        if (topData.stkList.isNotEmpty) {
          if (topData.stkList.length > 5) {
            _stkCatchTopList.addAll(topData.stkList.getRange(0, 5));
          } else {
            _stkCatchTopList.addAll(topData.stkList);
          }
        }
      }

      setState(() {});

      _fetchPosts(TR.FIND01,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND01) {
      _bInitFirst = false;

      final TrFind01 resData = TrFind01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find01> list = resData.listData;
        setState(() {
          _listFind01.clear();
          _listFind01.addAll(list);
        });
      }

      _fetchPosts(TR.FIND07,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND07) {
      final TrFind07 resData = TrFind07.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find07> list = resData.listData;
        setState(() {
          _listFind07.clear();
          _listFind07.addAll(list);
        });
      }

      _fetchPosts(
          TR.FIND09,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '50',
          }));
    }

    //주간토픽 중 최근 매수 종목 (FIND09)
    else if (trStr == TR.FIND09) {
      final TrFind09 resData = TrFind09.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find09> list = resData.listData;
        setState(() {
          _listFind09.clear();
          _listFind09.addAll(list);
        });
      }

      _fetchPosts(
          TR.PUSH04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Push04 item = resData.retData;
        if (item.catchBighandYn == 'Y') {
          _isPushOnBig = true;
        } else {
          _isPushOnBig = false;
        }
        if (item.catchTopYn == 'Y') {
          _isPushOnTop = true;
        } else {
          _isPushOnTop = false;
        }

        setState(() {});
      }
    }
  }
}

class SwpBig {
  final String swpSn;
  final String swpCode;
  final String swpDesc;
  final String imgPath;

  SwpBig(this.swpSn, this.swpCode, this.swpDesc, this.imgPath);
}

class SwpTop {
  final String swpSn;
  final String swpCode;
  final String swpDesc;
  String selTab;

  SwpTop(
    this.swpSn,
    this.swpCode,
    this.swpDesc,
    this.selTab,
  );
}
