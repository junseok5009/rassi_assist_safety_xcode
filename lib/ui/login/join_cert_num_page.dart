import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/user_join_info.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/login/join_pre_user_page.dart';
import 'package:rassi_assist/ui/login/terms_of_use_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_division_page.dart';

/// 2021.05.06
/// 인증 번호 입력

class JoinCertPage extends StatefulWidget {
  static const routeName = '/page_join_cert';
  static const String TAG = "[JoinCertPage]";
  static const String TAG_NAME = '쓱가입_인증번호';

  const JoinCertPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinCertPageState();
}

class JoinCertPageState extends State<JoinCertPage> {
  final _authController = TextEditingController();
  late PgData args;
  String _reqType = '';
  String _reqParam = '';
  String _tempId = '';
  String _strPhone = '';
  String _strOnTime = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(JoinCertPage.TAG_NAME);
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      _strPhone = args.pgData;
      if (_strPhone.length > 5) {
        //인증번호 발송
        _reqType = 'phone_check';
        _strOnTime = TStyle.getTimeString();
        _reqParam =
            'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=ollaJoin';
        setState(() {});
        _requestThink();
      }
    });
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '인증번호를\n확인해 주세요.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\n$_strPhone 으로 인증번호가 발송되었습니다.\n인증번호가 맞지 않다면,\n입력하신 번호를 다시 확인해 주세요.',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),

            //인증번호
            const Text(
              '인증번호',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _authController,
              decoration: const InputDecoration(
                filled: true,
                hintText: '인증번호를 입력하세요',
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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              cursorColor: Colors.black,
            ),
            const SizedBox(
              height: 50.0,
            ),

            Column(
              children: [
                CommonView.setConfirmBtnView(
                  () => _checkAuthNum(_authController.text.trim()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //인증번호 확인
  void _checkAuthNum(String data) {
    if (data.isNotEmpty) {
      //인증번호 확인
      _reqType = 'phone_confirm';
      _reqParam =
          'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&smsAuthNum=$data';
      _requestThink();
    } else {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '인증번호를 입력해 주세요');
    }
  }

  //회원가입 입력값 체크
  void _checkEditData() {
    //체크완료
    DLog.d(JoinCertPage.TAG, '### JoinPhone : $_strPhone');

    String devicePh;
    if (_strPhone.length > 7) {
      devicePh = _strPhone.substring(1);
    } else {
      commonShowToast('전화번호 처리에 오류가 있습니다.');
      return;
    }

    _reqType = 'login_check';
    String strSsgId = 'SSGOLLA$devicePh';
    DLog.d(JoinCertPage.TAG, 'SSG ID : $strSsgId');

    _reqParam = 'snsId=${Net.getEncrypt(strSsgId)}&snsEmail=&snsPos=SSGOLLA';
    _requestThink();
  }

  // 씽크풀 API 호출
  void _requestThink() async {
    DLog.d(JoinCertPage.TAG, '씽크풀 API 호출');
    DLog.d(JoinCertPage.TAG, 'Think Req Type : $_reqType');
    DLog.d(JoinCertPage.TAG, 'Think Req Param : $_reqParam');

    String url = '';
    if (_reqType == 'login_check') {
      //SNS 아이디(전화번호) 체크
      url = Net.THINK_SNS_LOGIN;
    } else if (_reqType == 'phone_check') {
      //인증번호 요청
      url = Net.THINK_CERT_NUM;
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      url = Net.THINK_CERT_CONFIRM;
    }

    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(JoinCertPage.TAG, '${response.statusCode}');
    DLog.d(JoinCertPage.TAG, response.body);

    final String result = response.body;
    if (_reqType == 'login_check') {
      //쓱가입 전화번호 아이디 체크
      if (result.isNotEmpty) {
        final ThinkLoginSns resData =
            ThinkLoginSns.fromJson(jsonDecode(result));
        if (resData.resultCode.toString().trim() == '-1') {
          DLog.d(JoinCertPage.TAG, '씽크풀 가입안됨');
          if (mounted) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String agentLink =
                AppGlobal().pendingDynamicLinkData?.link.toString() ??
                    prefs.getString(Const.PREFS_DEEPLINK_URI) ??
                    '';
            if (agentLink.isNotEmpty && mounted) {
              // Agent회원 - 회원가입으로 이동
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/agent_sign_up',
                ModalRoute.withName(LoginDivisionPage.routeName),
                arguments: UserJoinInfo(
                  userId: Net.getEncrypt(_strPhone),
                  email: '',
                  name: '',
                  phone: _strPhone,
                  pgType: 'SSGOLLA',
                ),
              );
            } else {
              // 약관 동의로 이동
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsOfUsePage(
                      UserJoinInfo(
                        userId: '',
                        email: '',
                        name: '',
                        phone: _strPhone,
                        pgType: 'SSGOLLA',
                      ),
                    ),
                  ),
                );
              }
            }
          }
        } else {
          DLog.d(JoinCertPage.TAG, '씽크풀 가입 되어 있음');
          //가입된 정보 페이지로 이동
          _tempId = resData.userId;
          if (mounted) {
            Navigator.pushNamed(
              context,
              JoinPreUserPage.routeName,
              arguments: PgData(userId: _tempId.trim()),
            );
          }
        }
      }
    } else if (_reqType == 'phone_check') {
      //인증번호 요청
      if (result == 'success') {
        // _showDialogMsg(('인증번호가 발송되었습니다. 인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'));
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(
              context, '알림', '인증번호 요청이 실패하였습니다. 정확한 번호 입력 후 다시 시도하여 주세요.');
        }
      }
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      DLog.d(JoinCertPage.TAG, '인증결과 : $result');
      if (result == 'success') {
        commonShowToastCenter('인증되었습니다.');
        _checkEditData();
      } else {
        //실패시 : result = smsAuthChkFail
        commonShowToastCenter('인증번호 인증 실패');
      }
    }
  }
}
