import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/http_process_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/login/join_route_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';

/// 2020.09.29
/// 라씨 회원가입
class RassiJoinPage extends StatefulWidget {
  static const routeName = '/page_join_rassi';
  static const String TAG = "[RassiJoinPage]";
  static const String TAG_NAME = '라씨_회원가입';

  const RassiJoinPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RassiJoinState();
}

class RassiJoinState extends State<RassiJoinPage> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  final _passReController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authController = TextEditingController();

  String deviceModel = '';
  String deviceOsVer = '';

  bool _isIdCheck = false; //아이디 중복체크
  String _reqType = '';
  String _reqParam = '';

  String _strId = '';

  String _strPhone = '';
  bool _isPhoneCheck = false;
  bool _phEnableField = true;
  bool _visibleAuth = false;
  String _strOnTime = '';
  final String posName = 'ollaTdJoin';
  bool _isAgreeMarketing = false; //마케팅 수신 동의 체크

  String _sJoinRoute = '';
  String deepLinkRoute = '';

  final List<bool> _checkBoolList = [false, false, false];
  bool _checkAll = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(RassiJoinPage.TAG_NAME);
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'in_signing_rassi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '',
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: ListView(
            children: [
              _setInputField(),
              _setBtns(),
              const SizedBox(height: 40,),
              Column(
                children: [
                  CommonView.setConfirmBtnView(() {
                    String id = _idController.text.trim();
                    String pass = _passController.text.trim();
                    _checkEditData(id, pass);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //회원정보 입력부
  Widget _setInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //아이디
        _setSubTitle(
          RString.id,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            TextField(
              readOnly: _isIdCheck,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                hintText: RString.hint_input_id,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: RColor.greyBox_f5f5f5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: RColor.greyBox_f5f5f5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              cursorColor: Colors.black,
              controller: _idController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  if (!_isIdCheck) {
                    _checkId();
                  }
                },
                child: Container(
                  width: 75,
                  height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: UIStyle.boxRoundLine8LineColor(
                    _isIdCheck
                        ? RColor.greyBasic_8c8c8c
                        : RColor.purpleBasic_6565ff,
                  ),
                  child: Center(
                    child: Text(
                      '중복확인',
                      style: TextStyle(
                        color: _isIdCheck
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
        const SizedBox(
          height: 10.0,
        ),

        //비밀번호
        _setSubTitle(
          RString.password,
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            filled: true,
            hintText: RString.hint_input_pass,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: RColor.greyBox_f5f5f5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: RColor.greyBox_f5f5f5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          cursorColor: Colors.black,
          obscureText: true,
          controller: _passController,
        ),
        const SizedBox(
          height: 10.0,
        ),

        //비밀번호 확인
        _setSubTitle(
          RString.password_re,
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            filled: true,
            hintText: RString.hint_input_pass_re,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: RColor.greyBox_f5f5f5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: RColor.greyBox_f5f5f5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          cursorColor: Colors.black,
          obscureText: true,
          controller: _passReController,
        ),
        const SizedBox(
          height: 10.0,
        ),

        //휴대폰 번호
        _setSubTitle(
          RString.phone_num,
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
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: RColor.greyBox_f5f5f5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              cursorColor: Colors.black,
              enabled: _phEnableField,
              controller: _phoneController,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  if (!_isPhoneCheck) {
                    _checkPhone();
                  }
                },
                child: Container(
                  width: 75,
                  height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: UIStyle.boxRoundLine8LineColor(
                    _isPhoneCheck
                        ? RColor.greyBasic_8c8c8c
                        : RColor.purpleBasic_6565ff,
                  ),
                  child: Center(
                    child: Text(
                      '인증받기',
                      style: TextStyle(
                        color: _isPhoneCheck
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
        const SizedBox(
          height: 5.0,
        ),
        Visibility(
          visible: _visibleAuth,
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
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: RColor.greyBox_f5f5f5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
        const SizedBox(
          height: 40.0,
        ),
      ],
    );
  }

  //타이틀 서식
  Widget _setSubTitle(
    String subTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 10,
      ),
      child: Text(
        subTitle,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  //동의
  Widget _setBtns() {
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
              _funcCheckAll();
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
                        WebPage(),
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
              _funcCheckAll();
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
                        WebPage(),
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
              _funcCheckAll();
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

  //아이디 중복확인
  //씽크풀 회원가입은 대소문자 구분이 없음
  void _checkId() {
    _strId = _idController.text.trim();
    if (_strId.length > 3) {
      _reqType = 'id_check';
      _reqParam = 'userid=${Net.getEncrypt(_strId.toLowerCase())}';
      _requestThink();
    } else {
      CommonPopup.instance.showDialogBasicConfirm(
          context, '알림', '잘못된 아이디 입니다.\n아이디는 4~12자리 영문, 숫자만\n사용하실 수 있습니다.');
    }
  }

  //전화번호 인증/확인
  void _checkPhone() {
    _strPhone = _phoneController.text.trim();
    if (_strPhone.length > 5) {
      //인증번호 발송
      _reqType = 'phone_check';
      _strOnTime = TStyle.getTimeString();
      _reqParam =
          'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=$posName';
      _requestThink();
    } else {
      CommonPopup.instance.showDialogBasicConfirm(
        context,
        '알림',
        '전화번호를 입력해 주세요',
      );
    }
  }

  //인증번호 확인
  void _checkAuthNum(String data) {
    if (data.isNotEmpty) {
      //인증번호 확인
      _reqType = 'phone_confirm';
      _reqParam =
          'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=$posName&smsAuthNum=$data';
      _requestThink();
    } else {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '인증번호를 입력해 주세요');
    }
  }

  //회원가입 입력값 체크
  void _checkEditData(final String id, final String pass) {
    if (!_isIdCheck) {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '아이디 중복확인을 해주세요.');
    } else if (_isPwCheck(pass) || _passController.text.trim().length < 6) {
      CommonPopup.instance.showDialogBasicConfirm(
          context, '알림', RString.join_err_pw_rule); //6~12자리 영문, 숫자만 가능
    } else if (_passController.text.trim() != _passReController.text.trim()) {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', RString.join_err_pw_match);
    } else if (!_isPhoneCheck) {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '전화번호를 인증해 주세요.');
    } else if (!_checkBoolList[0]) {
      CommonPopup.instance
          .showDialogBasic(context, '알림', '서비스 이용약관에 동의해 주세요.');
    } else if (!_checkBoolList[1]) {
      CommonPopup.instance
          .showDialogBasic(context, '알림', '개인정보 수집 및 이용에 동의해 주세요.');
    } else if (!_checkBoolList[2]) {
      CommonPopup.instance
          .showDialogBasic(context, '알림', '만 14세 이상을 확인해 주세요.');
    } else{
      //씽크풀 회원가입 페이지로 이동
      Navigator.pushNamed(
        context,
        JoinRoutePage.routeName,
        arguments: PgData(
            userId: id.toLowerCase(),
            pgData: pass,
            pgSn: _strPhone.trim(),
            flag: 'RASSI'),
      );
    }
  }

  //비밀번호 유효성 체크(동일한 문자, 숫자 3자리 불가)
  bool _isPwCheck(String strPw) {
    if (strPw == null || strPw.isEmpty) return false;

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

  // 씽크풀 API 호출
  void _requestThink() async {
    DLog.d(RassiJoinPage.TAG, '씽크풀 API 호출');
    DLog.d(RassiJoinPage.TAG, 'Think Req Type : $_reqType');
    DLog.d(RassiJoinPage.TAG, 'Think Req Param : $_reqParam');

    String url = '';
    if (_reqType == 'id_check') {
      //아이디 중복체크
      url = Net.THINK_CHECK_ID;
    } else if (_reqType == 'phone_check') {
      //인증번호 요청
      url = Net.THINK_CERT_NUM;
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      url = Net.THINK_CERT_CONFIRM;
    } else if (_reqType == 'join_confirm') {
      //회원가입
      url = Net.THINK_JOIN;
    }

    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(RassiJoinPage.TAG, '${response.statusCode}');
    DLog.d(RassiJoinPage.TAG, response.body);

    final String result = response.body.trim();
    if (_reqType == 'id_check') {
      //아이디 중복체크
      if (result == '0') {
        setState(() {
          _isIdCheck = true;
        });
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(
              context, '알림', ('멋진 아이디네요!\n아이디 사용이 가능합니다.'));
        }
      } else {
        _isIdCheck = false;
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(
              context, '알림', '이런, 죄송합니다.\n이미 사용중인 아이디 입니다.\n다른 아이디를 입력해 주세요.');
        }
      }
    } else if (_reqType == 'phone_check') {
      //인증번호 요청
      if (result == 'success' && mounted) {
        CommonPopup.instance.showDialogBasicConfirm(
            context, '알림', ('인증번호가 발송되었습니다.\n인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'));
        setState(() {
          _phEnableField = true;
          _visibleAuth = true;
        });
      } else {
        _phEnableField = true;
        CommonPopup.instance.showDialogBasicConfirm(
            context, '알림', ('인증번호 요청이 실패하였습니다.\n정확한 번호 입력 후 다시 시도하여 주세요.'));
      }
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      if (result == '00' || result == 'success') {
        //인증완료 회원가입 진행
        commonShowToast('인증되었습니다');
        setState(() {
          // 전화번호 필드 고정. 확인 완료
          _isPhoneCheck = true; //전화번호 확인 완료
          _phEnableField = true;
          _visibleAuth = false;
        });
      } else if (result == '10' || result == '01' || result == '11') {
        _showDialogIds(
            '이미 가입된 아이디가 있습니다.\n'
                '가입하셨던 아이디로 로그인 하시기 바랍니다.\n아이디가 기억나지 않으실 경우 아이디찾기를 '
                '통해 찾을 수 있습니다.',
            '확인',
            true);
      } else if (result == '99') {
        //아이디 체크시 오류
        _showDialogIds('없는 정보이거나 입력한 정보가 맞지 않습니다.', '확인', false);
      } else if (result == 'standby') {
        //휴면 전환된 전화번호를 가진 아이디 있는 상태
        commonShowToast('이미 가입하신 휴면상태의 아이디가 있습니다.');
      } else if (result == 'smsAuthChkFail') {
        commonShowToast('인증실패 - 인증번호를 확인해주세요');
      } else if (result == 'smsAuth3Fail') {
        commonShowToast('인증 3회 실패 - 인증번호를 확인해주세요');
      } else {
        commonShowToast('인증번호를 확인해주세요');
      }
    } else if (_reqType == 'join_confirm') {
      //회원가입
      if (result != 'ERR' && result.isNotEmpty) {
        HttpProcessClass().callHttpProcess0002(_strId).then((value) {
          DLog.d(RassiJoinPage.TAG, 'then() value : $value');
          switch (value.appResultCode) {
            case 200:
              {
                _goNextRoute(_strId);
                break;
              }
            case 400:
              {
                CommonPopup.instance.showDialogNetErr(context);
                break;
              }
            default:
              {
                CommonPopup.instance.showDialogMsg(context, value.appDialogMsg);
              }
          }
        });
      } else {
        //씽크풀 회원가입 실패
        if (result == 'PWERR' && mounted) {
          CommonPopup.instance
              .showDialogBasicConfirm(context, '알림', '안전한 비밀번호로 다시 설정해 주세요.');
        } else {
          CommonPopup.instance.showDialogBasicConfirm(
              context, '알림', '회원 가입에 실패하였습니다. 고객센터로 문의해주세요.');
        }
      }
    }
  }

  //이미 사용중인 아이디가 있을경우 (자동 페이지 종료)
  void _showDialogIds(String message, String btnText, bool bClose) {
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
                    _goPreviousPage();
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
                    height: 15.0,
                  ),
                  Text(
                    message,
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
                        // margin: const EdgeInsets.only(top: 20.0),
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
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
                      if (bClose) _goPreviousPage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop('complete'); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });
  }

  // 다음 페이지로 이동
  void _goNextRoute(String userId) {
    commonShowToast('로그인 되었습니다.');
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.rassi));
    if (userId != '') {
      if (basePageState != null) {
        // basePageState = null;
        basePageState = BasePageState();
      }
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const BasePage(),
              settings: const RouteSettings(name: '/base')),
          (route) => false);
    } else {}
  }

  _funcCheckAll() {
    if (_checkBoolList[0] && _checkBoolList[1] && _checkBoolList[2]) {
      _checkAll = true;
    } else {
      _checkAll = false;
    }
  }
}
