import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_function_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/chart_theme.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_chart.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme04n.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme05.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme06.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2022.04.22 - JY
/// (핫)테마 상세보기
class ThemeHotViewer extends StatefulWidget {
  static const routeName = '/page_theme_viewer';
  static const String TAG = "[ThemeHotViewer] ";
  static const String TAG_NAME = '테마_상세보기';

  const ThemeHotViewer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeHotViewerState();
}

class ThemeHotViewerState extends State<ThemeHotViewer> {
  final GlobalKey _containerKey = GlobalKey();
  late SharedPreferences _prefs;
  String _userId = "";

  bool _initFirst = true;
  String _themeCode = '';
  String _themeName = '';
  String _themeStatus = '';
  bool _isBearTheme = false;
  String _themeDays = ''; //강세/약세 00일째
  String _selDiv = '';
  String _increseRate = '';
  String _themeDesc = '';
  bool _bSelectA = true;
  bool _bSelectB = false;

  String _dateStr = '[]';
  String _dataStr = '[]';
  bool _bSelect1M = false, _bSelect6M = false, _bSelect12M = true;

  final List<StockChart> _stockList = [];
  final List<TopCard> _tcList = [];
  final List<ThemeStHistory> _thList = [];

  double _themeInfoTextWidgetHeight = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      ThemeHotViewer.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
        _themeCode = args.pgSn;
        if (_themeCode == null || _themeCode.isEmpty) {
          Navigator.pop(context);
        }
        if (_userId != '') {
          _fetchPosts(
              TR.THEME04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'themeCode': _themeCode,
                'periodMonth': '12',
              }));
        }
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        double getWidgetHeight =
            CommonFunctionClass.instance.getSize(_containerKey).height;
        if (getWidgetHeight != _themeInfoTextWidgetHeight) {
          _themeInfoTextWidgetHeight = getWidgetHeight;
          super.setState(() {});
        }
      });
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 테마명, 전일대비, 테마설명
              _setHeaderInfo(),
              SizedBox(
                height: _themeInfoTextWidgetHeight / 2 + 30,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const ImageIcon(
                      AssetImage(
                        'images/rassi_icon_qu_bl.png',
                      ),
                      size: 22,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _showDialogDesc(RString.desc_hot_theme_index_pop);
                    },
                  ),
                ),
              ),

              //AI테마분석 (THEME04 강세 / 약세)
              _setThemeStatus(),
              SizedBox(
                  height: 10.0,
                  child: Container(
                    color: RColor.bgWeakGrey,
                  )),

              //테마 지수 차트 (THEME04)
              _setSubTitle(
                '테마 차트',
              ),
              // const SizedBox(height: 10.0,),
              SizedBox(
                width: double.infinity,
                height: 250,
                child: _setEChartView(),
              ),
              _setSelectTabChart(),
              const SizedBox(
                height: 10.0,
              ),

              //현재 테마주도주 (THEME05)
              _setSubTitle(
                '현재 테마주도주',
              ),
              const SizedBox(
                height: 20,
              ),
              _setSelectThemeTypeTab(),

              _isBearTheme
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: CommonView.setNoDataView(
                        150,
                        '테마 추세가 현재 약세일 경우\n주도주가 분석되지 않습니다.',
                      ),
                    )
                  : ListView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _stockList.length,
                      itemBuilder: (context, index) {
                        return TileTheme05(_stockList[index], _selDiv);
                      },
                    ),

              const SizedBox(
                height: 10,
              ),

              //테마주도주 히스토리 (THEME06)
              _setSubTitle(
                '테마주도주 히스토리',
              ),
              _tcList.isEmpty
                  ? const SizedBox()
                  : _setCardHistory(),

              const SizedBox(
                height: 15,
              ),

              _thList.isEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: CommonView.setNoDataView(150, '히스토리 데이터가 없습니다.'),
                    )
                  : ListView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _thList.length,
                      itemBuilder: (context, index) {
                        return TileTheme06List(_thList[index]);
                      },
                    ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 테마명, 전일대비, 테마설명
  Widget _setHeaderInfo() {
    String rText;
    Color rColor;
    if (_increseRate.contains('-')) {
      rText = _increseRate;
      rColor = RColor.sigSell;
    }
    else {
      rText = '+$_increseRate';
      rColor = RColor.sigBuy;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _setThemeBackgroundImageWidget(_themeCode),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            iconSize: 24,
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(
              top: 55,
            ),
            child: Column(
              children: [
                Text(
                  '$_themeName 테마',
                  style: TStyle.btnTextWht20,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '전일대비 ',
                      style: TStyle.btnContentWht16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '$rText%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: rColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: (_themeInfoTextWidgetHeight) * -1 / 2,
          child: Container(
            key: _containerKey,
            //margin: const EdgeInsets.symmetric(horizontal: 10,),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            decoration: const BoxDecoration(
              //color: RColor.mainColor,
              //color: Color(0xffe9e9ec),
              color: RColor.mainColor,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Text(
              _themeDesc,
              /*style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),*/
              style: TStyle.btnTextWht13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _setThemeBackgroundImageWidget(String tCode) {
    if (tCode.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        height: 200,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.6), // 어두운 색 및 투명도 값 (0.0 ~ 1.0)
          BlendMode.srcATop, // 혼합 모드
        ),
        child: CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl:
              'http://files.thinkpool.com/rassi_signal/theme_images/$tCode.jpg',
          errorWidget: (context, url, error) => CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: RString.themeDefaultUrl,
            errorWidget: (context, url, error) => Container(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  //테마 상태 (강세 / 약세)
  Widget _setThemeStatus() {
    bool isBull = true;
    String status = '';
    String statusSub = '';
    if (_themeStatus == 'BULL') {
      isBull = true;
      status = '강세';
      statusSub = '추세';
    } else if (_themeStatus == 'Bullish') {
      isBull = true;
      status = '강세';
      statusSub = '추세';
    } else if (_themeStatus == 'BEAR') {
      isBull = false;
      status = '약세';
      statusSub = '추세';
    } else if (_themeStatus == 'Bearish') {
      isBull = false;
      status = '약세';
      statusSub = '전환';
    }

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'images/icon_rassi_logo_purple.png',
                      fit: BoxFit.cover,
                      height: 50,
                      color: RColor.mainColor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    const Text(
                      '라씨 매매비서가 분석한\n현재 테마 상태는?',
                      style: TStyle.title18,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: isBull ? RColor.bgBuy : RColor.bgSell,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' $statusSub',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          _themeDays,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 19,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          '일째',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
      onTap: () => _showDialogDesc(RString.desc_hot_theme_index_pop),
    );
  }

  //현재 테마주도주
  Widget _setSelectThemeTypeTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelectA
                        ? UIStyle.boxBtnSelectedSell()
                        : UIStyle.boxRoundLine20(),
                    child: Center(
                      child: Text(
                        '단기 강세 TOP 3',
                        style: _bSelectA
                            ? TStyle.btnTextWht15
                            : TStyle.commonTitle15,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (_bSelectB) {
                      setState(() {
                        _bSelectA = true;
                        _bSelectB = false;
                        _stockList.clear();
                      });
                      _requestTheme05('SHORT');
                    }
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelectB
                        ? UIStyle.boxBtnSelectedSell()
                        : UIStyle.boxRoundLine20(),
                    child: Center(
                      child: Text(
                        '추세주도주',
                        style: _bSelectB
                            ? TStyle.btnTextWht15
                            : TStyle.commonTitle15,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (_bSelectA) {
                      setState(() {
                        _bSelectA = false;
                        _bSelectB = true;
                        _stockList.clear();
                      });
                      DLog.d(ThemeHotViewer.TAG, '추세주도주');
                      _requestTheme05('TREND');
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),

          //테마주도주 설명 텍스트
          Visibility(
            visible: _bSelectA,
            child: const Text(
              RString.desc_theme_stock_short,
              style: TStyle.textGrey15,
              textAlign: TextAlign.left,
            ),
          ),
          Visibility(
            visible: _bSelectB,
            child: const Text(
              RString.desc_theme_stock_trend,
              style: TStyle.textGrey15,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  //테마주도주 히스토리 (THEME06)
  Widget _setCardHistory() {
    return SizedBox(
      width: double.infinity,
      height: 210,
      child: Swiper(
        controller: SwiperController(),
        pagination:
            _tcList.length < 2 ? null : CommonSwiperPagenation.getNormalSP(9.0),
        itemCount: _tcList.length,
        itemBuilder: (BuildContext context, int index) {
          return TileTheme06(_tcList[index]);
        },
      ),
    );
  }

  //차트 테마지수
  Widget _setEChartView() {
    return Echarts(
      captureHorizontalGestures: true,
      reloadAfterInit: true,
      extraScript: '''
          var date = [];
          var data = [];
        ''',
      option: '''
        {
          grid: {
            // backgroundColor: 'transparent',
            backgroundColor: 'rgba(125,125,125,0.1)',
            top: 15,
            left: 5,
            right: 5,
            bottom: 20,
            show: true,
          },
          xAxis: {
              show: false,
              type: 'category',
              boundaryGap: ['10%', '10%'],
              // boundaryGap: false,
              data: $_dateStr,
          },
          yAxis: {
              show: false,
              type: 'value',
              position: 'right',
              scale: true,
              boundaryGap: [0, '5%'],
              splitLine: {
                  show: false,
              },
          },
          tooltip: {
              trigger: 'axis',
          },
          dataZoom: [
          {
              type: 'inside',
              start: 0,
              end: 100,
          }, 
          ],
          series: [
              {
                name: '테마지수',
                type: 'line',
                smooth: true,
                stack: 'a',
                symbol: 'circle',
                symbolSize: 5,
                sampling: 'average',
                itemStyle: {
                  color: '#68cc54',
                },
                areaStyle: {
                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                    {
                      offset: 0,
                      color: 'rgba(104,204,84,0.8)',
                    },
                    {
                      offset: 1,
                      color: 'rgba(104,204,84,0.0)',
                    },
                  ])
                },
                data: $_dataStr,
              }
             
          ]
        }
      ''',
    );
  }

  //차트 선택 탭바
  Widget _setSelectTabChart() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelect1M
                        ? UIStyle.boxBtnSelectedTab()
                        : const BoxDecoration(),
                    child: const Center(
                      child: Text(
                        '1개월',
                        style: TStyle.textGrey18,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (!_bSelect1M) {
                      setState(() {
                        _bSelect1M = true;
                        _bSelect6M = false;
                        _bSelect12M = false;
                      });
                      _requestTheme04('1');
                    }
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelect6M
                        ? UIStyle.boxBtnSelectedTab()
                        : const BoxDecoration(),
                    child: const Center(
                      child: Text(
                        '6개월',
                        style: TStyle.textGrey18,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (!_bSelect6M) {
                      setState(() {
                        _bSelect1M = false;
                        _bSelect6M = true;
                        _bSelect12M = false;
                      });
                      _requestTheme04('6');
                    }
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: _bSelect12M
                        ? UIStyle.boxBtnSelectedTab()
                        : const BoxDecoration(),
                    child: const Center(
                      child: Text(
                        '1년',
                        style: TStyle.textGrey18,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (!_bSelect12M) {
                      setState(() {
                        _bSelect1M = false;
                        _bSelect6M = false;
                        _bSelect12M = true;
                      });
                      _requestTheme04('12');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            subTitle,
            style: TStyle.defaultTitle,
          ),
        ],
      ),
    );
  }

  //페이지 전환 에니메이션
  Route _createRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(ThemeHotViewer.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(ThemeHotViewer.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.USER04,
      //     jsonEncode(<String, String>{
      //       'userId': _userId,
      //     }));
    }
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
                  height: 25.0,
                ),
                const Text(
                  '안내',
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  desc,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestTheme04(String period) {
    _fetchPosts(
        TR.THEME04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'themeCode': _themeCode,
          'periodMonth': period,
        }));
  }

  void _requestTheme05(String type) {
    _fetchPosts(
        TR.THEME05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'themeCode': _themeCode,
          'selectDiv': type, //SHORT: 단기강세TOP3, TREND: 추세주도주
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
    DLog.d(ThemeHotViewer.TAG, '$trStr $json');

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
      DLog.d(ThemeHotViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(ThemeHotViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeHotViewer.TAG, response.body);

    if (trStr == TR.THEME04) {
      final TrTheme04N resData = TrTheme04N.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        DLog.d(ThemeHotViewer.TAG, resData.retData.themeObj.toString());

        ThemeStu item = resData.retData.themeObj;
        _themeName = item.themeName;
        _themeDays = item.elapsedDays;
        _themeStatus = item.themeStatus;
        _increseRate = item.increaseRate;
        _themeDesc = item.themeDesc;
        if (_themeStatus == 'BULL' || _themeStatus == 'Bullish') {
          _isBearTheme = false;
        } else if (_themeStatus == 'BEAR' || _themeStatus == 'Bearish') {
          _isBearTheme = true;
        }

        List<ChartTheme> chartData = resData.retData.listChart;
        _setChartData(chartData);
        setState(() {});
      }

      if (_initFirst) {
        _fetchPosts(
            TR.THEME05,
            jsonEncode(<String, String>{
              'userId': _userId,
              'themeCode': _themeCode,
              'selectDiv': 'SHORT', //SHORT: 단기강세TOP3, TREND: 추세주도주
            }));
      }
    }

    //현재 테마 주도주
    else if (trStr == TR.THEME05) {
      final TrTheme05 resData = TrTheme05.fromJson(jsonDecode(response.body));
      _stockList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _stockList.addAll(resData.retData.listStock);
        _selDiv = resData.retData.selectDiv;
      }
      setState(() {});

      if (_initFirst) {
        _initFirst = false;
        _fetchPosts(
            TR.THEME06,
            jsonEncode(<String, String>{
              'userId': _userId,
              'themeCode': _themeCode,
              'topStockYn': 'Y',
              'pageNo': '0',
              'pageItemSize': '5',
            }));
      }
    }
    //테마주도주 히스토리
    else if (trStr == TR.THEME06) {
      final TrTheme06 resData = TrTheme06.fromJson(jsonDecode(response.body));
      _tcList.clear();
      _thList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _tcList.addAll(resData.retData.listCard);
        _thList.addAll(resData.retData.listTimeline);
      }
      setState(() {});
    }
  }

  //테마지수 차트 데이터
  void _setChartData(List<ChartTheme> chartData) {
    String tmpDate = '[';
    String tmpData = '[';
    for (int i = 0; i < chartData.length; i++) {
      tmpDate = '$tmpDate\'${chartData[i].tradeDate}\',';
      // tmpDate = tmpDate + '\'${TStyle.getDateDivFormat(chartData[i].tradeDate)}\',';

      tmpData = '$tmpData{value: ${chartData[i].tradeIndex},symbol: \'none\'},';
    }
    tmpDate = '$tmpDate]';
    tmpData = '$tmpData]';
    _dateStr = tmpDate;
    _dataStr = tmpData;
    DLog.d(ThemeHotViewer.TAG, _dataStr);
  }
}
