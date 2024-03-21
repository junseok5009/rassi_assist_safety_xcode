import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/chart_data.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal07.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal08.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.12.22
/// 매매신호 - 모든 내역
class SignalAllPage extends StatelessWidget {
  static const routeName = '/page_signal_all';
  static const String TAG = "[SignalAllPage]";
  static const String TAG_NAME = '매매신호_전체내역';

  const SignalAllPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: const SignalAllWidget(),
      ),
    );
  }
}

class SignalAllWidget extends StatefulWidget {
  const SignalAllWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignalAllState();
}

class SignalAllState extends State<SignalAllWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String stkName = "";
  String stkCode = "";

  final List<ChartDataR> _listData = [];
  late ScrollController _scrollController;
  int pageNum = 0;

  String _dateStr = '[]';
  String _dataStr = '[]';
  final String upArrow = '\'path://M16 1l-15 15h9v16h12v-16h9z\'';
  final String downArrow = '\'path://M16 31l15-15h-9v-16h-12v16h-9z\'';

  String _tradePeriod = ''; //매매기간
  String _tradeCnt = ''; //매매횟수
  String _avgHolding = ''; //평균보유기간

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SignalAllPage.TAG_NAME,
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(SignalAllPage.TAG, "delayed user id : $_userId");
      if (_userId != '' && args != null) {
        DLog.d(SignalAllPage.TAG, args.pgData);

        _fetchPosts(
            TR.SIGNAL08,
            jsonEncode(<String, String>{
              'userId': _userId,
              'stockCode': args.stockCode,
              'includeData': 'Y',
            }));
      }
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    stkName = args.stockName;
    stkCode = args.stockCode;
    DLog.d(SignalAllPage.TAG, args.stockName);
    DLog.d(SignalAllPage.TAG, args.stockCode);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '${TStyle.getLimitString(stkName, 10)}의 AI매매신호 내역',
          style: TStyle.commonTitle,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _listData.length + 1,
          itemBuilder: (context, index) {
            if(index == 0) {
              return _setHeaderView();
            } else {
              return TileSignal07(_listData[index -1]);
            }
          },
        ),
      ),
    );
  }

  Widget _setHeaderView() {
    return Container(
      width: double.infinity,
      height: 460,
      color: RColor.bgWeakGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '최근 1년간 AI 매매신호',
                  style: TStyle.commonTitle,
                ),
              ),
              const SizedBox(height: 10.0),

              Container(
                width: double.infinity,
                height: 270,
                child: _setEChartView(),
              ),

              // Image.network(
              //   'https://webchart.thinkpool.com/signalapp/1ylinebs/A$stkCode.png',
              //   height: 240,),
            ],
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            color: RColor.bgWeakGrey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('매매기간'),
                      Text(_tradeCnt),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //매매기간
                      Text(
                        _tradePeriod,
                        style: TStyle.contentSBLK,
                      ),
                      //평균보유기간
                      Text(_avgHolding),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _setColumeTitle(),
        ],
      ),
    );
  }

  //컬럼 타이틀
  Widget _setColumeTitle() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 1.5),
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                '날짜',
                style: TStyle.commonSTitle,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey, width: 1)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '구분',
                style: TStyle.commonSTitle,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey, width: 1)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '가격',
                style: TStyle.commonSTitle,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                '수익률',
                style: TStyle.commonSTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      pageNum = pageNum + 1;
      _requestSIGNAL07();
    } else {}
  }

  _requestSIGNAL07() {
    _fetchPosts(
        TR.SIGNAL07,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockCode': stkCode,
          'pageNo': pageNum.toString(),
          'pageItemSize': '30',
        }));
  }

  //새로운 차트 데이터
  Widget _setEChartView() {
    return Echarts(
      captureHorizontalGestures: true,
      reloadAfterInit: true,
      extraScript: '''
          var up = 'path://M286.031,265l-16.025,3L300,223l29.994,45-16.041-3-13.961,69Z';
          var down = 'path://M216.969,292l16.025-3L203,334l-29.994-45,16.041,3,13.961-69Z';
          var non = 'none';
          var date = [];
          var data = [];
          var sym = [non, up, down];
        ''',
      option: '''
        {
          grid: {
            top: 15,
            left: 20,
            right: 60,
          },
          xAxis: {
              type: 'category',
              boundaryGap: false,
              data: $_dateStr
          },
          yAxis: {
              type: 'value',
              position: 'right',
              scale: true,
              boundaryGap: [0, '5%'],
          },
          dataZoom: [
          {
              type: 'inside',
              start: 0,
              end: 100
          }, 
          {
              start: 0,
              end: 10,
              handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
              handleSize: '80%',
              handleStyle: {
                  color: '#fff',
                  shadowBlur: 3,
                  shadowColor: 'rgba(0, 0, 0, 0.6)',
                  shadowOffsetX: 2,
                  shadowOffsetY: 2
              }
          }
          ],
          series: [
              {
                  name: 'data',
                  type: 'line',
                  color: '#31b573',
                  smooth: false,
                  showSymbol: true,
                  showAllSymbol: true,
                  symbolSize: 12,
                  sampling: 'average',
                  lineStyle: {
                    color: '#68cc54',
                    width: 1.5
                  },
                  data: $_dataStr,
              }
          ]
        }
      ''',
    );
  }

  //네트워크 에러 알림
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

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SignalAllPage.TAG, '$trStr $json');

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
      DLog.d(SignalAllPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(SignalAllPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  //비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalAllPage.TAG, response.body);

    if (trStr == TR.SIGNAL08) {
      final TrSignal08 resData = TrSignal08.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        final Signal08? mData = resData.retData;
        if (mData != null) {
          List<ChartData> chartData = mData.listChart;
          String tmpDate = '[';
          String tmpData = '[';
          for (int i = 0; i < chartData.length; i++) {
            tmpDate = '$tmpDate\'${TStyle.getDateDivFormat(chartData[i].tradeDate)}\',';

            //0:없음, 1:매수, 2:매도
            if (chartData[i].flag == null || chartData[i].flag == '') {
              tmpData = '$tmpData{value: ${chartData[i].tradePrc},symbol: \'none\'},';
            } else if (chartData[i].flag == 'B') {
              tmpData = '$tmpData{value: ${chartData[i].tradePrc},symbol: $upArrow, symbolOffset: [0,18],itemStyle: {color:\'red\'}},';
            } else if (chartData[i].flag == 'S') {
              tmpData = '$tmpData{value: ${chartData[i].tradePrc},symbol: $downArrow, symbolOffset: [0,-18],itemStyle: {color:\'blue\'}},';
              // 'symbol: \'arrow\', symbolRotate: 180, itemStyle: {color:\'blue\'}},';
            }
          }
          tmpDate = '$tmpDate]';
          tmpData = '$tmpData]';
          _dateStr = tmpDate;
          _dataStr = tmpData;
          DLog.d(SignalAllPage.TAG, _dataStr);
          setState(() {});
        }
      }

      _requestSIGNAL07();
    }

    //종목 매매신호 리스트
    else if (trStr == TR.SIGNAL07) {
      final TrSignal07 resData = TrSignal07.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Signal07? item = resData.retData;
        if (item != null) {
          if (pageNum == 0) {
            String beginD = '';
            String endD = '';

            if (item.beginDate.isEmpty) {
              if (item.listData.length > 0) {
                beginD = TStyle.getDateSFormat(item.listData[0].tradeDate);
                endD = TStyle.getTodayDateStringDot();
              } else {
                beginD = '';
                endD = '';
              }
            } else {
              beginD = TStyle.getDateSFormat(item.beginDate);
              endD = TStyle.getDateSFormat(item.endDate);
            }

            _tradePeriod = '$beginD~$endD';

            item.holdingDays.isEmpty ? _avgHolding = '' : _avgHolding = '평균보유기간 ${item.holdingDays}일';
            item.tradeCount.isEmpty ? _tradeCnt = '' : _tradeCnt = '총 ${item.tradeCount}회 매매';
          }
          // _listData = item.listData;
          _listData.addAll(item.listData);

          setState(() {});
        }
      }
    }
  }
}
