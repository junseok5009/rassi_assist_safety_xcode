import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/custom_lib/tripledes/utils.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_user/tr_user01.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
22.10.07 made by HJS
http 프로토콜 프로세스 모음 클래스입니다.

모든 변수 처리는 call--- 함수에 다 등록되어 헷갈리지 않게 합니다.

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
* return 값
성공 : 200
실패
  - 400 : 네트워크 에러로 인한 응답 못받음
  - 401 : USER01 실패
  - 402 : 필수입력코드값 누락

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
0001 : [ 로그인 전 사용자 정보 조회 + 토큰 / 디바이스 체크 프로세스 ]
       - user02(사용자 정보 조회)
         토큰 문제 > push01(토큰 등록) > user03
         문제 없음 > user03(디바이스 정보 등록) > push03 > 메인
         회원 정보 없음 > user01 > push01 > ...

 */

class HttpProcessResultClass {
  final String serverRetCode;
  final String serverRetMsg;
  final int appResultCode;
  final String appDialogMsg;

  HttpProcessResultClass({
    this.serverRetCode = '',
    this.serverRetMsg = '',
    this.appResultCode = 0,
    this.appDialogMsg = '',
  });

  @override
  String toString() {
    return '$serverRetCode | $serverRetMsg | $appResultCode | $appDialogMsg';
  }
}

class HttpProcessClass {
  final String tag = 'HttpProcessClass';

  int _callNum = 0000;
  late HttpProcessResultClass result;

  // 0001 = joinHttpProcess;

  late SharedPreferences _prefs;

  String _token = '';
  String _userId = '';
  late IosDeviceInfo _iosInfo;
  late AndroidDeviceInfo _androidInfo;
  final String _appEnv =
      Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20

  HttpProcessClass._privateConstructor();

  static final HttpProcessClass _instance =
      HttpProcessClass._privateConstructor();

  factory HttpProcessClass() {
    return _instance;
  }

  // 로그인 프로세스 User02 > psuh01, user03
  Future<HttpProcessResultClass> callHttpProcess0001(String vUserId) async {
    DLog.d(tag, 'ㅡㅡㅡㅡㅡ callHttpProcess0001 ㅡㅡㅡㅡㅡ');
    _callNum = 0001;
    _prefs = await SharedPreferences.getInstance();
    //_userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _userId = vUserId;
    _token = (await FirebaseMessaging.instance.getToken()) ?? '';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) _iosInfo = await deviceInfo.iosInfo;
    if (Platform.isAndroid) _androidInfo = await deviceInfo.androidInfo;

    await _fetchPosts(
        TR.USER02,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));

    DLog.d(tag,
        'ㅡㅡㅡㅡㅡ finish callHttpProcess0001 ㅡㅡㅡㅡㅡ \n result : ${result.toString()}');
    return result;
  }

  // 회원가입 프로세스 User01 > psuh01 > push03
  Future<HttpProcessResultClass> callHttpProcess0002({required String vUserId, required String vAgentCode}) async {
    DLog.d(tag, 'ㅡㅡㅡㅡㅡ callHttpProcess0002 ㅡㅡㅡㅡㅡ');
    _callNum = 0002;
    _prefs = await SharedPreferences.getInstance();

    if (vUserId.isEmpty) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    } else {
      _userId = vUserId;
    }
    _token = (await FirebaseMessaging.instance.getToken()) ?? '';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) _iosInfo = await deviceInfo.iosInfo;
    if (Platform.isAndroid) _androidInfo = await deviceInfo.androidInfo;

    await _fetchPosts(
        TR.USER01,
        jsonEncode(<String, String>{
          'userId': vUserId,
          'userStatus': 'N',
          'encHp': '', //씽크풀 가입시 전화번호 입력됨
          'appEnv': _appEnv,
          'userGroup': 'UGTA',
          'groupSubDiv': '',
          if(vAgentCode.isNotEmpty) 'agentCode' : vAgentCode,
        }));

    DLog.d(tag,
        'ㅡㅡㅡㅡㅡ finish callHttpProcess0002 ㅡㅡㅡㅡㅡ \n result : ${result.toString()}');
    return result;
  }

  Future<void> _parse0001(String trStr, final http.Response response) async {
    DLog.d(tag, response.body);

    String? deviceModel =
        Platform.isIOS ? _iosInfo.utsname.machine : _androidInfo.model;
    String? osVersion =
        Platform.isIOS ? _iosInfo.systemVersion : _androidInfo.version.release;

    // 사용자 정보 조회 부터
    if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final User02 data = resData.retData;
        if (data.userId.isNotEmpty) {
          _userId = data.userId;
        }
        await _prefs.setString(Const.PREFS_USER_ID, _userId);
        AppGlobal().userId = _userId;
        if (_token != '') {
          await _fetchPosts(
              TR.PUSH01,
              jsonEncode(<String, String>{
                'userId': data.userId,
                'appEnv': _appEnv,
                'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                'pushToken': _token,
              }));
        } else {
          await _fetchPosts(
              TR.USER03,
              jsonEncode(<String, String>{
                'userId': data.userId,
                'appEnv': _appEnv,
                'deviceModel': deviceModel ?? '',
                'osVer': osVersion ?? '',
                'appVer': Const.APP_VER,
                'adId': await utilsGetIDFA(),
              }));
        }
      } else if (resData.retCode == RT.NOT_RASSI_USER ||
          resData.retCode == RT.NOT_RASSI_USER_NEW) {
        await _fetchPosts(
            TR.USER01,
            jsonEncode(<String, String>{
              'userId': _userId,
              'userStatus': 'N',
              'encHp': '', //씽크풀 가입시 전화번호 입력됨
              'appEnv': _appEnv,
              'userGroup': 'UGTA',
              'groupSubDiv': '',
            }));
      } else {
        result = HttpProcessResultClass(
            serverRetCode: resData.retCode,
            serverRetMsg: resData.retMsg,
            appResultCode: 400,
            appDialogMsg: '네트워크 에러');
      }
    } else if (trStr == TR.USER01) {
      final TrUser01 resData = TrUser01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        await _prefs.setString(Const.PREFS_USER_ID, _userId);
        AppGlobal().userId = _userId;
        if (_token != '') {
          await _fetchPosts(
              TR.PUSH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'appEnv': _appEnv,
                'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                'pushToken': _token,
              }));
        } else {
          await _fetchPosts(
              TR.USER03,
              jsonEncode(<String, String>{
                'userId': _userId,
                'appEnv': _appEnv,
                'deviceModel': deviceModel ?? '',
                'osVer': osVersion ?? '',
                'appVer': Const.APP_VER,
                'adId': await utilsGetIDFA(),
              }));
        }
      } else if (resData.retCode == RT.ESSENTIAL_FIELD_MISSING) {
        //필수 입력 필드 값 누락
        result = HttpProcessResultClass(
            serverRetCode: resData.retCode,
            serverRetMsg: resData.retMsg,
            appResultCode: 402,
            appDialogMsg:
                'CODE : ${resData.retCode}\n' '필수입력필드누락\n고객센터에 문의해 주세요.');
      } else {
        //매매비서 계정 생성 실패
        result = HttpProcessResultClass(
            serverRetCode: resData.retCode,
            serverRetMsg: resData.retMsg,
            appResultCode: 401,
            appDialogMsg: 'CODE : ${resData.retCode}\n' '${resData.retMsg}\n고객센터에 문의해 주세요.');
      }
    }

    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token);
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }

      await _fetchPosts(
          TR.USER03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'appEnv': _appEnv,
            'deviceModel': deviceModel ?? '',
            'osVer': osVersion ?? '',
            'appVer': Const.APP_VER,
            'adId': await utilsGetIDFA(),
          }));
    }
    //디바이스/앱정보 등록
    else if (trStr == TR.USER03) {
      if (_callNum == 0001) {
        result = HttpProcessResultClass(
            serverRetCode: RT.SUCCESS,
            serverRetMsg: '성공',
            appResultCode: 200,
            appDialogMsg: '성공');
      } else {
        await _fetchPosts(
            TR.PUSH03,
            jsonEncode(<String, String>{
              'userId': _userId,
              'tradeSignalYn': 'Y',
              'rassiroNewsYn': 'N',
              'snsConcernYn': 'N',
              'stockNewsYn': 'N',
              'buySignalYn': 'Y',
              'catchBriefYn': 'Y',
              'catchBighandYn': 'Y',
              'catchThemeYn': 'Y',
              'catchTopYn': 'Y',
              'issueYn': 'Y',
              'noticeYn': 'N',
            }));
      }
    }
    //푸시 알림 기본값 설정
    else if (trStr == TR.PUSH03) {
      //_goNextRoute(_strId);
      DLog.d(tag, '_parse0001 PUSH03 !');
      result = HttpProcessResultClass(
          serverRetCode: RT.SUCCESS,
          serverRetMsg: '성공',
          appResultCode: 200,
          appDialogMsg: '성공');
    }
  }

  //convert 패키지의 jsonDecode 사용
  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.d(tag, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      switch (_callNum) {
        case 0001:
        case 0002:
          {
            await _parse0001(trStr, response);
          }
          break;
      }
      //_parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      result = HttpProcessResultClass(
          serverRetCode: '',
          serverRetMsg: '',
          appResultCode: 400,
          appDialogMsg: '네트워크 에러');
    } on SocketException catch (_) {
      result = HttpProcessResultClass(
          serverRetCode: '',
          serverRetMsg: '',
          appResultCode: 400,
          appDialogMsg: '네트워크 에러');
    }
  }
}
