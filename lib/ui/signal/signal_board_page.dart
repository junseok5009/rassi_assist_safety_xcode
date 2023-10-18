import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal03.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal04.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/signal/signal_hold_stock.dart';
import 'package:rassi_assist/ui/signal/signal_today_page.dart';
import 'package:rassi_assist/ui/signal/signal_wait_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pay/pay_premium_aos_page.dart';


/// 2021.02.17
/// 매매신호 종합분석 보드
class SignalBoardPage extends StatelessWidget {
  static const routeName = '/page_signal_board';
  static const String TAG = "[SignalBoardPage]";
  static const String TAG_NAME = '매매신호_종합보드';

  const SignalBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const SignalBoardWidget(),
      ),
    );
  }
}

class SignalBoardWidget extends StatefulWidget {
  const SignalBoardWidget({super.key});

  @override
  State<StatefulWidget> createState() => SignalBoardState();
}

class SignalBoardState extends State<SignalBoardWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true;     //true: 아직 화면이 사라지기 전

  String sCntBuy = "";
  String sCntSell = "";
  String sCntHold = "";
  String sCntWatch = "";
  final cirSize = 70.0;
  String _sUpdateTime = '업데이트';

  String _curProd = '';       //상품코드
  String _dataKospi = '[]';
  String _dataKosdaq = '[]';
  String _cntKospi = '0';
  String _cntKosdaq = '0';

  bool _bSelectA = true, _bSelectB = false;
  bool _bSelect_1 = true, _bSelect_3 = false, _bSelect_6 = false, _bSelect_12 = false;
  String _curBsType = 'B';
  String _curPeriod = '1';
  String _mixDate = '[]';
  String _mixSignal = '[]';
  String _mixIndex = '[]';
  String _indexMin = '2000';
  String _indexMax = '3500';
  String _sigBarColor = 'colors[0]';


  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: SignalBoardPage.TAG_NAME,
      screenClassOverride: SignalBoardPage.TAG_NAME,);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 500), (){
      DLog.d(SignalBoardPage.TAG, "delayed user id : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.SIGNAL03, jsonEncode(<String, String>{
          'userId': _userId,
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
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _curProd = args.pgData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('매매신호 종합보드', style: TStyle.defaultTitle,),
        automaticallyImplyLeading: false,
        backgroundColor: RColor.bgMintWeak,
        shadowColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(null),),
          const SizedBox(width: 10.0,),
        ],
      ),

      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              color: RColor.bgMintWeak,
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Text(_sUpdateTime, style: TStyle.contentGrey14,),
            ),

            Container(
              padding: const EdgeInsets.all(15.0),
              color: RColor.bgMintWeak,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _setCircleText(sCntBuy, RColor.sigBuy, '매수'),
                      _setCircleText(sCntSell, RColor.sigSell, '매도'),
                      _setCircleText(sCntHold, RColor.bgHolding, '보유'),
                      _setCircleText(sCntWatch, RColor.sigWatching, '관망'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25.0,),

            //코스피 vs 코스닥 종목의 포지션 비교
            _setPiePart(),
            const SizedBox(height: 25.0,),

            SizedBox(height: 15.0,
                child: Container(color: RColor.bgWeakGrey,)),
            const SizedBox(height: 25.0,),

            //AI 매매신호 발생 추이와 코스피 지수 비교
            _setMixedPart(),
            const SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }

  Widget _setCircleText(String cnt, Color color, String label) {
    return Column(
      children: [
        InkWell(
          child: Container(
            width: cirSize,
            height: cirSize,
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(cnt, style: TStyle.btnTextWht17,),
            ),
          ),
          onTap: (){
            if(label == '매수') {
              if(_curProd.contains('ac_pr')) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SignalTodayPage(),
                  settings: RouteSettings(arguments: PgData(userId: '', flag: 'B', pgData: cnt),),
                ));
              } else {
                _showDialogPremium();     //프리미엄 가입하기
              }
            }
            if(label == '매도') {
              if(_curProd.contains('ac_pr')) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SignalTodayPage(),
                  settings: RouteSettings(arguments: PgData(userId: '', flag: 'S', pgData: cnt),),
                ));
              } else {
                _showDialogPremium();     //프리미엄 가입하기
              }
            }
            if(label == '보유') {
              if(_curProd.contains('ac_pr')) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SignalHoldPage(),
                ));
              } else {
                _showDialogPremium();     //프리미엄 가입하기
              }
            }
            if(label == '관망') {
              if(_curProd.contains('ac_pr')) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SignalWaitPage(),
                ));
              } else {
                _showDialogPremium();     //프리미엄 가입하기
              }
            }
          },
        ),
        Text(label, style: TStyle.content16,),
      ],
    );
  }

  Widget _setPiePart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('코스피 vs 코스닥 종목의 포지션 비교',
                style: TStyle.defaultTitle,),
              InkWell(
                child: const ImageIcon(AssetImage('images/rassi_icon_qu_bl.png',),
                  size: 22, color: Colors.grey,),
                onTap: (){
                  _showDialogDesc(RString.desc_signal_position);
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 10,),

        Row(
          children: [
            Expanded(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(5),
                // color: Colors.grey[200],
                child: Stack(
                  children: [
                    _setPieChart(_dataKospi),
                    _setPieText('코스피', _cntKospi),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(5),
                // color: Colors.grey[200],
                child: Stack(
                  children: [
                    _setPieChart(_dataKosdaq),
                    _setPieText('코스닥', _cntKosdaq),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _setPieText(String mkText, String mkCount) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(mkText, style: TStyle.content17,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mkCount),
              const Text('종목'),
            ],
          ),
          const SizedBox(height: 7,),
        ],
      ),
    );
  }

  Widget _setPieChart(String sData) {
    return Echarts(
      captureAllGestures: false,
      reloadAfterInit: true,
      extraScript: '''
          var colorPalette = ['#FC525B','#2fccaf','#6A86E7','#7d81a0'];
        ''',
      option: '''
        option = {
          series: [
            {
              name: 'chart Name',
              type: 'pie',
              radius: ['45%', '85%'],
              avoidLabelOverlap: false,
              color: colorPalette,
              
              // itemStyle: {
              //   borderRadius: 2,
              //   borderColor: '#fff',
              //   borderWidth: 0.8,
              // },
              
              label: {
                  normal: {
                      show: true,
                      position: 'inside',
                      formatter: '{b}\\n{c}',
                      //formatter: '{d}%',
                      
                      textStyle : {             
                        align : 'center',
                        baseline : 'middle',
                        fontSize : 12,
                        //fontFamily : 'Microsoft Yahei',
                        fontWeight : 'bolder'
                      }
                  },
              },
              labelLine: {
                  show: false,
              },
              data: $sData,
            }
          ]
        }
      ''',
    );
  }

  Widget _setMixedPart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI매매신호 발생 추이와 코스피 지수 비교', style: TStyle.defaultTitle,),
              InkWell(
                child: const ImageIcon(AssetImage('images/rassi_icon_qu_bl.png',),
                  size: 22,
                  color: Colors.grey,),
                onTap: (){
                  _showDialogDesc(RString.desc_signal_compare);
                },
              )
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 27.0),
                width: double.infinity,
                height: 480,
                decoration: UIStyle.boxRoundLine10c(RColor.lineGrey),
                child: Column(
                  children: [
                    const SizedBox(height: 35,),
                    //기간별 매매신호 발생건수
                    _setCirclePeriod(),
                    const SizedBox(height: 5,),

                    Container(
                      width: double.infinity,
                      height: 350,
                      padding: const EdgeInsets.all(5),
                      child: _setMixedChart(),
                    ),
                  ],
                ),
              ),

              _setBtnBuySell(),
            ],
          ),
        ),

      ],
    );
  }

  //매수/매도 선택
  Widget _setBtnBuySell() {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelectA ? UIStyle.boxBtnSelectedBuy() : UIStyle.boxRoundLine20(),
                    child: Center(
                      child: Text('매수신호 vs 코스피',
                        style: _bSelectA ? TStyle.btnTextWht15 : TStyle.commonTitle15,),
                    ),
                  ),
                  onTap: (){
                    if(_bSelectB) {
                      setState(() {
                        _bSelectA = true;
                        _bSelectB = false;
                        _curBsType = 'B';
                        _sigBarColor = 'colors[0]';
                      });
                      _requestSignal04(_curBsType, _curPeriod);
                    }
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelectB ? UIStyle.boxBtnSelectedSell() : UIStyle.boxRoundLine20(),
                    child: Center(
                      child: Text('매도신호 vs 코스피',
                        style: _bSelectB ? TStyle.btnTextWht15 : TStyle.commonTitle15,),
                    ),
                  ),
                  onTap: (){
                    if(_bSelectA) {
                      setState(() {
                        _bSelectA = false;
                        _bSelectB = true;
                        _curBsType = 'S';
                        _sigBarColor = 'colors[2]';
                      });
                      _requestSignal04(_curBsType, _curPeriod);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setCirclePeriod() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
            decoration: _bSelect_1 ? UIStyle.circleBtnSelected() : UIStyle.circleBtnDefault(),
            child: const Center(
              child: Text('1개월', style: TStyle.content15,),
            ),
          ),
          onTap: (){
            setState(() {
              _bSelect_1 = true;
              _bSelect_3 = false;
              _bSelect_6 = false;
              _bSelect_12 = false;
              _curPeriod = '1';
            });
            _requestSignal04(_curBsType, _curPeriod);
          },
        ),
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
            decoration: _bSelect_3 ? UIStyle.circleBtnSelected() : UIStyle.circleBtnDefault(),
            child: const Center(
              child: Text('3개월', style: TStyle.content15,),
            ),
          ),
          onTap: (){
            setState(() {
              _bSelect_1 = false;
              _bSelect_3 = true;
              _bSelect_6 = false;
              _bSelect_12 = false;
              _curPeriod = '3';
            });
            _requestSignal04(_curBsType, _curPeriod);
          },
        ),
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
            decoration: _bSelect_6 ? UIStyle.circleBtnSelected() : UIStyle.circleBtnDefault(),
            child: const Center(
              child: Text('6개월', style: TStyle.content15,),
            ),
          ),
          onTap: (){
            setState(() {
              _bSelect_1 = false;
              _bSelect_3 = false;
              _bSelect_6 = true;
              _bSelect_12 = false;
              _curPeriod = '6';
            });
            _requestSignal04(_curBsType, _curPeriod);
          },
        ),
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
            decoration: _bSelect_12 ? UIStyle.circleBtnSelected() : UIStyle.circleBtnDefault(),
            child: const Center(
              child: Text('12개월', style: TStyle.content15,),
            ),
          ),
          onTap: (){
            setState(() {
              _bSelect_1 = false;
              _bSelect_3 = false;
              _bSelect_6 = false;
              _bSelect_12 = true;
              _curPeriod = '12';
            });
            _requestSignal04(_curBsType, _curPeriod);
          },
        ),
      ],
    );
  }

  Widget _setMixedChart() {
    return Echarts(
      captureHorizontalGestures: true,
      reloadAfterInit: true,
      extraScript: '''
          var colors = ['#FC525B','#2fccaf','#6A86E7'];
        ''',
      option: '''
        option = {
          color: colors,
      
          tooltip: {
              trigger: 'axis',
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
                  handleSize: '70%',
                  handleStyle: {
                      color: '#fff',
                      shadowBlur: 3,
                      shadowColor: 'rgba(0, 0, 0, 0.6)',
                      shadowOffsetX: 2,
                      shadowOffsetY: 2
                  }
              }
          ],
          legend: {
              data: ['매매신호', '코스피']
          },
          xAxis: [
              {
                  type: 'category',
                  axisTick: {
                      alignWithLabel: true
                  },
                  data: $_mixDate,
              }
          ],
          yAxis: [
              {
                  name: '매매신호',
                  type: 'value',
                  min: 0,
                  max: 230,
                  position: 'right',
                  axisLine: {
                      show: true,
                      lineStyle: {
                          color: $_sigBarColor
                      }
                  },
                  axisLabel: {
                      formatter: '{value}'
                  }
              },
              {
                  name: '코스피',
                  type: 'value',
                  min: $_indexMin,
                  max: $_indexMax,
                  position: 'left',
                  axisLine: {
                      show: true,
                      lineStyle: {
                          color: colors[1]
                      }
                  },
                  axisLabel: {
                      formatter: '{value}'
                  }
              }
          ],
          series: [
              {
                  name: '매매신호',
                  type: 'bar',
                  color: $_sigBarColor,
                  yAxisIndex: 0,
                  data: $_mixSignal,
              },
              {
                  name: '코스피',
                  type: 'line',
                  color: colors[1],
                  yAxisIndex: 1,
                  data: $_mixIndex,
              }
          ]
        }
      ''',
    );
  }

  //안내 다이얼로그
  void _showDialogDesc(String desc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
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
                const SizedBox(height: 25.0,),
                const Text('안내', style: TStyle.title20, textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                const SizedBox(height: 30.0,),
                Text(desc, style: TStyle.defaultContent,
                  textAlign: TextAlign.center, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                const SizedBox(height: 30.0,),
              ],
            ),
          ),
        );
      },
    );
  }

  //프리미엄 가입하기 다이얼로그
  void _showDialogPremium() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),),
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
                const SizedBox(height: 25.0,),
                const Text('안내', style: TStyle.title20, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                const SizedBox(height: 30.0,),

                const Text('매매비서 프리미엄에서 이용할 수 있는 정보입니다.',
                  textAlign: TextAlign.center, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                const SizedBox(height: 25.0,),
                const Text('프리미엄으로 업그레이드 하시고 더 완벽하게 이용해 보세요.',
                  textAlign: TextAlign.center, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                const SizedBox(height: 25.0,),

                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.deepBlue,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Center(
                        child: Text('프리미엄 가입하기', style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,),),
                    ),
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                    _navigateRefreshPay(context,
                      Platform.isIOS
                          ? PayPremiumPage()
                          : PayPremiumAosPage(),);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if(result == 'cancel') {
      DLog.d(SignalBoardPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SignalBoardPage.TAG, '*** navigateRefresh');
      _fetchPosts(TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //페이지 전환 에니메이션
  Route _createRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,);
      },
    );
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
                    child: Text('안내', style: TStyle.commonTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  ),
                  const SizedBox(height: 25.0,),
                  const Text(RString.err_network, textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text('확인', style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,),),
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


  void _requestSignal04(String bsType, String period) {
    _fetchPosts(TR.SIGNAL04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'marketType': '1',        //1:KOSPI, 2:KOSDAQ
          'tradeFlag': bsType,      //B:매수, S:매도
          'periodMonth': period,
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SignalBoardPage.TAG, trStr + ' ' +json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(SignalBoardPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(SignalBoardPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalBoardPage.TAG, response.body);

    if(trStr == TR.SIGNAL03) {
      final TrSignal03 resData = TrSignal03.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        Signal03? item = resData.retData;
        if(item != null) {
          String upTime = item.kospi.tradeDate + item.kospi.tradeTime;
          _sUpdateTime = '${TStyle.getDateTdFormat(upTime)} 업데이트';

          //값이 0 일 경우 디폴트값을 0 으로 파싱하는지 확인
          String kspBuy = item.kospi.buyCount;
          String kspSell = item.kospi.sellCount;
          String kspHold = item.kospi.holdCount;
          String kspWait = item.kospi.waitCount;
          String ksdBuy = item.kosdaq.buyCount;
          String ksdSell = item.kosdaq.sellCount;
          String ksdHold = item.kosdaq.holdCount;
          String ksdWait = item.kosdaq.waitCount;

          int bCnt = int.parse(item.kospi.buyCount) + int.parse(item.kosdaq.buyCount);
          int sCnt = int.parse(item.kospi.sellCount) + int.parse(item.kosdaq.sellCount);
          int hCnt = int.parse(item.kospi.holdCount) + int.parse(item.kosdaq.holdCount);
          int wCnt = int.parse(item.kospi.waitCount) + int.parse(item.kosdaq.waitCount);
          sCntBuy = bCnt.toString();
          sCntSell = sCnt.toString();
          sCntHold = hCnt.toString();
          sCntWatch = wCnt.toString();

          // String nameKspBuy = '\'매수\\n\'';   //따움표 안에서 \n 을 나타내려면 \\로 역슬래시 표현
          _dataKospi = '['
              + '{value:' + kspBuy + ', name: \'매수\'},'
              + '{value:' + kspHold + ', name: \'보유\'},'
              + '{value:' + kspSell + ', name: \'매도\'},'
              + '{value:' + kspWait + ', name: \'관망\'},' + ']';
          _dataKosdaq = '['
              + '{value:' + ksdBuy + ', name: \'매수\'},'
              + '{value:' + ksdHold + ', name: \'보유\'},'
              + '{value:' + ksdSell + ', name: \'매도\'},'
              + '{value:' + ksdWait + ', name: \'관망\'},' + ']';
          _cntKospi = item.kospi.totalCount;
          _cntKosdaq = item.kosdaq.totalCount;

          setState(() {});
        }
      }

      _fetchPosts(TR.SIGNAL04,
          jsonEncode(<String, String>{
            'userId': _userId,
            'marketType': '1',          //1:KOSPI, 2:KOSDAQ
            'tradeFlag': _curBsType,    //B:매수, S:매도
            'periodMonth': _curPeriod,
          }));
    }

    //매매신호와 시장지수 비교
    else if(trStr == TR.SIGNAL04) {
      final TrSignal04 resData = TrSignal04.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        Signal04? item = resData.retData;
        if(item != null) {
          var idxHigh = double.parse(item.indexHigh);
          var idxLow = double.parse(item.indexLow);
          var iMax = (idxHigh * 1.1).toInt();   // 10% 위로 범위
          var iMin = (idxLow * 0.8).toInt();    // 20% 아래로 범위
          DLog.d(SignalBoardPage.TAG, 'max:min = $iMax:$iMin');
          _indexMax = iMax.toString();
          _indexMin = iMin.toString();

          String tmpDate = '[';
          String tmpSig = '[';
          String tmpIdx = '[';
          List<SigGenData> chartData = item.listChart;
          for(int i=0; i < chartData.length; i++) {
            tmpDate = '$tmpDate\'${TStyle.getDateDivFormat(chartData[i].date)}\',';
            tmpSig = '$tmpSig${chartData[i].count},';
            tmpIdx = '$tmpIdx${chartData[i].index},';
          }
          _mixDate = '$tmpDate]';
          _mixSignal = '$tmpSig]';
          _mixIndex = '$tmpIdx]';

          setState(() {});
        }
      }
    }
  }
}

