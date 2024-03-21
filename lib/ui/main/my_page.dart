import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
import 'package:rassi_assist/provider/user_info_provider.dart';
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
  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;
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
  String _imgGrade = 'images/main_my_icon_menu_1.png';
  String _pushYn = ''; //PUSH 수신동의
  String _stockCnt = '';  //열람 가능 종목수
  String _pocketCnt = ''; //이용 가능 포켓수
  String _strUpgrade = ''; //결제 업그레이드

  List<Notice01> _listNotice = [];

  bool _bPayFinished = true; //결제 시도를 하지 않은 상태(결제 완료, 결과가 에러, 결제 시도를 안한 상태 : true)

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
    // _getToken = await _messaging.getToken();
    _prefs = await SharedPreferences.getInstance();
    _todayString = TStyle.getTodayString();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _preToken = _prefs.getString(Const.PREFS_SAVED_TOKEN) ?? '';
    _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_MY) ?? '';
    _bPayFinished = _prefs.getBool(Const.PREFS_PAY_FINISHED) ?? true;
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
          if (pCode != null && pCode.isNotEmpty) _adminCode = pCode;
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
          IconButton(
            icon: const ImageIcon(
              AssetImage(
                'images/main_arlim_icon_mdf.png',
              ),
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
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

            //상단 프로모션
            _setPrHigh(),
            const SizedBox(height: 10),

            _setSubTitle("라씨 매매비서,\n알고 쓰면 더 유용한 나의 비서"),
            _setNoticeList(context),
            const SizedBox(height: 20),
            _setPrMid(),

            _setSubTitle("나의 결제 관리"),
            const SizedBox(height: 15),
            _setPaymentDiv(),
            const SizedBox(height: 25),

            //결제 연결 배너
            _setPayBanner(),

            _setSubTitle("고객센터"),
            const SizedBox(height: 3),
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
                  // _navigateRefreshPay(context, TestPage(), PgData()); //TODO  임시코드
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
      padding: const EdgeInsets.only(top: 15, left: 10, right: 15),
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
                SizedBox(width: 5),
                ImageIcon(
                  AssetImage(
                    'images/rassi_icon_qu_bl.png',
                  ),
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
      decoration: UIStyle.boxShadowBasic(16),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setUserStatus(),
              Visibility(
                child: InkWell(
                  child: Text(_strUpgrade),
                  onTap: (){

                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 3),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //AI 매매신호
              InkWell(
                child: Column(
                  children: [
                    const Text(
                      'AI 매매신호',
                      style: TStyle.content14,
                    ),
                    Text(
                      _stockCnt,
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
                onTap: () {
                  basePageState.goLandingPage(LD.main_signal, '', '', '', '');
                },
              ),

              //포켓
              InkWell(
                child: Column(
                  children: [
                    const Text(
                      '포켓',
                      style: TStyle.content14,
                    ),
                    Text(
                      _pocketCnt,
                      style: TStyle.commonTitle,
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

              //매매신호 알림
              InkWell(
                child: const Column(
                  children: [
                    Text(
                      '매매신호 알림',
                      style: TStyle.content14,
                    ),
                    Text(
                      'On',
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
                onTap: () {
                  basePageState.goLandingPage(LD.main_info, '', '', '', '');
                },
              ),

            ],
          ),
        ],
      ),
    );
  }

  //나의 계정 좌측 유저 정보
  Widget _setUserStatus() {
    return InkWell(
      child: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _imgGrade,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                _strGrade,
                style: TStyle.textGreyDefault,
                textAlign: TextAlign.center,
              ),
            ],
          )
        ],
      ),
      onTap: () async {
        UserInfoProvider userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        if (userInfoProvider.isPremiumUser()) {
          String result = await _showDialogPremiumAlready();
          if (mounted && result == CustomNvRouteResult.landing) {
            basePageState.goLandingPage(LD.linkTypeUrl, 'https://thinkpoolost.wixsite.com/moneybot/service', '', '', '');
          }
        } else {
          String result = '';
          if (userInfoProvider.is3StockUser()) {
            result = await _showDialogPremiumUpgrade();
          } else {
            result = await _showDialogPremium();
          }
          if (mounted && result == CustomNvRouteResult.landPremiumPage) {
            Platform.isIOS
                ? _navigateRefreshPay(context, const PayPremiumPage())
                : _navigateRefreshPay(context, const PayPremiumAosPage());
          }
        }
      },
    );
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
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.title17,
      ),
    );
  }

  //나의 결제 관리
  Widget _setPaymentDiv() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: UIStyle.boxWithOpacity16(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/main_my_icon_m_menu_2.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 7),
                const Text('결제 내역', style: TStyle.textGrey15,),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, PayHistoryPage.routeName);
            },
          ),

          const Divider(thickness: 3,),

          InkWell(
            child: Row(
              children: [
                Image.asset(
                  'images/main_my_icon_m_menu_3.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 7),
                const Text('정기결제', style: TStyle.textGrey15,),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, PayManagePage.routeName);
            },
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
          top: 10.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.centerLeft,
        decoration: UIStyle.boxRoundLine6bgColor(
          Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TStyle.content16,
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
          top: 10.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.centerLeft,
        decoration: UIStyle.boxRoundLine6bgColor(
          Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TStyle.content16,
            ),
            // Icon(Icons.search, size: 20, color: Color.fromARGB(255, 53, 60, 115),),
          ],
        ),
      ),
      onTap: () {
        Platform.isIOS ? commonLaunchURL(strUrl) : commonLaunchUrlApp(strUrl);
      },
    );
  }

  //마케팅동의 다이얼로그
  void _showDialogAgree2(String smsYn) {
    bool bPush = false;
    bool bSms = false;
    if (_pushYn == 'Y') {
      bPush = true;
    } else {
      bPush = false;
    }
    if (smsYn == 'Y') bSms = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(25), //전체 margin 동작
              child: Container(
                width: double.infinity,
                // height: 250,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),

                child: SingleChildScrollView(
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
                      const Text(
                        '마케팅 동의 변경',
                        style: TStyle.defaultTitle,
                        textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      const Text(
                        RString.desc_marketing_agree,
                        style: TStyle.defaultContent,
                        textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      //SMS 수신동의
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SMS 수신동의',
                            style: TStyle.defaultContent,
                            textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  value: bSms,
                                  onChanged: (value) {
                                    setState(() {
                                      bSms = value!;
                                    });
                                  }),
                              const Text(
                                '동의',
                                textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                              ),
                            ],
                          ),
                        ],
                      ),
                      //PUSH 수신동의
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '앱푸시 수신동의',
                            style: TStyle.defaultContent,
                            textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  value: bPush,
                                  onChanged: (value) {
                                    setState(() {
                                      bPush = value!;
                                    });
                                  }),
                              const Text(
                                '동의',
                                textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Center(
                        child: MaterialButton(
                          child: Container(
                            width: 180,
                            height: 40,
                            decoration: UIStyle.roundBtnStBox(),
                            child: const Center(
                              child: Text(
                                '확인',
                                style: TStyle.btnTextWht16,
                                textScaler: TextScaler.linear(Const.TEXT_SCALE_FACTOR),
                              ),
                            ),
                          ),
                          onPressed: () {
                            saveMarketingAgree(bPush, bSms);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //마케팅동의 설정 저장
  void saveMarketingAgree(bool bPush, bool bSms) {
    DLog.d(MyPage.TAG, 'Agree $bPush | $bSms');

    String pushYn = 'N';
    if (bPush) pushYn = 'Y';
    String smsYn = 'N';
    if (bSms) smsYn = 'Y';

    _fetchPosts(
        TR.PUSH06,
        jsonEncode(<String, String>{
          'userId': _userId,
          'rcvAssentYn': pushYn,
        }));

    String type = 'set_sms';
    String param = 'userid=$_userId&etcData=tm_sms_f:$smsYn|daily:N|';
    _requestThink(type, param);
  }

  // 베이직일때
  Future<String> _showDialogPremium() async {
    if (context != null && context.mounted) {
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
                      '알림',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20
                    ),
                    const Text(
                      '계정을 업그레이드 하시고 매매비서를 더 완벽하게 이용해 보세요.',
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
                          '프리미엄계정 가입하기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landPremiumPage);
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
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

  // 3종목일때
  Future<String> _showDialogPremiumUpgrade() async {
    if (context != null && context.mounted) {
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
                      '알림',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      '추가 결제 없이 계정을 업그레이드 하시고 매매비서를 더 완벽하게 이용해 보세요.',
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
                          '프리미엄계정 업그레이드',
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

  // 프리미엄일때
  Future<String> _showDialogPremiumAlready() async {
    if (context != null && context.mounted) {
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
                      '알림',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      '매매비서를 완벽하게 이용해 보세요.',
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
                          '활용법 자세히 보기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landing);
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
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
          Platform.isIOS
              ? _navigateRefreshPay(context, const PayPremiumPage())
              : _navigateRefreshPay(context, const PayPremiumAosPage());
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

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    dynamic result = await Navigator.push(
      context,
      CustomNvRouteClass.createRoute(
        (instance),
      ),
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
          data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
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
                  const SizedBox(
                    height: 20,
                  ),
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

  void _adminEntrance(String sCode) {
    if (_adminCode == '') {
      commonShowToast('관리자코드가 없습니다.');
    } else if (_adminCode != sCode) {
      commonShowToast('입력된 코드가 틀립니다.');
    } else if (_adminCode == sCode) {
      _navigateRefreshPay(
        context,
        TestPage(),
      );
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(MyPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(MyPage.TAG, 'SocketException');
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  //비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
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
    } else if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        DLog.d(MyPage.TAG, data.accountData.toString());

        //NOTE : aos / ios 구분 해서 처리 ios 는 업그레이드 결제 없음
        if (data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatusAfterPayment();
          if (accountData.prodName == '프리미엄') {
            _strGrade = '프리미엄';
            _imgGrade = 'images/main_my_icon_menu_2.png';
            _stockCnt = '무제한';
            _pocketCnt = '10개';
            if(Platform.isAndroid) {
              //TODO 업그레이드 할 수 있는 결제인지 구분

            }
          }
          //3종목알림
          else if (accountData.prodCode == 'AC_S3') {
            _strGrade = '3종목 알림';
            _imgGrade = 'images/main_my_icon_menu_5.png';
            _stockCnt = '매일 5종목';
            _pocketCnt = '1개';
            _strUpgrade = '프리미엄 업그레이드';
            //NOTE : IOS 에서는 읽기모드
          }
          //베이직
          else {
            _strGrade = '베이직';
            _imgGrade = 'images/main_my_icon_menu_1.png';
            _stockCnt = '매일 5종목';
            _pocketCnt = '1개';
            _strUpgrade = '프리미엄 업그레이드';
            if (Platform.isAndroid) inAppBilling.requestPurchaseAsync();
          }
        } else {
          //회원정보 가져오지 못함
          _strGrade = '베이직';
          _imgGrade = 'images/main_my_icon_menu_1.png';
          _stockCnt = '매일 5종목';
          _pocketCnt = '1개';
          const AccountData().setFreeUserStatus();
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
    } else if (trStr == TR.APP02) {
      final TrApp02 resData = TrApp02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listServiceCenterMenu.clear();
        if (resData.listData.isNotEmpty) {
          _listServiceCenterMenu.addAll(resData.listData);
        }
        setState(() {});
      }

      _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
          }));
    }

    //푸시 설정 정보 조회
    else if (trStr == TR.PUSH04) {
      final TrPush04 resData = TrPush04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pushYn = resData.retData.rcvAssentYn;
        DLog.d(MyPage.TAG, '앱 푸시 수신동의 : $_pushYn');

        String type = 'get_sms';
        String strParam = "userid=$_userId";
        _requestThink(type, strParam);
      }
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

  // 씽크풀 API 호출
  void _requestThink(String type, String param) async {
    DLog.d(MyPage.TAG, 'marketing param : $param');

    String nUrl = '';
    if (type == 'get_sms') {
      nUrl = Net.THINK_INFO_MARKETING;
    } else if (type == 'set_sms') {
      nUrl = Net.THINK_EDIT_MARKETING;
    } else if (type == 'pay_complete') {
      nUrl = Net.THINK_CHECK_DAILY; //로그인/결제 휴면 방지
    }

    var url = Uri.parse(nUrl);
    final http.Response response = await http.post(
      url,
      headers: Net.think_headers,
      body: param,
    );

    // response ------------------------------------------------
    DLog.d(MyPage.TAG, '${response.statusCode}');
    DLog.d(MyPage.TAG, response.body);

    if (type == 'get_sms') {
      final String result = response.body;
      Map<String, dynamic> json = jsonDecode(result);
      String strSms = json['tm_sms_f'] ?? 'N';
      // _showDialogAgree(strSms);
      _showDialogAgree2(strSms);
    } else if (type == 'set_sms') {
      //마케팅 수신 저장 완료
    }
  }
}
