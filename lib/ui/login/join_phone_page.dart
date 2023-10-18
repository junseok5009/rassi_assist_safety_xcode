import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
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
  final ThemeData _theme = ThemeData();

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(JoinPhonePage.TAG_NAME);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.none(Colors.white,),
      body: ListView(
        children: [

          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('휴대폰 번호로\n시작하시겠어요?', style: TStyle.title22m,),
                SizedBox(height: 20,),
                Text('휴대폰 번호는 서비스 제공을 위해\n사용자님의 고유값 생성용으로 사용되며,\n외부에 노출되지 않습니다.',
                  style: TStyle.textGrey15,),
              ],
            ),
          ),
          const SizedBox(height: 40,),

          //휴대폰 번호
          _setSubTitle('휴대폰 번호'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _phoneController,
              decoration: const InputDecoration(hintText: '휴대폰 번호를 입력하세요'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50.0,),

          _setConfirmBtn(),
        ],
      ),
    );
  }

  //타이틀 서식
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
      child: Text(subTitle, style: TStyle.defaultTitle,),
    );
  }

  Widget _setConfirmBtn() {
    return Column(
      children: [
        Container(
          width: 170,
          height: 45,
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(vertical: 10,),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: const BorderSide(color: RColor.mainColor),
            ),
            color: RColor.mainColor,
            textColor: Colors.white,
            child: const Text('확인', style: TStyle.btnTextWht17,),
            onPressed: () {
              _checkPhone();
            },
          ),
        )
      ],
    );
  }

  //전화번호 인증/확인
  void _checkPhone() {
    _strPhone = _phoneController.text.trim();
    if(_strPhone.length > 5) {
      //인증번호 페이지로 이동
      Navigator.pushNamed(context, JoinCertPage.routeName,
        arguments: PgData(pgData: _strPhone,),);
    } else {
      _showDialogMsg('전화번호를 입력해 주세요');
    }
  }

  void _showDialogMsg(String msg) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15.0,),
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 15.0,),

                  const Text('알림', style: TStyle.title20, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  const SizedBox(height: 30.0,),

                  Text(msg, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  const SizedBox(height: 20.0,),

                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,),),
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

}