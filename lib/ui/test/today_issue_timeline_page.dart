import 'dart:async';
import 'dart:convert';
import 'dart:ui' as duTextDirection;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_index/tr_index02.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue03.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue08.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue09.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi19.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_date_picker.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleNode.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleRoot.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
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
  final List<Issue08> _listIssue08 = []; // 날짜 리스트
  String _selectStrYyyyMmDd = TStyle.getTodayString();
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

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      TodayIssueTimelinePage.TAG_NAME,
    );
    _rassiroListScrollController.addListener(() {
      if (_rassiroListScrollController.hasClients && _rassiroListScrollController.position.atEdge) {
        bool isTop = _rassiroListScrollController.position.pixels == 0;
        if (!isTop) {
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
    _loadPrefData().then((value) {
      _requestIssue08(issueDate: _todayStrYyyyMmDd);
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: CommonAppbar.basic(buildContext: context, title: '오늘의 이슈 타임라인', elevation: 1),
      backgroundColor: RColor.bgBasic_fdfdfd,
      bottomSheet: BottomSheet(
        builder: (context) => SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 12),
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
              height: _isFaVisible ? 100 : 0,
              duration: const Duration(
                milliseconds: 300,
              ),
              padding: const EdgeInsets.all(15),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(_scaffoldKey.currentState!.context).viewPadding.bottom,
              ),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectStrYyyyMmDd.substring(4, 6)}월',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Image.asset('images/icon_arrow_down.png', width: 14, height: 14),
                    onPressed: () async {
                      await CommonDatePicker.showYearMonthPicker(context, DateTime.parse(_listIssue08.last.issueDate))
                          .then((value) {
                        if (value != null) {
                          DateTime selectMonthLastDateTime = DateTime(
                            value.year,
                            value.month + 1,
                            0,
                          );

                          if (!_isNetworkDo) {
                            _requestIssue08(issueDate: DateFormat('yyyyMMdd').format(selectMonthLastDateTime));
                          }
                        }
                      });
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                  IconButton(
                    icon: Image.asset(
                      'images/main_jm_aw_l_g.png',
                      width: 16,
                      height: 14,
                    ),
                    onPressed: () {
                      if (!_isNetworkDo) {
                        _requestIssue08(issueDate: _listIssue08[_listIssue08.length - 2].issueDate);
                      }
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) => _bottomSheetDateView(index),
                      itemCount: _listIssue08.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      controller: _bottomSheetScrollController,
                    ),
                  ),
                  IconButton(
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
                  ),
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
              SingleChildScrollView(
                controller: _rassiroListScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),



                    // 코스피 코스닥 지수
                    _kosIndexView,

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
                              text: '${_selectStrYyyyMmDd.substring(4, 6)}월 ${_selectStrYyyyMmDd.substring(6, 8)}일에 총 ',
                            ),
                            TextSpan(
                              text: _listIssue08.isEmpty ? '' : _listIssue08.last.issueCount,
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

                    _realStocksView,
                    //MarketTileTodayMarket(index02: _index02),

                    const SizedBox(
                      height: 30,
                    ),


                  ],
                ),
              ),
              Visibility(
                visible: _isNetworkDo,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.withOpacity(0.1),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/gif_ios_loading_large.gif',
                    height: 20,
                  ),
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
    bool isSelectedDate = index == _listIssue08.length - 1 ? true : false;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (!isSelectedDate && !_isNetworkDo) {
          _requestIssue08(issueDate: _listIssue08[index].issueDate);
        }
      },
      child: Container(
        width: isSelectedDate ? 50 : 46,
        margin: EdgeInsets.symmetric(
          horizontal: isSelectedDate ? 2 : 0,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          color: isSelectedDate ? Colors.black : null,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _listIssue08[index].weekday,
                style: isSelectedDate
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
                _listIssue08[index].issueDate.substring(
                      6,
                    ),
                style: isSelectedDate
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

  Widget get _kosIndexView {
    return Visibility(
      visible: _index02.baseDate.isNotEmpty && _index02.kospi.fluctuationRate.isNotEmpty && _index02.kosdaq.fluctuationRate.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 - [날짜] 시장은?
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Text(
              '${_selectStrYyyyMmDd.substring(4, 6)}월 ${_selectStrYyyyMmDd.substring(6, 8)}일 시장은?',
              style: TStyle.defaultTitle,
            ),
          ),
          Container(
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
                  '코스닥은 ${_index02.kosdaq.fluctuationRate}% ${_index02.kosdaq.fluctuationRate.contains('-') ? '하락' : '상승'}'
                  '하였습니다.',
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/icon_event_chart_0.png'),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '코스피',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${TStyle.getMoneyPoint(_index02.kospi.priceIndex)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  TStyle.getTriangleStringWithMoneyPoint(_index02.kospi.indexFluctuation),
                                  style: TextStyle(
                                    //fontSize: 14,
                                    color: TStyle.getMinusPlusColor(_index02.kospi.fluctuationRate),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  TStyle.getPercentString(
                                    _index02.kospi.fluctuationRate,
                                  ),
                                  style: TextStyle(
                                    //fontSize: 12,
                                    color: TStyle.getMinusPlusColor(_index02.kospi.fluctuationRate),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/icon_event_chart_0.png'),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '코스닥',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${TStyle.getMoneyPoint(_index02.kosdaq.priceIndex)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  TStyle.getTriangleStringWithMoneyPoint(_index02.kosdaq.indexFluctuation),
                                  style: TextStyle(
                                    //fontSize: 14,
                                    color: TStyle.getMinusPlusColor(_index02.kosdaq.fluctuationRate),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  TStyle.getPercentString(
                                    _index02.kosdaq.fluctuationRate,
                                  ),
                                  style: TextStyle(
                                    //fontSize: 12,
                                    color: TStyle.getMinusPlusColor(_index02.kosdaq.fluctuationRate),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        Image.asset(
          'images/icon_time_lapse_clock_grey.png',
          width: 20,
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
                } else {
                  _selectTimeLapseIndex = (newValue as double).toInt();
                  if (_bubbleTimeLapseList[_selectTimeLapseIndex].listData.isEmpty) {
                    //commonShowToastCenter('_bubbleTimeLapseList[_selectTimeLapseIndex].listData : ${_bubbleTimeLapseList[_selectTimeLapseIndex].listData.length}');
                  } else {
                    //commonShowToastCenter('_bubbleTimeLapseList[_selectTimeLapseIndex].listData.length : ${_bubbleTimeLapseList[_selectTimeLapseIndex].listData.length}');
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

  Widget get _realStocksView{
    if(_listRassiroData.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀 - 특징주 종목들은?
        const SizedBox(height: 30,),
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
                  '${_selectStrYyyyMmDd.substring(4, 6)}월 ${_selectStrYyyyMmDd.substring(6, 8)}일 특징주는 총 ',
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
            Navigator.push(
              context,
              CustomNvRouteClass.createRouteData(
                const IssueViewer(),
                RouteSettings(
                  arguments: PgData(
                    userId: '',
                    pgSn: item.newsSn,
                    pgData: item.issueSn,
                  ),
                ),
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
            'tradeDate': _selectStrYyyyMmDd,
            'pageNo': '$_pageNo',
            'pageItemSize': '10',
          },
        ),
      );
    } else{
      commonShowToast('더 이상 내용이 없습니다.');
    }
  }

  /// NetWork
  _requestIssue08({required String issueDate}) {
    _fetchPosts(
      TR.ISSUE08,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'issueDate': issueDate,
          'selectCount': '20',
        },
      ),
    );
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

    // NOTE 오늘 날짜로 요청 > 해당 일이 영업일이 아니라면 가장가까운 영업일(과거)부터 과거 20일 동안의 영업일 리턴
    if (trStr == TR.ISSUE08) {
      final TrIssue08 resData = TrIssue08.fromJson(jsonDecode(response.body));
      _listIssue08.clear();
      if (resData.retCode == RT.SUCCESS && resData.listData.isNotEmpty) {
        _listIssue08.addAll(resData.listData);
        _selectStrYyyyMmDd = _listIssue08.last.issueDate;

        _listRassiroData.clear();
        _pageNo = 0;
        _totalPageSize = 0;

        _fetchPosts(
          TR.ISSUE09,
          jsonEncode(
            <String, String>{
              'userId': _userId,
              'issueDate': _selectStrYyyyMmDd,
            },
          ),
        );
      }
    }

    // NOTE 날짜의 이슈(버블차트 이슈)
    else if (trStr == TR.ISSUE09) {
      final TrIssue09 resData = TrIssue09.fromJson(jsonDecode(response.body));
      _bubbleTimeLapseList.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.issueDate != _selectStrYyyyMmDd) {
          _requestIssue08(issueDate: resData.retData.issueDate);
        } else {
          _bubbleTimeLapseList.addAll(resData.retData.listData);
          if (_selectStrYyyyMmDd == _todayStrYyyyMmDd) {
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
        }
        if (_bubbleTimeLapseList.isNotEmpty) {
          await _setBubbleNode();
        }
      }
      _fetchPosts(
          TR.INDEX02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'tradeDate': _selectStrYyyyMmDd,
          }));
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
            'tradeDate': _selectStrYyyyMmDd,
            'pageNo': '$_pageNo',
            'pageItemSize': '10',
          },
        ),
      ).then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_bottomSheetScrollController.position.pixels < _bottomSheetScrollController.position.maxScrollExtent) {
            _bottomSheetScrollController.animateTo(
              _bottomSheetScrollController.position.maxScrollExtent + 20,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          }
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
        if (_pageNo != 0) {
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
