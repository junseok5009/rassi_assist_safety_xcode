import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock04.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock05.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi04.dart';
import 'package:rassi_assist/models/tr_search/tr_search01.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal01.dart';
import 'package:rassi_assist/models/tr_sns01.dart';
import 'package:rassi_assist/models/tr_stk_home02.dart';
import 'package:rassi_assist/models/tr_user04.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_board.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';
import '../main/base_page.dart';
import '../stock_home/page/stock_ai_breaking_news_list_page.dart';

/// 2020.11.10
/// 포켓 상세
class PocketPage extends StatefulWidget {
  static const routeName = '/page_pocket';
  static const String TAG = "[PocketPage]";
  static const String TAG_NAME = '나의_포켓_상세보기';

  const PocketPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PocketPageState();
}

class PocketPageState extends State<PocketPage> {
  final _appGlobal = AppGlobal();
  var pageCallback;
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollStkController = ScrollController();

  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  String pktSn = ''; //포켓 SN
  String pktName = ''; //포켓 이름
  bool isEmptyStock = true; //빈 포켓 여부
  bool _hasSignal = true; //매매신호 발생한 내역이 있음
  bool _isSignalTargetYn = true; // 신호 노출 제한 종목  > 23.02.13 HJS 추가
  bool _isSignalIssueYn = true; // 신호 발생 여부  > 23.02.13 HJS 추가
  String _stkCode = ''; //선택된 종목코드
  String _stkName = ''; //선택된 종목명
  String prePrc = ''; //매수가 or 매도가
  String stkPrc = '';
  String curPrc = ''; //현재가
  String stkIndex = ""; //등락포인트, 등락률
  Color stkColor = Colors.grey;

  bool isHoldingStk = false; //보유중
  bool bOffHoldDays = false; //보유일 표시
  bool isTodayTrade = false; //당일매매 표시
  bool isTodayTag = false; //Today 매수/매도
  bool isTodayBuy = false; //당일매수
  bool hasPrcStock = false; //매수가 입력된 종목?
  bool genSigStock = false; //보유 후 매도 발생?

  Color profitColor = Colors.grey; //수익률 컬러
  String imgTodayTag = 'images/main_icon_today_buy.png';

  String holdDays = ""; //보유중 0일째 (매도 전 보유기간)
  String holdPeriod = ""; //지난 거래 전 보유기간

  String stkProfit = ""; //종목의 매매신호 수익률
  String dateTime = "";
  String statTxt = "";
  Color statColor = Colors.white; //Circle 보유중, 관망중 컬러
  String stkBriefing = '';
  String rassiCnt = '0', rassiCnt30 = '0';
  String cntSise = '0', cntInv = '0', cntInfo = '0';
  String statSns = 'images/rassibs_cht_img_1_1.png'; //소셜지수 이미지

  String crudPock05 = '';
  List<PStock> stkList = []; //포켓에 들어있는 종목
  bool _bUpdateStk = false;

  String myStkPrice = ''; //개인화 매수가
  String myStkProfit = ''; //개인화 수익률
  String myStkDesc = ''; //개인화 내용
  bool bPlusPrc = false; //개인화 수익 여부
  Color myStkColor = Colors.grey; //개인화 수익률 컬러
  String mySigPrice = ''; //개인화 매도 가격
  String mySigDate = ''; //개인화 매도 일시

  String pock01Type = ''; //포켓 업데이트, 삭제 처리

  //항상 포켓 SN 으로 페이지에 진입,
  bool _isForbiddenShow =
      false; //매매금지 종목 여부 Y + 관망중인 상태 > 매수신호가 발생되지 않습니다.. 체크 여부
  String _forbiddenDesc = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PocketPage.TAG_NAME);

    _initPageListener();
    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () {
        PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
        if (args != null) {
          pktSn = args.pgSn;
          if (args.stockCode != null) {
            _stkCode = args.stockCode;
            _bUpdateStk = true;
          }
          if (args.stockName != null) _stkName = args.stockName;
        }
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      });
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  Future<void> _initPageListener() async {
    //상태 리스너
    pageCallback = (status) {
      if (status == 'stk_change') {
        setState(() {
          pktSn = _appGlobal.pocketSn;
          _stkCode = _appGlobal.pktStockCode;
          _stkName = _appGlobal.pktStockName;
        });
        scrollController.jumpTo(0.0);
        scrollStkController.jumpTo(0.0);

        DLog.w('### Pocket Stock Change $_stkCode');
        if (pktSn.isNotEmpty) {
          _fetchPosts(
              TR.POCK04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'pocketSn': pktSn,
              }));
        }
      } else if (status == '') {}
    };
    _appGlobal.addPageStatusChangedListeners(pageCallback);
  }

  @override
  void dispose() {
    _appGlobal.isOnPocket = false;
    _appGlobal.removePageStatusChangedListeners(pageCallback);
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _setLayout();
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: CommonAppbar.basicWithAction(
        context,
        TStyle.getLimitString(pktName, 8),
        [
          IconButton(
            iconSize: 55,
            icon: const ImageIcon(
              AssetImage(
                'images/rassibs_pk_icon_board.png',
              ),
              color: Colors.black,
              size: 60,
            ),
            onPressed: () => goPocketBoard(),
          ),
          IconButton(
              iconSize: 22,
              icon: const ImageIcon(
                AssetImage('images/main_arlim_icon_mdf.png'),
                color: Colors.black,
              ),
              onPressed: () => _setModalBottomSheet(
                    context,
                    pktSn,
                    pktName,
                  )),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: scrollController,
          children: [
            _setPktStock(context),
            Visibility(
              visible: !isEmptyStock,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setStockInfo(),
                  const SizedBox(
                    height: 15.0,
                  ),

                  _setSubTitle('라씨 매매비서의 $_stkName 매매신호는?'),

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

                  Visibility(
                    visible: _isForbiddenShow,
                    child: Column(
                      children: [
                        TileSignal01Forbidden(_stkName, _forbiddenDesc),
                        const SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  ),

                  // 매매신호 실시간 받기 / 실시간 수신중
                  Stack(
                    children: [
                      _setBtnRealtime(),
                      _setBtnRegistered(),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),

                  //라씨 매매비서 제안
                  _setRassiSuggestion(),
                  const SizedBox(
                    height: 10.0,
                  ),

                  _setSubTitle('$_stkName 오늘의 요약 정보'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Wrap(
                      children: [
                        Text(
                          stkBriefing,
                          style: const TextStyle(fontSize: 16, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  _setSubTitleMore('AI속보'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setRassiCount(),
                  const SizedBox(
                    height: 10.0,
                  ),

                  _setSubTitleMore('소셜지수'),
                  const SizedBox(
                    height: 7.0,
                  ),
                  _setSocialIndex(),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
  }

  //포켓 상세 종목리스트
  Widget _setPktStock(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade50,
      child: ListView.builder(
        key: const PageStorageKey<String>('pocket_page_stock_list'),
        controller: scrollStkController,
        scrollDirection: Axis.horizontal,
        itemCount: stkList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _setTileAddStock();
          return _setTilePock04(stkList[index - 1], _stkCode);
        },
      ),
    );
  }

  //현재가, 등락률...
  Widget _setStockInfo() {
    return Container(
      width: double.infinity,
      height: 75,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 75,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _stkName,
                            style: TStyle.commonTitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          _stkCode,
                          style: TStyle.textSGrey,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Image.asset(
                          'images/rassi_icon_hold_home_w.png',
                          color: Colors.black87,
                          height: 14,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          curPrc,
                          style: TStyle.title18,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text(
                          stkIndex,
                          style: TextStyle(
                            color: stkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //종목 삭제
              IconButton(
                icon: Image.asset(
                  'images/main_my_icon_del.png',
                  height: 17,
                ),
                onPressed: () {
                  _showDialogDelete();
                },
              ),
            ],
          ),
        ),
        onTap: () {
          //종목홈으로 이동
          basePageState.goStockHomePage(
            _stkCode,
            _stkName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }

  //매수, 매도, 보유중, 관망중,
  Widget _setStatusCard() {
    if (!_isSignalTargetYn) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxSignalCard(),
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
        margin: const EdgeInsets.all(20),
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
      return InkWell(
        child: Container(
          margin: const EdgeInsets.all(20),
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
                              stkProfit,
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
                                style: const TextStyle(
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
                          )),
                      //신호가격
                      Visibility(
                        visible: _hasSignal,
                        child: Row(
                          children: [
                            Text('$prePrc '),
                            Text(
                              TStyle.getMoneyPoint(stkPrc),
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
        ),
        onTap: () {
          basePageState.goStockHomePage(
            _stkCode,
            _stkName,
            Const.STK_INDEX_SIGNAL,
          );
        },
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
                color: RColor.bgWeakGrey,
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
                color: RColor.bgWeakGrey,
                child: Column(
                  children: [
                    const Text('수익률'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      stkProfit,
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
          statTxt,
          style: TStyle.btnTextWht20,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  // AI 매매신호 실시간 받기
  Widget _setBtnRealtime() {
    return Visibility(
      visible: _appGlobal.isFreeUser && _isSignalTargetYn,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
          height: 40,
          decoration: UIStyle.roundBtnStBox(),
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
                Text(
                  '${TStyle.getLimitString(_stkName, 8)} AI매매신호 실시간 받기',
                  style: TStyle.btnTextWht14,
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          //기본 사용자일 경우에는 결제 페이지로 / 프리미엄 사용자일 경우에는 종목 등록
          if (_appGlobal.isFreeUser) {
            _navigateRefresh(context,
                Platform.isIOS ? PayPremiumPage() : PayPremiumAosPage());
            // _navigateRefresh(context, PayPremiumPage());
          } else {
            //종목 등록 안내
            _showDialogReg();
          }
        },
      ),
    );
  }

  // AI 매매신호 실시간 수신중
  Widget _setBtnRegistered() {
    return Visibility(
      visible: !_appGlobal.isFreeUser && _isSignalTargetYn,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 5.0, top: 5.0),
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: RColor.mainColor,
              width: 0.9,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/rassibs_btn_icon.png',
                  color: RColor.mainColor,
                  fit: BoxFit.cover,
                  height: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  '${TStyle.getLimitString(_stkName, 8)}의 AI매매신호 실시간 수신중',
                  style: const TextStyle(color: RColor.mainColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          //알림설정으로 이동
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NotificationSettingN()));
        },
      ),
    );
  }

  //회원님을 위한 라씨 매매비서 제안
  Widget _setRassiSuggestion() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          width: double.infinity,
          height: 150,
          color: RColor.deepBlue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '회원님을 위한 라씨 매매비서 제안',
                style: TStyle.btnTextWht16,
              ),
              Image.asset(
                'images/rassibs_icon_robot_s.png',
                height: 32,
              ),
            ],
          ),
        ),

        //매수가 입력 제안
        Visibility(
          visible: !hasPrcStock,
          child: _setPrcEmptyCard(),
        ),

        //종목 개인화 정보
        Visibility(
          visible: hasPrcStock,
          child: _setReturnCard(),
        ),

        Visibility(
          visible: genSigStock,
          child: _setSellCard(),
        )
      ],
    );
  }

  //라씨 매매비서 제안 (개인화 정보)
  Widget _setReturnCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      height: 180,
      decoration: UIStyle.boxRoundLine15(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '나의 매수가',
              ),
              //매수 정보 수정하기
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: RColor.mainColor,
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("+매수 정보 수정하기",
                          style: TextStyle(
                            color: RColor.mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          )),
                    ],
                  ),
                ),
                onTap: () {
                  _showDialogModDelPrc();
                },
              )
            ],
          ),
          const SizedBox(
            height: 5.0,
          ),

          //개인화 매수가격, 수익률
          Row(
            children: [
              Text(
                myStkPrice,
                style: TStyle.title18,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(myStkProfit,
                  style: TextStyle(
                    color: myStkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  )),
              Visibility(
                visible: bPlusPrc,
                child: const Text(
                  '수익중',
                  style: TStyle.commonTitle,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),

          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 110,
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Center(
                    child: Text(
                      '라씨 매매비서 Talk',
                      style: TStyle.btnSsTextWht,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),

                //개인화 Desc
                Text(
                  myStkDesc,
                  style: TStyle.textSGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //라씨 매매비서 제안 (개인화 정보 - 보유 후 매도 발생)
  Widget _setSellCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      height: 180,
      decoration: UIStyle.boxRoundLine15(),
      child: Column(
        children: [
          Text(
            '회원님의 $_stkName 매도신호',
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: RColor.bgWeakGrey,
            child: Column(
              children: [
                Text(mySigDate), //개인화 시그널 일시
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('매도가'),
                    const SizedBox(
                      width: 3.0,
                    ),
                    Text(
                      mySigPrice,
                      style: TStyle.commonTitle,
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    const Text('수익률'),
                    const SizedBox(
                      width: 3.0,
                    ),
                    Text(myStkProfit,
                        style: TextStyle(
                          color: myStkColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_stkName를 매도 하셨나요?',
                style: TStyle.textSGrey,
              ),
              const SizedBox(
                width: 5.0,
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 5.0),
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Center(
                    child: Text(
                      '+YES',
                      style: TStyle.btnTextWht13,
                    ),
                  ),
                ),
                onTap: () {
                  //yes 버튼  ->  종목 가격없이 업데이트 (매수 가격 삭제)
                  requestUpPktStock('0');
                },
              ),
              const SizedBox(
                width: 5.0,
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: RColor.mainColor,
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        " +NO ",
                        style: TStyle.puplePlainStyle(),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  _showDialogRe();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //매수 정보 입력하기 카드
  Widget _setPrcEmptyCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      height: 200,
      decoration: UIStyle.boxRoundLine15(),
      child: Column(
        children: [
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _stkName,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${TStyle.getJustPostWord(_stkName, '을', '를')} 보유중이신가요?',
                style: TStyle.defaultContent,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Text(
            '회원님의 매수가를 입력하시면\n회원님을 위한 매도신호를\n알려드립니다.',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15.0,
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: RColor.mainColor,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Text(
                "   +매수 정보 입력하기   ",
                style: TStyle.puplePlainStyle(),
              ),
            ),
            onTap: () {
              if (_appGlobal.isPremium) {
                if (_isSignalTargetYn) {
                  _showDialogPrice();
                } else {
                  CommonPopup().showDialogMsg(
                      context, 'AI매매신호가 발생되지 않는 종목은 나만의 매도 신호가 제공되지 않습니다.');
                }
              } else {
                _showSuggestPremium('오직 회원님을 위한 매도 신호는 프리미엄 계정에서 사용이 가능합니다.\n'
                    '프리미엄 계정으로 업그레이드 해보세요.');
              }
            },
          )
        ],
      ),
    );
  }

  //AI 속보
  Widget _setRassiCount() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        basePageState.callPageRouteData(
          const StockAiBreakingNewsListPage(),
          PgData(
            stockName: _stkName,
            stockCode: _stkCode,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Text('오늘 발생된 '),
                      Flexible(
                        child: Text(
                          _stkName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Text(' 관련 속보 '),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      rassiCnt,
                      style: TStyle.ulTextGrey,
                    ),
                    const Text('건'),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Text('최근 30일 동안 발생된 '),
                      Flexible(
                        child: Text(
                          _stkName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Text(' 관련 속보 '),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      rassiCnt30,
                      style: TStyle.ulTextGrey,
                    ),
                    const Text('건'),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //소셜지수
  Widget _setSocialIndex() {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 10.0,
        ),
        decoration: UIStyle.boxRoundLine17(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '참여도\n낮음',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Image.asset(
                statSns,
                fit: AppGlobal().isTablet ? BoxFit.contain : BoxFit.fill,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              '참여도\n높음',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          _stkCode,
          _stkName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }

  //종목알림 (공통으로 분리)
  Widget _setNoticeCnt() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: UIStyle.boxWeakGrey10(),
              child: Column(
                children: [
                  const Text('시세변동'),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    cntSise,
                    style: TStyle.title20,
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
                  const Text('투자자 변동'),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    cntInv,
                    style: TStyle.title20,
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
                  const Text('정보'),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    cntInfo,
                    style: TStyle.title20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 종목 리스트
  Widget _setTilePock04(PStock item, String curStkCode) {
    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: item.stockCode == curStkCode
            ? Colors.lightBlue[100]
            : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              width: 90,
              child: Center(
                child: Text(
                  item.stockName,
                  style: TStyle.subTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              right: 2.0,
              top: 15.0,
              child: Visibility(
                visible: (item.myTradeFlag == 'H' || item.myTradeFlag == 'S')
                    ? true
                    : false,
                child: Container(
                  height: 25,
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '보유',
                      style: TStyle.btnSsTextWht,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _stkCode = item.stockCode;
          _stkName = item.stockName;
          _fetchPosts(
              TR.SEARCH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'stockCode': _stkCode,
              }));
        },
      ),
    );
  }

  //+종목추가
  Widget _setTileAddStock() {
    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 8,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RColor.lineGrey,
          width: 1.0,
        ),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/main_item_icon_no1.png',
                height: 25,
              ),
              const SizedBox(
                height: 7.0,
              ),
              const Text(
                '+종목추가',
                style: TStyle.contentSBLK,
              ),
            ],
          ),
        ),
        onTap: () {
          if (_appGlobal.isPremium) {
            _navigateSearchData(
                context,
                const SearchPage(),
                PgData(
                  pgSn: pktSn,
                ));
          } else {
            if (stkList.length > 2) {
              _showSuggestPremium('베이직 계정에서는 3종목까지 이용이 가능합니다.\n'
                  '종목추가와 포켓을 마음껏 이용할 수 있는 프리미엄 계정으로 업그레이드 해보세요.');
            } else {
              _navigateSearchData(
                  context,
                  const SearchPage(),
                  PgData(
                    pgSn: pktSn,
                  ));
            }
          }
        },
      ),
    );
  }

  //해당 포켓보드의 Sn 인덱스 페이지로 이동
  void goPocketBoard() {
    Navigator.of(context).pushReplacementNamed(
      PocketBoard.routeName,
      arguments: PgData(
        pgSn: pktSn,
      ),
    );
  }

  //종목홈 탭이동 타이틀
  Widget _setSubTitleMore(
    String subTitle,
  ) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subTitle,
              style: TStyle.defaultTitle,
              textScaleFactor: Const.TEXT_SCALE_FACTOR,
            ),
            InkWell(
              child: const Text(
                ' +더보기 ',
                style: TStyle.textGrey15,
                textScaleFactor: Const.TEXT_SCALE_FACTOR,
              ),
              onTap: () {
                //Navigator.pop(context);
                if (subTitle == 'AI속보') {
                  basePageState.callPageRouteData(
                    const StockAiBreakingNewsListPage(),
                    PgData(
                      stockName: _stkName,
                      stockCode: _stkCode,
                    ),
                  );
                } else {
                  basePageState.goStockHomePageCheck(
                    context,
                    _stkCode,
                    _stkName,
                    Const.STK_INDEX_HOME,
                  );
                }
              },
            ),
          ],
        ));
  }

  //결제 안내 다이얼로그
  void _showSuggestPremium(String desc) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  Text(
                    desc,
                    style: TStyle.contentMGrey,
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
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                      _navigateRefreshPay(
                          context,
                          Platform.isIOS
                              ? PayPremiumPage()
                              : PayPremiumAosPage());
                      // _navigateRefreshPay(context, PayPremiumPage());
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //삭제 다이얼로그
  void _showDialogDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                // Image.asset('images/rassibs_img_infomation.png',
                //   height: 60, fit: BoxFit.contain,),
                // const SizedBox(height: 25.0,),
                Text('[$pktName]에서 $_stkName를 삭제 하시겠습니까?',
                    textScaleFactor: Const.TEXT_SCALE_FACTOR),
                const SizedBox(
                  height: 30.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.mainColor,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                    requestDelPktStock();
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

  //종목 매수가 입력
  void _showDialogPrice() {
    CustomFirebaseClass.logEvtScreenView('포켓_매수가입력');
    final priceController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setSubTitle('나의 종목 추가하기'),
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
                Text(
                  '$_stkName를 보유중이신가요?\n'
                  '회원님의 매수가를 입력하시면 회원님만을 위한\n매도신호를 알려드립니다.',
                  style: TStyle.contentMGrey,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 20,
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.all(15),
                  color: RColor.bgWeakGrey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '매수가 입력',
                        style: TStyle.commonTitle,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        decoration: _setBoxDecoration(),
                        child: TextField(
                          decoration: const InputDecoration.collapsed(hintText: '0'),
                          controller: priceController,
                          textAlign: TextAlign.end,
                          // keyboardType: TextInputType.number,  //키보드를 내릴수 없음
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //확인해 주세요
                _setInputDesc(),

                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 40,
                      decoration: UIStyle.roundBtnBox(RColor.deepBlue),
                      child: const Center(
                        child: Text(
                          '매수가 등록하기',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    String price = priceController.text.trim();
                    if (price.length == 0) {
                      commonShowToast('매수가격을 입력해주세요');
                    } else {
                      Navigator.pop(context);
                      requestUpPktStock(price);
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

  Widget _setInputDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _setSubTitle('! 확인해 주세요'),
        const Text(
          RString.desc_input_buy_prc,
          style: TStyle.contentMGrey,
          textScaleFactor: Const.TEXT_SCALE_FACTOR,
        ),
      ],
    );
  }

  //종목 재등록(NO 선택) 다이얼로그
  void _showDialogRe() {
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    '$_stkName의 매도신호를 다시 받아보시겠어요?',
                    style: TStyle.subTitle,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 25.0,
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
                      _showDialogModPrc();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //매수가 다시 입력
  void _showDialogModPrc() {
    final priceController = TextEditingController();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '매수가 입력',
                  style: TStyle.commonTitle,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        decoration: _setBoxDecoration(),
                        child: TextField(
                          decoration: const InputDecoration.collapsed(hintText: ''),
                          controller: priceController,
                          textAlign: TextAlign.end,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25.0,
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
                      String price = priceController.text.trim();
                      if (price.length == 0) {
                        commonShowToast('매수가격을 입력해주세요');
                      } else {
                        Navigator.pop(context);
                        requestUpPktStock(price);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //매수가 수정/삭제
  void _showDialogModDelPrc() {
    final priceController = TextEditingController();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '매수가 수정',
                  style: TStyle.commonTitle,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        decoration: _setBoxDecoration(),
                        child: TextField(
                          decoration: const InputDecoration.collapsed(hintText: '0'),
                          controller: priceController,
                          textAlign: TextAlign.end,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25.0,
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
                      String price = priceController.text.trim();
                      if (price.length == 0) {
                        commonShowToast('매수가격을 입력해주세요');
                      } else {
                        Navigator.pop(context);
                        requestUpPktStock(price);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnBox(Colors.grey),
                        child: const Center(
                          child: Text(
                            '삭제',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      requestUpPktStock('0');
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //종목추가 안내 다이얼로그
  void _showDialogReg() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  const Text(
                    '나의 종목으로 등록하시고,\nAI매매신호를 실시간으로 받아보세요.',
                    style: TStyle.content14,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20.0),
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
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
                      _fetchPosts(
                          TR.POCK03,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                          }));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 다이얼로그
  void _showDialogMsg(String message, String btnText) {
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
                  Text(message, textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: Center(
                          child: Text(
                            btnText,
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

  //종목 포켓 설정
  void _setModalBottomSheet(context, String pktSn, String pktName) {
    final nameController = TextEditingController();
    bool isNaming = false;
    String strHint = pktName;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),

                  //종목 포켓 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _setSubTitle('종목 포켓 설정'),
                      InkWell(
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),

                  //종목 포켓명
                  _setSubTitle('종목 포켓명'),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                          enabled: isNaming, //TODO 현재는 보여주기만 한다.
                          controller: nameController,
                          decoration: InputDecoration(hintText: strHint),
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          color: Colors.white,
                          textColor: Colors.black54,
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Visibility(
                                visible: !isNaming,
                                child: const Text(
                                  '변경',
                                  style: TextStyle(fontSize: 14.0),
                                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                                ),
                              ),
                              Visibility(
                                visible: isNaming,
                                child: const Text(
                                  '확인',
                                  style: TextStyle(fontSize: 14.0),
                                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            //이름 변경중
                            if (isNaming) {
                              String chName = nameController.text.trim();
                              if (chName.length > 0) {
                                DLog.d('tag', chName);
                                Navigator.pop(context);
                                requestPocket('U', pktSn, chName);
                              } else {
                                _showDialogMsg('포켓명을 입력해주세요', '확인');
                              }
                            } else {
                              setModalState(() {
                                isNaming = true;
                                strHint = '포켓명을 입력해 주세요.';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //알림 설정
                  InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/rassibs_btn_icon.png',
                            height: 24,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '알림설정',
                                style: TStyle.btnTextWht13,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                              Text(
                                '매매신호, 종목알림 동의',
                                style: TStyle.btnSsTextWht,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                              Text(
                                '수신 설정 화면으로 이동합니다.',
                                style: TStyle.btnSsTextWht,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationSettingN()));
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //종목 포켓 삭제
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: const [
                          Text(
                            '- 종목 포켓 삭제',
                            style: TStyle.commonSTitle,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                          Text(
                            '(등록된 모든 종목을 삭제하시겠습니까?)',
                            style: TStyle.textSGrey,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ],
                      ),

                      //종목 삭제
                      IconButton(
                        icon: Image.asset(
                          'images/main_my_icon_del.png',
                          height: 17,
                        ),
                        onPressed: () {
                          _showDelPocket(pktSn);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration _setBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: RColor.mainColor,
        width: 1.0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(7.0)),
    );
  }

  //포켓 삭제 다이얼로그
  void _showDelPocket(String pktSn) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  const Text(
                    '포켓 및 등록된 모든 종목이 삭제됩니다.\n삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TStyle.contentMGrey,
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
                      requestPocket('D', pktSn, '');
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //페이지 리프레시
  _navigateSearchData(
      BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(
        context,
        _createRouteData(
            instance,
            RouteSettings(
              arguments: pgData,
            )));
    if (result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.POCK04,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pocketSn': pktSn,
          }));
    }
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
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

  //결제 페이지 리프레시
  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
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

  _navigateRefresh(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //포켓 업데이트/삭제
  requestPocket(String type, String pktSn, String chName) {
    setState(() {
      pock01Type = type;
    });

    _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'crudType': type,
          'pocketSn': pktSn,
          'pocketName': chName,
        }));
  }

  //포켓 종목 업데이트
  requestUpPktStock(String price) {
    crudPock05 = 'U';
    _bUpdateStk = true;
    _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'pocketSn': pktSn,
          'crudType': crudPock05, //U:변경
          'stockCode': _stkCode,
          'buyPrice': price,
        }));
  }

  //포켓 종목 삭제
  requestDelPktStock() {
    crudPock05 = 'D';
    _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'pocketSn': pktSn,
          'crudType': crudPock05,
          'stockCode': _stkCode,
          'buyPrice': '', //TODO 보유종목일 경우 처리 (codeLine: 788)
        }));
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PocketPage.TAG, '$trStr $json');

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
      DLog.d(PocketPage.TAG, 'TimeoutException (10 seconds)');
    } on SocketException catch (_) {
      DLog.d(PocketPage.TAG, 'SocketException');
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PocketPage.TAG, response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04? data = resData.retData;
        if(data != null) {
          DLog.d(PocketPage.TAG, data.accountData.toString());

          if (data != null && data.accountData != null) {
            final AccountData? accountData = data.accountData;
            accountData?.initUserStatus();
          } else {
            //회원정보 가져오지 못함
            AccountData().setFreeUserStatus();
          }
          setState(() {});
        }
      }

      _fetchPosts(
          TR.POCK04,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pocketSn': pktSn,
          }));
    }

    //포켓 상세 조회
    else if (trStr == TR.POCK04) {
      final TrPock04 resData = TrPock04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Pock04 data = resData.retData;
        stkList.clear();
        pktName = data.pocketInfo.pocketName;
        if (data.stkList != null && data.stkList.isNotEmpty) {
          if (!_bUpdateStk) {
            _stkCode = data.stkList[0].stockCode;
            _stkName = data.stkList[0].stockName;
          } else {
            _bUpdateStk = false;
          }
          stkList = data.stkList;
          isEmptyStock = false;
        } else {
          isEmptyStock = true;
        }
        setState(() {});
        if (stkList.isNotEmpty) {
          if (_stkCode.isEmpty) {
            _stkCode = stkList[0].stockCode;
            _stkName = stkList[0].stockName;
          }
          _fetchPosts(
              TR.SEARCH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'stockCode': _stkCode,
              }));
        }
      }
    }

    else if (trStr == TR.SEARCH01) {
      final TrSearch01 resData = TrSearch01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (stkList.isNotEmpty) _setMyStockStatus(_getCurrentStock(_stkCode));

        Search01? item = resData.retData;
        if(item != null) {
          curPrc = TStyle.getMoneyPoint(item.currentPrice);
          if (item.fluctuationRate.contains('-')) {
            DLog.d(PocketPage.TAG, 'minus');
            stkIndex =
            '▼${TStyle.getMoneyPoint(item.fluctuationAmt)}   ${item.fluctuationRate}%';
            stkColor = RColor.sigSell;
          } else {
            stkIndex =
            '▲${TStyle.getMoneyPoint(item.fluctuationAmt)}   +${item.fluctuationRate}%';
            stkColor = RColor.sigBuy;
          }
          setState(() {});
        }
      }

      _fetchPosts(
          TR.SIGNAL01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': _stkCode,
          }));
    }

    else if (trStr == TR.SIGNAL01) {
      final TrSignal01 resData = TrSignal01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Signal01? data = resData.retData;
        if(data != null) {
          _hasSignal = true;
          _isSignalTargetYn = true;
          _isSignalIssueYn = true;
          if (data.signalData?.signalTargetYn == "N") {
            setState(() {
              _isSignalTargetYn = false;
            });
          } else if (data.signalData?.signalIssueYn == "N") {
            setState(() {
              _isSignalIssueYn = false;
            });
          } else {
            _parseSetSignal01(data);
          }
        }
      } else if (resData.retCode == '8021') {
        DLog.d(PocketPage.TAG, "이용자별 [무료 조회 가능 종목] 갯수를 초과하였습니다.");
      } else {
        DLog.d(PocketPage.TAG, "AI매매신호 내역이 없습니다.");
        _hasSignal = false;
        statColor = RColor.sigWatching;
        statTxt = '관망중';
        isHoldingStk = false;
        setState(() {});
      }

      _fetchPosts(
          TR.RASSI04,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': _stkCode,
          }));
    }
    //
    else if (trStr == TR.RASSI04) {
      final TrRassi04 resData = TrRassi04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Rassi04? data = resData.retData;
        if(data != null) {
          stkBriefing = data.content.replaceAll('<br>', '\n');
          rassiCnt = data.todayNewsCount;
          rassiCnt30 = data.monthNewsCount;
          setState(() {});
        }
      }
      _fetchPosts(
          TR.SNS01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': _stkCode,
          }));
    }
    //소셜지수
    else if (trStr == TR.SNS01) {
      final TrSns01 resData = TrSns01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData == '1') {
          statSns = 'images/rassibs_cht_img_1_1.png';
        } else if (resData.retData == '2') {
          statSns = 'images/rassibs_cht_img_1_2.png';
        } else if (resData.retData == '3') {
          statSns = 'images/rassibs_cht_img_1_3.png';
        } else if (resData.retData == '4') {
          statSns = 'images/rassibs_cht_img_1_4.png';
        }
        setState(() {});
      }

      _fetchPosts(
          TR.SHOME02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': _stkCode,
            'includeData': 'N',
            'pageNo': '0',
            'pageItemSize': '10',
          }));
    }
    //
    else if (trStr == TR.SHOME02) {
      final TrSHome02 resData = TrSHome02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        SHome02? data = resData.retData;
        if(data != null) {
          InfoCnt cItem = data.infoCnt;
          cntSise = cItem.siseCount;
          cntInv = cItem.investorCount;
          cntInfo = cItem.infoCount;

          setState(() {});
        }
      }
    }
    //
    else if (trStr == TR.POCK05) {
      final TrPock05 resData = TrPock05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (crudPock05 == 'U') {
          // 보유종목 or 종목 가격 삭제
          // showToast('포켓에 보유종목으로 등록되었습니다');
        } else if (crudPock05 == 'D') {
          scrollStkController.jumpTo(0.0);
          if (_appGlobal.stkCode == _stkCode) {
            // 종목 홈에서 포켓에 관심/보유 등록 이후에 이쪽으로 넘어왔을때 해당 종목이 여기서 다시 삭제되면 종목홈에도 반영해야해서
            Provider.of<StockInfoProvider>(context, listen: false)
                .postRequest(_stkCode);
          }
        }
        setState(() {});
        //삭제 성공 포켓 내용 다시 요청
        _fetchPosts(
            TR.POCK04,
            jsonEncode(<String, String>{
              'userId': _userId,
              'pocketSn': pktSn,
            }));
      } else if (resData.retCode == '8008') {
        //등록가능 종목수 초과
        commonShowToast(resData.retMsg);
      } else if (resData.retCode == '8010') {
        commonShowToast(resData.retMsg);
      } else if (resData.retCode == '8011') {
        //현재가 대비 -9%
        _showDialogMsg(
            '회원님만을 위한 AI매도신호 제공을 위한\n매수가 입력은 \'현재가 대비 -9%\'이내\n가격에서만 가능합니다.',
            '확인');
      }
    }

    //포켓 업데이트/삭제
    else if (trStr == TR.POCK01) {
      final TrPock01 resData = TrPock01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (pock01Type == 'U') {
          commonShowToast('포켓명이 변경 되었습니다.');
          _fetchPosts(
              TR.POCK04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'pocketSn': pktSn,
              }));
        } else if (pock01Type == 'D') {
          //포켓 삭제 완료
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pop(context);
          });
        }
      }
    }
  }

  //매매신호 Status
  void _parseSetSignal01(Signal01 data) {
    isTodayTag = false;
    isTodayBuy = false;
    isTodayTrade = false;
    isHoldingStk = false;
    _isForbiddenShow = false;
    _forbiddenDesc = '';
    if (data.signalData.tradeFlag == 'B') {
      //당일매수
      statColor = RColor.sigBuy;
      statTxt = '매수';
      prePrc = '매수가';
      isHoldingStk = true;
      isTodayTag = true;
      isTodayBuy = true;
      bOffHoldDays = true;
      isTodayTrade = false;
      imgTodayTag = 'images/main_icon_today_buy.png';
    } else if (data.signalData.tradeFlag == 'H') {
      //보유중
      statColor = RColor.sigHolding;
      statTxt = '보유중';
      prePrc = '매수가';
      isHoldingStk = true;
      isTodayTag = false;
      isTodayTrade = false;
      bOffHoldDays = false;
    } else if (data.signalData.tradeFlag == 'S') {
      //당일매도
      statColor = RColor.sigSell;
      statTxt = '매도';
      prePrc = '매도가';
      isHoldingStk = false;
      isTodayTag = true;
      isTodayTrade = true;
      bOffHoldDays = true;
      imgTodayTag = 'images/main_icon_today_sell.png';
    } else if (data.signalData.tradeFlag == 'W') {
      //관망중
      statColor = RColor.sigWatching;
      statTxt = '관망중';
      prePrc = '매도가';
      isTodayTag = false;
      isTodayTrade = false;
      bOffHoldDays = false;
      isHoldingStk = false;
      _isForbiddenShow = data.signalData.isForbidden == 'Y' ? true : false;
      _forbiddenDesc = data.signalData.isForbidden == 'Y'
          ? data.signalData.forbiddenDesc
          : '';
    }

    if (data.signalData.profitRate.contains('-')) {
      stkProfit = '${data.signalData.profitRate}%';
      profitColor = RColor.sigSell;
    } else {
      stkProfit = '+${data.signalData.profitRate}%';
      profitColor = RColor.sigBuy;
    }

    holdDays = data.signalData.elapsedDays;
    holdPeriod = data.signalData.termOfTrade;
    stkPrc = data.signalData.tradePrc;
    dateTime = data.signalData.tradeDate + data.signalData.tradeTime;
    setState(() {});
  }

  //관심/보유 종목 현황
  void _setMyStockStatus(PStock? item) {
    if(item != null) {
      DLog.e('item : ${item.toString()}');
      if (item.myTradeFlag == 'W') {
        //관심종목
        DLog.d(PocketPage.TAG, '관심종목 $item');
        hasPrcStock = false;
        genSigStock = false;
      } else if (item.myTradeFlag == 'H') {
        //보유종목
        DLog.d(PocketPage.TAG, '보유종목 $item');
        hasPrcStock = true;
        genSigStock = false;
        String strPrice = '${TStyle.getMoneyPoint(item.buyPrice)}원';
        myStkPrice = strPrice;

        if (item.profitRate.contains('-')) {
          myStkProfit = '${item.profitRate}%';
          myStkColor = RColor.sigSell;
          bPlusPrc = false;
        } else {
          myStkProfit = '+${item.profitRate}%';
          myStkColor = RColor.sigBuy;
          bPlusPrc = true;
        }

        if (item.listTalk.length > 0) myStkDesc = item.listTalk[0].achieveText;
        // myStkDesc
      } else {
        //보유 후 매도 발생
        DLog.d(PocketPage.TAG, '보유 후 매도 발생');
        hasPrcStock = true;
        genSigStock = true;

        String strDate = '';
        if (item.sellDttm.length > 8) {
          strDate = '${item.sellDttm.substring(4, 6)}/'
              '${item.sellDttm.substring(6, 8)}  '
              '${item.sellDttm.substring(8, 10)}:'
              '${item.sellDttm.substring(10, 12)}';
        }

        mySigDate = strDate;
        mySigPrice = '${TStyle.getMoneyPoint(item.sellPrice)}원';
        if (item.profitRate.contains('-')) {
          myStkProfit = '${item.profitRate}%';
          myStkColor = RColor.sigSell;
        } else {
          myStkProfit = '+${item.profitRate}%';
          myStkColor = RColor.sigBuy;
        }
      }
    }
  }

  PStock? _getCurrentStock(String stockCode) {
    DLog.e('_getCurrentStock() stockCode : $stockCode');
    if (stkList.isNotEmpty) {
      for (int i = 0; i < stkList.length; i++) {
        if (stkList[i].stockCode == stockCode) {
          DLog.e(stkList[i].toString());
          return stkList[i];
        }
      }
    }
    return null;
  }
}
