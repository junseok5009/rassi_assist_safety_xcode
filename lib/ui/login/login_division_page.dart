import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/common_function_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/http_process_class.dart';
import 'package:rassi_assist/models/none_tr/user_join_info.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/agent/agent_sign_up_page.dart';
import 'package:rassi_assist/ui/login/join_phone_page.dart';
import 'package:rassi_assist/ui/login/login_rassi_page.dart';
import 'package:rassi_assist/ui/login/terms_of_use_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// 2021.03.11
/// 로그인 구분
class LoginDivisionPage extends StatefulWidget {
  static const routeName = '/login_division';
  static const String TAG = "[LoginDivisionPage]";
  static const String TAG_NAME = '로그인_선택';
  static final GlobalKey<LoginDivisionPageState> globalKey = GlobalKey();

  LoginDivisionPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => LoginDivisionPageState();
}

class LoginDivisionPageState extends State<LoginDivisionPage> {
  String _reqParam = '';
  String _reqPos = '';
  String _tempId = '';
  String deviceModel = '';
  String deviceOsVer = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(LoginDivisionPage.TAG_NAME);
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'in_login_select');
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => _requestAppTracking());
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '라씨 매매비서가\n회원님을 기다리고 있습니다.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Text(
                '\nSNS 아이디로 시작하기에서는\n휴대폰 번호가 필요없어요.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: _setLoginBtns(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //쓱로그인, 네이버, 씽크풀 로그인, 다른 방법으로 로그인
  Widget _setLoginBtns() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //전화번호로 로그인
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pushNamed(context, JoinPhonePage.routeName);
            },
            child: Container(
              width: 270,
              height: 50,
              decoration: UIStyle.boxRoundFullColor25c(
                RColor.purpleBasic_6565ff,
              ),
              alignment: Alignment.center,
              child: const Text(
                '휴대폰 번호로 간편하게 시작하기',
                style: TStyle.btnContentWht15,
              ),
            ),
          ),

          // 카카오
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _setUpKakaoLogin();
            },
            child: Container(
              width: 270,
              height: 50,
              margin: const EdgeInsets.only(
                top: 15,
              ),
              decoration: UIStyle.boxRoundFullColor25c(
                const Color(
                  0xfffad200,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icon_kakao_talk.png',
                    height: 20,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  const Text(
                    '카카오 아이디로 시작하기',
                    style: TStyle.content15,
                  ),
                ],
              ),
            ),
          ),

          // 네이버
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _getNaverInfo();
            },
            child: Container(
              width: 270,
              height: 50,
              margin: const EdgeInsets.only(
                top: 15,
              ),
              decoration: UIStyle.boxRoundFullColor25c(
                const Color(
                  0xff2db400,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icon_naver.png',
                    height: 20,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  const Text(
                    '네이버 아이디로 시작하기',
                    style: TStyle.content15,
                  ),
                ],
              ),
            ),
          ),

          Platform.isAndroid
              ?
              //구글
              InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    signInWithGoogle();
                  },
                  child: Container(
                    width: 270,
                    height: 50,
                    decoration: UIStyle.boxRoundLine25c(
                      RColor.greyBoxLine_c9c9c9,
                    ),
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/icon_google.png',
                          height: 20,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        const Text(
                          '구글 아이디로 시작하기',
                          style: TStyle.content15,
                        ),
                      ],
                    ),
                  ),
                )
              :
              //애플 로그인
              InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    _signInWithApple2();
                  },
                  child: Container(
                    width: 270,
                    height: 50,
                    decoration: UIStyle.boxRoundLine25c(
                      RColor.greyBoxLine_c9c9c9,
                    ),
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apple,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          '애플 아이디로 시작하기',
                          style: TStyle.content15,
                        ),
                      ],
                    ),
                  ),
                ),

          // 씽크풀
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pushNamed(context, RassiLoginPage.routeName);
            },
            child: Container(
              width: 270,
              height: 50,
              margin: const EdgeInsets.only(
                top: 15,
              ),
              decoration: UIStyle.boxRoundFullColor25c(
                RColor.lightSell_2e70ff,
              ),
              alignment: Alignment.center,
              child: const Text(
                '라씨(씽크풀) 아이디로 시작하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //카카오 로그인
  void _setUpKakaoLogin() async {
    DLog.d(LoginDivisionPage.TAG, '_setUpKakaoLogin()');
    if (await AuthApi.instance.hasToken()) {
      DLog.d(LoginDivisionPage.TAG, 'hasToken() true');
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        DLog.d(LoginDivisionPage.TAG,
            '토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        _getKakaoUserInfo();
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          DLog.d(LoginDivisionPage.TAG, '토큰 만료');
        } else {
          DLog.d(LoginDivisionPage.TAG, '토큰 정보 조회 실패');
        }
        _goKakaoLogin();
      }
    } else {
      DLog.d(LoginDivisionPage.TAG, 'hasToken() false 발급된 토큰 없음');
      _goKakaoLogin();
    }
  }

  Future<void> _goKakaoLogin() async {
    DLog.d(LoginDivisionPage.TAG, 'goKakaoLogin()');
    OAuthToken? token;

    if (await isKakaoTalkInstalled()) {
      DLog.d(LoginDivisionPage.TAG, '카카오톡 설치 유저');
      try {
        DLog.d(LoginDivisionPage.TAG, '카카오톡 로그인 시도');
        token = await UserApi.instance.loginWithKakaoTalk();
        DLog.d(LoginDivisionPage.TAG, '카카오톡으로 로그인 성공');
      } on PlatformException catch (perror) {
        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        DLog.d(LoginDivisionPage.TAG, 'perror.code : ${perror.code}');
        DLog.d(LoginDivisionPage.TAG, 'perror.details : ${perror.details}');
        DLog.d(LoginDivisionPage.TAG, 'perror.message : ${perror.message}');

        if (perror.code == 'CANCELED') {
          commonShowToast('카카오 로그인을 취소하였습니다.');
        } else {
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 성공');
          } catch (error) {
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 실패 $error');
          }
        }
      } catch (error) {
        DLog.d(LoginDivisionPage.TAG, '카카오톡으로 로그인 실패 $error');
        DLog.d(LoginDivisionPage.TAG, error.toString());

        if (error.toString().isNotEmpty &&
            error.toString().contains('User denied access')) {
          commonShowToast('카카오 로그인을 취소하였습니다.');
        } else {
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인1 성공');
          } catch (error) {
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인1 실패 $error');
          }
        }
      }
    } else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
        DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 성공');
      } catch (error) {
        DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 실패 $error');
      }
    }

    if (token != null) {
      DLog.d(LoginDivisionPage.TAG, 'token != null');
      DLog.d(LoginDivisionPage.TAG, 'accessToken : ${token.accessToken}');

      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        DLog.d(LoginDivisionPage.TAG, '회원정보 / tokenInfo.id : ${tokenInfo.id}');
        DLog.d(LoginDivisionPage.TAG,
            '토큰만료시간 / tokenInfo.expiresIn : ${tokenInfo.expiresIn}');

        String numId = tokenInfo.id.toString();
        String email = '';
        String name = '';
        if (numId.isNotEmpty) {
          _reqPos = 'KAKAO';
          _reqParam =
              'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=KAKAO';
          _requestThink(numId, email, name);
        }
      } catch (error) {
        DLog.d(LoginDivisionPage.TAG, '토큰 정보 보기 실패 $error');
      }
    }
  }

  Future<void> _getKakaoUserInfo() async {
    DLog.d(LoginDivisionPage.TAG, 'getKakaoUserInfo()');
    try {
      User user = await UserApi.instance.me();
      DLog.d(LoginDivisionPage.TAG, '사용자 정보 요청 성공');
      DLog.d(LoginDivisionPage.TAG, '회원번호: ${user.id}');
      DLog.d(LoginDivisionPage.TAG,
          '닉네임 : ${user.kakaoAccount?.profile?.nickname}');
      DLog.d(LoginDivisionPage.TAG, '이메일: ${user.kakaoAccount?.email}');

      String numId = user.id.toString();
      String email = '';
      String name = '';
      if (numId.isNotEmpty) {
        _reqPos = 'KAKAO';
        _reqParam =
            'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=KAKAO';
        _requestThink(numId, email, name);
      }
    } catch (error) {
      DLog.d(LoginDivisionPage.TAG, '사용자 정보 요청 실패 $error');
      await UserApi.instance.unlink();
      try {
        await UserApi.instance.unlink(); // unlink는 토큰 삭제 + 로그아웃
        _goKakaoLogin();
      } catch (error) {
        DLog.d(LoginDivisionPage.TAG, 'error : $error');
      }
    }
  }

  //네이버 로그인 정보
  void _getNaverInfo() async {
    NaverLoginResult result = await FlutterNaverLogin.logIn();
    DLog.d(LoginDivisionPage.TAG, '####### NAVER ${result.account.email}');
    DLog.d(LoginDivisionPage.TAG, '####### NAVER ${result.account.id}');
    DLog.d(LoginDivisionPage.TAG, '####### NAVER ${result.account.name}');

    String numId = result.account.id;
    String email = result.account.email;
    String name = result.account.name;
    if (numId.isNotEmpty) {
      _reqPos = 'NAVER';
      DLog.d(LoginDivisionPage.TAG, 'Naver Num ID : $numId');
      _reqParam = 'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=NAVER';
      _requestThink(numId, email, name);
    }
  }

  //Apple 로그인
  void _signInWithApple2() async {
    SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    ).then((AuthorizationCredentialAppleID credential) {
      String? aId = credential.userIdentifier;
      // CredentialState state = SignInWithApple.getCredentialState(id ?? '') as CredentialState;
      // DLog.w('#### AppleCredential: ${state.name}');     // 'authorized' / 'revoked' / 'notFound':
      if (aId != null && aId.isNotEmpty) {
        String email = credential.email ?? '';
        String familyName = credential.familyName ?? '';
        String givenName = credential.givenName ?? '';
        if (aId.length > 5) {
          _reqPos = 'APPLE';
          _reqParam =
              'snsId=${Net.getEncrypt(aId)}&snsEmail=$email&snsPos=APPLE';
          _requestThink(aId, email, familyName + givenName);
        }
      } else {
        return;
      }
    }).onError((error, stackTrace) {
      if (error is PlatformException) return;
    });
  }

/*  void _signInWithApple() async {
    bool isAvailable = await asi.AppleSignIn.isAvailable();
    if (!isAvailable) {
      commonShowToast('해당 기기에서 Apple 로그인이 지원되지 않습니다');
      return null;
    }

    asi.AuthorizationResult result;
    try {
      result = await asi.AppleSignIn.performRequests([
        const asi.AppleIdRequest(
            requestedScopes: [asi.Scope.email, asi.Scope.fullName])
      ]);
    } catch (e) {
      DLog.d(LoginDivisionPage.TAG, e as String);
      return null;
    }

    switch (result.status) {
      case asi.AuthorizationStatus.authorized:
      //An identifier associated with the authenticated user. Can be null.
        DLog.d(LoginDivisionPage.TAG, '##### ${result.credential?.user}');

        DLog.d(LoginDivisionPage.TAG, '##### ${result.credential?.email}');
        DLog.d(LoginDivisionPage.TAG,
            '##### ${String.fromCharCodes(result.credential?.identityToken as Iterable<int>)}');
        DLog.d(LoginDivisionPage.TAG,
            '##### ${result.credential?.fullName?.givenName}');
        DLog.d(LoginDivisionPage.TAG,
            '##### ${result.credential?.fullName?.middleName}');
        DLog.d(LoginDivisionPage.TAG,
            '##### ${result.credential?.fullName?.familyName}');
        // DLog.d(LoginDivisionPage.TAG, '##### ${result.credential.state}');
        // DLog.d(LoginDivisionPage.TAG, '##### ${result.credential.realUserStatus}');
        // DLog.d(LoginDivisionPage.TAG, '##### ${String.fromCharCodes(result.credential.authorizationCode)}');

        String? aId = result.credential?.user;
        String email = result.credential?.email ?? '';
        String name = result.credential?.fullName?.givenName ?? '';
        if (aId != null && aId.length > 5) {
          _reqPos = 'APPLE';
          _reqParam =
              'snsId=${Net.getEncrypt(aId)}&snsEmail=$email&snsPos=APPLE';
          _requestThink(aId, email, name);
        }
        break;

      case asi.AuthorizationStatus.error:
        commonShowToast('로그인 에러가 발생했습니다.');
        DLog.d(LoginDivisionPage.TAG,
            'Sign in failed: ${result.error?.localizedDescription}');
        break;

      case asi.AuthorizationStatus.cancelled:
        if (Const.isDebuggable) commonShowToast('사용자 로그인 취소');
        break;
    }
    return null;
  }*/

  //Google 로그인
  void signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      // DLog.d(LoginDivisionPage.TAG, 'name = ${googleUser.displayName}');
      DLog.d(LoginDivisionPage.TAG, 'email = ${googleUser.email}');
      DLog.d(LoginDivisionPage.TAG, 'id = ${googleUser.id}');

      String numId = googleUser.id;
      String email = googleUser.email;
      if (numId.isNotEmpty) {
        _reqPos = 'GOOGLE';
        DLog.d(LoginDivisionPage.TAG, 'Google Num ID : $numId');
        _reqParam =
            'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=GOOGLE';
        _requestThink(numId, email, '');
      }
    }
  }

  // 다음 페이지로 이동
  void _goNextRoute(String userId) {
    commonShowToast('로그인 되었습니다.');
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (_reqPos) {
      case 'KAKAO':
        {
          CustomFirebaseClass.logEvtLogin(LoginPlatform.kakao.name);
          break;
        }
      case 'NAVER':
        {
          CustomFirebaseClass.logEvtLogin(LoginPlatform.naver.name);
          break;
        }
      case 'APPLE':
        {
          CustomFirebaseClass.logEvtLogin(LoginPlatform.apple.name);
          break;
        }
      case 'GOOGLE':
        {
          CustomFirebaseClass.logEvtLogin(LoginPlatform.google.name);
          break;
        }
    }
    if (userId != '') {
      // basePageState = null;
      basePageState = BasePageState();

      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BasePage(),
            settings: const RouteSettings(name: '/base'),
          ),
          (route) => false);
    } else {}
  }

  //App Tracking Transparency (ATT 팝업 : 설치 후 한번만 노출됨)
  Future<void> _requestAppTracking() async {
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
        TrackingStatus.notDetermined) {
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  // 씽크풀 API 호출
  void _requestThink(String userId, String email, String name) async {
    DLog.d(LoginDivisionPage.TAG, '씽크풀 API 호출');
    DLog.d(LoginDivisionPage.TAG, 'Think Req Param : $_reqParam');

    String url = Net.THINK_SNS_LOGIN;

    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(LoginDivisionPage.TAG, '${response.statusCode}');
    DLog.d(LoginDivisionPage.TAG, response.body);

    final String result = response.body;
    if (result.isNotEmpty && mounted) {
      final ThinkLoginSns resData = ThinkLoginSns.fromJson(jsonDecode(result));
      if (resData.resultCode.toString().trim() == '-1') {
        DLog.d(LoginDivisionPage.TAG, '씽크풀 가입안됨');

        // 24.03.15 Agent 추가, 링크 있을 경우 + 씽크풀 가입 X, 앱 가입 라서 신규 회원 가입
        await CommonFunctionClass.instance.isAgentLinkSaved.then(
          (isAgentLinkSaved) => {
            if (mounted && isAgentLinkSaved)
              {
                // Agent회원 - 회원가입으로 이동
                Navigator.pushNamed(
                  context,
                  AgentSignUpPage.routeName,
                  arguments: UserJoinInfo(
                    userId: userId,
                    email: email,
                    name: name,
                    phone: '',
                    pgType: _reqPos,
                  ),
                ),
              }
            else
              {
                // 일반회원 - 약관 동의로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsOfUsePage(
                      UserJoinInfo(
                        userId: userId,
                        email: email,
                        name: name,
                        phone: '',
                        pgType: _reqPos,
                      ),
                    ),
                  ),
                ),
              }
          },
        );
      } else {
        DLog.d(LoginDivisionPage.TAG,
            '씽크풀 가입 되어 있음 resData.encHpNo : ${resData.encHpNo}');
        //DLog.d(LoginDivisionPage.TAG, 'Net.getDecrypt(resData.encHpNo) : ${Net.getDecrypt(resData.encHpNo)}');
        _tempId = resData.userId;
        await HttpProcessClass().callHttpProcess0001(_tempId).then((value) {
          DLog.d(LoginDivisionPage.TAG, 'then() value : ${value.toString()}');
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
              }
          }
        });
      }
    }
  }
}
