import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/custom_lib/http_process_class.dart';
import 'package:rassi_assist/custom_lib/tripledes/utils.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/user_join_info.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/agent/agent_no_link_sign_up_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intro_start_page.dart';

/// 2021.04.28
/// 회원가입 경로 선택
class JoinRoutePage extends StatefulWidget {
  //static const routeName = '/page_join_route';
  static const String TAG = "[JoinRoutePage]";
  static const String TAG_NAME = '회원가입_가입경로';
  final UserJoinInfo userJoinInfo;

  const JoinRoutePage({
    Key? key,
    required this.userJoinInfo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinRouteState();
}

class JoinRouteState extends State<JoinRoutePage> {
  final _scrollController = ScrollController();
  String deviceOsVer = '';

  String _reqType = '';
  String _reqParam = '';
  String _sJoinRoute = '';
  final String _noLinkAgent = 'NoLinkAgent'; // 24.04.29 에이전트 사업 - 일반 회원 가입 단계(링크 없음)에서 추천인 입력으로 회원가입

  String _smsCheck = 'N'; //SMS 수신 동의 체크
  String _emailCheck = 'N'; //이메일 수신 동의 체크
  bool _isAgreeMarketing = false; //마케팅 수신 동의 체크

  final List<RouteInfo> itemList = [
    Platform.isIOS
        ? RouteInfo(
            '애플 앱스토어 / 검색  ',
            '애플 앱스토어 검색',
            '인터넷 검색(네이버 블로그 등)',
            '',
            '',
            0,
            1,
            13,
            13,
            0,
          )
        : RouteInfo(
            '플레이스토어 / 검색  ',
            '플레이스토어 검색',
            '인터넷 검색(네이버 블로그 등)',
            '',
            '',
            0,
            1,
            13,
            13,
            0,
          ),
    RouteInfo(
      'HTS / MTS  ',
      '파이낸셜 뉴스 보도자료',
      '',
      '',
      '',
      2,
      13,
      13,
      13,
      1,
    ),
    RouteInfo(
      '방송 / 유튜브  ',
      'SBS특집 \'AI vs 인간\'',
      '유튜브 \'라씨 매매비서\'',
      '',
      '',
      3,
      4,
      13,
      13,
      2,
    ),
    RouteInfo(
      '씽크풀 / 라씨로  ',
      '씽크풀 웹 / 모바일',
      '라씨로 앱 / 라씨로 속보',
      '',
      '',
      5,
      6,
      13,
      13,
      3,
    ),
    RouteInfo(
      '광고 / 홍보  ',
      '구글 광고',
      '페이스북 광고',
      '',
      '',
      7,
      8,
      13,
      13,
      4,
    ),
    RouteInfo(
      '기타  ',
      '추천인',
      '기타',
      '',
      '',
      9,
      10,
      13,
      13,
      5,
    ),
  ];

  bool _isNetworkDo = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(JoinRoutePage.TAG_NAME);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Column(
              children: [
                _setHeaderTile(),
                Expanded(
                  child: Align(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: itemList.length,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      itemBuilder: (context, i) {
                        return _setDivTile(i, expandList[i]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _isNetworkDo,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.1),
              alignment: Alignment.center,
              child: Image.asset(
                'images/gif_ios_loading_large.gif',
                height: 20,
              ),
            ),
          ),
        ],
      ),

      // 하단 동의하고 시작합니다
      bottomNavigationBar: Visibility(
        visible: _sJoinRoute.isNotEmpty,
        child: Container(
          width: double.infinity,
          height: 80,
          color: RColor.bgWeakGrey,
          child: Container(
            width: double.infinity,
            height: 75,
            color: RColor.purpleBasic_6565ff,
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: const Center(
                child: Text(
                  '시작하기',
                  style: TStyle.btnTextWht16,
                ),
              ),
              onTap: () {
                _checkEditData();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _setHeaderTile() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        '라씨 매매비서를\n어떻게 만나시게 되셨나요?',
        //textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

/*  Widget _setFooterTile() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(
          top: 15,
        ),
        width: double.infinity,
        height: 56,
        decoration: statList[10] ? UIStyle.boxBtnSelected() : UIStyle.boxRoundLine6(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '기타',
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.bold, color: statList[10] ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
      onTap: () {
        _setSelectExpand(5);
        _setSelectStatus(10);
        _goBottomPage();
      },
    );
  }*/

  //리스트 item 하나
  Widget _setDivTile(int idx, bool expStat) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
      ),
      width: double.infinity,
      decoration: expStat ? UIStyle.boxSelectedLine12() : UIStyle.boxRoundLine6(),
      child: _setExpansionTile(idx),
    );
  }

  //확장 리스트 item
  Widget _setExpansionTile(
    int idx,
  ) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        //타이틀 Center 정렬을 위한 아이콘
        leading: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.transparent,
        ),
        collapsedIconColor: RColor.greyBoxLine_c9c9c9,
        // collapsedIconColor: Colors.amber,
        iconColor: RColor.greyBoxLine_c9c9c9,
        //타이틀
        title: Center(
          child: Text(
            itemList[idx].subItemTitle,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        onExpansionChanged: (expanded) {
          if (idx == 3 && expanded) _goBottomPage();
          if (idx == 4 && expanded) _goBottomPage();
        },

        //하위 메뉴
        children: itemList[idx].secondStatus == itemList[idx].firstStatus + 1
            ? _setSubItem2(
                idx,
                statList[itemList[idx].firstStatus],
                statList[itemList[idx].secondStatus],
              )
            : [
                _setSubItem1(
                  idx,
                  statList[itemList[idx].firstStatus],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
      ),
    );
  }

  Widget _setSubItem1(int idx, bool firstStat) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _setSelectExpand(itemList[idx].expandStatus);
          _setSelectStatus(itemList[idx].firstStatus);
        },
        child: Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: firstStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
          child: Center(
            child: Text(
              itemList[idx].firstContent,
              style: firstStat ? TStyle.btnTextWht16 : TStyle.content16,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _setSubItem2(int idx, bool firstStat, bool secondStat) {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            _setSelectExpand(itemList[idx].expandStatus);
            _setSelectStatus(itemList[idx].firstStatus);
          },
          child: Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            decoration: firstStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
            child: Center(
              child: Text(
                itemList[idx].firstContent,
                style: firstStat ? TStyle.btnTextWht16 : TStyle.content16,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            _setSelectExpand(itemList[idx].expandStatus);
            _setSelectStatus(itemList[idx].secondStatus);
          },
          child: Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            decoration: secondStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
            child: Center(
              child: Text(
                itemList[idx].secondContent,
                style: secondStat ? TStyle.btnTextWht16 : TStyle.content16,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  List<Widget> _setSubItem4(int idx, bool firstStat, bool secondStat, bool thirdStat, bool fourthStat) {
    return [
      InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: firstStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
          child: Center(
            child: Text(
              itemList[idx].firstContent,
              style: firstStat ? TStyle.btnTextWht16 : TStyle.content16,
            ),
          ),
        ),
        onTap: () {
          _setSelectExpand(itemList[idx].expandStatus);
          _setSelectStatus(itemList[idx].firstStatus);
        },
      ),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: secondStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
          child: Center(
            child: Text(
              itemList[idx].secondContent,
              style: secondStat ? TStyle.btnTextWht16 : TStyle.content16,
            ),
          ),
        ),
        onTap: () {
          _setSelectExpand(itemList[idx].expandStatus);
          _setSelectStatus(itemList[idx].secondStatus);
        },
      ),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: thirdStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
          child: Center(
            child: Text(
              itemList[idx].thirdContent,
              style: thirdStat ? TStyle.btnTextWht16 : TStyle.content16,
            ),
          ),
        ),
        onTap: () {
          _setSelectExpand(itemList[idx].expandStatus);
          _setSelectStatus(itemList[idx].thirdStatus);
        },
      ),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: fourthStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
          child: Center(
            child: Text(
              itemList[idx].fourthContent,
              style: fourthStat ? TStyle.btnTextWht16 : TStyle.content16,
            ),
          ),
        ),
        onTap: () {
          _setSelectExpand(itemList[idx].expandStatus);
          _setSelectStatus(itemList[idx].fourthStatus);
        },
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  //항목 하나 추가해서 선택되지 않은 항목으로 사용 (13번째 항목)
  final List<bool> statList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  void _setSelectStatus(int idx) {
    for (var i = 0; i < statList.length; i++) {
      if (i == idx) {
        statList[i] = true;
      } else {
        statList[i] = false;
      }
    }
    _setRouteValue(idx);
    setState(() {});
  }

  void _setRouteValue(int idx) {
    if (idx == 0) {
      _sJoinRoute = 'OLLAAS'; //앱스토어 검색
    } else if (idx == 1) {
      _sJoinRoute = 'OLLASH'; //인터넷 검색
    } else if (idx == 2) {
      _sJoinRoute = 'OLLAF'; //파이낸셜
    } else if (idx == 3) {
      _sJoinRoute = 'OLLASBS'; //AI 대 인간
    } else if (idx == 4) {
      _sJoinRoute = 'OLLASBS'; //유튜브 라씨 매매비서
    } else if (idx == 5) {
      _sJoinRoute = 'OLLATH'; //씽크풀
    } else if (idx == 6) {
      _sJoinRoute = 'OLLARSRO'; //라씨로
    } else if (idx == 7) {
      _sJoinRoute = 'OLLAAD'; //구글 광고
    } else if (idx == 8) {
      _sJoinRoute = 'OLLAAD'; //페이스북 광고
    } else if (idx == 9) {
      _sJoinRoute = _noLinkAgent; // 추천인 - 에이전트
    } else if (idx == 10) {
      _sJoinRoute = 'OLLAETC'; // 기타
    } else {
      _sJoinRoute = 'OLLAETC';
    }
  }

  //항목의 collapse 선택 상태
  final List<bool> expandList = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  void _setSelectExpand(int idx) {
    for (var i = 0; i < expandList.length; i++) {
      if (i == idx) {
        expandList[i] = true;
      } else {
        expandList[i] = false;
      }
    }
  }

  //회원가입 입력값 체크
  void _checkEditData() {
    if (_sJoinRoute.isEmpty) {
      CommonPopup.instance.showDialogBasicConfirm(context, '알림', '가입하시게 된 경로를 선택해 주세요.');
    } else if (_sJoinRoute == _noLinkAgent) {
      Navigator.pushNamed(context, AgentNoLinkSignUpPage.routeName, arguments: widget.userJoinInfo);
    } else {
      //체크완료
      if (_isAgreeMarketing) {
        _smsCheck = 'Y';
      } else {
        _smsCheck = 'N';
      }
      DLog.d(JoinRoutePage.TAG, '마케팅 수신동의 : $_isAgreeMarketing');
      DLog.d(JoinRoutePage.TAG, '### JoinRoute : $_sJoinRoute');
      DLog.d(JoinRoutePage.TAG, 'widget.userJoinInfo.toString() : ${widget.userJoinInfo.toString()}');

      //라씨 회원가입
      if (widget.userJoinInfo.pgType == 'RASSI') {
        widget.userJoinInfo.userId = widget.userJoinInfo.userId.toLowerCase();
        _reqType = 'join_confirm';
        _reqParam =
            'userid=${Net.getEncrypt(widget.userJoinInfo.userId.toLowerCase())}&passWd=${Net.getEncrypt(widget.userJoinInfo.email.trim())}&hp=${Net.getEncrypt(widget.userJoinInfo.phone.trim())}&username=&sex_gubun=&joinRoute=$_sJoinRoute&daily=$_emailCheck&tm_sms_f=$_smsCheck';
        _requestThink();
      }
      //쓱가입
      else if (widget.userJoinInfo.pgType == 'SSGOLLA') {
        DLog.d('SsgJoinPage.TAG', '씽크풀 가입안됨 ' + "SSGOLLA" + utilsGetDeviceHpID(widget.userJoinInfo.phone));
        _reqType = 'join_sns';
        _reqParam =
            "snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(widget.userJoinInfo.phone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(widget.userJoinInfo.phone)}&kt_provide_flag=N&hpEncFlag=Y";
        _requestThink();
      }
      //네이버/카카오/애플
      else {
        if (widget.userJoinInfo.userId.isNotEmpty) {
          _reqType = 'join_sns';
          _reqParam =
              "snsId=${Net.getEncrypt(widget.userJoinInfo.userId)}&snsPos=${widget.userJoinInfo.pgType}&nick=&userName=${widget.userJoinInfo.name}&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SM&email=${widget.userJoinInfo.email}&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N";
          _requestThink();
        }
      }
    }
  }

  void _goBottomPage() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  // 다음 페이지로 이동
  Future<void> _goNextRoute() async {
    CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (widget.userJoinInfo.pgType) {
      case 'SSGOLLA':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.ssg.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.ssg.name);
          break;
        }
      case 'KAKAO':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.kakao.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.kakao.name);
          break;
        }
      case 'NAVER':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.naver.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.naver.name);
          break;
        }
      case 'APPLE':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.apple.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.apple.name);
          break;
        }
      case 'GOOGLE':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.google.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.google.name);
          break;
        }
      case 'RASSI':
        {
          await CustomFirebaseClass.logEvtLogin(LoginPlatform.rassi.name);
          await CustomFirebaseClass.logEvtSignUp(LoginPlatform.rassi.name);
          break;
        }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String prefsUserId = prefs.getString(Const.PREFS_USER_ID) ?? '';
    String globalUserId = AppGlobal().userId;

    if (prefsUserId.isEmpty) {
      if (globalUserId.isEmpty) {
        if (mounted) {
          await CommonPopup.instance.showDialogBasicConfirm(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, IntroStartPage.routeName, (route) => false);
          }
        }
      } else {
        await prefs.setString(Const.PREFS_USER_ID, globalUserId);
      }
    }

    if (globalUserId.isEmpty) {
      AppGlobal().userId = prefsUserId;
    }

    basePageState = BasePageState();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const BasePage(), settings: const RouteSettings(name: BasePage.routeName)),
        (route) => false,
      );
    }
  }

  // 씽크풀 API 호출
  void _requestThink() async {
    DLog.d(JoinRoutePage.TAG, '씽크풀 API 호출');
    DLog.d(JoinRoutePage.TAG, 'Think Req Type : $_reqType');
    DLog.d(JoinRoutePage.TAG, 'Think Req Param : $_reqParam');

    String url = '';
    if (_reqType == 'join_sns') {
      //회원가입(SNS)
      url = Net.THINK_SNS_JOIN;
    } else if (_reqType == 'join_confirm') {
      //회원가입
      url = Net.THINK_JOIN;
    }
    if (_isNetworkDo) {
      return;
    } else {
      setState(() => _isNetworkDo = true);
    }
    var urls = Uri.parse(url);
    final http.Response response = await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(JoinRoutePage.TAG, '${response.statusCode}');
    DLog.d(JoinRoutePage.TAG, response.body);

    final String result = response.body;

    if (_reqType == 'join_sns') {
      //SNS 회원가입
      if (result.isNotEmpty) {
        final ThinkLoginSns resData = ThinkLoginSns.fromJson(jsonDecode(result));
        if (resData.resultCode.toString().trim() == '0') {
          commonShowToast("회원가입에 실패했습니다");
        } else {
          DLog.d(JoinRoutePage.TAG, "USER ID : ${resData.userId}");
          DLog.d(JoinRoutePage.TAG, "NICK : ${resData.nickName}");
          widget.userJoinInfo.userId = resData.userId;
          await HttpProcessClass()
              .callHttpProcess0002(
            vUserId: widget.userJoinInfo.userId,
            vAgentCode: '',
          )
              .then((value) async {
            switch (value.appResultCode) {
              case 200:
                {
                  await _goNextRoute();
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
      setState(() => _isNetworkDo = false);
    } else if (_reqType == 'join_confirm') {
      //라씨 회원가입
      if (result != 'ERR' && result.isNotEmpty) {
        HttpProcessClass()
            .callHttpProcess0002(
          vUserId: widget.userJoinInfo.userId,
          vAgentCode: '',
        )
            .then((value) {
          DLog.d(JoinRoutePage.TAG, 'then() value : $value');
          switch (value.appResultCode) {
            case 200:
              {
                _goNextRoute();
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
      } else {
        //씽크풀 회원가입 실패
        if (mounted) {
          if (result == 'PWERR') {
            CommonPopup.instance.showDialogBasicConfirm(context, '알림', '안전한 비밀번호로 다시 설정해 주세요.');
          } else {
            CommonPopup.instance
                .showDialogBasicConfirm(context, '알림', '회원 가입에 실패하였습니다. 고객센터로 문의해주세요.')
                .then((value) => Navigator.pop(context));
          }
        }
      }
      setState(() => _isNetworkDo = false);
    }
  }
}

class RouteInfo {
  final String subItemTitle;
  final String firstContent;
  final String secondContent;
  final String thirdContent;
  final String fourthContent;
  final int firstStatus;
  final int secondStatus;
  final int thirdStatus;
  final int fourthStatus;
  final int expandStatus;

  RouteInfo(this.subItemTitle, this.firstContent, this.secondContent, this.thirdContent, this.fourthContent,
      this.firstStatus, this.secondStatus, this.thirdStatus, this.fourthStatus, this.expandStatus);
}
