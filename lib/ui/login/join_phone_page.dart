import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/login/join_cert_num_page.dart';

/// 2021.05.06
/// 휴대폰 번호 입력
class JoinPhonePage extends StatefulWidget {
  static const routeName = '/page_join_phone';
  static const String TAG = "[JoinPhonePage]";
  static const String TAG_NAME = '쓱가입_폰번호_입력';

  const JoinPhonePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinPhonePageState();
}

class JoinPhonePageState extends State<JoinPhonePage> {
  late PgData args;
  String deviceModel = '';
  String deviceOsVer = '';
  final _phoneController = TextEditingController();
  String _strPhone = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(JoinPhonePage.TAG_NAME);
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
              children: const [
                Text(
                  '휴대폰 번호로\n시작하시겠어요?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\n휴대폰 번호는 서비스 제공을 위해\n사용자님의 고유값 생성용으로 사용되며,\n외부에 노출되지 않습니다.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),

            //휴대폰 번호
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
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                filled: true,
                hintText: '휴대폰 번호를 입력하세요',
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
                  () => _checkPhone(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //전화번호 인증/확인
  void _checkPhone() {
    _strPhone = _phoneController.text.trim();
    if (_strPhone.length > 5) {
      //인증번호 페이지로 이동
      Navigator.pushNamed(
        context,
        JoinCertPage.routeName,
        arguments: PgData(
          pgData: _strPhone,
        ),
      );
    } else {
      CommonPopup.instance
          .showDialogBasicConfirm(context, '알림', '전화번호를 입력해 주세요');
    }
  }
}
