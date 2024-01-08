import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/des/http_process_class.dart';
import 'package:rassi_assist/provider/login_rassi_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/join_rassi_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.09
/// 라씨 로그인
class RassiLoginPage extends StatefulWidget {
  static const routeName = '/page_login_rassi';
  static const String TAG = "[RassiLoginPage]";
  static const String TAG_NAME = '씽크풀_아이디_로그인';

  const RassiLoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RassiLoginPageState();
}

class RassiLoginPageState extends State<RassiLoginPage> {
  final _scrollController = ScrollController();
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String _tempId = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(RassiLoginPage.TAG_NAME);
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'in_login_rassi');
    Provider.of<LoginRassiProvider>(context, listen: false).initValueFalse();
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
      body: SafeArea(
        child: KeyboardVisibilityBuilder(builder: (_, isKeyboardVisible) {
          return LayoutBuilder(builder: (layoutBuilderContext, constraint) {
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
                (_) => Provider.of<LoginRassiProvider>(context, listen: false)
                    .setValue(isKeyboardVisible));
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const Text(
                              RString.desc_waiting_for_you,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: _idController,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      labelText: '아이디',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white60),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white60),
                                      ),
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 100),
                                    onTap: () {
                                      _goBottomPage();
                                    },
                                  ),
                                  const SizedBox(height: 12.0),
                                  TextField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: _passController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      labelText: '비밀번호',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white60),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white60),
                                      ),
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 100),
                                  ),
                                  _setAnotherRoute(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _isLoading,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey.withOpacity(0.1),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'images/gif_ios_loading_large.gif',
                              height: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }),
      ),
      bottomSheet: Consumer<LoginRassiProvider>(
        builder: (_, value, __) {
          if (value.getIsKeyboardVisible) {
            return InkWell(
              child: Container(
                width: double.infinity,
                height: 60,
                color: RColor.purpleBasic_6565ff,
                child: const Center(
                  child: Text(
                    '입력완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
              },
            );
          } else {
            return InkWell(
              child: Container(
                width: double.infinity,
                height: 60 + MediaQuery.of(context).padding.bottom,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                color: RColor.purpleBasic_6565ff,
                child: const Center(
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              onTap: () {
                String id = _idController.text.trim();
                String pass = _passController.text.trim();
                _checkEditData(id, pass);
              },
            );
          }
        },
      ),
    );
  }

  void _goBottomPage() {
    if (_scrollController.position != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastOutSlowIn,
        );
      });
    }
  }

  //아이디/비밀번호 찾기, 회원가입
  Widget _setAnotherRoute() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                child: const Text(
                  '아이디 찾기',
                  style: TStyle.wtText,
                ),
                onTap: () {
                  commonLaunchURL(Net.URL_FIND_TP_ID);
                },
              ),
              const Text(
                ' / ',
                style: TStyle.wtText,
              ),
              InkWell(
                child: const Text(
                  '비밀번호 찾기',
                  style: TStyle.wtText,
                ),
                onTap: () {
                  commonLaunchURL(Net.URL_FIND_TP_PW);
                },
              ),
            ],
          ),
          InkWell(
            child: const Text(
              RString.join_think_pool,
              style: TStyle.wtText,
            ),
            onTap: () {
              Navigator.pushNamed(context, RassiJoinPage.routeName);
            },
          ),
        ],
      ),
    );
  }

  //로그인 입력값 체크
  void _checkEditData(final String id, final String pass) {
    if (id.isEmpty) {
      commonShowToast('아이디를 입력해 주세요');
    } else {
      if (pass.isEmpty) {
        commonShowToast('패스워드를 입력해 주세요');
      } else {
        setState(() => _isLoading = true);
        String strParam =
            "userid=${Net.getEncrypt(id.toLowerCase())}&passWd=${Net.getEncrypt(pass)}";
        _tempId = id.toLowerCase();
        _requestThink(strParam);
      }
    }
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
      // Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BasePage()),
          (route) => false);
    } else {}
  }

  // 씽크풀 API 호출
  void _requestThink(String param) async {
    DLog.d(RassiLoginPage.TAG, 'Login param : $param');

    var url = Uri.parse(Net.THINK_LOGIN);
    final http.Response response =
        await http.post(url, headers: Net.think_headers, body: param);

    DLog.d(RassiLoginPage.TAG, '${response.statusCode}');
    DLog.d(RassiLoginPage.TAG, response.body);

    final String result = response.body;
    if (result != 'ERR' && result.isNotEmpty) {
      DLog.d(RassiLoginPage.TAG, '씽크풀 로그인 완료');

      HttpProcessClass().callHttpProcess0001(_tempId).then((value) {
        DLog.d(RassiLoginPage.TAG, 'then() value : $value');
        switch (value.appResultCode) {
          case 200:
            {
              _goNextRoute(_tempId);
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
              break;
            }
        }
      });
    } else {
      //씽크풀 로그인 실패 & 알림팝업
      DLog.d(RassiLoginPage.TAG, '씽크풀 로그인 실패');
      commonShowToast(
          '씽크풀 회원이 아니시거나 입력정보가 틀립니다. 아이디가 없으신 경우에는 회원가입을 해주시기 바랍니다.');
      setState(() => _isLoading = false);
    }
  }
}
