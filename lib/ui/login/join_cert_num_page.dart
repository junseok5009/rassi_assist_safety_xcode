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
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/login/join_pre_user_page.dart';
import 'package:rassi_assist/ui/login/join_route_page.dart';

/// 2021.05.06
/// 인증 번호 입력
class JoinCertPage extends StatelessWidget {
  static const routeName = '/page_join_cert';
  static const String TAG = "[JoinCertPage]";
  static const String TAG_NAME = '쓱가입_인증번호';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepBlue,
          elevation: 0,
        ),
        body: JoinCertWidget(),
      ),
    );
  }
}

class JoinCertWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JoinCertState();
}

class JoinCertState extends State<JoinCertWidget> {

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
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_strPhone.length > 5) {
        //인증번호 발송
        _reqType = 'phone_check';
        _strOnTime = TStyle.getTimeString();
        _reqParam = 'inputNum=' +
            Net.getEncrypt(_strPhone) +
            '&pos=' +
            _strOnTime +
            '&posName=ollaJoin';
        _requestThink();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _strPhone = args.pgData ?? '';
    DLog.d(JoinCertPage.TAG, 'args : $_strPhone');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            unselectedWidgetColor: Colors.white,
            colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white)),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증번호를\n확인해 주세요.',
                    style: TStyle.title22m,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '$_strPhone 으로 인증번호가 발송되었습니다.\n인증번호가 맞지 않다면,\n입력하신 번호를 다시 확인해 주세요.',
                    style: TStyle.textGrey15,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),

            //인증번호
            _setSubTitle('인증번호'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _authController,
                decoration: const InputDecoration(hintText: '인증번호'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),

            _setConfirmBtn(),
          ],
        ),
      ),
    );
  }

  //타이틀 서식
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  Widget _setConfirmBtn() {
    return Column(
      children: [
        Container(
          width: 170,
          height: 45,
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: const BorderSide(color: RColor.mainColor),
            ),
            color: RColor.mainColor,
            textColor: Colors.white,
            child: Text(
              '확인',
              style: TStyle.btnTextWht17,
            ),
            onPressed: () {
              _checkAuthNum(_authController.text.trim());
            },
          ),
        )
      ],
    );
  }

  //인증번호 확인
  void _checkAuthNum(String data) {
    if (data.length > 0) {
      //인증번호 확인
      _reqType = 'phone_confirm';
      _reqParam = 'inputNum=' +
          Net.getEncrypt(_strPhone) +
          '&pos=' +
          _strOnTime +
          '&smsAuthNum=$data';
      _requestThink();
    } else {
      _showDialogMsg('인증번호를 입력해 주세요');
    }
  }

  //회원가입 입력값 체크
  void _checkEditData() {
    //체크완료
    DLog.d(JoinCertPage.TAG, '### JoinPhone : $_strPhone');

    String devicePh;
    if (_strPhone != null && _strPhone.length > 7) {
      devicePh = _strPhone.substring(1);
    } else {
      commonShowToast('전화번호 처리에 오류가 있습니다.');
      return;
    }

    _reqType = 'login_check';
    String strSsgId = 'SSGOLLA' + devicePh;
    DLog.d(JoinCertPage.TAG, 'SSG ID : $strSsgId');

    _reqParam =
        'snsId=' + Net.getEncrypt(strSsgId) + '&snsEmail=&snsPos=SSGOLLA';
    _requestThink();
  }

  void _showDialogMsg(String msg) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Text(
                    '알림',
                    style: TStyle.title20,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    msg,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0)),
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
                    },
                  ),
                ],
              ),
            ),
          );
        });
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
    final http.Response response = await http.post(urls,
        headers: Net.think_headers,
        body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(JoinCertPage.TAG, '${response.statusCode}');
    DLog.d(JoinCertPage.TAG, response.body);

    final String result = response.body;
    if (_reqType == 'login_check') {
      //쓱가입 전화번호 아이디 체크
      if (result.length > 0) {
        final ThinkLoginSns resData =
            ThinkLoginSns.fromJson(jsonDecode(result));
        if (resData.resultCode.toString().trim() == '-1') {
          DLog.d(JoinCertPage.TAG, '씽크풀 가입안됨');

          //씽크풀 회원가입 -> 경로 선택 화면으로 이동
          Navigator.pushNamed(
            context,
            JoinRoutePage.routeName,
            arguments: PgData(
                userId: _strPhone, pgData: '', pgSn: '', flag: 'SSGOLLA'),
          );

        } else {
          DLog.d(JoinCertPage.TAG, '씽크풀 가입 되어 있음');
          //가입된 정보 페이지로 이동
          _tempId = resData.userId;
          Navigator.pushNamed(
            context,
            JoinPreUserPage.routeName,
            arguments: PgData(userId: _tempId.trim()),
          );
        }
      }
    } else if (_reqType == 'phone_check') {
      //인증번호 요청
      if (result == 'success') {
        // _showDialogMsg(('인증번호가 발송되었습니다. 인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'));
      } else {
        _showDialogMsg(('인증번호 요청이 실패하였습니다. 정확한 번호 입력 후 다시 시도하여 주세요.'));
      }
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      DLog.d(JoinCertPage.TAG, '인증결과 : $result');
      if (result == 'success') {
        commonShowToast('인증되었습니다.');
        _checkEditData();
      } else {
        //실패시 : result = smsAuthChkFail
        commonShowToast('인증번호 인증 실패');
      }
    }
  }

}
