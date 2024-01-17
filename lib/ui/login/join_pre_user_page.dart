import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/http_process_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2021.05.06
/// SSG 이미 가입된 유저 페이지
class JoinPreUserPage extends StatefulWidget {
  static const routeName = '/page_join_pre_user';
  static const String TAG = "[JoinPreUserPage]";
  static const String TAG_NAME = '쓱가입_가입된_회원';

  const JoinPreUserPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinPreUserPageState();
}

class JoinPreUserPageState extends State<JoinPreUserPage> {
  PgData? args;
  String deviceModel = '';
  String deviceOsVer = '';
  String _strId = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(JoinPreUserPage.TAG_NAME);
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      _strId = args?.userId ?? '';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: ListView(
          children: [
            const Text(
              '기존 로그인 정보가\n존재합니다.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40,
            ),

            //가입된 아이디 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: UIStyle.boxWeakGrey10(),
              child: Center(
                child: Text(
                  'ID : $_strId',
                  style: TStyle.defaultContent,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '본인의 로그인 정보가 아닐 경우 고객센터로 연락 주세요',
                  style: TStyle.contentGrey14,
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '02-2174-6445  /  ',
                      style: TStyle.contentGrey14,
                    ),
                    InkWell(
                      splashColor: Colors.deepPurpleAccent.withAlpha(30),
                      child: const Text(
                        '카카오톡 문의',
                        style: TStyle.ulTextPurple,
                      ),
                      onTap: () {
                        commonLaunchURL(Net.URL_KAKAO_QA);
                      },
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),

            Column(
              children: [
                CommonView.setConfirmBtnView(
                  () => HttpProcessClass()
                      .callHttpProcess0001(_strId)
                      .then((value) {
                    DLog.d(JoinPreUserPage.TAG, 'then() value : $value');
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
                          CommonPopup.instance
                              .showDialogMsg(context, value.appDialogMsg);
                          break;
                        }
                    }
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 다음 페이지로 이동
  void _goNextRoute(String userId) {
    commonShowToast('로그인 되었습니다.');
    CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.ssg));

    if (userId != '') {
      if (basePageState != null) {
        // basePageState = null;
        basePageState = BasePageState();
      }
      // Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const BasePage(),
              settings: const RouteSettings(name: '/base')),
          (route) => false);
    } else {}
  }
}
