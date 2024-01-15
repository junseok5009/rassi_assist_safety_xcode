import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2020.12.
/// 회원정보 관리
class UserInfoPage extends StatelessWidget {
  static const routeName = '/page_user_info';
  static const String TAG = "[UserInfoPage] ";
  static const String TAG_NAME = 'MY_회원정보';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: UserInfoWidget(),
    );
  }
}

class UserInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserInfoState();
}

class UserInfoState extends State<UserInfoWidget> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _appEnv = Platform.isIOS ? "EN20" : "EN10";
  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  late SharedPreferences _prefs;
  String _userId = '';
  String? _token = '';
  late PgNews args;

  String title = '';
  String nDate = '';
  Color statColor = Colors.grey;

  final _passController = TextEditingController();
  final _phoneController = TextEditingController();
  final _certController = TextEditingController();
  bool _isChPass = false;
  String _sBtnPass = '변경';
  String _sPassHint = '********';

  bool _isChPhone = false;
  bool _isCertInput = false;
  String _certTime = '';
  String _sBtnPhone = '변경';
  String _sPhoneHint = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      UserInfoPage.TAG_NAME,
    );

    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(UserInfoPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.USER02,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _token = await FirebaseMessaging.instance.getToken();
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _setSubTitle(
              "회원 정보 관리",
            ),
            const SizedBox(
              height: 25.0,
            ),

            _setSubTitle(
              "아이디",
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 10, top: 10, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _userId,
                    style: TStyle.content16,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    color: Colors.white,
                    textColor: Colors.black54,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onPressed: () {
                      _showDialogLogout();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),

            Visibility(
              visible: _userId != null && !_userId.contains('@'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setSubTitle(
                    "비밀번호",
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: TextField(
                          enabled: _isChPass,
                          controller: _passController,
                          decoration: InputDecoration(
                            hintText: _sPassHint,
                            hintStyle: TStyle.textGrey15,
                          ),
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
                          child: Text(
                            _sBtnPass,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          onPressed: () {
                            //변경중
                            if (_isChPass) {
                              String chPass = _passController.text.trim();
                              if (_isPwCheck(chPass) ||
                                  _passController.text.trim().length < 6) {
                                _showDialogMsg(RString
                                    .join_err_pw_rule); //6~12자리 영문, 숫자만 가능
                              } else {
                                DLog.d('Pass Ch -> ', chPass);
                                _requestChPass(chPass);
                              }
                            } else {
                              setState(() {
                                _sBtnPass = '확인';
                                _isChPass = true;
                                _sPassHint = '6~12자리 영문/숫자, 동일 3자리 불가';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),

            _setSubTitle(
              "휴대폰 번호",
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    enabled: _isChPhone,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: _sPhoneHint,
                      hintStyle: TStyle.textGrey15,
                    ),
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
                    child: Text(
                      _sBtnPhone,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    onPressed: () {
                      //변경중
                      if (_isChPhone) {
                        String chPhone = _phoneController.text.trim();
                        if (chPhone.length > 7) {
                          DLog.d('인증번호요청 -> ', chPhone);
                          _requestCertNum(chPhone);
                        } else {
                          _showDialogMsg('휴대폰 번호를 입력해주세요');
                        }
                      } else {
                        setState(() {
                          _isChPhone = true;
                          _sBtnPhone = '인증번호 요청';
                          _sPhoneHint = '번호 입력 후 인증번호 요청해주세요.';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            //인증번호 입력
            Visibility(
              visible: _isCertInput,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextField(
                      controller: _certController,
                      decoration: const InputDecoration(
                        hintText: '인증번호 입력',
                        hintStyle: TStyle.textGrey15,
                      ),
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
                      child: const Text(
                        '확인',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: () {
                        String strNum = _certController.text.trim();
                        if (strNum.length > 4) {
                          _requestCertConfirm(
                              _phoneController.text.trim(), strNum);
                        } else {
                          _showDialogMsg('인증번호를 입력해주세요');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),

            //회원 탈퇴
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: InkWell(
                child: const Text(
                  '- 회원 탈퇴',
                  style: TStyle.textGrey15,
                ),
                onTap: () {
                  // 결제 정보 호출 후 탈퇴 진행
                  _showDialogClose();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //비밀번호 유효성 체크(동일한 문자, 숫자 3자리 불가)
  bool _isPwCheck(String strPw) {
    if (strPw == null || strPw.length == 0) return false;

    int count = 0; //중복된 글자수
    String tmp = strPw[0];

    for (int i = 0; i < strPw.length; i++) {
      if (tmp == strPw[i]) {
        tmp = strPw[i];
        count = count + 1;
      } else {
        tmp = strPw[i];
        if (count < 3) {
          count = 1;
        }
      }
    }
    return count > 2;
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Text(
        subTitle,
        style: TStyle.title17,
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
  }

  //로그아웃 다이얼로그
  void _showDialogLogout() {
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
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text('로그아웃 하시겠어요?',
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
                            '로그아웃',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _setLogoutStatus();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 로그아웃 처리
  Future<void> _setLogoutStatus() async {
    _prefs ??= await SharedPreferences.getInstance();

    AppGlobal().setLogoutStatus();

    if (_userId.length > 3) {
      String checkLoginDiv = _userId.substring(_userId.length - 3);
      switch (checkLoginDiv) {
        case '@ko':
          {
            await kakaoLogout();
            break;
          }
        case '@nv':
          {
            await naverLogout();
            break;
          }
        case '@ap':
          {
            break;
          }
      }
    }

    await _prefs.setString(Const.PREFS_USER_ID, '');
    if (context.mounted) {
      makeRoutePage(context: context, desPage: const IntroStartPage());
    }

    if (Platform.isAndroid) {
      try {
        await channel.invokeMethod('setPrefLogout');
      } on PlatformException catch (_) {}
    }
  }

  Future<void> kakaoLogout() async {
    DLog.d(UserInfoPage.TAG, 'goKakaoLogout()');
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.unlink(); // unlink는 토큰 삭제 + 로그아웃
      } catch (error) {
        DLog.d(UserInfoPage.TAG, 'error : $error');
      }
    }
  }

  Future<void> naverLogout() async {
    DLog.d(UserInfoPage.TAG, 'naverLogout()');
    await FlutterNaverLogin.logOutAndDeleteToken();
  }

  //TODO 다시 로그인 되는 페이지에서 basePageState 다시 생성
  // if(basePageState != null) {
  // basePageState = null;
  // basePageState = new BasePageState();
  // }

  //로그아웃 페이지 이동
  void makeRoutePage({required BuildContext context, required Widget desPage}) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => desPage), (route) => false);
  }

  //회원탈퇴 확인
  void _showDialogClose() {
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
                  _setSubTitle('회원탈퇴'),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    '사용중인 유료 결제 서비스가 있으신 경우 사용중인 서비스를 해지하신 후 탈퇴를 하시기 바랍니다.\n'
                    '회원탈퇴를 하시면 씽크풀 웹, 모바일, 앱의 모든 활동정보가 삭제됩니다.',
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
                      _fetchPosts(
                          TR.USER04,
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

  void _showDialogMsg(
    String content,
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
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  _setSubTitle('알림'),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    content,
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
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(UserInfoPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(UserInfoPage.TAG, response.body);

    if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        String hp = resData.retData.userHp.trim();
        if (hp == 'null' || hp == 'NULL') {
          _sPhoneHint = '';
        } else {
          _sPhoneHint = hp;
        }
        setState(() {});
        DLog.d(UserInfoPage.TAG, resData.retData.userHp);
        DLog.d(UserInfoPage.TAG, _token ?? '');

        if (resData.retData.pushValid == 'N') {
          //푸시 재등록
          if (_token != '') {
            if (!Const.isDebuggable) {
              _fetchPosts(
                  TR.PUSH01,
                  jsonEncode(<String, String>{
                    'userId': _userId,
                    'appEnv': _appEnv,
                    'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                    'pushToken': _token ?? '',
                  }));
            }
          }
        }
      }
    } else if (trStr == TR.USER04) {
      //탈퇴 가능 여부
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _checkCloseStatus(resData.retData);
      } else if (resData.retCode == RT.NO_DATA) {}
    }

    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token ?? '');
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }
    }
  }

  void _checkCloseStatus(User04 item) {
    AccountData aData = item.accountData!;
    if (aData != null) {
      //체험상품 사용자 -> 탈퇴가능
      if (aData.isFreeUser == 'Y') {
        _requestAppClose();
      }
      //프리미엄 사용자 -> 탈퇴 불가
      else if (aData.prodName == '프리미엄') {
        _showDialogMsg(
            '현재 사용중인 유료 결제 서비스가 있습니다.\n사용중인 서비스를 해지하신 후\n탈퇴를 하시기 바랍니다.');
      }
      //유료상품 사용자 -> 탈퇴 불가
      else if (aData.prodCode == 'AC_S3') {
        _showDialogMsg(
            '현재 사용중인 유료 결제 서비스가 있습니다.\n사용중인 서비스를 해지하신 후\n탈퇴를 하시기 바랍니다.');
      }
      //사용 상품 없음
      else {
        _requestAppClose();
      }
    }
  }

  //인증번호 요청
  _requestCertNum(String sPhone) {
    _certTime = TStyle.getTodayAllTimeString();
    String strParam = "inputNum=" +
        Net.getEncrypt(sPhone) +
        "&pos=" +
        _certTime +
        '&posName=ollaJoin';
    _requestThink('cert_num', strParam);
  }

  //인증번호 확인
  _requestCertConfirm(String sPhone, String cNum) {
    String strParam = "inputNum=" +
        Net.getEncrypt(sPhone) +
        "&pos=" +
        _certTime +
        '&smsAuthNum=' +
        cNum;
    _requestThink('cert_confirm', strParam);
  }

  //전화번호 변경
  _requestChPhone(String sPhone) {
    setState(() {
      _isChPhone = false;
      _sBtnPhone = '변경';
      _isCertInput = false;
    });

    DLog.d(UserInfoPage.TAG, 'CH_Phone : ' + sPhone);
    String strParam = "userid=" + _userId + "&encHpNo=" + sPhone;
    _requestThink('phone_change', strParam);
  }

  //비밀번호 변경
  _requestChPass(String newPass) {
    String strParam = "userid=" +
        Net.getEncrypt(_userId) +
        "&newPassWd=" +
        Net.getEncrypt(newPass);
    _requestThink('ch_pass', strParam);
  }

  //회원탈퇴 처리
  _requestAppClose() {
    DLog.d(UserInfoPage.TAG, '회원탈퇴 처리');

    String strParam =
        "userid=" + Net.getEncrypt(_userId) + "&memo=RassiAssistDismiss";
    _requestThink('close', strParam);

    _fetchPosts(
        TR.USER01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'userStatus': 'C',
          'encHp': '',
          'appEnv': _appEnv,
          'userGroup': 'UGTA',
        }));
    _setLogoutStatus();
  }

  // 씽크풀 API 호출
  void _requestThink(String type, String param) async {
    DLog.d(UserInfoPage.TAG, 'param : $param');

    String url = '';
    if (type == 'ch_pass') {
      url = Net.THINK_CH_PASS;
    } else if (type == 'cert_num') {
      url = Net.THINK_CERT_NUM;
    } else if (type == 'cert_confirm')
      url = Net.THINK_CERT_CONFIRM;
    else if (type == 'phone_change') {
      url = Net.THINK_CH_PHONE;
    } else if (type == 'close') {
      url = Net.THINK_USER_CLOSE;
    }

    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: param);

    DLog.d(UserInfoPage.TAG, '${response.statusCode}');
    DLog.d(UserInfoPage.TAG, response.body);

    // ----- Response -----
    final String result = response.body;
    if (type == 'ch_pass') {
      if (result == '1') {
        _passController.clear();
        setState(() {
          _sBtnPass = '변경';
          _isChPass = false;
          _sPassHint = '********';
        });
        _showDialogMsg('비밀번호가 변경되었습니다.');
      } else {
        _showDialogMsg('비밀번호 변경시 오류가 발생하였습니다.');
      }
    } else if (type == 'cert_num') {
      setState(() {
        _isChPhone = false;
        _isCertInput = true;
      });
      _showDialogMsg('인증번호를 요청했습니다.');
    } else if (type == 'cert_confirm') {
      if (result == 'success') {
        DLog.d(UserInfoPage.TAG, '인증번호 확인 완료');
        _requestChPhone(_phoneController.text.trim());
      } else {
        _showDialogMsg('인증번호가 틀립니다.\n인증번호를 확인 후 다시 입력해 주세요.');
      }
    } else if (type == 'phone_change') {
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '전화번호 변경 완료');
        _showDialogMsg('전화번호 변경이 완료되었습니다.');
      } else if (result == '-9') {
        DLog.d(UserInfoPage.TAG, '폰 변경 잘못된 Param');
      } else {
        _showDialogMsg('전화번호 변경 요청이 실패하였습니다.');
      }
    } else if (type == 'close') {
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '씽크풀 회원 탈퇴 완료');
      } else {
        _showDialogMsg('회원 탈퇴에 실패하였습니다.');
      }
    }
  }
}
