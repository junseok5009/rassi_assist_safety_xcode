import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare01.dart';
import 'package:rassi_assist/models/tr_compare/tr_compare02.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
22.10.07 made by HJS
http 프로토콜 프로세스 모음 클래스입니다.
0001 : [ 로그인 전 사용자 정보 조회 + 토큰 / 디바이스 체크 프로세스 ] // - user02(사용자 정보 조회) > push01(토큰 등록) > user03
                                                                                   > user03(디바이스 정보 등록) > push03 > 메인
 */

class TestHttpClass {
  String TAG = 'TestHttpClass';
  int _call_num = 0000;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late BuildContext _context;
  late SharedPreferences _prefs;
  String _token = '';
  String _userId = '';

  TestHttpClass._privateConstructor();

  static final TestHttpClass _instance = TestHttpClass._privateConstructor();

  factory TestHttpClass() {
    return _instance;
  }

  Future<bool> joinHttpProcess(BuildContext _vContext) async {
    _context = _vContext;
    _call_num = 0001;
    _prefs = await SharedPreferences.getInstance()
        .whenComplete(() => {_userId = 'hjs14233b',});
    _token = (await FirebaseMessaging.instance.getToken()) ?? '';

    return await _fetchPosts(TR.COMPARE01,
        jsonEncode(<String, String>{
          'userId': _userId,
        })).then((value) => value);
  }

  /* void _parseTr0001(String trStr, final http.Response response){
    DLog.d(TAG, response.body);

    // 사용자 정보 조회
    if(trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        final User02 data = resData.retData;
        DLog.d(TAG, data.toString());

        if(data.userId.isNotEmpty) {
          _prefs.setString(Const.PREFS_USER_ID, data.userId);
          DLog.d(TAG, 'token : $_token');

          if(_token != null && _token != '') {
            _fetchPosts(TR.PUSH01, jsonEncode(<String, String>{
              'userId': data.userId,
              'appEnv': 'EN20',
              'deviceId': _getDeviceId(),
              'pushToken': _token,
            }));
          } else {
            showToast('푸시 알림이 등록 되지 않았습니다.');
            _goNextRoute(_strId);
          }

        } else {
          //매매비서 DB에 회원정보 없을 경우 생성
          _fetchPosts(TR.USER01,
              jsonEncode(<String, String>{
                'userId': _strId,
                'userStatus': 'N',
                'encHp': '',
                'appEnv': 'EN20',
                'userGroup': 'UGTA',
              }));
        }
      } else {    //사용자 조회 실패
        //회원정보 없을 경우 회원정보 생성 후 -> 로그인 완료
        showToast('Login fail code : ${resData.retCode}');

        //매매비서 DB에 회원정보 없을 경우 생성
        _fetchPosts(TR.USER01,
            jsonEncode(<String, String>{
              'userId': _strId,
              'userStatus': 'N',
              'encHp': '',
              'appEnv': 'EN20',
              'userGroup': 'UGTA',
            }));
      }
    }

    if (trStr == TR.USER01) {
      final TrUser01 resData = TrUser01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_USER_ID, _strId);

        if(_token != null && _token != '') {
          _fetchPosts(TR.PUSH01,
              jsonEncode(<String, String> {
                'userId': _strId,
                'appEnv': 'EN20',
                'deviceId': _getDeviceId(),
                'pushToken': _token,
              }));
        } else {
          showToast('푸시 알림이 등록 되지 않았습니다.');
          _goNextRoute(_strId);
        }
      } else {
        //매매비서 계정 생성 실패
        _showDialogMsg('CODE : ${resData.retCode}\n' +
            '${resData.retMsg}\n고객센터에 문의해 주세요.');
      }
    }

    //푸시 토큰 등록
    if(trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token);
      }
      else {  //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }

      _fetchPosts(TR.USER03, jsonEncode(<String, String> {
        'userId': _strId,
        'appEnv': 'EN20',
        'deviceModel': deviceModel,
        'osVer': deviceOsVer,
        'appVer': Const.APP_VER,
        'adId': _strIDFA,
      }));
    }

    //디바이스 정보 등록
    if(trStr == TR.USER03) {

      _fetchPosts(TR.PUSH03, jsonEncode(<String, String> {
        'userId': _strId,
        'tradeSignalYn': 'Y',
        'rassiroNewsYn': 'N',
        'snsConcernYn': 'N',
        'stockNewsYn': 'N',
        'buySignalYn': 'Y',
        'catchBriefYn': 'Y',
        'issueYn': 'Y',
        'keywordYn': 'Y',
        'catchSubsYn': 'Y',
        'noticeYn': 'N',
      }));
    }

    //푸시 알림 기본값 설정
    if(trStr == TR.PUSH03) {
      _goNextRoute(_strId);
    }
  }*/

  Future<bool> _parseTr0001(String trStr, final http.Response response) async {
    DLog.d(TAG, response.body);
    bool _parseTr0001Result = false;

    // 사용자 정보 조회
    if (trStr == TR.COMPARE01) {
      final TrCompare01 resData =
          TrCompare01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final Compare01 data = resData.retData;
        DLog.d(TAG, '${data.toString()}');
      }

      await _fetchPosts(TR.COMPARE02,  jsonEncode(<String, String>{
        'userId': _userId,
      }));

    }

    else if(trStr == TR.COMPARE02){
      final TrCompare02 resData =
      TrCompare02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final Compare02 data = resData.retData;
        DLog.d(TAG, '${data.toString()}');
        _parseTr0001Result = true;
      }else {
        _parseTr0001Result = false;
      }
    }

    return _parseTr0001Result;

  }

  //convert 패키지의 jsonDecode 사용
  Future<bool> _fetchPosts(String trStr, String json) async {
    DLog.d(TAG, trStr + ' ' + json);
    bool _fetchPostsResult = false;

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      switch (_call_num) {
        case 0001:
          {
            //_parseTr0001();
            _fetchPostsResult = await _parseTr0001(trStr, response);
          }
          break;
        default: _fetchPostsResult = false;
      }
      //_parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
      _fetchPostsResult = false;
    } on SocketException catch (_) {
      DLog.d(TAG, 'ERR : SocketException');
      _showDialogNetErr();
      _fetchPostsResult = false;
    }

    return _fetchPostsResult;
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    if (_context != null) {
      showDialog(
          context: _context,
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
                      padding:
                          EdgeInsets.only(top: 20, left: 10, right: 10),
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
                    InkWell(
                      child: Container(
                        width: 140,
                        height: 36,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  void _showDialog(String message) {
    if (_context != null) {
      showDialog(
          context: _context,
          barrierDismissible: true,
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
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Text(
                        message,
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
                    InkWell(
                      child: Container(
                        width: 140,
                        height: 36,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

}
