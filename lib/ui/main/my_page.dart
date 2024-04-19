import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_app/tr_app02.dart';
import 'package:rassi_assist/models/tr_notice01.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_history_page.dart';
import 'package:rassi_assist/ui/pay/pay_manage_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/test/test_page.dart';
import 'package:rassi_assist/ui/user/terms_page.dart';
import 'package:rassi_assist/ui/user/usage_info_page.dart';
import 'package:rassi_assist/ui/user/user_center_page.dart';
import 'package:rassi_assist/ui/user/user_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/custom_nv_route_class.dart';
import '../pay/payment_service.dart';

/// 2020.10.06
/// My
class MyPage extends StatefulWidget {
  static const routeName = '/page_my';
  static const String TAG = "[MyPage]";
  static const String TAG_NAME = 'MY메인';
  static final GlobalKey<MyPageState> globalKey = GlobalKey();

  MyPage({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final String _appEnv = Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20
  var appGlobal = AppGlobal();
  var inAppBilling;

  late SharedPreferences _prefs;
  String _userId = '';
  String _adminCode = '00700070';
  String _getToken = '';
  String _preToken = '';
  String _todayString = '0000';
  String _dayCheckPush = '';

  String _strGrade = '';
  String _imgGrade = 'images/main_my_icon_basic.png';
  bool _isPushOn = false; //PUSH 수신동의
  String _stockCnt = ''; //열람 가능 종목수
  String _pocketCnt = ''; //이용 가능 포켓수
  String _strUpgrade = ''; //결제 업그레이드
  String _strPromotionText = ''; //텍스트 프로모션
  bool _isPremium = false;
  bool _isUpgradeable = false; //결제 업그레이드 가능

  List<Notice01> _listNotice = [];

  bool prTOP = false, prHGH = false, prMID = false, prLOW = false;
  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];
  final List<App02> _listServiceCenterMenu = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      MyPage.TAG_NAME,
    );
    _setTestPageData();
    _loadPrefData().then(
      (value) => {
        if (_userId != '')
          {
            _fetchPosts(
              TR.NOTICE01,
              jsonEncode(
                <String, String>{
                  'userId': _userId,
                  'appEnv': _appEnv,
                },
              ),
            ),
          },
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _getToken = (await FirebaseMessaging.instance.getToken()) ?? '';
    _prefs = await SharedPreferences.getInstance();
    _todayString = TStyle.getTodayString();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _preToken = _prefs.getString(Const.PREFS_SAVED_TOKEN) ?? '';
    _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_MY) ?? '';
    appGlobal.userId = _userId;

    Platform.isIOS ? inAppBilling = PaymentService() : inAppBilling = PaymentAosService();
  }

  //firebase 원격설정을 이용한 관리자 페이지 코드
  _setTestPageData() async {
    if (Const.isDebuggable) {
      try {
        bool updated = await _remoteConfig.fetchAndActivate();
        if (updated) {
          String pCode = _remoteConfig.getString('ios_test_page_password');
          if (pCode.isNotEmpty) _adminCode = pCode;
          DLog.d(MyPage.TAG, '### Remote Config String : $_adminCode');
        } else {
          DLog.d(MyPage.TAG, '### Remote Config Not updated');
        }
      } on PlatformException catch (exception) {
        DLog.d(MyPage.TAG, '${exception.message}');
      } catch (exception) {
        DLog.d(MyPage.TAG, exception.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgMyPage,
      appBar: CommonAppbar.simpleWithAction(
        'MY',
        [
          //회원정보 설정
          InkWell(
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(
                    'images/main_arlim_icon_mdf.png',
                  ),
                  color: RColor.greyBasicStrong_666666,
                  size: 21,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '설정',
                  style: TStyle.contentGreyTitle,
                ),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
            onTap: () {
              basePageState.callPageRouteUP(const UserInfoPage());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            //최상단 프로모션
            _setPrTop(),

            //나의 계정
            _setMyAccount(),
            _setUserStatusCard(),
            const SizedBox(height: 15),
            _setUserStatusText(),

            //상단 프로모션
            _setPrHigh(),

            _setSubTitle("라씨 매매비서,\n알고 쓰면 더 유용한 나의 비서"),
            const SizedBox(height: 10),
            _setNoticeList(context),
            const SizedBox(height: 20),
            _setPrMid(),
            const SizedBox(height: 10),

            _setSubTitle("나의 결제 관리"),
            const SizedBox(height: 20),
            _setPaymentDiv(),
            const SizedBox(height: 25),

            //결제 연결 배너
            _setPayBanner(),

            _setSubTitle("고객센터"),
            const SizedBox(height: 10),
            _setServiceCenterMenu(),

            Visibility(
              visible: Const.isDebuggable && Const.BASE == 'rassiappdev',
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 10.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  alignment: Alignment.centerLeft,
                  decoration: UIStyle.boxRoundLine6(),
                  child: const Text('# 매매비서 테스트 페이지 #'),
                ),
                onTap: () {
                  _showDialogAdmin();
                },
              ),
            ),
            const SizedBox(height: 5),

            _setPrLow(),
            const SizedBox(height: 25),

            _setCopyright(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  //나의 계정
  Widget _setMyAccount() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '나의 계정',
            style: TStyle.title17,
          ),
          InkWell(
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '계정별 이용안내',
                  style: TStyle.textGrey14,
                ),
                SizedBox(width: 7),
                ImageIcon(
                  AssetImage('images/rassi_icon_qu_bl.png'),
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              basePageState.callPageRouteUP(const UsageInfoPage());
            },
          ),
        ],
      ),
    );
  }

  //나의 계정
  Widget _setUserStatusCard() {
    return Container(
      width: double.infinity,
      //width: 250,
      decoration: UIStyle.boxShadowBasic(16),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            //width: 250,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: RColor.greyBox_f5f5f5,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //상단 좌측 사용 상품정보
                _setUserStatus(),

                //프리미엄 업그레이드 버튼
                Visibility(
                  visible: !_isPremium || _isUpgradeable,
                  child: Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: UIStyle.boxRoundLine6bgColor(
                          RColor.bgBasic_fdfdfd,
                        ),
                        //margin: EdgeInsets.only(left: 10,),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          _strUpgrade,
                          maxLines: 3,
                          style: TextStyle(
                            //좀 더 작은(리스트) 소항목 타이틀 (bold)
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () async {
                        _showPayDialogAndNavigate();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //AI 매매신호
              Expanded(
                child: InkWell(
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: const Text(
                          'AI 매매신호',
                          style: TStyle.content16T,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _isPremium
                          ? Image.asset('images/main_my_icon_sig_cnt1.png', height: 35)
                          : Image.asset('images/main_my_icon_sig_cnt.png', height: 35),
                      const SizedBox(height: 15),
                      Text(
                        _stockCnt,
                        style: TStyle.content17T,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goLandingPage(LD.main_signal, '', '', '', '');
                  },
                ),
              ),

              //포켓
              Expanded(
                child: InkWell(
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        alignment: Alignment.center,
                        // color: RColor.bubbleChartGrey,
                        child: const Text(
                          '포켓',
                          style: TStyle.content16T,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'images/main_my_icon_pocket.png',
                        height: 35,
                        color: _isPremium ? RColor.mainColor : Colors.black,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _pocketCnt,
                        style: TStyle.content17T,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 0,
                    );
                  },
                ),
              ),

              //매매신호 알림
              Expanded(
                child: InkWell(
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        alignment: Alignment.center,
                        // color: RColor.bubbleChartGrey,
                        child: const Text(
                          '매매신호\n알림',
                          style: TStyle.content16T,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'images/main_my_icon_sig_bell.png',
                        height: 35,
                        color: _isPremium ? RColor.mainColor : Colors.black,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _isPushOn ? 'ON' : 'OFF',
                        style: TStyle.content17T,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goLandingPage(LD.main_info, '', '', '', '');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //나의 계정 좌측 유저 정보
  Widget _setUserStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            _imgGrade,
            width: 35,
            height: 35,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          _strGrade,
          style: _isPremium ? TStyle.textMainColor19 : TStyle.textGrey18,
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 7),
        Visibility(
          visible: _isPremium,
          child: Container(
            margin: EdgeInsets.only(right: 7,),
            child: InkWell(
              child: Image.asset(
                'images/icon_kakao_talk.png',
                height: 26,
                fit: BoxFit.contain,
              ),
              onTap: () {
                _showPremiumConsultKakao();
              },
            ),
          ),
        ),
      ],
    );
  }

  //계정별 텍스트 프로모션
  Widget _setUserStatusText() {
    return Visibility(
      visible: !_isPremium || _isUpgradeable,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: UIStyle.boxRoundFullColor10c(
            RColor.purple_e7e7ff,
          ),
          child: Text(
            _strPromotionText,
            style: TStyle.content16,
          ),
        ),
        onTap: () async {
          _showPayDialogAndNavigate();
        },
      ),
    );
  }

  //결제 페이지 전 팝업
  _showPayDialogAndNavigate() async {
    if (_isPremium) {
      if (Platform.isAndroid && _isUpgradeable) {
        // 6개월 상품으로 업그레이드
        String result = await _showDialogPremiumUpgrade();
        if (result == CustomNvRouteResult.landPremiumPage) {
          if (mounted) _navigateRefreshPay(context);
        }
      }
    } else {
      if (Platform.isAndroid && _isUpgradeable) {
        // 1개월 상품으로 업그레이드
        String result = await _showDialogPremiumUpgrade();
        if (result == CustomNvRouteResult.landPremiumPage) {
          if (mounted) _navigateRefreshPay(context);
        }
      } else {
        // 일반적인 프리미엄 결제
        String result = await CommonPopup.instance.showDialogPremium(context);
        if (result == CustomNvRouteResult.landPremiumPage) {
          if (mounted) _navigateRefreshPay(context);
        }
      }
    }
  }

  //알고 쓰면 더 유용한 나의 비서
  Widget _setNoticeList(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listNotice.length,
          itemBuilder: (context, index) {
            return TileNotice01(_listNotice[index]);
          }),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
      child: Text(
        subTitle,
        style: TStyle.title18T,
      ),
    );
  }

  //나의 결제 관리
  Widget _setPaymentDiv() {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: UIStyle.boxWithOpacity16(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/main_my_bill_list.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    '나의 결제 내역',
                    style: TStyle.textGrey15,
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, PayHistoryPage.routeName);
              },
            ),
          ),
          Container(
            width: 0.5,
            height: 110,
            color: Colors.grey,
          ),
          Expanded(
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/main_my_subscription.png',
                    height: 39,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    '정기 결제 이용 현황',
                    style: TStyle.textGrey15,
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, PayManagePage.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 고객센터 메뉴
  Widget _setServiceCenterMenu() {
    return Column(
      children: List.generate(_listServiceCenterMenu.length, (index) {
        App02 item = _listServiceCenterMenu[index];
        switch (item.linkType) {
          case "URL":
            {
              String linkUrl = item.linkPage;
              if (linkUrl.contains('http://') || linkUrl.contains('https://')) {
              } else {
                linkUrl = 'http://$linkUrl';
              }
              return _setBoxBtnUrl(item.menuName, linkUrl);
            }
          case "APP":
            {
              String routeName = '';
              if (item.linkPage == LD.main_my_service_center_11_inquiry) {
                routeName = UserCenterPage.routeName;
              } else if (item.linkPage == LD.main_my_service_center_user_private) {
                routeName = TermsPage.routeName;
              }
              return _setBoxBtn(item.menuName, routeName);
            }
          default:
            {
              return const SizedBox();
            }
        }
      }),
    );
  }

  //Custom Button
  Widget _setBoxBtn(String title, String routeStr) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 55,
        margin: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 15.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TStyle.content16,
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: ImageIcon(
                AssetImage('images/main_my_icon_arrow.png'),
                size: 20,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, routeStr);
      },
    );
  }

  //씽크풀 카피라이트
  Widget _setCopyright() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: const Center(
        child: Text(
          RString.copy_right,
          style: TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  //웹브라우저 호출
  Widget _setBoxBtnUrl(String title, String strUrl) {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: double.infinity,
        height: 55,
        margin: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 15.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: TStyle.content16),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: ImageIcon(
                AssetImage('images/main_my_icon_arrow.png'),
                size: 20,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Platform.isIOS ? commonLaunchURL(strUrl) : commonLaunchUrlApp(strUrl);
      },
    );
  }

  //프리미엄 계정 전용 상담
  _showPremiumConsultKakao() {
    if (context.mounted) {
      return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
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
                    Navigator.pop(context, CustomNvRouteResult.cancel);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '프리미엄 계정 전용 상담',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '사용법을 좀 더 자세히 알고 싶으신가요?\n결제 관련 문의가 있으신가요?\n\n'
                      '아래 상담하기 버튼을 누르시면\n바로 연결됩니다.',
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.kakao,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/icon_kakao_talk.png',
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              '상담하기',
                              style: TStyle.subTitle16,
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        String strUrl = 'http://pf.kakao.com/_swxiLxb/chat';
                        Platform.isIOS ? commonLaunchURL(strUrl) : commonLaunchUrlApp(strUrl);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '이용시간 : 평일 오전9시 ~ 오후5시\n(점심시간 11:30~13:00)',
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ).then(
        (value) {
          if (value != null) {
            return value;
          } else {
            return CustomNvRouteResult.cancel;
          }
        },
      );
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 업그레이드 결제
  Future<String> _showDialogPremiumUpgrade() async {
    if (context.mounted) {
      return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
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
                    Navigator.pop(context, CustomNvRouteResult.cancel);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '프리미엄 계정 업그레이드',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '추가 결제 없이 프리미엄 계정을\n지금 바로 이용해 보세요.',
                      textAlign: TextAlign.start,
                      style: TStyle.content15,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 25,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: UIStyle.boxRoundFullColor6c(
                        RColor.greyBox_f5f5f5,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '프리미엄에서는\n',
                              style: TStyle.content15,
                            ),
                            TextSpan(
                              text: '매매신호 무제한+실시간 알림\n',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: RColor.mainColor,
                              ),
                            ),
                            TextSpan(
                              text: '+포켓추가+나만의 매도신호\n',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: RColor.mainColor,
                              ),
                            ),
                            TextSpan(
                              text: '등을 모두 이용하실 수 있습니다.',
                              style: TStyle.content15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.mainColor,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '계정 업그레이드',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landPremiumPage);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ).then(
        (value) {
          if (value != null) {
            return value;
          } else {
            return CustomNvRouteResult.cancel;
          }
        },
      );
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  //결제 연결 배너
  Widget _setPayBanner() {
    return Visibility(
      visible: !appGlobal.isPremium,
      child: InkWell(
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          width: double.infinity,
          height: 150,
          color: const Color(0xffb57dea),
          child: FittedBox(
            child: Image.asset(
              'images/main_my_img_bn_mypo.png',
              fit: AppGlobal().isTablet ? BoxFit.contain : BoxFit.fill,
            ),
          ),
        ),
        onTap: () {
          if (mounted) _navigateRefreshPay(context);
        },
      ),
    );
  }

  //프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: prTOP,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrTop),
      ),
    );
  }

  //프로모션 - 상단
  Widget _setPrHigh() {
    return Visibility(
      visible: prHGH,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrHgh),
      ),
    );
  }

  //프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: prMID,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrMid),
      ),
    );
  }

  //프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: prLOW,
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: CardProm02(_listPrLow),
      ),
    );
  }

  _navigateRefreshPay(
    BuildContext context,
  ) async {
    Widget? instance;
    Platform.isIOS ? instance = const PayPremiumPage() : instance = const PayPremiumAosPage();

    dynamic result = await Navigator.push(
      context,
      CustomNvRouteClass.createRoute(instance),
    );
    if (result == 'cancel') {
      DLog.d(MyPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(MyPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //푸시 토큰 재생성 체크
  void _checkPushToken() {
    //푸시 재등록 여부(개발모드에서 제외)
    if (!Const.isDebuggable) {
      if (_dayCheckPush != _todayString) {
        DLog.d(MyPage.TAG, 'preToken: $_preToken');
        DLog.d(MyPage.TAG, 'genToken: $_getToken');
        DLog.d(MyPage.TAG, '하루 푸시체크 $_todayString');
        _prefs.setString(Const.PREFS_DAY_CHECK_MY, _todayString);

        if (_preToken != _getToken) {
          DLog.d(MyPage.TAG, '푸시 재등록 PUSH01');
          _fetchPosts(
              TR.PUSH01,
              jsonEncode(<String, String>{
                'userId': _userId,
                'appEnv': _appEnv,
                'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                'pushToken': _getToken,
              }));
        }
      }
    }
  }

  //포켓 생성 등록(POCK01)
  requestGenPocket() {
    DLog.d(MyPage.TAG, '포켓생성');
    _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'crudType': 'C',
          'pocketSn': '',
          'pocketName': '',
        }));
  }

  //관리자 페이지 진입코드
  void _showDialogAdmin() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
          ),
          child: AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _setSubTitle('관리자코드를 입력해주세요'),
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          decoration: UIStyle.boxRoundLine6(),
                          child: TextField(
                            controller: codeController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 170,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      String sCode = codeController.text.trim();
                      if (sCode.isEmpty) {
                        commonShowToast('입력된 코드가 없습니다');
                      } else {
                        Navigator.pop(context);
                        _adminEntrance(sCode);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _adminEntrance(String sCode) async {
    if (_adminCode == '') {
      commonShowToast('관리자코드가 없습니다.');
    } else if (_adminCode != sCode) {
      commonShowToast('입력된 코드가 틀립니다.');
    } else if (_adminCode == sCode) {
      dynamic result = await Navigator.push(
        context,
        CustomNvRouteClass.createRoute(TestPage()),
      );
      if (result == 'cancel') {
        DLog.d(MyPage.TAG, '*** navigete cancel ***');
      } else {
        DLog.d(MyPage.TAG, '*** navigateRefresh');
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(MyPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(MyPage.TAG, response.body);

    if (trStr == TR.NOTICE01) {
      final TrNotice01 resData = TrNotice01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listNotice = resData.listData;
        setState(() {});
      }

      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
    //회원정보 조회
    else if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        DLog.d(MyPage.TAG, data.accountData.toString());

        final AccountData accountData = data.accountData;
        accountData.initUserStatusAfterPayment();
        String curProd = accountData.productId;
        String payMethod = accountData.payMethod;
        DLog.d(MyPage.TAG, '현재 상품: $curProd');

        if (accountData.prodName == '프리미엄') {
          _strGrade = '프리미엄';
          _imgGrade = 'images/main_my_icon_premium.png';
          _stockCnt = '무제한';
          _pocketCnt = '10개';
          _strUpgrade = '';
          _strPromotionText = '';
          _isPremium = true;
          if (Platform.isAndroid) {
            if (curProd == 'ac_pr.am6d0' ||
                curProd == 'ac_pr.am6d5' ||
                curProd == 'ac_pr.am6d7' ||
                curProd == 'ac_pr.mw1e1' ||
                curProd == 'ac_pr.m01') {
              // 업그레이드 결제 차단
              _strUpgrade = '';
              _isUpgradeable = false;
            } else if (payMethod == 'PM50') {
              // 업그레이드 결제 가능
              _strUpgrade = '기간 업그레이드';
              _isUpgradeable = true;
              _strPromotionText = '프리미엄 계정의 기간을 업그레이드 해보세요!';
            }
          }
        }
        //3종목알림
        else if (accountData.prodCode == 'AC_S3') {
          _strGrade = '3종목 알림';
          _imgGrade = 'images/main_my_icon_three.png';
          _stockCnt = '매일 5종목';
          _pocketCnt = '1개';
          _strPromotionText = '추가 결제 없이 프리미엄으로 업그레이드 해보세요!';
          _isPremium = false;
          if (Platform.isAndroid) {
            if (payMethod == 'PM50') {
              _strUpgrade = '프리미엄 업그레이드';
              _isUpgradeable = true;
            }
          }
        }
        //베이직
        else {
          _strGrade = '베이직';
          _imgGrade = 'images/main_my_icon_basic.png';
          _stockCnt = '매일 5종목';
          _pocketCnt = '1개';
          _strUpgrade = '프리미엄 업그레이드'; //일반 결제 화면으로 이동
          _strPromotionText = '회원님, 라씨 매매비서 프리미엄을 이용해 보세요!';
          _isPremium = false;
          if (Platform.isAndroid) inAppBilling.requestPurchaseAsync();
        }

        setState(() {});
      } else {
        const AccountData().setFreeUserStatus();
      }

      _fetchPosts(
          TR.PROM02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'viewPage': 'LPE1',
            'promoDiv': '',
          }));
    }
    //프로모션
    else if (trStr == TR.PROM02) {
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listPrTop.clear();
        _listPrHgh.clear();
        _listPrMid.clear();
        _listPrLow.clear();
        if (resData.retData.isNotEmpty) {
          for (int i = 0; i < resData.retData.length; i++) {
            Prom02 item = resData.retData[i];
            if (item.viewPosition.isNotEmpty) {
              if (item.viewPosition == 'TOP') _listPrTop.add(item);
              if (item.viewPosition == 'HGH') _listPrHgh.add(item);
              if (item.viewPosition == 'MID') _listPrMid.add(item);
              if (item.viewPosition == 'LOW') _listPrLow.add(item);
            }
          }
        }
        setState(() {
          if (_listPrTop.isNotEmpty) prTOP = true;
          if (_listPrHgh.isNotEmpty) prHGH = true;
          if (_listPrMid.isNotEmpty) prMID = true;
          if (_listPrLow.isNotEmpty) prLOW = true;
        });
      }

      _fetchPosts(
          TR.APP02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
          }));
    }
    //고객센터 조회
    else if (trStr == TR.APP02) {
      final TrApp02 resData = TrApp02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listServiceCenterMenu.clear();
        if (resData.listData.isNotEmpty) {
          _listServiceCenterMenu.addAll(resData.listData);
        }
        setState(() {});
      }

      _fetchPosts(
          TR.PUSH04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
    //푸시 설정 정보 조회
    else if (trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.rcvAssentYn == 'Y') _isPushOn = true;
        DLog.d(MyPage.TAG, '앱 푸시 수신동의 : $_isPushOn');

        //String type = 'get_sms';
        //String strParam = "userid=$_userId";
        setState(() {});
      }

      _checkPushToken();
    }
    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _getToken);
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
      }
    }
  }

  // 23.01.26 JS 추가 > prom02 > tileprom02 (배너) 에서 결제하고 돌아오면 화면 갱신
  requestTrUser04() {
    _fetchPosts(
      TR.USER04,
      jsonEncode(
        <String, String>{
          'userId': _userId,
        },
      ),
    );
  }
}
