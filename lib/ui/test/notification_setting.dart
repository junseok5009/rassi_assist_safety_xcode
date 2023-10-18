import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_push03.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.02.04
/// 알림설정 (TODO 기존 알림 설정 - 삭제 예정)
class NotificationSetting extends StatelessWidget {
  static const routeName = '/page_notification_setting';
  static const String TAG = "[NotificationSetting]";
  static const String TAG_NAME = '알림설정';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: NotificationSetWidget(),
      ),
    );
  }
}

class NotificationSetWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotificationSetState();
}

class NotificationSetState extends State<NotificationSetWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true;    //true: 아직 화면이 사라지기 전

  bool _bSignal = false;
  bool _bRassiro = false;
  bool _bSocial = false;
  bool _bStkInfo = false;
  bool _bCatchBuy = false;    //신규매수
  bool _bCatchBrief = false;  //캐치브리핑
  bool _bCatchIssue = false;  //이슈
  bool _bTodayInfo = false;   //오늘의 이슈, 유용한 소식
  bool _bUseInfo = false;     //알림모드 사용

  String sSignalYn = 'N';
  String sRassiroYn = 'N';
  String sSocialYn = 'N';
  String sStkInfoYn = 'N';
  String sTodaySigYn = 'N';
  String sCatchBrief = 'N';
  String sCatchIssue = 'N';
  String sNoticeYn = 'N';


  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NotificationSetting.TAG_NAME);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 300), (){
      DLog.d(NotificationSetting.TAG, "delayed user id : $_userId");

      if(_userId != '') {
        _fetchPosts(TR.PUSH04, jsonEncode(<String, String>{
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('알림설정', style: TStyle.title18,),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: ListView(
          children: [

            //캐치 부분
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSubTitle('나의 종목 알림'),

                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('매매비서의 AI매매신호', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bSignal,
                    onChanged: (value){
                      setState(() {
                        _bSignal = value;
                        if(value) {
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
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI속보', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bRassiro,
                    onChanged: (value){
                      setState(() {
                        _bRassiro = value;
                        if(value) {
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
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('소셜지수', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bSocial,
                    onChanged: (value){
                      setState(() {
                        _bSocial = value;
                        if(value) sSocialYn = 'Y';
                        else sSocialYn = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('내 종목 소식', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bStkInfo,
                    onChanged: (value){
                      setState(() {
                        _bStkInfo = value;
                        if(value) sStkInfoYn = 'Y';
                        else sStkInfoYn = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),

            //캐치 부분
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSubTitle('종목 캐치 알림'),

                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('신규 매수', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchBuy,
                    onChanged: (value){
                      setState(() {
                        _bCatchBuy = value;
                        if(value) sTodaySigYn = 'Y';
                        else sTodaySigYn = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('캐치브리핑(매도성과, 인기종목)', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchBrief,
                    onChanged: (value){
                      setState(() {
                        _bCatchBrief = value;
                        if(value) sCatchBrief = 'Y';
                        else sCatchBrief = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('이슈&이슈', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bCatchIssue,
                    onChanged: (value){
                      setState(() {
                        _bCatchIssue = value;
                        if(value) sCatchIssue = 'Y';
                        else sCatchIssue = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),


            //라씨 소식
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSubTitle('라씨 소식'),
                ],
              ),
            ),
            const Divider(height: 1,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('오늘의 이슈 및 라씨의 유용한 소식', style: TStyle.content16,),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: RColor.mainColor,
                    value: _bTodayInfo,
                    onChanged: (value){
                      setState(() {
                        _bTodayInfo = value;
                        if(value) sNoticeYn = 'Y';
                        else sNoticeYn = 'N';
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1,),


            //알림 모드 설정
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 15),
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       _setSubTitle('알림 모드 설정'),
            //     ],
            //   ),
            // ),
            // Divider(height: 1,),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text('알림 모드 사용'),
            //       Switch(
            //         activeColor: Colors.white,
            //         activeTrackColor: RColor.mainColor,
            //         value: _bUseInfo,
            //         onChanged: (value){
            //           setState(() {
            //             _bUseInfo = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // Divider(height: 1,),
            const SizedBox(height: 30,),

            const Center(
              child: Text('모든 알림 설정은 저장을 눌러주셔야 반영이 됩니다.',
                style: TStyle.textGrey14,),
            ),
            const SizedBox(height: 10,),

            MaterialButton(
              child: Center(
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Center(
                    child: Text('저장', style: TStyle.btnTextWht17,),),
                ),
              ),
              onPressed: (){
                _fetchPosts(TR.PUSH03, jsonEncode(<String, String>{
                  'userId': _userId,
                  'tradeSignalYn': sSignalYn,
                  'rassiroNewsYn': sRassiroYn,
                  'snsConcernYn': sSocialYn,
                  'stockNewsYn': sStkInfoYn,
                  'buySignalYn': sTodaySigYn,
                  'catchBriefYn': sCatchBrief,
                  'issueYn': sCatchIssue,
                  'noticeYn': sNoticeYn,
                }));
              },
            ),
            const SizedBox(height: 30,),

          ],
        ),
      ),
    );
  }


  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Text(
        subTitle,
        style: TStyle.title17,
      ),
    );
  }

  //설명 영역
  Widget _setDescription(String desc) {
    return // -------------------------------------------------------
      Padding(
        padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(desc, style: TStyle.textSGrey,),
            InkWell(
              child: const ImageIcon(AssetImage('images/rassi_icon_qu_bl.png',),
                size: 22, color: Colors.grey,),
              onTap: (){
                // _showDialogTopDesc();
              },
            )
          ],
        ),
      );
  }


  _setViewData(String sigYn, String rasYn, String socYn, String sInfoYn,
      String tBuyYn, String brfYn, String issYn, String notiYn) {
    if(sigYn == 'Y') _bSignal = true;
    else _bSignal = false;
    if(rasYn == 'Y') _bRassiro = true;
    else _bRassiro = false;
    if(socYn == 'Y') _bSocial = true;
    else _bSocial = false;
    if(sInfoYn == 'Y') _bStkInfo = true;
    else _bStkInfo = false;

    if(tBuyYn == 'Y') _bCatchBuy = true;
    else _bCatchBuy = false;
    if(brfYn == 'Y') _bCatchBrief = true;
    else _bCatchBrief = false;
    if(issYn == 'Y') _bCatchIssue = true;
    else _bCatchIssue = false;
    if(notiYn == 'Y') _bTodayInfo = true;
    else _bTodayInfo = false;

    setState(() {});
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
    DLog.d(NotificationSetting.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(NotificationSetting.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(NotificationSetting.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NotificationSetting.TAG, response.body);

    if(trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {

        Push04 item = resData.retData;
        sSignalYn = item.tradeSignalYn;
        sRassiroYn = item.rassiroNewsYn;
        sSocialYn = item.snsConcernYn;
        sStkInfoYn = item.stockNewsYn;
        sTodaySigYn = item.buySignalYn;
        sCatchBrief = item.catchBriefYn;
        sCatchIssue = item.issueYn;
        sNoticeYn = item.noticeYn;

        _setViewData(sSignalYn, sRassiroYn, sSocialYn, sStkInfoYn, sTodaySigYn,
            sCatchBrief, sCatchIssue, sNoticeYn);
      }
    }

    else if(trStr == TR.PUSH03) {
      final TrPush03 resData = TrPush03.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        commonShowToast('설정 변경이 저장되었습니다.');
      } else {

      }
    }

  }
}