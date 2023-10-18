import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/tr_user04.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pay/pay_three_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../provider/stock_home/stock_home_tab_name_provider.dart';
import '../pay/pay_premium_aos_page.dart';
import '../pay/pay_premium_page.dart';
import 'stock_home_home_page.dart';
import 'stock_home_signal_page.dart';

/// 2023.04.19 - HJS
/// 종목홈 TAB
class StockHomeTab extends StatefulWidget {
  static const routeName = '/page_stock_home_tab';
  static const String TAG = "[StockHomeTab] ";
  static const String TAG_NAME = '종목홈';
  static final GlobalKey<StockHomeTabState> globalKey = GlobalKey();

  StockHomeTab({Key? key}) : super(key: globalKey);

  @override
  State<StockHomeTab> createState() => StockHomeTabState();
}

class StockHomeTabState extends State<StockHomeTab>
    with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  String _userId = "";
  final _appGlobal = AppGlobal();
  bool wantKeppAlive = true;

  late PgData args;
  int tabIndex = 0; // 초기 탭뷰 인덱스
  int _currentTabIndex = 0; // 현재 탭뷰 인덱스
  bool stkInitData = true;
  String stkName = "";
  String stkCode = "";
  Color curColor = Colors.grey[500]!;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (_appGlobal.stkCode.isEmpty || _appGlobal.stkName.isEmpty) {
      Navigator.pop(context);
    }
    stkCode = _appGlobal.stkCode;
    stkName = _appGlobal.stkName;
    tabIndex = _appGlobal.tabIndex >= 2 ? 0 : _appGlobal.tabIndex;
    _currentTabIndex = tabIndex;
    //logoUrl = 'http://files.thinkpool.com/radarstock/company_logo/logo_' + stkCode + '.jpg';
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: tabIndex);
    _tabController.addListener(_handleTabSelection);
    Provider.of<StockTabNameProvider>(context, listen: false).setJustTopTrue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockInfoProvider>(context, listen: false)
          .postRequest(stkCode);
    });
    _loadPrefData();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            leadingWidth: 40,
            //automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                if (context != null && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_sharp,
              ),
            ),
            actions: [
              const SizedBox(
                width: 4,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Icon(
                  Icons.search,
                  size: 27,
                  color: Colors.black,
                ),
                onTap: () {
                  //_getPocketStat();
                  _navigateAndGetResultSearchStockPage();
                },
              ),
              const SizedBox(
                width: 10,
              ),
            ],
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.black),
            titleSpacing: 5.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  indicatorPadding: const EdgeInsets.only(
                    right: 0,
                  ),
                  unselectedLabelColor: Colors.grey,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    //vertical: 5,
                  ),
                  isScrollable: true,
                  tabs: _setOnlyTitleTabView(),
                  //_setNormalTabView(),
                ),
              ],
            ),
            /* bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: Colors.black,
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      unselectedLabelColor: Colors.grey,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      isScrollable: true,
                      //tabs: _isTopScroll ? _setNormalTabView() : _setStockTabView(),
                      tabs: _setNormalTabView(),
                    ),
                  ],
                ),
              ),
            ),*/
          ),
        ),
        body: _setTabView(),
      ),
    );
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _fetchPosts(
      TR.USER04,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _tabController.previousIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  //convert 패키지의 jsonDecode 사용
  _fetchPosts(String trStr, String json) async {
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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  _parseTrData(String trStr, final http.Response response) {
    //DLog.w(trStr + response.body);
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        if (data != null && data.accountData != null) {
          final AccountData _accountData = data.accountData;
          _accountData.initUserStatus();
        } else {
          AccountData().setFreeUserStatus();
        }
      }
    }
  }

  //하단 탭뷰
  Widget _setTabView() {
    return TabBarView(
      physics: Platform.isAndroid ? const NeverScrollableScrollPhysics() : null,
      controller: _tabController,
      children: [
        /*RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Colors.blue,
          strokeWidth: 4.0,
          onRefresh: () {
            //commonShowToast('dd');
            return Future<void>.delayed(const Duration(seconds: 0));
          },
          child: StockHomeHomePage(),
        ),*/
        StockHomeHomePage(),
        StockHomeSignalPage(),
      ],
    );
  }

  List<Widget> _setOnlyTitleTabView() {
    return [
      Consumer<StockTabNameProvider>(
        builder: (context, provider, _) {
          String stockFluctuationRate =
              Provider.of<StockInfoProvider>(context, listen: true)
                  .getFluctaionRate;
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              provider.getIsTop
                  ? '종목홈'
                  : stkName.length > 8
                      ? stkName.substring(0, 8)
                      : stkName,
              style: TextStyle(
                //공통 중간 타이틀
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: provider.getIsTop ||
                        stockFluctuationRate.isEmpty ||
                        stockFluctuationRate == '0'
                    ? Colors.black
                    : stockFluctuationRate.contains('-')
                        ? RColor.sigSell
                        : RColor.sigBuy,
              ),
            ),
          );
        },
      ),
      _currentTabIndex == 1
          ? const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                'AI매매신호',
                style: TextStyle(
                  //공통 중간 타이틀
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Container(
                margin: const EdgeInsets.only(left: 0),
                child: Image.asset(
                  'images/gif_stock_home_tab_signal_title.gif',
                  //width: 100,
                  height: 17,
                ),
              ),
            ),
    ];
  }

  List<Widget> _setNormalTabView() {
    return [
      Consumer<StockTabNameProvider>(
        builder: (context, _provider, _) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              _provider.getIsTop
                  ? '종목홈'
                  : stkName.length > 8
                      ? stkName.substring(0, 7)
                      : stkName,
              style: const TextStyle(
                //공통 중간 타이틀
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
      Consumer<StockTabNameProvider>(
        builder: (context, _provider, _) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: 5,
            ),
            child: Row(
              children: [
                const Text(
                  'AI매매신호',
                  style: TextStyle(
                    //공통 중간 타이틀
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                if (_provider.getIsTop)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 5),
                    child:
                        /*Lottie.asset('assets/robot.json',
                          fit: BoxFit.fill),*/
                        Image.asset(
                      'images/gif_stock_home_tab_robo.gif',
                      height: 20,
                    ),
                  )
                else
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                    child: Image.asset(
                      'images/icon_stock_home_tab_ai.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ];
  }

  /*List<Widget> _setMoveTabView() {
    return [
      Column(
        children: [
          Container(
            width: 100,
            height: 40,
            alignment: Alignment.center,
            child: Swiper(
              scrollDirection: Axis.vertical,
              itemCount: 2,
              loop: true,
              autoplay: true,
              autoplayDelay: 4000,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Text(
                      stkName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  );
                } else {
                  return Consumer<StockInfoProvider>(
                    builder: (_, _stockInfoProvider, __) {
                      return Column(
                        children: [
                          Column(
                            children: [
                              Text(
                                TStyle.getMoneyPoint(
                                    '${_stockInfoProvider.getCurrentPrice}'),
                                style: TextStyle(
                                  //공통 중간 타이틀
                                  fontWeight: FontWeight.w600,
                                  color: _stockInfoProvider.getColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          //등락률, 등락포인트
                          Text(
                            _stockInfoProvider.getCurrentSubInfo,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: _stockInfoProvider.getColor,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'AI매매신호',
            style: TextStyle(
              //공통 중간 타이틀
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Icon(
            Icons.adb,
          ),
        ],
      )
    ];
  }*/

  // 종목 검색 갔다가 돌아오기
  _navigateAndGetResultSearchStockPage() async {
    final result = await Navigator.push(
      context,
      commonPageRouteFromBottomToUpWithSettings(
        SearchPage(),
        PgData(
          pgSn: '',
        ),
      ),
    );
    if (result != null &&
        result is Stock &&
        result.stockName.isNotEmpty &&
        result.stockCode.isNotEmpty) {
      if (_appGlobal.stkCode != result.stockCode) {
        _appGlobal.stkCode = result.stockCode;
        _appGlobal.stkName = result.stockName;
        //_appGlobal.tabIndex = Const.STK_INDEX_HOME;
        //Provider.of<StockHomeProvider>(context, listen: false).updateAll(stockCode, stockName, Const.STK_INDEX_HOME);
      }
      funcStockTabUpdate();
    }
  }

  // 종목홈에서 결제연동
  navigateAndGetResultPayPremiumPage() async {
    final result = await Navigator.push(
      context,
      Platform.isIOS
          ? commonPageRouteFromBottomToUp(PayPremiumPage())
          : commonPageRouteFromBottomToUp(PayPremiumAosPage()),
    );

    if (result == 'cancel') {
      if (!mounted) return;
      Provider.of<StockInfoProvider>(context, listen: false)
          .postRequest(stkCode);
    } else {
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
      funcStockTabUpdate();
    }
  }

  // 종목홈에서 3종목 결제연동
  navigateAndGetResultPayThreeStockPage() async {
    final result = await Navigator.push(
      context,
      commonPageRouteFromBottomToUp(PayThreeStock()),
    );

    if (result == 'cancel') {
      if (!mounted) return;
      Provider.of<StockInfoProvider>(context, listen: false)
          .postRequest(stkCode);
    } else {
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
      funcStockTabUpdate();
    }
  }

  // 자식 탭뷰 갱신시키기
  funcStockTabUpdate() {
    setState(() {
      stkCode = _appGlobal.stkCode;
      stkName = _appGlobal.stkName;
      tabIndex = _appGlobal.tabIndex;
    });
    if (StockHomeSignalPage.globalKey.currentState != null) {
      var childCurrentState = StockHomeSignalPage.globalKey.currentState;
      childCurrentState?.stkCode = _appGlobal.stkCode;
      childCurrentState?.stkName = _appGlobal.stkName;
      childCurrentState?.requestTrAll();
    }
    if (StockHomeHomePage.globalKey.currentState != null) {
      var childCurrentState = StockHomeHomePage.globalKey.currentState;
      childCurrentState?.stkCode = _appGlobal.stkCode;
      childCurrentState?.stkName = _appGlobal.stkName;
      childCurrentState?.stkGrpCode = '';
      childCurrentState?.reload();
    }
    //_tabController.animateTo(tabIndex);
    Provider.of<StockInfoProvider>(context, listen: false).postRequest(stkCode);
  }

  // 자식에서 탭뷰 index 이동
  funcTabMove(int moveTabIndex) {
    if (_tabController.index != moveTabIndex) {
      setState(() {
        tabIndex = moveTabIndex;
        _tabController.animateTo(moveTabIndex);
      });
    }
  }
}
