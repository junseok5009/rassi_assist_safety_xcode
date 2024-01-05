import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal06.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';

/// 2020.11.23
/// 오늘의 매매신호 현황
class SignalTodayPage extends StatefulWidget {
  static const routeName = '/page_signal_today';
  static const String TAG = "[SignalTodayPage]";
  static const String TAG_NAME = '매매신호_오늘발생한신호';

  const SignalTodayPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignalTodayPageState();
}

class SignalTodayPageState extends State<SignalTodayPage> {
  late SharedPreferences _prefs;
  String _userId = '';
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String _strBS = ''; //매수, 매도
  String _tradeFlag = '';
  String _signalCount = ''; //전제 signal count
  String _honorCount = ''; //성과 TOP 종목 count
  Color _statColor = Colors.grey;
  String _isHonorYn = 'N';
  bool _isBuyList = true;
  bool _bSelectA = true, _bSelectB = false;

  final List<TimeLineSig> _listData = [];
  late ScrollController _scrollController;
  int _pageNum = 0;
  String pageSize = '20';

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SignalTodayPage.TAG_NAME,);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (deviceModel.contains('iPad')) {
        pageSize = '40';
      }

      if (_userId != '') {
        _fetchPosts(
            TR.SIGNAL06,
            jsonEncode(<String, String>{
              'userId': _userId,
              'tradeFlag': _tradeFlag, //B:매수, S:매도, 미입력시 전체조회
              'honorYn': _isHonorYn, //명예의 전당 종목만 only
              'pageNo': _pageNum.toString(),
              'pageItemSize': pageSize,
            }));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // DLog.d(SignalTodayPage.TAG, 'Device Model : ' + iosInfo.model);
      DLog.d(SignalTodayPage.TAG,
          'Device Model : ${iosInfo.utsname.machine}'); //모델별 모델명
      DLog.d(SignalTodayPage.TAG, 'OS Ver : ${iosInfo.systemVersion}');

      setState(() {
        _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
        deviceModel = iosInfo.model!;
      });
    } else if (Platform.isAndroid) {
      setState(() {
        _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      });
    }
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData(false);
    } else {}
  }

  _requestData(bool bInit) {
    DLog.d(SignalTodayPage.TAG, '### requestData');
    if (bInit) {
      //초기화
      _listData.clear();
      _pageNum = 0;
    }

    _fetchPosts(
        TR.SIGNAL06,
        jsonEncode(<String, String>{
          'userId': _userId,
          'tradeFlag': _tradeFlag, //B:매수, S:매도, 미입력시 전체조회
          'honorYn': _isHonorYn, //명예의 전당 종목만 only
          'pageNo': _pageNum.toString(),
          'pageItemSize': '20',
        }));
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _tradeFlag = args.flag;
    _signalCount = args.pgData ?? '';

    if (_tradeFlag == 'B') {
      _strBS = '매수';
      _statColor = RColor.bgBuy;
      _isBuyList = true;
    } else if (_tradeFlag == 'S') {
      _strBS = '매도';
      _statColor = RColor.bgSell;
      _isBuyList = false;
    }

    return Scaffold(
      backgroundColor: RColor.bgWeakGrey,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '오늘 발생한 AI매매신호',
        elevation: 1,
      ),
      //타임라인 리스트
      body: SafeArea(
        child: Column(
          children: [
            _setFlagBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                itemCount: _listData.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeader();
                  } else {
                    return _buildOneItem(_listData[index - 1].elapsedTmTx,
                        _listData[index - 1].listData);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setFlagBar() {
    return Container(
      height: 60,
      color: _statColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 15.0,
          ),
          Image.asset(
            'images/rassi_itemar_icon_1.png',
            height: 17,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            '현재',
            style: TStyle.commonSTitle,
          ),
          const SizedBox(
            width: 5.0,
          ),
          Chip(
            backgroundColor: Colors.black,
            label: Text(
              ' $_strBS ',
              style: TextStyle(
                //볼드 [매수] 컬러
                fontSize: 16, fontWeight: FontWeight.w600,
                color: _statColor,
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            '총',
            style: TStyle.commonSTitle,
          ),
          Text(
            _signalCount,
            style: TStyle.btnTextWht15,
          ),
          const Text(
            '종목',
            style: TStyle.commonSTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '성과 TOP ',
                style: TStyle.title18T,
              ),
              Text(
                '종목 중',
                style: TStyle.content17T,
              ),
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          Row(
            children: [
              Text(
                '$_honorCount개 종목',
                style: TStyle.textBBuy,
              ),
              const Text(
                '에서',
                style: TStyle.content17T,
              ),
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            '새로운 $_strBS 신호가',
            style: TStyle.content17T,
          ),
          const SizedBox(
            height: 3,
          ),
          const Text(
            '발생하였습니다.',
            style: TStyle.content17T,
          ),
          const SizedBox(
            height: 20,
          ),
          Visibility(
            visible: true,
            child: _setSelectList(),
          ),
        ],
      ),
    );
  }

  //모든 종목 / 성과 Top 선택 버
  Widget _setSelectList() {
    return Column(
      children: [
        //매수 일때
        Visibility(
          visible: _isBuyList,
          child: Container(
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
                          decoration: _bSelectA
                              ? UIStyle.boxBtnSelectedBuy()
                              : UIStyle.boxBtnUnSelectedBuy(),
                          child: Center(
                            child: Text(
                              '모든 종목보기',
                              style: _bSelectA
                                  ? TStyle.btnTextWht15
                                  : TStyle.textMBuy,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_bSelectB) {
                            setState(() {
                              _bSelectA = true;
                              _bSelectB = false;
                              _isHonorYn = 'N';
                            });
                            _requestData(true);
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
                          decoration: _bSelectB
                              ? UIStyle.boxBtnSelectedBuy()
                              : UIStyle.boxBtnUnSelectedBuy(),
                          child: Center(
                            child: Text(
                              '성과 TOP 종목만 보기',
                              style: _bSelectB
                                  ? TStyle.btnTextWht15
                                  : TStyle.textMBuy,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_bSelectA) {
                            setState(() {
                              _bSelectA = false;
                              _bSelectB = true;
                              _isHonorYn = 'Y';
                            });
                            _requestData(true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //매도 일때
        Visibility(
          visible: !_isBuyList,
          child: Container(
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
                          padding: const EdgeInsets.all(4),
                          decoration: _bSelectA
                              ? UIStyle.boxBtnSelectedSell()
                              : UIStyle.boxBtnUnSelectedSell(),
                          child: Center(
                            child: Text(
                              '모든 종목보기',
                              style: _bSelectA
                                  ? TStyle.btnTextWht15
                                  : TStyle.textMSell,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_bSelectB) {
                            setState(() {
                              _bSelectA = true;
                              _bSelectB = false;
                              _isHonorYn = 'N';
                            });
                            _requestData(true);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          height: 38,
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.all(4),
                          decoration: _bSelectB
                              ? UIStyle.boxBtnSelectedSell()
                              : UIStyle.boxBtnUnSelectedSell(),
                          child: Center(
                            child: Text(
                              '성과 TOP 종목만 보기',
                              style: _bSelectB
                                  ? TStyle.btnTextWht15
                                  : TStyle.textMSell,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_bSelectA) {
                            setState(() {
                              _bSelectA = false;
                              _bSelectB = true;
                              _isHonorYn = 'Y';
                            });
                            _requestData(true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //종목 리스트
  Widget _buildOneItem(String strTime, List<SignalSig> subList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 15,
            top: 15,
          ),
          child: Row(
            children: [
              Image.asset(
                'images/rassi_itemar_icon_ar1.png',
                fit: BoxFit.cover,
                scale: 3,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                strTime,
                style: const TextStyle(
                    fontSize: 14, color: Colors.deepOrangeAccent),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 5),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: RColor.lineGrey,
              width: 0.8,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: subList.length,
              itemBuilder: (context, index) {
                String strTopImg = 'images/main_hnr_win_trade.png';
                if (subList[index].honorDiv == '' ? false : true) {
                  strTopImg = _getTopImage(subList[index].honorDiv);
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              TStyle.getLimitString(
                                  subList[index].stockName, 10),
                              style: TStyle.commonSTitle,
                            ),
                            const SizedBox(
                              width: 3.0,
                            ),
                            Text(
                              subList[index].stockCode,
                              style: TStyle.textSGrey,
                            ),
                            const SizedBox(
                              width: 3.0,
                            ),

                            //TOP 이미지
                            Visibility(
                              visible:
                                  subList[index].honorDiv == '' ? false : true,
                              child: Image.asset(
                                strTopImg,
                                height: 17,
                              ),
                            ),
                          ],
                        ),
                        Text(
                            '${TStyle.getMoneyPoint(subList[index].tradePrice)}원'),
                      ],
                    ),
                    onTap: () {
                      basePageState.goStockHomePage(
                        subList[index].stockCode,
                        subList[index].stockName,
                        Const.STK_INDEX_SIGNAL,
                      );
                    },
                  ),
                );
              }),
        )
      ],
    );
  }

  String _getTopImage(String topType) {
    if (topType.length > 0) {
      if (topType == 'WIN_RATE')
        return 'images/main_hnr_win_trade.png';
      else if (topType == 'PROFIT_10P')
        return 'images/main_hnr_avg_ratio.png';
      else if (topType == 'SUM_PROFIT')
        return 'images/main_hnr_max_ratio.png';
      else if (topType == 'MAX_PROFIT')
        return 'images/main_hnr_win_ratio.png';
      else if (topType == 'AVG_PROFIT')
        return 'images/main_hnr_acc_ratio.png';
      else
        return 'images/main_hnr_win_trade.png';
    }
    return '';
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
    DLog.d(SignalTodayPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SignalTodayPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(SignalTodayPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalTodayPage.TAG, response.body);

    if (trStr == TR.SIGNAL06) {
      final TrSignal06 resData = TrSignal06.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listData.addAll(resData.retData?.listData as Iterable<TimeLineSig>);
        _honorCount = resData.retData?.honorCount as String;

        setState(() {});
      }
    }
  }
}
