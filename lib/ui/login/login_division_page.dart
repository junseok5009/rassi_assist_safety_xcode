import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:apple_sign_in_safety/apple_sign_in.dart' as asi;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/des/http_process_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/login/join_phone_page.dart';
import 'package:rassi_assist/ui/login/join_route_page.dart';
import 'package:rassi_assist/ui/login/login_rassi_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';


/// 2021.03.11
/// 로그인 구분
class LoginDivisionPage extends StatefulWidget {
  static const routeName = '/page_login_division';
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
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => _requestAppTracking());

  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.none(RColor.mainColor,),
        body: SafeArea(
          child: Container(
            color: RColor.mainColor,
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'images/rassibs_intro_bn_img_3_0807_bg.png',
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        iconSize: 22,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10,), // 패딩 설정
                        //constraints: BoxConstraints(), // constraints
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      top:0.0,
                      right: 0.0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20,),
                        alignment: Alignment.bottomRight,
                        child: const Text(
                          '라씨 매매비서가\n회원님을 기다리고 있습니다.',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                            //fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      children: [
                        //로그인 버튼 배열
                        const SizedBox(
                          height: 10,
                        ),
                        _setLoginBtns(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        //하단 이용약관 표시
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 1.0,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _setTermsText(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //쓱로그인, 네이버, 씽크풀 로그인, 다른 방법으로 로그인
  Widget _setLoginBtns() {
    return Column(
      children: [
        //전화번호로 로그인
        Container(
          width: 250,
          height: 45,
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: const BorderSide(color: RColor.mainColor)),
            color: RColor.mainColor,
            textColor: Colors.white,
            child: const Text(
              '휴대폰 번호로 간편하게 시작하기',
              style: TStyle.btnTextWht15,
            ),
            onPressed: () {
              Navigator.pushNamed(context, JoinPhonePage.routeName);
              // Navigator.pushNamed(context, SsgJoinPage.routeName);
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),

        //네이버 아이디로 로그인
        Container(
          width: 250,
          height: 45,
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: const BorderSide(color: RColor.naver),
            ),
            color: RColor.naver,
            textColor: Colors.white,
            child: const Text(
              '네이버 아이디로 시작하기',
              style: TStyle.btnTextWht15,
            ),
            onPressed: () {
              _getNaverInfo();
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),

        //카카오 아이디로 로그인
        Visibility(
          visible: true,
          child: Container(
            width: 250,
            height: 45,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: const BorderSide(color: RColor.kakao),
              ),
              color: RColor.kakao,
              textColor: Colors.white,
              child: const Text(
                '카카오 아이디로 시작하기',
                style: TStyle.commonTitle15,
              ),
              onPressed: () {
                _setUpKakaoLogin();
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),

        //애플 아이디로 로그인
        Visibility(
          visible: Platform.isIOS,
          child: Container(
            width: 250,
            height: 45,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: const BorderSide(color: Colors.black),
              ),
              color: Colors.black,
              textColor: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/img_apple.png',
                    height: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Apple로 계속하기',
                    style: TStyle.btnTextWht15,
                  ),
                ],
              ),
              onPressed: () {
                signInWithApple();
              },
            ),
          ),
        ),
        const SizedBox(
          height: 0,
        ),

        //구글 아이디로 로그인
        Visibility(
          visible: Platform.isAndroid,
          child: Container(
            width: 250,
            height: 45,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: const BorderSide(color: RColor.bgGoogle),
              ),
              color: RColor.bgGoogle,
              textColor: Colors.white,
              child: const Text(
                '구글 아이디로 시작하기',
                style: TStyle.btnTextWht15,
              ),
              onPressed: () {
                signInWithGoogle();
              },
            ),
          ),
        ),

        Center(
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: SizedBox(
              width: 250,
              child: ExpansionTile(
                collapsedIconColor: RColor.new_basic_text_color_grey,
                iconColor: RColor.new_basic_text_color_grey,
                initiallyExpanded: false,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                leading: null,
                title: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '         로그인 방법 더보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: RColor.new_basic_text_color_grey,
                    ),
                  ),
                ),
                children: [
                  //씽크풀 아이디로 로그인
                  SizedBox(
                    width: 250,
                    height: 45,
                    child: MaterialButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(color: RColor.deepBlue),
                      ),
                      color: RColor.deepBlue,
                      textColor: Colors.white,
                      child: const Text(
                        '씽크풀(라씨) 아이디로 시작하기',
                        style: TStyle.btnTextWht15,
                      ),
                      onPressed: () {
                        // Navigator.pushNamed(context, RassiLoginPage.routeName);

                        // TODO ===== 테스트 ===== //TODO  TEST  TEST   TEST  TEST
                        _goNextRoute('developtest');
                        //TODO  TEST  TEST   TEST  TEST


                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        }else{
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 성공');
          } catch (error) {
            DLog.d(LoginDivisionPage.TAG, '카카오계정으로 로그인2 실패 $error');
          }
        }
      } catch (error) {
        DLog.d(LoginDivisionPage.TAG, '카카오톡으로 로그인 실패 $error');
        DLog.d(LoginDivisionPage.TAG, '${error.toString()}');

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
        if (numId != null && numId.length > 0) {
          _reqPos = 'KAKAO';
          _reqParam = 'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=KAKAO';
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
      if (numId != null && numId.length > 0) {
        _reqPos = 'KAKAO';
        _reqParam = 'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=KAKAO';
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
    if (numId != null && numId.length > 0) {
      _reqPos = 'NAVER';
      DLog.d(LoginDivisionPage.TAG, 'Naver Num ID : $numId');
      _reqParam = 'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=NAVER';
      _requestThink(numId, email, name);
    }
  }

  //Apple 로그인
  void signInWithApple() async {
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
          _reqParam = 'snsId=${Net.getEncrypt(aId)}&snsEmail=$email&snsPos=APPLE';
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
  }

  //Google 로그인
  void signInWithGoogle() async {
/*    GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if(googleUser != null) {
      // DLog.d(LoginDivisionPage.TAG, 'name = ${googleUser.displayName}');
      DLog.d(LoginDivisionPage.TAG, 'email = ${googleUser.email}');
      DLog.d(LoginDivisionPage.TAG, 'id = ${googleUser.id}');

      String numId = googleUser.id;
      String email = googleUser.email;
      if (numId != null && numId.length > 0) {
        _reqPos = 'GOOGLE';
        DLog.d(LoginDivisionPage.TAG, 'Google Num ID : $numId');
        _reqParam = 'snsId=${Net.getEncrypt(numId)}&snsEmail=$email&snsPos=GOOGLE';
        _requestThink(numId, email, '');
      }
    }*/
  }

  // 다음 페이지로 이동
  void _goNextRoute(String userId) {
    commonShowToast('로그인 되었습니다.');
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (_reqPos) {
      case 'KAKAO':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.kakao));
          break;
        }
      case 'NAVER':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.naver));
          break;
        }
      case 'APPLE':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.apple));
          break;
        }
      case 'GOOGLE':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.google));
          break;
        }
    }
    if (userId != '') {
      if (basePageState != null) {
        // basePageState = null;
        basePageState = BasePageState();
      }

      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => const BasePage()), (route) => false);
    } else {}
  }

  //이용약관, 개인정보처리방침
  Widget _setTermsText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '시작시 ',
          style: TStyle.textSGrey,
        ),
        InkWell(
          child: const Text(
            '이용약관',
            style: TStyle.ulTextBlue,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebPage(),
                  settings: RouteSettings(
                    arguments: PgData(pgData: Net.AGREE_TERMS),
                  ),
                ));
          },
        ),
        const Text(
          '과 ',
          style: TStyle.textSGrey,
        ),
        InkWell(
          child: const Text(
            '개인정보 처리방침',
            style: TStyle.ulTextBlue,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebPage(),
                  settings: RouteSettings(
                    arguments: PgData(pgData: Net.AGREE_POLICY_INFO),
                  ),
                ));
          },
        ),
        const Text(
          '에 동의 됩니다.',
          style: TStyle.textSGrey,
        ),
      ],
    );
  }

  //App Tracking Transparency (ATT 팝업 : 설치 후 한번만 노출됨)
  Future<void> _requestAppTracking() async {
    if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.notDetermined) {
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
    final http.Response response = await http.post(urls,
        headers: Net.think_headers,
        body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(LoginDivisionPage.TAG, '${response.statusCode}');
    DLog.d(LoginDivisionPage.TAG, response.body);

    final String result = response.body;
    if (result.length > 0) {
      final ThinkLoginSns resData = ThinkLoginSns.fromJson(jsonDecode(result));
      if (resData.resultCode.toString().trim() == '-1') {
        DLog.d(LoginDivisionPage.TAG, '씽크풀 가입안됨');

        //씽크풀 회원가입 루트 선택 페이지로 이동
        Navigator.pushNamed(
          context,
          JoinRoutePage.routeName,
          arguments:
          PgData(userId: userId, pgData: email, pgSn: name, flag: _reqPos),
        );
      } else {
        DLog.d(LoginDivisionPage.TAG, '씽크풀 가입 되어 있음');
        _tempId = resData.userId;
        HttpProcessClass().callHttpProcess0001(_tempId).then((value) {
          DLog.d(LoginDivisionPage.TAG, 'then() value : ${value.toString()}');
          DLog.d(
              LoginDivisionPage.TAG, 'then() if value null : ${value == null}');
          switch (value.appResultCode) {
            case 200:
              {
                _goNextRoute(_tempId);
                break;
              }
            case 400:
              {
                CommonPopup().showDialogNetErr(context);
                break;
              }
            default:
              {
                CommonPopup().showDialogMsg(context, value.appDialogMsg);
              }
          }
        });
      }
    }
  }
}
