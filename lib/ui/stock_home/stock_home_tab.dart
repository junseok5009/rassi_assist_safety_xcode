import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../provider/stock_home/stock_home_tab_name_provider.dart';
import '../main/base_page.dart';
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
  late UserInfoProvider _userInfoProvider;

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
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    _userInfoProvider.addListener(refreshChild);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockInfoProvider>(context, listen: false)
          .postRequest(stkCode);
    });
    _loadPrefData();
  }

  @override
  void dispose() {
    _userInfoProvider.removeListener(refreshChild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (mounted) {
                Navigator.pop(
                  context,
                  CustomNvRouteResult.cancel,
                );
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
      if(mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  _parseTrData(String trStr, final http.Response response) {
    //DLog.w(trStr + response.body);
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        final AccountData accountData = data.accountData;
        accountData.initUserStatus();
      }
    }
  }

  //하단 탭뷰
  Widget _setTabView() {
    return TabBarView(
      physics: //Platform.isAndroid ? const NeverScrollableScrollPhysics() : null,
      const NeverScrollableScrollPhysics(),
      controller: _tabController,
      children: [
        RefreshIndicator(
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          onRefresh: () async {
            if (StockHomeHomePage.globalKey.currentState != null) {
              var childCurrentState = StockHomeHomePage.globalKey.currentState;
              childCurrentState!.stkCode = _appGlobal.stkCode;
              childCurrentState.stkName = _appGlobal.stkName;
              childCurrentState.stkGrpCode = '';
              Provider.of<StockInfoProvider>(context, listen: false)
                  .postRequest(stkCode);
              await childCurrentState.reload();
            }
          },
          child: StockHomeHomePage(),
        ),
        /* StockHomeHomePage(),*/
        RefreshIndicator(
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          onRefresh: () async {
            if (StockHomeSignalPage.globalKey.currentState != null) {
              var childCurrentState =
                  StockHomeSignalPage.globalKey.currentState;
              //Provider.of<StockInfoProvider>(context, listen: false).postRequest(stkCode);
              childCurrentState?.reload();
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          child: StockHomeSignalPage(),
        ),
        //StockHomeSignalPage(),
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
                        ? RColor.lightSell_2e70ff
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
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              provider.getIsTop
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
        builder: (context, provider, _) {
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
                if (provider.getIsTop)
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
      CustomNvRouteClass.createRoute(
        SearchPage.goStockHome(),
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
      refreshChild();
    }
  }

  // 자식 탭뷰 갱신시키기
  refreshChild() {
    setState(() {
      stkCode = _appGlobal.stkCode;
      stkName = _appGlobal.stkName;
      tabIndex = _appGlobal.tabIndex;
    });
    if (StockHomeSignalPage.globalKey.currentState != null) {
      var childCurrentState = StockHomeSignalPage.globalKey.currentState;
      childCurrentState!.stkCode = _appGlobal.stkCode;
      childCurrentState.stkName = _appGlobal.stkName;
      childCurrentState.reload();
    }
    if (StockHomeHomePage.globalKey.currentState != null) {
      var childCurrentState = StockHomeHomePage.globalKey.currentState;
      childCurrentState!.stkCode = _appGlobal.stkCode;
      childCurrentState.stkName = _appGlobal.stkName;
      childCurrentState.stkGrpCode = '';
      childCurrentState.reload();
    }
    //_tabController.animateTo(tabIndex);
    Provider.of<StockInfoProvider>(context, listen: false).postRequest(stkCode);
  }

  showAddStockLayerAndResult() async {
    String result =
        await CommonLayer.instance.showLayerAddStockWithAddSignalBtn(
      context,
      Stock(
        stockName: stkName,
        stockCode: stkCode,
      ),
    );
    if (mounted) {
      if (result == CustomNvRouteResult.refresh) {
        Provider.of<StockInfoProvider>(context, listen: false).postRequest(stkCode);
        _showBottomSheetMyStock();
      } else if (result == CustomNvRouteResult.cancel) {
        //
      } else if (result == CustomNvRouteResult.landing) {
        // 나만의 매도신호 만들기 레이어 띄우기 !
        if (AppGlobal().isPremium) {
          _showAddSignalLayerAndResult();
        } else {
          String result = await CommonPopup.instance.showDialogPremium(context);
          if (result == CustomNvRouteResult.landPremiumPage && mounted) {
            Navigator.push(
              context,
              Platform.isIOS
                  ? CustomNvRouteClass.createRoute(const PayPremiumPage())
                  : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
            );
          }
        }
      } else if (result == CustomNvRouteResult.landPremiumPopup) {
        String result = await CommonPopup.instance.showDialogPremium(context);
        if (result == CustomNvRouteResult.landPremiumPage && mounted) {
          Navigator.push(
            context,
            Platform.isIOS
                ? CustomNvRouteClass.createRoute(const PayPremiumPage())
                : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
          );
        }
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(
            context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
      } else {
        CommonPopup.instance.showDialogBasic(context, '알림', result);
      }
    } else {
      //Navigator.pop(context, CustomNvRouteResult(false, CustomNvRouteResult.fail,),);
    }
  }

  _showAddSignalLayerAndResult() async {
    String result = await CommonLayer.instance.showLayerAddSignal(
      context,
      Stock(
        stockName: stkName,
        stockCode: stkCode,
      ),
    );
    if (mounted) {
      if (result == CustomNvRouteResult.refresh) {
        // auto refresh
      } else if (result == CustomNvRouteResult.cancel) {
        // user cancel
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(
            context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
      } else {
        CommonPopup.instance.showDialogBasic(context, '알림', result);
      }
    }
  }

  showDelStockPopupAndResult(
    String pocketSn,
  ) async {
    String result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
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
                  Navigator.pop(context, CustomNvRouteResult.cancel);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '알림',
                    style: TStyle.title18T,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    '내 종목 포켓에서 해당 종목을 삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TStyle.content15,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                      ),
                      decoration: UIStyle.boxRoundFullColor50c(
                        RColor.mainColor,
                      ),
                      child: const Text(
                        '삭제하기',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, CustomNvRouteResult.refresh);
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          return value;
        } else {
          return CustomNvRouteResult.cancel;
        }
      },
    );

    if (mounted) {
      if (result == CustomNvRouteResult.refresh) {
        String result =
            await Provider.of<PocketProvider>(context, listen: false)
                .deleteStock(
          Stock(
            stockName: stkName,
            stockCode: stkCode,
          ),
          pocketSn,
        );
        if (mounted) {
          if (result == CustomNvRouteResult.refresh) {
            Provider.of<StockInfoProvider>(context, listen: false)
                .postRequest(stkCode);
          } else if (result == CustomNvRouteResult.fail) {
            CommonPopup.instance.showDialogBasic(
                context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
          } else {
            CommonPopup.instance.showDialogBasic(context, '안내', result);
          }
        }
      } else if (result == CustomNvRouteResult.cancel) {
      } else {}
    }
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

  // 관심 종목으로 등록 이후 바텀시트
  _showBottomSheetMyStock() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나의 종목 추가하기',
                      style: TStyle.title18T,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  '${TStyle.getPostWord(AppGlobal().stkName, '이', '가')} 나의 종목으로 추가되었습니다.\n나의 종목 포켓에서 확인하시겠어요?',
                  style: TStyle.content15,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  child: SizedBox(
                    width: 240,
                    //height: 40,
                    child: Image.asset(
                      'images/rassibs_btn_pk.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    var stockInfoProvider =
                        Provider.of<StockInfoProvider>(context, listen: false);
                    // [포켓 > 나의포켓 > 포켓선택]
                    basePageState.goPocketPage(Const.PKT_INDEX_MY,
                        pktSn: stockInfoProvider.getPockSn);
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/base'),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
