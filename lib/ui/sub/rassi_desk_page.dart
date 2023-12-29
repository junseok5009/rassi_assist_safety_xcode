import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi17.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/const.dart';
import '../../models/rassiro.dart';
import '../main/base_page.dart';
import '../news/news_viewer.dart';

class RassiDeskPage extends StatefulWidget {
  const RassiDeskPage({Key? key}) : super(key: key);
  static const String TAG = "[RassiDeskPage]";
  static const String TAG_NAME = 'PM6시_라씨데스크';

  @override
  State<RassiDeskPage> createState() => _RassiDeskPageState();
}

class _RassiDeskPageState extends State<RassiDeskPage>
    with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  String _isNoData = ''; // 카드 없을 때 ==> 화면 전체 No Data
  String _isNoDataAiNews = ''; // 관련 AI속보 없을 때
  String _userId = '';
  String _stockCode = '';
  String _stockName = '';

  int _currentTabIndex = 0; // 현재 탭뷰 인덱스
  late TabController _tabController;
  final List<String> _tabTitles = [
    '시간외 거래 급등주',
    '외국인 순매수 상위 20종목',
    '기관 순매수 상위 20종목',
    '외국인 순매도 상위 20종목',
    '기관 순매도 상위 20종목',
  ];

  final SwiperController _swiperController = SwiperController();
  final List<Rassi17Stock> _stockList = [];
  final List<Rassiro> _newsList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      RassiDeskPage.TAG_NAME,
    );
    _tabController =
        TabController(length: 5, vsync: this, initialIndex: _currentTabIndex);
    _tabController.addListener(_handleTabSelection);
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            if (_userId != '') {
              _requestTrRassi17();
            }
          }),
        });
  }

  @override
  void dispose() {
    _bYetDispose = false;
    _swiperController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: RColor.new_basic_box_grey,
        title: const Text(
          'PM6시 30분 라씨데스크',
          style: TStyle.title18T,
        ),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        leadingWidth: 25,
      ),
      body: SafeArea(
        child: _isNoData == 'Y' || _isNoData == 'N'
            ? Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    color: RColor.new_basic_box_grey,
                    child: TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      controller: _tabController,
                      tabs: _makeTabs(),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isNoData == 'N'
                        ? CustomScrollView(
                            scrollDirection: Axis.vertical,
                            slivers: [
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    Container(
                                      color: RColor.new_basic_box_grey,
                                      child: Column(
                                        children: [
                                          _setCardView(),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              _showStockSelectDialog();
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.add_circle,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                  Text(
                                                    ' 관련 종목 전체 보기',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 20, 15, 5),
                                      child: Text(
                                        '관련 AI 속보',
                                        style: TStyle.title18T,
                                      ),
                                    ),
                                    _setAiNewsView(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            alignment: Alignment.center,
                            color: RColor.new_basic_box_grey,
                            child: Text(
                                '${_tabTitles[_currentTabIndex]} 종목이 없습니다.'),
                          ),
                  ),
                ],
              )
            : const SizedBox(),
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
            height: 50,
            child: Container(
              decoration: UIStyle.boxRoundFullColor25c(Colors.black),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      } else {
        tabs.add(
          Tab(
            height: 50,
            child: Text(
              value,
              style: const TextStyle(
                color: RColor.new_basic_text_color_strong_grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    });
    return tabs;
  }

  Widget _setCardView() {
    return SizedBox(
      width: double.infinity,
      height: AppGlobal().isTablet
          ? MediaQuery.of(context).size.width * 3 / 4
          : 400,
      child: Swiper(
        itemCount: _stockList.length,
        itemWidth: MediaQuery.of(context).size.width -
            (AppGlobal().isTablet ? 120 : 50),
        layout: SwiperLayout.STACK,
        axisDirection: AxisDirection.right,
        controller: _swiperController,
        onIndexChanged: (changedIndex) {
          _stockCode = _stockList[changedIndex].stockCode;
          _stockName = _stockList[changedIndex].stockName;
          //_requestTrRassi02();
        },
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              /*border: Border.all(
                //color: RColor.mainColor,
                //width: 1,
              ),*/
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 4, //그림자 효과의 반경, 설정 값이 높을 수록 넓어진다.
                  blurRadius: 6, //그림자 효과를 흐리게 해줌, 0일 수록 그림자 선이 선명해짐
                  offset: const Offset(2,
                      1), //x,y의 offset값으로 x의 숫자가 커질수록 오른쪽으로, y의 숫자가 커질수록 아래로 이동하여 표시된다.
                )
              ],
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _stockList[index].stockName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              _stockList[index].stockCode,
                              style: const TextStyle(
                                color: RColor.new_basic_text_color_grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Icon(
                              Icons.home_outlined,
                              color: Colors.black,
                              size: 22,
                            ),
                          ],
                        ),
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              TStyle.getMoneyPoint(
                                  _stockList[index].currentPrice),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: TStyle.getMinusPlusColor(
                                  _stockList[index].fluctuationRate,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              TStyle.getTriangleStringWithMoneyPoint(
                                _stockList[index].fluctuationAmt,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: TStyle.getMinusPlusColor(
                                  _stockList[index].fluctuationRate,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              TStyle.getPercentString(
                                _stockList[index].fluctuationRate,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: TStyle.getMinusPlusColor(
                                  _stockList[index].fluctuationRate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    basePageState.goStockHomePage(
                      _stockList[index].stockCode,
                      _stockList[index].stockName,
                      Const.STK_INDEX_HOME,
                    );
                  },
                ),
                //const SizedBox(height: 4,),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: AppGlobal().isTablet
                        ? const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          )
                        : null,
                    child: Image.network(
                      "https://webchart.thinkpool.com/rassiro/stock1day30big/A${_stockList[index].stockCode}.png",
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      //fit: AppGlobal().isTablet ? BoxFit.contain : BoxFit.fill,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  //height: _currentTabIndex == 0 ? 5 : 26,
                  height: 5,
                ),
                Container(
                  alignment: Alignment.center,
                  //height: _currentTabIndex == 0 ? 93 : 72,
                  height: 93,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: RColor.bgWeakGrey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: _currentTabIndex == 0
                      ? _setCardViewTab1(_stockList[index])
                      : _setCardViewTab2(_stockList[index]),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _setAiNewsView() {
    if (_isNoDataAiNews == 'Y') {
      return Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: UIStyle.boxRoundFullColor10c(
          RColor.new_basic_box_grey,
        ),
        child: const Center(
          child: Text('관련 AI 속보가 없습니다.'),
        ),
      );
    }
    return ListView.builder(
      itemCount: _newsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            padding: const EdgeInsets.all(15),
            decoration: UIStyle.boxRoundLine10c(
              RColor.new_basic_line_grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_newsList[index].title),
                Text(
                  TStyle.getDateTdFormat(_newsList[index].issueDttm),
                ),
              ],
            ),
          ),
          onTap: () {
            basePageState.callPageRouteNews(
              const NewsViewer(),
              PgNews(
                stockCode: '',
                stockName: '',
                newsSn: _newsList[index].newsSn,
                createDate: _newsList[index].newsCrtDate,
              ),
            );
          },
        );
      },
    );
  }

  // DEFINE 시간외 거래 급등주
  Widget _setCardViewTab1(Rassi17Stock item) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('시간외 종가'),
            Text(
              '${TStyle.getMoneyPoint(
                item.afterHourClose,
              )}원',
              style: TextStyle(
                color: TStyle.getMinusPlusColor(item.afterHourFluctRate),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('시간외 등락률'),
            Text(
              TStyle.getPercentString(item.afterHourFluctRate),
              style: TextStyle(
                color: TStyle.getMinusPlusColor(item.afterHourFluctRate),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('시간외 거래량'),
            Text(
              '${TStyle.getMoneyPoint(item.afterHourVol)}주',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // DEFINE 외국인
  Widget _setCardViewTab2(Rassi17Stock item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentTabIndex == 2 || _currentTabIndex == 4
                  ? '기관 순매매량'
                  : '외국인 순매매량',
            ),
            Text(
              '${TStyle.getMoneyPoint(item.netVol)}주',
              style: TextStyle(
                color: TStyle.getMinusPlusColor(item.netVol),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentTabIndex == 2 || _currentTabIndex == 4
                  ? '기관 순매매금액'
                  : '외국인 순매매금액',
            ),
            Text(
              '${TStyle.getMoneyPoint(item.netAmt)}억원',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _tabController.previousIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _requestTrRassi17();
    }
  }

  _showStockSelectDialog() {
    // auto height 레이어
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              _setStockSelectDialogView(),
            ],
          ),
        );
      },
    );
  }

  Widget _setStockSelectDialogView() {
    return SafeArea(
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
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          Text(
            '${_tabTitles[_currentTabIndex]} 관련 종목',
            style: TStyle.title19T,
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 20,
              left: 5,
              right: 5,
            ),
            width: double.infinity,
            child: Wrap(
              spacing: 10.0,
              alignment: WrapAlignment.center,
              children: List.generate(
                _stockList.length,
                (index) => _makeSelectStockBox(index),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _makeSelectStockBox(int index) {
    var item = _stockList[index];
    if (item.stockCode == _stockCode) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
        decoration: UIStyle.boxBtnSelectedMainColor6Cir(),
        child: Text(
          item.stockName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          setState(() {
            _stockCode = item.stockCode;
            _stockName = item.stockName;
            _swiperController.move(
              index,
              animation: true,
            );
          });
          Navigator.of(context).pop(null);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
          decoration: UIStyle.boxRoundLine6(),
          child: Text(item.stockName),
        ),
      );
    }
  }

  _requestTrRassi17() async {
    _fetchPosts(
      TR.RASSI17,
      jsonEncode(
        <String, String>{
          "userId": _userId,
          "menuDiv":
              "${_currentTabIndex == 0
                  ? 5
                  : _currentTabIndex == 1
                  ? 1
                  : _currentTabIndex == 2
                  ? 3
                  : _currentTabIndex == 3
                  ? 2
                  : _currentTabIndex == 4
                  ? 4
                  : 5
              }",
        },
      ),
    );
  }

  void _fetchPosts(String trStr, String json) async {
    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.RASSI17) {
      final TrRassi17 resData = TrRassi17.fromJson(jsonDecode(response.body));
      final Rassi17 rassi17 = resData.retData;
      _isNoData = 'Y';
      _isNoDataAiNews = 'Y';
      _stockList.clear();
      _newsList.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (rassi17.stockList.isNotEmpty) {
          _isNoData = 'N';
          _stockList.addAll(
            rassi17.stockList,
          );
          _stockCode = _stockList[0].stockCode;
          _stockName = _stockList[0].stockName;
          _swiperController.move(
            0,
            animation: false,
          );
        }
        if (rassi17.newsList.isNotEmpty) {
          _isNoDataAiNews = 'N';
          _newsList.addAll(
            rassi17.newsList,
          );
        }
      }
      setState(() {});
    }
  }
}
