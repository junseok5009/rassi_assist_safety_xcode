import 'dart:async';
import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/const.dart';
import '../../../common/tstyle.dart';
import '../../../models/tr_signal/tr_signal09.dart';

/// [홈_홈 오늘의 AI매매신호는?] - 2023.09.07 HJS
class HomeTileTodaySignal extends StatefulWidget {
  static final GlobalKey<HomeTileTodaySignalState> globalKey = GlobalKey();

  HomeTileTodaySignal() : super(key: globalKey);

  @override
  State<HomeTileTodaySignal> createState() => HomeTileTodaySignalState();
}

class HomeTileTodaySignalState extends State<HomeTileTodaySignal> {
  late SharedPreferences _prefs;
  final AppGlobal _appGlobal = AppGlobal();
  String _userId = '';

  Signal09 _signal09 = defSignal09;
  String _noticeCode = '';
  bool _bTodaySignal = false; //오늘 신호 발생 여부
  final List<SignalCount> _listSigStatus = [];
  final List<double> _circlePadding = [18, 22, 11];
  final List<double> _circleFontSize = [14, 16, 12];

  // 프로세스
  String _engineStr1 = '';
  String _engineStr2 = '';
  final List<String> _preStartStr = [
    '학습 정보 Update',
    'Today 시세마스터 생성',
    '미거래/매매금지 종목 Filtering',
    '신규 종목 Confirm',
    '거래 종목 fixed',
    '종목 정보/분석 Update',
    'Dashboard Reset',
    'Start Trading Standby',
  ];
  Timer? _countTimer;
  int _minute = 0;
  int _second = 0;

  @override
  void initState() {
    super.initState();
    _loadPrefData().then((_) {
      initPage();
    });
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 AI매매신호는?',
            style: TStyle.title18T,
          ),
          const SizedBox(
            height: 25,
          ),
          _signal09.isEmpty()
              ? Container(
                  decoration: UIStyle.boxShadowBasic(16),
                  child: CommonView.setNoDataTextView(
                    120,
                    '오늘 새로 발생된 매매신호가 없습니다.',
                  ),
                )
              : _setDataView(),
        ],
      ),
    );
  }

  //롤링 현황 텍스트
  Widget _setTileSigString(SignalCount item) {
    String timeStr = TStyle.getTimeFormat(item.tradeTime);
    String honor;
    String endStr;
    String cnt = item.tradeCount;
    if (item.honorDiv.isNotEmpty) {
      if (item.honorDiv == 'WIN_RATE') {
        honor = '적중률 TOP 종목';
      } else if (item.honorDiv == 'PROFIT_10P') {
        honor = '수익난 매매 TOP 종목';
      } else if (item.honorDiv == 'SUM_PROFIT') {
        honor = '누적수익률 TOP 종목';
      } else if (item.honorDiv == 'MAX_PROFIT') {
        honor = '최대수익률 TOP 종목';
      } else {
        honor = '평균수익률 TOP 종목';
      }
      if (item.tradeFlag == 'B') {
        endStr = '에서 새로운 매수 신호 발생';
      } else {
        endStr = '에서 새로운 매도 신호 발생';
      }
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 3,
          ),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  honor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  endStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          DefaultTabController.of(context).animateTo(1);
        },
      );
    } else {
      String preStr = '';
      Color stColor;
      if (item.tradeFlag == 'B') {
        preStr = '매수신호';
        stColor = RColor.sigBuy;
      } else {
        preStr = '매도신호';
        stColor = RColor.sigSell;
      }
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 3,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: Color(
                      0xff8C8C8C,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  '새로운 ',
                ),
                Text(
                  preStr,
                  style: TextStyle(
                    color: stColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '가 ',
                ),
                Text(
                  '$cnt종목',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '에서 발생',
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          DefaultTabController.of(context).animateTo(1);
        },
      );
    }
  }

  //장 종료 후 롤링 텍스트
  Widget _setTileSigStringTimeClose(SignalCount item) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 3,
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                  minHeight: 20,
                ),
                child: Text(
                  TStyle.getLimitString(item.stockName, 10),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                item.tradeFlag == 'B'
                    ? '보유중'
                    : item.tradeFlag == 'S'
                        ? '오늘매도'
                        : '',
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                TStyle.getPercentString(item.profitRate),
                style: TextStyle(
                  color: TStyle.getMinusPlusColor(
                    item.profitRate,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '(${item.holdingDays}',
                style: const TextStyle(),
              ),
              Text(
                item.tradeFlag == 'B'
                    ? '일전 매수)'
                    : item.tradeFlag == 'S'
                        ? '일 보유)'
                        : '',
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        DefaultTabController.of(context).animateTo(1);
      },
    );
  }

  _initData() async {
    _listSigStatus.addAll(_signal09.listData);
    _noticeCode = _signal09.noticeCode;
    _bTodaySignal = (_noticeCode != 'TIME_BEFORE' && _noticeCode.isNotEmpty);

    //장시작 대기, 전일 미거래 종목 필터링중(08시 ~ 개장전)
    if (_noticeCode == 'TIME_BEFORE') {
      _engineStr1 = 'AI는 현재 데이터 처리 중';
      _engineStr2 = '';
    }
    //장시작 후 첫 신호 발생전까지
    else if (_noticeCode == 'TIME_OPEN') {
      _engineStr1 = 'AI는 현재 신호 발생 중';
      _engineStr2 = 'AI는 현재 새로운\nAI매매신호를 발생 중입니다.';
    }
    //9시 20분 첫 신호 발생부터 다음 신호 발생 정각까지 20분 단위 카운트 다운
    else if (_noticeCode == 'TIME_TERM') {
      _engineStr1 = 'AI는 현재 실시간 분석 중';
      _engineStr2 = 'AI의 다음 신호 발생까지';
      _startTimer(_signal09.remainTime);
    }
    //9시 40분 2번째 신호 발생부터 20분/40분/60분 해당 신호대 신호 발생까지 노출
    else if (_noticeCode == 'TIME_WAIT') {
      _engineStr1 = 'AI는 현재 신호 발생 중';
      _engineStr2 = 'AI는 현재 새로운\nAI매매신호를 발생 중입니다.';
      _startTimerWait();
    }
    //비영업일, 영업일 장종료후
    else {
      _engineStr1 = 'AI는 현재 학습 업데이트 중';
      _engineStr2 = 'AI는 현재 데이터를 수집,\n학습에 반영 중입니다.';
    }
    setState(() {});
  }

  Widget _setDataView() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 80,
      ),
      decoration: UIStyle.boxShadowBasic(16),
      padding: const EdgeInsets.all(15),
      child: (_noticeCode == 'TIME_BEFORE')
          ? _signalOnlyProcessView()
          : Column(
              children: [
                _signalView(),
                //롤링 현황 - 새로운 매매신호 발생(Signal09) / 장 종료 후 - 오늘 매수 / 매도 종목들 롤링
                if (_listSigStatus.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 32,
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                    decoration: UIStyle.boxRoundFullColor8c(
                      RColor.greyBox_f5f5f5,
                    ),
                    child: Swiper(
                      loop: true,
                      autoplay: _listSigStatus.length > 1 ? true : false,
                      autoplayDelay: 4000,
                      scrollDirection: Axis.horizontal,
                      itemCount: _listSigStatus.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_noticeCode == 'TIME_TERM' || _noticeCode == 'TIME_WAIT') {
                          return _setTileSigString(_listSigStatus[index]);
                        } else if (_noticeCode == 'TIME_CLOSE' || _noticeCode == 'TIME_DAWN') {
                          return _setTileSigStringTimeClose(_listSigStatus[index]);
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  //오늘의 매매신호
  Widget _signalView() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _signalProcessView(),
        ),
        Visibility(
          visible: _bTodaySignal,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              _signalCountView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _signalProcessView() {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //장 시작전 대기... 필터중... 작업중
            _noticeCode == 'TIME_BEFORE'
                ? SizedBox(
                    //width: 220,
                    height: 40,
                    child: Swiper(
                        loop: true,
                        autoplay: true,
                        autoplayDelay: 4000,
                        itemCount: _preStartStr.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  _preStartStr[index],
                                  textAlign: TextAlign.center,
                                ),
                              ));
                        }),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: FittedBox(
                          child: Text(
                            _engineStr2,
                            overflow: TextOverflow.ellipsis,
                            //maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _noticeCode == 'TIME_TERM',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$_minute'.padLeft(2, '0'),
                              style: TStyle.commonTitle15,
                            ),
                            const Text(
                              '분 ',
                              style: TextStyle(
                                color: RColor.greyBasic_8c8c8c,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '$_second'.padLeft(2, '0'),
                              style: TStyle.commonTitle15,
                            ),
                            const Text(
                              '초전',
                              style: TextStyle(
                                color: RColor.greyBasic_8c8c8c,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ],
        ),
        onTap: () {
          _showDialogProcess();
        },
      ),
    );
  }

  Widget _signalOnlyProcessView() {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _engineStr1,
              style: TStyle.commonTitle15,
            ),
            //장 시작전 대기... 필터중... 작업중
            _noticeCode == 'TIME_BEFORE'
                ? Container(
                    height: 50,
                    decoration: UIStyle.boxRoundFullColor6c(
                      const Color(0xffF5F5F5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Swiper(
                        loop: true,
                        autoplay: true,
                        autoplayDelay: 4000,
                        itemCount: _preStartStr.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Center(
                            child: Text(
                              _preStartStr[index],
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                  )
                : Center(
                    child: Text(
                      _engineStr2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
        onTap: () {
          _showDialogProcess();
        },
      ),
    );
  }

  Widget _signalCountView() {
    int buyCount = int.parse(_signal09.buyCount);
    int cellCount = int.parse(_signal09.sellCount);
    double buyCirclePadding = _circlePadding[0];
    double cellCirclePadding = _circlePadding[0];
    double buyCircleFontSize = _circleFontSize[0];
    double cellCircleFontSize = _circleFontSize[0];
    if (buyCount > cellCount) {
      buyCirclePadding = _circlePadding[1];
      buyCircleFontSize = _circleFontSize[1];
      cellCirclePadding = _circlePadding[2];
      cellCircleFontSize = _circleFontSize[2];
    } else if (buyCount < cellCount) {
      buyCirclePadding = _circlePadding[2];
      buyCircleFontSize = _circleFontSize[2];
      cellCirclePadding = _circlePadding[1];
      cellCircleFontSize = _circleFontSize[1];
    } else {
      buyCirclePadding = _circlePadding[0];
      buyCircleFontSize = _circleFontSize[0];
      cellCirclePadding = _circlePadding[0];
      cellCircleFontSize = _circleFontSize[0];
    }

    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: buyCount > cellCount
            ? CrossAxisAlignment.start
            : buyCount < cellCount
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
        children: [
          _setCircleText(
            '매수',
            _signal09.buyCount,
            RColor.sigBuy,
            'B',
            buyCirclePadding,
            buyCircleFontSize,
          ),
          _setCircleText(
            '매도',
            _signal09.sellCount,
            RColor.sigSell,
            'S',
            cellCirclePadding,
            cellCircleFontSize,
          ),
        ],
      ),
      onTap: () {
        DefaultTabController.of(context).animateTo(1);
      },
    );
  }

  //매수, 매도 Count
  Widget _setCircleText(
    String title,
    String cnt,
    Color color,
    String tradeFlag,
    double circlePadding,
    double circleFontSize,
  ) {
    return Container(
      padding: EdgeInsets.all(
        circlePadding,
      ),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: circleFontSize,
              color: Colors.white,
            ),
          ),
          Text(
            cnt,
            style: TextStyle(
              color: Colors.white,
              fontSize: circleFontSize + 3,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer(String sTime) {
    _countTimer?.cancel();
    if (sTime.length > 3) {
      _minute = int.parse(sTime.substring(0, 2));
      _second = int.parse(sTime.substring(2, 4));
      _countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_second > 0) {
            _second--;
          } else if (_second == 0) {
            if (_minute > 0) {
              _minute--;
              _second = 59;
            } else if (_minute == 0) {
              _requestTrSignal09();
            }
          }
        });
      });
    } else {
      return;
    }
  }

  void _startTimerWait() {
    _countTimer?.cancel();
    _countTimer = Timer.periodic(const Duration(seconds: 70), (timer) {
      _requestTrSignal09();
    });
  }

  initPage() {
    _requestTrSignal09();
  }

  _requestTrSignal09() {
    _fetchPosts(
        TR.SIGNAL09,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);

    if (trStr == TR.SIGNAL09) {
      final TrSignal09 resData = TrSignal09.fromJson(jsonDecode(response.body));
      _countTimer?.cancel();
      _listSigStatus.clear();
      if (resData.retCode == RT.SUCCESS) {
        _signal09 = resData.resData;
        if (!_signal09.isEmpty()) {
          _initData();
        } else {
          setState(() {
            _signal09 = defSignal09;
          });
        }
      } else {
        setState(() {
          _signal09 = defSignal09;
        });
      }
    }
  }

  //AI 처리 프로세스 다이얼로그
  void _showDialogProcess() {
    String imgPath = 'images/re_img_pop_001.png';
    if (_noticeCode == 'TIME_BEFORE') {
      imgPath = 'images/re_img_pop_003.png';
    }
    //장시작 후 첫 신호 발생전까지
    else if (_noticeCode == 'TIME_OPEN') {
      imgPath = 'images/re_img_pop_004.png';
    }
    //9시 20분 첫 신호 발생부투 다음 신호 발생 정각까지 20분 단위 카운트 다운
    else if (_noticeCode == 'TIME_TERM') {
      imgPath = 'images/re_img_pop_004.png';
    }
    //9시 40분 2번째 신호 발생부터 20분/40분/60분 해당 신호대 신호 발생까지 노출
    else if (_noticeCode == 'TIME_WAIT') {
      imgPath = 'images/re_img_pop_001.png';
    } else {
      imgPath = 'images/re_img_pop_002.png';
    }

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                    'AI의 처리 프로세스',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 175,
                    child: Image.asset(
                      imgPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    'AI는 처리 프로세스에 따라 각 시점에서 '
                    '역할을 수행하며 이 과정을 통해 최적의 매매타이밍에서 '
                    'AI매매신호를 발생시킵니다.',
                    style: TStyle.textMGrey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
