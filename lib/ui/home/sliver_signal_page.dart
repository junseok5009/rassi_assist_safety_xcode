import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_info.dart';
import 'package:rassi_assist/models/tr_catch01.dart';
import 'package:rassi_assist/models/tr_find/tr_find01.dart';
import 'package:rassi_assist/models/tr_find/tr_find02.dart';
import 'package:rassi_assist/models/tr_find/tr_find03.dart';
import 'package:rassi_assist/models/tr_find/tr_find04.dart';
import 'package:rassi_assist/models/tr_find/tr_find05.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_search/tr_search04.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal05.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal09.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/catch_list_page.dart';
import 'package:rassi_assist/ui/news/catch_viewer.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/signal/signal_board_page.dart';
import 'package:rassi_assist/ui/signal/signal_pop_list_page.dart';
import 'package:rassi_assist/ui/signal/signal_today_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_m_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2022.04.20
/// AI 매매신호(sliver)
class SliverSignalWidget extends StatefulWidget {
  static const routeName = '/page_signal_sliver';
  static const String TAG = "[SliverSignalWidget]";
  static const String TAG_NAME = '홈_AI매매신호';
  static final GlobalKey<SliverSignalWidgetState> globalKey = GlobalKey();

  SliverSignalWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverSignalWidgetState();
}

class SliverSignalWidgetState extends State<SliverSignalWidget> {
  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = '';

  String _emptyString = '매매신호를 수신중 입니다.';
  String _strBuy = '';
  String _strSell = '';
  String _strTime = '';
  bool _bIsTrading = false;
  String _catchTitle = '';
  String _catchSn = '';

  bool _isFreeVisible = true;
  List<HonorData> honorList = [];

  //인공지능 시그널 발생 현황
  bool _isReqComplete = false;
  String _engineStr1 = '';
  String _engineStr2 = '';
  String _engineStatus = '';
  String _strLottie = 'assets/41561-machine-learning.json';
  bool _isBeforeTime = false;
  bool _isVisibleTimer = false;
  final List<String> _preStartStr = [
    '학습 정보 Update',
    'Today 시세마스터 생성',
    '미거래/매매금지 종목 Filtering',
    '신규 종목 Confirm',
    '거래 종목 fixed',
    '종목 정보/분석 Update',
    'Dashboard Reset',
    'Start Trading Standby',
  ];
  Timer? countTimer;
  int minute = 0;
  int second = 0;

  List<StockInfo> _popularList = [];
  final List<Find01> _listFind01 = [];
  final List<Find02> _listFind02 = [];
  final List<Find03> _listFind03 = [];
  final List<Find04> _listFind04 = [];
  final List<Find05> _listFind05 = [];

  List<Stock> _catchStkList = [];

  bool prTOP = false, prHGH = false, prMID = false, prLOW = false;
  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];

  //note  타이머로 시그널이 갱신될때 swiper 내용도 갱신되지 않도록 주의
  //note  swiper 내용은 페이지 만들어질때만 구현
  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SliverSignalWidget.TAG_NAME,
    );
    _loadPrefData().then((_) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _curProd = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
      reload();
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    countTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 오늘의 AI 매매신호 현황
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 125,
                    color: RColor.bgbora,
                  ),
                  _setStatus(),
                ],
              ),

              // AI 는 현재 ...
              Visibility(
                visible: _isReqComplete,
                child: _setAnalStatus(),
              ),
              Visibility(
                visible: !_isReqComplete,
                child: Container(
                  height: 85.0,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: RColor.bgWeakGrey,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text(''),
                ),
              ),

              _setPrTop(),

              _setSubTitle("지금 인기 종목들은"),
              _setPopularList(context),

              const SizedBox(
                height: 15.0,
              ),

              CommonView.setBasicMoreRoundBtnView(
                [
                  Text(
                    "+ 인기종목",
                    style: TStyle.puplePlainStyle(),
                  ),
                  const Text(
                    " 더보기",
                    style: TStyle.commonSTitle,
                  ),
                ],
                () {
                  basePageState.callPageRoute(const SignalPopListPage());
                },
              ),

              const SizedBox(
                height: 10.0,
              ),

              //라씨 매매비서의 주간토픽
              _setWeeklyTopic(),

              _setPrHigh(),

              // -------------------------------------------------------
              _setSubTitle("특정 조건 종목들은"),
              const SizedBox(
                height: 10.0,
              ),

              _setSubTitleMore(
                  "  최근 3일 매수 후 급등 종목", TStyle.commonTitle15, 'CUR_B'),
              _setTopRising(),

              _setSubTitleMore(
                  "  적중률 TOP 중 최근 3일 매수 종목", TStyle.commonTitle15, 'HIT_H'),
              _setTopHitHolding(),

              _setSubTitleMore(
                  "  적중률 TOP 중 관망 종목", TStyle.commonTitle15, 'HIT_W'),
              _setTopHitWatching(context),

              _setSubTitleMore(
                  "  평균수익률 TOP 중 최근 3일 매수 종목", TStyle.commonTitle15, 'AVG_H'),
              _setTopAvgHolding(context),

              _setSubTitleMore(
                  "  평균수익률 TOP 중 관망 종목", TStyle.commonTitle15, 'AVG_W'),
              _setTopAvgWatching(context),

              const SizedBox(
                height: 10.0,
              ),
              _setPrMid(),

              // -------------------------------------------------------
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '성과 TOP 종목',
                      style: TStyle.defaultTitle,
                    ),
                    InkWell(
                      child: const ImageIcon(
                        AssetImage(
                          'images/rassi_icon_qu_bl.png',
                        ),
                        size: 22,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showDialogTopDesc();
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 7.0,
              ),
              _setBoxBtn('적중률', 'images/main_hnr_win_trade.png', 'HIT'),
              _setBoxBtn('수익난 매매', 'images/main_hnr_avg_ratio.png', 'PRF'),
              _setBoxBtn('누적수익률', 'images/main_hnr_max_ratio.png', 'STA'),
              _setBoxBtn('최대수익률', 'images/main_hnr_win_ratio.png', 'MAX'),
              _setBoxBtn('평균수익률', 'images/main_hnr_acc_ratio.png', 'AVG'),

              const SizedBox(
                height: 30.0,
              ),

              // 매매신호 종합 분석 보드 배너
              InkWell(
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xfff97a7c),
                        Color(0xfff9997b),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '매매신호 종합 분석 보드',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '매매신호 현황과\n시장과의 관계를 분석해 보세요.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25.0)),
                            ),
                            child: const Text(
                              '자세히보기',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'images/rstm_today_07.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  basePageState.callPageRouteUpData(
                      SignalBoardPage(), PgData(pgData: _curProd));
                },
              ),

              const SizedBox(
                height: 3.0,
              ),

              _setPrLow(),
            ]),
          ),
        ],
      ),
    );
  }

  // 소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  // 소항목 타이틀 (+ 더보기)
  Widget _setSubTitleMore(String subTitle, TextStyle textStyle, String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subTitle,
            style: textStyle,
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
              if (_isFreeVisible) {
                if (type == 'CUR_B') {
                  //3일내에 매수 후 급등 (FIND01)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                } else {
                  _navigateRefresh(
                      context,
                      Platform.isIOS
                          ? const PayPremiumPage()
                          : const PayPremiumAosPage());
                }
              } else {
                if (type == 'CUR_B') {
                  //3일내에 매수 후 급등 (FIND01)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                } else if (type == 'HIT_H') {
                  //적중률 높은 최근 매수 (FIND02)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                } else if (type == 'HIT_W') {
                  //적중률 높은 최근 관망 (FIND03)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                } else if (type == 'AVG_H') {
                  //평균수익률 높은 최근 매수 (FIND04)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                } else if (type == 'AVG_W') {
                  //평균수익률 높은 관망 (FIND05)
                  basePageState.callPageRouteData(
                      const SignalMTopPage(), PgData(pgData: type));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  //오늘의 AI 매매신호 현황
  Widget _setStatus() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      decoration: UIStyle.boxRoundLine6bgColor(Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 AI매매신호 현황',
                style: TStyle.commonTitle,
              ),
              Row(
                children: [
                  Text(
                    _strTime,
                    style: TStyle.textSGrey,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Image.asset(
                    'images/rassi_icon_hold_wch.png',
                    height: 12,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: _bIsTrading,
            child: _setSignalStatus(),
          ),
          const SizedBox(
            height: 10,
          ),
          //TOP 종목에서 새로운 신호 발생
          Visibility(
            visible: honorList.isNotEmpty,
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: Swiper(
                  loop: honorList.length > 1 ? true : false,
                  autoplay: honorList.length > 1 ? true : false,
                  autoplayDelay: 4000,
                  itemCount: honorList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TileSigStatus(honorList[index]);
                  }),
            ),
          ),

          Visibility(
            visible: !_bIsTrading,
            child: SizedBox(
              height: 105,
              child: Center(
                child: Text(
                  _emptyString,
                  style: TStyle.textGrey15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //매수, 매도
  Widget _setSignalStatus() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '매수',
              style: TStyle.subTitle,
            ),
            _setCircleText(_strBuy, RColor.sigBuy, 'B'),
            _setCircleText(_strSell, RColor.sigSell, 'S'),
            const Text(
              '매도',
              style: TStyle.subTitle,
            ),
          ],
        ),
      ],
    );
  }

  //매수, 매도 Count
  Widget _setCircleText(String cnt, Color color, String tradeFlag) {
    return InkWell(
      child: Container(
        width: 70.0,
        height: 70.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            cnt,
            style: const TextStyle(
              //버튼 화이트 텍스트 20
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Color(0xffEFEFEF),
            ),
          ),
        ),
      ),
      onTap: () {
        if (_curProd.contains('ac_pr')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignalTodayPage(),
                settings: RouteSettings(
                  arguments: PgData(userId: '', flag: tradeFlag, pgData: cnt),
                ),
              ));
        } else {
          _showDialogPremium(); //프리미엄 가입하기
        }
        DLog.d(SliverSignalWidget.TAG, '#Current Prod : $_curProd');
      },
    );
  }

  //AI 는 분석중
  Widget _setAnalStatus() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: RColor.bgWeakGrey,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _engineStr1,
                  style: TStyle.title17,
                ),
                const SizedBox(
                  height: 7.0,
                ),

                Visibility(
                  visible: !_isBeforeTime,
                  child: Row(
                    children: [
                      Text(_engineStr2),
                      Visibility(
                        visible: _isVisibleTimer,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '$minute'.padLeft(2, '0'),
                              style: TStyle.commonSTitle,
                            ),
                            const Text(
                              '분',
                              style: TStyle.commonSTitle,
                            ),
                            Text(
                              '$second'.padLeft(2, '0'),
                              style: TStyle.commonSTitle,
                            ),
                            const Text(
                              '초전',
                              style: TStyle.commonSTitle,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                //장 시작전 대기... 필터중... 작업중
                Visibility(
                  visible: _isBeforeTime,
                  child: SizedBox(
                    width: 220,
                    height: 40,
                    child: Swiper(
                        loop: true,
                        autoplay: true,
                        autoplayDelay: 4000,
                        itemCount:
                            _preStartStr != null ? _preStartStr.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(_preStartStr[index]);
                        }),
                  ),
                ),
              ],
            ),
            Lottie.asset(_strLottie, height: 57),
          ],
        ),
      ),
      onTap: () {
        _showDialogProcess(_engineStatus);
      },
    );
  }

  //지금 인기 종목들은
  Widget _setPopularList(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 450,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _popularList.length,
          itemBuilder: (context, index) {
            return TileSearch04(_popularList[index]);
          }),
    );
  }

  //Catch - 매매비서의 주간토픽
  Widget _setWeeklyTopic() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "라씨 매매비서의 주간토픽",
                style: TStyle.defaultTitle,
              ),
              // Text("$_catchWeek", style: TStyle.contentMGrey,),
              _setMoreText('stock_catch'),
            ],
          ),
        ),
        InkWell(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: UIStyle.boxWeakGrey6(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/rassibs_icon_img_3.png',
                      fit: BoxFit.cover,
                      height: 40,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      _catchTitle,
                      maxLines: 2,
                      style: TStyle.subTitle,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  childAspectRatio: 4.5,
                  children: List.generate(_catchStkList.length,
                      (index) => TileStockCatch(_catchStkList[index])),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              _createRouteData(
                CatchViewer(),
                RouteSettings(
                  arguments: PgData(userId: '', pgSn: _catchSn),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  //더보기
  Widget _setMoreText(String desType) {
    return InkWell(
      child: const Padding(
        padding: EdgeInsets.only(
          right: 15,
        ),
        child: Text(
          '+더보기',
          style: TStyle.commonPurple14,
        ),
      ),
      onTap: () {
        if (desType == 'signal') {
          DefaultTabController.of(context).animateTo(1);
        } else if (desType == 'stock_catch') {
          basePageState.callPageRoute(const CatchListPage());
        }
      },
    );
  }

  //최근 매수 급등 종목 (Find01)
  Widget _setTopRising() {
    return _listFind01.isEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10,
            ),
            child: CommonView.setNoDataView(150, '최근 3일 매수 후 급등 종목이 없습니다.'),
          )
        : Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: _listFind01.length,
                itemBuilder: (context, index) {
                  return TileFind01(_listFind01[index]);
                }),
          );
  }

  //적중률 TOP 최근 매수 종목 (Find02)
  Widget _setTopHitHolding() {
    return _isFreeVisible
        ? _setFreeCard()
        : _listFind02.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: CommonView.setNoDataView(
                    150, '적중률 TOP 중 최근 3일 매수 종목이 없습니다.'),
              )
            : Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: _listFind02.length,
                    itemBuilder: (context, index) {
                      return TileFind02(_listFind02[index]);
                    }),
              );
  }

  //적중률 TOP 관망 종목
  Widget _setTopHitWatching(BuildContext context) {
    return _isFreeVisible
        ? _setFreeCard()
        : _listFind03.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: CommonView.setNoDataView(150, '적중률 TOP 중 관망 종목이 없습니다.'),
              )
            : Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: _listFind03.length,
                    itemBuilder: (context, index) {
                      return TileFind03(_listFind03[index]);
                    }),
              );
  }

  //평균수익률 TOP 최근 매수 종목 (Find04)
  Widget _setTopAvgHolding(BuildContext context) {
    return _isFreeVisible
        ? _setFreeCard()
        : _listFind04.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: CommonView.setNoDataView(
                    150, '평균수익률 TOP 중 최근 3일 매수 종목이 없습니다.'),
              )
            : Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: _listFind04.length,
                    itemBuilder: (context, index) {
                      return TileFind04(_listFind04[index]);
                    }),
              );
  }

  //평균수익률 TOP 관망 종목
  Widget _setTopAvgWatching(BuildContext context) {
    return _isFreeVisible
        ? _setFreeCard()
        : _listFind05.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child:
                    CommonView.setNoDataView(150, '평균수익률 TOP 중 관망 종목이 없습니다.'),
              )
            : Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: _listFind05.length,
                  itemBuilder: (context, index) {
                    return TileFind05(_listFind05[index]);
                  },
                ),
              );
  }

  //결제하지 않은 회원
  Widget _setFreeCard() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: UIStyle.boxRoundLine6(),
        child: SizedBox(
          width: double.infinity,
          height: 130.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/rassi_itemar_icon_ar_wch.png',
                height: 40,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                '프리미엄으로 업그레이드 하시고\n지금 모든 종목을 확인해 보세요.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _navigateRefresh(
          context,
          Platform.isIOS ? PayPremiumPage() : PayPremiumAosPage(),
        );
      },
    );
  }

  //Custom Button
  Widget _setBoxBtn(String title, String imgPath, String routeStr) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6(),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imgPath,
                  fit: BoxFit.cover,
                  height: 45,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TStyle.commonTitle,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text('TOP'),
                Text(
                  '50',
                  style: TStyle.title20,
                ),
                Text('종목'),
              ],
            )
          ],
        ),
        onTap: () {
          basePageState.callPageRouteData(
              SignalTopPage(), PgData(pgData: routeStr));
        },
      ),
    );
  }

  //프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: prTOP,
      child: Container(
        width: double.infinity,
        height: 110,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: CardProm02(_listPrTop),
      ),
    );
  }

  // 프로모션 - 상단
  Widget _setPrHigh() {
    return prHGH
        ? SizedBox(
            width: double.infinity,
            height: 110,
            child: CardProm02(_listPrHgh),
          )
        : const SizedBox(
            height: 5,
          );
  }

  //프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: prMID,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrMid)),
    );
  }

  //프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: prLOW,
      child: SizedBox(
          width: double.infinity, height: 180, child: CardProm02(_listPrLow),
      ),
    );
  }

  //AI 처리 프로세스 다이얼로그
  void _showDialogProcess(String pType) {
    String imgPath = 'images/re_img_pop_001.png';
    if (pType == 'TIME_BEFORE') {
      imgPath = 'images/re_img_pop_003.png';
    }
    //장시작 후 첫 신호 발생전까지
    else if (pType == 'TIME_OPEN') {
      imgPath = 'images/re_img_pop_004.png';
    }
    //9시 20분 첫 신호 발생부투 다음 신호 발생 정각까지 20분 단위 카운트 다운
    else if (pType == 'TIME_TERM') {
      imgPath = 'images/re_img_pop_004.png';
    }
    //9시 40분 2번째 신호 발생부터 20분/40분/60분 해당 신호대 신호 발생까지 노출
    else if (pType == 'TIME_WAIT') {
      imgPath = 'images/re_img_pop_001.png';
    } else {
      imgPath = 'images/re_img_pop_002.png';
    }

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  const Text(
                    'AI의 처리 프로세스',
                    style: TStyle.defaultTitle,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 175,
                    child: Image.asset(
                      imgPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Text(
                    'AI는 처리 프로세스에 따라 각 시점에서\n'
                    '역할을 수행하며 이 과정을 통해 최적의 매매타이밍\n'
                    'AI매매신호를 발생시켜 알려드립니다.',
                    style: TStyle.textSGrey,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                ],
              ),
            ),
          );
        });
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
                  '매매비서 프리미엄에서 이용할 수 있는 정보입니다.',
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
                    _navigateRefreshPay(
                        context,
                        Platform.isIOS
                            ? PayPremiumPage()
                            : PayPremiumAosPage());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //성과 TOP 내용 다이얼로그
  void _showDialogTopDesc() {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  height: 25.0,
                ),
                const Text(
                  '성과 TOP 종목은?',
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  RString.desc_result_top,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _navigateRefresh(BuildContext context, Widget instance) async {
    final result =
        await Navigator.push(context, CustomNvRouteClass.createRoute(instance));
    if (result == 'cancel') {
      DLog.d(SliverSignalWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverSignalWidget.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result =
        await Navigator.push(context, CustomNvRouteClass.createRoute(instance));
    if (result == 'cancel') {
      DLog.d(SliverSignalWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverSignalWidget.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

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
      DLog.d(SliverSignalWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverSignalWidget.TAG, '*** navigateRefresh');
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

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverSignalWidget.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverSignalWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverSignalWidget.TAG, 'ERR : SocketException');
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverSignalWidget.TAG, response.body);

    if (trStr == TR.USER04) {
      //탭이동을 홈으로 초기화(setState 필요)
      Provider.of<PageNotifier>(context, listen: false).setPageData(0);

      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        _setUserStatus(data);

        if (data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatusAfterPayment();
        } else {
          const AccountData().setFreeUserStatus();
        }
        setState(() {});
      } else {
        const AccountData().setFreeUserStatus();
      }

      _fetchPosts(
          TR.PROM02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'viewPage': 'LPB2',
            'promoDiv': '',
          }));
    } else if (trStr == TR.PROM02) {
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listPrTop.clear();
        _listPrHgh.clear();
        _listPrMid.clear();
        _listPrLow.clear();
        if (resData.retData.isNotEmpty) {
          for (int i = 0; i < resData.retData.length; i++) {
            Prom02 item = resData.retData[i];
            if (item.viewPosition.isNotEmpty) {
              if (item.viewPosition == 'TOP') _listPrTop.add(item);
              if (item.viewPosition == 'HGH') _listPrHgh.add(item);
              if (item.viewPosition == 'MID') _listPrMid.add(item);
              if (item.viewPosition == 'LOW') _listPrLow.add(item);
            }
          }
        }
        setState(() {
          if (_listPrTop.length > 0) prTOP = true;
          if (_listPrHgh.length > 0) prHGH = true;
          if (_listPrMid.length > 0) prMID = true;
          if (_listPrLow.length > 0) prLOW = true;
        });
      }

      _fetchPosts(
          TR.SIGNAL05,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '50',
            'includeData': 'Y'
          }));
    } else if (trStr == TR.SIGNAL05) {
      final TrSignal05 resData = TrSignal05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final Signal05 data = resData.retData;

        honorList.clear();
        if (data != null) {
          _strBuy = data.buyCount;
          _strSell = data.sellCount;
          _strTime =
              "${data.updateDttm.substring(4, 6)}/${data.updateDttm.substring(6, 8)}  ${data.updateDttm.substring(8, 10)}:${data.updateDttm.substring(10, 12)}";
          honorList.addAll(data.listHonor);
        }

        setState(() {});
      }

      _fetchPosts(
          TR.SIGNAL09,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //현재의 매매신호 현황
    else if (trStr == TR.SIGNAL09) {
      final TrSignal09 resData = TrSignal09.fromJson(jsonDecode(response.body));
      countTimer?.cancel();
      _bIsTrading = false;
      if (resData.retCode == RT.SUCCESS) {
        Signal09 item = resData.resData;
        _setParseSigStatus(item);
      }

      _fetchPosts(
          TR.SEARCH04,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': 'S',
            'selectCount': '5',
          }));
    }

    //인기종목
    else if (trStr == TR.SEARCH04) {
      final TrSearch04 resData = TrSearch04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _popularList = resData.retData.listStock;
      }

      _fetchPosts(TR.FIND01,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND01) {
      final TrFind01 resData = TrFind01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find01> list = resData.listData;
        setState(() {
          _listFind01.clear();
          _listFind01.addAll(list);
        });
      }

      _fetchPosts(TR.FIND02,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND02) {
      final TrFind02 resData = TrFind02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find02> list = resData.listData;
        setState(() {
          _listFind02.clear();
          _listFind02.addAll(list);
        });
      } else {}

      _fetchPosts(TR.FIND03,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND03) {
      final TrFind03 resData = TrFind03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find03> list = resData.listData;
        setState(() {
          _listFind03.clear();
          _listFind03.addAll(list);
        });
      } else if (resData.retCode == RT.NO_DATA) {
        setState(() {
          _listFind03.clear();
        });
      }

      _fetchPosts(TR.FIND04,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND04) {
      final TrFind04 resData = TrFind04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find04> list = resData.listData;
        setState(() {
          _listFind04.clear();
          _listFind04.addAll(list);
        });
      } else if (resData.retCode == RT.NO_DATA) {
        setState(() {
          _listFind04.clear();
        });
      }

      _fetchPosts(TR.FIND05,
          jsonEncode(<String, String>{'userId': _userId, 'selectCount': '10'}));
    } else if (trStr == TR.FIND05) {
      final TrFind05 resData = TrFind05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Find05> list = resData.listData;
        setState(() {
          _listFind05.clear();
          _listFind05.addAll(list);
        });
      }

      _fetchPosts(
          TR.CATCH01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.CATCH01) {
      final TrCatch01 resData = TrCatch01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.listStock.length > 4) {
          _catchStkList = resData.retData.listStock.sublist(0, 4);
        } else {
          _catchStkList = resData.retData.listStock;
        }
        setState(() {
          _catchTitle = resData.retData.title;
          _catchSn = resData.retData.catchSn;
        });
      }
    }
  }

  reload() {
    _fetchPosts(
      TR.USER04,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );
  }

  //회원정보 Status
  void _setUserStatus(User04 uData) {
    AccountData acData = uData.accountData;
    if (acData != null) {
      if (acData.prodName == '프리미엄') {
        _isFreeVisible = false;
      } else if (acData.prodCode == 'AC_S3') {
        _isFreeVisible = true;
      } else {
        //베이직 계정
        _isFreeVisible = true;
      }
    } else {
      //회원정보 가져오지 못함
      _isFreeVisible = true;
    }
  }

  //매매신호 현황
  _setParseSigStatus(Signal09 item) {
    if (item != null) {
      _isReqComplete = true; //기본값 노출방지
      _isVisibleTimer = false;
      _bIsTrading = (item.noticeCode != 'TIME_BEFORE' && item.noticeCode.isNotEmpty);

      //장시작 대기, 전일 미거래 종목 필터링중(08시 ~ 개장전)
      if (item.noticeCode == 'TIME_BEFORE') {
        _isBeforeTime = true;
        _engineStr1 = 'AI는 현재 데이터 처리 중';
        _engineStr2 = '';
        _strLottie = 'assets/9678-colorfull-loading.json';
      }
      //장시작 후 첫 신호 발생전까지
      else if (item.noticeCode == 'TIME_OPEN') {
        _engineStr1 = 'AI는 현재 신호 발생 중';
        _engineStr2 = '새로운 AI매매신호가 발생중입니다.';
        _strLottie = 'assets/8796-dashboard-motion.json';
      }
      //9시 20분 첫 신호 발생부터 다음 신호 발생 정각까지 20분 단위 카운트 다운
      else if (item.noticeCode == 'TIME_TERM') {
        _engineStr1 = 'AI는 현재 실시간 분석 중';
        _engineStr2 = '다음 신호 발생까지';
        _strLottie = 'assets/985-phonological.json';
        _isBeforeTime = false;
        _isVisibleTimer = true;

        if (item.remainTime != null) startTimer(item.remainTime);
      }
      //9시 40분 2번째 신호 발생부터 20분/40분/60분 해당 신호대 신호 발생까지 노출
      else if (item.noticeCode == 'TIME_WAIT') {
        _engineStr1 = 'AI는 현재 신호 발생 중';
        _engineStr2 = '새로운 AI매매신호가 발생중입니다.';
        _strLottie = 'assets/9925-check-purple.json';

        startTimerWait();
      }
      //비영업일, 영업일 장종료후
      else {
        _engineStr1 = 'AI는 현재 학습 업데이트 중';
        _engineStr2 = '데이터를 수집하여 학습에 반영중입니다.';
        _strLottie = 'assets/41561-machine-learning.json';
      }

      _engineStatus = item.noticeCode;
      _strBuy = item.buyCount ?? '0';
      _strSell = item.sellCount ?? '0';
      if (_strBuy == '0' && _strSell == '0') {
        if (item.noticeCode == 'TIME_BEFORE') {
          _emptyString = '장 시작 전 입니다.';
        } else if (item.noticeCode != 'TIME_OPEN') {
          _emptyString = '오늘 새로 발생된 매매신호가 없습니다.';
        }
      }
      // _processTxt = item.processText;

      setState(() {});
    }
  }

  void startTimer(String sTime) {
    countTimer?.cancel();
    DLog.d(SliverSignalWidget.TAG, 'Timer cancel');
    DLog.d(SliverSignalWidget.TAG, 'Timer remain : $sTime');
    if (sTime.length > 3) {
      minute = int.parse(sTime.substring(0, 2));
      second = int.parse(sTime.substring(2, 4));

      countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (second > 0) {
            second--;
            // DLog.d(SliverSignalWidget.TAG, '# Second : $second');
          } else if (second == 0) {
            if (minute > 0) {
              minute--;
              second = 59;
            } else if (minute == 0) {
              DLog.d(SliverSignalWidget.TAG, '# _fetchPosts SIGNAL09');
              _fetchPosts(
                  TR.SIGNAL09,
                  jsonEncode(<String, String>{
                    'userId': _userId,
                  }));
            }
          }
        });
      });
    } else {
      return;
    }
  }

  void startTimerWait() {
    countTimer?.cancel();
    DLog.d(SliverSignalWidget.TAG, 'Timer cancel');

    DLog.d(SliverSignalWidget.TAG, 'Timer Wait : 70sec');
    countTimer = Timer.periodic(const Duration(seconds: 70), (timer) {
      DLog.d(SliverSignalWidget.TAG, '# _fetchPosts(TimerWait)');
      _fetchPosts(
          TR.SIGNAL09,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    });
  }
}
