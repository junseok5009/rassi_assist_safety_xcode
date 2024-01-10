import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/sticky_header/custom_table_sticky_header/custom_table_sticky_headers.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare01.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare02.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/stock_home/stock_compare_chart_page/stock_compare_chart2_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_compare_chart_page/stock_compare_chart4_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_compare_chart_page/stock_compare_chart5_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_compare_chart_page/stock_compare_chart7_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_compare_chart_page/stock_compare_chart8_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.01.18 - JS
/// 종목비교 상세페이지
class StockComparePage extends StatefulWidget {
  static const String TAG = "[StockComparePage]";
  static const String TAG_NAME = '종목비교';
  static final GlobalKey<StockComparePageState> globalKey = GlobalKey();

  StockComparePage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => StockComparePageState();
}

class StockComparePageState extends State<StockComparePage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences _prefs;
  bool _isLoading = true; // 현재 API 불러와서 로딩중

  String _userId = "";
  bool haveData = false; // compare02 전문 데이터가 있으면 true
  final ScrollController _scrollController = ScrollController();

  String _stkName = "";
  String _stkCode = "";
  String _stockGrpNm = "";
  String _stockGrpCd = "";
  String _stockGrpFluctRate = '';

  // DEFINE < SCALE : 기업규모 / VALUE : 기업가치 / GROWTH : 성장성 / FLUCT : 변동성 >
  String selectDiv = "SCALE";

  // DEFINE < 0 : 기업규모 / 1 : 기업가치 / 2: 성장성 / 3 : 변동성 >
  bool _tab0 = true;
  bool _tab1 = false;
  bool _tab2 = false;
  bool _tab3 = false;
  List<StockGroup> alStockGroup = [];
  List<StockCompare02> alStockCompare02 = [];
  final List<YearQuarterClass> _listYQClass = []; // 년도/쿼터 반영 종목 부분 리스트

  // List<StockCompare02> _listTableStockCompare02 = []; // 테이블 들어가는 항목들은 탭에 따라 높은순 정렬해야해서..
  String _year = '';
  String _quarter = '';
  String _chart1DataStr = '';

  var alTipTitles = ["TIP 기업규모", "TIP 기업가치", "TIP 성장성", "TIP 변동성"];
  var alTipContents = [
    '''
시가총액은 주가에 상장주식수를 곱한 것으로, 기업의 규모를 판단해 볼 수 있는 대표적인 지표 입니다.
시가총액이 클수록 우량하고 가치가 높은 기업이라고 볼 수 있습니다.
매출액은 기업의 총 수익이지만 매출액이 높다고 사업이 잘 되었다고 수는 없습니다.
영업이익은 매출액에서 원가 및 판매비, 인건비 등을 제외한 금액으로 진짜 수익으로 판단해 볼 수 있습니다.
(단위 : 억원)
''',
    '''
PER(주가수익비율) 은 주가가 그 회사 1주당 수익의 몇배가 되는가를 나타내는 지표로 주가를 1주당 순이익(EPS)으로 나눈 것 입니다.
동종업계와 비교하여 저평가인지 고평가인지를 가늠 해 볼  수 있으며, 성장주의 경우 높은 PER이 나올 수 있습니다.
PBR(주가순자산비율) 은 현재 주가 1주당 순자산의 몇 배로 거래되고 있는지를 판단하는 지표 입니다.
PBR은 개별 종목의 높고 낮음을 보기보다 동종업계의 평균과 비교하여 판단하는 것이 좋습니다.
배당수익률은 1주당 배당금의 비율 입니다. 
배당을 많이 주는 기업이 아닌, 지속적으로 배당을 상승시킨 ‘배당성장주’ 를 찾아보면 좋습니다. 
(단위 : 배, %)
''',
    '''매출액 증가율과 영업이익 증가율을 통해 기업의 성장성을 판단 할 수 있습니다.
매출액 증가율과 함께 영업이익률과 ROE가 같이 높다면 좋은 기업으로 판단해 볼 수 있습니다.
(단위:%)
''',
    '''변동률이 높은 종목은 투자에 주의해야 합니다. 크게 수익을 보거나 큰 손실을 볼 수 있습니다.
현재 주가가 과거 대비 어떤 상태인지 파악하여 매매에 참고 하면 좋습니다.
(단위 : %)
'''
  ];

  List<StockGroup> alStockHotGroup = []; // 핫한 종목군 데이터
  String strStockHotGroupInfo = '''
※ DART 공시내용을 실시간으로 수집/분석해서 제공 합니다. 
수집/분석 과정에서 일부 데이터 오류나 누락이 발생할 수 있습니다.
※ 조회일 또는 비교기준일 등으로 타 증권사이트와 데이터 차이가 있을 수 있습니다. 
※ 일부 종목의 특별한 사유로 인해 실적 반영일이 다를 수 있습니다.
  ''';

  int chart1YAxisTitleIndex = 0;
  List<String> titleColumn0 = ['시가총액', '매출액', '영업이익']; // 기업규모
  List<String> titleColumn1 = ['PER', 'PBR', '배당수익률']; // 기업가치
  List<String> unitColumn1 = ['배', '배', '%']; // 기업가치 단위
  List<String> titleColumn2 = ['매출액 증가율', '영업이익 증가율']; // 성장성
  List<String> titleColumn3 = ['최근1년 등락률', '52주최고가대비 변동률', '52주최저가대비 변동률'];
  List<String> titleTableColumn3 = [
    '기간별\n등락률',
    '52주최고가\n대비변동률',
    '52주최저가\n대비변동률'
  ]; // 테이블 0행 [변동성]
  int _compareChartXaxisInterval = 0;
  int _compareChartXAxisMax = 0;
  int _compareChartXAxisMin = 0;
  bool _compareChartIsShowOver = true; // 차트에 [이상] 찍기
  int _compareChartYaxisInterval = 0;
  int _compareChartYAxisMax = 0;
  int _compareChartYAxisMin = 0;
  bool _compareChartIsShowOverPerYAxis = false; // PER차트 150이상 있을 경우 [이상] 찍기
  String _compareChartYAxisUnit = '';
  String _compareChartYAxisTitle = '';
  String _compareChartYAxisBasicStr = '';
  String _compareChartYAxisOverStr = '';

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockComparePage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            PgData pgData = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                pgData.stockCode != null &&
                pgData.stockCode.isNotEmpty) {
              _stkName = pgData.stockName;
              _stkCode = pgData.stockCode;
              requestTrAll();
              Provider.of<StockInfoProvider>(context, listen: false)
                  .postRequest(_stkCode);
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

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  requestTrAll() async {
    String jsonCOMPARE01 = jsonEncode(<String, String>{'userId': _userId});
    String jsonCOMPARE02 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': _stkCode,
        '_stockGrpCd': _stockGrpCd,
        'selectDiv': selectDiv,
      },
    );

    _isLoading = true;

    await Future.wait(
      [
        // DEFINE 그룹 정보(기어규모, 가치 ...)
        _fetchPosts(TR.COMPARE02, jsonCOMPARE02),

        // DEFINE 핫그룹
        _fetchPosts(TR.COMPARE01, jsonCOMPARE01),
      ],
    );
    setState(() {
      _isLoading = false;
    });
  }

  _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);

    // DEFINE TR.COMPARE01 핫 그룹 리스트뷰 데이터
    if (trStr == TR.COMPARE01) {
      final TrCompare01 resData =
          TrCompare01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        alStockHotGroup.clear();
        alStockHotGroup.addAll(resData.retData.listData);
      }
    }
    // DEFINE TR.COMPARE02 테이블 표 + 해당 종목이 가진 모든 그룹
    else if (trStr == TR.COMPARE02) {
      final TrCompare02 resData =
          TrCompare02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (_stockGrpCd == "" && resData.retData.listStockGroup.isNotEmpty) {
          StockGroup stockGroup = resData.retData.listStockGroup[0];
          _stockGrpCd = stockGroup.stockGrpCd;
          _stockGrpNm = stockGroup.stockGrpNm;
          _stockGrpFluctRate = stockGroup.groupfluctRate;
        }

        alStockGroup.clear();
        alStockGroup.addAll(resData.retData.listStockGroup);

        alStockCompare02.clear();
        alStockCompare02.addAll(resData.retData.listStock);

        //_baseDate = resData.retData.baseDate;
        _year = resData.retData.year;
        _quarter = resData.retData.quarter;

        setState(() {
          haveData = true;
        });
      } else {
        setState(() {
          haveData = false;
        });
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _fetchPosts(String trStr, String json) async {
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
      DLog.d(StockComparePage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(StockComparePage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '종목비교',
        elevation: 1,
      ),
      body: _isLoading
          ? const SizedBox()
          : CustomScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(
                        height: 15.0,
                      ),
                      Visibility(
                        visible: haveData,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 15, left: 10, right: 10),
                              child: Text(
                                '한 눈에 보는 종목비교',
                                style: TStyle.commonTitle,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              decoration: const BoxDecoration(
                                color: RColor.bgWeakGrey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _stockGrpNm,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        TStyle.getPercentString(
                                            _stockGrpFluctRate
                                        ),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: TStyle.getMinusPlusColor(
                                              _stockGrpFluctRate
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: _stockGrpCd != "" &&
                                        alStockCompare02.length > 1,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.fromLTRB(
                                            15,
                                            15,
                                            15,
                                            0,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            5,
                                            10,
                                            5,
                                            10,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                6,
                                              ),
                                            ),
                                          ),
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              Text(
                                                _stkName,
                                                style: TStyle.commonPurple14,
                                              ),
                                              const Text(' 외 '),
                                              Text(
                                                '${alStockCompare02.length}종목',
                                                style: TStyle.subTitle,
                                              ),
                                              const Text('이 '),
                                              const Text('속해 있는 종목 그룹 입니다'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _stockGrpCd != "" &&
                                        alStockGroup.length > 1,
                                    child: InkWell(
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 1, 12, 1),
                                        decoration: const BoxDecoration(
                                          color: RColor.deepBlue,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: const Text(
                                          '다른 비교 그룹 보기',
                                          style: TStyle.btnTextWht14,
                                        ),
                                      ),
                                      onTap: () {
                                        _showScrollableSheetGroupCompare();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // NOTE 2. 차트1
                      _makeChartTopInfo(),
                      const SizedBox(
                        height: 6,
                      ),
                      _makeChart(),

                      // NOTE 차트, 이렇게 보세요
                      _makeChartWatchInfoView(),

                      // NOTE 3. 버튼 4개
                      _makeTabButton(),

                      // NOTE 4. 탭에 의한 아래 뷰들
                      _makeTableHighInfo(),
                      _makeTable(),
                      _makeTableQuarterInfo(), // 기업규모, 성장성에만 있는 쿼터 반영 정보
                      _makeTableLowInfo(), // NOTE TIP 설명

                      // NOTE ㅡㅡㅡㅡㅡ 데이터가 없을때 ㅡㅡㅡㅡㅡ
                      _makeNoDataView(),

                      // NOTE ㅡㅡㅡㅡㅡ 데이터 상관없이 핫그릅뷰 ㅡㅡㅡㅡㅡ
                      _makeHotGroupView(),

                      // 핫그룹 설명
                      Visibility(
                        visible: haveData,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            strStockHotGroupInfo,
                            style: TStyle.contentGrey14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // DEFINE ONCLICK
  setOnClickGroupView(StockGroup vStockGroup) {
    _stockGrpCd = vStockGroup.stockGrpCd;
    _stockGrpNm = vStockGroup.stockGrpNm;
    _stockGrpFluctRate = vStockGroup.groupfluctRate;
    if (vStockGroup.listStock != null && vStockGroup.listStock.isNotEmpty) {
      _stkCode = vStockGroup.listStock[0].stockCode;
      _stkName = vStockGroup.listStock[0].stockName;
      _scrollController.jumpTo(0);
      requestTrAll();
    }
  }

  setOnClickHotGroupView(StockGroup vStockGroup) {
    _stkCode = vStockGroup.listStock[0].stockCode;
    _stkName = vStockGroup.listStock[0].stockName;
    _stockGrpCd = vStockGroup.stockGrpCd;
    _stockGrpNm = vStockGroup.stockGrpNm;
    _stockGrpFluctRate = vStockGroup.groupfluctRate;
    _scrollController.jumpTo(0);
    requestTrAll();
    /*Provider.of<StockInfoProvider>(context, listen: false)
        .updateData(_stkCode);*/
    //_appGlobal.stkCode = _stkCode;
    //_appGlobal.stkName = _stkName;
    //_appGlobal.tabIndex = Const.STK_INDEX_COMPARE;

    //StockHomeTab.globalKey.currentState.funcStockTabUpdate();
  }

  setOnClickTabsView2TitleClick(int i, int j) {
    if (!_tab0 && j == 0) {
      if (_tab1) {
        // per > 차트2 / pbr > 차트3 / 배당수익률 > 차트4
        if (i == 0) {
          //_showDialogChart2(2);
          _showChart2(2);
        } else if (i == 1) {
          //_showDialogChart2(3);
          _showChart2(3);
        } else if (i == 2) {
          _showChart4();
        }
      } else if (_tab2) {
        if (i == 0) {
          _showChart5(5);
        } else if (i == 1) {
          _showChart5(6);
        }
      } else if (_tab3) {
        if (i == 0) {
          _showChart7();
        } else if (i == 1) {
          _showChart8(8);
        } else if (i == 2) {
          _showChart8(9);
        }
      }
    }
  }

  setOnClickTabButtonView() {
    chart1YAxisTitleIndex = 0;

    if (_tab0) {
      selectDiv = "SCALE";
    } else if (_tab1) {
      selectDiv = "VALUE";
    } else if (_tab2) {
      selectDiv = "GROWTH";
    } else if (_tab3) {
      selectDiv = "FLUCT";
    }

    _fetchPosts(
        TR.COMPARE02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockCode': _stkCode,
          '_stockGrpCd': _stockGrpCd,
          'selectDiv': selectDiv,
        }));
  }

  // 항목선택 _ 리스트뷰 _ 차일드 클릭
  setOnClickChart1DivListViewChild(int vTabIndex) {
    _tab0 = false;
    _tab1 = false;
    _tab2 = false;
    _tab3 = false;
    switch (vTabIndex) {
      // 기업규모
      case 0:
        _tab0 = true;
        selectDiv = "SCALE";
        break;
      // 기업가치
      case 1:
        _tab1 = true;
        selectDiv = "VALUE";
        break;
      // 성장성
      case 2:
        _tab2 = true;
        selectDiv = "GROWTH";
        break;
      // 변동성
      case 3:
        _tab3 = true;
        selectDiv = "FLUCT";
        break;
    }

    _fetchPosts(
        TR.COMPARE02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockCode': _stkCode,
          '_stockGrpCd': _stockGrpCd,
          'selectDiv': selectDiv,
        }));
  }

  _setOnClickTableRow(int index) {
    if (index != 0 &&
        (index - 1 <= alStockCompare02.length) &&
        alStockCompare02[index - 1].stockCode != _stkCode) {
      setState(() {
        _stkCode = alStockCompare02[index - 1].stockCode;
        _stkName = alStockCompare02[index - 1].stockName;
        _scrollController.jumpTo(0);
      });
      //requestTrAll();
      //_appGlobal.stkCode = _stkCode;
      //_appGlobal.stkName = _stkName;
      //_appGlobal.tabIndex = Const.STK_INDEX_COMPARE;
      //StockHomeTab.globalKey.currentState.funcStockTabUpdate();
    }
  }

  // DEFINE ShowChartView
  _showChart2(int chartDiv) {
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
                StockCompareChart2Page(
                  alStockCompare02,
                  chartDiv: chartDiv,
                  stockCode: _stkCode,
                ),
              ],
            ),
          );
        });

    // full width 레이어
    /*showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) =>  Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          //height: MediaQuery.of(context).size.height * 0.95,
          child: StockCompareChart2Page(
              chartDiv, _stkCode, alStockCompare02),
        ),
    );*/
  }

  _showChart4() {
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
                StockCompareChart4Page(
                  groupCode: _stockGrpCd,
                  stockCode: _stkCode,
                ),
              ],
            ),
          );
        });

    // full width 레이어
    /*showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.95,
        child: StockCompareChart4Page(_stockGrpCd, _stkCode),
      ),
    );*/
  }

  _showChart5(int chartDiv) {
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
                StockCompareChart5Page(
                    chartDiv: chartDiv,
                    groupCode: _stockGrpCd,
                    stockCode: _stkCode,
                    listYQClass: _listYQClass),
              ],
            ),
          );
        });

    // full width 레이어
    /*showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.95,
        child: StockCompareChart5Page(chartDiv, _stockGrpCd, _stkCode, _listYQClass),
      ),
    );*/
  }

  _showChart7() {
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
                StockCompareChart7Page(groupCode: _stockGrpCd, stockCode: _stkCode,),
              ],
            ),
          );
        });

    // full width 레이어
    /*showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.95,
        child: StockCompareChart7Page(_stockGrpCd, _stkCode),
      ),
    );*/
  }

  _showChart8(int chartDiv) {
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
                StockCompareChart8Page(chartDiv: chartDiv, groupCode: _stockGrpCd, stockCode: _stkCode,),
              ],
            ),
          );
        });

    // full width 레이어
    /*showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.95,
        child: StockCompareChart8Page(chartDiv, _stockGrpCd, _stkCode),
      ),
    );*/
  }

  // DEFINE Make Widget Fun

  // 그룹 선택 다이어로그
  _showScrollableSheetGroupCompare() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.8,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: ListView(
                controller: scrollController,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          //'${TStyle.getPostWord(_stkName, '이', '가')} 속한 그룹 입니다.',
                          _stkName,
                          style: TStyle.commonTitle,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Text(
                          //'${TStyle.getPostWord(_stkName, '이', '가')} 속한 그룹 입니다.',
                          '종목이 속한 그룹 입니다.',
                          style: TStyle.content15,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 500,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: ListView.builder(
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemCount: alStockGroup.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _makeGroupView(alStockGroup[index],
                            _stockGrpCd == alStockGroup[index].stockGrpCd);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 그룹 선택 다이어로그 _ 그룹 리스트뷰
  Widget _makeGroupView(StockGroup vStockGroup, bool isSelect) {
    Color _vColor;
    if (isSelect) {
      _vColor = RColor.mainColor;
    } else {
      _vColor = RColor.lineGrey;
    }
    return InkWell(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        decoration: UIStyle.boxRoundLine10c(_vColor),
        alignment: Alignment.center,
        child:
            Text('${vStockGroup.stockGrpNm}', style: TStyle.purpleThinStyle()),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!isSelect) {
          setOnClickGroupView(vStockGroup);
        }
      },
    );
  }

  // 차트 위 단위, y축, y축데이터 정렬 박스
  Widget _makeChartTopInfo() {
    // DEFINE 기업규모
    if (_tab0) {
      _compareChartYAxisUnit = '억';
      if (chart1YAxisTitleIndex == 0) {
        _compareChartYAxisTitle = titleColumn0[1];
      } else if (chart1YAxisTitleIndex == 1) {
        _compareChartYAxisTitle = titleColumn0[2];
      } else {
        _compareChartYAxisTitle = titleColumn0[1];
      }
    }

    // DEFINE 기업가치
    else if (_tab1) {
      _compareChartYAxisUnit = unitColumn1[chart1YAxisTitleIndex];
      _compareChartYAxisTitle = titleColumn1[chart1YAxisTitleIndex];
    }

    // DEFINE 성장성
    else if (_tab2) {
      _compareChartYAxisUnit = '%';
      _compareChartYAxisTitle = titleColumn2[chart1YAxisTitleIndex];
    }

    // DEFINE 변동성
    else if (_tab3) {
      _compareChartYAxisUnit = '%';
      _compareChartYAxisTitle = titleColumn3[chart1YAxisTitleIndex];
    }
    return Visibility(
      visible: haveData,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_compareChartYAxisTitle, style: TStyle.content16),
                Text(
                  '($_compareChartYAxisUnit)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Color(0xff111111),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _showScrollableSheetChart1Div();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: RColor.lineGrey,
                    width: 0.8,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "항목선택",
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "▼",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 차트 항목선택 다이어로그
  _showScrollableSheetChart1Div() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.95,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            //controller: scrollController,
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
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10),
                child: const Text(
                  '비교 항목을 선택 하세요.',
                  style: TStyle.title18T,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //SizedBox(height: 10,),
                        const Text(
                          '기업규모',
                          style: TStyle.commonSTitle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _makeChart1SortListViewChild(0, 0),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(0, 1),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          '기업가치',
                          style: TStyle.commonSTitle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _makeChart1SortListViewChild(1, 0),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(1, 1),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(1, 2),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          '성장성',
                          style: TStyle.commonSTitle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _makeChart1SortListViewChild(2, 0),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(2, 1),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          '변동성',
                          style: TStyle.commonSTitle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _makeChart1SortListViewChild(3, 0),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(3, 1),
                        const SizedBox(
                          height: 10,
                        ),
                        _makeChart1SortListViewChild(3, 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* // 차트 y축 항목선택 다이어로그 _ 리스트 뷰
  Widget _makeChart1SortView(int index) {
    bool isSelect = false;
    String strDivName;
    Color _color;

    if (_tab0) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn0[index + 1];
    } else if (_tab1) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn1[index];
    } else if (_tab2) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn2[index];
    } else if (_tab3) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn3[index];
    }

    if (isSelect) {
      _color = RColor.mainColor;
    } else {
      _color = RColor.lineGrey;
    }

    return InkWell(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        decoration: UIStyle.boxRoundLine10c(_color),
        alignment: Alignment.center,
        child: Text('$strDivName'),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!isSelect) {
          setState(() {
            chart1YAxisTitleIndex = index;
          });
        }
      },
    );
  }*/

  // 차트 항목선택 다이어로그 _ 리스트 뷰 _ 차일드
  Widget _makeChart1SortListViewChild(int tabIndex, int index) {
    bool isSelect = false;
    String strDivName = '';
    Color _color;
    TextStyle _tStyle;

    switch (tabIndex) {
      // 기업규모
      case 0:
        if (index == chart1YAxisTitleIndex && _tab0) {
          isSelect = true;
        }
        strDivName = titleColumn0[index + 1];
        break;
      // 기업가치
      case 1:
        if (index == chart1YAxisTitleIndex && _tab1) {
          isSelect = true;
        }
        strDivName = titleColumn1[index];
        break;
      // 성장성
      case 2:
        if (index == chart1YAxisTitleIndex && _tab2) {
          isSelect = true;
        }
        strDivName = titleColumn2[index];
        break;
      // 변동성
      case 3:
        if (index == chart1YAxisTitleIndex && _tab3) {
          isSelect = true;
        }
        strDivName = titleColumn3[index];
        break;
    }

    /*if (_tab0) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn0[index + 1];
    } else if (_tab1) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn1[index];
    } else if (_tab2) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn2[index];
    } else if (_tab3) {
      if (index == chart1YAxisTitleIndex) {
        isSelect = true;
      } else {
        isSelect = false;
      }
      strDivName = titleColumn3[index];
    }*/

    if (isSelect) {
      _color = RColor.mainColor;
      _tStyle = TStyle.commonPurple14;
    } else {
      _color = RColor.lineGrey;
      _tStyle = TStyle.content14;
    }

    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: UIStyle.boxRoundLine10c(_color),
        alignment: Alignment.center,
        child: Text(
          strDivName,
          style: _tStyle,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!isSelect) {
          chart1YAxisTitleIndex = index;
          setOnClickChart1DivListViewChild(tabIndex);
        }
      },
    );
  }

  // 차트1
  Widget _makeChart() {
    _setChart1Data();

    int _gridBottomPadding = 0;
    int _gridLeftPadding = 14;
    if (!_compareChartIsShowOver) {
      _gridBottomPadding = 30;
    }
    if (_compareChartIsShowOverPerYAxis) {
      _gridLeftPadding = -10;
    }

    return Visibility(
      visible: haveData,
      child: Container(
        // margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        width: double.infinity,
        height: 240,
        child: Stack(
          children: [
            Echarts(
              captureHorizontalGestures: true,
              reloadAfterInit: true,
              extraScript: '''

              ''',
              option: '''
                      {
                        backgroundColor: '#F3F4F8',
                        grid: {
                          left: $_gridLeftPadding,
                          top: 24,
                          right: 34,
                          bottom: $_gridBottomPadding,
                          containLabel: true
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
                            }
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
                        
                   ''' +
                  _compareChartYAxisBasicStr +
                  _compareChartYAxisOverStr +
                  '''    
                          
                          {
                            axisLine: {
                              show: false,
                            },
                            name: '시가총액(억)',
                            nameLocation: 'start',
                            nameGap: 26,
                            nameTextStyle: {
                              align:'center',
                              fontSize: 11,
                            },
                          },
                        ],
                        series: [$_chart1DataStr],
                      }
                        ''',
            ),
            InkWell(
              onTap: () {
                if (_tab0) {
                  if (chart1YAxisTitleIndex == 0) {
                    setState(() {
                      chart1YAxisTitleIndex++;
                    });
                  } else if (chart1YAxisTitleIndex == 1) {
                    chart1YAxisTitleIndex = 0;
                    setOnClickChart1DivListViewChild(1);
                  }
                } else if (_tab1) {
                  if (chart1YAxisTitleIndex == 0 ||
                      chart1YAxisTitleIndex == 1) {
                    setState(() {
                      chart1YAxisTitleIndex++;
                    });
                  } else {
                    chart1YAxisTitleIndex = 0;
                    setOnClickChart1DivListViewChild(2);
                  }
                } else if (_tab2) {
                  if (chart1YAxisTitleIndex == 0) {
                    setState(() {
                      chart1YAxisTitleIndex++;
                    });
                  } else if (chart1YAxisTitleIndex == 1) {
                    chart1YAxisTitleIndex = 0;
                    setOnClickChart1DivListViewChild(3);
                  }
                } else if (_tab3) {
                  if (chart1YAxisTitleIndex == 0 ||
                      chart1YAxisTitleIndex == 1) {
                    setState(() {
                      chart1YAxisTitleIndex++;
                    });
                  } else {
                    chart1YAxisTitleIndex = 0;
                    setOnClickChart1DivListViewChild(0);
                  }
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeChartWatchInfoView() {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: const BoxDecoration(
          color: RColor.bgWeakGrey,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: ExpansionTile(
          collapsedIconColor: RColor.mainColor,
          iconColor: RColor.mainColor,
          initiallyExpanded: false,
          title: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'images/icon_rassi_logo_purple.png',
                  width: 20,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '차트, 이렇게 보세요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Text(
                _tab0
                    ? RString.str_list_stock_compare_chart_info[0]
                    : _tab1
                        ? RString.str_list_stock_compare_chart_info[1]
                        : _tab2
                            ? RString.str_list_stock_compare_chart_info[2]
                            : _tab3
                                ? RString.str_list_stock_compare_chart_info[3]
                                : '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 탭 버튼들
  Widget _makeTabButton() {
    return Visibility(
      visible: haveData,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (!_tab0) {
                    _tab0 = true;
                    _tab1 = false;
                    _tab2 = false;
                    _tab3 = false;
                    setOnClickTabButtonView();
                  }
                },
                child: Container(
                  height: 40,
                  decoration: _tab0
                      ? UIStyle.boxBtnSelected20()
                      : UIStyle.boxRoundLine20(),
                  alignment: Alignment.center,
                  child: Text(
                    '기업규모',
                    style: _tab0 ? TStyle.btnContentWht15 : TStyle.content15,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  _tab0 = false;
                  _tab1 = true;
                  _tab2 = false;
                  _tab3 = false;
                  setOnClickTabButtonView();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 40,
                  decoration: _tab1
                      ? UIStyle.boxBtnSelected20()
                      : UIStyle.boxRoundLine20(),
                  alignment: Alignment.center,
                  child: Text(
                    '기업가치',
                    style: _tab1 ? TStyle.btnContentWht15 : TStyle.content15,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  _tab0 = false;
                  _tab1 = false;
                  _tab2 = true;
                  _tab3 = false;
                  setOnClickTabButtonView();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 40,
                  decoration: _tab2
                      ? UIStyle.boxBtnSelected20()
                      : UIStyle.boxRoundLine20(),
                  alignment: Alignment.center,
                  child: Text(
                    '성장성',
                    style: _tab2 ? TStyle.btnContentWht15 : TStyle.content15,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  _tab0 = false;
                  _tab1 = false;
                  _tab2 = false;
                  _tab3 = true;
                  setOnClickTabButtonView();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 40,
                  decoration: _tab3
                      ? UIStyle.boxBtnSelected20()
                      : UIStyle.boxRoundLine20(),
                  alignment: Alignment.center,
                  child: Text(
                    '변동성',
                    style: _tab3 ? TStyle.btnContentWht15 : TStyle.content15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 테이블 _ 상단 : 데이터 반영 기준일 + base data 표시
  Widget _makeTableHighInfo() {
    String _leftInfoStr = '';
    if (_tab0) {
      _leftInfoStr = '$_year/${_quarter}Q반영 연환산';
    } else if (_tab1) {
      _leftInfoStr = 'PER, PBR : 전일 보통주 수정주가 / 최근 분기 EPS, BPS\n배당수익률 : 최근결산 기준';
    } else if (_tab2) {
      _leftInfoStr = '$_year/${_quarter}Q반영 전년동기대비';
    } else if (_tab3) {
      _leftInfoStr = '최근 1년';
    }

    return Visibility(
      visible: haveData,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _leftInfoStr,
                style: TStyle.textSGrey,
              ),
            ),
            Visibility(
              visible: _tab1 || _tab3,
              child: const Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '전일종가기준',
                    style: TStyle.textSGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 테이블
  Widget _makeTable() {
    List<String> titleColumn = [];
    // DEFINE 기업규모
    if (_tab0) {
      titleColumn = titleColumn0;
      // 시가총액 높은 > 낮은 순으로 정렬
      alStockCompare02.sort((a, b) {
        if (a.marketValue.isEmpty) {
          return 1;
        } else if (b.marketValue.isEmpty) {
          return 0;
        } else {
          return double.parse(b.marketValue)
              .compareTo(double.parse(a.marketValue));
        }
      });
    }
    // DEFINE 기업가치
    else if (_tab1) {
      titleColumn = titleColumn1;
      // PER낮은순
      alStockCompare02.sort((a, b) {
        if (a.per.isEmpty) {
          return 1;
        } else if (b.per.isEmpty) {
          return 0;
        } else {
          return double.parse(a.per).compareTo(double.parse(b.per));
        }
      });
    }
    // DEFINE 성장성
    else if (_tab2) {
      titleColumn = titleColumn2;
      // 매출액증가율 높은순
      alStockCompare02.sort((a, b) {
        if (a.salesRateQuart.isEmpty) {
          return 1;
        } else if (b.salesRateQuart.isEmpty) {
          return 0;
        } else {
          return double.parse(b.salesRateQuart)
              .compareTo(double.parse(a.salesRateQuart));
        }
      });
    }
    // DEFINE 변동성
    else if (_tab3) {
      titleColumn = titleTableColumn3;
      // 간별등락률 높은순
      alStockCompare02.sort((a, b) {
        if (a.fluctYear1.isEmpty) {
          return 1;
        } else if (b.fluctYear1.isEmpty) {
          return 0;
        } else {
          return double.parse(b.fluctYear1)
              .compareTo(double.parse(a.fluctYear1));
        }
      });
    }

    int columns = titleColumn.length;
    int rows = alStockCompare02.length;
    int highLightedIndex = 0;

    final List<List<String>> result = [];
    for (int i = 0; i < columns; i++) {
      final List<String> row = [];
      for (int j = 0; j < rows + 1; j++) {
        if (j == 0) {
          row.add(titleColumn[i]);
        } else {
          StockCompare02 stockCompare02 = alStockCompare02[j - 1];
          if (stockCompare02.stockCode == _stkCode) {
            highLightedIndex = j;
          }
          String rowValue = '';

          // DEFINE 기업규모
          if (_tab0) {
            if (i == 0) {
              rowValue = stockCompare02.marketValue;
            } else if (i == 1) {
              rowValue = stockCompare02.sales;
            } else {
              rowValue = stockCompare02.salesProfit;
            }
          }
          // DEFINE 기업가치
          else if (_tab1) {
            if (i == 0) {
              rowValue = stockCompare02.per;
            } else if (i == 1) {
              rowValue = stockCompare02.pbr;
            } else {
              rowValue = stockCompare02.dividendRate;
            }
          }
          // DEFINE 성장성
          else if (_tab2) {
            if (i == 0) {
              rowValue = stockCompare02.salesRateQuart;
            } else if (i == 1) {
              rowValue = stockCompare02.profitRateQuart;
            }
          }
          // DEFINE 변동성
          else if (_tab3) {
            if (i == 0) {
              rowValue = stockCompare02.fluctYear1;
            } else if (i == 1) {
              rowValue = stockCompare02.top52FluctRate;
            } else {
              rowValue = stockCompare02.low52FluctRate;
            }
          }

          // DEFINE N/A 값 체크
          if (rowValue.isEmpty) {
            rowValue = '-';
          } else {
            rowValue = TStyle.getMoneyPoint2(rowValue);
          }
          row.add(rowValue);
        }
      }
      result.add(row);
    }

    //     contentCellHeight: 50.0,
    //     stickyLegendHeight: 50.0,

    double rowSize = 0;
    double screenSzie = MediaQuery.of(context).size.width;

    // 나중에 열 하나 더 추가 되면
    /*if(titleColumn.length > 3){
      titleColumn.length 가 3보단 작아야함 밑에 계산할때
    }
*/
    rowSize = ((screenSzie - (screenSzie / 4.0)) / titleColumn.length) - 10.5;

    double titleViewHeight = 80;

    return Visibility(
      visible: haveData,
      child: Container(
        height: 50.0 * (rows) + titleViewHeight + 2,
        margin: const EdgeInsets.fromLTRB(15, 4, 15, 4),
        decoration: const BoxDecoration(
          //color: RColor.bgWeakGrey,
          border: Border(
            top: BorderSide(color: Colors.black, width: 1),
            //bottom: BorderSide(color: Colors.black, width: 1.4),
            //right: BorderSide(color: Colors.red, width: 1),
          ),
        ),
        child: CustomStickyHeadersTable(
          columnsLength: titleColumn.length,
          // rowsLength: _listTableStockCompare02.length + 1,
          rowsLength: alStockCompare02.length + 1,
          //  rowsTitleBuilder: (i) => _makeTableTitleRowView(i, _listTableStockCompare02[i]),
          rowsTitleBuilder: (i) => _makeTableTitleRowView(
            i,
          ),
          onRowTitlePressed: (i) => _setOnClickTableRow(i),
          contentCellBuilder: (i, j) =>
              _makeTableTitleColumnView(j, result[i][j]),
          onContentCellPressed: (i, j) => setOnClickTabsView2TitleClick(i, j),
          rowTitleWidth: MediaQuery.of(context).size.width / 4.0,
          // 종목명 들어가는 1열의 width
          dataCellcontentWidth: rowSize,
          // 데이터 들어가는 행들의 width
          titleViewHeight: titleViewHeight,
          highLightedIndex: highLightedIndex, onEndScrolling: (double x, double y) {  },
        ),
      ),
    );
  }

  // 테이블 _ 0열에 종목/항목 + 종목명 들어가는 0열 만드는 뷰
  Widget _makeTableTitleRowView(
    int i,
  ) {
    if (i == 0) {
      return Container(
        child: const Text(
          '종목/항목',
        ),
      );
    } else {
      return Text(
        TStyle.getLimitString(alStockCompare02[i - 1].stockName, 6),
        style: TStyle.subTitle,
        //overflow: TextOverflow.ellipsis,
      );
    }
  }

  // 테이블 _ 0행에 시가/총액 매출액, per, pbr, 매출액 증가율 등 타이틀 만드는 뷰
  Widget _makeTableTitleColumnView(int j, String data) {
    TextStyle tStyle;
    if (j == 0) {
      if (data == _compareChartYAxisTitle ||
          (_tab3 && (data == titleTableColumn3[chart1YAxisTitleIndex]))) {
        tStyle = TStyle.commonPurple14;
      } else {
        tStyle = TStyle.subTitle;
      }

      if (!_tab0) {
        return Container(
          //alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: _tab3,
                child: Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        data,
                        style: tStyle,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !_tab3,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    data,
                    style: tStyle,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: UIStyle.boxRoundLine25c(RColor.mainColor),
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: const Text(
                  '차트보기',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: RColor.mainColor,
                  ),
                ),
              ),
              Visibility(
                visible: _tab3,
                child: const SizedBox(
                  height: 6,
                ),
              ),
              /*Image.asset(
                'images/img_inst.png',
                height: 30,
                fit: BoxFit.contain,
              ),*/
            ],
          ),
        );
      }
    } else {
      /*if (data.contains('-')) {
        tStyle = TStyle.textMSell;
      } else {
        tStyle = TStyle.content14;
      }*/
      tStyle = TStyle.content14;
    }

    return Text(
      data,
      style: tStyle,
    );
  }

  // 테이블 _ 하단 : 종목 반영 년도 + 분기 표시
  Widget _makeTableQuarterInfo() {
    bool _isShowThisView = false;
    if (_tab0 || _tab2) {
      _isShowThisView = true;
    }

    List<StockCompare02> _vAlStockCompare02 = [];
    _vAlStockCompare02.addAll(alStockCompare02);

    _listYQClass.clear();
    for (int i = 0; i < _vAlStockCompare02.length; i++) {
      var item = _vAlStockCompare02[i];
      if (item.latestQuarter.isNotEmpty) {
        String itemYear = item.latestQuarter.substring(0, 4);
        String itemQ = item.latestQuarter.substring(5);
        bool isSame = false;
        for (int k = 0; k < _listYQClass.length; k++) {
          if (itemYear == _listYQClass[k].year &&
              itemQ == _listYQClass[k].quarter) {
            isSame = true;
            _listYQClass[k].listStockName.add(item.stockName);
            break;
          }
        }
        if (!isSame) {
          List<String> vListStockName = [item.stockName];
          _listYQClass.add(YearQuarterClass(itemYear, itemQ, vListStockName));
        }
      }
    }

    _listYQClass.sort((a, b) => b.quarter.compareTo(a.quarter));
    _listYQClass.sort((a, b) => b.year.compareTo(a.year));

    return Visibility(
      visible: _isShowThisView && haveData,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: TileYearQuarterListView(_listYQClass),
      ),
    );
  }

  // 테이블 _ 하단2 : 탭 4개의 설명들
  Widget _makeTableLowInfo() {
    String _vTipTitle = '';
    String _vTipcontent = '';
    String _vTopTip = '';

    if (_tab0) {
      _vTipTitle = alTipTitles[0];
      _vTipcontent = alTipContents[0];
      _vTopTip = '시가총액 : 매일 현재가 업데이트\n매출액, 영업이익 : 최근분기포함 4개분기 합';
    } else if (_tab1) {
      _vTipTitle = alTipTitles[1];
      _vTipcontent = alTipContents[1];
      _vTopTip = '배당수익률 : KIND(한국거래소 기업공시채널) 자료 수집 제공';
    } else if (_tab2) {
      _vTipTitle = alTipTitles[2];
      _vTipcontent = alTipContents[2];
    } else if (_tab3) {
      _vTipTitle = alTipTitles[3];
      _vTipcontent = alTipContents[3];
    }

    return Visibility(
      visible: haveData,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        child: Column(
          children: [
            Visibility(
              visible: _tab0 || _tab1,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _vTopTip,
                    style: TStyle.contentGrey12,
                  )),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                _vTipTitle,
                style: TStyle.puplePlainStyle(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(
                _vTipcontent,
                style: TStyle.textGrey14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMPARE02 데이터 없을때
  Widget _makeNoDataView() {
    return Visibility(
      visible: !haveData,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
        decoration: UIStyle.boxWeakGrey10(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(
              'images/icon_no_compare_group.png',
              height: 70,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${TStyle.getLimitString(_stkName, 6)} ',
                  style: TStyle.title17,
                ),
                const Text(
                  '종목비교가 없습니다.',
                  style: TStyle.content16,
                ),
              ],
            ),
            const Text(
              '지금 핫한 다른 종목그룹을 비교해 보세요!',
              style: TStyle.content16,
            ),
          ],
        ),
      ),
    );
  }

  // 핫그룹
  Widget _makeHotGroupView() {
    return Container(
      margin:
          haveData ? const EdgeInsets.only(top: 20) : const EdgeInsets.all(0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: haveData ? RColor.bgWeakGrey : Colors.transparent,
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Visibility(
                    visible: haveData,
                    child: const Text(
                      '이 시간 핫 종목비교',
                      style: TStyle.commonTitle,
                    ),
                  ),
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: alStockHotGroup.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: TileStockGroup(alStockHotGroup[index]),
                      onTap: () {
                        setOnClickHotGroupView(alStockHotGroup[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setChart1Data() {
    String tmpData = '';
    String _markLine = '';
    int _xAxisIndex = 0;
    int _vOverChartIndex = 0; // 차트에 표기 못하고 [이상 으로 표기해야하는 시작 index]
    String _chartColor = '';

    _compareChartIsShowOver = false;
    _compareChartIsShowOverPerYAxis = false;

    if (alStockCompare02.isEmpty) {
      return;
    }

    // 시가총액 낮은 > 높은 순으로 정렬
    alStockCompare02.sort((a, b) =>
        double.parse(a.marketValue).compareTo(double.parse(b.marketValue)));

    // DEFINE 최소값
    String _smallMarketValue = alStockCompare02[0].marketValue;
    if (_smallMarketValue.isEmpty) {
      _compareChartXAxisMin = 0;
    } else {
      _compareChartXAxisMin = int.parse(_smallMarketValue) -
          (int.parse(_smallMarketValue) * 0.15).toInt();
    }

    // DEFINE 최대값 [1]
    String _bigMarketValue = '';

    // DEFINE 종목 개수 3개 이상일때
    if (alStockCompare02.length > 2) {
      if (_smallMarketValue.isNotEmpty &&
          int.parse(_smallMarketValue) > 10000) {
        _bigMarketValue =
            alStockCompare02[alStockCompare02.length - 1].marketValue;
      } else {
        for (int k = 1; k < alStockCompare02.length; k++) {
          _vOverChartIndex = k;
          if (alStockCompare02[k].marketValue.isNotEmpty &&
              int.parse(alStockCompare02[k].marketValue) > 10000) {
            _compareChartIsShowOver = true;
            _bigMarketValue = alStockCompare02[k - 1].marketValue;
            if (k + 3 <= alStockCompare02.length) {
              _compareChartIsShowOver = false;
              _bigMarketValue =
                  alStockCompare02[alStockCompare02.length - 1].marketValue;
            }
            break;
          } else if (k == alStockCompare02.length - 1 &&
              int.parse(alStockCompare02[k].marketValue) <= 10000) {
            _vOverChartIndex = k + 1;
            _bigMarketValue = alStockCompare02[k].marketValue;
          }
        }
      }
    }
    // 2개 알때
    else if (alStockCompare02.length == 2) {
      _bigMarketValue = alStockCompare02[1].marketValue;
    }
    // 1개 일때
    else if (alStockCompare02.length == 1) {
      _compareChartXAxisMax = _compareChartXAxisMax;
    } else {
      return;
    }

    // DEFINE 최대값 [2]
    _compareChartXAxisMax = int.parse(_bigMarketValue) +
        (int.parse(_bigMarketValue) * 0.15).toInt();

    int _numbering = 0;
    for (int k = 0; k < 2; k++) {
      int _chartXAxisFinalValue = 0;
      if (k == 0) {
        if (_compareChartXAxisMin == 0) {
          _numbering = 0;
        } else {
          _numbering = log(_compareChartXAxisMin) ~/ ln10 + 1;
        }
        _chartXAxisFinalValue = _compareChartXAxisMin;
      } else {
        _numbering = log(_compareChartXAxisMax) ~/ ln10 + 1;
        _chartXAxisFinalValue = _compareChartXAxisMax;
      }

      if (_numbering == 3) {
        _chartXAxisFinalValue = _chartXAxisFinalValue -
            (_chartXAxisFinalValue % 100 % 10); // 일의자리 0으로 만들기
      } else if (_numbering == 4) {
        _chartXAxisFinalValue = _chartXAxisFinalValue -
            (_chartXAxisFinalValue % 1000 % 100); // 일, 십 의자리 0으로 만들기
      } else if (_numbering == 5) {
        _chartXAxisFinalValue = _chartXAxisFinalValue -
            (_chartXAxisFinalValue % 10000 % 1000 % 100); // 일, 십 의자리 0으로 만들기
      } else if (_numbering == 6) {
        _chartXAxisFinalValue = _chartXAxisFinalValue -
            (_chartXAxisFinalValue %
                100000 %
                10000 %
                1000); // 일, 십, 백 의자리 0으로 만들기
      } else if (_numbering == 7) {
        _chartXAxisFinalValue = _chartXAxisFinalValue -
            (_chartXAxisFinalValue %
                1000000 %
                100000 %
                10000 %
                1000); // 일, 십, 백 의자리 0으로 만들기
      }

      if (k == 0) {
        _compareChartXAxisMin = _chartXAxisFinalValue;
      } else {
        _compareChartXAxisMax = _chartXAxisFinalValue;
      }
    }

    _compareChartXaxisInterval =
        (_compareChartXAxisMax - _compareChartXAxisMin) ~/ 5;

    // DEFINE Y축 PER 이상 추가
    if (_tab1 && chart1YAxisTitleIndex == 0) {
      List _listStockCompare02YAxisSort = [];
      _listStockCompare02YAxisSort.addAll(alStockCompare02);

      // 1. Y축 정렬
      // per 낮은 > 높은 순으로 정렬
      _listStockCompare02YAxisSort.sort((a, b) {
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
      if (_listStockCompare02YAxisSort.length > 1) {
        if (_listStockCompare02YAxisSort[0].per.isNotEmpty &&
            double.parse(_listStockCompare02YAxisSort[0].per) > 150) {
          _compareChartIsShowOverPerYAxis = true;
          _bigPerValue = '140';
        } else {
          for (int k = 1; k < _listStockCompare02YAxisSort.length; k++) {
            if (_listStockCompare02YAxisSort[k].per.isNotEmpty &&
                double.parse(_listStockCompare02YAxisSort[k].per) > 150) {
              _compareChartIsShowOverPerYAxis = true;
              _bigPerValue = _listStockCompare02YAxisSort[k - 1].per;
              break;
            }
          }
        }
      }

      if (_compareChartIsShowOverPerYAxis) {
        // DEFINE 최대값 [2]
        _compareChartYAxisMax = (double.parse(_bigPerValue) + 20).toInt();
        while (_compareChartYAxisMax % 5 != 0) _compareChartYAxisMax++;

        _compareChartYaxisInterval = (_compareChartYAxisMax) ~/ 5;
      }
    }

    _setChart1YAxisStr();

    for (int k = 0; k < alStockCompare02.length; k++) {
      var item = alStockCompare02[k];
      int _yAxisIndex = 0;
      String _yAxisValue = '';
      String _xAxisChartValue = '0'; // 차트에 찍는 x값
      String _dataLabelStr = '\\n';
      String _dataLabelPosition = 'right';
      String _customYAxisValue = '';

      // DEFINE 기업규모
      if (_tab0) {
        if (chart1YAxisTitleIndex == 0) {
          _yAxisValue = item.sales;
        } else {
          _yAxisValue = item.salesProfit;
        }
      }

      // DEFINE 기업가치
      else if (_tab1) {
        if (chart1YAxisTitleIndex == 0) {
          _yAxisValue = item.per;
        } else if (chart1YAxisTitleIndex == 1) {
          _yAxisValue = item.pbr;
        } else if (chart1YAxisTitleIndex == 2) {
          _yAxisValue = item.dividendRate;
        } else {
          _yAxisValue = item.per;
        }
      }

      // DEFINE 성장성
      else if (_tab2) {
        if (chart1YAxisTitleIndex == 0) {
          _yAxisValue = item.salesRateQuart;
        } else if (chart1YAxisTitleIndex == 1) {
          _yAxisValue = item.profitRateQuart;
        } else {
          _yAxisValue = item.salesRateQuart;
        }
      }

      // DEFINE 변동성
      else if (_tab3) {
        if (chart1YAxisTitleIndex == 0) {
          _yAxisValue = item.fluctYear1;
        } else if (chart1YAxisTitleIndex == 1) {
          _yAxisValue = item.top52FluctRate;
        } else if (chart1YAxisTitleIndex == 2) {
          _yAxisValue = item.low52FluctRate;
        } else {
          _yAxisValue = item.fluctYear1;
        }
      }

      if (_yAxisValue.isEmpty) _yAxisValue = '0';
      _customYAxisValue = _yAxisValue;

      // DEFINE DATA LABEL
      // [기업규모]매출액, 영업이익 > 소수점 자르기 // 나머지는 소수점 두자리까지 그대로 표기
      if (_tab0) {
        if (_customYAxisValue.contains('.')) {
          _customYAxisValue = _customYAxisValue.split('.')[0];
        }
        _dataLabelStr += TStyle.getMoneyPoint(_customYAxisValue);
      } else {
        _dataLabelStr += TStyle.getMoneyPoint2(_customYAxisValue);
      }

      if (k < _vOverChartIndex || !_compareChartIsShowOver) {
        _xAxisChartValue = item.marketValue;
        _xAxisIndex = 0;
        _markLine = '';
      } else {
        _xAxisChartValue = '0';
        _xAxisIndex = 1;
        _dataLabelPosition = 'left';
        _markLine = '''
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

      if (_stkCode == item.stockCode) {
        _chartColor = '#7774F7';
      } else {
        _chartColor = 'black';
      }

      if (_tab1 &&
          chart1YAxisTitleIndex == 0 &&
          _compareChartIsShowOverPerYAxis &&
          item.per.isNotEmpty &&
          (double.parse(item.per) > 150)) {
        _yAxisIndex = 1;
        _yAxisValue = '0';

        tmpData += '''
        {
          xAxisIndex: $_xAxisIndex,
          yAxisIndex: $_yAxisIndex,
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
              color: '$_chartColor',
              fontWeight: 'bold',
            },
            fontSize: 12,
            show: true,
            position: '$_dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$_xAxisChartValue, 0, '${item.stockName}\\n'],],
          type: 'scatter',
          itemStyle: {
            color: '$_chartColor',
          },
        },
        ''';
      } else {
        tmpData += '''
        {
          xAxisIndex: $_xAxisIndex,
          markLine: {$_markLine},
          label: {
            textStyle:{
              color: '$_chartColor',
              fontWeight: 'bold',
            },
            fontSize: 12,
            show: true,
            position: '$_dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$_xAxisChartValue, $_yAxisValue, '${item.stockName}\\n'],],
          type: 'scatter',
          itemStyle: {
            color: '$_chartColor',
          },
        },
        ''';
      }

      // 차트 라벨 데이터 때문에 한번더..
      tmpData += '''
        {
          xAxisIndex: $_xAxisIndex,
          yAxisIndex: $_yAxisIndex,
          label: {
            textStyle:{
              color: '$_chartColor',
            },
            fontSize: 8,
            show: true,
            position: '$_dataLabelPosition',
            formatter: function(d) {
              return d.value[2];
            },
          },
          symbolSize: 8,
          data: [[$_xAxisChartValue, $_yAxisValue, '$_dataLabelStr$_compareChartYAxisUnit'],],
          type: 'scatter',
          itemStyle: {
              color: '$_chartColor',
          },
        },
        ''';
    }

    _chart1DataStr = tmpData;
  }

  void _setChart1YAxisStr() {
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
          name: '차트를 클릭해 보세요.',
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
        position: 'left',
        name: '차트를 클릭해 보세요.',
        nameLocation: 'end',
        nameGap: 0,
        nameTextStyle: {
          align:'left',
          fontSize: 11,
        },
      },
      ''';
      _compareChartYAxisOverStr = '';
    }
  }

  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
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
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
