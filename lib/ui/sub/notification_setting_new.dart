import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_push03.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.07.13
/// 알림설정 new
class NotificationSettingN extends StatefulWidget {
  static const routeName = '/page_notification_setting_n';
  static const String TAG = "[NotificationSettingN] ";
  static const String TAG_NAME = '알림설정';

  const NotificationSettingN({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NotificationSettingNState();
}

class NotificationSettingNState extends State<NotificationSettingN> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  final double cHeight = 75;

  bool _bSignal = false;
  bool _bRassiro = false;
  bool _bSocial = false;
  bool _bStkInfo = false; //종목소식(스톡벨)
  //bool _bNewBuy = false;      //신규매수
  bool _bNewIssue = false; //이슈
  bool _bCatchBrief = false; //캐치브리핑
  bool _bCatchBig = false;

  //bool _bCatchTheme = false;
  bool _bCatchTop = false;
  bool _bNotice = false; //오늘의 이슈, 유용한 소식, 공지알림, 이벤트

  String sSignalYn = 'N';
  String sRassiroYn = 'N';
  String sSocialYn = 'N';
  String sStkInfoYn = 'N';
  String _sNewBuyYn = 'N';
  String sNewIssue = 'N';
  String sCatchBrief = 'N';
  String sCatchBig = 'N';
  String sCatchTheme = 'N';
  String sCatchTop = 'N';
  String sNoticeYn = 'N';

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: NotificationSettingN.TAG_NAME,
      screenClassOverride: NotificationSettingN.TAG_NAME,
    );

    _loadPrefData().then(
      (value) {
        if (_userId != '') {
          _fetchPosts(
              TR.PUSH04,
              jsonEncode(<String, String>{
                'userId': _userId,
              }));
        }
      },
    );
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(context, '알림설정'),
      body: SafeArea(
        child: ListView(
          children: [
            // ======= 포켓 종목 부분 =======
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setSubTitle('나의 포켓 종목 알림'),
                  _setDescription(RString.desc_notify_pocket, 1),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //AI매매신호
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _setSwitchLabel('매매비서의 AI매매신호', 'TS'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bSignal,
                    onChanged: (value) {
                      setState(() {
                        _bSignal = value;
                        if (value) {
                          sSignalYn = 'Y';
                        } else {
                          sSignalYn = 'N';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //AI속보
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _setSwitchLabel('AI속보', 'RN'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bRassiro,
                    onChanged: (value) {
                      setState(() {
                        _bRassiro = value;
                        if (value) {
                          sRassiroYn = 'Y';
                        } else {
                          sRassiroYn = 'N';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //소셜지수
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _setSwitchLabel('소셜지수', 'SN'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bSocial,
                    onChanged: (value) {
                      setState(() {
                        _bSocial = value;
                        if (value) {
                          sSocialYn = 'Y';
                        } else {
                          sSocialYn = 'N';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //내 종목 소식
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _setSwitchLabel('내 종목 소식', 'SB'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bStkInfo,
                    onChanged: (value) {
                      setState(() {
                        _bStkInfo = value;
                        if (value) {
                          sStkInfoYn = 'Y';
                        } else {
                          sStkInfoYn = 'N';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            // ======= 종목 캐치 알림 부분 =======
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setSubTitle('종목 캐치 알림'),
                  _setDescription(RString.desc_notify_stk_catch, 2),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            //큰손들의 종목캐치
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSwitchLabel('큰손들의 종목캐치', 'SC_BIG'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchBig,
                    onChanged: (value) {
                      setState(() {
                        _bCatchBig = value;
                        if (value)
                          sCatchBig = 'Y';
                        else
                          sCatchBig = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            //테마 캐치
            // Container(
            //   height: cHeight,
            //   padding: const EdgeInsets.symmetric(horizontal: 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       _setSwitchLabel('테마 캐치'),
            //       Switch(
            //         activeColor: Colors.white,
            //         activeTrackColor: RColor.mainColor,
            //         value: _bCatchTheme,
            //         onChanged: (value){
            //           setState(() {
            //             _bCatchTheme = value;
            //             if(value) sCatchTheme = 'Y';
            //             else sCatchTheme = 'N';
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // const Divider(height: 1,),
            //성과 TOP 종목 캐치
            Container(
              height: cHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSwitchLabel('성과 TOP 종목 캐치', 'SC_TOP'),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchTop,
                    onChanged: (value) {
                      setState(() {
                        _bCatchTop = value;
                        if (value)
                          sCatchTop = 'Y';
                        else
                          sCatchTop = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            // ======= 라씨 소식 =======
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setSubTitle('라씨 소식'),
                  _setDescription(RString.desc_notify_info, 3),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '라씨 브리핑(매도성과, 인기종목)',
                    style: TStyle.content17,
                  ),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchBrief,
                    onChanged: (value) {
                      setState(() {
                        _bCatchBrief = value;
                        if (value)
                          sCatchBrief = 'Y';
                        else
                          sCatchBrief = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //오늘의 이슈
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 이슈',
                    style: TStyle.content17,
                  ),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bNewIssue,
                    onChanged: (value) {
                      setState(() {
                        _bNewIssue = value;
                        if (value)
                          sNewIssue = 'Y';
                        else
                          sNewIssue = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),

            //공지, 이벤트 및 유용한 소식
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이벤트 및 유용한 소식',
                    style: TStyle.content17,
                  ),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bNotice,
                    onChanged: (value) {
                      setState(() {
                        _bNotice = value;
                        if (value)
                          sNoticeYn = 'Y';
                        else
                          sNoticeYn = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            const SizedBox(
              height: 30,
            ),

            // ======= 알림 설정 저장 =======
            Center(
              child: Text(
                '모든 알림 설정은 저장을 눌러주셔야 반영이 됩니다.',
                style: TStyle.textGrey14,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              child: Center(
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Center(
                    child: Text(
                      '저장',
                      style: TStyle.btnTextWht17,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                _fetchPosts(
                    TR.PUSH03,
                    jsonEncode(<String, String>{
                      'userId': _userId,
                      'tradeSignalYn': sSignalYn,
                      'rassiroNewsYn': sRassiroYn,
                      'snsConcernYn': sSocialYn,
                      'stockNewsYn': sStkInfoYn,
                      'catchBriefYn': sCatchBrief,
                      'catchBighandYn': sCatchBig,
                      'catchThemeYn': sCatchTheme,
                      'catchTopYn': sCatchTop,
                      // 'buySignalYn': sNewBuyYn,     //신규 매수 알림
                      'issueYn': sNewIssue,
                      'noticeYn': sNoticeYn,
                    }));
              },
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  // 타이틀
  Widget _setSwitchLabel(String label, String type) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TStyle.content17,
        ),
        InkWell(
          child: Text(
            '어떤 알림을 받을지 궁금해요',
            style: TStyle.ulTextGreySmall,
          ),
          onTap: () {
            _showDialogDesc(type);
          },
        ),
      ],
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 19, bottom: 8),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  //설명 영역
  Widget _setDescription(String desc, int type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 21),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              desc,
              style: TStyle.textMGrey,
            ),
          ),
          InkWell(
            child: const ImageIcon(
              AssetImage(
                'images/rassi_icon_qu_bl.png',
              ),
              size: 22,
              color: Colors.grey,
            ),
            onTap: () {
              if (type == 1) {
                _showDialogMsg(RString.dl_info_notification_pocket);
              } else if (type == 2) {
                _showDialogMsg(RString.dl_info_notification_catch);
              } else if (type == 3) {
                _showDialogMsg(RString.dl_info_notification_rassi);
              }
            },
          )
        ],
      ),
    );
  }

  _setViewData(
      String sigYn,
      String rasYn,
      String socYn,
      String sInfoYn,
      String nBuyYn,
      String brfYn,
      String bigYn,
      String thmYn,
      String topYn,
      String issYn,
      String notiYn) {
    if (sigYn == 'Y')
      _bSignal = true;
    else
      _bSignal = false;
    if (rasYn == 'Y')
      _bRassiro = true;
    else
      _bRassiro = false;
    if (socYn == 'Y')
      _bSocial = true;
    else
      _bSocial = false;
    if (sInfoYn == 'Y')
      _bStkInfo = true;
    else
      _bStkInfo = false;

    if (brfYn == 'Y')
      _bCatchBrief = true;
    else
      _bCatchBrief = false;
    if (bigYn == 'Y')
      _bCatchBig = true;
    else
      _bCatchBig = false;
    //if(thmYn == 'Y') _bCatchTheme = true;
    //else _bCatchTheme = false;
    if (topYn == 'Y')
      _bCatchTop = true;
    else
      _bCatchTop = false;

    //if(nBuyYn == 'Y') _bNewBuy = true;
    //else _bNewBuy = false;
    if (issYn == 'Y')
      _bNewIssue = true;
    else
      _bNewIssue = false;
    if (notiYn == 'Y')
      _bNotice = true;
    else
      _bNotice = false;

    setState(() {});
  }

  // 다이얼로그 - 알림 설정 안내
  void _showDialogMsg(String message) {
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
                  const Text('알림 설정 안내',
                      style: TStyle.defaultTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text('$message',
                      textAlign: TextAlign.center,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showDialogDesc(String type) {
    String title = '';
    String content = '';
    String permission = '';
    if (type == 'TS') {
      title = '매매비서의 AI매매신호';
      content =
          '나의 포켓에 관심 또는 보유종목으로 등록된 종목에 대해서 AI매매신호 또는 나만의 매도신호가 발생했을 때 알려드립니다.';
      permission = '이용권한 : 프리미엄 계정 또는 3종목알림 회원님';
    } else if (type == 'RN') {
      title = 'AI속보';
      content = 'AI가 분석한 속보가 발생하면 알려드립니다. 나의 포켓에 종목이 많을 경우 알림 빈도가 높을 수 있어요.';
      permission = '이용권한 : 모든 회원님';
    } else if (type == 'SN') {
      title = '소셜지수';
      content =
          '종목의 소셜지수가 폭발했을 경우에 알려드립니다.\n소셜지수가 폭발하면 해당 종목에 특별한 이슈가 있을 수 있으니 꼭 확인해 보세요.';
      permission = '이용권한 : 모든 회원님';
    } else if (type == 'SB') {
      title = '내 종목 소식';
      content =
          '시세 급변, 거래량 급변, 변동성 급변이 있을 때 실시간 알림으로 알려드립니다. 나의 포켓에 종목이 많을 경우 알림 빈도가 높을 수 있어요.';
      permission = '이용권한 : 모든 회원님';
    } else if (type == 'SC_BIG') {
      title = '큰손들의 종목캐치';
      content = '외국인, 기관이 집중매수하는 종목에서 라씨 매매비서의 매수 신호가 발생할 경우 알려드립니다.';
      permission = '이용권한 : 프리미엄 계정 회원님';
    } else if (type == 'SC_THM') {
      title = '테마캐치';
      content = '테마에 속한 종목들 중에 라씨 매매비서의 신규 매수 신호가 발생할 경우 알려드립니다.';
      permission = '이용권한 : 프리미엄 계정 회원님';
    } else if (type == 'SC_TOP') {
      title = '성과 TOP 종목캐치';
      content = '다양한 부분의 성과 지표에서 우수한 성과를 내고 있는 종목의 신규 매수가 발생할 경우 알려드립니다.';
      permission = '이용권한 : 프리미엄 계정 회원님';
    } else if (type == '') {
      title = '';
      content = '';
      permission = '';
    }

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '$title',
                  style: TStyle.defaultTitle,
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  child: Icon(
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
                    height: 20.0,
                  ),
                  Text(
                    '$content',
                    style: TStyle.defaultContent,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    '$permission',
                    style: TextStyle(
                      color: RColor.mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 30.0,),
                ],
              ),
            ),
          );
        });
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
                  child: Icon(
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
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Text(
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
                        child: Center(
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
    DLog.d(NotificationSettingN.TAG, trStr + ' ' + json);

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
      DLog.d(NotificationSettingN.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(NotificationSettingN.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NotificationSettingN.TAG, response.body);

    if (trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Push04? item = resData.retData;
        if(item != null) {
          sSignalYn = item.tradeSignalYn;
          sRassiroYn = item.rassiroNewsYn;
          sSocialYn = item.snsConcernYn;
          sStkInfoYn = item.stockNewsYn;
          _sNewBuyYn = item.buySignalYn;
          sCatchBrief = item.catchBriefYn;
          sNewIssue = item.issueYn;
          sCatchBig = item.catchBighandYn;
          sCatchTheme = item.catchThemeYn;
          sCatchTop = item.catchTopYn;
          sNoticeYn = item.noticeYn;

          _setViewData(
              sSignalYn,
              sRassiroYn,
              sSocialYn,
              sStkInfoYn,
              _sNewBuyYn,
              sCatchBrief,
              sCatchBig,
              sCatchTheme,
              sCatchTop,
              sNewIssue,
              sNoticeYn);
        }
      }
    } else if (trStr == TR.PUSH03) {
      final TrPush03 resData = TrPush03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        commonShowToast('설정 변경이 저장되었습니다.');
      } else {}
    }
  }
}
