import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare01.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare02.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/stock_home/page/stock_compare_page.dart';

/// Made HJS
/// 메인[홈]_홈_이 시간 핫 종목비교
///
class TileHomeHomeStockCompare extends StatefulWidget {
  static const String TAG = "[HomeSliver_TileHomeHomeStockCompare]";

  const TileHomeHomeStockCompare({Key? key}) : super(key: key);

  @override
  State<TileHomeHomeStockCompare> createState() =>
      _TileHomeHomeStockCompareState();
}

class _TileHomeHomeStockCompareState extends State<TileHomeHomeStockCompare>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _userId = '';
  final _appGlobal = AppGlobal();
  String _stockCode = '';

  final List<StockGroup> _listCompareStockGroup = []; // 이 시간 핫 종목비교
  final List<StockCompare02> _listCompareStock02 = []; // 이 시간 핫 종목비교 차트안에 비교 종목들

  final List<String> _listCompareChartTitle = ['매출액', 'PER', '영업이익 증가율', '최근 1년 변동률'];
  final List<String> _listCompareChartDiv = ['SCALE', 'VALUE', 'GROWTH', 'FLUCT'];

  int _compareChartClickIndex = 0;
  String _compareChartDataStr = '';

  int _compareChartXaxisInterval = 0;
  int _compareChartXAxisMax = 0;
  int _compareChartXAxisMin = 0;
  bool _compareChartIsShowOver = false; // 차트에 [이상] 찍기

  int _compareChartYaxisInterval = 0;
  int _compareChartYAxisMax = 0;
  int _compareChartYAxisMin = 0;
  bool _compareChartIsShowOverPerYAxis = false; // PER차트 150이상 있을 경우 [이상] 찍기
  String _compareChartYAxisUnit = '';
  String _compareChartYAxisBasicStr = '';
  String _compareChartYAxisOverStr = '';
  int _swiperCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _userId = _appGlobal.userId;
    _fetchPosts(
        TR.COMPARE01,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _setSubTitle('이 시간 핫 종목비교'),
            Visibility(
              visible: _listCompareStockGroup.isNotEmpty,
              child: InkWell(
                child: const Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Text(
                    '+자세히 보기',
                    style: TStyle.commonPurple14,
                  ),
                ),
                onTap: () {
                  // 종목비교 상세
                  basePageState.callPageRouteData(
                    StockComparePage(),
                    PgData(
                      stockName: _listCompareStockGroup[_swiperCurrentIndex]
                          .listStock[0]
                          .stockName,
                      stockCode: _listCompareStockGroup[_swiperCurrentIndex]
                          .listStock[0]
                          .stockCode,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Visibility(
          visible: _listCompareStockGroup.isEmpty,
          child: Container(
            width: double.infinity,
            height: 150,
            margin:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            decoration: UIStyle.boxRoundLine6(),
            child: const Center(
              child: Text('발생한 종목비교 데이터가 없습니다.'),
            ),
          ),
        ),
        Visibility(
          visible: _listCompareStockGroup.isNotEmpty,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 10),
            width: double.infinity,
            height: 410,
            child: Swiper(
              controller: SwiperController(),
              pagination: _listCompareStockGroup.length < 2
                  ? null
                  : _setPagination2(),
              loop: false,
              autoplay: false,
              onIndexChanged: (int index) {
                _swiperCurrentIndex = index;
                _stockCode =
                    _listCompareStockGroup[index].listStock[0].stockCode;
                _fetchPosts(
                    TR.COMPARE02,
                    jsonEncode(<String, String>{
                      'userId': _userId,
                      'stockCode': _stockCode,
                      'stockGrpCd': _listCompareStockGroup[index].stockGrpCd,
                      'selectDiv':
                          _listCompareChartDiv[_compareChartClickIndex],
                    }));
              },
              itemCount: _listCompareStockGroup.length,
              itemBuilder: (BuildContext context, int index) {
                return _setStockCompareSwipeWidget(index);
              },
            ),
          ),
        ),
      ],
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  SwiperPagination _setPagination2() {
    return const SwiperPagination(
      margin: EdgeInsets.only(top: 380),
      alignment: Alignment.topCenter,
      builder: DotSwiperPaginationBuilder(
        size: 9,
        activeSize: 9,
        space: 4,
        color: RColor.bgGrey,
        activeColor: Colors.deepPurpleAccent,
      ),
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(TileHomeHomeStockCompare.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      _showDialogNetErr();
    } on SocketException catch (_) {
      _showDialogNetErr();
    }
  }

  //비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각 / 전체 싱글스레트 기반도 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    //이 시간 핫 종목비교, compare01 그룹 + 종목 가져오기
    if (trStr == TR.COMPARE01) {
      final TrCompare01 resData =
          TrCompare01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listCompareStockGroup.clear();
        _listCompareStockGroup.addAll(resData.retData.listData);

        if (resData.retData.listData.length > 0) {
          _stockCode = _listCompareStockGroup[0].listStock[0].stockCode;
          _fetchPosts(
              TR.COMPARE02,
              jsonEncode(<String, String>{
                'userId': _userId,
                'stockCode': _stockCode,
                'stockGrpCd': _listCompareStockGroup[0].stockGrpCd,
                'selectDiv': 'SCALE',
              }));
        }
      } else {}
    }
    //이 시간 핫 종목비교, compare02
    else if (trStr == TR.COMPARE02) {
      final TrCompare02 resData = TrCompare02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listCompareStock02.clear();
        _listCompareStock02.addAll(resData.retData.listStock);
        setState(() {});
      } else {
        _listCompareStock02.clear();
        setState(() {});
      }
    }
  }

  //이 시간 핫 종목비교 스와이프 위젯
  Widget _setStockCompareSwipeWidget(
    int index,
  ) {
    _setStockCompareChartData(index);

    int gridBottomPadding = 0;
    int gridLeftPadding = 8;
    if (!_compareChartIsShowOver) {
      gridBottomPadding = 20;
    }
    if (_compareChartIsShowOverPerYAxis) {
      gridLeftPadding = -20;
    }
    return Container(
      decoration: UIStyle.boxRoundLine6(),
      // color: Colors.lightBlueAccent,
      //margin: EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 32.6),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: UIStyle.boxRoundFullColor6c(RColor.bgWeakGrey),
            child: InkWell(
              onTap: () {
                // 종목비교 상세
                basePageState.callPageRouteData(
                  StockComparePage(),
                  PgData(
                    stockName: _listCompareStockGroup[_swiperCurrentIndex]
                        .listStock[0]
                        .stockName,
                    stockCode: _listCompareStockGroup[_swiperCurrentIndex]
                        .listStock[0]
                        .stockCode,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          TStyle.getLimitString(
                              _listCompareStockGroup[index].stockGrpNm, 8),
                          style: TStyle.title19T,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        _appGlobal.stockGrpCd =
                            _listCompareStockGroup[index].stockGrpCd;
                        _appGlobal.stockGrpNm =
                            _listCompareStockGroup[index].stockGrpNm;
                        basePageState.goStockHomePage(
                          _listCompareStockGroup[index].listStock[0].stockCode,
                          _listCompareStockGroup[index].listStock[0].stockName,
                          Const.STK_INDEX_HOME,
                        );
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            const Text(
                              '상승률 1위',
                              style: TStyle.content14,
                            ),
                            Row(
                              children: [
                                Text(
                                  TStyle.getLimitString(_listCompareStockGroup[index].listStock[0].stockName, 8),
                                  style: TStyle.commonTitle15,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    TStyle.getPercentString(_listCompareStockGroup[index].listStock[0].fluctuationRate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: TStyle.getMinusPlusColor(
                                          _listCompareStockGroup[index]
                                              .listStock[0]
                                              .fluctuationRate),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Text(
              '${_listCompareChartTitle[_compareChartClickIndex]} 비교',
              style: TStyle.commonTitle15,
            ),
          ),
          const Text(
            '차트를 클릭해 보세요.',
            style: TStyle.contentGrey12,
          ),
          Container(
            decoration: BoxDecoration(
              color: RColor.bgWeakGrey,
              border: Border.all(
                color: RColor.bgWeakGrey,
                width: 0.8,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            height: 222.8,
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(top: 10),
            child: Stack(
              children: [
                Echarts(
                  captureHorizontalGestures: false,
                  captureVerticalGestures: false,
                  captureAllGestures: false,
                  reloadAfterInit: true,
                  extraScript: ''' ''',
                  option: '''                  {
                    backgroundColor: '#F3F4F8',
                    grid: {
                      left: $gridLeftPadding,
                      top: 24,
                      right: 24,
                      containLabel: true,
                      bottom: $gridBottomPadding,
                    },
                    xAxis: [
                      {
                        interval: $_compareChartXaxisInterval,
                        min: $_compareChartXAxisMin,
                        max: $_compareChartXAxisMax,
                        splitNumber: 5,
                        axisLabel: {
                          show: true,
                          formatter: function (value, index) {
                            if(value == $_compareChartXAxisMax && $_compareChartIsShowOver){
                                return '';
                            }else{
                              return value.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');
                            }
                          }
                        },
                      },
                      {
                        type: 'category',
                        inverse: true,
                        position: 'bottom',
                        axisLabel: {
                          show: $_compareChartIsShowOver,
                        },
                        axisLine: {
                          show: false,
                        },
                        axisTick: {
                          show: false,
                        },
                        data: ['1조이상','','','','','',''],
                      },
                    ],
                    yAxis: [
                      $_compareChartYAxisBasicStr$_compareChartYAxisOverStr                      {
                        axisLine: {
                          show: false,
                        },
                        name: '시가총액(억)',
                        nameLocation: 'start',
                        nameGap: 26,
                        nameTextStyle: {
                          align:'center',
                          fontSize: 11,
                           padding:[0,20,0,0],
                        },
                      },
                    ],
                    series: [$_compareChartDataStr],
                  }
                    ''',
                ),
                InkWell(
                  onTap: () {
                    if (_compareChartClickIndex == 3) {
                      _compareChartClickIndex = 0;
                    } else {
                      _compareChartClickIndex++;
                    }
                    _stockCode =
                        _listCompareStockGroup[index].listStock[0].stockCode;
                    _fetchPosts(
                        TR.COMPARE02,
                        jsonEncode(<String, String>{
                          'userId': _userId,
                          'stockCode': _stockCode,
                          'stockGrpCd':
                              _listCompareStockGroup[index].stockGrpCd,
                          'selectDiv':
                              _listCompareChartDiv[_compareChartClickIndex],
                        }));
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setStockCompareChartData(int index) {
    String tmpData = '';
    String markLine = '';
    int xAxisIndex = 0;
    int vOverChartIndex = 0; // 차트에 표기 못하고 [이상 으로 표기해야하는 시작 index]
    String chartColor = '';
    _compareChartIsShowOver = false;
    _compareChartIsShowOverPerYAxis = false;

    if (_listCompareStock02.length > 0) {
      // 시총 낮은 > 높은 순으로 정렬
      _listCompareStock02.sort((a, b) =>
          double.parse(a.marketValue).compareTo(double.parse(b.marketValue)));

      // DEFINE 최소값
      String smallMarketValue = _listCompareStock02[0].marketValue;
      if (smallMarketValue.isEmpty) {
        _compareChartXAxisMin = 0;
      } else {
        _compareChartXAxisMin = int.parse(smallMarketValue) -
            (int.parse(smallMarketValue) * 0.15).toInt();
      }

      // DEFINE 최대값 [1]
      String bigMarketValue = '';

      // 3개 이상
      if (_listCompareStock02.length > 2) {
        if (smallMarketValue.isNotEmpty &&
            int.parse(smallMarketValue) > 10000) {
          bigMarketValue =
              _listCompareStock02[_listCompareStock02.length - 1].marketValue;
        } else {
          for (int k = 1; k < _listCompareStock02.length; k++) {
            vOverChartIndex = k;
            if (_listCompareStock02[k].marketValue.isNotEmpty &&
                int.parse(_listCompareStock02[k].marketValue) > 10000) {
              _compareChartIsShowOver = true;
              bigMarketValue = _listCompareStock02[k - 1].marketValue;
              if (k + 3 <= _listCompareStock02.length) {
                _compareChartIsShowOver = false;
                bigMarketValue =
                    _listCompareStock02[_listCompareStock02.length - 1]
                        .marketValue;
              }
              break;
            } else if (k == _listCompareStock02.length - 1 &&
                int.parse(_listCompareStock02[k].marketValue) <= 10000) {
              vOverChartIndex = k + 1;
              bigMarketValue = _listCompareStock02[k].marketValue;
            }
          }
        }
      }
      // 2개 알때
      else if (_listCompareStock02.length == 2) {
        bigMarketValue = _listCompareStock02[1].marketValue;
      }
      // 1개 일때
      else {
        _compareChartXAxisMax = _compareChartXAxisMax;
      }

      // DEFINE 최대값 [2]
      _compareChartXAxisMax = int.parse(bigMarketValue) +
          (int.parse(bigMarketValue) * 0.15).toInt();

      int numbering = 0;
      /*
        최소값 최대값 예쁘게 찍기 위한 값 변환과정
        1자리수 7 > 7 그대로
        2자리수 14 > 14 그대로
        3자리수 138 > 130 뒷 1자리
        4자리수 1387 > 1300 뒷 2자리
        5자리수 13620 > 13000 뒷 2자리
      */
      for (int k = 0; k < 2; k++) {
        int chartXAxisFinalValue = 0;

        if (k == 0) {
          if (_compareChartXAxisMin == 0) {
            numbering = 0;
          } else {
            numbering = log(_compareChartXAxisMin) ~/ ln10 + 1;
          }
          chartXAxisFinalValue = _compareChartXAxisMin;
        } else {
          numbering = log(_compareChartXAxisMax) ~/ ln10 + 1;
          chartXAxisFinalValue = _compareChartXAxisMax;
        }

        if (numbering == 3) {
          chartXAxisFinalValue = chartXAxisFinalValue -
              (chartXAxisFinalValue % 100 % 10); // 일의자리 0으로 만들기
        } else if (numbering == 4) {
          chartXAxisFinalValue = chartXAxisFinalValue -
              (chartXAxisFinalValue % 1000 % 100); // 일의자리 0으로 만들기
        } else if (numbering == 5) {
          chartXAxisFinalValue = chartXAxisFinalValue -
              (chartXAxisFinalValue % 10000 % 1000 % 100); // 일의자리 0으로 만들기
        } else if (numbering == 6) {
          chartXAxisFinalValue = chartXAxisFinalValue -
              (chartXAxisFinalValue %
                  100000 %
                  10000 %
                  1000); // 일, 십, 백 의자리 0으로 만들기
        } else if (numbering == 7) {
          chartXAxisFinalValue = chartXAxisFinalValue -
              (chartXAxisFinalValue %
                  1000000 %
                  100000 %
                  10000 %
                  1000); // 일, 십, 백 의자리 0으로 만들기
        }

        if (k == 0) {
          _compareChartXAxisMin = chartXAxisFinalValue;
        } else {
          _compareChartXAxisMax = chartXAxisFinalValue;
        }
      }

      // 인터벌은 차트를 무조건 5칸으로 딱 나눠떨어지게 만들어야하기때문
      _compareChartXaxisInterval =
          (_compareChartXAxisMax - _compareChartXAxisMin) ~/ 5;

      // DEFINE Y축 PER 이상 추가
      if (_compareChartClickIndex == 1) {
        List listStockCompare02YAxisSort = [];
        listStockCompare02YAxisSort.addAll(_listCompareStock02);

        // 1. Y축 정렬
        // per 낮은 > 높은 순으로 정렬
        listStockCompare02YAxisSort.sort((a, b) {
          if (a.per.isEmpty) {
            return 1;
          } else if (b.per.isEmpty) {
            return 0;
          } else {
            return double.parse(a.per).compareTo(double.parse(b.per));
          }
        });

        // DEFINE 최대값 [1]
        String _bigPerValue = '';

        // DEFINE 종목 개수 2개 초과일때
        if (listStockCompare02YAxisSort.length > 1) {
          if (listStockCompare02YAxisSort[0].per.isNotEmpty &&
              double.parse(listStockCompare02YAxisSort[0].per) > 150) {
            _compareChartIsShowOverPerYAxis = true;
            _bigPerValue = '140';
          } else {
            for (int k = 1; k < listStockCompare02YAxisSort.length; k++) {
              if (listStockCompare02YAxisSort[k].per.isNotEmpty &&
                  double.parse(listStockCompare02YAxisSort[k].per) > 150) {
                _compareChartIsShowOverPerYAxis = true;
                _bigPerValue = listStockCompare02YAxisSort[k - 1].per;
                break;
              }
            }
          }
        }

        if (_compareChartIsShowOverPerYAxis) {
          // DEFINE 최대값 [2]
          _compareChartYAxisMax = (double.parse(_bigPerValue) + 20).toInt();
          while (_compareChartYAxisMax % 5 != 0) {
            _compareChartYAxisMax++;
          }

          _compareChartYaxisInterval = (_compareChartYAxisMax) ~/ 5;
        }
      }

      for (int k = 0; k < _listCompareStock02.length; k++) {
        var item = _listCompareStock02[k];
        int yAxisIndex = 0;
        String yAxisValue = '';
        String xAxisChartValue = '0'; // 차트에 찍는 x값
        String dataLabelStr = '\\n';
        String dataLabelPosition = 'right';
        String customYAxisValue = '';

        // DEFINE 기업규모 > 매출액 비교
        if (_compareChartClickIndex == 0) {
          yAxisValue = item.sales;
          _compareChartYAxisUnit = '억';
        }
        // DEFINE 기업가치 > PER 비교
        else if (_compareChartClickIndex == 1) {
          yAxisValue = item.per;
          _compareChartYAxisUnit = '배';
        }
        // DEFINE 성장성 > 영업이익 증가율 비교
        else if (_compareChartClickIndex == 2) {
          yAxisValue = item.profitRateQuart;
          _compareChartYAxisUnit = '%';
        }
        // DEFINE 변동성 > 최근 1년 변동률 비교
        else if (_compareChartClickIndex == 3) {
          yAxisValue = item.fluctYear1;
          _compareChartYAxisUnit = '%';
        }

        if (yAxisValue.isEmpty) yAxisValue = '0';
        customYAxisValue = yAxisValue;
        // DEFINE DATA LABEL
        // [기업규모]매출액, 영업이익 > 소수점 자르기 // 나머지는 소수점 두자리까지 그대로 표기
        if (_compareChartClickIndex == 0) {
          if (customYAxisValue.contains('.')) {
            customYAxisValue = customYAxisValue.split('.')[0];
          }
          dataLabelStr += TStyle.getMoneyPoint(customYAxisValue);
        } else {
          dataLabelStr += TStyle.getMoneyPoint2(customYAxisValue);
        }

        if (k < vOverChartIndex || !_compareChartIsShowOver) {
          xAxisChartValue = item.marketValue;
          xAxisIndex = 0;
          markLine = '';
        } else {
          xAxisChartValue = '0';
          xAxisIndex = 1;
          dataLabelPosition = 'left';
          markLine = '''
        label: {
          show: false,
        },
        lineStyle: {
          color: 'grey',
        },
        symbol: 'none',
        data: [{name: '',xAxis: 0,},],
        ''';
        }

        if (_stockCode == item.stockCode) {
          chartColor = '#7774F7';
        } else {
          chartColor = 'black';
        }

        if (_compareChartClickIndex == 1 &&
            _compareChartIsShowOverPerYAxis &&
            item.per.isNotEmpty &&
            (double.parse(item.per) > 150)) {
          yAxisIndex = 1;
          yAxisValue = '0';

          tmpData += '''
        {
          xAxisIndex: $xAxisIndex,
          yAxisIndex: $yAxisIndex,
          markLine: {        
            label: {
              show: false,
            },
            lineStyle: {
              color: 'grey',
            },
            symbol: 'none',
            data: [{name: '',yAxis: 0,},],
          },
          label: {
            textStyle:{
              color: '$chartColor',
              fontWeight: 'bold',
            },
            fontSize: 12,
            show: true,
            position: '$dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$xAxisChartValue, 0, '${item.stockName}\\n'],],
          type: 'scatter',
          itemStyle: {
            color: '$chartColor',
          },
        },
        ''';
        } else {
          tmpData += '''
        {
          xAxisIndex: $xAxisIndex,
          markLine: {$markLine},
          label: {
            textStyle:{
               color: '$chartColor',
              fontWeight: 'bold',
            },
            fontSize: 12,
            show: true,
            position: '$dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$xAxisChartValue, $yAxisValue, '${item.stockName}\\n'],],
          type: 'scatter',
          itemStyle: {
             color: '$chartColor',
          },
        },
        ''';
        }

        // 차트 라벨 데이터 때문에 한번더..
        tmpData += '''
        {
          xAxisIndex: $xAxisIndex,
          yAxisIndex: $yAxisIndex,
          label: {
            textStyle:{
               color: '$chartColor',
            },
            fontSize: 8,
            show: true,
            position: '$dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$xAxisChartValue, $yAxisValue, '$dataLabelStr$_compareChartYAxisUnit'],],
          type: 'scatter',
          itemStyle: {
               color: '$chartColor',
          },
        },
        ''';
      }
      _compareChartDataStr = tmpData;
      _setStockCompareChartYAxisStr();
    }
  }

  void _setStockCompareChartYAxisStr() {
    if (_compareChartIsShowOverPerYAxis) {
      _compareChartYAxisBasicStr = '';
      _compareChartYAxisOverStr = '''
       {
          interval: $_compareChartYaxisInterval,
          min: $_compareChartYAxisMin,
          max: $_compareChartYAxisMax,
          splitNumber: 5,
          axisLabel: {
            show: true,
            formatter: function (value, index) {
              if(value == $_compareChartYAxisMax && $_compareChartIsShowOverPerYAxis){
                return '';
              }else{
                return value;
              }
            }   
          }
        },
        {
          type: 'category',
          inverse: true,
          position: 'left',
          axisLabel: {
            show: true,
          },
          axisLine: {
            show: false,
          },
          axisTick: {
            show: false,
          },
          data: ['150이상','','','','','',''],
          name: '${_listCompareChartTitle[_compareChartClickIndex]}($_compareChartYAxisUnit)',
          nameLocation: 'start',
          nameGap: 0,
          nameTextStyle: {
            align:'left',
            fontSize: 11,
          },
        },
      ''';
    } else {
      _compareChartYAxisBasicStr = '''
      {
        type: 'value',
        name: '${_listCompareChartTitle[_compareChartClickIndex]}($_compareChartYAxisUnit)',
        nameLocation: 'end',
        nameGap: 10,
        nameTextStyle: {
          align:'center',
          fontSize: 11,
          padding:[0,-30,0,0],
        },
      },
      ''';
      _compareChartYAxisOverStr = '';
    }
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  _setSubTitle('알림'),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
