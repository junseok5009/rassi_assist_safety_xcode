import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_notice01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:rassi_assist/models/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pay/pay_history_page.dart';
import 'package:rassi_assist/ui/pay/pay_manage_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/pocket/pocket_list_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_setting_page.dart';
import 'package:rassi_assist/ui/test/test_page.dart';
import 'package:rassi_assist/ui/user/terms_page.dart';
import 'package:rassi_assist/ui/user/user_center_page.dart';
import 'package:rassi_assist/ui/user/user_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../../common/custom_nv_route_class.dart';
import '../../models/tr_app02.dart';
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
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final String _appEnv =
      Platform.isIOS ? "EN20" : "EN10"; // android: EN10, ios: EN20
  var appGlobal = AppGlobal();
  var inAppBilling;

  late SharedPreferences _prefs;
  String _userId = '';
  String _adminCode = '00700070';
  String _getToken = '';
  String _preToken = '';
  String _todayString = '0000';
  String _dayCheckPush = '';

  String _strGrade = '베이직\n계정';
  String _imgGrade = 'images/main_my_icon_menu_1.png';
  String _pushYn = ''; //PUSH 수신동의

  String _usedPktCnt = '1';
  String _availPktCnt = '1';
  var _loadPktCnt = 1;

  List<Pock03> _listPocket = [];
  List<Notice01> _listNotice = [];

  bool _bPayFinished =
      true; //결제 시도를 하지 않은 상태(결제 완료, 결과가 에러, 결제 시도를 안한 상태 : true)

  bool prTOP = false, prHGH = false, prMID = false, prLOW = false;
  final List<Prom02> _listPrTop = [];
  final List<Prom02> _listPrHgh = [];
  final List<Prom02> _listPrMid = [];
  final List<Prom02> _listPrLow = [];

  final List<App02> _listServiceCenterMenu = [];

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      MyPage.TAG_NAME,
    );
    _setTestPageData();
    appGlobal.pocketCnt > 3
        ? _loadPktCnt = 3
        : _loadPktCnt = appGlobal.pocketCnt;
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

  //저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _getToken = (await FirebaseMessaging.instance.getToken()) ?? '';
    _prefs = await SharedPreferences.getInstance();
    _todayString = TStyle.getTodayString();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _preToken = _prefs.getString(Const.PREFS_SAVED_TOKEN) ?? '';
    _dayCheckPush = _prefs.getString(Const.PREFS_DAY_CHECK_MY) ?? '';
    _bPayFinished = _prefs.getBool(Const.PREFS_PAY_FINISHED) ?? true;
    appGlobal.userId = _userId;

    Platform.isIOS
        ? inAppBilling = PaymentService()
        : inAppBilling = PaymentAosService();
  }

  //firebase 원격설정을 이용한 관리자 페이지 코드
  _setTestPageData() async {
    if (Const.isDebuggable) {
      try {
        bool updated = await _remoteConfig.fetchAndActivate();
        if (updated) {
          String pCode = _remoteConfig.getString('ios_test_page_password');
          if (pCode != null && pCode.length > 0) _adminCode = pCode;
          DLog.d(MyPage.TAG, '### Remote Config String : $_adminCode');
        } else {
          DLog.d(MyPage.TAG, '### Remote Config Not updated');
        }
      } on PlatformException catch (exception) {
        // DLog.d(MyPage.TAG, exception.message);
      } catch (exception) {
        // DLog.d(MyPage.TAG, exception);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.none(Colors.white,),
      backgroundColor: RColor.bgMyPage,
      body: SafeArea(
        child: ListView(
          children: [
            _setUserInfo(),
            _setPrTop(),

            //나의 종목 포켓
            _setPocketBar(),
            const SizedBox(
              height: 5.0,
            ),
            _setMyPocketList(),
            const SizedBox(
              height: 5.0,
            ),
            _setPocketAll(),
            const SizedBox(
              height: 15.0,
            ),

            //결제 연결 배너
            _setPayBanner(),
            //상단 프로모션
            _setPrHigh(),
            const SizedBox(
              height: 10.0,
            ),

            _setSubTitle("라씨 매매비서,\n알고 쓰면 더 유용한 나의 비서"),
            _setNoticeList(context),
            const SizedBox(
              height: 20.0,
            ),
            _setPrMid(),

            _setSubTitle("나의 정보 관리"),
            const SizedBox(
              height: 10.0,
            ),
            _setInfoDiv(),
            const SizedBox(
              height: 15.0,
            ),

            _setSubTitle("고객센터"),
            const SizedBox(
              height: 3.0,
            ),

            /* _setBoxBtnUrl('자주 묻는 질문', Net.URL_FREQ_QA),
            _setBoxBtn('1대1 문의', UserCenterPage.routeName),
            _setBoxBtnUrl('네이버 톡톡 상담', Net.URL_NAVER_QA),
            _setBoxBtn('회원약관과 개인정보 처리방침', TermsPage.routeName),
            _setBoxBtn('라씨 매매비서 AI엔진 히스토리', AiVersionPage.routeName),*/

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
                  // _navigateRefreshPay(context, TestPage(),);
                  _showDialogAdmin();
                  // _navigateRefreshPay(context, TestPage(), PgData()); //TODO  임시코드
                },
              ),
            ),

            const SizedBox(
              height: 5.0,
            ),
            _setPrLow(),
            const SizedBox(
              height: 25.0,
            ),
            _setCopyright(),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }

  //상단 유저 정보
  Widget _setUserInfo() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //상단 좌측 아이콘 영역
              _setUserIcon(),
              //상단 우측 회원 계정 정보
              _setUserStatView(),
            ],
          ),
        ),

        //상단 라인
        Container(
          color: Colors.grey,
          width: double.infinity,
          height: 0.5,
        ),
      ],
    );
  }

  //상단 좌측 유저 아이콘
  Widget _setUserIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20.0,
        ),
        Image.asset(
          'images/main_my_img_ar_line.png',
          scale: 2.7,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Image.asset(
          'images/main_my_img_ar_line_text.png',
          scale: 3,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  //상단 우측 유저 정보
  Widget _setUserStatView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40.0,
            ),
            Image.asset(
              _imgGrade,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              _strGrade,
              style: TStyle.textSGrey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(
          width: 7.0,
        ),
      ],
    );
  }

  //포켓 정보 Bar
  Widget _setPocketBar() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        direction: Axis.horizontal,
        runSpacing: 10,
        children: [
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  '나의 종목 포켓',
                  style: TStyle.defaultTitle,
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text(
                  '사용',
                  style: TStyle.commonSTitle,
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  _usedPktCnt,
                  style: TStyle.ulTextPurple,
                ),
                const Text(
                  ' / 가능',
                  style: TStyle.commonSTitle,
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  _availPktCnt,
                  style: TStyle.ulTextPurple,
                ),
              ],
            ),
          ),

          //우측 버튼부
          FittedBox(
            child: Row(
              children: [
                InkWell(
                  child: Row(
                    children: [
                      Image.asset(
                        'images/rassibs_pk_icon_ae_g2.png',
                        fit: BoxFit.cover,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Text('추가'),
                    ],
                  ),
                  onTap: () {
                    if (appGlobal.isPremium) {
                      //포켓을 추가하는 팝업
                      _showPocketAdd();
                    } else {
                      _showDialogPremium();
                    }
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  child: Row(
                    children: [
                      Image.asset(
                        'images/rassibs_pk_icon_ae_g1.png',
                        fit: BoxFit.cover,
                        height: 18,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Text('설정'),
                    ],
                  ),
                  onTap: () {
                    //포켓 설정
                    _navigateRefresh(context, PocketSettingPage.routeName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //유저 포켓 리스트
  Widget _setMyPocketList() {
    if (_isLoading && Const.isSkeletonLoader) {
      return _setPocketLoading();
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: _listPocket.length,
        itemBuilder: (context, index) {
          return _tilePocketList(_listPocket[index]);
        },
      );
    }
  }

  Widget _tilePocketList(Pock03 item) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6bgColor(
        Colors.white,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 47,
                ),
                Chip(
                  label: Text(item.pocketName),
                  backgroundColor: RColor.yonbora,
                ),
                IconButton(
                    icon: const ImageIcon(
                      AssetImage(
                        'images/rassibs_pk_icon_plu.png',
                      ),
                    ),
                    color: Colors.grey,
                    onPressed: () {
                      _navigateSearchData(
                          context,
                          const SearchPage(),
                          PgData(
                            pgSn: item.pocketSn,
                          ));
                    }),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '관심종목 ',
                        style: TStyle.content15,
                      ),
                      Text(
                        item.waitCount,
                        style: TStyle.title19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 0.5,
                  child: Container(
                    width: 0.7,
                    height: 22,
                    color: RColor.lineGrey,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '보유종목 ',
                        style: TStyle.content15,
                      ),
                      Text(
                        item.holdCount,
                        style: TStyle.title19,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        onTap: () {
          _navigateSearchData(
              context,
              const PocketPage(),
              PgData(
                pgSn: item.pocketSn,
              )); //TODO callUp 필요없음
        },
      ),
    );
  }

  Widget _setPocketLoading() {
    return SkeletonLoader(
      items: _loadPktCnt,
      period: const Duration(seconds: 2),
      highlightColor: Colors.grey[100]!,
      direction: SkeletonDirection.ltr,
      builder: Container(
        margin: const EdgeInsets.all(10),
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
        alignment: Alignment.centerLeft,
        decoration: UIStyle.boxRoundLine(),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 75,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: RColor.lineGrey,
                      width: 0.8,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 30,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 30,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //포켓 모두보기 버튼
  Widget _setPocketAll() {
    return Visibility(
      visible: true,
      child: Column(
        children: [
          MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.0),
                side: const BorderSide(color: RColor.mainColor)),
            color: Colors.white,
            textColor: RColor.mainColor,
            // elevation: 0.0,
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "나의포켓",
                    style: TStyle.puplePlain17(),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  const Text(
                    "모두보기",
                    style: TStyle.defaultTitle,
                  ),
                ],
              ),
            ),
            onPressed: () {
              _navigateRefresh(context, PocketListPage.routeName);
            },
          ),
        ],
      ),
    );
  }

  //포켓 종목추가 버튼
  Widget _setPocketAddStock(String pktSn) {
    return Column(
      children: [
        MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17.0),
              side: const BorderSide(color: RColor.mainColor)),
          color: Colors.white,
          textColor: RColor.mainColor,
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "+종목추가",
                  style: TStyle.puplePlainStyle(),
                ),
              ],
            ),
          ),
          onPressed: () {
            //종목 검색 페이지로 이동
            basePageState.callPageRouteUpData(
                const SearchPage(), PgData(pgSn: pktSn));
          },
        ),
      ],
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
  Widget _setSubTitle(
    String subTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.title17,
      ),
    );
  }

  //나의 결제 관리
  Widget _setPayDiv() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //결제 내역
        MaterialButton(
          child: Column(
            children: [
              Image.asset(
                'images/main_my_icon_m_menu_2.png',
                height: 45,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 7,
              ),
              const Text('결제 내역'),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, PayHistoryPage.routeName);
          },
        ),
        // const SizedBox(width: 30.0,),

        //정기결제
        MaterialButton(
          child: Column(
            children: [
              Image.asset(
                'images/main_my_icon_m_menu_3.png',
                height: 45,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 7,
              ),
              const Text('정기결제'),
            ],
          ),
          onPressed: () {
            // Navigator.pushNamed(context, SubsManagePage.routeName);
          },
        ),
        const SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  //나의 정보 관리
  Widget _setInfoDiv() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 15,
      children: [
        InkWell(
          child: Column(
            children: [
              Image.asset(
                'images/main_my_icon_b_menu_1.png',
                height: 45,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 7,
              ),
              const Text('회원정보'),
            ],
          ),
          onTap: () {
            basePageState.callPageRouteUP(UserInfoPage());
          },
        ),

        //마케팅 동의
        InkWell(
          child: Column(
            children: [
              Image.asset(
                'images/main_my_icon_b_menu_2.png',
                height: 45,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 7,
              ),
              const Text('마케팅 동의'),
            ],
          ),
          onTap: () {
            _fetchPosts(
                TR.PUSH04,
                jsonEncode(<String, String>{
                  'userId': _userId,
                }));
          },
        ),

        InkWell(
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Image.asset(
                'images/main_my_icon_m_menu_2.png',
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 11,
              ),
              const Text('결제 내역'),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, PayHistoryPage.routeName);
          },
        ),

        //정기결제
        InkWell(
          child: Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              Image.asset(
                'images/main_my_icon_m_menu_3.png',
                height: 37,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 9,
              ),
              const Text('정기결제'),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, PayManagePage.routeName);
          },
        ),
      ],
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
              } else if (item.linkPage ==
                  LD.main_my_service_center_user_private) {
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
        decoration: UIStyle.boxRoundLine6bgColor(Colors.white,),
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

  //Custom Button
  Widget _setBoxBtnUp(String title, Widget instance) {
    return Container(
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
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
          ],
        ),
        onTap: () {
          basePageState.callPageRouteUP(instance);
        },
      ),
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
        decoration: UIStyle.boxRoundLine6bgColor(Colors.white,),
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

  //포켓 추가 다이얼로그
  void _showPocketAdd() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
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
                  '알림',
                  style: TStyle.commonTitle,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '종목 포켓을 추가로 만드시겠어요?',
                  style: TStyle.commonTitle,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  '생성 후에는 설정을 통해 포켓 이름을 변경하실 수 있습니다.', //노출 순서 변경과\n종목
                  style: TStyle.contentMGrey,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '만들기',
                          style: TStyle.btnTextWht16,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    requestGenPocket();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //마케팅동의 다이얼로그
  void _showDialogAgree(String smsYn) {
    bool bPush = false;
    bool bSms = false;
    if (_pushYn == 'Y')
      bPush = true;
    else
      bPush = false;
    if (smsYn == 'Y') bSms = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
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
                      style: TStyle.commonTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Text(
                      RString.desc_marketing_agree,
                      style: TStyle.contentMGrey,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    //SMS 수신동의
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SMS 수신동의',
                            textScaleFactor: Const.TEXT_SCALE_FACTOR),
                        Row(
                          children: [
                            Checkbox(
                                value: bSms,
                                onChanged: (value) {
                                  setState(() {
                                    bSms = value!;
                                  });
                                }),
                            const Text('동의',
                                textScaleFactor: Const.TEXT_SCALE_FACTOR),
                          ],
                        ),
                      ],
                    ),
                    //PUSH 수신동의
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('앱푸시 수신동의',
                            textScaleFactor: Const.TEXT_SCALE_FACTOR),
                        Row(
                          children: [
                            Checkbox(
                                value: bPush,
                                onChanged: (value) {
                                  setState(() {
                                    bPush = value!;
                                  });
                                }),
                            const Text('동의',
                                textScaleFactor: Const.TEXT_SCALE_FACTOR),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    MaterialButton(
                      child: Center(
                        child: Container(
                          width: 180,
                          height: 40,
                          decoration: UIStyle.roundBtnStBox(),
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
                        saveMarketingAgree(bPush, bSms);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      const Text(
                        RString.desc_marketing_agree,
                        style: TStyle.defaultContent,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      //SMS 수신동의
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('SMS 수신동의',
                              style: TStyle.defaultContent,
                              textScaleFactor: Const.TEXT_SCALE_FACTOR),
                          Row(
                            children: [
                              Checkbox(
                                  value: bSms,
                                  onChanged: (value) {
                                    setState(() {
                                      bSms = value!;
                                    });
                                  }),
                              const Text('동의',
                                  textScaleFactor: Const.TEXT_SCALE_FACTOR),
                            ],
                          ),
                        ],
                      ),
                      //PUSH 수신동의
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('앱푸시 수신동의',
                              style: TStyle.defaultContent,
                              textScaleFactor: Const.TEXT_SCALE_FACTOR),
                          Row(
                            children: [
                              Checkbox(
                                  value: bPush,
                                  onChanged: (value) {
                                    setState(() {
                                      bPush = value!;
                                    });
                                  }),
                              const Text('동의',
                                  textScaleFactor: Const.TEXT_SCALE_FACTOR),
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
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
    String param =
        'userid=$_userId&etcData=tm_sms_f:$smsYn|daily:N|';
    _requestThink(type, param);
  }

  //프리미엄 소개 다이얼로그
  void _showDialogPremium() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                Image.asset(
                  'images/rassibs_img_infomation.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '종목 포켓을 추가로 만드시겠어요?',
                  style: TStyle.commonTitle,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                const Text(
                  RString.desc_add_pocket_premium,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  style: TStyle.contentMGrey,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '프리미엄 가입하기',
                          style: TStyle.btnTextWht16,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateRefreshPay(
                      context,
                      Platform.isIOS
                          ? const PayPremiumPage()
                          : PayPremiumAosPage(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
              ? _navigateRefreshPay(
                  context,
                  PayPremiumPage(),
                )
              : _navigateRefreshPay(
                  context,
                  PayPremiumAosPage(),
                );
        },
      ),
    );
  }

  //프로모션 - 최상단
  Widget _setPrTop() {
    return Visibility(
      visible: prTOP,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrTop)),
    );
  }

  //프로모션 - 상단
  Widget _setPrHigh() {
    return Visibility(
      visible: prHGH,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrHgh)),
    );
  }

  //프로모션 - 중간
  Widget _setPrMid() {
    return Visibility(
      visible: prMID,
      child: SizedBox(
          width: double.infinity, height: 110, child: CardProm02(_listPrMid)),
    );
  }

  //프로모션 - 하단
  Widget _setPrLow() {
    return Visibility(
      visible: prLOW,
      child: SizedBox(
          width: double.infinity, height: 180, child: CardProm02(_listPrLow)),
    );
  }

  _navigateRefresh(BuildContext context, String routeName) async {
    final result = await Navigator.pushNamed(context, routeName);
    if (result == 'cancel') {
      DLog.d(MyPage.TAG, '*** ***');
    } else {
      DLog.d(MyPage.TAG, '*** navigateRefresh');

      _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
          }));
    }
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

  _navigateSearchData(
      BuildContext context, Widget instance, PgData pgData) async {
    DLog.e('_navigateSearchData!!!');
    final result = await Navigator.push(
      context,
      CustomNvRouteClass.createRouteData(
        instance,
        RouteSettings(
          arguments: pgData,
        ),
      ),
    );
    DLog.e('_navigateSearchData!!! result : ${result}');
    if (result == 'cancel') {
      DLog.d(MyPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(MyPage.TAG, '*** navigateRefresh');
      _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
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

        if(_getToken != null) {
          if (_preToken != _getToken) {
            DLog.d(MyPage.TAG, '푸시 재등록 PUSH01');
            _fetchPosts(
                TR.PUSH01,
                jsonEncode(<String, String>{
                  'userId': _userId,
                  'appEnv': _appEnv,
                  'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                  'pushToken': _getToken!,
                }));
          }
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
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
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
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      String sCode = codeController.text.trim();
                      if (sCode.length == 0) {
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

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
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
      DLog.d(MyPage.TAG, 'TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(MyPage.TAG, 'SocketException');
      _showDialogNetErr();
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
        User04? data = resData.retData;
        if(data != null) {
          DLog.d(MyPage.TAG, data.accountData.toString());

          if (data.accountData != null) {
            final AccountData? accountData = data.accountData;
            accountData?.initUserStatusAfterPayment();
            if (accountData?.prodName == '프리미엄') {
              _strGrade = '프리미엄\n계정';
              _imgGrade = 'images/main_my_icon_menu_2.png';
              _availPktCnt = '20';
            } else if (accountData?.prodCode == 'AC_S3') {
              //TODO 3종목 알림일 경우 프리미엄 배너 노출 여부 확인
              _strGrade = '3종목\n알림';
              _imgGrade = 'images/main_my_icon_menu_5.png';
            } else {
              //베이직 계정
              _strGrade = '베이직\n계정';
              _imgGrade = 'images/main_my_icon_menu_1.png';
              if (Platform.isAndroid) inAppBilling.requestPurchaseAsync();
            }
          } else {
            //회원정보 가져오지 못함
            _strGrade = '베이직\n계정';
            _imgGrade = 'images/main_my_icon_menu_1.png';
            AccountData().setFreeUserStatus();
          }
          setState(() {});
        }
      } else {
        AccountData().setFreeUserStatus();
      }

      _fetchPosts(
          TR.PROM02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'viewPage': 'LPE1',
            'promoDiv': '',
          }));
    }
    //
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
          if (_listPrTop.length > 0) prTOP = true;
          if (_listPrHgh.length > 0) prHGH = true;
          if (_listPrMid.length > 0) prMID = true;
          if (_listPrLow.length > 0) prLOW = true;
        });
      }

      _fetchPosts(
          TR.APP02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
          }));
    }
    //
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
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectCount': '10',
          }));
    }

    //포켓 리스트
    else if (trStr == TR.POCK03) {
      //포켓 리스트
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listPocket.clear();
        if (resData.listData != null) {
          _usedPktCnt = resData.listData.length.toString();

          if (resData.listData.length > 3) {
            _listPocket = resData.listData.sublist(0, 3);
          } else {
            _listPocket = resData.listData;
          }
        }

        _isLoading = false;
        setState(() {});
      }

      _checkPushToken();

      //결제가 미완결 상태일 경우
      if (!_bPayFinished) inAppBilling.getPurchaseHistory();
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

    //포켓 생성 등록
    else if (trStr == TR.POCK01) {
      final TrPock01 resData = TrPock01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        commonShowToast('포켓이 생성되었습니다.');

        _fetchPosts(
            TR.POCK03,
            jsonEncode(<String, String>{
              'userId': _userId,
              'selectCount': '10',
            }));
      } else if (resData.retCode == '8007') {
        commonShowToast('생성 가능한 포켓 갯수를 초과했습니다.');
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
    if (type == 'get_sms')
      nUrl = Net.THINK_INFO_MARKETING;
    else if (type == 'set_sms')
      nUrl = Net.THINK_EDIT_MARKETING;
    else if (type == 'pay_complete')
      nUrl = Net.THINK_CHECK_DAILY; //로그인/결제 휴면 방지

    var url = Uri.parse(nUrl);
    final http.Response response =
        await http.post(url, headers: Net.think_headers, body: param);

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
