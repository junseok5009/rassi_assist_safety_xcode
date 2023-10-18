import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/tr_search/tr_search08.dart';
import 'package:rassi_assist/models/tr_search/tr_search09.dart';
import 'package:speech_balloon/speech_balloon.dart';

import '../../common/common_swiper_pagination.dart';

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
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  final _appGlobal = AppGlobal();
  String _userId = '';
  String _stockCode = '';
  String _stockName = '';

  late SwiperController _swiperController;

  String _eventLineChartData = '[]';
  String _eventChartXAxisData = '[]';
  String _eventChartMarkPointData = '[]';
  final List<ChartData> _listPriceChart = []; // 차트 데이터
  String _issueDate = '';
  Search09 _search09 = defSearch09;
  final List<Event> _listEventsDatas = [];

  // late Timer _timer;

  bool _isShowHandleTip = true;

  @override
  bool get wantKeepAlive => true;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _stockCode = _appGlobal.stkCode;
    _stockName = _appGlobal.stkName;
    _requestTrAll();
  }

  @override
  void initState() {
    super.initState();
    _userId = _appGlobal.userId;
    _swiperController = SwiperController();
    initPage();
  }

  @override
  void dispose() {
    _bYetDispose = false;
    // if (_timer != null) {
    //   _timer.cancel();
    // }
    if (_swiperController != null) {
      _swiperController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        5,
        5,
        5,
        20,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          _setEventLineChart(),
          _setEventLineChartContentView(),
          //const SizedBox(height: 20,),
        ],
      ),
    );
  }

  // 라인차트 - 특정 날짜 발생 이벤트
  Widget _setEventLineChart() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: Echarts(
              captureHorizontalGestures: true,
              //captureVerticalGestures: false,
              captureAllGestures: true,
              reloadAfterInit: true,
              option: '''
                  {
                    tooltip: {
                      triggerOn: 'none',
                      transitionDuration: 0,
                      confine: true,
                      //trigger: 'axis',
                      backgroundColor: 'rgba(255, 255, 255, 0.8)',
                      formatter: function (params) {                  
                        Messager.postMessage(chart.getOption().xAxis[0].axisPointer.value);
                        let tooltip = ``;
                        params.forEach(({ marker, seriesName, value }) => {
                          value = value || [0];
                          tooltip += `
                            <div style="text-align:right";>
                              \${dateDotFormatter(params[0].axisValue)}
                            </div>                     
                            <div style="text-align:right";>
                              \${numberWithCommas(params[0].data.value)}원
                            </div>
                            <div style="text-align:right";>
                              이벤트 \${params[0].data.value1}
                            </div>
                          `;                            
                        });
                        return tooltip;
                      },
                      position: function (pos, params, dom, rect, size) {                 
                          if(pos[0] < size.viewSize[0] / 2) return [pos[0] + 15, '25%'];
                          else return [pos[0] - 100, '25%'];
                        },
                    },
                    dataZoom: [
                      {
                        start: ${_listPriceChart.length > 60 ? '85' : '0'},
                        end: 100,
                        //xAxisIndex: [0, 1],
                        xAxisIndex: 0,
                        zoomLock: true,
                        handleSize: '0%',
                        moveHandleSize: 30,
                        brushSelect: false,
                        top: 'top',
                      },
                      {
                        type: 'inside',
                        realtime: false,
                        start: 50,
                        end: 60,
                        zoomLock: true,
                        xAxisIndex: [0, 1]
                      }
                    ],
                    grid: {
                      left: '2%',
                      top: '12%',
                      right: '15%',
                      bottom: '18%'
                    },
                    xAxis:  {
                        type: 'category',
                        show: true,
                        boundaryGap: false,                
                        data: $_eventChartXAxisData,
                        axisLabel: {
                          formatter: function (value, index) {
                            return dateDotFormatter(value);
                          }
                        },
                        axisPointer: {
                          show: true,
                          label: {
                            show: false,
                          },
                          lineStyle:{
                            //show: false,
                            color:'#FC525B',                    
                          },
                          handle: {
                            show: true,
                            color:'#FC525B',         
                            snap:true,
                            size: 40,
                            margin: 36,
                            icon: 'image://https://files.thinkpool.com/rassi_signal/tap_2.png',
                          },
                        },
                      },
                    yAxis: {
                      type: 'value',
                      position: 'right',
                      min: 'dataMin',
                      triggerEvent: true,
                      scale: true,      
                      show: true,
                      axisLabel: {
                        color: 'black',
                      },                
                    },
                    series: [
                      {
                        //name: '$_stockName',
                        type: 'line',
                        symbol: 'none',
                        triggerEvent: false,
                        lineStyle: {
                          color: '#454A63',
                          width: 1,
                        },
                        silent: true,
                        data: $_eventLineChartData,
                        markPoint: {
                          itemStyle: {
                            color: 'white',
                            borderColor: 'black',
                            borderWidth: '1.4'
                          },
                          label: {
                            fontSize: 10,
                            fontWeight: 'bold'
                          },
                          data: $_eventChartMarkPointData
                        },
                      }
                    ]
                  }
                  ''',
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
                    return x.toString();
                  }
                  var result = x.toString();
                  result =
                    result.substring(2, 4) +'.'
                    + result.substring(4, 6) + '.'
                    + result.substring(6, 8);
                  return result;
                };                 
                chart.on('dataZoom', function (params) {
                    var option = chart.getOption();
                    Messager.postMessage(option.xAxis[0].axisPointer.value);
                });
              ''',
              onMessage: (String message) {
                DLog.w('message : $message');
                if (_isShowHandleTip) {
                  setState(() {
                    _isShowHandleTip = false;
                  });
                }
                if (_issueDate !=
                    _listPriceChart[double.parse(message).toInt()].td) {
                  _issueDate = _listPriceChart[double.parse(message).toInt()].td;
                  _setTimer(message, 500);
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.15 + 20),
            child: Visibility(
              visible: _isShowHandleTip,
              child: const SpeechBalloon(
                nipLocation: NipLocation.right,
                borderColor: RColor.lineGrey2,
                width: 260,
                height: 26,
                child: Center(
                  child: Text(
                    '차트 위 이벤트 지점으로 손가락을 움직여 보세요!',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setEventLineChartContentView() {
    if (_listEventsDatas.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: UIStyle.boxNewBasicGrey10(),
        margin: const EdgeInsets.only(
          top: 10,
          left: 5,
          right: 5,
        ),
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Visibility(
                  visible: _search09.issueDate == TStyle.getTodayString(),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: RColor.new_basic_text_color_grey,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Center(
                          child: Text(
                            '오늘',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  TStyle.getDateSlashFormat3(_search09.issueDate),
                  style: TStyle.commonTitle,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  TStyle.getMoneyPoint(_search09.tradePrice),
                  /*style: TextStyle(
                    color:
                        TStyle.getMinusPlusColor(_search09.fluctuationRate),
                  ),*/
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  TStyle.getPercentString(_search09.fluctuationRate),
                  /*style: TextStyle(
                    color:
                        TStyle.getMinusPlusColor(_search09.fluctuationRate),
                  ),*/
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '발생한 이벤트가 없습니다.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            const Text(
              '차트를 터치해 보세요.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    if (_listEventsDatas.length == 1) {
      var item = _listEventsDatas[0];
      return Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.only(
          top: 10,
          left: 5,
          right: 5,
        ),
        child: Container(
          child: item.newsDiv == 'ISS'
              ? TileSearch09ISS(
                  search09: _search09,
                  event: item,
                )
              : item.newsDiv == 'SND'
                  ? TileSearch09SND(
                      search09: _search09,
                      event: item,
                    )
                  : item.newsDiv == 'SCR'
                      ? TileSearch09SCR(
                          search09: _search09,
                          event: item,
                        )
                      : item.newsDiv == 'SNS'
                          ? TileSearch09SNS(
                              search09: _search09,
                              event: item,
                              stock: Stock(
                                stockName: _appGlobal.stkName,
                                stockCode: _appGlobal.stkCode,
                              ),
                            )
                          : item.newsDiv == 'DSC'
                              ? TileSearch09DSC(
                                  search09: _search09,
                                  event: item,
                                )
                              : const SizedBox(),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 150,
        margin: const EdgeInsets.only(
          top: 10,
          left: 5,
          right: 5,
        ),
        child: Swiper(
          controller: _swiperController,
          scale: 0.9,
          pagination: CommonSwiperPagenation.getNormalSpWithMargin(
            8,
            128,
            Colors.black,
          ),
          autoplay: false,
          itemCount: _listEventsDatas.length,
          itemBuilder: (BuildContext context, int index) {
            var item = _listEventsDatas[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: item.newsDiv == 'ISS'
                  ? TileSearch09ISS(
                      search09: _search09,
                      event: item,
                    )
                  : item.newsDiv == 'SND'
                      ? TileSearch09SND(
                          search09: _search09,
                          event: item,
                        )
                      : item.newsDiv == 'SCR'
                          ? TileSearch09SCR(
                              search09: _search09,
                              event: item,
                            )
                          : item.newsDiv == 'SNS'
                              ? TileSearch09SNS(
                                  search09: _search09,
                                  event: item,
                                  stock: Stock(
                                    stockName: _appGlobal.stkName,
                                    stockCode: _appGlobal.stkCode,
                                  ),
                                )
                              : item.newsDiv == 'DSC'
                                  ? TileSearch09DSC(
                                      search09: _search09,
                                      event: item,
                                    )
                                  : const SizedBox(),
            );
          },
        ),
      );
    }
  }

  _initEventLineChartOption() {
    // DEFINE 라인 / 봉 차트 데이터 파싱 + 마크 포인트 파싱
    _eventLineChartData = '[';
    _eventChartMarkPointData = '[';
    _eventChartXAxisData = '[';
    String eventChartMarkPointYAxisValue = '0'; //마크포인트 찍는 y좌표 = 최고가 위에 찍어야함

    _listPriceChart.asMap().forEach(
      (index, value) {
        //_eventLineChartData += '${double.parse(value.tp)},';
        _eventLineChartData +=
            '{value : ${double.parse(value.tp)}, value1: "${value.ec}건",},';
        eventChartMarkPointYAxisValue = value.tp;
        switch (value.ec) {
          case '0':
            break;
          case '1':
          case '2':
          /* _eventChartMarkPointData += '''
            {
              coord: [$index, $eventChartMarkPointYAxisValue,],
              //name: "${value.td}",
              //value: "${value.ec}",
              symbol: 'circle',
              symbolSize: 4,
              //symbolOffset: [0, -10],
              itemStyle: {
                            //color: 'red',
                            color: '#454A63',
                            //borderColor: 'red',
                            //borderWidth: '1.4',
                        },
            },
            ''';
            break;*/
          case '3':
          case '4':
          case '5':
            _eventChartMarkPointData += '''
            {
              coord: [$index, $eventChartMarkPointYAxisValue,],
              name: "${value.td}",
              value: "${value.ec}",
              label: {
                fontSize: 9,
                color: ${value.ec == '3' || value.ec == '4' || value.ec == '5' ? '\'#FC525B\'' : '\'black\''},        
              },
              itemStyle:{
                //borderWidth: 0.6,
                borderWidth: ${value.ec == '3' || value.ec == '4' || value.ec == '5' ? '1.0' : '0.6'}, 
                borderColor: ${value.ec == '3' || value.ec == '4' || value.ec == '5' ? '\'#FC525B\'' : '\'black\''},
              },
              symbol: 'roundRect',
              symbolSize: 11,
            },
            ''';
            break;
        }

        _eventChartXAxisData += "'${value.td}',";
      },
    );

    _eventLineChartData += ']';
    _eventChartMarkPointData += ']';
    _eventChartXAxisData += ']';

    /*DLog.d(StockHomeHomeTileEventView.TAG,
        '_eventLineChartData : $_eventLineChartData');*/
    //DLog.w('_eventChartMarkPointData : $_eventChartMarkPointData');
    /*DLog.d(StockHomeHomeTileEventView.TAG,
        '_eventChartXAxisData : $_eventChartXAxisData');*/
    setState(() {});
  }

  _setTimer(String msgIssueDate, int millSeconds) {
    // _timer ??= Timer(
    //     Duration(
    //       milliseconds: millSeconds,
    //     ), () {
    //   _timer = null;
    //   if (_issueDate == msgIssueDate) {
    //     _requestTrSearch09();
    //   } else {
    //     _setTimer(_issueDate, 700);
    //   }
    // });
  }

  _requestTrAll() async {
    // DEFINE 차트
    _fetchPosts(
      TR.SEARCH08,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'selectDiv': 'Y1'
        },
      ),
    );
  }

  _requestTrSearch09() {
    // DEFINE 이벤트 뷰들
    _fetchPosts(
      TR.SEARCH09,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'issueDate': _issueDate,
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
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
    if (trStr == TR.SEARCH08) {
      final TrSearch08 resData = TrSearch08.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Search08 search08 = resData.retData;
        _listPriceChart.clear();
        if (search08.listPriceChart.isNotEmpty) {
          _listPriceChart.addAll(search08.listPriceChart);
        } else {
          _listPriceChart.clear();
        }
        _issueDate = search08.search01.tradeDate;
        _requestTrSearch09();
      } else {
        _listPriceChart.clear();
      }
      _initEventLineChartOption();
    } else if (trStr == TR.SEARCH09) {
      final TrSearch09 resData = TrSearch09.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _search09 = resData.retData;
        _listEventsDatas.clear();
        if (_search09.listEvent.isNotEmpty) {
          _listEventsDatas.addAll(_search09.listEvent);
        }
      }
      setState(() {});
    }
  }
}
