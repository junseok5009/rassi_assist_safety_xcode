import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bubble_chart/bubble_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/models/tr_index01.dart';
import 'package:rassi_assist/models/tr_issue03.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi11.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi12.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi14.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi15.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/news/issue_list_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
import 'package:rassi_assist/ui/news/news_list_page.dart';
import 'package:rassi_assist/ui/news/news_tag_all_page.dart';
import 'package:rassi_assist/ui/sub/home_market_kos_chart.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_time_line_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main/base_page.dart';

/// 2022.04.20 - JY
/// 마켓뷰 (sliver)
class SliverMarketWidget extends StatefulWidget {
  static const routeName = '/page_market_sliver';
  static const String TAG = "[SliverMarketWidget]";
  static const String TAG_NAME = '홈_마켓뷰';
  static const String LD_CODE = "LPB3";

  const SliverMarketWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverMarketWidgetState();
}

class SliverMarketWidgetState extends State<SliverMarketWidget> {
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  // DEFINE 코스피 / 코스닥
  String _kospiSub = "";
  Color _kospiColor = Colors.grey;
  String _kosdaqSub = "";
  Color _kosdaqColor = Colors.grey;
  Index01 _index01 = defIndex01;

  String _issueDate = "";
  List<Issue03> _issueList = []; //오늘의 이슈
  List<Rassi11> _pickTagList = []; //이 시간 PICK
  List<Rassi12> _reportList = []; //분석리포트
  final List<TagNew> _hidingTagList = []; //숨어있는 정보 태그
  final List<TagNew> _rapidTagList = []; //빠른 정보 태그
  List<Rassiro> _newsList = [];
  final List<Rassi14> _relayList = []; // AI가 찾은 추천정보 > 관련된 최근 소식

  bool _bSelectA = true, _bSelectB = false, _bSelectC = false;
  bool _relayMoreBtnShow = true;
  String _aiSelectType = 'INVESTOR';
  final List<TagEvent> _recomTagList = [];

  int pageNum = 0;

  bool prTOP = false, prHGH = false, prMID = false, prLOW = false;
  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];

  AlignmentGeometry _alignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverMarketWidget.TAG_NAME);
    _loadPrefData().then(
      (value) {
        if (_userId != '') {
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
        }
      },
    );
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
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
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _setMarketIndex(),
            _setPrTop(),

            Container(
              color: RColor.bgWeakGrey,
              height: 12,
            ),

            //오늘의 이슈
            _setTodayIssueBubble(),

            _setRassiDeskBanner(),

            //이 시간 PICK
            _setCurrentPick(),

            _setPrHigh(),
            const SizedBox(
              height: 25.0,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSubTitle('이 시간 AI속보', ''),
                  InkWell(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsListPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            _setNewsList(),
            const SizedBox(
              height: 25.0,
            ),

            Container(
              color: RColor.bgWeakGrey,
              height: 12,
            ),

            //_setMoreButton('+이 시간 AI속보', 'news', ' 더보기'), > _더보기 추가로 인해 삭제

            //AI 가 찾은 추천 정보
            _setRecomInfo(),

            Padding(
              padding: const EdgeInsets.only(left: 10, top: 0),
              child: _setSubTitle('관련된 최근 소식', ''),
            ),
            _setRelayNews(),
            //관련 ai속보 더보기 버튼
            const SizedBox(
              height: 10.0,
            ),
            Visibility(
              visible: _relayMoreBtnShow,
              child: CommonView.setBasicMoreRoundBtnView(
                [
                  Text(
                    "+ 관련 AI속보",
                    style: TStyle.puplePlainStyle(),
                  ),
                  const Text(
                    " 더보기",
                    style: TStyle.commonSTitle,
                  ),
                ],
                () {
                  pageNum++;
                  requestRassi14();
                },
              ),
            ),

            const SizedBox(
              height: 25.0,
            ),

            Container(
              color: RColor.bgWeakGrey,
              height: 12,
            ),

            _setPrMid(),

            //AI 분석리포트
            _setAnlReport(),

            Container(
              color: RColor.bgWeakGrey,
              height: 12,
            ),

            //AI의 추천 태그
            _setHidingTag(),
            _setRapidTag(),
            const SizedBox(
              height: 10.0,
            ),
            _setPrLow(),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                  top: 25, left: 15, right: 15, bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: UIStyle.boxRoundLine6bgColor(
                Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'AI가 분석하는 모든 태그\n분류를 확인해 보세요',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CommonView.setBasicMoreRoundBtnView(
                    [
                      Text(
                        "→ 태그",
                        style: TStyle.puplePlainStyle(),
                      ),
                      const Text(
                        " 전체보기",
                        style: TStyle.commonSTitle,
                      ),
                    ],
                    () {
                      basePageState.callPageRouteUP(
                        const NewsTagAllPage(),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30.0,
            ),
          ]),
        ),
      ],
    );
  }

  //시장 지수
  Widget _setMarketIndex() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height -
                AppGlobal().deviceStatusBarHeight,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              /*borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
              ),*/
            ),
            child: HomeMarketKosChartPage(),
          ),
        );
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Visibility(
        visible: !_index01.isEmpty(),
        child: SizedBox(
            height: 150,
            child: _index01.marketTimeDiv == 'N'
                ? Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: const [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    '코스피',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    '코스닥',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              '장시작 전 입니다.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '코스피',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                _index01.kospi.priceIndex,
                                style: const TextStyle(
                                  //공통 타이틀 (bold)
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xff111111),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _kospiSub,
                                style: TextStyle(
                                  color: _kospiColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _index01.marketTimeDiv == "B"
                                    ? "${TStyle.getMonthDayString()} 개장전 예상지수"
                                    : _index01.marketTimeDiv == "O"
                                        ? "${TStyle.getMonthDayString()} ${TStyle.getTimeFormat(_index01.baseTime)}"
                                        : _index01.marketTimeDiv == "C"
                                            ? "${TStyle.getMonthDayString()} 장마감"
                                            : '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '코스닥',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                _index01.kosdaq.priceIndex,
                                style: const TextStyle(
                                  //공통 타이틀 (bold)
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xff111111),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _kosdaqSub,
                                style: TextStyle(
                                  color: _kosdaqColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _index01.marketTimeDiv == "B"
                                    ? "${TStyle.getMonthDayString()} 개장전 예상지수"
                                    : _index01.marketTimeDiv == "O"
                                        ? "${TStyle.getMonthDayString()} ${TStyle.getTimeFormat(_index01.baseTime)}"
                                        : _index01.marketTimeDiv == "C"
                                            ? "${TStyle.getMonthDayString()} 장마감"
                                            : '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }

  //오늘의 이슈(버블차트)
  Widget _setTodayIssueBubble() {
    List<BubbleNode> listNodes = [];
    TextStyle tStyle;
    Color? bgColor;
    Color txtColor = Colors.white;
    String name = '';
    double minValue = 0;
    FontWeight fontWeight = FontWeight.bold;
    double? padding = 0;

    _issueList.sort(
      (a, b) => double.parse(b.avgFluctRate)
          .abs()
          .compareTo(double.parse(a.avgFluctRate).abs()),
    );

    for (int i = 0; i < _issueList.length; i++) {
      txtColor = Colors.white;

      Issue03 item = _issueList[i];

      num value = double.parse(item.avgFluctRate);
      //최대값 찾기 > 최대값의 1/15이 최소값임
      if (i == 0) {
        minValue = (double.parse((value.abs() / 15).toStringAsFixed(2)));
        //DLog.d(SliverMarketWidget.TAG, 'minValue : $minValue');
      }

      /*DLog.d(SliverMarketWidget.TAG,
          'keyword : ${item.keyword} / value : ${item.avgFluctRate} / status : ${item.issueStatus}');*/

      fontWeight = FontWeight.bold;
      padding = 10;

      /* else if(_value > 0.2){
        _padding = 14 * _value;
      } else{
        _padding = 10;
      }*/

      if (value > 3) {
        bgColor = RColor.bubbleChartStrongRed;
        padding = (3 * value) as double?;
      } else if (value > 1) {
        bgColor = RColor.bubbleChartRed;
        padding = (7 * value) as double?;
      } else if (value <= -1 && value > -5) {
        bgColor = RColor.bubbleChartBlue;
        value = value.abs();
        padding = (7 * value) as double?;
      } else if (value <= -5) {
        bgColor = RColor.bubbleChartStrongBlue;
        value = value.abs();
        padding = 4.5 * value;
      } else {
        fontWeight = FontWeight.w600;
        padding = 10;
        switch (item.issueStatus) {
          case 'bohab':
            {
              if (value > 0.1) {
                bgColor = RColor.bubbleChartWeakRed;
                txtColor = RColor.bubbleChartTxtColorRed;
              } else if (value > -0.1) {
                value = value.abs();
                bgColor = RColor.bubbleChartGrey;
                txtColor = RColor.bubbleChartTxtColorGrey;
              } else {
                value = value.abs();
                bgColor = RColor.bubbleChartWeakBlue;
                txtColor = Colors.blueAccent;
              }
              break;
            }
          case 'up':
            {
              if (value > -0.7) {
                value = value.abs();
                bgColor = RColor.bubbleChartWeakRed;
                txtColor = RColor.bubbleChartTxtColorRed;
              } else {
                value = value.abs();
                bgColor = RColor.bubbleChartWeakBlue;
                txtColor = Colors.blueAccent;
              }
              break;
            }
          case 'dn':
            {
              if (value > 0.7) {
                bgColor = RColor.bubbleChartWeakRed;
                txtColor = RColor.bubbleChartTxtColorRed;
              } else if (value > -0.7) {
                value = value.abs();
                bgColor = RColor.bubbleChartGrey;
                txtColor = RColor.bubbleChartTxtColorGrey;
              } else {
                value = value.abs();
                bgColor = RColor.bubbleChartWeakBlue;
                txtColor = Colors.blueAccent;
              }
              break;
            }
        }
      }

      if (value.abs() < minValue) {
        value = minValue;
      }

      tStyle = TextStyle(
        fontWeight: fontWeight,
        fontSize: 20,
        color: txtColor,
      );

      name = item.keyword.replaceAll(' ', '\n');
      if (name.length == 4 || name.length == 5) {
        name = '${name.substring(0, 2)}\n${name.substring(2, 4)}';
      }

      BubbleNode childNode = BubbleNode.leaf(
        value: value,
        options: BubbleOptions(
          color: bgColor,
          onTap: () {
            CustomFirebaseClass.logEvtTodayIssue(
              item.keyword,
            );
            Navigator.push(
              context,
              CustomNvRouteClass.createRouteData(
                IssueViewer(),
                RouteSettings(arguments: PgData(userId: '', pgSn: item.newsSn)),
              ),
            );
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: Padding(
              padding: EdgeInsets.all(padding!),
              child: Text(
                name,
                style: tStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      listNodes.add(childNode);
    }

    /*for (int k = 0; k < listNodes.length; k++) {
      DLog.d(SliverMarketWidget.TAG, '$k : ${listNodes[k].value}');
    }*/

    if (listNodes.isEmpty) {
      listNodes.add(BubbleNode.leaf(
        value: 10,
        options: BubbleOptions(color: Colors.transparent),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
      //color: RColor.bgWeakGrey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setSubTitle(RString.tl_today_issues, '이슈와 관련 종목을 한눈에'),
              Text(
                _issueDate,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          SizedBox(
            height: 300,
            child: BubbleChartLayout(
              children: [
                BubbleNode.node(
                  options: BubbleOptions(color: Colors.transparent),
                  padding: 1,
                  children: listNodes,
                ),
              ],
              duration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          CommonView.setBasicMoreRoundBtnView(
            [
              Text(
                "+ 날짜별 이슈",
                style: TStyle.puplePlainStyle(),
              ),
              const Text(
                " 모두보기",
                style: TStyle.commonSTitle,
              ),
            ],
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IssueListPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 라씨데스크 배너
  Widget _setRassiDeskBanner() {
    return InkWell(
      onTap: () {
        basePageState.callPageRoute(const RassiDeskTimeLinePage());
      },
      child: Container(
        width: double.infinity,
        height: AppGlobal().isTablet ? 150 : 130,
        color: RColor.mainColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: UIStyle.boxRoundFullColor25c(
                              RColor.bgSignal,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: const Text(
                              'TODAY BRIEFING',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Text(
                            '오늘 꼭 봐야할 정보,',
                            style: TextStyle(
                              color: Color(0xE6FFFFFF),
                              fontSize: 17,
                              height: 1.2,
                            ),
                          ),
                          const Text(
                            '라씨데스크 타임라인으로 보기',
                            style: TextStyle(
                              color: Color(0xE6FFFFFF),
                              fontSize: 17,
                              height: 1.2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'images/icon_market_view_banner1.png',
                    width: 80,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              '#내가놓친그종목  #여기서한번에',
              style: TextStyle(
                color: RColor.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //이 시간 PICK
  Widget _setCurrentPick() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 시간 PICK',
            style: TStyle.commonTitle,
          ),
          Container(
            width: double.infinity,
            color: Colors.grey.shade50,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: _pickTagList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  width: double.infinity,
                  decoration: UIStyle.boxRoundLine6(),
                  child: TileRassi11N(
                      index,
                      _pickTagList[index],
                      RColor.issueBack[index % 6],
                      RColor.issueRelay[index % 6]),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // 이 시간 AI 속보
  Widget _setNewsList() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
            return TileRassi01(_newsList[index]);
          }),
    );
  }

  //AI 가 찾은 추천정보
  Widget _setRecomInfo() {
    double _margin = (MediaQuery.of(context).size.width / 6) + (10 / 3);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              right: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      'AI가 찾은 추천 정보',
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Container(
                          height: 80,
                          margin: const EdgeInsets.only(left: 15),
                          // padding: const EdgeInsets.all(15),
                          decoration: _bSelectA
                              ? UIStyle.boxBtnSelected()
                              : UIStyle.boxRoundLine6(),
                          child: Center(
                            child: Text(
                              '장중투자자\n동향',
                              textAlign: TextAlign.center,
                              style: _bSelectA
                                  ? TStyle.btnTextWht15
                                  : TStyle.commonSTitle,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _alignment = Alignment.centerLeft;
                            _bSelectA = true;
                            _bSelectB = false;
                            _bSelectC = false;
                            _aiSelectType = 'INVESTOR';
                            pageNum = 0;
                          });
                          requestRassi14();
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          height: 80,
                          margin: const EdgeInsets.only(left: 15),
                          // padding: const EdgeInsets.all(15),
                          decoration: _bSelectB
                              ? UIStyle.boxBtnSelected()
                              : UIStyle.boxRoundLine6(),
                          child: Center(
                            child: Text(
                              '큰손매매',
                              style: _bSelectB
                                  ? TStyle.btnTextWht15
                                  : TStyle.commonSTitle,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _alignment = Alignment.center;

                            _bSelectA = false;
                            _bSelectB = true;
                            _bSelectC = false;
                            _aiSelectType = 'AGENCY';
                            pageNum = 0;
                          });
                          requestRassi14();
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          height: 80,
                          margin: const EdgeInsets.only(left: 15),
                          // padding: const EdgeInsets.all(15),
                          decoration: _bSelectC
                              ? UIStyle.boxBtnSelected()
                              : UIStyle.boxRoundLine6(),
                          child: Center(
                            child: Text(
                              '시장핫종목',
                              style: _bSelectC
                                  ? TStyle.btnTextWht15
                                  : TStyle.commonSTitle,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _alignment = Alignment.centerRight;

                            _bSelectA = false;
                            _bSelectB = false;
                            _bSelectC = true;
                            _aiSelectType = 'HOT_STOCK';
                            pageNum = 0;
                          });
                          requestRassi14();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  //color: Colors.redAccent,
                  margin:
                      EdgeInsets.only(left: _margin - 20, right: _margin - 35),
                  padding: EdgeInsets.zero,
                  child: AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(
                      milliseconds: 500,
                      //seconds: 1
                    ),
                    curve: Curves.easeIn,
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: RColor.mainColor,
                      //size: 40,
                      //size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            width: double.infinity,
            child: Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.start,
              children: List.generate(
                _recomTagList.length,
                (index) => TileChip14(
                  _recomTagList[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //관련된 최근 소식(뉴스)
  Widget _setRelayNews() {
    return ListView.builder(
        physics: const ScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _relayList.length,
        itemBuilder: (context, index) {
          return TileRassi14(_relayList[index]);
        });
  }

  //AI속보의 분석리포트
  Widget _setAnlReport() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Text(
              'AI속보의 분석리포트',
              style: TStyle.defaultTitle,
            ),
          ),
          Container(
            width: double.infinity,
            height: 120,
            color: Colors.grey.shade50,
            child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: _reportList.length,
                itemBuilder: (context, index) {
                  return TileRassi12(
                      _reportList[index], RColor.assistBack[index % 6]);
                }),
          )
        ],
      ),
    );
  }

  //숨어 있는 정보를 찾으시나요?
  Widget _setHidingTag() {
    return Visibility(
      visible: _hidingTagList != null && _hidingTagList.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 25, left: 10, right: 10),
            child: Text(
              'AI의 추천 태그',
              style: TStyle.defaultTitle,
            ),
          ),
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: UIStyle.boxRoundLine6bgColor(
              Colors.white,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '숨어 있는 정보를 찾으시나요?',
                  style: TStyle.defaultTitle,
                ),
                const SizedBox(
                  height: 15,
                ),
                Wrap(
                  spacing: 7.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(_hidingTagList.length,
                      (index) => TileChipTag(_hidingTagList[index])),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //빠른 정보를 찾으시나요?
  Widget _setRapidTag() {
    return Visibility(
      visible: _rapidTagList != null && _rapidTagList.length > 0,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: UIStyle.boxRoundLine6bgColor(
          Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              '빠른 정보를 찾으시나요?',
              style: TStyle.defaultTitle,
            ),
            const SizedBox(
              height: 15,
            ),
            Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.center,
              children: List.generate(_rapidTagList.length,
                  (index) => TileChipTag(_rapidTagList[index])),
            )
          ],
        ),
      ),
    );
  }

  // 프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: prTOP,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrTop)),
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
      return Container(
        color: RColor.bgWeakGrey,
        height: 12,
      );
    }
  }

  // 프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: prMID,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrMid)),
    );
  }

  // 프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: prLOW,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrLow)),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String title, String subTitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: TStyle.defaultTitle,
          textScaleFactor: Const.TEXT_SCALE_FACTOR,
        ),
        const SizedBox(
          width: 5.0,
        ),
        Text(
          subTitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textScaleFactor: Const.TEXT_SCALE_FACTOR,
        ),
      ],
    );
  }

  void requestRassi14() {
    DLog.d(SliverMarketWidget.TAG, 'requestRassi14() pageNum : $pageNum');
    _fetchPosts(
        TR.RASSI14,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': _aiSelectType,
          'pageNo': pageNum.toString(),
          'pageItemSize': pageNum == 0 ? '3' : '5',
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverMarketWidget.TAG, '$trStr $json');

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

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverMarketWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverMarketWidget.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverMarketWidget.TAG, response.body);

    if (trStr == TR.PROM02) {
      //탭이동을 홈으로 초기화(setState 필요)
      Provider.of<PageNotifier>(context, listen: false).setPageData(0);

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
          if (_listPrTop.length > 0) prTOP = true;
          if (_listPrHgh.length > 0) prHGH = true;
          if (_listPrMid.length > 0) prMID = true;
          if (_listPrLow.length > 0) prLOW = true;
        });
      }

      _fetchPosts(
          TR.INDEX01,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    } else if (trStr == TR.INDEX01) {
      final TrIndex01 resData = TrIndex01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _index01 = resData.retData;

        Kospi kospi = resData.retData.kospi;
        Kosdaq kosdaq = resData.retData.kosdaq;

        if (kospi.fluctuationRate.contains('-')) {
          _kospiSub = '▼${kospi.indexFluctuation.replaceAll('-', '')}  ${kospi.fluctuationRate}%';
          _kospiColor = RColor.sigSell;
        } else if (kospi.fluctuationRate == '0.00') {
          _kospiSub =
              '${kospi.indexFluctuation}  ${kospi.fluctuationRate}%';
        } else {
          _kospiSub = '▲${kospi.indexFluctuation}  +${kospi.fluctuationRate}%';
          _kospiColor = RColor.sigBuy;
        }

        if (kosdaq.fluctuationRate.contains('-')) {
          _kosdaqSub = '▼${kosdaq.indexFluctuation.replaceAll('-', '')}   ${kosdaq.fluctuationRate}%';
          _kosdaqColor = RColor.sigSell;
        } else if (kosdaq.fluctuationRate == '0.00') {
          _kosdaqSub =
              '${kosdaq.indexFluctuation}  ${kosdaq.fluctuationRate}%';
        } else {
          _kosdaqSub = '▲${kosdaq.indexFluctuation}   +${kosdaq.fluctuationRate}%';
          _kosdaqColor = RColor.sigBuy;
        }
      } else {
        _index01 = defIndex01;
      }
      setState(() {});
      _fetchPosts(
          TR.ISSUE03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'issueDate': '',
          }));
    }

    //이슈 지정일 조회
    else if (trStr == TR.ISSUE03) {
      final TrIssue03 resData = TrIssue03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _issueList = resData.listData;
        String month = resData.listData[0].issueDttm.substring(4, 6);
        String day = resData.listData[0].issueDttm.substring(6, 8);

        if (month[0] == '0') month = month[1];
        if (day[0] == '0') day = day[1];

        _issueDate = '$month/$day';
        setState(() {});
      }

      _fetchPosts(
          TR.RASSI01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': '0',
            'pageItemSize': '3',
          }));
    } else if (trStr == TR.RASSI01) {
      final TrRassi01 resData = TrRassi01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _newsList = resData.listData;

        setState(() {});
      }

      _fetchPosts(
          TR.RASSI11,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //라씨로 PICK
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
          TR.RASSI15,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': 'ALL',
          }));
    }

    //추천 태그
    else if (trStr == TR.RASSI15) {
      final TrRassi15 resData = TrRassi15.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.listData != null && resData.listData.length > 0) {
          for (int i = 0; i < resData.listData.length; i++) {
            if (resData.listData[i].tagDiv == 'H') {
              //숨은 정보
              _hidingTagList.add(resData.listData[i]);
            } else if (resData.listData[i].tagDiv == 'S') {
              //빠른 정보
              _rapidTagList.add(resData.listData[i]);
            }
          }
        }

        setState(() {});
      }

      _fetchPosts(
          TR.RASSI14,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectDiv': _aiSelectType,
            'pageNo': pageNum.toString(),
            'pageItemSize': '3',
          }));
    }

    //AI가 찾은 추천 정보 조회
    else if (trStr == TR.RASSI14) {
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
