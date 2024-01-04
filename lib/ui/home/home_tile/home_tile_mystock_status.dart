import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/home/sliver_home_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/strings.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/tr_pock/tr_pock09.dart';
import '../../common/common_view.dart';

/// [홈_홈 나의 종목 현황] - 2023.09.07 HJS
class HomeTileMystockStatus extends StatefulWidget {
  const HomeTileMystockStatus({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeTileMystockStatus> createState() => HomeTileMystockStatusState();
}

class HomeTileMystockStatusState extends State<HomeTileMystockStatus>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late SharedPreferences _prefs;
  final AppGlobal _appGlobal = AppGlobal();
  String _userId = '';
  bool _isLoading = true;

  late Pock09 _pock09;
  int _stockCount = 0; // 회원의 모든 포켓 안에 담겨 있는 종목의 개수
  String _pocketSn = '';

  int _currentTabIndex = 0; // 현재 탭뷰 인덱스
  late TabController _tabController;
  final List<String> _tabTitles = [
    '상승',
    '하락',
    '매매신호',
    '종목소식',
    'AI속보',
  ];
  final List<String> _tabSelectDiv = [
    'UP',
    'DN',
    'TS',
    'SB',
    'RN',
  ];

  initPage() {
    _requestTrPock09();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging &&
        _tabController.index != _tabController.previousIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _isLoading = true;
      });
      _requestTrPock09();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _tabController =
        TabController(length: 5, vsync: this, initialIndex: _currentTabIndex);
    _tabController.addListener(_handleTabSelection);
    _loadPrefData().then((_) {
      initPage();
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
    super.dispose();
  }

  /*@override
  bool get wantKeepAlive => true;*/

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '내 종목 현황',
                style: TStyle.title18T,
              ),
              InkWell(
                onTap: () async {
                  // [포켓 > TODAY > 같은 상승, 하락 ... 탭으로 이동]
                  basePageState.goPocketPage(Const.PKT_INDEX_TODAY, todayIndex: 0,);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    color: RColor.greyMore_999999,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15.0,
          ),
          Center(
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.transparent,
              controller: _tabController,
              tabs: _makeTabs(),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 10,
            ),
            child: (() {
              if (_isLoading) {
                if (_stockCount == 0) {
                  return const SizedBox(
                    height: 117,
                  );
                } else {
                  return _loadingView();
                }
              } else {
                if (_pock09 == null) {
                  return _itemBaseContainer(
                    CommonView.setNoDataTextView(
                      80,
                      '데이터가 없습니다.',
                    ),
                  );
                } else if (_pock09.beforeOpening == 'Y') {
                  return _itemBaseContainer(
                    CommonView.setNoDataTextView(
                      80,
                      '장 시작 전 입니다.',
                    ),
                  );
                } else if (_pock09.isEmpty()) {
                  if (_stockCount == 0) {
                    return _setAddStockView();
                  } else {
                    return _itemBaseContainer(
                      CommonView.setNoDataTextView(
                        80,
                        _pock09.getEmptyTitle(),
                      ),
                    );
                  }
                } else {
                  return _setPocketStatusList();
                }
              }
            })(),
          ),
          _setAddStockBtn(),
          _setBannerRobot(),
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

  //마이 포켓 현황 리스트
  Widget _setPocketStatusList() {
    int itemCnt = 0;
    if (_tabSelectDiv[_currentTabIndex] == 'UP' ||
        _tabSelectDiv[_currentTabIndex] == 'DN' ||
        _tabSelectDiv[_currentTabIndex] == 'TS') {
      itemCnt = _pock09.stockList.length;
    } else if (_tabSelectDiv[_currentTabIndex] == 'SB' ||
        _tabSelectDiv[_currentTabIndex] == 'RN') {
      itemCnt = _pock09.pushList.length;
    }
    return SingleChildScrollView(
      child: ListView.builder(
        addAutomaticKeepAlives: true,
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
      ),
    );
  }

  Widget _itemBaseContainer(Widget child) {
    return Container(
      width: double.infinity,
      decoration: UIStyle.boxRoundFullColor16c(
        RColor.greyBox_f5f5f5,
      ),
      margin: const EdgeInsets.only(
        top: 15.0,
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
    if (_tabSelectDiv[_currentTabIndex] == 'UP' ||
        _tabSelectDiv[_currentTabIndex] == 'DN') {
      return InkWell(
        child: TileUpAndDown(
          _pock09.stockList[idx],
          _setChartItem(_pock09.stockList[idx]),
        ),
        onTap: () async {
          if (_pock09.stockList[idx] != null) {
            // [포켓 > TODAY > 같은 상승, 하락 ... 탭으로 이동]
            // > 종목홈으로 이동
            StockPktChart item = _pock09.stockList[idx];
            basePageState.goStockHomePage(item.stockCode, item.stockName,  Const.STK_INDEX_HOME,);
          }
        },
      );
    } else if (_tabSelectDiv[_currentTabIndex] == 'TS') {
      return InkWell(
        child: TilePocketSig(_pock09.stockList[idx]),
        onTap: () async {
          //포켓상세로 이동
          if (_pock09.stockList[idx] != null) {
            // [포켓 > TODAY > 같은 상승, 하락 ... 탭으로 이동]
            // > 종목홈으로 이동
            StockPktChart item = _pock09.stockList[idx];
            basePageState.goStockHomePage(item.stockCode, item.stockName,  Const.STK_INDEX_SIGNAL,);
          }
        },
      );
    } else if (_tabSelectDiv[_currentTabIndex] == 'SB') {
      return InkWell(
        child: TileStockPush(_pock09.pushList[idx]),
        onTap: () {
          basePageState.goStockHomePage(
            _pock09.pushList[idx].stockCode,
            _pock09.pushList[idx].stockName,
            Const.STK_INDEX_HOME,
          );
        },
      );
    } else if (_tabSelectDiv[_currentTabIndex] == 'RN') {
      return InkWell(
        child: TileStockNews(_pock09.pushList[idx]),
        onTap: () {
          var item = _pock09.pushList[idx];
          basePageState.callPageRouteNews(
            const NewsViewer(),
            PgNews(
              stockCode: item.stockCode,
              stockName: item.stockName,
              newsSn: item.newsSn,
              createDate: item.newsCrtDate,
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Pock09ChartModel _setChartItem(StockPktChart item) {
    final List<FlSpot> listChartData = [];
    double chartYAxisMin = 0;
    double chartMarkLineYAxis = 0;
    Color chartLineColor = Colors.transparent;
    if (item.listChart.isNotEmpty) {
      listChartData.clear();
      var chartItem = item.listChart;
      chartMarkLineYAxis = double.parse(chartItem[0].tradePrc);
      for (int i = 0; i < chartItem.length; i++) {
        listChartData
            .add(FlSpot(i.toDouble(), double.parse(chartItem[i].tradePrc)));
        if (i == 0) {
          chartYAxisMin = double.parse(chartItem[0].tradePrc);
        } else {
          if (int.parse(chartItem[i].tradePrc) < chartYAxisMin) {
            chartYAxisMin = double.parse(chartItem[i].tradePrc);
          }
        }
      }
      if (chartMarkLineYAxis >
          double.parse(chartItem[chartItem.length - 1].tradePrc)) {
        chartLineColor = RColor.bgSell;
      } else {
        chartLineColor = RColor.bgBuy;
      }
    }

    return Pock09ChartModel(
      listChartData: listChartData,
      chartYAxisMin: chartYAxisMin,
      chartMarkLineYAxis: chartMarkLineYAxis,
      chartLineColor: chartLineColor,
    );
  }

  // 종목 추가
  Widget _setAddStockBtn() {
    return InkWell(
      onTap: () async {
        _navigatorResultCheck(
          await Navigator.push(
            context,
            CustomNvRouteClass.createRoute(
                SearchPage.goLayer(SearchPage.landAddPocketLayer, _pocketSn)),
          ),
        );
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          top: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: RColor.greyTitle_cdcdcd,
                    width: 1.4,
                  ),
                ),
                padding: const EdgeInsets.all(
                  2,
                ),
                alignment: Alignment.center,
                child: const Center(
                  child: Text(
                    '+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RColor.greyTitle_cdcdcd,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              '종목추가',
            )
          ],
        ),
      ),
    );
  }

  //무료 사용자 배너
  Widget _setBannerRobot() {
    return Visibility(
      visible: _appGlobal.isFreeUser,
      //visible: false,
      child: InkWell(
        child: Container(
          width: double.infinity,
          height: 110.0,
          margin: const EdgeInsets.only(top: 20.0),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 15,
          ),
          decoration: UIStyle.boxRoundFullColor6c(
            const Color(
              0xffE7E7FF,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '종목 제한없이',
                      style: TextStyle(
                        color: RColor.mainColor,
                        fontSize: 12,
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'AI매매신호 실시간 알림 받기',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Image.asset(
                'images/img_robot.png',
                fit: BoxFit.cover,
                scale: 4,
              ),
            ],
          ),
        ),
        onTap: () {
          SliverHomeWidgetState? parent =
              context.findAncestorStateOfType<SliverHomeWidgetState>();
          parent?.showDialogPremium();
        },
      ),
    );
  }

  void _requestTrPock09() {
    _fetchPosts(
      TR.POCK09,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'selectDiv': _tabSelectDiv[_currentTabIndex],
        },
      ),
    );
  }

  void _navigatorResultCheck(dynamic result) {
    if (result == 'cancel') {
      DLog.w('*** navigete cancel ***');
    } else {
      DLog.w('*** navigateRefresh');
      _requestTrPock09();
    }
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.POCK09) {
      final TrPock09 resData = TrPock09.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pock09 = resData.retData!;
        if (resData.retData != null) {
          _stockCount = int.parse(_pock09.stockCount);
          _pocketSn = _pock09.pocketSn;
          //_tabSelectDiv[_currentTabIndex] = _pock09.selectDiv;
        }
      } else {
        _pock09 = Pock09.emptyWithSelectDiv(_tabSelectDiv[_currentTabIndex]);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
}
