import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search12.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_event_view_div_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_expanded_view.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/only_web_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/stock_home/page/recent_social_list_page.dart';
import 'package:rassi_assist/ui/stock_home/page/result_analyze_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_disclos_list_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_issue_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_최상단 메인 이벤트 차트

class StockHomeHomeTileEventView extends StatefulWidget {
  static String TAG = 'StockHomeHomeTileEventView';
  static final GlobalKey<StockHomeHomeTileEventViewState> globalKey =
      GlobalKey();

  StockHomeHomeTileEventView() : super(key: globalKey);

  @override
  State<StockHomeHomeTileEventView> createState() =>
      StockHomeHomeTileEventViewState();
}

class StockHomeHomeTileEventViewState extends State<StockHomeHomeTileEventView>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileEventView> {
  final _appGlobal = AppGlobal();
  String _userId = '';
  String _stockCode = '';
  String _stockName = '';
  bool _beforeOpening = false;
  bool _beforeChart = false;
  String _fluctuationRate = '0';

  // 1일 1개월 3개월..
  late StockHomeEventViewDivProvider _stockHomeEventViewDivProvider;
  final List<Search12DivModel> _listChartDateDivModel = Search12DivModel().getListDate();

  // 이슈발생, 커뮤니티, 시세특이, 공시발생
  int _eventDivSelectedIndex = 0;
  final List<Search12DivModel> _listEventChartDivModel = Search12DivModel().getListEvent();

  final List<String> _listEventMoreStr = [
    '종목이슈',
    '소셜지수',
    '자세한 차트',
    '공시 모아',
    '실적분석'
  ];

  // 이벤트 차트 변수
  String _eventChartOption = '{}';
  String _eventChartData = '[]';
  String _eventChartXAxisData = '[]';
  String _eventChartMarkPointData = '[]';
  String _eventChartRightMargin = '20%';
  final List<Search12ChartData> _listPriceEventChart = [];

  // 일반 차트 변수
  String _commonChartOption = '{}';
  String _commonChartData = '[]';
  String _commonChartXAxisData = '[]';
  String _commonChartMarkPointData = '[]';
  String _commonChartMarkLine = '{}';
  String _commonChartPreClosePrice = '';
  String _commonChartRightMargin = '20%';
  final List<Search12ChartData> _listPriceCommonChart = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _userId = _appGlobal.userId;
    _stockCode = _appGlobal.stkCode;
    _stockName = _appGlobal.stkName;
    if (_stockHomeEventViewDivProvider.getIndex != 0) {
      _stockHomeEventViewDivProvider.setIndex(0);
    }
    _requestTrAll();
  }

  @override
  void initState() {
    super.initState();
    _stockHomeEventViewDivProvider = Provider.of<StockHomeEventViewDivProvider>(
      context,
      listen: false,
    );
    initPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        5,
        10,
        5,
        20,
      ),
      child: Column(
        children: [
          _setStockInfo(),
          Container(
            width: double.infinity,
            height: 250,
            color: RColor.bgBasic_fdfdfd,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Echarts(
                    captureAllGestures: true,
                    reloadAfterInit: true,
                    onWebResourceError: (p0, p1) {
                      DLog.e('onWebResourceError p0 : $p0 / p1 : $p1');
                    },
                    option: _stockHomeEventViewDivProvider.getIndex == 2
                        ? _eventChartOption
                        : _commonChartOption,
                    extraScript: '''
                  const upColor = 'red'; // 상승 봉 색깔
                  const upBorderColor = 'red'; // 상승 선 색깔
                  const downColor = 'blue';
                  const downBorderColor = 'blue';
                  function numberWithCommas(x) {
                    return x.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");
                  };
                  function dateDotFormatter(x) {
                    if (x.toString().length < 7) {
                      return x.substring(0,2) + ':' + x.substring(2,4);
                    }
                    var result = x.toString();
                    result =
                      result.substring(2, 4) +'/'
                      + result.substring(4, 6) + '/'
                      + result.substring(6, 8);
                      return result;
                  };                 
                  chart.on('mousemove', function (params) {
                      Messager.postMessage('mousemove4');
                  });
                  chart.on('mouseup', function (params) {
                      Messager.postMessage('mouseup');
                  });
                  chart.on('mouseover', (params) => {
                      chart.dispatchAction({
                        type: 'highlight',
                        seriesIndex: [0],
                        dataIndex: [0],
                      });
                      chart.dispatchAction({
                        type: 'showTip',
                        seriesIndex: 0,
                        dataIndex: 0,
                      });
                      Messager.postMessage('mouseover');
                  });
                  
                  chart.on('globalout', (params) => {
                      Messager.postMessage('globalout');
                  });
                  
                  chart.on('mousedown', (params) => {
                      Messager.postMessage('mousedown');
                  });
                  
                  chart.on('mouseout', (params) => {
                      chart.dispatchAction({
                        type: 'downplay',
                        seriesIndex: [0],
                        dataIndex: [0],
                      });
                      chart.dispatchAction({
                        type: 'hideTip',
                        seriesIndex: 0,
                        dataIndex: 0,
                      });
                      Messager.postMessage('mouseout');
                  });
                  ''',
                    onMessage: (String message) {
                      DLog.w('message : $message');
                    },
                  ),
                ),
                if (_beforeOpening &&
                    _stockHomeEventViewDivProvider.getIndex == 0)
                  Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    child: const Text('장 시작 전 입니다.'),
                  )
                else if (_beforeChart &&
                    _stockHomeEventViewDivProvider.getIndex == 0)
                  Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    child: const Text(
                      '20분부터 업데이트 됩니다.\n(20분 지연)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  )
                else if (_stockHomeEventViewDivProvider.getIndex == 2 &&
                    _isEventExist)
                  Container(
                    alignment: Alignment.center,
                    //color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    child: Text(
                      '최근 3개월간 ${_listEventChartDivModel[_eventDivSelectedIndex].divName.replaceAll('\n', '')} 이벤트가 없습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ),

                /*Visibility(
                  visible: _beforeOpening &&
                      _stockHomeEventViewDivProvider.getIndex == 0,
                  child: Container(
                    alignment: Alignment.center,
                    color: RColor.bgBasic_fdfdfd,
                    margin: const EdgeInsets.only(bottom: 30,),
                    child: const Text('장 시작 전 입니다.'),
                  ),
                ),*/
                /* Visibility(
                  visible: _stockHomeEventViewDivProvider.getIndex == 2 &&
                      _isEventExist,
                  child: Center(
                    child: Text(
                      '최근 3개월간 ${_listEventChartDivModel[_eventDivSelectedIndex].divName.replaceAll('\n', '')} 이벤트가 없습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.greyBasic_8c8c8c,
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 10.0,
              alignment: WrapAlignment.center,
              children: List.generate(
                _listChartDateDivModel.length,
                (index) => _setEventChartDateDivView(index),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          CommonExpandedView(
            expand: _stockHomeEventViewDivProvider.getIndex == 2,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  decoration: UIStyle.boxRoundFullColor6c(
                    RColor.greyBox_f5f5f5,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'EVENT를 선택 후 발생 시점을 차트에서 확인해 보세요.',
                    style: TextStyle(
                      fontSize: 13,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  child: Wrap(
                    spacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      _listEventChartDivModel.length,
                      (index) => _setEventDivView(index),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: UIStyle.boxRoundLine6(),
                    alignment: Alignment.center,
                    child: Text(
                      '${_listEventMoreStr[_eventDivSelectedIndex]} 보기',
                      //style: TStyle.subTitle16,
                    ),
                  ),
                  onTap: () {
                    switch (_eventDivSelectedIndex) {
                      case 0:
                        {
                          // make
                          basePageState.callPageRoute(
                            StockIssuePage(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                      case 1:
                        {
                          // 커뮤니티
                          basePageState.callPageRouteData(
                            RecentSocialListPage(),
                            PgData(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                      case 2:
                        {
                          // 시세특이
                          Navigator.push(
                            context,
                            CustomNvRouteClass.createRoute(
                              OnlyWebViewPage(
                                title: '',
                                url:
                                    'https://m.thinkpool.com/item/$_stockCode/chart',
                              ),
                            ),
                          );
                          break;
                        }
                      case 3:
                        {
                          // 공시발생
                          basePageState.callPageRouteData(
                            const StockDisclosListPage(),
                            PgData(
                              stockName: AppGlobal().stkName,
                              stockCode: AppGlobal().stkCode,
                            ),
                          );
                          break;
                        }
                      case 4:
                        {
                          // 실적발표
                          basePageState.callPageRouteData(
                            ResultAnalyzePage(),
                            PgData(
                              stockName: _appGlobal.stkName,
                              stockCode: _appGlobal.stkCode,
                            ),
                          );
                          break;
                        }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 종목정보 - 가격, 등락률, 서브정보들
  Widget _setStockInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        _stockName,
                        style: TStyle.title18T,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      _stockCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Consumer<StockInfoProvider>(
                builder: ((_, provider, child) {
                  if (provider.getIsMyStock) {
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: UIStyle.boxRoundLine6LineColor(
                          RColor.mainColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 17,
                              height: 17,
                              child: Image.asset(
                                'images/icon_my_pock_on.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              '포켓에서 삭제',
                              style: TextStyle(
                                fontSize: 13,
                                color: RColor.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        StockHomeTab.globalKey.currentState
                            ?.showDelStockPopupAndResult(
                          provider.getPockSn,
                        );
                      },
                    );
                  } else {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration:
                            UIStyle.boxRoundLine6LineColor(Colors.black),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 17,
                              height: 17,
                              child: Image.asset(
                                'images/icon_my_pock_off.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              '포켓에 넣기',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        StockHomeTab.globalKey.currentState
                            ?.showAddStockLayerAndResult();
                      },
                    );
                  }
                }),
              ),
            ],
          ),
          Consumer<StockInfoProvider>(
            builder: (_, provider, __) {
              if (provider.getIsLoading) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 71,
                  child: SkeletonLoader(
                    items: 1,
                    period: const Duration(seconds: 2),
                    highlightColor: Colors.grey[100]!,
                    direction: SkeletonDirection.ltr,
                    builder: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                      ),
                      alignment: Alignment.centerLeft,
                      //decoration: UIStyle.boxRoundLine6(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 2 / 5,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: 71,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            TStyle.getMoneyPoint(provider.getCurrentPrice),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                          const Text(
                            '원',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            provider.getTimeTxt,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: provider.getTradingHaltYn == 'N'
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        provider.getCurrentSubInfo,
                                        style: TextStyle(
                                          color: TStyle.getMinusPlusColor(
                                            provider.getFluctaionRate,
                                          ),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _stockHomeEventViewDivProvider
                                                    ?.getIndex ==
                                                0
                                            ? ''
                                            : _stockHomeEventViewDivProvider
                                                        ?.getIndex ==
                                                    1
                                                ? '(1개월 수익률)'
                                                : _stockHomeEventViewDivProvider
                                                            ?.getIndex ==
                                                        2
                                                    ? '(3개월 수익률)'
                                                    : _stockHomeEventViewDivProvider
                                                                ?.getIndex ==
                                                            3
                                                        ? '(올해 수익률)'
                                                        : _stockHomeEventViewDivProvider
                                                                    ?.getIndex ==
                                                                4
                                                            ? '(1년 수익률)'
                                                            : _stockHomeEventViewDivProvider
                                                                        ?.getIndex ==
                                                                    5
                                                                ? '(3년 수익률)'
                                                                : '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: const [
                                      Text(
                                        '0  0.00%',
                                        style: TextStyle(
                                          color: RColor.greyBasic_8c8c8c,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '거래정지',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: RColor.greyBasic_8c8c8c,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            width: 76,
                            child: IconButton(
                              icon: Image.asset('images/icon_chart1.png'),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.topRight,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                // 시세특이
                                Navigator.push(
                                  context,
                                  CustomNvRouteClass.createRoute(
                                    OnlyWebViewPage(
                                      title: '',
                                      url:
                                          'https://m.thinkpool.com/item/$_stockCode/chart',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _setEventChartDateDivView(int index) {
    if (_stockHomeEventViewDivProvider?.getIndex == index) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: UIStyle.boxRoundFullColor25c(
          RColor.greySliderBar_ebebeb,
        ),
        child: Text(
          _listChartDateDivModel[index].divName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );
    } else {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          _stockHomeEventViewDivProvider?.setIndex(index);
          Provider.of<StockInfoProvider>(context, listen: false).postRequestDiv(
            _stockCode,
            _listChartDateDivModel[index].divCode,
          );
          _requestTrAll();
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Text(
            _listChartDateDivModel[index].divName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RColor.greyBasic_8c8c8c,
            ),
          ),
        ),
      );
    }
  }

  Widget _setEventDivView(int index) {
    if (_eventDivSelectedIndex == index) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Text(
          _listEventChartDivModel[index].divName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      );
    } else {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          _eventDivSelectedIndex = index;
          _requestTrAll();
          /* setState(() {
            _eventDivSelectedIndex = index;
            _requestTrAll();
          });*/
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            //color: RColor.greyBoxLine_c9c9c9,
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: RColor.greyBasic_8c8c8c,
              width: 1,
            ),
          ),
          child: Text(
            _listEventChartDivModel[index].divName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: RColor.greyBasic_8c8c8c,
              height: 1.2,
            ),
          ),
        ),
      );
    }
  }

  // 이벤트 차트 셋팅
  _initEventChartOption() {
    // DEFINE 라인 / 봉 차트 데이터 파싱 + 마크 포인트 파싱
    _eventChartData = '[';
    _eventChartMarkPointData = '[';
    _eventChartXAxisData = '[';
    String eventChartMarkPointYAxisValue = '0'; //마크포인트 찍는 y좌표 = 최고가 위에 찍어야함

    _listPriceEventChart.asMap().forEach(
      (index, value) {
        //_eventChartData += '${double.parse(value.tp)},';
        _eventChartData +=
            '{value : ${double.tryParse(value.tp) ?? "''"}, value1: ${value.ec}, value2: [';

        for (var element in value.titleList) {
          _eventChartData += "'$element',";
        }

        _eventChartData += '],},';
        //'value2: [ ${value.ec}, ${int.parse(value.ec) + 1}, ${int.parse(value.ec) + 2}, ${int.parse(value.ec) + 3} ],},'

        eventChartMarkPointYAxisValue = value.tp;
        switch (value.ec) {
          case '0':
            break;
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
            _eventChartMarkPointData += '''
            {
              coord: [$index, $eventChartMarkPointYAxisValue,],
              name: "${value.td}",              
              symbol: '${_eventDivSelectedIndex == 0 ? 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_is.png' : _eventDivSelectedIndex == 1 ? 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_com.png' : _eventDivSelectedIndex == 2 ? 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_pr.png' : _eventDivSelectedIndex == 3 ? 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_no.png' : _eventDivSelectedIndex == 4 ? 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_re.png' : 'image://https://files.thinkpool.com/rassi_signal/rs_img_bell_is.png'}',
              symbolSize: '${_eventDivSelectedIndex == 0 || _eventDivSelectedIndex == 1 || _eventDivSelectedIndex == 2 ? 10 : 15}',
            },
            ''';
            break;
        }

        _eventChartXAxisData += "'${value.td}',";
      },
    );

    var maxTpItem = _findMaxTpEventItem;
    bool isOffsetMax = (maxTpItem.index < _listPriceEventChart.length / 10) ||
            (maxTpItem.index >
                _listPriceEventChart.length -
                    (_listPriceEventChart.length / 10))
        ? true
        : false;
    _eventChartMarkPointData += '''
    {        
      coord: [${maxTpItem.index}, ${maxTpItem.tp}],
      value: '최고${isOffsetMax ? '\\n' : ' '}${TStyle.getMoneyPoint(maxTpItem.tp)}',
      symbol: 'roundRect',
      symbolSize: 0.1,      
       label: {
        show: true,
        backgroundColor: 'transparent',
        color: '#FC525B',
        textStyle: {
          fontSize: 11,
        },       
        position: 'top',
      },
    },
    ''';

    var minTpItem = _findMinTpEventItem;
    bool isOffsetMin = (minTpItem.index < _listPriceEventChart.length / 10) ||
            (minTpItem.index >
                _listPriceEventChart.length -
                    (_listPriceEventChart.length / 10))
        ? true
        : false;
    _eventChartMarkPointData += '''
    {        
      coord: [${minTpItem.index}, ${minTpItem.tp}],
      value: '최저${isOffsetMin ? '\\n' : ' '}${TStyle.getMoneyPoint(minTpItem.tp)}',
      symbol: 'roundRect',
      symbolSize: 0.1,
      label: {
        show: true,
        backgroundColor: 'transparent',
        color: '#6A86E7',
        textStyle: {
          fontSize: 10.5,
        },        
        position: 'bottom',
      },
    },
    ''';

    //symbolOffset: ['${minTpItem.index > (_listPriceChart.length / 2) ? '-300%' : '200%'}', '100%'],

    _eventChartData += ']';
    _eventChartMarkPointData += ']';
    _eventChartXAxisData += ']';

    //DLog.d('','_eventChartData : $_eventChartData');
    //DLog.d('','_eventChartMarkPointData : $_eventChartMarkPointData');
    //DLog.d('','_eventChartXAxisData : $_eventChartXAxisData');

    double maxTp = double.tryParse(_findMaxTpEventItem.tp) ?? 0;
    _eventChartRightMargin = maxTp > 1000000
        ? '20%'
        : maxTp > 100000
            ? '18%'
            : maxTp > 10000
                ? '16%'
                : maxTp > 1000
                    ? '14%'
                    : maxTp > 100
                        ? '12%'
                        : maxTp > 10
                            ? '10%'
                            : '20%';

    _initCommonChartOption();
  }

  Search12ChartData get _findMaxTpEventItem {
    if (_listPriceEventChart.isEmpty) {
      return Search12ChartData.empty();
    } else if (_listPriceEventChart.length == 1) {
      return _listPriceEventChart[0];
    } else {
      return _listPriceEventChart.reduce(
        (curr, next) =>
            (double.tryParse(curr.tp) ?? 0) > (double.tryParse(next.tp) ?? 0)
                ? curr
                : next,
      );
    }
  }

  Search12ChartData get _findMinTpEventItem {
    if (_listPriceEventChart.isEmpty) {
      return Search12ChartData.empty();
    } else if (_listPriceEventChart.length == 1) {
      return _listPriceEventChart[0];
    } else {
      return _listPriceEventChart.reduce(
        (curr, next) =>
            (double.tryParse(curr.tp) ?? 0) > (double.tryParse(next.tp) ?? 0)
                ? next
                : curr,
      );
    }
  }

  // 일반 차트 셋팅
  _initCommonChartOption() {
    // DEFINE 라인 / 봉 차트 데이터 파싱 + 마크 포인트 파싱
    _commonChartData = '[';
    _commonChartMarkPointData = '[';
    _commonChartMarkLine = '{}';
    _commonChartXAxisData = '[';
    _listPriceCommonChart.asMap().forEach(
      (index, value) {
        _commonChartData +=
            '{value : ${double.tryParse(value.tp)}, value1: ${value.ec}, value2: [';
        for (var element in value.titleList) {
          _commonChartData += "'$element',";
        }
        //_commonChartData += "], lineStyle: { color: 'red', width: 15, }, },";

        _commonChartData += '],},';
        _commonChartXAxisData +=
            "'${_stockHomeEventViewDivProvider?.getIndex == 0 ? value.tt : value.td}',";
      },
    );

    if (_eventDivSelectedIndex == 0 && (_beforeOpening || _beforeChart)) {
    } else {
      var maxTpItem = _findMaxTpCommonItem;
      bool isOffsetMax =
          (maxTpItem.index < _listPriceCommonChart.length / 10) ||
                  (maxTpItem.index >
                      _listPriceCommonChart.length -
                          (_listPriceCommonChart.length / 10))
              ? true
              : false;
      _commonChartMarkPointData += '''
    {        
      coord: [${maxTpItem.index}, ${maxTpItem.tp}],
      value: '최고${isOffsetMax ? '\\n' : ' '}${TStyle.getMoneyPoint(maxTpItem.tp)}',
      symbol: 'roundRect',
      symbolSize: 0.1,
       label: {
        show: true,
        backgroundColor: 'transparent',
        color: '#FC525B',
        textStyle: {
          fontSize: 11,
        }, 
        position: 'top',      
      },
    },
    ''';

      var minTpItem = _findMinTpCommonItem;
      bool isOffsetMin =
          (minTpItem.index < _listPriceCommonChart.length / 10) ||
                  (minTpItem.index >
                      _listPriceCommonChart.length -
                          (_listPriceCommonChart.length / 10))
              ? true
              : false;
      _commonChartMarkPointData += '''
    {        
      coord: [${minTpItem.index}, ${minTpItem.tp}],
      value: '최저${isOffsetMin ? '\\n' : ' '}${TStyle.getMoneyPoint(minTpItem.tp)}',
      symbol: 'roundRect',
      symbolSize: 0.1,      
      label: {
        show: true,
        backgroundColor: 'transparent',
        color: '#6A86E7',
        textStyle: {
          fontSize: 10.5,
        },        
        position: 'bottom',
      },
    },
    ''';
    }

    if (_stockHomeEventViewDivProvider?.getIndex == 0 && !_beforeOpening) {
      _commonChartMarkLine = '''
    {
      show: ${_stockHomeEventViewDivProvider?.getIndex == 0 ? 'true' : 'false'},
      symbol: 'none',      
      label: {
        show: true,
        position: 'insideEndTop',
        formatter:'전일종가 ${TStyle.getMoneyPoint(
        _commonChartPreClosePrice,
      )}',
        fontSize: 10,
        color: '#8C8C8C',
      },
      silent: false,
      emphasis: {
        disabled: false,
      },
      lineStyle: {
        color: '#8C8C8C',
      },
      data: [{
        yAxis: '$_commonChartPreClosePrice',
      },],
    },    
    ''';
    }

    _commonChartData += ']';
    _commonChartMarkPointData += ']';
    _commonChartXAxisData += ']';

    //DLog.w('_commonChartData : $_commonChartData');
    //DLog.w('_commonChartMarkPointData : $_commonChartMarkPointData');
    //DLog.w('_commonChartXAxisData : $_commonChartXAxisData');

    double maxTp = double.tryParse(_findMaxTpCommonItem.tp) ?? 0;
    _commonChartRightMargin = _stockHomeEventViewDivProvider.getIndex == 0 &&
            (_beforeOpening || _beforeChart)
        ? '5%'
        : maxTp > 1000000
            ? '20%'
            : maxTp > 100000
                ? '18%'
                : maxTp > 10000
                    ? '16%'
                    : maxTp > 1000
                        ? '14%'
                        : maxTp > 100
                            ? '12%'
                            : maxTp > 10
                                ? '10%'
                                : '20%';

    _initChartOption();
  }

  Search12ChartData get _findMaxTpCommonItem {
    if (_listPriceCommonChart.isEmpty) {
      return Search12ChartData.empty();
    } else if (_listPriceCommonChart.length == 1) {
      return _listPriceCommonChart[0];
    } else {
      return _listPriceCommonChart.reduce(
        (curr, next) => double.tryParse(curr.tp) == null
            ? next
            : double.tryParse(next.tp) == null
                ? curr
                : double.parse(curr.tp) > double.parse(next.tp)
                    ? curr
                    : next,
      );
    }
  }

  Search12ChartData get _findMinTpCommonItem {
    if (_listPriceCommonChart.isEmpty) {
      return Search12ChartData.empty();
    } else if (_listPriceCommonChart.length == 1) {
      return _listPriceCommonChart[0];
    } else {
      return _listPriceCommonChart.reduce(
        (curr, next) => double.tryParse(curr.tp) == null
            ? next
            : double.tryParse(next.tp) == null
                ? curr
                : double.parse(curr.tp) > double.parse(next.tp)
                    ? next
                    : curr,
      );
    }
  }

  int get _find1DEventHasTpCount {
    int count = 0;
    _listPriceCommonChart
        .takeWhile((value) => value.tp.isNotEmpty)
        .forEach((element) {
      count = element.index;
    });
    return count;
  }

  bool get _isEventExist {
    //bool isEventExist = false;
    for (var item in _listPriceEventChart) {
      int eventCount = int.tryParse(item.ec) ?? 0;
      if (eventCount != 0) {
        return false;
      }
    }
    return true;
    //return isEventExist;
  }

  // 차트 이닛 옵션
  _initChartOption() {
    String lineColor = _fluctuationRate.contains('-') ? '#9eb3ff' : '#FF9090';
    String areaColor = _fluctuationRate.contains('-') ? '#b4c3fa' : '#eea0a0';

    _eventChartOption = '''
{
    tooltip: {
        transitionDuration: 0,
        confine: true,
        trigger: 'none',
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        formatter: function(params) {
            let tooltip = ``;
            params.forEach(({
                marker,
                seriesName,
                value
            }) => {
                value = value || [0];
                tooltip += `
                              <div style="text-align:left;">
                              <span style="text-align:left;color:#8C8C8C;font-size:12px;";> \${dateDotFormatter(params[0].axisValue)} </span>
                                 &nbsp;\${numberWithCommas(params[0].data.value)}원
                              </div>                                                
                            `;   
                for (var i = 0; i < params[0].data.value2.length; i++) {
                    tooltip += ` <div style="text-align:left;color:#7774F7;";>
        \${params[0].data.value2[i]}
        </div>
        `;
                };
            });
            return tooltip;
        },
        position: function(pos, params, dom, rect, size) {          
            if (pos[0] < size.viewSize[0] / 2) return [pos[0] + 15, 'top'];
            else return [pos[0] - 100, 'top'];
        },          
    },
    dataZoom: [{
        type: 'inside',
        disabled: false,
        zoomLock: true,
    }, ],
    grid: {
        left: '5%',
        top: '10%',
         right: '$_eventChartRightMargin',
        bottom: '18%',
    },
    xAxis: {
        type: 'category',
        show: true,
        boundaryGap: false,
        data: $_eventChartXAxisData,
        axisLabel: {
            formatter: function(value, index) {
                return dateDotFormatter(value);
            },
            color: '#8C8C8C',
            fontSize: 10,
        },        
        offset: 25,
        axisPointer: {
            show: true,
            label: {
                show: false,
            },
            snap: true,
            lineStyle: { color: 'black' , }, }, }, 
    yAxis: { 
      type: 'value',
      position: 'right',
      min: function(value) { 
        return value.min
      },
      triggerEvent: false,
      show: true,
      axisLabel: {
        color: 'black',
      },
      offset: 5,
    },
        series: [{
            type: 'line',
            symbol: 'none',
            triggerEvent: false,
            name: 'chart',
            lineStyle: {
                color: '$lineColor',
                width: 1,
            },            
            silent: false,
                          symbol: function(value, params){
                             if (params.dataIndex == 0 || params.dataIndex == ${_listPriceEventChart.length - 1}) {
                              return 'circle';
                            } 
                            else {
                              return 'none';
                            }
                          },
                          showSymbol: 'true',
                          showAllSymbol: 'true',
                          symbolSize: 6,
                                                    bolderWhenHover: false,
            itemStyle: {
              borderWidth: 0,
              color: '$lineColor'
            },
            areaStyle: {
                            silent: false,
                            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                              {
                                offset: 0,
                                color: '$areaColor'
                              },
                              {
                                offset: 1,
                                color: '#ffffff'
                              }
                            ]),
                          },
                          emphasis: {
                              areaStyle: {
                                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                                  {
                                  offset: 0,
                                  color: '$areaColor'
                                  },
                                  {
                                  offset: 1,
                                  color: '#ffffff'
                                  }
                                ]),
                                opacity: 0.6,                                
                              },
                              lineStyle: {
                              color: '$lineColor',
                              width: 1,
                              },                              
                          },
            data: $_eventChartData,           
            markPoint: {
                data: $_eventChartMarkPointData
            },
         
        },],
    }                  
''';

    DLog.d('tag', _eventChartOption);

    _commonChartOption = '''
                  {
                    tooltip: {
                      transitionDuration: 0,
                      confine: true,                      
                      backgroundColor: 'rgba(255, 255, 255, 0.5)',
                      formatter: function (params) {                  
                        let tooltip = ``;
                        if(params[0].axisValue != null && params[0].axisValue !== "" && params[0].data.value != null && params[0].data.value !== ""){                           
                            tooltip += `
                              <div style="text-align:left;">
                              <span style="text-align:left;color:#8C8C8C;font-size:12px;";> \${dateDotFormatter(params[0].axisValue)} </span>
                                 &nbsp;\${numberWithCommas(params[0].data.value)}원
                              </div>                                                
                            `;         
                        }    
                        if(params[0].data != null && params[0].data.value2 != null){
                            <!--Messager.postMessage(params[0].data.value2);-->
                            for(var i = 0; i < params[0].data.value2.length; i++){
                             tooltip += `
                             <div style="text-align:left;"'>
                                \${params[0].data.value2[i]}
                             </div>
                            `;
                            };     
                        }   
                        return tooltip;
                      },
                      position: function (pos, params, dom, rect, size) {                 
                          if(pos[0] < size.viewSize[0] / 2) return [pos[0] + 20, 'top'];
                          else return [pos[0] - 130, 'top'];
                        },
                    },     
                    dataZoom: [
                      {
                       type: 'inside',      
                       disabled: false,  
                       zoomLock: true,                      
                      },
                    ],             
                    grid: {
                      left: '5%',
                      top: '10%',
                      right: '$_commonChartRightMargin',
                      bottom: '18%',                      
                    },
                    xAxis:  {
                        type: 'category',
                        show: true,
                        triggerEvent: true,
                        boundaryGap: false,                
                        data: $_commonChartXAxisData,
                        axisLabel: {
                          formatter: function (value, index) {
                            return dateDotFormatter(value);
                          },
                          color: '#8C8C8C',
                          fontSize: 10,
                        },
                        offset: 25,
                        axisPointer: {
                          show: true,
                          label: {
                            show: false,
                          },                         
                          snap: true,
                          lineStyle:{
                            color:'black',                    
                          },                          
                        },
                      },
                    yAxis: {
                      type: 'value',
                      position: 'right',
                      min: function (value) {
                          return ${_stockHomeEventViewDivProvider?.getIndex != 0 ? 'value.min' : (double.tryParse(_findMinTpCommonItem.tp) ?? 0) > (double.tryParse(_commonChartPreClosePrice) ?? 0) ? '${double.tryParse(_commonChartPreClosePrice) ?? 0}' : 'value.min'} 
                      },                      
                      max: function (value) {
                          return ${_stockHomeEventViewDivProvider?.getIndex == 0 && !_beforeOpening && (double.tryParse(_commonChartPreClosePrice) ?? 0) > (double.tryParse(_findMaxTpCommonItem.tp) ?? 0) ? '${(double.tryParse(_commonChartPreClosePrice) ?? 0)}' : 'null'};  
                      },
                      triggerEvent: true, 
                      show: true,
                      axisLabel: {
                        color: 'black',
                      },                
                      offset: 5,
                    },
                    series: [
                      {
                          type: 'line',
                          symbol: 'none',
                          name: 'chart',
                          triggerEvent: true,
                          triggerLineEvent: true,
                          lineStyle: {
                              color: '$lineColor',
                              width: 1,
                          },                                                    
                          symbol: function(value, params){
                             if (params.dataIndex == 0 || params.dataIndex == ${_stockHomeEventViewDivProvider.getIndex == 0 ? _find1DEventHasTpCount : _listPriceCommonChart.length - 1}) {
                              return 'circle';
                            } 
                            else {
                              return 'none';
                            }
                          },
                          showSymbol: 'true',
                          showAllSymbol: 'true',
                          symbolSize: 6,
                          bolderWhenHover: false,
                          itemStyle: {
                            borderWidth: 0,
                            color: '$lineColor',
                          },
                          areaStyle: {
                            
                            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                              {
                                offset: 0,
                                color: '$areaColor'
                              },
                              {
                                offset: 1,
                                color: '#ffffff'
                              }
                            ]),
                          },
                          emphasis: {
                              areaStyle: {
                                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                                  {
                                  offset: 0,
                                  color: '$areaColor'
                                  },
                                  {
                                  offset: 1,
                                  color: '#ffffff'
                                  }
                                ]),
                                opacity: 0.6,                                
                              },
                              lineStyle: {
                              color: '$lineColor',
                              width: 1,
                              },                              
                          },
                          data: $_commonChartData,
                          markPoint: {
                              data: $_commonChartMarkPointData
                          },
                          markLine: $_commonChartMarkLine
                      },   
                    ],
                  }
                  ''';

    setState(() {});
  }

  _requestTrAll() async {
    // DEFINE 차트
    _fetchPosts(
      TR.SEARCH12,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'selectDiv':
              _listChartDateDivModel[_stockHomeEventViewDivProvider.getIndex]
                  .divCode,
          if (_stockHomeEventViewDivProvider?.getIndex == 2)
            'menuDiv': _listEventChartDivModel[_eventDivSelectedIndex].divCode,
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.e('$trStr $json');

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
    DLog.e(trStr + response.body);
    if (trStr == TR.SEARCH12) {
      final TrSearch12 resData = TrSearch12.fromJson(jsonDecode(response.body));
      _beforeOpening = false;
      _beforeChart = false;
      _fluctuationRate = '0';
      if (resData.retCode == RT.SUCCESS) {
        Search12 search12 = resData.retData!;
        _beforeOpening = search12.beforeOpening == 'Y';
        _beforeChart = search12.beforeChart == 'Y';
        _commonChartPreClosePrice = search12.basePrice;
        _fluctuationRate = search12.search01!.fluctuationRate;

        if (_stockHomeEventViewDivProvider.getIndex == 2) {
          _listPriceEventChart.clear();
          if (search12.listPriceChart.isNotEmpty) {
            _listPriceEventChart.addAll(search12.listPriceChart);
          }
          _initEventChartOption();
        } else {
          _listPriceCommonChart.clear();
          if (search12.listPriceChart.isNotEmpty) {
            _listPriceCommonChart.addAll(search12.listPriceChart);
          }
          _initCommonChartOption();
        }
      } else {
        setState(() {
          _listPriceEventChart.clear();
          _listPriceCommonChart.clear();
        });
      }
    }
  }
}
