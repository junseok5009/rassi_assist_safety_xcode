import 'dart:async';
import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/models/tr_index/tr_index02.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue09.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi11.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi12.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi14.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi18.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/home/home_tile/home_tile_hot_theme.dart';
import 'package:rassi_assist/ui/home/market_tile/market_tile_today_issue.dart';
import 'package:rassi_assist/ui/home/market_tile/market_tile_today_market.dart';
import 'package:rassi_assist/ui/market/headline_now_page.dart';
import 'package:rassi_assist/ui/market/home_market_kos_chart.dart';
import 'package:rassi_assist/ui/market/related_news_page.dart';
import 'package:rassi_assist/ui/news/news_list_page.dart';
import 'package:rassi_assist/ui/news/news_tag_all_page.dart';
import 'package:rassi_assist/ui/test/today_feature_stock_list_page.dart';
import 'package:rassi_assist/ui/test/today_issue_timeline_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main/base_page.dart';

/// 2024.06
/// 마켓뷰 (sliver)
class SliverMarketNewWidget extends StatefulWidget {
  static const routeName = '/page_market_sliver';
  static const String TAG = "[SliverMarketWidget]";
  static const String TAG_NAME = '홈_마켓뷰';
  static const String LD_CODE = "LPB3";

  static final GlobalKey<SliverMarketWidgetState> globalKey = GlobalKey();

  SliverMarketNewWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverMarketWidgetState();
}

class SliverMarketWidgetState extends State<SliverMarketNewWidget> {
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = "";
  Index02 _index02 = const Index02();
  Issue09 _issue09 = const Issue09();

  List<MenuDiv> _listFeature = [];

  List<Rassi11> _pickTagList = []; //이 시간 PICK
  List<Rassi12> _reportList = []; //분석리포트
  List<Rassiro> _newsList = [];
  final List<Rassi14> _relayList = []; // AI가 찾은 추천정보 > 관련된 최근 소식

  List<bool> isSelected = [true, false, false];
  bool _relayMoreBtnShow = true;
  String _aiSelectType = 'INVESTOR';
  final List<TagEvent> _recomTagList = [];

  int pageNum = 0;

  bool prTOP = false, prHGH = false, prMID = false, prLOW = false;
  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverMarketNewWidget.TAG_NAME);
    _loadPrefData().then(
      (_) {
        _fetchPosts(
          TR.ISSUE09,
          jsonEncode(
            <String, String>{
              'userId': _userId,
              'issueDate': TStyle.getTodayString(),
            },
          ),
        );
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? appGlobal.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _setPrTop(),

              const SizedBox(height: 10),
              //오늘의 이슈
              if (_issue09.listData.isNotEmpty)
                MarketTileTodayIssue(
                  issue09: _issue09,
                ),
              const SizedBox(height: 30),

              _setTimelineBanner(),

              CommonView.setDivideLine,
              const SizedBox(height: 10),

              //오늘 시장은
              _setSubTitleMore('오늘 시장은', '더보기', _showSheetMarketChart),
              MarketTileTodayMarket(index02: _index02),
              const SizedBox(height: 25),

              //오늘의 특징주 빠르게 보기
              _setFeatureStocks(),
              const SizedBox(height: 25),

              CommonView.setDivideLine,

              //이 시간 핫 테마
              const HomeTileHotTheme(),

              CommonView.setDivideLine,

              //이 시간 헤드라인
              _setCurrentHeadline(),
              const SizedBox(height: 5),

              _setPrHigh(),
              const SizedBox(height: 5),

              //실시간 속보
              _setNewsList(),
              const SizedBox(height: 15),

              CommonView.setDivideLine,

              //AI 가 찾은 추천 정보
              _setRecomInfo(),
              const SizedBox(height: 25),

              CommonView.setDivideLine,

              _setPrMid(),

              //분석리포트
              _setAnlReport(),

              CommonView.setDivideLine,
              const SizedBox(height: 10),

              _setPrLow(),

              _setNewsAllTagBtn(),
              const SizedBox(height: 30),
            ]),
          ),
        ],
      ),
    );
  }

  // 시장 지수 상세페이지
  void _showSheetMarketChart() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height - AppGlobal().deviceStatusBarHeight,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          /*borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
              ),*/
        ),
        child: const HomeMarketKosChartPage(),
      ),
    );
  }

  // 오늘의 특징주 보기
  Widget _setFeatureStocks() {
    return Column(
      children: [
        _setSubTitleMore('오늘의 특징주 빠르게 보기', '', () {}),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _listFeature.length,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 55,
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 17.0),
                  alignment: Alignment.centerLeft,
                  decoration: UIStyle.boxRoundFullColor10c(RColor.greyBox_f5f5f5),
                  child: InkWell(
                    splashColor: Colors.deepPurpleAccent.withAlpha(30),
                    child: Container(
                      width: double.infinity,
                      height: 53,
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _setFeatureText(_listFeature[index]),
                                style: TStyle.content16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const ImageIcon(
                            AssetImage('images/main_my_icon_arrow.png'),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        TodayFeatureStockListPage.routeName,
                        arguments: _listFeature[index].menuDiv,
                      );
                    },
                  ),
                );
              }),
        )
      ],
    );
  }

  String _setFeatureText(MenuDiv item) {
    var content = '';
    if (item.content.isEmpty) {
      content = '종목이 없습니다.';
    } else {
      content = item.content;
    }
    if (item.menuDiv == 'REAL') return '실시간 특징주 발생 $content';
    if (item.menuDiv == 'WEEK52') return '52주 신고가 돌파 $content';
    if (item.menuDiv == 'LIMIT') return '상한가 발생 $content';
    if (item.menuDiv == 'CHANGE') return '손바뀜 종목 $content';
    return '';
  }

  // 타임라인 배너
  Widget _setTimelineBanner() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, TodayIssueTimelinePage.routeName);
      },
      child: Container(
        width: double.infinity,
        height: AppGlobal().isTablet ? 150 : 130,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: UIStyle.boxWithOpacity16(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 이슈 타임라인', style: TStyle.commonTitle),
                SizedBox(height: 10),
                Text('날짜별 모든 이슈를\n확인해보세요'),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'images/icon_calendar_dec.png',
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //이 시간 헤드라인
  Widget _setCurrentHeadline() {
    return Column(
      children: [
        _setSubTitleMore('이시간 헤드라인', '더보기', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeadlineNowPage(),
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pickTagList.length,
            itemBuilder: (context, index) {
              return TileRassi11(_pickTagList[index]);
            },
          ),
        ),
      ],
    );
  }

  // 실시간 속보
  Widget _setNewsList() {
    return Column(
      children: [
        _setSubTitleMore('실시간 속보', '더보기', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewsListPage(),
            ),
          );
        }),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                return TileRassi01(_newsList[index]);
              }),
        ),
      ],
    );
  }

  // AI 가 찾은 추천정보
  Widget _setRecomInfo() {
    return Column(
      children: [
        _setSubTitleMore('AI가 찾은 추천 정보', '', () {}),
        const SizedBox(height: 20),

        //투자자동향/큰손매매/시장핫종목
        Container(
          margin: const EdgeInsets.only(left: 20, right: 10),
          child: LayoutBuilder(builder: (context, constraints) {
            return ToggleButtons(
              isSelected: isSelected,
              color: Colors.blue,
              selectedColor: Colors.black,
              fillColor: Colors.transparent,
              constraints: BoxConstraints.expand(width: constraints.maxWidth / 3),
              renderBorder: false,
              splashColor: Colors.transparent,
              children: <Widget>[
                _buildRecomButton('장중투자자동향', isSelected[0]),
                _buildRecomButton('큰손매매', isSelected[1]),
                _buildRecomButton('시장핫종목', isSelected[2]),
              ],
              onPressed: (int index) {
                setState(() {
                  isSelected = List.generate(
                    isSelected.length,
                    (i) => i == index,
                  );
                  pageNum = 0;
                  if (index == 0) _aiSelectType = 'INVESTOR';
                  if (index == 1) _aiSelectType = 'AGENCY';
                  if (index == 2) _aiSelectType = 'HOT_STOCK';
                });
                _requestRassi14();
              },
            );
          }),
        ),
        const SizedBox(height: 25),

        //태그 리스트
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recomTagList.length,
              itemBuilder: (context, index) {
                return TileTagStock(_recomTagList[index]);
              }),
        ),
        const SizedBox(height: 25),

        //관련 ai속보 더보기 버튼
        Visibility(
            visible: _relayMoreBtnShow,
            child: InkWell(
              child: Container(
                width: double.infinity,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: UIStyle.boxRoundLine6bgColor(Colors.white),
                child: const Center(
                  child: Text(
                    "관련 속보와 종목 모두 보기",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RelatedNewsPage(),
                    settings: RouteSettings(
                      arguments: PgData(pgData: _aiSelectType),
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildRecomButton(String label, bool bSelect) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: bSelect ? UIStyle.boxBtnSelected() : UIStyle.boxRoundLine10c(RColor.lineGrey),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: bSelect ? TStyle.subTitle : TStyle.contentGrey14,
        ),
      ),
    );
  }

  // 분석리포트
  Widget _setAnlReport() {
    List<List<Rassi12>> tempList = [];
    if (_reportList.isNotEmpty) {
      int dSize = 4;
      tempList = List.generate(
        (_reportList.length / dSize).ceil(),
        (index) => _reportList.sublist(
            index * dSize, (index * dSize + dSize > _reportList.length) ? _reportList.length : index * dSize + dSize),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '분석 리포트',
              style: TStyle.defaultTitle,
            ),
          ),
          Container(
            width: double.infinity,
            height: 390,
            margin: const EdgeInsets.only(top: 15),
            child: Swiper(
              controller: SwiperController(),
              pagination: CommonSwiperPagenation.getNormalSpWithMargin(8.0, 370, Colors.black),
              loop: false,
              autoplay: false,
              onIndexChanged: (int index) {},
              itemCount: tempList.length,
              itemBuilder: (BuildContext context, int index) {
                return TileSwpRassi12(tempList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 모든 태그를 확인해 보세요
  Widget _setNewsAllTagBtn() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Text(
            'AI가 분석하는 모든 태그\n분류를 확인해 보세요',
            style: TStyle.defaultTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          CommonView.setBasicMoreRoundBtnView(
            [
              // Text(
              //   "→ 태그",
              //   style: TStyle.puplePlainStyle(),
              // ),
              const Text(
                "+ 태그 전체보기",
                style: TStyle.commonSTitle,
              ),
            ],
            () {
              basePageState.callPageRouteUP(
                NewsTagAllPage(),
              );
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // 프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: prTOP,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrTop),
      ),
    );
  }

  // 프로모션 - 상단
  Widget _setPrHigh() {
    if (prHGH) {
      return Visibility(
        visible: prHGH,
        child: SizedBox(
          width: double.infinity,
          height: 110,
          child: CardProm02(_listPrHgh),
        ),
      );
    } else {
      return CommonView.setDivideLine;
    }
  }

  // 프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: prMID,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrMid),
      ),
    );
  }

  // 프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: prLOW,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrLow),
      ),
    );
  }

  // 소항목 타이틀
  Widget _setSubTitleMore(String title, String moreTxt, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TStyle.defaultTitle,
          ),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(
                moreTxt,
                style: const TextStyle(
                  color: RColor.greyMore_999999,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestRassi14() {
    DLog.d(SliverMarketNewWidget.TAG, '_requestRassi14() pageNum : $pageNum');
    _fetchPosts(
        TR.RASSI14,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': _aiSelectType,
          'pageNo': pageNum.toString(),
          'pageItemSize': pageNum == 0 ? '3' : '5',
        }));
  }

  reload() {
    _fetchPosts(
      TR.ISSUE09,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'issueDate': TStyle.getTodayString(),
        },
      ),
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverMarketNewWidget.TAG, '$trStr $json');

    // var url = Uri.parse(Net.TR_BASE_android + trStr); //NOTE ***[TEST]***
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
      DLog.d(SliverMarketNewWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverMarketNewWidget.TAG, response.body);

    // NOTE 날짜의 이슈(버블차트 이슈)
    if (trStr == TR.ISSUE09) {
      final TrIssue09 resData = TrIssue09.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _issue09 = resData.retData;
        setState(() {});
      }
      _fetchPosts(
        TR.PROM02,
        jsonEncode(
          <String, String>{
            'userId': _userId,
            'viewPage': LD.market_page,
            'promoDiv': '',
          },
        ),
      );
    } else if (trStr == TR.PROM02) {
      //탭이동을 홈으로 초기화(setState 필요)
      Provider.of<PageNotifier>(context, listen: false).setPageData(0);
      _listPrTop.clear();
      _listPrHgh.clear();
      _listPrMid.clear();
      _listPrLow.clear();
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
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
          if (_listPrTop.isNotEmpty) prTOP = true;
          if (_listPrHgh.isNotEmpty) prHGH = true;
          if (_listPrMid.isNotEmpty) prMID = true;
          if (_listPrLow.isNotEmpty) prLOW = true;
        });
      }

      _fetchPosts(
          TR.INDEX02,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //코스피 코스닥 차트
    else if (trStr == TR.INDEX02) {
      final TrIndex02 resData = TrIndex02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _index02 = resData.retData;
      } else {
        _index02 = const Index02();
      }
      setState(() {});

      _fetchPosts(
          TR.RASSI18,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //특징주 빠르게 보기
    else if (trStr == TR.RASSI18) {
      final TrRassi18 resData = TrRassi18.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listFeature = resData.listData;
        setState(() {});
      }

      _fetchPosts(
          TR.RASSI01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': '0',
            'pageItemSize': '3',
          }));
    }

    //라씨로 일반 뉴스
    else if (trStr == TR.RASSI01) {
      final TrRassi01 resData = TrRassi01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _newsList = resData.listData;

        setState(() {});
      }

      _fetchPosts(
          TR.RASSI11,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': '0',
            'pageItemSize': '5',
          }));
    }

    //이 시간 헤드라인 (라씨로 PICK)
    else if (trStr == TR.RASSI11) {
      final TrRassi11 resData = TrRassi11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pickTagList = resData.listData;
        setState(() {});
      }

      _fetchPosts(
          TR.RASSI12,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //라씨 분석 리포트
    else if (trStr == TR.RASSI12) {
      TrRassi12 resData = TrRassi12.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _reportList = resData.listData;
      }

      _fetchPosts(
          TR.RASSI14,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': _aiSelectType,
            'pageNo': pageNum.toString(),
            'pageItemSize': '10',
          }));
    }

    //AI가 찾은 추천 정보 조회
    else if (trStr == TR.RASSI14) {
      _relayList.clear();
      final TrRassi14 resData = TrRassi14.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _relayMoreBtnShow = true;
        if (pageNum == 0) {
          _recomTagList.clear();
          _recomTagList.addAll(resData.listTag);
          _relayList.clear();
        }
        _relayList.addAll(resData.listData);
        setState(() {});
      } else {
        _relayMoreBtnShow = false;
      }
    }
  }
}
