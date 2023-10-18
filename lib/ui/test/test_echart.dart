import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/chart_data.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal08.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';


/// EChart Page
class EChartPage extends StatelessWidget {
  static const routeName = '/page_e_chart';
  static const String TAG = "[EChartPage] ";

  const EChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Default',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: const EChartWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EChartWidget extends StatefulWidget {
  const EChartWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EChartState();
}

class EChartState extends State<EChartWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //플루터에서 JavaScript 로그를 읽어오는 방법은?
  //https://echarts.apache.org/examples/en/index.html
  //https://www.programmersought.com/article/43374390101/

  late SharedPreferences _prefs;
  String _userId = '';

  String _dateStr = '[]';
  String _dataStr = '[]';
  final String upArrow = '\'path://M16 1l-15 15h9v16h12v-16h9z\'';
  final String downArrow = '\'path://M16 31l15-15h-9v-16h-12v16h-9z\'';

  @override
  void initState() {
    super.initState();

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      DLog.d(EChartPage.TAG, "User ID : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.SIGNAL08,
            jsonEncode(<String, String>{
              'userId': _userId,
              'stockCode': '119830',
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


  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: Column(children: [
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Half yearly sales analysis'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Sales',
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true))
              ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              //Initialize the spark charts widget
              child: SfSparkLineChart.custom(
                //Enable the trackball
                trackball: const SparkChartTrackball(
                    activationMode: SparkChartActivationMode.tap),
                //Enable marker
                marker: const SparkChartMarker(
                    displayMode: SparkChartMarkerDisplayMode.all),
                //Enable data label
                labelDisplayMode: SparkChartLabelDisplayMode.all,
                xValueMapper: (int index) => data[index].year,
                yValueMapper: (int index) => data[index].sales,
                dataCount: 5,
              ),
            ),
          )
        ]));
  }


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
            left: 20,
            right: 55,
          },
          toolbox: {
              feature: {
                  restore: {
                    title: 'restore'
                  },
              }
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
              boundaryGap: [0, '20%'],
          },
          dataZoom: [
          {
              type: 'inside',
              start: 80,
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


  void requestToday04() {
    _fetchPosts(TR.TODAY04, jsonEncode(<String, String> {
      'userId': _userId,
    }));
  }

  void requestSIGNAL09() {
    _fetchPosts(TR.SIGNAL09, jsonEncode(<String, String> {
      'userId': _userId,
    }));
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
                  child: const Icon(Icons.close, color: Colors.black,),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 5.0,),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text('안내', style: TStyle.commonTitle,),
                  ),
                  const SizedBox(height: 25.0,),
                  const Text(RString.err_network, textAlign: TextAlign.center,),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text('확인', style: TStyle.btnTextWht16,),),
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(EChartPage.TAG, '$trStr $json');

    // note 땡정보 테스트를 위한 설정
    // var url = Uri.parse(Net.TR_BASE_android + trStr); //NOTE ***[TEST]***
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(EChartPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(EChartPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(EChartPage.TAG, response.body);

    if(trStr == TR.SIGNAL08) {
      final TrSignal08 resData = TrSignal08.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        final Signal08 mData = resData.retData;
        List<ChartData> chartData = mData.listChart;

        String tmpDate = '[';
        String tmpData = '[';
        for(int i=0; i < chartData.length; i++) {
          tmpDate = '$tmpDate\'${TStyle.getDateDivFormat(chartData[i].tradeDate)}\',';

          //0:없음, 1:매수, 2:매도
          if(chartData[i].flag == null || chartData[i].flag == '') {
            tmpData = '$tmpData{value: ${chartData[i].tradePrc},symbol: \'none\'},';
          }
          else if(chartData[i].flag == 'B') {
            tmpData = '$tmpData{value: ${chartData[i].tradePrc},'
                'symbol: $upArrow, symbolOffset: [0,15],itemStyle: {color:\'red\'}},';
          }
          else if(chartData[i].flag == 'S') {
            tmpData = '$tmpData{value: ${chartData[i].tradePrc},'
                'symbol: $downArrow, symbolOffset: [0,-15],itemStyle: {color:\'blue\'}},';
                // 'symbol: \'arrow\', symbolRotate: 180, itemStyle: {color:\'blue\'}},';
          }
        }
        tmpDate = '$tmpDate]';
        tmpData = '$tmpData]';
        _dateStr = tmpDate;
        _dataStr = tmpData;
        DLog.d(EChartPage.TAG, _dataStr);

        setState(() {});
      }


      requestToday04();
    }
    else if(trStr == TR.TODAY04) {

      // requestSIGNAL09();

      _fetchPosts(TR.RASSI15, jsonEncode(<String, String>{
        'userId': _userId,
        'selectDiv': 'ALL',
      }));
    }
  }

}


class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}