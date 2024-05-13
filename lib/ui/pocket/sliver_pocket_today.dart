import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock11.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/pocket/pocket_tile/tile_pocket_today_sub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../../common/const.dart';
import '../../common/d_log.dart';
import '../../common/net.dart';
import '../../common/strings.dart';
import '../../common/ui_style.dart';
import '../../models/none_tr/app_global.dart';
import '../../models/none_tr/stock/stock_pkt_chart.dart';
import '../../models/tr_pock/tr_pock10.dart';
import '../common/common_popup.dart';
import '../common/common_view.dart';
import '../main/base_page.dart';

/// 2023.10
/// 포켓_TODAY
class SliverPocketTodayWidget extends StatefulWidget {
  static const routeName = '/page_pocket_today_sliver';
  static const String TAG = "[SliverPocketTodayWidget] ";
  static const String TAG_NAME = '포켓_TODAY';
  static final GlobalKey<SliverPocketTodayWidgetState> globalKey = GlobalKey();

  SliverPocketTodayWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverPocketTodayWidgetState();
}

class SliverPocketTodayWidgetState extends State<SliverPocketTodayWidget> with TickerProviderStateMixin {
  late PocketProvider _pocketProvider;
  late SharedPreferences _prefs;
  final AppGlobal _appGlobal = AppGlobal();

  String _userId = '';
  bool _isLoading = true;
  Pock10 _pock10 = Pock10.emptyWithSelectDiv('');
  Pock11 _pock11 =
      Pock11(upCnt: '', downCnt: '', issueCnt: '', sigBuyCnt: '', sigSellCnt: '', supplyCnt: '', chartCnt: '');
  late ScrollController _scrollController;
  bool _showBottomBoard = false;

  int _currentTabIndex = 0; // 현재 탭뷰 인덱스
  late TabController _tabController;
  final List<String> _tabTitles = [
    '상승 50',
    '하락 50',
    '매매신호',
    '이슈',
    '수급',
    '차트분석',
  ];
  final List<String> _tabSelectDiv = [
    'UP',
    'DN',
    'TS',
    'IS',
    'SP',
    'CH',
  ];

  initPage() {
    _requestTrPocketToday();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging && _tabController.index != _tabController.previousIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _isLoading = true;
      });
      _requestTrPocketToday();
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverPocketTodayWidget.TAG_NAME);
    CustomFirebaseClass.logEvtMyPocketView(SliverPocketTodayWidget.TAG_NAME);
    _pocketProvider = Provider.of<PocketProvider>(context, listen: false);
    _pocketProvider.addListener(reload);
    _currentTabIndex = _appGlobal.pocketTodayIndex;
    _appGlobal.pocketTodayIndex = 0;
    _isLoading = true;
    _tabController = TabController(length: 6, vsync: this, initialIndex: _currentTabIndex);
    _tabController.addListener(_handleTabSelection);
    _loadPrefData().then((_) {
      initPage();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        if (!_showBottomBoard) {
          setState(() {
            _showBottomBoard = true;
          });
        }
      } else {
        if (_showBottomBoard) {
          setState(() {
            _showBottomBoard = false;
          });
        }
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pocketProvider.removeListener(reload);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _showBottomBoard ? _setBottomCountBoard(context) : null,
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: TabBar(
                padding: const EdgeInsets.all(15),
                labelPadding: EdgeInsets.zero,
                isScrollable: true,
                indicatorColor: Colors.transparent,
                controller: _tabController,
                splashFactory: NoSplash.splashFactory,
                tabs: _makeTabs(),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // const SizedBox(height: 5.0,),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: (() {
                        if (_isLoading) {
                          return _loadingView();
                        } else {
                          if (_pock10.beforeOpening == 'Y' && _pock10.selectDiv != 'IS') {
                          return _itemBaseContainer(
                            CommonView.setNoDataTextView(
                              80,
                              '장 시작 전 입니다.',
                            ),
                          );
                        } else if (_pock10.isEmpty()) {
                          // if (_stockCount == 0) {
                          //   return _setAddStockView();
                          // } else {
                          return _itemBaseContainer(
                            CommonView.setNoDataTextView(
                              80,
                              _pock10.getEmptyTitle(),
                            ),
                          );
                          // }
                        } else {
                          return _setPocketStatusList();
                        }
                        }
                      })(),
                    ),
                  ],
                ),
                // children: ,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _makeTabs() {
    List<Widget> tabs = [];
    _tabTitles.asMap().forEach((key, value) {
      if (key == _tabController.index) {
        tabs.add(
          Tab(
            icon: null,
            height: 40,
            child: Container(
              width: 90,
              height: 40,
              decoration: UIStyle.boxRoundLine25c(Colors.black),
              margin: EdgeInsets.only(
                left: key == 0 ? 0 : 10,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else {
        tabs.add(
          Tab(
            height: 40,
            child: Container(
              width: 90,
              height: 40,
              decoration: UIStyle.boxRoundLine25c(
                RColor.greyBoxLine_c9c9c9,
              ),
              margin: EdgeInsets.only(
                left: key == 0 ? 0 : 10,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  color: RColor.new_basic_text_color_strong_grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }
    });
    return tabs;
  }

  //Today 하단 각 항목 카운팅
  Widget _setBottomCountBoard(BuildContext context) {
    return Container(
      height: 73,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2), //changes position of shadow
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //상승
          InkWell(
            child: Column(
              children: [
                const Text(
                  '상승',
                  style: TStyle.content14,
                ),
                Text(
                  _pock11.upCnt,
                  style: TStyle.commonTitle,
                ),
              ],
            ),
            onTap: () {
              _tabController.animateTo(Const.PKT_TODAY_UP);
            },
          ),

          //하락
          InkWell(
            child: Column(
              children: [
                const Text(
                  '하락',
                  style: TStyle.content14,
                ),
                Text(
                  _pock11.downCnt,
                  style: TStyle.commonTitle,
                ),
              ],
            ),
            onTap: () {
              _tabController.animateTo(Const.PKT_TODAY_DN);
            },
          ),

          //매매신호
          InkWell(
            child: Column(
              children: [
                const Text(
                  '매매신호',
                  style: TStyle.content14,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _pock11.sigBuyCnt,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: RColor.sigBuy,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      _pock11.sigSellCnt,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: RColor.sigSell,
                      ),
                    ),
                  ],
                )
              ],
            ),
            onTap: () {
              _tabController.animateTo(Const.PKT_TODAY_TS);
            },
          ),

          //이슈
          InkWell(
            child: Column(
              children: [
                const Text(
                  '이슈',
                  style: TStyle.content14,
                ),
                Text(
                  _pock11.issueCnt,
                  style: TStyle.commonTitle,
                ),
              ],
            ),
            onTap: () {
              _tabController.animateTo(Const.PKT_TODAY_IS);
            },
          ),

          //특이사항
          InkWell(
            child: Column(
              children: [
                const Text(
                  '특이사항',
                  style: TStyle.content14,
                ),
                Text(
                  '${(int.tryParse(_pock11.chartCnt) ?? 0) + (int.tryParse(_pock11.supplyCnt) ?? 0)}',
                  style: TStyle.commonTitle,
                ),
              ],
            ),
            onTap: () {
              if ((int.tryParse(_pock11.supplyCnt) ?? 0) == 0 && (int.tryParse(_pock11.chartCnt) ?? 0) != 0) {
                _tabController.animateTo(Const.PKT_TODAY_CH);
              } else {
                _tabController.animateTo(Const.PKT_TODAY_SP);
              }
            },
          ),
        ],
      ),
    );
  }

  // 데이터 없음 + 회원이 포켓에 등록한 종목이 0개 > 종목을 추가해 보세요
  Widget _setAddStockView() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Image.asset(
            'images/main_item_icon_no1.png',
            height: 35,
          ),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            RString.tl_suggest_add_stock,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //마이 포켓 TODAY 리스트
  Widget _setPocketStatusList() {
    int itemCnt = 0;
    if (_tabSelectDiv[_currentTabIndex] == 'UP' ||
        _tabSelectDiv[_currentTabIndex] == 'DN' ||
        _tabSelectDiv[_currentTabIndex] == 'TS') {
      itemCnt = _pock10.stockList.length;
    } else if (_tabSelectDiv[_currentTabIndex] == 'IS') {
      itemCnt = _pock10.issueList.length;
    } else if (_tabSelectDiv[_currentTabIndex] == 'SP' || _tabSelectDiv[_currentTabIndex] == 'CH') {
      itemCnt = _pock10.sdList.length;
    }
    return ListView.builder(
      // addAutomaticKeepAlives: true,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.zero,
      itemCount: itemCnt,
      itemBuilder: (context, index) {
        return _itemBaseContainer(
          _selectMyPocketTile(index),
        );
      },
    );
  }

  Widget _itemBaseContainer(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 15.0,
      ),
      decoration: UIStyle.boxRoundFullColor16c(
        RColor.greyBox_f5f5f5,
      ),
      child: child,
    );
  }

  Widget _loadingView() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: SkeletonLoader(
          items: 1,
          period: const Duration(seconds: 2),
          highlightColor: const Color(
            0xffffffff,
          ),
          baseColor: RColor.greyBox_f5f5f5,
          direction: SkeletonDirection.ltr,
          builder: Container(
            width: double.infinity,
            height: 80,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: UIStyle.boxRoundFullColor16c(
              RColor.greyBox_f5f5f5,
            ),
            child: const SizedBox(
              height: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectMyPocketTile(int idx) {
    //상승,하락
    if (_tabSelectDiv[_currentTabIndex] == 'UP' || _tabSelectDiv[_currentTabIndex] == 'DN') {
      // 포켓명 : 나의 포켓, 나머지 : 종목홈_홈
      return InkWell(
        onTap: () {
          basePageState.goStockHomePage(
            _pock10.stockList[idx].stockCode,
            _pock10.stockList[idx].stockName,
            Const.STK_INDEX_HOME,
          );
        },
        child: TileUpAndDown(
          _pock10.stockList[idx],
          _setChartItem(_pock10.stockList[idx]),
        ),
      );
    }
    //매매신호
    else if (_tabSelectDiv[_currentTabIndex] == 'TS') {
      return TilePocketSig(_pock10.stockList[idx]);
    }
    //이슈
    else if (_tabSelectDiv[_currentTabIndex] == 'IS') {
      return TileStockIssue(_pock10.issueList[idx]);
    }
    //수급
    else if (_tabSelectDiv[_currentTabIndex] == 'SP') {
      return InkWell(
        child: TileSupplyAndDemand(_pock10.sdList[idx]),
        onTap: () async {
          await basePageState.goStockHomePage(
            _pock10.sdList[idx].stockCode,
            _pock10.sdList[idx].stockName,
            Const.STK_INDEX_HOME,
          );
        },
      );
    }
    //차트
    else if (_tabSelectDiv[_currentTabIndex] == 'CH') {
      return InkWell(
        child: TileStockChart(_pock10.sdList[idx]),
        onTap: () async {
          await basePageState.goStockHomePage(
            _pock10.sdList[idx].stockCode,
            _pock10.sdList[idx].stockName,
            Const.STK_INDEX_HOME,
          );
        },
      );
    }
    return const SizedBox();
  }

  Pock10ChartModel _setChartItem(StockPktChart item) {
    final List<FlSpot> listChartData = [];
    double chartYAxisMin = 0;
    double chartMarkLineYAxis = 0;
    Color chartLineColor = Colors.transparent;
    if (item.listChart.isNotEmpty) {
      listChartData.clear();
      var chartItem = item.listChart;
      chartMarkLineYAxis = double.parse(chartItem[0].tradePrc);
      for (int i = 0; i < chartItem.length; i++) {
        listChartData.add(FlSpot(i.toDouble(), double.parse(chartItem[i].tradePrc)));
        if (i == 0) {
          chartYAxisMin = double.parse(chartItem[0].tradePrc);
        } else {
          if (int.parse(chartItem[i].tradePrc) < chartYAxisMin) {
            chartYAxisMin = double.parse(chartItem[i].tradePrc);
          }
        }
      }
      if (chartMarkLineYAxis > double.parse(chartItem[chartItem.length - 1].tradePrc)) {
        chartLineColor = RColor.bgSell;
      } else {
        chartLineColor = RColor.bgBuy;
      }
    }

    return Pock10ChartModel(
      listChartData: listChartData,
      chartYAxisMin: chartYAxisMin,
      chartMarkLineYAxis: chartMarkLineYAxis,
      chartLineColor: chartLineColor,
    );
  }

  void _requestTrPocketToday() {
    _fetchPosts(
      TR.POCK11,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );

    _fetchPosts(
      TR.POCK10,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'selectDiv': _tabSelectDiv[_currentTabIndex],
        },
      ),
    );
  }

  reload() {
    // 결제됐을때 갱신해야 되는 부분들 정의 해주시면 됩니다.
    _requestTrPocketToday();
  }

  void _navigatorResultCheck(dynamic result) {
    if (result == 'cancel') {
      DLog.w('*** navigete cancel ***');
    } else {
      DLog.w('*** navigateRefresh');
      _requestTrPocketToday();
    }
  }

  Future<void> _fetchPosts(String trStr, String json) async {
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

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);

    if (trStr == TR.POCK10) {
      final TrPock10 resData = TrPock10.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pock10 = resData.retData!;
        DLog.d('d', _pock10.toString());

        if (resData.retData != null) {
          // _stockCount = int.parse(resData.retData.stockCount);
          // _pocketSn = resData.retData.pocketSn;
          _tabSelectDiv[_currentTabIndex] = _pock10.selectDiv;
        }
      } else {
        _pock10 = Pock10.emptyWithSelectDiv(_tabSelectDiv[_currentTabIndex]);
      }
      setState(() {
        _isLoading = false;
      });
    } else if (trStr == TR.POCK11) {
      final TrPock11 resData = TrPock11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        DLog.d('d', '$_showBottomBoard');
        _pock11 = resData.retData!;
        setState(() {
/*          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 10),
            curve: Curves.easeInOut,);*/
          if (!_showBottomBoard) _showBottomBoard = true;
        });
      }
    }
  }
}
