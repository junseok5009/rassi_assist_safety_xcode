import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/http_process_class.dart';
import 'package:rassi_assist/custom_lib/tripledes/utils.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/user_join_info.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2024.03.14
/// 에이전트 회원가입 페이지
class AgentSignUpPage extends StatefulWidget {
  const AgentSignUpPage({super.key});

  static const String routeName = "/agent_sign_up";

  @override
  State<AgentSignUpPage> createState() => _AgentSignUpPageState();
}

class _AgentSignUpPageState extends State<AgentSignUpPage> {
  UserJoinInfo _userJoinInfo = UserJoinInfo();
  late SharedPreferences _prefs;

  String _reqType = ''; // 씽크풀 API 호출 종류 변수
  String _reqParam = ''; // 씽크풀 API 호출 파라미터 변수
  String _strOnTime = ''; // 씽크풀 API 호출 시간

  String _agentName = ''; // 추천인

  final _phoneController = TextEditingController(); // 휴대폰 번호 입력 박스 컨트롤러
  String _strPhone = ''; // 휴대폰 번호
  bool _phoneEditEnabled = true; // 휴대폰 번호 수정 가능 여부 (인증 이후에는 수정할 수 없음)
  bool _isConfirmPhone = false; // 휴대폰 인증 여부

  bool _visibleAuth = false; // 인증번호 박스 보여주기 여부 체크
  final _authController = TextEditingController(); // 인증번호 입력 박스 컨트롤러

  final List<bool> _checkBoolList = [false, false, false]; // 약관 동의 체크 변수
  bool _checkAll = false; // 약관 동의 전체 체크 완료 여부

  bool _isNetworkDo = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView('에이전트_회원가입');
    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () {
        Uri? strLink = AppGlobal().pendingDynamicLinkData?.link ??
            Uri.parse(_prefs.getString(Const.PREFS_DEEPLINK_URI) ?? '');
        strLink.queryParameters.forEach((key, value) {
          //if(key == '')
        });
        _agentName = strLink.queryParameters.toString();
        _userJoinInfo =
            ModalRoute.of(context)!.settings.arguments as UserJoinInfo;
        if (_userJoinInfo.pgType == 'SSGOLLA') {
          _strPhone = _userJoinInfo.phone;
          _phoneController.text = _userJoinInfo.phone;
          _phoneEditEnabled = false;
          _isConfirmPhone = true;
        }
        setState(() {});
        //_strPhone = args.pgData;
        //setState(() {});
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '',
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: ListView(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '서비스 이용을 위해 가입을\n진행해 주세요.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\n라씨 매매비서는 서비스 제공을 위해\n최소한의 정보만 수집하며\n수집된 정보 보안을 위해 최선을 다합니다.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),

                // 추천인
                const Text(
                  '추천인',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  //height: 10,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: RColor.greyBox_f5f5f5,
                    borderRadius: BorderRadius.circular(8),
                    //borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _agentName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: RColor.purpleBasic_6565ff,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),

                // 휴대폰 번호
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '휴대폰 번호',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TextField(
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: '휴대폰 번호를 입력해 주세요',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: RColor.greyBox_f5f5f5,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: RColor.greyBox_f5f5f5,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          cursorColor: Colors.black,
                          enabled: _phoneEditEnabled,
                          controller: _phoneController,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              if (!_isConfirmPhone) {
                                _checkPhone();
                              }
                            },
                            child: Container(
                              width: 75,
                              height: 40,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: UIStyle.boxRoundLine8LineColor(
                                _isConfirmPhone
                                    ? RColor.greyBasic_8c8c8c
                                    : RColor.purpleBasic_6565ff,
                              ),
                              child: Center(
                                child: Text(
                                  _isConfirmPhone ? '인증완료' : '인증받기',
                                  style: TextStyle(
                                    color: _isConfirmPhone
                                        ? RColor.greyBasicStrong_666666
                                        : RColor.purpleBasic_6565ff,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 인증번호
                Visibility(
                  visible: _visibleAuth,
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TextField(
                          controller: _authController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: '수신된 인증번호를 입력하세요.',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: RColor.greyBox_f5f5f5,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: RColor.greyBox_f5f5f5,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          cursorColor: Colors.black,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              _checkAuthNum(_authController.text.trim());
                            },
                            child: Container(
                              width: 75,
                              height: 40,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: UIStyle.boxRoundLine8LineColor(
                                RColor.purpleBasic_6565ff,
                              ),
                              child: const Center(
                                child: Text(
                                  '확인',
                                  style: TextStyle(
                                    color: RColor.purpleBasic_6565ff,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20.0,
                ),
                // 약관 동의 위젯
                _setTermsBtns(),

                const SizedBox(
                  height: 50.0,
                ),
                Column(
                  children: [
                    CommonView.setConfirmBtnView(
                      () {
                        if (!_isConfirmPhone) {
                          CommonPopup.instance.showDialogBasicConfirm(
                              context, '알림', '전화번호를 인증해 주세요.');
                        } else if (!_checkAll) {
                          CommonPopup.instance.showDialogBasic(
                              context, '알림', '서비스 이용약관에 동의해 주세요.');
                        } else {
                          _reqType = 'join_sns';
                          if (_userJoinInfo.pgType == 'SSGOLLA') {
                            _reqParam =
                                //"snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(_userJoinInfo.phone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(_userJoinInfo.phone)}&kt_provide_flag=N&hpEncFlag=Y";
                                // TEST 마케팅 에이전트 : OLLAMAG , 전문가 에이전트 : OLLAEXAG
                                // 에이전트 회원가입은 휴대폰번호가 있어서 일반 회원으로 가입시키기 위해 join_channel = NM 입니다.
                                "snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(_userJoinInfo.phone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=OLLAMAG&joinChannel=NM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(_userJoinInfo.phone)}&kt_provide_flag=N&hpEncFlag=Y";
                            _requestThink();
                          }
                          //네이버/카카오/애플/구글
                          else {
                            if (_userJoinInfo.userId.isNotEmpty) {
                              _reqParam =
                                  "snsId=${Net.getEncrypt(_userJoinInfo.userId)}&snsPos=${_userJoinInfo.pgType}&nick=&userName=${_userJoinInfo.name}&sexGubun=&joinRoute=OLLAMAG&joinChannel=NM&email=${_userJoinInfo.email}&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${_userJoinInfo.phone}";
                              //"snsId=${_userJoinInfo.userId}&snsPos=${_userJoinInfo.pgType}&nick=&userName=${_userJoinInfo.name}&sexGubun=&joinRoute=OLLAMAG&joinChannel=SM&email=${_userJoinInfo.email}&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N";
                              _requestThink();
                            }
                          }
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          Visibility(
            visible: _isNetworkDo,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.1),
              alignment: Alignment.center,
              child: Image.asset(
                'images/gif_ios_loading_large.gif',
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 위젯 - 약관 동의
  Widget _setTermsBtns() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 전체 동의
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              if (_checkAll) {
                _checkBoolList[0] = false;
                _checkBoolList[1] = false;
                _checkBoolList[2] = false;
              } else {
                _checkBoolList[0] = true;
                _checkBoolList[1] = true;
                _checkBoolList[2] = true;
              }
              _checkAll = !_checkAll;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  _checkAll
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  fit: BoxFit.cover,
                  width: 22,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '전체동의',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          width: double.infinity,
          height: 1,
          color: RColor.greyBox_dcdfe2,
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
        ),

        // 서비스 이용약관
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _checkBoolList[0] = !_checkBoolList[0];
              _funcTermsCheckAll();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  _checkBoolList[0]
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  fit: BoxFit.cover,
                  width: 22,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '서비스 이용약관',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomNvRouteClass.createRouteData(
                        const WebPage(),
                        RouteSettings(
                          arguments: PgData(
                            pgData: Net.AGREE_TERMS,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Text(
                      '내용보기',
                      style: TextStyle(
                        fontSize: 13,
                        color: RColor.greyMore_999999,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 개인정보 수집 및 이용
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _checkBoolList[1] = !_checkBoolList[1];
              _funcTermsCheckAll();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  _checkBoolList[1]
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  fit: BoxFit.cover,
                  width: 22,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '개인정보 수집 및 이용',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomNvRouteClass.createRouteData(
                        const WebPage(),
                        RouteSettings(
                          arguments: PgData(
                            pgData: Net.AGREE_POLICY_INFO,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Text(
                      '내용보기',
                      style: TextStyle(
                        fontSize: 13,
                        color: RColor.greyMore_999999,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 만 14세 이상
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _checkBoolList[2] = !_checkBoolList[2];
              _funcTermsCheckAll();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  _checkBoolList[2]
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  fit: BoxFit.cover,
                  width: 22,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '만 14세 이상입니다.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 약관동의 전체 체크 여부
  _funcTermsCheckAll() {
    if (_checkBoolList[0] && _checkBoolList[1] && _checkBoolList[2]) {
      _checkAll = true;
    } else {
      _checkAll = false;
    }
  }

  // 휴대폰 번호 인증 1단계 : 번호 입력 + 인증받기 버튼
  void _checkPhone() {
    _strPhone = _phoneController.text.trim();
    if (_strPhone.isEmpty) {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '전화번호를 입력해 주세요');
    } else if (_strPhone.length < 5) {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '전화번호를 확인해 주세요');
    } else {
      //인증번호 발송
      _reqType = 'phone_check';
      _strOnTime = TStyle.getTimeString();
      _reqParam =
          'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=ollaTdJoin';
      _requestThink();
    }
  }

  // 휴대폰 번호 인증 3단계 : 인증번호 확인
  void _checkAuthNum(String data) {
    if (data.isNotEmpty) {
      //인증번호 확인
      _reqType = 'phone_confirm';
      _reqParam =
          'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=ollaTdJoin&smsAuthNum=$data';
      _requestThink();
    } else {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '인증번호를 입력해 주세요');
    }
  }

  // 씽크풀 API 호출
  void _requestThink() async {
    DLog.e('_requestThink _reqType : $_reqType / _reqParam : $_reqParam');

    String url = '';
    if (_reqType == 'phone_check') {
      //인증번호 요청
      url = Net.THINK_CERT_NUM;
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      url = Net.THINK_CERT_CONFIRM;
    } else if (_reqType == 'join_sns') {
      //회원가입
      url = Net.THINK_SNS_JOIN;
    }
    if (_isNetworkDo) {
      return;
    } else {
      setState(() => _isNetworkDo = true);
    }
    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.e(
        '씽크풀 API response / response.statusCode : ${response.statusCode} / response.body : ${response.body}');

    final String result = response.body.trim();
    if (_reqType == 'phone_check') {
      //인증번호 요청
      if (result == 'success' && mounted) {
        CommonPopup.instance.showDialogBasicConfirm(
            context, '알림', ('인증번호가 발송되었습니다.\n인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'));
        _phoneEditEnabled = false;
        _visibleAuth = true;
      } else {
        _phoneEditEnabled = true;
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(
              context, '알림', ('인증번호 요청이 실패하였습니다.\n정확한 번호 입력 후 다시 시도하여 주세요.'));
        }
      }
      setState(() => _isNetworkDo = false);
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      if (result == '00' || result == 'success') {
        //인증완료 회원가입 진행
        commonShowToastCenter('인증되었습니다');
        setState(() {
          // 전화번호 필드 고정. 확인 완료
          _isConfirmPhone = true; //전화번호 확인 완료
          _phoneEditEnabled = false;
          _visibleAuth = false;
          // 휴대폰 번호로 간편하게 시작하기로 온 경우에, 휴대폰 인증 후 인증받은 휴대폰 번호가 id입니다.
          if (_userJoinInfo.pgType == 'SSGOLLA') {
            _userJoinInfo.userId = _strPhone;
          }
          _userJoinInfo.phone = _strPhone;
        });
      } else if (result == '10' || result == '01' || result == '11') {
        if (mounted) {
          CommonPopup.instance.showDialogBasic(context, '알림',
              '이미 가입된 아이디가 있습니다.\n가입하셨던 아이디로 로그인 하시기 바랍니다.\n아이디가 기억나지 않으실 경우 아이디 찾기를 통해 찾을 수 있습니다.');
        }
      } else if (result == '99') {
        //아이디 체크시 오류
        if (mounted) {
          CommonPopup.instance
              .showDialogBasic(context, '알림', '없는 정보이거나 입력한 정보가 맞지 않습니다.');
        }
      } else if (result == 'standby') {
        //휴면 전환된 전화번호를 가진 아이디 있는 상태
        commonShowToastCenter('이미 가입하신 휴면상태의 아이디가 있습니다.');
      } else if (result == 'smsAuthChkFail') {
        commonShowToastCenter('인증실패 - 인증번호를 확인해주세요');
      } else if (result == 'smsAuth3Fail') {
        commonShowToastCenter('인증 3회 실패 - 인증번호를 확인해주세요');
      } else {
        commonShowToast('인증번호를 확인해주세요');
      }
      setState(() => _isNetworkDo = false);
    } else if (_reqType == 'join_sns') {
      //SNS 회원가입
      if (result.isNotEmpty) {
        final ThinkLoginSns resData =
            ThinkLoginSns.fromJson(jsonDecode(result));
        if (resData.resultCode.toString().trim() == '0') {
          commonShowToast("회원가입에 실패했습니다");
        } else {
          _userJoinInfo.userId = resData.userId;
          await HttpProcessClass()
              .callHttpProcess0002(_userJoinInfo.userId)
              .then((value) {
            switch (value.appResultCode) {
              case 200:
                {
                  _goNextRoute();
                  break;
                }
              case 400:
                {
                  CommonPopup.instance.showDialogNetErr(context);
                  break;
                }
              default:
                {
                  CommonPopup.instance
                      .showDialogMsg(context, value.appDialogMsg);
                }
            }
          });
        }
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasic(
              context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
        }
      }
      setState(() => _isNetworkDo = false);
    }
  }

  // 다음 페이지로 이동
  Future<void> _goNextRoute() async {
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (_userJoinInfo.pgType) {
      case 'SSGOLLA':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.ssg.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.ssg.name);
          break;
        }
      case 'KAKAO':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.kakao.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.kakao.name);
          break;
        }
      case 'NAVER':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.naver.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.naver.name);
          break;
        }
      case 'APPLE':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.apple.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.apple.name);
          break;
        }
      case 'GOOGLE':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.google.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.google.name);
          break;
        }
      case 'RASSI':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.rassi.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.rassi.name);
          break;
        }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String prefsUserId = prefs.getString(Const.PREFS_USER_ID) ?? '';
    String globalUserId = AppGlobal().userId;

    if (prefsUserId.isEmpty) {
      if (globalUserId.isEmpty) {
        if (mounted) {
          await CommonPopup.instance.showDialogBasicConfirm(
              context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, IntroStartPage.routeName, (route) => false);
          }
        }
      } else {
        await prefs.setString(Const.PREFS_USER_ID, globalUserId);
      }
    }

    if (globalUserId.isEmpty) {
      AppGlobal().userId = prefsUserId;
    }

    AppGlobal().pendingDynamicLinkData = null;
    basePageState = BasePageState();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        BasePage.routeName,
        (route) => false,
      );
    }
  }
}
