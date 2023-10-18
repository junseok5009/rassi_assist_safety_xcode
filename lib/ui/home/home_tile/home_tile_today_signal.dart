import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';

import '../../../common/const.dart';
import '../../../common/tstyle.dart';
import '../../../models/tr_signal/tr_signal09.dart';

/// [홈_홈 오늘의 AI매매신호는?] - 2023.09.07 HJS
class HomeTileTodaySignal extends StatefulWidget {
  const HomeTileTodaySignal({Key? key}) : super(key: key);

  @override
  State<HomeTileTodaySignal> createState() => _HomeTileTodaySignalState();
}

class _HomeTileTodaySignalState extends State<HomeTileTodaySignal> {
  Signal09 _signal09 = defSignal09;

  String _noticeCode = '';
  bool _bTodaySignal = false; //오늘 신호 발생 여부
  final List<SignalCount> _listSigStatus = [];
  final List<double> _circlePadding = [18, 22, 11];

  // 프로세스
  String _engineStr1 = '';
  String _engineStr2 = '';
  final List<String> _preStartStr = [
    '장시작 대기, 전일 미거래 종목 필터 중',
    '매수 금지 종목 필터링 작업중, 거래 정지 종목 업데이트',
    '트레이딩 종목 리스트 확정',
    '시세 마스터 생성, Signal bong 생성',
    '종목별 상하한가 생성, 대시보드 초기화, 모니터링 종목 리스트업',
  ];
  Timer? _countTimer;
  int _minute = 0;
  int _second = 0;

  @override
  void initState() {
    super.initState();
    _requestTrSignal09();
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
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 15,
          ),
          _signal09 == null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: UIStyle.boxWithOpacity(),
                  child: CommonView.setNoDataTextView(
                    150,
                    '매매신호를 수신 중입니다.',
                  ),
                )
              : _signal09.isEmpty()
                  ? Container(
                      decoration: UIStyle.boxWithOpacity(),
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
    String cnt = '';
    if (item.tradeCount != null) cnt = item.tradeCount;
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
            horizontal: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeStr,
                style: TStyle.textMGrey,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                honor,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  endStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeStr,
              style: TStyle.textMGrey,
            ),
            const SizedBox(
              width: 7,
            ),
            const Text('새로운 '),
            Text(
              preStr,
              style: TextStyle(color: stColor, fontWeight: FontWeight.bold),
            ),
            const Text('가 '),
            Text(
              '$cnt종목',
              style: TStyle.subTitle,
            ),
            const Text('에서 발생')
          ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              item.stockName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(
            width: 4,
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
      onTap: () {
        DefaultTabController.of(context).animateTo(1);
      },
    );
  }

  _initData() async {
    _listSigStatus.clear();
    _listSigStatus.addAll(_signal09.listData);
    _noticeCode = _signal09.noticeCode;
    _bTodaySignal = (_noticeCode == 'TIME_WAIT' ||
        _noticeCode == 'TIME_TERM' ||
        _noticeCode == 'TIME_CLOSE');

    //장시작 대기, 전일 미거래 종목 필터링중(08시 ~ 개장전)
    if (_noticeCode == 'TIME_BEFORE') {
      _engineStr1 = 'AI는 현재 데이터 처리 중';
      _engineStr2 = '';
    }
    //장시작 후 첫 신호 발생전까지
    else if (_noticeCode == 'TIME_OPEN') {
      _engineStr1 = 'AI는 현재 신호 발생 중';
      _engineStr2 = '새로운 AI매매신호가 발생중입니다.';
    }
    //9시 20분 첫 신호 발생부터 다음 신호 발생 정각까지 20분 단위 카운트 다운
    else if (_noticeCode == 'TIME_TERM') {
      _engineStr1 = 'AI는 현재 실시간 분석 중';
      _engineStr2 = '다음 신호 발생까지';
      if (_signal09.remainTime != null) _startTimer(_signal09.remainTime);
    }
    //9시 40분 2번째 신호 발생부터 20분/40분/60분 해당 신호대 신호 발생까지 노출
    else if (_noticeCode == 'TIME_WAIT') {
      _engineStr1 = 'AI는 현재 신호 발생 중';
      _engineStr2 = '새로운 AI매매신호가 발생중입니다.';
      _startTimerWait();
    }
    //비영업일, 영업일 장종료후
    else {
      _engineStr1 = 'AI는 현재 학습 업데이트 중';
      _engineStr2 = '데이터를 수집하여 학습에 반영중입니다.';
    }
  }

  Widget _setDataView() {
    return Container(
      margin: const EdgeInsets.symmetric(
          //horizontal: 10,
          //vertical: 10,
          ),
      constraints: const BoxConstraints(
        minHeight: 80,
      ),
      decoration: UIStyle.boxWithOpacity(),
      padding: const EdgeInsets.all(15),
      child: (_noticeCode == 'TIME_DAWN' ||
              _noticeCode == 'TIME_BEFORE' ||
              _noticeCode == 'TIME_OPEN')
          ? _signalOnlyProcessView()
          : Column(
              children: [
                _signalView(),
                //롤링 현황 - 새로운 매매신호 발생(Signal09) / 장 종료 후 - 오늘 매수 / 매도 종목들 롤링
                Visibility(
                  visible: _listSigStatus.isNotEmpty,
                  child: Container(
                    width: double.infinity,
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                    decoration: UIStyle.boxRoundFullColor6c(
                      RColor.bgWeakGrey,
                    ),
                    child: Swiper(
                      loop: true,
                      autoplay: _listSigStatus.length < 2 ? false : true,
                      autoplayDelay: 4000,
                      scrollDirection: Axis.horizontal,
                      itemCount: _listSigStatus.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_noticeCode == 'TIME_TERM' ||
                            _noticeCode == 'TIME_WAIT') {
                          return _setTileSigString(_listSigStatus[index]);
                        } else if (_noticeCode == 'TIME_CLOSE') {
                          return _setTileSigStringTimeClose(
                              _listSigStatus[index]);
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
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
          visible: _bTodaySignal && _signal09.buyCount != '0' ||
              _signal09.sellCount != '0',
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
            Text(
              _engineStr1,
              style: TStyle.commonTitle15,
            ),
            const SizedBox(
              height: 7.0,
            ),
            //장 시작전 대기... 필터중... 작업중
            _noticeCode == 'TIME_BEFORE'
                ? SizedBox(
                    //width: 220,
                    height: 40,
                    child: Swiper(
                        loop: true,
                        autoplay: true,
                        autoplayDelay: 4000,
                        itemCount:
                            _preStartStr != null ? _preStartStr.length : 0,
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
                : Row(
                    children: [
                      Flexible(
                        child: Text(
                          _engineStr2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Visibility(
                        visible: _noticeCode == 'TIME_TERM',
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$_minute'.padLeft(2, '0'),
                              style: TStyle.subTitle,
                            ),
                            const Text(
                              '분 ',
                            ),
                            Text(
                              '$_second'.padLeft(2, '0'),
                              style: TStyle.subTitle,
                            ),
                            const Text(
                              '초전',
                              style: TStyle.subTitle,
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
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _engineStr1,
              style: TStyle.commonTitle15,
            ),
            const SizedBox(
              height: 7.0,
            ),
            //장 시작전 대기... 필터중... 작업중
            _noticeCode == 'TIME_BEFORE'
                ? SizedBox(
                    //width: 220,
                    height: 40,
                    child: Swiper(
                        loop: true,
                        autoplay: true,
                        autoplayDelay: 4000,
                        itemCount:
                            _preStartStr != null ? _preStartStr.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(_preStartStr[index]);
                        }),
                  )
                : Text(
                    _engineStr2,
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
    if (buyCount > cellCount) {
      buyCirclePadding = _circlePadding[1];
      cellCirclePadding = _circlePadding[2];
    } else if (buyCount < cellCount) {
      buyCirclePadding = _circlePadding[2];
      cellCirclePadding = _circlePadding[1];
    } else {
      buyCirclePadding = _circlePadding[0];
      cellCirclePadding = _circlePadding[0];
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
          ),
          _setCircleText(
            '매도',
            _signal09.sellCount,
            RColor.sigSell,
            'S',
            cellCirclePadding,
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            cnt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer(String sTime) {
    DLog.e('_startTimer() sTime : $sTime');
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

  _requestTrSignal09() {
    _fetchPosts(
        TR.SIGNAL09,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.SIGNAL09) {
      final TrSignal09 resData = TrSignal09.fromJson(jsonDecode(response.body));
      _countTimer?.cancel();
      if (resData.retCode == RT.SUCCESS) {
        _signal09 = resData.resData;
        if (!_signal09.isEmpty()) {
          _initData();
        }
      } else {
        _signal09 = defSignal09;
      }
      setState(() {});
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
                    'AI의 처리 프로세스',
                    style: TStyle.defaultTitle,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                    height: 15.0,
                  ),
                  const Text(
                    'AI는 처리 프로세스에 따라 각 시점에서\n'
                    '역할을 수행하며 이 과정을 통해 최적의 매매타이밍\n'
                    'AI매매신호를 발생시켜 알려드립니다.',
                    style: TStyle.textSGrey,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
