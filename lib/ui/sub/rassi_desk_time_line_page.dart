import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/tr_today/tr_today05.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:rassi_assist/ui/news/issue_list_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_page.dart';
import 'package:rassi_assist/ui/sub/social_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../common/const.dart';
import '../../common/d_log.dart';
import '../../common/net.dart';
import '../../models/pg_data.dart';
import '../../models/pg_news.dart';
import '../common/common_appbar.dart';
import '../main/base_page.dart';
import '../news/news_tag_page.dart';
import '../news/news_tag_sum_page.dart';

class RassiDeskTimeLinePage extends StatefulWidget {
  const RassiDeskTimeLinePage({Key? key}) : super(key: key);
  static const routeName = '/rassi_desk_timeline';
  static const String TAG = "[RassiDeskTimeLinePage]";
  static const String TAG_NAME = '라씨데스크_타임라인';

  @override
  State<RassiDeskTimeLinePage> createState() => _RassiDeskTimeLinePageState();
}

class _RassiDeskTimeLinePageState extends State<RassiDeskTimeLinePage> with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  String _userId = '';
  String _nowHourMinute = '0000';

  final List<RassiroNewsDdInfo> _listRassiroNewsDdInfo = [];

  final List<GlobalKey> _listGlobalKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ]; // 키 생성
  final List<String> _listCompareTimes1 = [
    '0000',
    '0830',
    '0900',
    '1000',
    '1400',
    '1600',
    '1830',
    '2000',
  ];
  final List<String> _listCompareTimes2 = [
    '0829',
    '0859',
    '0959',
    '1359',
    '1559',
    '1829',
    '1959',
    '2400',
  ];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      RassiDeskTimeLinePage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            if (_userId != '') {
              _requestTrToday05();
            }
          }),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    _nowHourMinute = DateFormat('HHmm').format(DateTime.now());
    return Scaffold(
      backgroundColor: RColor.bgWeakGrey,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '라씨데스크',
        elevation: 1,
      ),
      body: SafeArea(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 첫번째
                        TimelineTile(
                          alignment: TimelineAlign.start,
                          isFirst: true,
                          beforeLineStyle: const LineStyle(
                            color: RColor.mainColor,
                            thickness: 1,
                          ),
                          indicatorStyle: IndicatorStyle(
                            width: 22,
                            height: 16,
                            //height: 0,
                            //padding: const EdgeInsets.all(2),
                            indicator: Container(
                              width: 10,
                              height: 10,
                              color: RColor.bgWeakGrey,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time,
                                color: RColor.new_basic_text_color_grey,
                                size: 18,
                              ),
                            ),
                          ),
                          endChild: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: Text(
                              '${TStyle.getDateMdKorFormat(TStyle.getTodayString(), isZeroVisible : true)} ${TStyle.getWeekdayKor(TStyle.getTodayString())} ${TStyle.getTimeString1()}',
                              style: const TextStyle(
                                color: RColor.mainColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        TimelineTile(
                          alignment: TimelineAlign.start,
                          beforeLineStyle: const LineStyle(
                            color: RColor.mainColor,
                            thickness: 1,
                          ),
                          indicatorStyle: IndicatorStyle(
                            width: 22,
                            height: 0,
                            //height: 0,
                            //padding: const EdgeInsets.all(1),
                            indicator: Container(
                              width: 10,
                              height: 10,
                              color: RColor.mainColor,
                            ),
                          ),
                          endChild: Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                              top: 10,
                              bottom: 0,
                            ),
                            padding: const EdgeInsets.all(15),
                            child: const Center(
                              child: Text(
                                '오늘 발생한 꼭 봐야할 정보를 살펴보고,\n시장의 흐름을 알아보세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: RColor.new_basic_text_color_grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        _setTileFirst(),

                        _setTile0830(),

                        _setTile0900(),

                        _setTile1000(),

                        _setTile1400(),

                        _setTile1600(),

                        _setTile1830(),

                        _setTileLast(),
                      ],
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

  Widget _setTimeLineTile(int index, bool isNow, bool isOn) {
    if (index >= _listRassiroNewsDdInfo.length) {
      return Container();
    }
    var item = _listRassiroNewsDdInfo[index];
    return Container(
      key: _listGlobalKeys[index],
      child: TimelineTile(
        alignment: TimelineAlign.start,
        isLast: index == _listRassiroNewsDdInfo.length - 1 ? true : false,
        beforeLineStyle: LineStyle(
          color: isOn ? RColor.mainColor : RColor.new_basic_line_grey,
          thickness: 1,
        ),
        afterLineStyle: LineStyle(
          color: isNow
              ? RColor.new_basic_line_grey
              : isOn
                  ? RColor.mainColor
                  : RColor.new_basic_line_grey,
          thickness: 1,
        ),
        indicatorStyle: IndicatorStyle(
          width: 22,
          height: 13,
          drawGap: false,
          color: isOn ? RColor.mainColor : RColor.new_basic_line_grey,
          indicator: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? RColor.mainColor : RColor.new_basic_line_grey,
            ),
          ),
        ),
        endChild: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            CustomFirebaseClass.logEvtDdInfo(time: item.displayTime);
            if (!isOn) {
              CommonPopup.instance.showDialogMsg(context, '정보 발생 전 입니다.');
            } else {
              if (item.contentDiv == 'MKT2' || item.contentDiv == 'MKT') {
                basePageState.callPageRouteNews(NewsTagSumPage(), PgNews(tagCode: '', tagName: ''));
              } else if (item.contentDiv == 'ISS') {
                basePageState.callPageRoute(const IssueListPage());
              } else if (item.contentDiv == 'STK') {
                basePageState.callPageRouteNews(NewsTagPage(), PgNews(tagCode: 'USRTAG', tagName: '실시간특징주'));
              } else if (item.contentDiv == 'SNS') {
                Navigator.pushNamed(context, SocialListPage.routeName, arguments: PgData(pgSn: ''));
              } else if (item.contentDiv == 'BRF2') {
                basePageState.callPageRoute(const RassiDeskPage());
              } else if (item.contentDiv == 'SCH') {
                basePageState.callPageRouteUP(
                  const SearchPage(
                    landWhere: SearchPage.goStockHome,
                    pocketSn: '',
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(
              left: 10,
              top: 20,
              bottom: 20,
            ),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isNow
                  ? RColor.mainColor
                  : isOn
                      ? RColor.yonbora3
                      : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), //changes position of shadow
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    index == 0 || index == _listRassiroNewsDdInfo.length - 1
                        ? const SizedBox()
                        : _setTextTime(index, isOn, isNow),
                    Text(
                      item.displaySubject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isNow ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    Visibility(
                      visible: isNow,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Image.asset(
                            'images/icon_now.png',
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  item.displayTitle,
                  style: TextStyle(
                    color: isNow ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                if (!isOn)
                  const Text(
                    '종목분석중',
                    style: TextStyle(
                      fontSize: 13,
                      color: RColor.mainColor,
                    ),
                  )
                else if (item.listItem.isEmpty)
                  item.contentDiv == 'SNS'
                      ? Text(
                          '소셜 폭발 종목 확인하기',
                          style: TextStyle(
                            color: isNow ? RColor.orange : RColor.mainColor,
                            fontSize: 13,
                          ),
                        )
                      : const SizedBox()
                else
                  Wrap(
                    spacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      item.listItem.length > 2 ? 2 : item.listItem.length,
                      (index) {
                        return InkWell(
                          child: Text(
                            '#${item.listItem[index].itemName}',
                            style: TextStyle(
                              color: isNow ? RColor.orange : RColor.mainColor,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            if (item.contentDiv == 'ISS') {
                              Navigator.pushNamed(
                                context,
                                IssueNewViewer.routeName,
                                arguments: PgData(
                                  pgSn: item.listItem[index].itemCode,
                                  //pgData: item.listItem[index].itemCode,
                                  data: item.listItem[index].itemName,
                                ),
                              );
                            }
                            /*else if (item.contentDiv == 'RPT') {
                              // 증권사 리포트로
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportPage(),
                                  settings: RouteSettings(
                                    arguments: PgData(
                                      pgSn: '0',
                                      pgData: '증권사 리포트',
                                    ),
                                  ),
                                ),
                              );
                            } */ /*else if (item.contentDiv == 'BRF') {
                              // 웹뷰로 띄우기
                            } */
                            else if (item.contentDiv == 'SCH') {
                              basePageState.callPageRouteUP(
                                const SearchPage(
                                  landWhere: SearchPage.goStockHome,
                                  pocketSn: '',
                                ),
                              );
                            } else {
                              // 종목홈으로
                              basePageState.goStockHomePage(
                                item.listItem[index].itemCode,
                                item.listItem[index].itemName,
                                Const.STK_INDEX_HOME,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _setTileFirst() {
    // 첫번째, 00:00 ~ 08:29
    bool isOn = _nowHourMinute.compareTo('0000') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '0829'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(0, isNow, isOn);
  }

  Widget _setTile0830() {
    // 두번째, 08:30
    bool isOn = _nowHourMinute.compareTo('0830') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '0859'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(1, isNow, isOn);
  }

  Widget _setTile0900() {
    // 세번째, 0900
    bool isOn = _nowHourMinute.compareTo('0900') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '0959'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(2, isNow, isOn);
  }

  Widget _setTile1000() {
    // 네번째, 10:00
    bool isOn = _nowHourMinute.compareTo('1000') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '1359'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(3, isNow, isOn);
  }

  Widget _setTile1400() {
    // 다섯번째, 1400
    bool isOn = _nowHourMinute.compareTo('1400') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '1559'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(4, isNow, isOn);
  }

  Widget _setTile1600() {
    // 여섯번째, 1600
    bool isOn = _nowHourMinute.compareTo('1600') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '1829'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(5, isNow, isOn);
  }

  Widget _setTile1830() {
    // 일곱번째, 18:30
    bool isOn = _nowHourMinute.compareTo('1830') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '1959'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(6, isNow, isOn);
  }

  Widget _setTileLast() {
    // 마지막, 20:00 ~ 24:00
    bool isOn = _nowHourMinute.compareTo('2000') >= 0;
    bool isNow = false;
    if (isOn) {
      isNow = '2400'.compareTo(_nowHourMinute) >= 0;
    }
    return _setTimeLineTile(7, isNow, isOn);
  }

  Widget _setTextTime(int timeIndex, isOn, isNow) {
    return Container(
      margin: const EdgeInsets.only(
        right: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isNow ? Colors.white : RColor.new_basic_text_color_grey,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Text(
        _listRassiroNewsDdInfo[timeIndex].displayTime,
        style: TextStyle(
          //fontWeight: FontWeight.w600,
          color: isNow
              ? Colors.white
              : isOn
                  ? RColor.mainColor
                  : RColor.new_basic_text_color_grey,
          fontSize: 12,
        ),
      ),
    );
  }

  _requestTrToday05() async {
    _fetchPosts(
      TR.TODAY05,
      jsonEncode(
        <String, String>{
          'userId': _userId,
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
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
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
    if (trStr == TR.TODAY05) {
      final TrToday05 resData = TrToday05.fromJson(jsonDecode(response.body));
      _listRassiroNewsDdInfo.clear();
      if (resData.retCode == RT.SUCCESS) {
        Today05 today05 = resData.retData;
        _listRassiroNewsDdInfo.addAll(today05.listRassiroNewsDdInfo);
      }
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listGlobalKeys.asMap().forEach((key, value) {
        bool isOn = _nowHourMinute.compareTo(_listCompareTimes1[key]) >= 0;
        bool isNow = false;
        if (isOn) {
          isNow = _listCompareTimes2[key].compareTo(_nowHourMinute) >= 0;
          if (isNow) {
            Scrollable.ensureVisible(
              _listGlobalKeys[key].currentContext!,
              alignment: 0.5,
              curve: Curves.fastEaseInToSlowEaseOut,
              duration: const Duration(milliseconds: 500),
            );
          }
        }
      });
    });
  }
}
