import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
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
import 'package:rassi_assist/models/none_tr/chart_data.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal01.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal02.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal08.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/pay_three_stock.dart';
import 'package:rassi_assist/ui/signal/signal_all_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_page.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:rassi_assist/ui/tiles/card_require_pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../provider/stock_home/stock_home_tab_name_provider.dart';
import 'stock_home_tab.dart';

class StockHomeSignalPage extends StatefulWidget {
  static const String TAG_NAME = '종목홈_매매신호';
  static final GlobalKey<StockHomeSignalPageState> globalKey = GlobalKey();

  StockHomeSignalPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => StockHomeSignalPageState();
}

class StockHomeSignalPageState extends State<StockHomeSignalPage> {
  final AppGlobal _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  bool varWantKeepAlive = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  late StockTabNameProvider _stockTabNameProvider;
  bool _showBottomSheet = true;

  bool _isFreeVisible = false; //1일 5종목 무료 보기에 해당되는지(서버에서 내려줌)
  bool _isInit = false; //초기화 중일때 false
  bool _hasSignal = true; //매매신호 발생한 내역이 있음

  String pktWillSn = ''; //등록될 포켓 Sn

  String stkName = "";
  String stkCode = "";
  String prePrc = ""; //매수가 or 매도가
  String stkPrc = "";
  String stkProfit = "";
  String dateTime = "";
  String statTxt = "";

  String holdDays = ""; //보유중 0일째 (매도 전 보유기간)
  String holdPeriod = ""; //지난 거래 전 보유기간

  bool bOffHoldDays = false; //보유일 표시
  bool isTodayTrade = false; //당일매매 표시
  bool isTodayBuy = false; //당일매수
  bool isTodayTag = false; //Today 매수/매도
  bool isHoldingStk = false; //보유중
  String imgTodayTag = 'images/main_icon_today_buy.png';
  Color statColor = Colors.grey; //신호 분류에 따른 컬러(보유중, 관망중...)
  Color profitColor = Colors.grey; //수익률 컬러

  //투자수익은?
  String beginYear = "";
  String invAmt = "";
  String balAmt = "";

  // DEFINE 신호 노출 제한 종목
  bool _isSignalTargetYn = true;

  // DEFINE 매매신호 한번도 발생안한 경우 > true면 아직 한번도 매매신호가 발생한적이 없음 (신규상장..등)
  bool _isSignalIssueYn = false;

  // DEFINE 매매금지 종목 여부 Y + 관망중인 상태 > 매수신호가 발생되지 않습니다.. 체크 여부
  bool _isForbiddenShow = false;
  String _forbiddenDesc = '';

  // DEFINE 최근 1년간 AI 매매신호 차트
  late ZoomPanBehavior _zoomPanBehavior;
  final List<ChartData> _signalChartDataList = [];

  // 라씨매매비서는 현재?
  List<SignalAnal> _acvList = []; //AI 매매신호 성과 : 적중률, 누적수익률, 매매횟수 등등
  bool _hasSellResults = true; //매매신호(매도) 성과 표시여부

  //NumericAxisController? _numericAxisController;
  ChartSeriesController<ChartData, DateTime>? _chartSeriesController;
  String _recentSignalDataFlag = '';

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockHomeSignalPage.TAG_NAME,
    );
    stkCode = _appGlobal.stkCode;
    stkName = _appGlobal.stkName;
    _stockTabNameProvider = Provider.of<StockTabNameProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        if (!_showBottomSheet) {
          setState(() {
            _showBottomSheet = true;
          });
        }
      } else {
        if (_showBottomSheet) {
          setState(() {
            _showBottomSheet = false;
          });
        }
      }
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (isTop) {
          if (!_stockTabNameProvider.getIsTop) {
            _stockTabNameProvider.setTopTrue();
          }
        } else {}
      } else {
        if (_stockTabNameProvider.getIsTop && _scrollController.position.pixels > 0) {
          _stockTabNameProvider.setTopFalse();
        }
      }
    });
    _loadPrefData().then((_) => {
          varWantKeepAlive = true,
          if (_userId != '')
            _fetchPosts(
                TR.USER04,
                jsonEncode(<String, String>{
                  'userId': _userId,
                })),
          /*Provider.of<StockInfoProvider>(context, listen: false)
              .postRequest(stkCode),*/
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  reload() {
    _fetchPosts(
        TR.USER04,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastEaseInToSlowEaseOut);
    }
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      bottomSheet: _showBottomSheet && _hasSellResults
          ? Provider.of<StockInfoProvider>(context, listen: true).getIsMyStock
              ? BottomSheet(
                  builder: (bsContext) => InkWell(
                    onTap: () {
                      setState(() {
                        _showBottomSheet = false;
                      });
                      // [포켓 > 나의포켓 > 포켓선택]
                      basePageState.goPocketPage(Const.PKT_INDEX_MY,
                          pktSn: Provider.of<StockInfoProvider>(context, listen: false).getPockSn);
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(BasePage.routeName),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: AppGlobal().isTablet ? 130 : 110,
                      color: const Color(0xd9a064e0),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(_scaffoldKey.currentState!.context).viewPadding.bottom,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '나의 종목 포켓에 등록된 종목입니다.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '보유중이시라면 회원님을 위한',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '매도신호를 받아보세요!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    border: Border.all(
                                      width: 0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  child: const Text(
                                    '나의 종목 포켓으로 이동',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'images/icon_stock_home_signal_banner1.png',
                              width: 55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onClosing: () {
                    setState(() {
                      _showBottomSheet = false;
                    });
                  },
                  enableDrag: false,
                )
              : BottomSheet(
                  builder: (bsContext) => InkWell(
                    onTap: () {
                      setState(() {
                        _showBottomSheet = false;
                      });
                      StockHomeTab.globalKey.currentState!.showAddStockLayerAndResult();
                    },
                    child: Container(
                      width: double.infinity,
                      height: AppGlobal().isTablet ? 130 : 110,
                      color: RColor.lightSell_2e70ff,
                      margin:
                          EdgeInsets.only(bottom: MediaQuery.of(_scaffoldKey.currentState!.context).viewPadding.bottom),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MY 종목에 추가해 보세요.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI매매신호, AI속보, 종목 이슈 알짜 정보를',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '바로 확인 하실 수 있습니다.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    border: Border.all(
                                      width: 0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  child: const Text(
                                    '바로가기',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'images/icon_stock_home_signal_banner1.png',
                              width: 55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onClosing: () {
                    setState(() {
                      _showBottomSheet = false;
                    });
                  },
                  enableDrag: false,
                )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  _setSubTitle('$stkName의 매매신호'),
                  Visibility(
                    visible: _isFreeVisible,
                    child: _setFreeCard(),
                  ),
                  //카드뷰 - 매수, 매도, 보유중, 관망중,
                  Visibility(
                    visible: !_isFreeVisible,
                    child: Stack(
                      children: [
                        _setStatusCard(),
                        Visibility(
                          visible: isTodayTag && _isInit,
                          child: Positioned(
                            top: 25,
                            right: 16,
                            child: Image.asset(
                              imgTodayTag,
                              height: 23,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //카드뷰 - isIssueYn = true , 아직 한번도 매수신호 발생 한적이 없을 때, 관망 중 + 매매신호 내역이 없습니다.
                  Visibility(
                    visible: _isForbiddenShow,
                    child: Column(
                      children: [
                        TileSignal01Forbidden(stkName, _forbiddenDesc),
                        const SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    child: (() {
                      bool isMyStock = Provider.of<StockInfoProvider>(context, listen: false).getIsMyStock;
                      if (_appGlobal.isFreeUser) {
                        if (_isSignalTargetYn || !isMyStock) {
                          // 매매신호 실시간 받기
                          return _setBtnRealtime();
                        } else {
                          // 실시간 수신중
                          return _setBtnRegistered();
                        }
                      } else {
                        if (isMyStock) {
                          // 실시간 수신중
                          return _setBtnRegistered();
                        } else {
                          // 매매신호 실시간 받기
                          return _setBtnRealtime();
                        }
                      }
                    })(),
                  ),

                  const SizedBox(
                    height: 10.0,
                  ),

                  //최근 1년간 AI 매매신호
                  Visibility(
                    visible: _isInit && !_isFreeVisible,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _setSubTitle(
                          '최근 1년간 AI 매매신호',
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
                        Column(
                          children: [
                            /*SizedBox(
                              width: double.infinity,
                              height: 270,
                              child: _setEChartView(),
                            ),*/
                            Column(
                              children: [
                                _setSignalLineChart1(),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),

                  // 모든 매매내역 보기
                  _setBtnListAll(),
                  const SizedBox(
                    height: 25.0,
                  ),

                  Visibility(
                    visible: _hasSellResults,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 투자 수익은 ?
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 140,
                              color: RColor.bgPink,
                            ),
                            _setReturnCard(),
                          ],
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),

                        _setSubTitle(
                          '$stkName AI매매신호 성과',
                        ),
                        _setAchievements(context),
                        const SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  ),

                  //성과 TOP 종목
                  _setTopStock(),

                  _setPockBanner(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //결제하지 않은 회원
  Widget _setFreeCard() {
    return InkWell(
      child: const CardReqPay(),
      onTap: () {
        Navigator.push(
          context,
          Platform.isIOS
              ? CustomNvRouteClass.createRoute(const PayPremiumPage())
              : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
        );
      },
    );
  }

  //매수, 매도, 보유중, 관망중,
  Widget _setStatusCard() {
    if (!_isInit) {
      return SkeletonLoader(
        items: 1,
        period: const Duration(seconds: 2),
        highlightColor: Colors.grey[100]!,
        direction: SkeletonDirection.ltr,
        builder: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
          decoration: UIStyle.boxRoundLine6(),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(
                  right: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: RColor.lineGrey,
                    width: 0.8,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            height: 20,
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Flexible(
                          flex: 2,
                          child: SizedBox(
                            width: double.infinity,
                            height: 20,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
      /*return Container(
        width: double.infinity,
        height: 100,
        decoration: UIStyle.boxRoundLine6(),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
      );*/
    } else if (!_isSignalTargetYn) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxRoundLine6(),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 80.0,
                backgroundColor: RColor.bgWeakGrey,
                child: ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(fontSize: 40, color: RColor.iconGrey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Flexible(
              flex: 1,
              child: Center(
                child: Text('AI매매신호가 발생되지\n않는 종목입니다.',
                    style: TextStyle(fontSize: 16, color: RColor.iconGrey), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
    } else if (!_isSignalIssueYn) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxRoundLine6(),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              width: 80.0,
              height: 80.0,
              decoration: const BoxDecoration(
                color: RColor.sigWatching,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '관망중', style: TStyle.btnTextWht20,
                  // style: theme.textTheme.body.apply(color: textColor),
                ),
              ),
            ),
            const Flexible(
              flex: 1,
              child: Center(
                child: Text('AI매매신호 내역이 없습니다.',
                    style: TextStyle(fontSize: 16, color: RColor.iconGrey), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        decoration: UIStyle.boxRoundLine6(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _setCircleText(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: isTodayTag,
                      child: const SizedBox(
                        height: 25,
                      ),
                    ),
                    //보유중
                    Visibility(
                      visible: isHoldingStk,
                      child: Row(
                        children: [
                          const Text(
                            '수익률',
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            stkProfit,
                            style: TextStyle(
                              color: profitColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //관망중
                    Visibility(
                      visible: _hasSignal,
                      child: Visibility(
                        visible: !isHoldingStk && !isTodayTrade,
                        child: Row(
                          children: [
                            const Text(
                              '관망 ',
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              '$holdDays일째',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),

                    Visibility(
                      visible: isHoldingStk && !isTodayBuy,
                      child: Row(
                        children: [
                          const Text(
                            '보유 ',
                          ),
                          Text(
                            holdDays,
                            style: TStyle.subTitle,
                          ),
                          const Text(
                            '일째',
                          ),
                        ],
                      ),
                    ),
                    //신호가격
                    Visibility(
                      visible: _hasSignal,
                      child: Row(
                        children: [
                          Text('$prePrc '),
                          Text(
                            TStyle.getMoneyPoint(stkPrc),
                            style: TStyle.subTitle,
                          ),
                          const Text('원'),
                        ],
                      ),
                    ),
                    //발생시간
                    Visibility(
                      visible: _hasSignal,
                      child: Row(
                        children: [
                          const Text('발생 '),
                          Text(
                            TStyle.getDateFormat(dateTime),
                            style: TStyle.subTitle,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !_hasSignal,
                      child: const Center(
                        child: Text(
                          'AI매매신호 내역이 없습니다.',
                          style: TStyle.defaultContent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _setPeriodRate(),
          ],
        ),
      );
    }
  }

  //보유기간/수익률
  Widget _setPeriodRate() {
    return Visibility(
      visible: isTodayTrade,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: UIStyle.boxWeakGrey10(),
                child: Column(
                  children: [
                    const Text('보유기간'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$holdPeriod일',
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(15),
                decoration: UIStyle.boxWeakGrey10(),
                child: Column(
                  children: [
                    const Text('수익률'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      stkProfit,
                      style: TextStyle(
                        color: profitColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setCircleText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: statColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          statTxt, style: TStyle.btnTextWht20,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  // AI 매매신호 실시간 받기
  Widget _setBtnRealtime() {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
        height: 40,
        decoration: UIStyle.roundBtnStBox(),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/rassibs_btn_icon.png',
                fit: BoxFit.cover,
                height: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  '$stkName ',
                  style: TStyle.btnTextWht14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Text(
                'AI매매신호 실시간 받기',
                style: TStyle.btnTextWht14,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        //기본 사용자일 경우에는 결제 페이지로 / 프리미엄 사용자일 경우에는 종목 등록
        if (_appGlobal.isFreeUser) {
          Navigator.push(
            context,
            Platform.isIOS
                ? CustomNvRouteClass.createRoute(const PayPremiumPage())
                : CustomNvRouteClass.createRoute(const PayThreeStock()),
          );
        } else {
          //종목 등록 안내
          _showDialogReg();
        }
      },
    );
  }

  // AI 매매신호 실시간 수신중
  Widget _setBtnRegistered() {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0, top: 5.0),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: RColor.mainColor,
            width: 1.2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/rassibs_btn_icon.png',
              color: RColor.mainColor,
              fit: BoxFit.cover,
              height: 15,
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                stkName,
                style: const TextStyle(color: RColor.mainColor, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              '의 AI매매신호 실시간 수신중',
              style: TextStyle(color: RColor.mainColor, fontSize: 14),
            ),
          ],
        ),
      ),
      onTap: () {
        //알림설정으로 이동
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingN()));
      },
    );
  }

  // 모든 매매내역 보기
  Widget _setBtnListAll() {
    return Visibility(
      visible: _hasSignal,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
          height: 40,
          decoration: UIStyle.roundBtnBox(RColor.btnAllView),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/rassibs_trade_history.png',
                  fit: BoxFit.cover,
                  height: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    '$stkName ',
                    style: TStyle.btnTextWht14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(
                  '모든 매매내역 보기',
                  style: TStyle.btnTextWht14,
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          if (_isFreeVisible) {
            Navigator.push(
              context,
              Platform.isIOS
                  ? CustomNvRouteClass.createRoute(const PayPremiumPage())
                  : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
            );
          } else {
            basePageState.callPageRouteData(
              const SignalAllPage(),
              PgData(userId: '', stockCode: stkCode, stockName: stkName),
            );
          }
        },
      ),
    );
  }

  //투자수익은?
  Widget _setReturnCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      decoration: UIStyle.boxRoundLine6bgColor(
        Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '투자수익은?',
                style: TStyle.commonTitle,
              ),
              InkWell(
                onTap: () {
                  CommonPopup.instance.showDialogTitleMsg(
                      context,
                      '투자수익은?',
                      "* 수익금을 재투자하여 매매한 금액입니다.\n"
                          "* 매도시 세금과 수수료(0.3%)가 반영되었습니다.\n"
                          "* 가상투자로 실제 투자와 차이가 있을 수 있습니다.");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                    border: Border.all(
                      width: 1.8,
                      color: RColor.new_basic_text_color_grey,
                    ),
                  ),
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: RColor.new_basic_text_color_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('$beginYear년 1월'),
                  _setCircleReturns(
                    invAmt,
                    RColor.yonbora,
                    const TextStyle(
                      fontSize: 15,
                      color: RColor.jinbora,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 5.0,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  Image.asset(
                    'images/main_my_icon_aw.png',
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(
                width: 5.0,
              ),
              Column(
                children: [
                  const Text('현재'),
                  _setCircleReturns(balAmt, RColor.jinbora, TStyle.btnTextWht16),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            'AI매매신호를 따라 $invAmt만원 투자했을 경우, 현재 $balAmt만원 입니다.',
            style: TStyle.textGrey15,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            '※ 수익금을 재투자한 복리효과가 반영된 금액으로 누적수익률과 차이가 있을 수 있습니다.',
            style: TStyle.purpleThinStyle(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  //투자수익 Circle
  Widget _setCircleReturns(String prc, Color color, TextStyle tStyle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prc,
            style: tStyle,
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            '만원',
            style: tStyle,
          ),
        ],
      ),
    );
  }

  //AI 매매신호 성과
  Widget _setAchievements(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 280,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _acvList.length,
        itemBuilder: (context, index) {
          return TileSignalAnal(_acvList[index]);
        },
      ),
    );
  }

  //성과 TOP 종목
  Widget _setTopStock() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      color: RColor.bgWeakGrey,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle(
            "성과 TOP 종목",
          ),
          const SizedBox(
            height: 10.0,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _setTopBtn('승률', 'images/main_hnr_win_trade.png', 'HIT'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('누적수익률', 'images/main_hnr_max_ratio.png', 'STA'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('평균수익률', 'images/main_hnr_acc_ratio.png', 'AVG'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('최대수익률', 'images/main_hnr_win_ratio.png', 'MAX'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('수익난매매', 'images/main_hnr_avg_ratio.png', 'PRF'),
            ],
          ),
          const SizedBox(
            height: 25.0,
          ),

          //책임 제한
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Center(
              child: Text(
                RString.liability_limit,
                style: TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Custom Button
  Widget _setTopBtn(String title, String imgPath, String routeStr) {
    return InkWell(
      child: Column(
        children: [
          Image.asset(
            imgPath,
            fit: BoxFit.cover,
            height: 45,
          ),
          const SizedBox(
            height: 7.0,
          ),
          Text(
            title,
            style: TStyle.textSGrey,
          ),
          const Text(
            'TOP',
            style: TStyle.textSGrey,
          ),
        ],
      ),
      onTap: () {
        basePageState.callPageRouteData(const SignalTopPage(), PgData(pgData: routeStr));
      },
    );
  }

  //각 항목의 타이틀
  Widget _setSubTitle(
    String subTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.title17,
      ),
    );
  }

  //MY 종목에 추가해 보세요.
  Widget _setPockBanner() {
    return Provider.of<StockInfoProvider>(context, listen: false).getIsMyStock
        ? InkWell(
            onTap: () {
              // [포켓 > 나의포켓 > 포켓선택]
              basePageState.goPocketPage(Const.PKT_INDEX_MY,
                  pktSn: Provider.of<StockInfoProvider>(context, listen: false).getPockSn);
              Navigator.popUntil(
                context,
                ModalRoute.withName(BasePage.routeName),
              );
            },
            child: Container(
              width: double.infinity,
              height: AppGlobal().isTablet ? 130 : 110,
              color: const Color(0xd9a064e0),
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '나의 종목 포켓에 등록된 종목입니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '보유중이시라면 회원님을 위한',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '매도신호를 받아보세요!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border.all(
                              width: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          child: const Text(
                            '나의 종목 포켓으로 이동',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'images/icon_stock_home_signal_banner1.png',
                      width: 55,
                    ),
                  ),
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () {
              StockHomeTab.globalKey.currentState!.showAddStockLayerAndResult();
            },
            child: Container(
              width: double.infinity,
              height: AppGlobal().isTablet ? 130 : 110,
              color: RColor.lightSell_2e70ff,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MY 종목에 추가해 보세요.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI매매신호, AI속보, 종목 이슈 알짜 정보를',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '바로 확인 하실 수 있습니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border.all(
                              width: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          child: const Text(
                            '바로가기',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'images/icon_stock_home_signal_banner1.png',
                      width: 55,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  //종목추가 안내 다이얼로그
  void _showDialogReg() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                    '나의 종목으로 등록하시고,\nAI매매신호를 실시간으로 받아보세요.',
                    style: TStyle.content14,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20.0),
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
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
                      Navigator.pop(buildContext);
                      StockHomeTab.globalKey.currentState!.showAddStockLayerAndResult();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //매매신호 Status
  void _parseSetSignal01(Signal01 data) {
    if (data.signalData.tradeFlag == 'B') {
      //당일매수
      statColor = RColor.sigBuy;
      statTxt = '매수';
      prePrc = '매수가';
      isTodayTag = true;
      isTodayBuy = true;
      isHoldingStk = true;
      bOffHoldDays = true;
      imgTodayTag = 'images/main_icon_today_buy.png';
    } else if (data.signalData.tradeFlag == 'H') {
      //보유중
      statColor = RColor.sigHolding;
      statTxt = '보유중';
      prePrc = '매수가';
      isHoldingStk = true;
    } else if (data.signalData.tradeFlag == 'S') {
      //당일매도
      statColor = RColor.sigSell;
      statTxt = '매도';
      prePrc = '매도가';
      isTodayTag = true;
      isTodayTrade = true;
      imgTodayTag = 'images/main_icon_today_sell.png';
    } else if (data.signalData.tradeFlag == 'W') {
      //관망중
      statColor = RColor.sigWatching;
      statTxt = '관망중';
      prePrc = '매도가';
      isHoldingStk = false;
      _isForbiddenShow = data.signalData.isForbidden == 'Y' ? true : false;
      _forbiddenDesc = data.signalData.isForbidden == 'Y' ? data.signalData.forbiddenDesc : '';
    }

    if (data.signalData.profitRate.contains('-')) {
      stkProfit = '${data.signalData.profitRate}%';
      profitColor = RColor.sigSell;
    } else {
      stkProfit = '+${data.signalData.profitRate}%';
      profitColor = RColor.sigBuy;
    }

    holdDays = data.signalData.elapsedDays;
    holdPeriod = data.signalData.termOfTrade;
    stkPrc = data.signalData.tradePrc;
    dateTime = data.signalData.tradeDate + data.signalData.tradeTime;

    setState(() {});
  }

  Widget _setSignalLineChart1() {
    if (_signalChartDataList.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      height: 230,
      margin: const EdgeInsets.all(
        10,
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 230,
            padding: const EdgeInsets.all(5),
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              /*annotations: [
                if (provider.getVisibleXAxisLastIndex != -1 && _signalChartDataList.isNotEmpty)
                    CartesianChartAnnotation(
                      coordinateUnit: CoordinateUnit.percentage,
                      //region: AnnotationRegion.chart,
                      widget: FittedBox(
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 20,
                          ),
                          //width: 50,
                          height: 30,
                          decoration: UIStyle.boxRoundFullColor8c(Colors.red),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Text(
                            provider.getVisibleXAxisLastIndex != -1
                                ? _signalChartDataList[provider.getVisibleXAxisLastIndex].tradePrc
                                : '',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      //x: provider.getVisibleXAxisLastIndex + 3,
                      //y: int.parse(_signalChartDataList[provider.getVisibleXAxisLastIndex].tradePrc),
                      x: '93%',
                      y: '${100 - provider.getYAxisPercentage}%',
                      //y: '100%'
                      //y: '86%',
                      //y: '${100 - provider.getYAxisPercentage < 5 ? 5 : 100 - provider.getYAxisPercentage > 89 ? 89 : 100 - provider.getYAxisPercentage}%',
                      //y: '89%'
                    ),
              ],*/
              primaryXAxis: DateTimeCategoryAxis(
                // https://www.syncfusion.com/forums/175539/xaxis-disappears-when-pinching-out
                plotOffset: 10,
                initialVisibleMinimum: _signalChartDataList.length > 36
                    ? _signalChartDataList[_signalChartDataList.length - 35].dateTime
                    : _signalChartDataList.first.dateTime,
                initialVisibleMaximum: _signalChartDataList.last.dateTime,
                interval: 7,
                axisBorderType: AxisBorderType.withoutTopAndBottom,
                axisLine: const AxisLine(
                  width: 1,
                  color: Colors.black,
                ),
                majorGridLines: const MajorGridLines(
                  width: 0,
                ),
                majorTickLines: const MajorTickLines(
                  width: 1,
                  color: Colors.black,
                ),
                desiredIntervals: 1,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelPlacement: LabelPlacement.onTicks,
                axisLabelFormatter: (axisLabelRenderArgs) {
                  return ChartAxisLabel(
                    _signalChartDataList.isEmpty || _signalChartDataList.length - 1 < axisLabelRenderArgs.value.toInt()
                        ? ''
                        : TStyle.getDateSlashFormat1(_signalChartDataList[axisLabelRenderArgs.value.toInt()].tradeDate),
                    const TextStyle(
                      fontSize: 10,
                    ),
                  );
                },
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(
                  width: 0,
                  //color: RColor.greyBasic_8c8c8c,
                ),
                majorGridLines: const MajorGridLines(
                  width: 0,
                ),
                majorTickLines: const MajorTickLines(
                  width: 0,
                ),
                plotOffset: 10,
                placeLabelsNearAxisLine: false,
                decimalPlaces: 0,
                axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                  TStyle.getMoneyPoint(axisLabelRenderArgs.text),
                  const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                labelAlignment: LabelAlignment.center,
                opposedPosition: true,
                rangePadding: ChartRangePadding.round,
              ),
              zoomPanBehavior: _zoomPanBehavior,
              onMarkerRender: (markerArgs) {
                int? index = markerArgs.pointIndex;
                if (index != null &&
                    index < _signalChartDataList.length &&
                    _signalChartDataList[index].flag.isNotEmpty) {
                  var item = _signalChartDataList[index];
                  // markerArgs.seriesIndex == 0 : 매수 / markerArgs.seriesIndex == 1 : 매도
                  if (item.flag == 'B' && markerArgs.seriesIndex == 1) {
                    //DLog.e('markerArgs.seriesIndex : ${markerArgs.seriesIndex} / markerArgs.viewportPointIndex : ${markerArgs.viewportPointIndex}');
                    //markerArgs.color = Colors.red;
                    //markerArgs.borderWidth = 1;
                    //markerArgs.shape = DataMarkerType.triangle;
                    markerArgs.markerWidth = 30;
                    markerArgs.markerHeight = 50;
                  } else if (item.flag == 'S' && markerArgs.seriesIndex == 0) {
                    markerArgs.markerWidth = 30;
                    markerArgs.markerHeight = 50;
                    //markerArgs.color = Colors.blue;
                    //markerArgs.shape = DataMarkerType.invertedTriangle;
                    //markerArgs.borderWidth = 1;
                  } else {
                    markerArgs.markerWidth = 0;
                  }
                } else {
                  markerArgs.markerWidth = 0;
                  //markerArgs.color = Colors.white;
                }
              },
              onDataLabelRender: (dataLabelArgs) {
                int index = dataLabelArgs.pointIndex;
                if (index < _signalChartDataList.length && _signalChartDataList[index].flag.isNotEmpty) {
                  var item = _signalChartDataList[index];
                  if (item.flag == 'B') {
                    dataLabelArgs.color = Colors.red;
                    dataLabelArgs.text = '${dataLabelArgs.text}\n매수신호발생';
                    //dataLabelArgs.borderWidth = 1;
                    //dataLabelArgs.shape = DataMarkerType.triangle;
                  } else if (item.flag == 'S') {
                    dataLabelArgs.color = Colors.blue;
                    dataLabelArgs.text = '${dataLabelArgs.text}\n매도신호발생';
                    //dataLabelArgs.shape = DataMarkerType.invertedTriangle;
                  } else {
                    dataLabelArgs.textStyle = const TextStyle(fontSize: 0);
                  }
                } else {
                  dataLabelArgs.textStyle = const TextStyle(fontSize: 0);
                }
              },
              series: [
                if (_signalChartDataList.isNotEmpty)
                  AreaSeries<ChartData, DateTime>(
                    dataSource: _signalChartDataList,
                    xValueMapper: (item, index) => item.dateTime,
                    yValueMapper: (item, index) => int.tryParse(item.tradePrc) ?? 0,
                    pointColorMapper: (ChartData data, _) => const Color(0xffCBCBCB),
                    onRendererCreated: (controller) => _chartSeriesController = controller,
                    borderWidth: 1.4,
                    borderColor: _recentSignalDataFlag.isEmpty
                        ? const Color(0xffCBCBCB)
                        : _recentSignalDataFlag == 'B'
                        ? const Color(0xfffddbdb)
                        : (_recentSignalDataFlag == 'S')
                        ? const Color(0xffe1e0e0)
                        : const Color(0xffCBCBCB),
                    enableTooltip: false,
                    animationDelay: 100,
                    animationDuration: 2000,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      borderWidth: 0,
                      width: 0,
                      height: 0,
                      shape: DataMarkerType.image,
                      image: AssetImage('images/icon_arrow_signal_chart_dn.png'),
                    ),
                    initialIsVisible: true,
                    gradient: LinearGradient(
                      colors: [
                        if (_recentSignalDataFlag.isEmpty)
                          const Color(0xffffffff)
                        else if (_recentSignalDataFlag == 'B')
                          const Color(0xffFFECEC)
                        else if (_recentSignalDataFlag == 'S')
                          const Color(0xffEFEFEF)
                        else
                          const Color(0xffffffff),
                        if (_recentSignalDataFlag.isEmpty)
                          const Color(0xffffffff)
                        else if (_recentSignalDataFlag == 'B')
                          const Color(0xffFFECEC)
                        else if (_recentSignalDataFlag == 'S')
                            const Color(0xffEFEFEF)
                          else
                            const Color(0xffffffff),
                      ],
                       stops: const [
                        0,
                        0,
                      ],

                    ),
                  ),
                if (_signalChartDataList.isNotEmpty)
                  LineSeries<ChartData, DateTime>(
                    dataSource: _signalChartDataList,
                    xValueMapper: (item, index) => item.dateTime,
                    yValueMapper: (item, index) => int.tryParse(item.tradePrc) ?? 0,
                    width: 0,
                    color: Colors.transparent,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      borderWidth: 0,
                      width: 0,
                      height: 0,
                      shape: DataMarkerType.image,
                      image: AssetImage('images/icon_arrow_signal_chart_up.png'),
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _findRecentSignalData {
    if (_signalChartDataList.isEmpty) {
      return '';
    } else {
      String flag = '';
      for (int a = _signalChartDataList.length - 1; a >= 0; a--) {
        String itemFlag = _signalChartDataList[a].flag;
        if (itemFlag.isNotEmpty) {
          flag = itemFlag;
          break;
        }
      }
      return flag;
    }
  }

  void _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.w(trStr + response.body);
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;

        final AccountData accountData = data.accountData;
        accountData.initUserStatus();
      }

      if (_scrollController.hasClients && _scrollController.position.pixels == 0) {
        if (!_showBottomSheet) {
          setState(() {
            _showBottomSheet = true;
          });
        }
      } else {
        if (_showBottomSheet) {
          setState(() {
            _showBottomSheet = false;
          });
        }
      }

      _fetchPosts(
          TR.SIGNAL01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
          }));
    } else if (trStr == TR.SIGNAL01) {
      final TrSignal01 resData = TrSignal01.fromJson(jsonDecode(response.body));
      _isFreeVisible = false;

      isTodayTag = false;
      isTodayBuy = false;
      isTodayTrade = false;
      isHoldingStk = false;
      _isForbiddenShow = false;
      _forbiddenDesc = '';

      if (resData.retCode == RT.SUCCESS) {
        Signal01 data = resData.retData;
        _hasSignal = true;
        _isSignalTargetYn = true;
        _isSignalIssueYn = true;
        if (data.signalData.signalTargetYn == "N") {
          setState(() {
            _isSignalTargetYn = false;
          });
        } else if (data.signalData.signalIssueYn == "N") {
          setState(() {
            _isSignalIssueYn = false;
          });
        } else {
          _parseSetSignal01(data);
        }
      } else if (resData.retCode == '8021') {
        _isFreeVisible = true;
        setState(() {});
      } else {
        _hasSignal = false;
        statColor = RColor.sigWatching;
        statTxt = '관망중';
        isHoldingStk = false;
        setState(() {});
      }

      _isInit = true;
      _fetchPosts(
          TR.SIGNAL02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
          }));
    }

    //매매신호 성과
    else if (trStr == TR.SIGNAL02) {
      final TrSignal02 resData = TrSignal02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (_hasSellDataCheck(resData.retData.listSignalAnal)) {
          if (resData.retData.listSignalAnal.length > 3) {
            _acvList = resData.retData.listSignalAnal.sublist(0, 3);
          } else {
            _acvList = resData.retData.listSignalAnal;
          }
          _hasSellResults = true;
        } else {
          _hasSellResults = false;
        }
        setState(() {});
      }

      _fetchPosts(
          TR.SIGNAL08,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
            'includeData': 'Y',
          }));
    }

    //매매신호 차트 및 투자 수익금
    else if (trStr == TR.SIGNAL08) {
      final TrSignal08 resData = TrSignal08.fromJson(jsonDecode(response.body));
      _signalChartDataList.clear();
      _recentSignalDataFlag = '';
      //_chartSeriesController?.isVisible = false;
      //setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      if (resData.retCode == RT.SUCCESS) {
        final Signal08 mData = resData.retData;
        beginYear = mData.beginYear;
        invAmt = mData.investAmt;
        balAmt = mData.balanceAmt;
        _signalChartDataList.addAll(mData.listChart);
        _recentSignalDataFlag = _findRecentSignalData;
        setState(() {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _chartSeriesController?.isVisible = true;
            _chartSeriesController?.animate();
          });
        });
      }
    }
  }

  //성과 데이터 중 매도 데이터가 있는지 확인한다.
  bool _hasSellDataCheck(List<SignalAnal> dataList) {
    if (dataList.isNotEmpty) {
      int count = 0;
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i].analTarget == 'S') {
          count++;
        }
      }
      if (count > 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
