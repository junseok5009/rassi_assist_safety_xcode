import 'dart:async';
import 'dart:convert';
import 'dart:ui' as duTextDirection;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_index/tr_index02.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue03.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue09.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi19.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_date_picker.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleNode.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleRoot.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_insight_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TodayIssueTimelinePage extends StatefulWidget {
  const TodayIssueTimelinePage({super.key});

  static const routeName = '/today_issue_timeline';
  static const String TAG = "[TodayIssueTimelinePage]";
  static const String TAG_NAME = '오늘의_이슈_타임라인';

  @override
  State<TodayIssueTimelinePage> createState() => _TodayIssueTimelinePageState();
}

class _TodayIssueTimelinePageState extends State<TodayIssueTimelinePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late SharedPreferences _prefs;
  String _userId = "";
  bool _isNetworkDo = false;

  final String _todayStrYyyyMmDd = TStyle.getTodayString(); // 오늘 날짜 yyyymmdd
  final List<TimeLapseDateClass> _listDate = []; // 날짜 리스트
  int _selectDateIndex = -1; // 날짜 리스트
  final ScrollController _bottomSheetScrollController = ScrollController();

  // 버블
  final List<Widget> _bubbleWidgetList = [];
  final List<AnimationController> _bubbleChartAniControllerList = [];
  bool _isStartBubbleAnimation = false;

  // 버블 타임랩스
  int _selectTimeLapseIndex = 0;
  int _timeLapselastDataIndex = 0;
  final List<Issue09TimeLapse> _bubbleTimeLapseList = [];

  // 코스피 코스닥
  Index02 _index02 = const Index02();

  // 이슈 종목 리스트 PageNo
  int _pageNo = 0;
  int _totalPageSize = 0;
  String _totalItemSize = '0';
  final List<Rassi19Rassiro> _listRassiroData = [];
  final ScrollController _rassiroListScrollController = ScrollController();

  bool _isFaVisible = true;

  int _nowMillisecondsSinceEpoch = 0; // 이미지 캐시 방지를 위한 값

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      TodayIssueTimelinePage.TAG_NAME,
    );
    _rassiroListScrollController.addListener(() {
      if (_rassiroListScrollController.hasClients && _rassiroListScrollController.position.atEdge) {
        bool isTop = _rassiroListScrollController.position.pixels == 0;
        if (!isTop && _listRassiroData.isNotEmpty) {
          _checkAndRequestTrRassi19();
        }
      }
      if (_rassiroListScrollController.position.userScrollDirection == ScrollDirection.forward && !_isFaVisible) {
        setState(() {
          _isFaVisible = true;
        });
      } else if (_rassiroListScrollController.position.userScrollDirection == ScrollDirection.reverse && _isFaVisible) {
        setState(() {
          _isFaVisible = false;
        });
      }
    });
    _nowMillisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    _loadPrefData().then((value) {
      _getDaysOfMonth(standardDate: _todayStrYyyyMmDd);
      _requestIssue09(issueDate: _todayStrYyyyMmDd);
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
    _bottomSheetScrollController.dispose();
    _rassiroListScrollController.dispose();
    for (var element in _bubbleChartAniControllerList) {
      element.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return _listDate.isEmpty
        ? const SizedBox()
        : Scaffold(
            key: _scaffoldKey,
            appBar: CommonAppbar.basic(buildContext: context, title: '오늘의 이슈 타임라인', elevation: 1),
            backgroundColor: RColor.bgBasic_fdfdfd,
            bottomSheet: BottomSheet(
              builder: (context) => SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: const Border.fromBorderSide(
                      BorderSide(
                        color: RColor.greyBox_f5f5f5,
                      ),
                    ),
                    color: RColor.bgBasic_fdfdfd,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        //spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, -5), //changes position of shadow
                      )
                    ],
                  ),
                  child: AnimatedContainer(
                    width: double.infinity,
                    height: _isFaVisible ? 90 : 0,
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    //padding: const EdgeInsets.all(15),
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 10,
                      bottom: 10,
                    ),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(_scaffoldKey.currentState!.context).viewPadding.bottom,
                    ),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser()) {
                              await CommonDatePicker.showYearMonthPicker(
                                      context, DateTime.parse(_listDate[_selectDateIndex].yyyyMMdd))
                                  .then((value) {
                                if (value != null) {
                                  String getYearMonth = DateFormat('yyyyMMdd').format(value);
                                  DateTime selectMonthLastDateTime = DateTime.now();
                                  if (getYearMonth.substring(0, 6) != _todayStrYyyyMmDd.substring(0, 6)) {
                                    selectMonthLastDateTime = DateTime(
                                      value.year,
                                      value.month + 1,
                                      0,
                                    );
                                  }
                                  if (!_isNetworkDo) {
                                    String getMonthLastDay = DateFormat('yyyyMMdd').format(selectMonthLastDateTime);
                                    _getDaysOfMonth(standardDate: getMonthLastDay);
                                    if (getMonthLastDay == _todayStrYyyyMmDd) {
                                      for (int i = 0; i < _listDate.length; i++) {
                                        if (_listDate[i].yyyyMMdd == _todayStrYyyyMmDd) {
                                          _selectDateIndex = i;
                                          break;
                                        }
                                      }
                                    } else {
                                      _selectDateIndex = _listDate.length - 1;
                                    }
                                    _requestIssue09(issueDate: getMonthLastDay);
                                  }
                                }
                              });
                            } else {
                              CommonPopup.instance.showDialogPremiumBasic(context).then(
                                (result) {
                                  if (result == CustomNvRouteResult.landPremiumPage) {
                                    basePageState.navigateAndGetResultPayPremiumPage();
                                  }
                                },
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                '${_listDate[_selectDateIndex].yyyyMMdd[4] == '0' ? _listDate[_selectDateIndex].yyyyMMdd.substring(5, 6) : _listDate[_selectDateIndex].yyyyMMdd.substring(4, 6)}월',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  child: Image.asset('images/icon_arrow_down.png', width: 14, height: 14)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: double.infinity,
                          color: RColor.greyBasic_8c8c8c,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                        ),
                        /*IconButton(
                        icon: Image.asset(
                          'images/main_jm_aw_l_g.png',
                          width: 16,
                          height: 14,
                        ),
                        onPressed: () {
                          if (!_isNetworkDo) {
                            _requestIssue09(issueDate: _listIssue08[_listIssue08.length - 2].issueDate);
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),*/
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ListView.builder(
                              itemBuilder: (context, index) => _bottomSheetDateView(index),
                              itemCount: _listDate.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              controller: _bottomSheetScrollController,
                            ),
                          ),
                        ),
                        /*IconButton(
                        icon: Image.asset(
                          'images/main_jm_aw_r_g.png',
                          width: 16,
                          height: 14,
                        ),
                        onPressed: () {
                          if (!_isNetworkDo) {
                            DateTime dateTime = DateTime.parse(_listIssue08.last.issueDate);
                            dateTime = dateTime.add(
                              const Duration(days: 1),
                            );
                            //commonShowToastCenter('dateTime : ${dateTime.toString()}');
                            _requestIssue08(issueDate: DateFormat('yyyyMMdd').format(dateTime));
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),*/
                      ],
                    ),
                  ),
                ),
              ),
              enableDrag: false,
              onClosing: () {},
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Stack(
                  children: [
                    if (!_isNetworkDo && _index02.marketTimeDiv.isEmpty && _bubbleWidgetList.isEmpty)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: 0.3,
                                  child: Image.asset(
                                    'images/icon_issue_timelapse_nodata.png',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25,),
                            Expanded(
                              child: Text(
                                '선택하신 날짜에는 데이터가 없습니다.\n다른 날짜를 선택해 보세요.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          ],
                        ),
                      )
                    else if (_isNetworkDo)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.withOpacity(0.1),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ),
                        child: Image.asset(
                          'images/gif_ios_loading_large.gif',
                          height: 20,
                        ),
                      )
                    else
                      SingleChildScrollView(
                        controller: _rassiroListScrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _setBtnIssueInsight,
                            const SizedBox(
                              height: 10,
                            ),

                            // 타이틀 - [날짜] 시장은?
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                _index02.baseDate.isEmpty
                                    ? '${TStyle.getDateMdKorFormat(_listDate[_selectDateIndex].yyyyMMdd, isZeroVisible: false)} 시장은?'
                                    : '${TStyle.getDateMdKorFormat(_index02.baseDate, isZeroVisible: false)} 시장은?',
                                //'${_listDate[_selectDateIndex].yyyyMMdd[4] == '0' ? _listDate[_selectDateIndex].yyyyMMdd.substring(5, 6) : _listDate[_selectDateIndex].yyyyMMdd.substring(4, 6)}월 ${_listDate[_selectDateIndex].yyyyMMdd.substring(6, 8)}일 시장은?',
                                style: TStyle.defaultTitle,
                              ),
                            ),

                            // 코스피 코스닥 지수
                            _index02.marketTimeDiv.isEmpty
                                ? CommonView.setNoDataTextView(120, '오늘 시장 데이터가 없습니다.')
                                : _index02.marketTimeDiv == 'N'
                                    ? CommonView.setNoDataTextView(120, '장 시작 전 입니다')
                                    : _kosIndexView,

                            // 타이틀 - 이슈는?
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                '이슈는?',
                                style: TStyle.defaultTitle,
                              ),
                            ),

                            if (_bubbleTimeLapseList.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: UIStyle.boxRoundFullColor6c(
                                  RColor.greyBox_f5f5f5,
                                ),
                                child: RichText(
                                  //textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _index02.baseDate.isEmpty
                                            ? '${TStyle.getDateMdKorFormat(_listDate[_selectDateIndex].yyyyMMdd, isZeroVisible: false)}에 총 '
                                            : '${TStyle.getDateMdKorFormat(_index02.baseDate, isZeroVisible: false)}에 총 ',
                                      ),
                                      TextSpan(
                                        //text: _listIssue08.isEmpty ? '' : _listIssue08.last.issueCount,
                                        text: _bubbleTimeLapseList[_selectTimeLapseIndex].listData.length.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '개 이슈가 발생되었습니다.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(
                              height: 0,
                            ),

                            // 버블 차트
                            _bubbleChartView,

                            // 타임랩스
                            _bubbleTimeLapseList.isEmpty && !_isNetworkDo
                                ? CommonView.setNoDataTextView(200, '이슈 데이터가 없습니다.')
                                : _bubbleTimeLapseView,

                            const SizedBox(
                              height: 20,
                            ),

                            CommonView.setDivideLine,
                            // 타이틀 - 특징주 종목들은?
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                '특징주 종목들은?',
                                style: TStyle.defaultTitle,
                              ),
                            ),

                            _listRassiroData.isEmpty
                                ? CommonView.setNoDataTextView(150, '오늘의 특징주가 없습니다.')
                                : _realStocksView,
                            //MarketTileTodayMarket(index02: _index02),

                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  /// make Widget

  Widget _bottomSheetDateView(int index) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (index != _selectDateIndex && !_isNetworkDo) {
          if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser()) {
            _selectDateIndex = index;
            _requestIssue09(issueDate: _listDate[index].yyyyMMdd);
          } else {
            CommonPopup.instance.showDialogPremiumBasic(context).then(
              (result) {
                if (result == CustomNvRouteResult.landPremiumPage) {
                  basePageState.navigateAndGetResultPayPremiumPage();
                }
              },
            );
          }
        }
      },
      child: Container(
        key: _listDate[index].globalKey,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          color: index == _selectDateIndex ? Colors.black : null,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _listDate[index].weekDay,
                style: index == _selectDateIndex
                    ? const TextStyle(
                        color: Colors.white,
                        //fontSize: 15,
                      )
                    : const TextStyle(
                        //fontSize: 15,
                        color: RColor.greyBasic_8c8c8c,
                      ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                _listDate[index].yyyyMMdd.substring(
                      6,
                    ),
                style: index == _selectDateIndex
                    ? const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )
                    : const TextStyle(
                        fontSize: 18,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _setBtnIssueInsight {
    return Visibility(
      visible: false,
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_f5f5f5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  text: '시장 이슈를 분석하는  ',
                  style: TStyle.content15,
                  children: <TextSpan>[
                    TextSpan(
                      text: '이슈 인사이트',
                      style: TextStyle(
                        color: RColor.mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      // recognizer: TapGestureRecognizer()
                      //   ..onTap = () {
                      //     // open desired screen
                      //   }
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const ImageIcon(
                AssetImage('images/main_my_icon_arrow.png'),
                size: 20,
              )
            ],
          ),
        ),
        onTap: () {
          basePageState.callPageRouteUP(const IssueInsightPage());
        },
      ),
    );
  }

  Widget get _kosIndexView {
    return Visibility(
      visible: _index02.baseDate.isNotEmpty &&
          _index02.marketTimeDiv != 'N' &&
          _index02.kospi.fluctuationRate.isNotEmpty &&
          _index02.kosdaq.fluctuationRate.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: false,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: UIStyle.boxRoundFullColor6c(
                RColor.greyBox_f5f5f5,
              ),
              child: Text(
                '코스피는 ${_index02.kospi.fluctuationRate}% ${_index02.kospi.fluctuationRate.contains('-') ? '하락' : '상승'}, '
                '코스닥은 ${_index02.kosdaq.fluctuationRate}% ${_index02.kosdaq.fluctuationRate.contains('-') ? '하락' : '상승'}',
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Container(
            //margin: EdgeInsets.symmetric(horizontal: 10,),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: UIStyle.boxShadowBasic(16),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /*Image.network(
                              'https://webchart.thinkpool.com/2024/mini_index/U1001.png',
                              width: 40,

                            ),*/
                            if (_index02.marketTimeDiv == 'B')
                              Container(
                                width: 40,
                                height: 40,
                                decoration: UIStyle.boxSquareLine(),
                                alignment: Alignment.center,
                                child: const Text(
                                  '예상\n지수',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: RColor.greyMore_999999,
                                    height: 1.2,
                                  ),
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: _listDate[_selectDateIndex].yyyyMMdd == _todayStrYyyyMmDd
                                    ? "https://webchart.thinkpool.com/2024/mini_index/U1001.png?timestamp=$_nowMillisecondsSinceEpoch"
                                    : 'https://webchart.thinkpool.com/2024/mini_index/U${_listDate[_selectDateIndex].yyyyMMdd}1001.png?timestamp=$_nowMillisecondsSinceEpoch',
                                width: 40,
                                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: RColor.greyBox_f5f5f5,
                                ),
                                errorWidget: (context, url, error) => const SizedBox(
                                  width: 40,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '코스피',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  AutoSizeText(
                                    TStyle.getMoneyPoint(_index02.kospi.priceIndex),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${TStyle.getTriangleStringWithMoneyPoint(_index02.kospi.indexFluctuation)}'
                          '   ${TStyle.getPercentString(
                            _index02.kospi.fluctuationRate,
                          )}',
                          style: TextStyle(
                            fontSize: 12,
                            color: TStyle.getMinusPlusColor(_index02.kospi.fluctuationRate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Container(
                    decoration: UIStyle.boxShadowBasic(16),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /*Image.network(
                              'https://webchart.thinkpool.com/2024/mini_index/U2001.png',
                              width: 40,
                            ),*/
                            if (_index02.marketTimeDiv == 'B')
                              Container(
                                width: 40,
                                height: 40,
                                decoration: UIStyle.boxSquareLine(),
                                alignment: Alignment.center,
                                child: const Text(
                                  '예상\n지수',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: RColor.greyMore_999999,
                                    height: 1.2,
                                  ),
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: _listDate[_selectDateIndex].yyyyMMdd == _todayStrYyyyMmDd
                                    ? "https://webchart.thinkpool.com/2024/mini_index/U2001.png?timestamp=$_nowMillisecondsSinceEpoch"
                                    : 'https://webchart.thinkpool.com/2024/mini_index/U${_listDate[_selectDateIndex].yyyyMMdd}2001.png?timestamp=$_nowMillisecondsSinceEpoch',
                                width: 40,
                                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: RColor.greyBox_f5f5f5,
                                ),
                                errorWidget: (context, url, error) => const SizedBox(
                                  width: 40,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '코스닥',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  AutoSizeText(
                                    TStyle.getMoneyPoint(_index02.kosdaq.priceIndex),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${TStyle.getTriangleStringWithMoneyPoint(_index02.kosdaq.indexFluctuation)}'
                          '   ${TStyle.getPercentString(
                            _index02.kosdaq.fluctuationRate,
                          )}',
                          style: TextStyle(
                            fontSize: 12,
                            color: TStyle.getMinusPlusColor(_index02.kosdaq.fluctuationRate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CommonView.setDivideLine,
        ],
      ),
    );
  }

  Widget get _bubbleChartView {
    if (_bubbleWidgetList.isEmpty) return const SizedBox();
    return SizedBox(
      width: double.infinity,
      height: (AppGlobal().deviceWidth),
      child: Stack(
        children: _bubbleWidgetList,
      ),
    );
  }

  Widget get _bubbleTimeLapseView {
    if (_bubbleTimeLapseList.isEmpty) return const SizedBox();
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            CommonPopup.instance.showDialogBasic(
              context,
              '이슈 타임랩스',
              '이슈 타임랩스는 하루동안의 이슈의 강약 변화를 볼 수 있습니다.\n'
                  '장시작 부터 장마감까지 1시간 단위로 저장됩니다.\n'
                  '오늘의 이슈의 실시간 이슈 강약 확인은 물론 과거의 강약도 함께 확인해 보세요.',
            );
          },
          child: Image.asset(
            'images/icon_time_lapse_clock_grey.png',
            width: 20,
          ),
        ),
        Expanded(
          //width: double.infinity,
          //color: Colors.green,
          child: SfSliderTheme(
            data: SfSliderThemeData(
              overlayColor: RColor.greyBox_dcdfe2.withOpacity(0.5),
              overlayRadius: 20,
              activeTrackHeight: 15,
              activeDividerColor: RColor.grey_c8cace,
              activeTrackColor: RColor.greyBox_dcdfe2,
              activeDividerRadius: 2.5,
              //tickOffset: Offset(10,0),
              thumbColor: const Color(0xffABB0BB),
              inactiveTrackHeight: 15,
              //inactiveDividerColor: RColor.bubbleChartGrey,
              inactiveTrackColor: RColor.greyBox_dcdfe2,
              inactiveDividerRadius: 0,
            ),
            child: SfSlider(
              min: 0,
              max: _bubbleTimeLapseList.length - 1,
              value: _selectTimeLapseIndex,
              interval: 1,
              stepSize: 1,
              showDividers: true,
              thumbShape: _SfThumbShape(bubbleTimeLapseList: _bubbleTimeLapseList),
              onChanged: (dynamic newValue) async {
                //DLog.e('newValue : $newValue');
                if (newValue > _timeLapselastDataIndex) {
                  //미래 데이터
                } else {
                  _selectTimeLapseIndex = (newValue as double).toInt();
                  if (_bubbleTimeLapseList[_selectTimeLapseIndex].listData.isEmpty) {
                  } else {
                    CustomFirebaseClass.logEvtTodayIssueTimelapse(
                        time: _bubbleTimeLapseList[_selectTimeLapseIndex].timeLapse);
                    await _setBubbleNode();
                    setState(() {});
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_isStartBubbleAnimation && _bubbleWidgetList.isNotEmpty) {
                        _isStartBubbleAnimation = true;
                        _bubbleChartAniStart().then(
                          (_) => _isStartBubbleAnimation = false,
                        );
                      }
                    });
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget get _realStocksView {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: UIStyle.boxRoundFullColor6c(
            RColor.greyBox_f5f5f5,
          ),
          child: RichText(
            //textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text:
                      '${TStyle.getDateMdKorFormat(_listDate[_selectDateIndex].yyyyMMdd, isZeroVisible: false)} 특징주는 총 ',
                ),
                TextSpan(
                  text: _totalItemSize,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: '종목입니다.',
                ),
              ],
            ),
          ),
        ),
        ListView.builder(
          //controller: _rassiroListScrollController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listRassiroData.length,
          itemBuilder: (context, index) => Rassi19TimeLineRealItemWidget(
            item: _listRassiroData[index],
          ),
          shrinkWrap: true,
        ),
      ],
    );
  }

  /// make function

  Future<void> _setBubbleNode() async {
    for (var element in _bubbleChartAniControllerList) {
      element.dispose();
    }
    _bubbleChartAniControllerList.clear();
    _bubbleWidgetList.clear();

    List<Issue03> issueList = _bubbleTimeLapseList[_selectTimeLapseIndex].listData;

    issueList.sort(
      (a, b) => double.parse(b.avgFluctRate).abs().compareTo(double.parse(a.avgFluctRate).abs()),
    );

    List<CustomBubbleNode> listNodes = [];
    TextStyle tStyle;
    Color? bgColor;
    Color txtColor = Colors.white;
    String name = '';
    double minValue = 0;
    FontWeight fontWeight = FontWeight.bold;
    double padding = 0;

    bool isAllSameValue = issueList.every((val1) => val1.avgFluctRate == issueList.first.avgFluctRate);

    for (int i = 0; i < issueList.length; i++) {
      txtColor = Colors.white;
      Issue03 item = issueList[i];
      num value = double.parse(item.avgFluctRate);
      //최대값 찾기 > 최대값의 1/15이 최소값임
      if (i == 0) {
        minValue = (double.parse((value.abs() / 15).toStringAsFixed(2)));
      }
      fontWeight = FontWeight.w700;
      padding = 10;
      if (value > 3) {
        bgColor = RColor.bubbleChartStrongRed;
        padding = 2.0 * value;
      } else if (value > 1) {
        bgColor = RColor.bubbleChartRed;
        padding = 3.0 * value;
        fontWeight = FontWeight.w600;
      } else if (value > 0.1) {
        bgColor = RColor.bubbleChartWeakRed;
        padding = 10.0 * value;
        fontWeight = FontWeight.w400;
        txtColor = RColor.bubbleChartTxtColorRed;
      } else if (value > -0.1) {
        bgColor = RColor.bubbleChartGrey;
        value = value.abs();
        padding = 7;
        fontWeight = FontWeight.w400;
        txtColor = const Color(0xff8a8a8a);
      } else if (value > -1) {
        bgColor = RColor.bubbleChartWeakBlue;
        value = value.abs();
        padding = 10.0 * value;
        fontWeight = FontWeight.w400;
        txtColor = RColor.bubbleChartTxtColorBlue;
      } else if (value > -5) {
        bgColor = RColor.bubbleChartBlue;
        value = value.abs();
        padding = 3.0 * value;
        fontWeight = FontWeight.w600;
      } else if (value <= -5) {
        bgColor = RColor.bubbleChartStrongBlue;
        value = value.abs();
        padding = 2.0 * value;
      } else {
        bgColor = RColor.bubbleChartGrey;
        value = value.abs();
        padding = 12;
        fontWeight = FontWeight.w400;
        txtColor = const Color(0xff8a8a8a);
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
      CustomBubbleNode customBubbleNode = CustomBubbleNode.leaf(
        value: value,
        index: i,
        options: CustomBubbleOptions(
          color: bgColor,
          onTap: () {
            CustomFirebaseClass.logEvtTodayIssue(
              item.keyword,
            );
            Navigator.pushNamed(
              context,
              IssueNewViewer.routeName,
              arguments: PgData(
                pgSn: item.newsSn,
                pgData: item.issueSn,
                data: item.keyword,
              ),
            );
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: AutoSizeText(
                name,
                style: tStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ),
      );
      listNodes.add(customBubbleNode);
      _bubbleChartAniControllerList.add(
        AnimationController(
          duration: Duration(milliseconds: 2000 + 300 * i),
          vsync: this,
        ),
      );
    }

    List<Widget> bubbleWidgetList = CustomBubbleRoot(
      root: CustomBubbleNode.node(
        children: listNodes,
        padding: 1,
      ),
      size: Size(
        (AppGlobal().deviceWidth),
        (AppGlobal().deviceWidth),
      ),
      stretchFactor: isAllSameValue ? 0.5 : 1,
    ).nodes.fold([], (result, node) {
      return result
        ..add(
          Positioned(
            key: node.key,
            top: node.y! - node.radius!,
            left: node.x! - node.radius!,
            width: node.radius! * 2,
            height: node.radius! * 2,
            child: ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: _bubbleChartAniControllerList[node.index], curve: Curves.elasticOut),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(node.radius! * 2),
                child: InkResponse(
                  borderRadius: BorderRadius.circular(node.radius! * 2),
                  onTap: node.options?.onTap,
                  child: Container(
                    width: node.radius! * 2,
                    height: node.radius! * 2,
                    decoration: BoxDecoration(
                      border: node.options?.border ?? const Border(),
                      color: node.options?.color ?? RColor.purpleBgBasic_dbdbff,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: node.options?.child ?? Container()),
                  ),
                ),
              ),
            ),
          ),
        );
    });

    _bubbleWidgetList.addAll(bubbleWidgetList);
    return;
  }

  Future<void> _bubbleChartAniStart() async {
    _bubbleChartAniControllerList.asMap().forEach((key, value) async {
      await Future.delayed(
          const Duration(
            milliseconds: 100,
          ), () async {
        if (mounted) {
          value.forward();
          //_bubbleChartAniControllerList.remove(value);
        }
      });
    });

    /*for (final controller in _bubbleChartAniControllerList) {
      await Future.delayed(
          const Duration(
            milliseconds: 200,
          ), () async {
        if (mounted) {
          controller.forward();
          //_bubbleChartAniControllerList.remove(value);
        }
      });
    }*/
    return;
  }

  _checkAndRequestTrRassi19() {
    if (_pageNo < _totalPageSize) {
      _fetchPosts(
        TR.RASSI19,
        jsonEncode(
          <String, String>{
            'userId': _userId,
            'menuDiv': 'REAL',
            'tradeDate': _listDate[_selectDateIndex].yyyyMMdd,
            'pageNo': '$_pageNo',
            'pageItemSize': '10',
          },
        ),
      );
    } else if (_listRassiroData.isEmpty) {
    } else {
      commonShowToast('더 이상 내용이 없습니다.');
    }
  }

  /// NetWork
  _requestIssue09({required String issueDate}) {
    _fetchPosts(
      TR.ISSUE09,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'issueDate': issueDate,
        },
      ),
    );
  }

  _getDaysOfMonth({required String standardDate}) {
    _listDate.clear();

    // 현재 날짜 정보를 가져옵니다.
    DateTime dateTime = DateTime.parse(standardDate);

    // 현재 년과 월을 저장합니다.
    int year = dateTime.year;
    int month = dateTime.month;

    // 해당 월의 마지막 날을 구합니다.
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // 1일부터 마지막 날까지 반복하여 리스트에 추가합니다.
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      DateTime currentDay = DateTime(year, month, i);
      String formattedDate = DateFormat('yyyyMMdd').format(currentDay);
      String weekDay = _getKoreanWeekDay(currentDay);
      _listDate.add(TimeLapseDateClass(yyyyMMdd: formattedDate, weekDay: weekDay, globalKey: GlobalKey()));
      if (_selectDateIndex == -1 && formattedDate == _todayStrYyyyMmDd) {
        _selectDateIndex = i - 1;
      }
    }
  }

  // 요일을 한국어로 변환하는 함수
  String _getKoreanWeekDay(DateTime date) {
    List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    // DateTime의 weekday는 1(월요일)에서 7(일요일)까지의 값을 가집니다.
    return weekDays[date.weekday - 1];
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);
    if (!_isNetworkDo) {
      setState(() {
        _isNetworkDo = true;
      });
    }

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

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.w(trStr + response.body);

    // NOTE 날짜의 이슈(버블차트 이슈)
    if (trStr == TR.ISSUE09) {
      final TrIssue09 resData = TrIssue09.fromJson(jsonDecode(response.body));
      _pageNo = 0;
      _totalPageSize = 0;
      _listRassiroData.clear();
      _bubbleTimeLapseList.clear();

      Scrollable.ensureVisible(
        _listDate[_selectDateIndex].globalKey.currentContext!,
        alignment: 0.5,
        curve: Curves.fastEaseInToSlowEaseOut,
        duration: const Duration(seconds: 1),
      );

      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.issueDate != _listDate[_selectDateIndex].yyyyMMdd) {
          _bubbleChartAniControllerList.clear();
          _bubbleWidgetList.clear();
          _index02 = const Index02();
          setState(() {
            _isNetworkDo = false;
          });
        } else {
          //_getDaysOfMonth(standardDate: _listDate[_selectDateIndex].yyyyMMdd);

          _bubbleTimeLapseList.addAll(resData.retData.listData);
          if (_listDate[_selectDateIndex].yyyyMMdd == _todayStrYyyyMmDd) {
            _selectTimeLapseIndex = _bubbleTimeLapseList.indexWhere((element) => element.lastDataYn == 'Y');
            _timeLapselastDataIndex = _selectTimeLapseIndex;
            if (_selectTimeLapseIndex == -1) {
              _selectTimeLapseIndex = 0;
              _timeLapselastDataIndex = _selectTimeLapseIndex = 0;
            }
          } else {
            _selectTimeLapseIndex = _bubbleTimeLapseList.length - 1;
            _timeLapselastDataIndex = _bubbleTimeLapseList.length - 1;
          }
          if (_bubbleTimeLapseList.isNotEmpty) {
            await _setBubbleNode();
          }
          _fetchPosts(
              TR.INDEX02,
              jsonEncode(<String, String>{
                'userId': _userId,
                'tradeDate': _listDate[_selectDateIndex].yyyyMMdd,
              }));
        }
      } else {
        _bubbleChartAniControllerList.clear();
        _bubbleWidgetList.clear();
        _index02 = const Index02();
        setState(() {
          _isNetworkDo = false;
        });
      }
    }

    //코스피 코스닥 지수
    else if (trStr == TR.INDEX02) {
      final TrIndex02 resData = TrIndex02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _index02 = resData.retData;
      } else {
        _index02 = const Index02();
      }
      _fetchPosts(
        TR.RASSI19,
        jsonEncode(
          <String, String>{
            'userId': _userId,
            'menuDiv': 'REAL',
            'tradeDate': _listDate[_selectDateIndex].yyyyMMdd,
            'pageNo': '$_pageNo',
            'pageItemSize': '10',
          },
        ),
      ).then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          /*if (_bottomSheetScrollController.position.pixels < _bottomSheetScrollController.position.maxScrollExtent) {
            _bottomSheetScrollController.animateTo(
              _bottomSheetScrollController.position.maxScrollExtent + 20,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          }*/

          if (!_isStartBubbleAnimation && _bubbleWidgetList.isNotEmpty) {
            _isStartBubbleAnimation = true;
            _bubbleChartAniStart().then(
              (_) => _isStartBubbleAnimation = false,
            );
          }
        });
      });
    } else if (trStr == TR.RASSI19) {
      // NOTE 해당 날짜의 특징주 리스트
      final TrRassi19 resData = TrRassi19.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Rassi19 rassi19 = resData.retData;
        if (_pageNo != 0 && _listRassiroData.isNotEmpty) {
          _listRassiroData.removeLast();
        }
        _pageNo++;
        _totalPageSize = int.parse(rassi19.totalPageSize);
        _totalItemSize = rassi19.totalItemSize;
        if (rassi19.listRassiro.isNotEmpty) {
          _listRassiroData.addAll(
            rassi19.listRassiro,
          );
          if (_pageNo < _totalPageSize) {
            _listRassiroData.add(Rassi19Rassiro());
          }
        }
      } else {
        if (_pageNo == 0) {
          _listRassiroData.clear();
        }
      }
      setState(() {
        _isNetworkDo = false;
      });
    }
  }
}

class _SfThumbShape extends SfThumbShape {
  final List<Issue09TimeLapse> bubbleTimeLapseList;

  _SfThumbShape({required this.bubbleTimeLapseList});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required duTextDirection.TextDirection textDirection,
      required SfThumb? thumb}) {
    final double radius = getPreferredSize(themeData).width / 2;
    final bool hasThumbStroke = themeData.thumbStrokeColor != null &&
        themeData.thumbStrokeColor != Colors.transparent &&
        themeData.thumbStrokeWidth != null &&
        themeData.thumbStrokeWidth! > 0;

    if (themeData is SfRangeSliderThemeData &&
        !hasThumbStroke &&
        themeData.thumbColor != Colors.transparent &&
        themeData.overlappingThumbStrokeColor != null) {
      context.canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = themeData.overlappingThumbStrokeColor!
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true
            ..strokeWidth = 1.0);
    }

    if (paint == null) {
      paint = Paint();
      paint.isAntiAlias = true;
      paint.color =
          ColorTween(begin: themeData.disabledThumbColor, end: themeData.thumbColor).evaluate(enableAnimation)!;
    }

    context.canvas.drawCircle(center, radius, paint);
    if (child != null) {
      context.paintChild(child, Offset(center.dx - (child.size.width) / 2, center.dy - (child.size.height) / 2));
    }

    if (themeData.thumbStrokeColor != null && themeData.thumbStrokeWidth != null && themeData.thumbStrokeWidth! > 0) {
      final Paint strokePaint = Paint()
        ..color = themeData.thumbStrokeColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = themeData.thumbStrokeWidth! > radius ? radius : themeData.thumbStrokeWidth!;
      context.canvas.drawCircle(center,
          themeData.thumbStrokeWidth! > radius ? radius / 2 : radius - themeData.thumbStrokeWidth! / 2, strokePaint);
    }

    // "문구영역" 텍스트를 원 아래에 추가
    String time = bubbleTimeLapseList[currentValue as int].timeLapse;
    final TextSpan span = TextSpan(
      text: '${time.substring(0, 2)}:${time.substring(
        2,
      )}',
      style: const TextStyle(
        color: RColor.greyMore_999999,
        fontSize: 14.0,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: duTextDirection.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(context.canvas, Offset(center.dx - tp.width / 2, center.dy + radius + 5));
  }
}

class TimeLapseDateClass {
  final String yyyyMMdd;
  final String weekDay;
  final GlobalKey globalKey;

  const TimeLapseDateClass({
    required this.yyyyMMdd,
    required this.weekDay,
    required this.globalKey,
  });
}
