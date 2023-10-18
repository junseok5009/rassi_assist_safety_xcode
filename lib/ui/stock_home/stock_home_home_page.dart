import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest24.dart';
import 'package:rassi_assist/models/tr_issue06.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi04.dart';
import 'package:rassi_assist/models/tr_shome/tr_shome06.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal01.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal02.dart';
import 'package:rassi_assist/models/tr_stk_home01.dart';
import 'package:rassi_assist/models/tr_user04.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_tab_name_provider.dart';
import 'package:rassi_assist/ui/common/only_web_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_ai_breaking_news_list_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';
import 'package:rassi_assist/ui/stock_home/tile/stock_home_home_tile_event_view.dart';
import 'package:rassi_assist/ui/stock_home/tile/stock_home_home_tile_result_analyze.dart';
import 'package:rassi_assist/ui/stock_home/tile/stock_home_home_tile_trading_trends.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../../common/my_stock_register.dart';
import '../common/common_swiper_pagination.dart';
import '../../models/app_global.dart';
import '../../models/tr_disclos01.dart';
import '../../models/tr_sns06.dart';
import '../common/common_view.dart';
import 'page/result_analyze_page.dart';
import 'page/stock_disclos_list_page.dart';
import 'page/stock_info_page.dart';
import 'page/stock_recent_report_list_page.dart';
import 'tile/stock_home_home_tile_loan_transaction.dart';
import 'tile/stock_home_home_tile_report_analyze.dart';
import 'tile/stock_home_home_tile_social_analyze.dart';
import 'tile/stock_home_home_tile_stock_compare.dart';


/// 2023.02.14_HJS
/// 종목홈(개편)_홈
class StockHomeHomePage extends StatefulWidget {
  static const String TAG_NAME = '종목홈_홈';
  static final GlobalKey<StockHomeHomePageState> globalKey = GlobalKey();

  StockHomeHomePage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => StockHomeHomePageState();
}

class StockHomeHomePageState extends State<StockHomeHomePage>
    with AutomaticKeepAliveClientMixin<StockHomeHomePage> {
  final AppGlobal _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  // 유저정보
  String _userId = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // static value
  String stkName = '';
  String stkCode = '';
  String stkGrpCode = '';

  late ScrollController _scrollController;
  late StockTabNameProvider _stockTabNameProvider;
  bool _showBottomSheet = false;

  // DEFINE 오늘의 요약
  String _stkBriefing = ''; // 오늘의 요약 text 내용들
  String rassiCnt = '0', rassiCnt30 = '0'; // 오늘의 요약 개수
  final List<Rassi04News> _listRassi04News = [];
  Shome06 _shome06 = defShome06; // chatgpt

  // DEFINE 라씨매매비서는 현재
  Signal01 _signal01Data = defSignal01;

  // 매매신호 미발생 대상 종목(signalTargtYn ='N) + 매매금지 종목 여부 isForbidden = 'Y' 일 경우
  bool _isForbiddenShow = false;

  //5종목 무료 보기 true 면 개수 초과
  bool _isFreeVisible = false;

  // DEFINE 라씨 매매비서는 현재 2 : 무료사용자
  // AI 매매신호 성과 : 적중률, 누적수익률, 매매횟수 등등
  List<SignalAnal> _acvList = [];
  final List<HonorStock> _hnrList = [];

  // DEFINE 종목 이슈
  final List<Issue06> _listStockIssue = [];

  // DEFINE 소셜 분석
  Sns06 _sns06 = defSns06;

  // DEFINE 보호 예수
  final List<Invest24Lockup> _listInvest24Lockup = [];

  // DEFINE AI속보
  List<RassiroH> _listRassiro = [];

  // DEFINE 공시
  final List<Disclos> _listDisclos = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockHomeHomePage.TAG_NAME,
    );
    stkCode = _appGlobal.stkCode;
    stkName = _appGlobal.stkName;
    _stockTabNameProvider =
        Provider.of<StockTabNameProvider>(context, listen: false);
    _showBottomSheet = true;
    _scrollController = ScrollController();
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
        if (_stockTabNameProvider.getIsTop &&
            _scrollController.position.pixels > 0) {
          _stockTabNameProvider.setTopFalse();
        }
      }
    });
    _loadPrefData().then((_) => {
      if (_userId != '') requestTrUser04(),
      /*Provider.of<StockInfoProvider>(context, listen: false)
              .postRequest(stkCode),*/
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_bYetDispose) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    }
  }

  requestTrUser04() {
    _fetchPosts(
      TR.USER04,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InfoProvider(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        bottomSheet: _showBottomSheet
            ? BottomSheet(
          builder: (context) => SafeArea(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showBottomSheet = false;
                });
                StockHomeTab.globalKey.currentState?.funcTabMove(Const.STK_INDEX_SIGNAL);
              },
              child: Container(
                height: AppGlobal().isTablet ? 130 : 110,
                color: const Color(0xd9fda02c),
                padding: const EdgeInsets.all(15),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(_scaffoldKey.currentState!.context)
                      .viewPadding
                      .bottom,
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          child: Image.asset(
                              'images/icon_stock_home_home_banner1.png'),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '지금 보고 있는 종목의',
                                  style: TextStyle(
                                    color: Color(0xff1F2D52),
                                    fontSize: 17,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  '매매신호를 확인해 보세요',
                                  style: TextStyle(
                                    color: Color(0xff1F2D52),
                                    fontSize: 17,
                                    height: 1.2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                border: Border.all(
                                  width: 1.2,
                                  color: const Color(0xff1F2D52),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: const Text(
                                '바로가기',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            scrollDirection: Axis.vertical,
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(
                      height: 5,
                    ),

                    _setStockInfo(),

                    // 이벤트 메인차트 + 아래 뷰
                    StockHomeHomeTileEventView(),

                    Container(
                      color: RColor.new_basic_grey,
                      height: 15.0,
                    ),

                    //오늘의 요약정보
                    _setTodayBrief(),

                    Container(
                      color: RColor.new_basic_grey,
                      height: 15.0,
                    ),

                    // 라씨매매비서는 현재?
                    _setRassiSignal(),

                    // 종목 이슈
                    _setStockIssue(),

                    // 종목 비교
                    StockHomeHomeTileStockCompare(),

                    // 실적분석
                    StockHomeHomeTileResultAnalyze(),

                    // 투자자별 매매동향 (외국인/기관 매매동향) + 일자별 매매동향 현황
                    StockHomeHomeTileTradingTrends(),

                    // 대차거래와 공매
                    StockHomeHomeTileLoanTransaction(),

                    // 리포트 분석
                    StockHomeHomeTileReportAnalyze(),

                    // 소셜 분석
                    StockHomeHomeTileSocialAnalyze(_sns06),

                    // 보호 예수
                    _setLockupList(),

                    // AI속보
                    _setRassiroList(),

                    //공시
                    _setDisclos(),

                    _setAddPocket(),
                  ],
                  //addAutomaticKeepAlives: true,
                ),
              )
            ],
            /* child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
              child:


            ),*/
          ),
        ),
      ),
    );
  }

  Widget _setStockInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stkCode,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        stkName,
                        style: TStyle.title18T,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Consumer<StockInfoProvider>(
                      builder: ((_, provider, child) {
                        return InkWell(
                          child: Icon(
                            provider.getIsMyStock
                                ? Icons.star
                                : Icons.star_border,
                            size: 24,
                            color: provider.getIsMyStock
                                ? Colors.yellow
                                : Colors.black,
                          ),
                          onTap: () {
                            MyStockRegister(
                              buildContext: context,
                              screenName: StockHomeHomePage.TAG_NAME,
                            ).startLogic();
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // 종목정보로 이동
                  basePageState.callPageRouteUpData(
                    const StockInfoPage(),
                    PgData(
                        stockName: AppGlobal().stkName,
                        stockCode: AppGlobal().stkCode),
                  );
                },
                splashColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  decoration: UIStyle.boxNewSelectBtn1(),
                  child: const Text(
                    '종목정보',
                    style: TStyle.subTitle,
                  ),
                ),
              ),
            ],
          ),
          Consumer<StockInfoProvider>(
            builder: (_, provider, __) {
              if(provider.getIsLoading){
                return Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 65,
                  margin: const EdgeInsets.symmetric(vertical: 5,),
                  child: SkeletonLoader(
                    items: 1,
                    period: const Duration(seconds: 2),
                    highlightColor: Colors.grey[100]!,
                    direction: SkeletonDirection.ltr,
                    builder: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(vertical: 2,),
                      alignment: Alignment.centerLeft,
                      //decoration: UIStyle.boxRoundLine6(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 2 / 5,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else{
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          TStyle.getMoneyPoint(provider.getCurrentPrice),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                        const Text(
                          '원',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              provider.getCurrentSubInfo,
                              style: TextStyle(
                                color: TStyle.getMinusPlusColor(
                                    provider.getFluctaionRate),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              provider.getTimeTxt,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Image.asset('images/icon_chart_pole4.png'),
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.topRight,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            basePageState.callPageRouteNews(
                              OnlyWebView(),
                              PgNews(
                                  linkUrl:
                                  'https://m.thinkpool.com/item/$stkCode/chart'),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 종목 이미지 둥글게
  Widget _setNetImage() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: RColor.lineGrey,
            //border: BoxBorder.lerp(a, b, t)
          ),
          child: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.network(
                  'http://files.thinkpool.com/radarstock/company_logo/logo_$stkCode.jpg',
                  width: 30,
                  height: 30,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Image.asset(
          'images/test_logo_samsung.png',
          width: 30,
          height: 30,
          fit: BoxFit.fill,
        ),
      ],
    );
  }

  // 오늘의 요약
  Widget _setTodayBrief() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setSubTitle('오늘의 요약'),
              Text(
                DateFormat('MM.dd').format(DateTime.now()),
                style: TStyle.contentGrey14,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (_listRassi04News.length == 1)
            Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: _setTodayBriefView(_listRassi04News.first))
          else if (_listRassi04News.length > 1)
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Swiper(
                scrollDirection: Axis.vertical,
                scale: 0.9,
                autoplay: _listRassi04News.length > 1,
                autoplayDelay: 3000,
                itemCount: _listRassi04News.length,
                itemBuilder: (BuildContext context, int index) =>
                    _setTodayBriefView(_listRassi04News[index]),
              ),
            ),
          if (_stkBriefing.isEmpty)
            Container(
              width: double.infinity,
              height: 100,
              decoration: UIStyle.boxRoundLine6(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                        color: RColor.new_basic_text_color_grey,
                      ),
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                            fontSize: 18,
                            color: RColor.new_basic_text_color_grey),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    '오늘의 요약 내용이 없습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: RColor.new_basic_text_color_grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: Wrap(
                children: [
                  Text(
                    _stkBriefing,
                    style: const TextStyle(
                      height: 1.6,
                      fontSize: 15,
                      // letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          Visibility(
            visible: _shome06.content.isNotEmpty,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                height: 50,
                margin: const EdgeInsets.only(
                  top: 10,
                ),
                decoration: UIStyle.boxRoundLine6(),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/icon_chat_gpt_logo.jpg',
                      width: 18,
                      height: 18,
                    ),
                    const Text(
                      ' 챗GPT가 요약한',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        ' $stkName',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: RColor.mainColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      '의 사업 개요',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              onTap: () {
                _showChatGptShome06Dialog();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _setTodayBriefView(Rassi04News item) {
    return InkWell(
      onTap: () {
        if (item.newsDiv == 'DSC') {
          // 공시
          basePageState.callPageRouteData(
            StockDisclosListPage(),
            PgData(
              stockName: AppGlobal().stkName,
              stockCode: AppGlobal().stkCode,
            ),
          );
        } else if (item.newsDiv == 'SCR') {
          // 잠정 실적
          basePageState.callPageRouteData(
            ResultAnalyzePage(),
            PgData(
              stockName: _appGlobal.stkName,
              stockCode: _appGlobal.stkCode,
            ),
          );
        } else if (item.newsDiv == 'RPT') {
          // 최신 종목 리포트 리스트 페이지
          basePageState.callPageRouteData(
            StockRecentReportListPage(),
            PgData(
              stockName: stkName,
              stockCode: stkCode,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: UIStyle.boxNewBasicGrey10(),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              item.newsDiv == 'DSC'
                  ? '공시발생'
                  : item.newsDiv == 'SCR'
                  ? '잠정실적'
                  : item.newsDiv == 'RPT'
                  ? '리포트'
                  : item.newsDiv == 'LUP'
                  ? '보호예수'
                  : '',
              style: TStyle.commonTitle,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Image.asset(
                    'images/main_icon_new_red_small.png',
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 챗GPT 오늘의 요약 기업 개요 레이어
  _showChatGptShome06Dialog() {
    // auto height 레이어
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: MediaQuery.of(context).size.height * 3 / 4,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  constraints: const BoxConstraints(),
                  iconSize: 26,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'images/icon_chat_gpt_logo.jpg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '챗GPT가 요약한 $stkName의 사업 개요',
                            style: TStyle.title17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${TStyle.getDateSlashFormat3(_shome06.updateDate)} 업데이트',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      _shome06.content,
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: RColor.new_basic_line_grey,
                      margin: const EdgeInsets.symmetric(vertical: 10,),
                    ),
                    const Text(
                      '※ ChatGPT를 이용한 사업개요 요약은 DART 자료를 바탕으로 수집되며, 기술적 방법에 따라 일부 내용에 오류가 있을 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '※ ${_appGlobal.stkName}의 공시자료를 GPT-3.5 Turbo로 구동되는 씽크풀의 컨텐츠 생성 및 검수 시스템을 통해 요약한 정보 입니다. 본 컨텐츠는 AI를 이용한 컨텐츠로, AI기술이 가진 구조적 한계를 가지고 있습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 라씨매매비서는 현재?
  Widget _setRassiSignal() {
    // 매수신호 미발생 종목은 안보여준다
    if (_isForbiddenShow) {
      return const SizedBox();
    } else {
      return Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff454A63),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 15,
            ),
            padding: const EdgeInsets.all(20),
            child: _signal01Data == null || _isFreeVisible
                ? (_acvList.isNotEmpty)
                ? _setRassiSignalFreeView()
                : _setRassiNoSignalFreeView()
                : _setRassiSignalPremiumView(),
          ),
          Container(
            height: 15,
            color: RColor.new_basic_grey,
          ),
        ],
      );
    }
  }

  Widget _setRassiNoSignalFreeView() {
    return InkWell(
      onTap: () {
        StockHomeTab.globalKey.currentState?.funcTabMove(Const.STK_INDEX_SIGNAL);
      },
      child: Text(
        '$stkName AI매매신호를 확인해보세요.',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _setRassiSignalFreeView() {
    return InkWell(
      onTap: () {
        StockHomeTab.globalKey.currentState?.funcTabMove(Const.STK_INDEX_SIGNAL);
      },
      child: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      stkName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    ' AI매매신호 성과',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: _acvList.isNotEmpty && _hnrList.isNotEmpty,
                child: Row(
                  children: [
                    SizedBox(
                      height: 30,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: _hnrList.length,
                        itemBuilder: (context, index) {
                          String imgRoute = '';
                          switch (_hnrList[index].honorDiv) {
                            case "WIN_RATE":
                              {
                                imgRoute = 'images/main_hnr_win_trade.png';
                                break;
                              }
                            case "PROFIT_10P":
                              {
                                imgRoute = 'images/main_hnr_avg_ratio.png';
                                break;
                              }
                            case "SUM_PROFIT":
                              {
                                imgRoute = 'images/main_hnr_max_ratio.png';
                                break;
                              }
                            case "MAX_PROFIT":
                              {
                                imgRoute = 'images/main_hnr_win_ratio.png';
                                break;
                              }
                            case "AVG_PROFIT":
                              {
                                imgRoute = 'images/main_hnr_acc_ratio.png';
                                break;
                              }
                          }
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(1.0),
                            margin: const EdgeInsets.only(
                              right: 4,
                            ),
                            child: Image.asset(
                              imgRoute,
                              height: 18,
                              width: 18,
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      ' 뱃지 ${_hnrList.length}개를 획득 했어요!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xffe1e1e1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          Row(
            children: _setRassiSignalAcvViews(),
          ),
        ],
      ),
    );
  }

  List<Widget> _setRassiSignalAcvViews() {
    List<Widget> listViews = [];

    for (var item in _acvList) {
      listViews.add(
        Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff737995),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  item.analType,
                  style: const TextStyle(
                    color: Color(0xccffffff),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: FittedBox(
                  child: Text(
                    item.empValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return listViews;
  }

  Widget _setRassiSignalPremiumView() {
    String tradeFlag = _signal01Data.signalData.tradeFlag;
    String strTradeFlag = '';
    String strTradeFlaging = '';

    switch (tradeFlag) {
      case 'B':
        {
          // 매수
          strTradeFlag = '오늘매수';
          strTradeFlaging = '오늘매수';
          break;
        }
      case 'S':
        {
          // 매도
          strTradeFlag = '오늘매도';
          strTradeFlaging = '오늘매도';
          break;
        }
      case 'H':
        {
          // 보유
          strTradeFlag = '보유';
          strTradeFlaging = '보유중';
          break;
        }
      case 'W':
        {
          // 관망
          strTradeFlag = '관망';
          strTradeFlaging = '관망중';
          break;
        }
      default:
        {}
    }
    return InkWell(
      onTap: () {
        StockHomeTab.globalKey.currentState?.funcTabMove(Const.STK_INDEX_SIGNAL);
      },
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '라씨매매비서는',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '현재',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: tradeFlag == 'B'
                        ? RColor.sigBuy
                        : tradeFlag == 'S'
                        ? RColor.sigSell
                        : tradeFlag == 'H'
                        ? RColor.sigHolding
                        : tradeFlag == 'W'
                        ? RColor.sigWatching
                        : Colors.white,
                  ),
                  child: Text(
                    strTradeFlaging,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              if (_signal01Data.signalData.tradeFlag == 'B' ||
                  _signal01Data.signalData.tradeFlag == 'S')
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    TStyle.getPercentString(
                        _signal01Data.signalData.profitRate),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: TStyle.getMinusPlusColor(
                        _signal01Data.signalData.profitRate,
                      ),
                    ),
                  ),
                )
              else
                Visibility(
                  visible: _signal01Data.signalData.signalIssueYn != 'N',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        strTradeFlag,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xffe1e1e1),
                        ),
                      ),
                      Text(
                        ' ${_signal01Data.signalData.elapsedDays}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '일째',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xffe1e1e1),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 종목 이슈
  Widget _setStockIssue() {
    if (_listStockIssue.isNotEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _setSubTitle('종목이슈'),
                const SizedBox(
                  height: 20,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  // 나열 방향
                  alignment: WrapAlignment.start,
                  // 정렬 방식
                  spacing: 5,
                  // 좌우 간격
                  //runSpacing: 2,
                  // 상하 간격
                  children: [
                    Text(
                      TStyle.getPostWord(stkName, '은', '는'),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    for (var item in _listStockIssue)
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Text(
                          item.newsSn == _listStockIssue.last.newsSn
                              ? '#${item.keyword}'
                              : '#${item.keyword},',
                          style: const TextStyle(
                            color: RColor.mainColor,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          basePageState.callPageRouteUpData(
                            IssueViewer(),
                            PgData(userId: '', pgSn: item.newsSn),
                          );
                        },
                      ),
                    const Text(
                      '종목이슈가 있습니다.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: _listStockIssue.length < 2 ? 184 : 230,
                  child: Swiper(
                    controller: SwiperController(),
                    scale: 0.9,
                    pagination: _listStockIssue.length < 2
                        ? null
                        : CommonSwiperPagenation.getNormalSpWithMargin(
                      8, 200, Colors.black,
                    ),
                    //autoplay: _listStockIssue.length < 2 ? false : true,
                    autoplay: false,
                    autoplayDelay: 4000,
                    itemCount: _listStockIssue.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = _listStockIssue[index];
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        margin: EdgeInsets.only(
                          //left: 5, right: 5,
                            bottom: _listStockIssue.length < 2 ? 0 : 46),
                        //height: 250,
                        decoration: UIStyle.boxNewBasicGrey10(),
                        child: InkWell(
                          splashColor: Colors.deepPurpleAccent.withAlpha(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.keyword,
                                style: TStyle.title20,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '${TStyle.getDateSlashFormat3(item.issueDttm)} ${item.title}',
                                  style: TStyle.newBasicStrongGreyS16,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Wrap(
                                  spacing: 10.0,
                                  alignment: WrapAlignment.start,
                                  children: List.generate(
                                    item.stkList.length,
                                        (index) {
                                      return InkWell(
                                        child: Text(
                                          '#${item.stkList[index].stockName}',
                                          style: TStyle.purpleThin16Style(),
                                        ),
                                        onTap: () {
                                          _appGlobal.stkCode =
                                              item.stkList[index].stockCode;
                                          _appGlobal.stkName =
                                              item.stkList[index].stockName;
                                          StockHomeTab.globalKey.currentState
                                              ?.funcStockTabUpdate();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            //이슈 뷰어
                            basePageState.callPageRouteUpData(
                              IssueViewer(),
                              PgData(userId: '', pgSn: item.newsSn),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: RColor.new_basic_grey,
            height: 15.0,
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _setLockupList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '보호예수',
                    style: TStyle.title18T,
                  ),
                  Text(
                    '최근 1년',
                    style: TextStyle(
                      color: RColor.new_basic_text_color_grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              _listInvest24Lockup.isEmpty
                  ? CommonView.setNoDataView(120, '보호예수 내용이 없습니다.')
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [
                      Table(
                        children: List.generate(
                          _listInvest24Lockup.length + 1,
                              (row) => TableRow(
                            children: List.generate(
                              4,
                                  (column) => _setTableView(row, column),
                            ),
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2.4),
                          2: FlexColumnWidth(3.4),
                          3: FlexColumnWidth(3),
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    '* 반환행의 날짜(괄호)는 예수일 입니다.',
                    style: TextStyle(
                      color: RColor.new_basic_text_color_grey,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    '* 비율은 총발행주식수 대비 주식수 비율(%) 입니다.',
                    style: TextStyle(
                      color: RColor.new_basic_text_color_grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
      ],
    );
  }

  _setTableView(int row, int column) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 1,
          color: row == 0 ? RColor.bgTableTextGrey : RColor.lineGrey,
        ),
        row == 0
            ? Container(
          height: 50,
          color: RColor.bgTableGrey,
          alignment: Alignment.center,
          child: _setTitleView(column),
        )
            : _setValueView(row - 1, column),
        Visibility(
          visible: _listInvest24Lockup.length == row,
          child: Container(
            height: 1,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ],
    );
  }

  _setTitleView(int column) {
    if (column == 0) {
      return const SizedBox(
        child: Text(
          '구분',
          style: TextStyle(
            fontSize: 16,
            color: RColor.bgTableTextGrey,
          ),
        ),
      );
    } else if (column == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            '주식수',
            style: TextStyle(
              fontSize: 14,
              color: RColor.bgTableTextGrey,
            ),
          ),
          FittedBox(
            child: Text(
              '총발행주식수대비',
              style: TextStyle(
                fontSize: 14,
                color: RColor.bgTableTextGrey,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        column == 1
            ? '날짜'
            : column == 3
            ? '사유'
            : '',
        style: const TextStyle(
          fontSize: 16,
          color: RColor.bgTableTextGrey,
        ),
      );
    }
  }

  _setValueView(int row, int column) {
    String value = '';
    bool isBooking = _listInvest24Lockup[row].workDiv == '반환';
    if (column == 0) {
      value = _listInvest24Lockup[row].workDiv;
    } else if (column == 1) {
      value = isBooking
          ? '${TStyle.getDateSlashFormat1(
        _listInvest24Lockup[row].returnDate,
      )}\n(${TStyle.getDateSlashFormat1(
        _listInvest24Lockup[row].lockupDate,
      )})'
          : TStyle.getDateSlashFormat1(_listInvest24Lockup[row].lockupDate);
    } else if (column == 2) {
      value = isBooking
          ? '${TStyle.getMoneyPoint(_listInvest24Lockup[row].returnVol)}\n${_listInvest24Lockup[row].returnRate}%'
          : '${TStyle.getMoneyPoint(_listInvest24Lockup[row].lockupVol)}\n${_listInvest24Lockup[row].lockupRate}%';
    } else if (column == 3) {
      value = _listInvest24Lockup[row].reasonName;
    }
    return Container(
      alignment: Alignment.center,
      height: 56,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: isBooking && column == 0
              ? RColor.mainColor
              : RColor.bgTableTextGrey,
        ),
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  //라씨로 리스트
  Widget _setRassiroList() {
    return Visibility(
      visible: _listRassiro.isNotEmpty,
      child: Column(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              basePageState.callPageRouteData(
                const StockAiBreakingNewsListPage(),
                PgData(
                  stockName: AppGlobal().stkName,
                  stockCode: AppGlobal().stkCode,
                ),
              );
            },
            child: _setSubTitleMore(
              'AI속보',
            ),
          ),
          //_setRassiCount(),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listRassiro.length,
            itemBuilder: (context, index) {
              return TileRassiroH(_listRassiro[index]);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: RColor.new_basic_grey,
            height: 15.0,
          ),
        ],
      ),
    );
  }

  // 공시
  Widget _setDisclos() {
    if (_listDisclos.isNotEmpty) {
      return Column(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              basePageState.callPageRouteData(
                StockDisclosListPage(),
                PgData(
                  stockName: AppGlobal().stkName,
                  stockCode: AppGlobal().stkCode,
                ),
              );
            },
            child: _setSubTitleMore(
              '공시',
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listDisclos.length,
            itemBuilder: (context, index) {
              return TileDisclos01(_listDisclos[index]);
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  // AI매매신호에서 지금 보고 있는 종목의 .. 배너
  Widget _setAddPocket() {
    return InkWell(
      onTap: () {
        setState(() {
          _showBottomSheet = false;
        });
        StockHomeTab.globalKey.currentState?.funcTabMove(Const.STK_INDEX_SIGNAL);
      },
      child: Container(
        width: double.infinity,
        height: AppGlobal().isTablet ? 130 : 110,
        color: const Color(0xd9fda02c),
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'images/icon_stock_home_home_banner1.png',
                width: 80,
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '지금 보고 있는 종목의',
                        style: TextStyle(
                          color: Color(0xff1F2D52),
                          fontSize: 17,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '매매신호를 확인해 보세요',
                        style: TextStyle(
                          color: Color(0xff1F2D52),
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(
                        width: 1.2,
                        color: const Color(0xff1F2D52),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    child: const Text(
                      '바로가기',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //프리미엄 이동 배너
  Widget _setGoPremium() {
    BoxFit boxFit = BoxFit.contain;
    if (_appGlobal.isTablet) {
      boxFit = BoxFit.fitHeight;
    } else {
      boxFit = BoxFit.fill;
    }
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 175,
        color: const Color(0xffCAE7FF),
        child: Image.asset(
          'images/main_ad_premium.png',
          fit: boxFit,
        ),
      ),
      onTap: () {
        StockHomeTab.globalKey.currentState
            ?.navigateAndGetResultPayPremiumPage();
      },
    );
  }

  //서브 항목 타이틀
  Widget _setSubTitle(
      String subTitle,
      ) {
    return Text(
      subTitle,
      style: TStyle.title18T,
    );
  }

  // 더보기 > 상세, 관련 페이지 이동
  Widget _setSubTitleMore(String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            subTitle,
            style: TStyle.title18T,
          ),
          const Text(
            '더보기',
            style: TStyle.contentGrey14,
          ),
        ],
      ),
    );
  }

  Future<bool> reload() async {
    //var controller = PrimaryScrollController.of(context);
    //controller?.jumpTo(0);
    _scrollController.jumpTo(0);
    // 이벤트 차트
    if (StockHomeHomeTileEventView.globalKey.currentState != null) {
      StockHomeHomeTileEventView.globalKey.currentState?.initPage();
    }
    // 종목 비교
    if (StockHomeHomeTileStockCompare.globalKey.currentState != null) {
      StockHomeHomeTileStockCompare.globalKey.currentState?.initPage();
    }
    // 실적 분석
    if (StockHomeHomeTileResultAnalyze.globalKey.currentState != null) {
      StockHomeHomeTileResultAnalyze.globalKey.currentState?.initPage();
    }
    // 매매 동향
    if (StockHomeHomeTileTradingTrends.globalKey.currentState != null) {
      StockHomeHomeTileTradingTrends.globalKey.currentState?.initPage();
    }
    // 대차 거래
    if (StockHomeHomeTileLoanTransaction.globalKey.currentState != null) {
      StockHomeHomeTileLoanTransaction.globalKey.currentState?.initPage();
    }
    // 리포트 분석
    if (StockHomeHomeTileReportAnalyze.globalKey.currentState != null) {
      StockHomeHomeTileReportAnalyze.globalKey.currentState?.initPage();
    }

    await Future.wait([_requestTrAll()]);
    return true;
  }

  Future<bool> _requestTrAll() async {
    String jsonRASSI04 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
      },
    );
    String jsonSHOME06 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
      },
    );
    String jsonSIGNAL01 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
      },
    );
    String jsonISSUE06 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
        'selectCount': '10',
        'includeData': 'Y',
      },
    );
    String jsonSNS06 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
        'selectDiv': "M1",
      },
    );
    String jsonINVEST24 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
        'selectDiv': "Y1",
      },
    );
    String jsonSHOME01 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
      },
    );
    String jsonDISCLOS01 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': stkCode,
        'pageNo': '0',
        'pageItemSize': '5'
      },
    );

    await Future.wait(
      [
        // DEFINE 오늘의 요약
        _fetchPosts(
          TR.RASSI04,
          jsonRASSI04,
        ),

        // DEFINE 오늘의 요약 - 챗 GPT 기업 개요
        _fetchPosts(
          TR.SHOME06,
          jsonSHOME06,
        ),

        // DEFINE 라씨 매매비서는 현재?
        _fetchPosts(
          TR.SIGNAL01,
          jsonSIGNAL01,
        ),

        // DEFINE 종목 이슈
        _fetchPosts(
          TR.ISSUE06,
          jsonISSUE06,
        ),

        // DEFINE 소셜 분석 - 차트
        _fetchPosts(
          TR.SNS06,
          jsonSNS06,
        ),

        // DEFINE 보호예수
        _fetchPosts(
          TR.INVEST24,
          jsonINVEST24,
        ),

        // DEFINE 라씨로 속보
        _fetchPosts(
          TR.SHOME01,
          jsonSHOME01,
        ),

        // DEFINE 공시
        _fetchPosts(
          TR.DISCLOS01,
          jsonDISCLOS01,
        ),
      ],
    );

    if (_bYetDispose) setState(() {});
    return true;
  }

  //convert 패키지의 jsonDecode 사용
  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;

        if (data != null && data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatus();
        } else {
          //회원정보 가져오지 못함
          AccountData().setFreeUserStatus();
        }
      }

      _requestTrAll();
    }

    // NOTE 오늘의 요약
    else if (trStr == TR.RASSI04) {
      final TrRassi04 resData = TrRassi04.fromJson(jsonDecode(response.body));
      _listRassi04News.clear();
      _stkBriefing = '';
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.content != null) {
          _stkBriefing = resData.retData.content.replaceAll('<br>', '\n');
        }
        _stkBriefing = _stkBriefing.replaceRange(0, 1, '⦁');
        _stkBriefing = _stkBriefing.replaceAll('\n-', '\n⦁');
        rassiCnt = resData.retData.todayNewsCount;
        rassiCnt30 = resData.retData.monthNewsCount;
        if (resData.retData.rassi04NewsList.isNotEmpty) {
          _listRassi04News.addAll(resData.retData.rassi04NewsList);
        }
      }

      _fetchPosts(
          TR.SHOME03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
          }));
    }

    // NOTE 오늘의 요약 - 챗 GPT 기업 개요 정보
    else if (trStr == TR.SHOME06) {
      final TrShome06 resData = TrShome06.fromJson(jsonDecode(response.body));
      _shome06 = defShome06;
      if (resData.retCode == RT.SUCCESS) {
        _shome06 = resData.retData;
      }
    }

    // NOTE 라씨 매매비서는 현재
    else if (trStr == TR.SIGNAL01) {
      final TrSignal01 resData = TrSignal01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _signal01Data = resData.retData;
        _isForbiddenShow = _signal01Data.signalData.isForbidden == 'Y' ||
            _signal01Data.signalData.signalTargetYn == 'N'
            ? true
            : false;
        _isFreeVisible = false;
      } else {
        _signal01Data = defSignal01;
        _isFreeVisible = true;
        _fetchPosts(
            TR.SIGNAL02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'stockCode': stkCode,
              'includeExtra': 'Y',
            }));
      }
    }

    // NOTE 라씨 매매비서는 현재 2 : 무료사용자
    else if (trStr == TR.SIGNAL02) {
      // DEFINE 매매신호 성과 부분
      final TrSignal02 resData = TrSignal02.fromJson(jsonDecode(response.body));
      _acvList.clear();
      _hnrList.clear();
      if (resData.retCode == RT.SUCCESS) {
        // DEFINE 1. 성과 > 적중률,,누적수익률,,매매횟수 등 데이터 체크
        for (var e in resData.retData.listSignalAnal) {
          if (e.analTarget == 'S' && e.analType != '') _acvList.add(e);
        }
        if (_acvList.length > 3) _acvList = _acvList.sublist(0, 3);

        // DEFINE 2. 뱃지 체크
        _hnrList.addAll(resData.retData.listHonorStock);
        setState(() {});
      }
    }

    // NOTE 종목 이슈
    else if (trStr == TR.ISSUE06) {
      final TrIssue06 resData = TrIssue06.fromJson(jsonDecode(response.body));
      _listStockIssue.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.listData.isNotEmpty) {
          _listStockIssue.addAll(resData.listData);
        }
      }
    }

    // NOTE 소셜 분석
    else if (trStr == TR.SNS06) {
      final TrSns06 resData = TrSns06.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.listPriceChart.isNotEmpty) {
          _sns06 = resData.retData;
        }
      } else {
        _sns06 = defSns06;
      }
    }

    // NOTE 보호 예수
    else if (trStr == TR.INVEST24) {
      final TrInvest24 resData = TrInvest24.fromJson(jsonDecode(response.body));
      _listInvest24Lockup.clear();
      if (resData.retCode == RT.SUCCESS) {
        Invest24 data = resData.retData;
        if (data.listInvest24Lockup.isNotEmpty) {
          _listInvest24Lockup.addAll(data.listInvest24Lockup);
        }
      }
    }

    // NOTE 라씨로 속보
    else if (trStr == TR.SHOME01) {
      final TrSHome01 resData = TrSHome01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        SHome01 data = resData.retData;
        if (data.listRas != null) _listRassiro = resData.retData.listRas!;
      }
    }

    // NOTE 공시
    else if (trStr == TR.DISCLOS01) {
      final TrDisclos01 resData =
      TrDisclos01.fromJson(jsonDecode(response.body));
      _listDisclos.clear();
      if (resData.retCode == RT.SUCCESS) {
        Disclos01 data = resData.retData;
        if (data.listDisclos.isNotEmpty) {
          _listDisclos.addAll(data.listDisclos);
        }
      }
    }

    /*else if (trStr == TR.POCK03) {
      //포켓 리스트
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        StockHomeTab.globalKey.currentState
            .showBottomSheetAddStock(resData.listData);
      }
    }*/
  }
}

class StockHomeMainChartModel {
  String? td;
  String? tl;
  String? th;
  String? ts;
  String? tp;
  String? cnt;

  StockHomeMainChartModel({
    this.td, this.tl, this.th,
    this.ts, this.tp, this.cnt
  });

  factory StockHomeMainChartModel.fromJson(Map<String, dynamic> json) {
    return StockHomeMainChartModel(
      td: json['td'] ?? '',
      tl: json['tl'] ?? '',
      th: json['th'] ?? '',
      ts: json['ts'] ?? '',
      tp: json['tp'],
      cnt: json['cnt'] ?? '',
    );
  }

  Map toJson() => {
    'td': td,
    'tl': tl,
    'th': th,
    'ts': ts,
    'tp': tp,
    'cnt': cnt,
  };
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
