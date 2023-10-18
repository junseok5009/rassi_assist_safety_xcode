import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock05.dart';
import 'package:rassi_assist/models/tr_search/tr_search01.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal01.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal02.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal08.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_popup.dart';
import '../login/login_division_page.dart';

/// 2021.01.21
/// --- 수정 기록 ---
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// 로그인 전 종목 검색
class TradeIntroPage extends StatefulWidget {
  static const routeName = '/page_trade_intro';
  static const String TAG = "[TradeIntroPage]";
  static const String TAG_NAME = '인트로_매매신호_상세';
  const TradeIntroPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => TradeIntroPageState();
}

class TradeIntroPageState extends State<TradeIntroPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String stkName = "";
  String stkCode = "";
  String prePrc = ""; //매수가 or 매도가
  String stkPrc = "";
  String stkProfit = ""; //수익률
  String holdDays = ""; //보유중 0일째 (매도 전 보유기간)
  String holdPeriod = ""; //지난 거래 전 보유기간
  String dateTime = "";
  String statTxt = "";
  bool _hasSignal = true; //매매신호 발생한 내역이 있음

  String _dateStr = '[]';
  String _dataStr = '[]';
  final String upArrow = '\'path://M16 1l-15 15h9v16h12v-16h9z\'';
  final String downArrow = '\'path://M16 31l15-15h-9v-16h-12v16h-9z\'';

  bool isMyPkt = false; //즐겨찾기 Y/N
  String stkPktSn = ''; //종목이 등록된 포켓Sn
  String pktWillSn = ''; //등록될 포켓 Sn

  bool bOffHoldDays = false; //보유일 표시
  bool isTodayTrade = false; //당일매매 표시
  bool isTodayBuy = false; //당일매수
  bool isTodayTag = false; //Today 매수/매도
  bool isHoldingStk = false; //보유중
  String imgTodayTag = 'images/main_icon_today_buy.png';
  Color statColor = Colors.grey; //신호 분류에 따른 컬러(보유중, 관망중...)
  Color profitColor = Colors.grey; //수익률 컬러

  //투자수익은?
  String beginYear = "";
  String invAmt = "";
  String balAmt = "";

  List<SignalAnal> _acvList = []; //AI 매매신호 성과
  bool _hasSellResults = true; //매매신호(매도) 성과 표시여부
  List<String> _searchList = []; //무료 5종목 검색

  // DEFINE 신호 노출 제한 종목
  bool _isSignalTargetYn = true;

  // DEFINE 매매신호 한번도 발생안한 경우 > true면 아직 한번도 매매신호가 발생한적이 없음 (신규상장..등)
  bool _isSignalIssueYn = false;

  // DEFINE 매매금지 종목 여부 Y + 관망중인 상태 > 매수신호가 발생되지 않습니다.. 체크 여부
  bool _isForbiddenShow = false;
  String _forbiddenDesc = '';

  final List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: TradeIntroPage.TAG_NAME,
      screenClassOverride: TradeIntroPage.TAG_NAME,
    );

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fetchPosts(
          TR.SIGNAL01,
          jsonEncode(<String, String>{
            'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
            'stockCode': stkCode,
          }));
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';

      //무료 5종목 체크
      _searchList = _prefs.getStringList(TStyle.getTodayString()) ?? [];

      if (stkCode != null && stkCode.isNotEmpty) {
        if (_searchList.length < 5) {
          if (!_containListData(_searchList, stkCode)) {
            //새로운 종목코드를 가지고 있지 않다면 저장
            _searchList.add(stkCode);
            _prefs.setStringList(TStyle.getTodayString(), _searchList);
          }
        }
        DLog.d(TradeIntroPage.TAG, _searchList.toString());
      }
    });
  }

  //리스트에서 해당 종목코드 있는지
  bool _containListData(List<String> sList, String newStr) {
    if (sList != null && sList.isNotEmpty) {
      for (int i = 0; i < sList.length; i++) {
        if (sList[i] == newStr) return true;
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    stkName = args.stockName; //TODO 글자수 제한
    stkCode = args.stockCode;
    DLog.d(TradeIntroPage.TAG, args.stockName);
    DLog.d(TradeIntroPage.TAG, args.stockCode);
    // Bottom Navigation 안에서 페이지가 열릴 경우 SafeArea 삭제

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      //상단바 - 종목명, 종목코드, 종목홈
      appBar: _setCustomAppBar(),
      body: SafeArea(
        child: ListView(
          children: [
            //카드뷰 - 매수, 매도, 보유중, 관망중,
            Stack(
              children: [
                _setStatusCard(),
                Visibility(
                  visible: isTodayTag,
                  child: Positioned(
                    top: 25,
                    right: 16,
                    child: Image.asset(
                      imgTodayTag,
                      height: 23,
                    ),
                  ),
                ),
              ],
            ),

            //카드뷰 - isIssueYn = true , 아직 한번도 매수신호 발생 한적이 없을 때, 관망 중 + 매매신호 내역이 없습니다.
            Visibility(
              visible: _isForbiddenShow,
              child: Column(
                children: [
                  TileSignal01Forbidden(stkName, _forbiddenDesc),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),

            // 매매신호 실시간 받기
            _setBtnRealtime(),
            const SizedBox(
              height: 15.0,
            ),

            // 최근 1년간 AI 매매신호 차트
            _setSubTitle(
              "최근 1년간 AI 매매신호",
            ),
            SizedBox(
              width: double.infinity,
              height: 270,
              child: _setEChartView(),
            ),

            const SizedBox(
              height: 10.0,
            ),

            // 모든 매매내역 보기
            _setBtnListAll(),
            const SizedBox(
              height: 20.0,
            ),

            Visibility(
              visible: _hasSellResults,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 투자 수익은 ?
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 170,
                        color: RColor.bgPink,
                      ),
                      _setReturnCard(),
                    ],
                  ),
                  _setSubTitle(
                    '$stkName AI매매신호 성과',
                  ),
                  _setAchievements(context),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),

            // 성과 TOP 종목
            _setTopStock(),
            // 간편하게 시작하기
            InkWell(
              child: Image.asset(
                'images/rassibs_bn_simply_start.png',
                //height: 170,
                fit: BoxFit.fitWidth,
              ),
              onTap: () {
                if (LoginDivisionPage.globalKey.currentState == null) {
                  Navigator.pushReplacementNamed(
                      context, LoginDivisionPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _setCustomAppBar() {
    return AppBar(
      toolbarHeight: 65,
      automaticallyImplyLeading: false,
      backgroundColor: RColor.deepBlue,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: RColor.deepBlue,
      ),
      elevation: 0,
      title: Row(
        children: [
          const SizedBox(
            width: 7,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TStyle.getLimitString(args.stockName, 12),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                args.stockCode,
                style: TStyle.btnSTextWht,
              ),
            ],
          ),
        ],
      ),
      actions: [
        //닫기
        InkWell(
          child: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(
          width: 15.0,
        ),
      ],
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //매수, 매도, 보유중, 관망중,
  Widget _setStatusCard() {
    if (!_isSignalTargetYn) {
      return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxSignalCard(),
        //decoration: UIStyle.boxWithOpacity(),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 80.0,
                backgroundColor: RColor.bgWeakGrey,
                child: ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(fontSize: 40, color: RColor.iconGrey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Flexible(
              flex: 1,
              child: Center(
                child: Text('AI매매신호가 발생되지\n않는 종목입니다.',
                    style: TextStyle(fontSize: 16, color: RColor.iconGrey),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
    } else if (!_isSignalIssueYn) {
      return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxSignalCard(),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              width: 80.0,
              height: 80.0,
              decoration: const BoxDecoration(
                color: RColor.sigWatching,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '관망중', style: TStyle.btnTextWht20,
                  // style: theme.textTheme.body.apply(color: textColor),
                ),
              ),
            ),
            const Flexible(
              flex: 1,
              child: Center(
                child: Text('AI매매신호 내역이 없습니다.',
                    style: TextStyle(fontSize: 16, color: RColor.iconGrey),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        decoration: UIStyle.boxSignalCard(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _setCircleText(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: isTodayTag,
                      child: const SizedBox(
                        height: 25,
                      ),
                    ),
                    Visibility(
                      visible: isHoldingStk,
                      child: Row(
                        children: [
                          const Text(
                            '수익률',
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            '$stkProfit',
                            style: TextStyle(
                              color: profitColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //관망중
                    Visibility(
                      visible: _hasSignal,
                      child: Visibility(
                        visible: !isHoldingStk && !isTodayTrade,
                        child: Row(
                          children: [
                            const Text(
                              '관망 ',
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              '$holdDays일째',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),

                    Visibility(
                      visible: isHoldingStk && !isTodayBuy,
                      child: Row(
                        children: [
                          const Text(
                            '보유 ',
                          ),
                          Text(
                            holdDays,
                            style: TStyle.subTitle,
                          ),
                          const Text(
                            '일째',
                          ),
                        ],
                      ),
                    ),
                    //신호가격
                    Visibility(
                      visible: _hasSignal,
                      child: Row(
                        children: [
                          Text('$prePrc '),
                          Text(
                            '${TStyle.getMoneyPoint(stkPrc)}',
                            style: TStyle.subTitle,
                          ),
                          const Text('원'),
                        ],
                      ),
                    ),
                    //발생시간
                    Visibility(
                      visible: _hasSignal,
                      child: Row(
                        children: [
                          const Text('발생 '),
                          Text(
                            TStyle.getDateFormat(dateTime),
                            style: TStyle.subTitle,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !_hasSignal,
                      child: const Center(
                        child: Text(
                          'AI매매신호 내역이 없습니다.',
                          style: TStyle.defaultContent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _setPeriodRate(),
          ],
        ),
      );
    }
  }

  //보유기간/수익률
  Widget _setPeriodRate() {
    return Visibility(
      visible: isTodayTrade,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: UIStyle.boxWeakGrey10(),
                child: Column(
                  children: [
                    const Text('보유기간'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$holdPeriod일',
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(15),
                decoration: UIStyle.boxWeakGrey10(),
                child: Column(
                  children: [
                    const Text('수익률'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$stkProfit',
                      style: TextStyle(
                        color: profitColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
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

  // AI 매매신호 실시간 받기
  Widget _setBtnRealtime() {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        padding: const EdgeInsets.only(
            left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
        height: 40,
        decoration: const BoxDecoration(
          color: RColor.mainColor,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/rassibs_btn_icon.png',
                fit: BoxFit.cover,
                height: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  stkName,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Text(
                ' AI매매신호 실시간 받기',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showDialogMsg('$stkName 의\nAI매매신호 실시간 받기는');
      },
    );
  }

  // 모든 매매내역 보기
  Widget _setBtnListAll() {
    return Visibility(
      visible: _hasSignal,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
          height: 40,
          decoration: const BoxDecoration(
            color: RColor.btnAllView,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/rassibs_trade_history.png',
                  fit: BoxFit.cover,
                  height: 15,
                ),
                const SizedBox(
                  width: 7,
                ),
                Flexible(
                  child: Text(
                    stkName,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Text(
                  ' 모든 매매내역 보기',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          _showDialogMsg('$stkName 의\n모든 매매내역 보기는');
        },
      ),
    );
  }

  Widget _setCircleText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: statColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$statTxt', style: TStyle.btnTextWht20,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  //투자수익은?
  Widget _setReturnCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: RColor.lineGrey,
          width: 0.8,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '투자수익은?',
                style: TStyle.commonTitle,
              ),
              InkWell(
                onTap: () {
                  CommonPopup().showDialogTitleMsg(
                      context,
                      '투자수익은?',
                      "* 수익금을 재투자하여 매매한 금액입니다.\n"
                          "* 매도시 세금과 수수료(0.3%)가 반영되었습니다.\n"
                          "* 가상투자로 실제 투자와 차이가 있을 수 있습니다.");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                    border: Border.all(
                      width: 1.4,
                      color: RColor.new_basic_text_color_grey,
                      //style: BorderStyle.solid,
                    ),
                  ),
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: RColor.new_basic_text_color_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('$beginYear년 1월'),
                  _setCircleReturns(
                    invAmt,
                    RColor.yonbora,
                    const TextStyle(
                      fontSize: 15,
                      color: RColor.jinbora,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 5.0,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  Image.asset(
                    'images/main_my_icon_aw.png',
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(
                width: 5.0,
              ),
              Column(
                children: [
                  const Text('현재'),
                  _setCircleReturns(
                      balAmt, RColor.jinbora, TStyle.btnTextWht16),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            'AI매매신호를 따라 ${invAmt}만원 투자했을 경우, 현재 ${balAmt}만원 입니다.',
            style: TStyle.textGrey15,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            '※ 수익금을 재투자한 복리효과가 반영된 금액으로 누적수익률과 차이가 있을 수 있습니다.',
            style: TStyle.purpleThinStyle(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  //투자수익 Circle
  Widget _setCircleReturns(String prc, Color color, TextStyle tStyle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prc,
            style: tStyle,
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            '만원',
            style: tStyle,
          ),
        ],
      ),
    );
  }

  //AI 매매신호 성과
  Widget _setAchievements(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 280,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _acvList.length,
          itemBuilder: (context, index) {
            return TileSignalAnal(_acvList[index]);
          }),
    );
  }

  //매매신호 성과 Circle
  Widget _setCircleStatus(String txt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Center(
        child: Text(
          '$txt',
          // '$index'
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  //성과 TOP 종목
  Widget _setTopStock() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 25.0),
      color: RColor.bgWeakGrey,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle("성과 TOP 종목"),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _setTopBtn('승률', 'images/main_hnr_win_trade.png', 'HIT'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('누적수익률', 'images/main_hnr_max_ratio.png', 'STA'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('평균수익률', 'images/main_hnr_acc_ratio.png', 'AVG'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('최대수익률', 'images/main_hnr_win_ratio.png', 'MAX'),
              const SizedBox(
                width: 10,
              ),
              _setTopBtn('수익난매매', 'images/main_hnr_avg_ratio.png', 'PRF'),
            ],
          ),
          const SizedBox(
            height: 25.0,
          ),

          //책임 제한
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              RString.liability_limit,
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  //Custom Button
  Widget _setTopBtn(String title, String imgPath, String routeStr) {
    return InkWell(
      child: Column(
        children: [
          Image.asset(
            imgPath,
            fit: BoxFit.cover,
            height: 45,
          ),
          const SizedBox(
            height: 7.0,
          ),
          Text(
            title,
            style: TStyle.textSGrey,
          ),
          const Text(
            'TOP',
            style: TStyle.textSGrey,
          ),
        ],
      ),
      onTap: () {
        _showDialogMsg('$title TOP50 종목의\n모든 AI매매신호내역 확인은');
      },
    );
  }

  //간편하게 가입하기 다이얼로그
  void _showDialogMsg(String msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dailogContext) {
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
                  'images/rassibs_iconimg_01.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Text(
                  '$msg\n라씨 매매비서 시작하기 후 제공됩니다.',
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  '1초만에 하는\n간편하게 시작하기를 하세요.',
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  style: TextStyle(
                    //공통 중간 타이틀
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xcc111111),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: UIStyle.roundBtnStBox(),
                    child: const Center(
                      child: Text(
                        '라씨 매매비서 시작하기',
                        style: TStyle.btnTextWht15,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(dailogContext);
                    if (LoginDivisionPage.globalKey.currentState == null) {
                      Navigator.pushReplacementNamed(
                          context, LoginDivisionPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //5종목 초과 검색시 알림
  void _showDialogLimit(
    String stockName,
  ) {
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
                  'images/rassibs_iconimg_01.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '알림',
                  textAlign: TextAlign.center,
                  style: TStyle.title18,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '로그인 전 매매비서 / 매매신호 열람은 하루 5종목까지 무료로 제공됩니다.',
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                TextButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.mainColor,
                        borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                      ),
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
      },
    );
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
              splitLine: {
                show: false,
              },
          },
          dataZoom: [
                {
                  //show: false,
                  start: ${chartData.length > 60 ? '85' : '0'},
                  end: 100,
                  xAxisIndex: [0, 1],
                  zoomLock: true,
                  handleSize: '0%',
                  moveHandleSize: 30,
                  brushSelect: false,
                },
                {
                  type: 'inside',
                  realtime: true,
                  start: 50,
                  end: 60,
                  zoomLock: true,
                  xAxisIndex: [0, 1]
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

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(TradeIntroPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    if (_bYetDispose) _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(TradeIntroPage.TAG, response.body);

    //종목시세(20분지연)
    if (trStr == TR.SEARCH01) {
      final TrSearch01 resData = TrSearch01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Search01 data = resData.retData;
        DLog.d(TradeIntroPage.TAG, "SEARCH01 : ${data.stockName}|${data.isMyStock}");
        if (data.isMyStock == 'Y') {
          isMyPkt = true;
          stkPktSn = data.pocketSn;
        }
        setState(() {});
      }

      _fetchPosts(
          TR.SIGNAL01,
          jsonEncode(<String, String>{
            'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
            'stockCode': args.stockCode,
          }));
    }

    //매매신호 상태
    else if (trStr == TR.SIGNAL01) {
      final TrSignal01 resData = TrSignal01.fromJson(jsonDecode(response.body));

      isTodayTag = false;
      isTodayBuy = false;
      isTodayTrade = false;
      isHoldingStk = false;
      _isForbiddenShow = false;
      _forbiddenDesc = '';

      /*if (resData.retCode == RT.SUCCESS) {
        Signal01 data = resData.retData;
        _parseSetSignal01(data);
      } else {
        _hasSignal = false;
        statColor = RColor.sigWatching;
        statTxt = '관망중';
        isHoldingStk = false;
        setState(() {});
      }*/

      if (resData.retCode == RT.SUCCESS) {
        Signal01 data = resData.retData;
        _hasSignal = true;
        _isSignalTargetYn = true;
        _isSignalIssueYn = true;
        if (data.signalData.signalTargetYn == "N") {
          setState(() {
            _isSignalTargetYn = false;
          });
        } else if (data.signalData.signalIssueYn == "N") {
          setState(() {
            _isSignalIssueYn = false;
          });
        } else {
          _parseSetSignal01(data);
        }
      } else if (resData.retCode == '8021') {
        _hasSignal = false;
        statColor = RColor.sigWatching;
        statTxt = '관망중';
        isHoldingStk = false;
        setState(() {});
      } else {
        _hasSignal = false;
        statColor = RColor.sigWatching;
        statTxt = '관망중';
        isHoldingStk = false;
        setState(() {});
      }

      _fetchPosts(
          TR.SIGNAL02,
          jsonEncode(<String, String>{
            'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
            'stockCode': args.stockCode,
          }));
    }

    //매매신호 성과
    else if (trStr == TR.SIGNAL02) {
      final TrSignal02 resData = TrSignal02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (_hasSellDataCheck(resData.retData.listSignalAnal)) {
          if (resData.retData.listSignalAnal.length > 3) {
            _acvList = resData.retData.listSignalAnal.sublist(0, 3);
          } else {
            _acvList = resData.retData.listSignalAnal;
          }
          _hasSellResults = true;
        } else {
          _hasSellResults = false;
        }
        setState(() {});
      }

      _fetchPosts(
          TR.SIGNAL08,
          jsonEncode(<String, String>{
            'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
            'stockCode': args.stockCode,
            'includeData': 'Y',
          }));
    }

    //매매신호 차트 및 투자 수익금 TODO 추후에 진행
    else if (trStr == TR.SIGNAL08) {
      final TrSignal08 resData = TrSignal08.fromJson(jsonDecode(response.body));
      chartData.clear();
      // DLog.d(TradeInfo.TAG, resData);
      if (resData.retCode == RT.SUCCESS) {
        final Signal08 mData = resData.retData;
        beginYear = mData.beginYear;
        invAmt = mData.investAmt;
        balAmt = mData.balanceAmt;

        chartData.addAll(mData.listChart);
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
        DLog.d(TradeIntroPage.TAG, _dataStr);

        setState(() {});
      }
    } else if (trStr == TR.POCK05) {
      //포켓 종목 등록/해제
      final TrPock05 resData = TrPock05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (!isMyPkt) {
          isMyPkt = true;
          DLog.d(TradeIntroPage.TAG, '즐겨찾기 등록 완료');
        } else {
          isMyPkt = false;
          DLog.d(TradeIntroPage.TAG, '즐겨찾기 해제 완료');
        }
        setState(() {});
      } else if (resData.retCode == '8010') {}
    }
  }

  //성과 데이터 중 매도 데이터가 있는지 확인한다.
  bool _hasSellDataCheck(List<SignalAnal> dataList) {
    if (dataList != null && dataList.length > 0) {
      int count = 0;
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i].analTarget == 'S' && dataList[i].analType != null) {
          count++;
        }
      }
      if (count > 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //매매신호 Status
  void _parseSetSignal01(Signal01 data) {
    if (data.signalData.tradeFlag == 'B') {
      //당일매수
      statColor = RColor.sigBuy;
      statTxt = '매수';
      prePrc = '매수가';
      isTodayTag = true;
      isTodayBuy = true;
      isHoldingStk = true;
      bOffHoldDays = true;
      imgTodayTag = 'images/main_icon_today_buy.png';
    } else if (data.signalData.tradeFlag == 'H') {
      //보유중
      statColor = RColor.sigHolding;
      statTxt = '보유중';
      prePrc = '매수가';
      isHoldingStk = true;
    } else if (data.signalData.tradeFlag == 'S') {
      //당일매도
      statColor = RColor.sigSell;
      statTxt = '매도';
      prePrc = '매도가';
      isTodayTag = true;
      bOffHoldDays = true;
      isTodayTrade = true;
      isHoldingStk = false;
      imgTodayTag = 'images/main_icon_today_sell.png';
    } else if (data.signalData.tradeFlag == 'W') {
      //관망중
      statColor = RColor.sigWatching;
      statTxt = '관망중';
      prePrc = '매도가';
      isHoldingStk = false;
      _isForbiddenShow = data.signalData.isForbidden == 'Y' ? true : false;
      _forbiddenDesc = data.signalData.isForbidden == 'Y'
          ? data.signalData.forbiddenDesc
          : '';
    }

    if (data.signalData.profitRate.contains('-')) {
      stkProfit = data.signalData.profitRate + '%';
      profitColor = RColor.sigSell;
    } else {
      stkProfit = '+' + data.signalData.profitRate + '%';
      profitColor = RColor.sigBuy;
    }

    holdDays = data.signalData.elapsedDays;
    holdPeriod = data.signalData.termOfTrade;
    stkPrc = '${data.signalData.tradePrc}';
    dateTime = data.signalData.tradeDate + data.signalData.tradeTime;

    setState(() {});
  }
}
