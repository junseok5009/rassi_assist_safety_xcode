import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intro_start_page.dart';

/// 2021.04.28
/// 회원가입 경로 선택
class JoinRoutePage extends StatefulWidget {
  static const routeName = '/page_join_route';
  static const String TAG = "[JoinRoutePage]";
  static const String TAG_NAME = '회원가입_가입경로';
  final UserJoinInfo userJoinInfo;

  const JoinRoutePage(
    this.userJoinInfo, {
    Key? key,
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
  ];

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Column(
          children: [
            _setHeaderTile(),
            Expanded(
              child: Align(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: itemList.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 5) {
                      return _setFooterTile();
                    } else {
                      int idx = i;
                      return _setDivTile(idx, expandList[idx]);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 동의하고 시작합니다
      bottomNavigationBar: Visibility(
        visible: _sJoinRoute.isNotEmpty,
        child: Container(
          width: double.infinity,
          height: 75,
          color: RColor.bgWeakGrey,
          child: Container(
            width: double.infinity,
            height: 75,
            color: RColor.purpleBasic_6565ff,
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: InkWell(
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
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _setFooterTile() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(
          top: 15,
        ),
        width: double.infinity,
        height: 56,
        decoration: statList[10]
            ? UIStyle.boxRoundLine8LineColor(RColor.purpleBasic_6565ff)
            : UIStyle.boxRoundLine8LineColor(
                RColor.greyBoxLine_c9c9c9,
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '기타',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color:
                      statList[10] ? RColor.purpleBasic_6565ff : Colors.black),
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
  }

  //리스트 item 하나
  Widget _setDivTile(int idx, bool expStat) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
      ),
      width: double.infinity,
      decoration: expStat
          ? UIStyle.boxRoundLine8LineColor(RColor.purpleBasic_6565ff)
          : UIStyle.boxRoundLine8LineColor(
              RColor.greyBoxLine_c9c9c9,
            ),
      child: _setExpansionTile(idx),
    );
  }

  //확장 리스트 item
  Widget _setExpansionTile(
    int idx,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent,),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20,),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itemList[idx].firstContent,
                style: TextStyle(
                  color: firstStat
                      ? RColor.purpleBasic_6565ff
                      : RColor.new_basic_text_color_strong_grey,
                ),
              ),
              Image.asset(
                firstStat
                    ? 'images/icon_circle_check_y.png'
                    : 'images/icon_circle_check_n.png',
                width: 24,
                fit: BoxFit.cover,
              ),
            ],
          ),
          onTap: () {
            _setSelectExpand(itemList[idx].expandStatus);
            _setSelectStatus(itemList[idx].firstStatus);
          },
        ),
      ),
    );
  }

  List<Widget> _setSubItem2(int idx, bool firstStat, bool secondStat) {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            _setSelectExpand(itemList[idx].expandStatus);
            _setSelectStatus(itemList[idx].firstStatus);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itemList[idx].firstContent,
                  style: TextStyle(
                    color: firstStat
                        ? RColor.purpleBasic_6565ff
                        : RColor.new_basic_text_color_strong_grey,
                  ),
                ),
                Image.asset(
                  firstStat
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ],
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
          onTap: () {
            _setSelectExpand(itemList[idx].expandStatus);
            _setSelectStatus(itemList[idx].secondStatus);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itemList[idx].secondContent,
                  style: TextStyle(
                    color: secondStat
                        ? RColor.purpleBasic_6565ff
                        : RColor.new_basic_text_color_strong_grey,
                  ),
                ),
                Image.asset(
                  secondStat
                      ? 'images/icon_circle_check_y.png'
                      : 'images/icon_circle_check_n.png',
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  List<Widget> _setSubItem4(int idx, bool firstStat, bool secondStat,
      bool thirdStat, bool fourthStat) {
    return [
      InkWell(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration:
              firstStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: secondStat
              ? UIStyle.boxSelectedPurple()
              : UIStyle.boxWeakGrey25(),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration:
              thirdStat ? UIStyle.boxSelectedPurple() : UIStyle.boxWeakGrey25(),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 50,
          decoration: fourthStat
              ? UIStyle.boxSelectedPurple()
              : UIStyle.boxWeakGrey25(),
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
      _sJoinRoute = 'OLLAETC'; //기타
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
      _showDialogMsg('가입하시게 된 경로를 선택해 주세요.');
    } else {
      //체크완료
      if (_isAgreeMarketing) {
        _smsCheck = 'Y';
      } else {
        _smsCheck = 'N';
      }
      DLog.d(JoinRoutePage.TAG, '마케팅 수신동의 : $_isAgreeMarketing');
      DLog.d(JoinRoutePage.TAG, '### JoinRoute : $_sJoinRoute');
      DLog.d(JoinRoutePage.TAG,
          '### userId : ${widget.userJoinInfo.userId} / ### pass : ${widget.userJoinInfo.email} / ### phone : ${widget.userJoinInfo.name}');
      //라씨 회원가입
      if (widget.userJoinInfo.pgType == 'RASSI') {
        widget.userJoinInfo.userId = widget.userJoinInfo.userId.toLowerCase();
        _reqType = 'join_confirm';
        _reqParam =
            'userid=${Net.getEncrypt(widget.userJoinInfo.userId.toLowerCase())}&passWd=${Net.getEncrypt(widget.userJoinInfo.email.trim())}&hp=${Net.getEncrypt(widget.userJoinInfo.name.trim())}&username=&sex_gubun=&joinRoute=$_sJoinRoute&daily=$_emailCheck&tm_sms_f=$_smsCheck';
        _requestThink();
      }
      //쓱가입
      else if (widget.userJoinInfo.pgType == 'SSGOLLA') {
        DLog.d(
            'SsgJoinPage.TAG',
            '씽크풀 가입안됨 ' +
                "SSGOLLA" +
                utilsGetDeviceHpID(widget.userJoinInfo.phone));
        _reqType = 'join_sns';
        _reqParam =
            "snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(widget.userJoinInfo.phone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SNSM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(widget.userJoinInfo.phone)}&kt_provide_flag=N&hpEncFlag=Y";
        _requestThink();
      }
      //네이버/카카오/애플
      else {
        if (widget.userJoinInfo.userId.isNotEmpty) {
          _reqType = 'join_sns';
          _reqParam =
              "snsId=${Net.getEncrypt(widget.userJoinInfo.userId)}&snsPos=${widget.userJoinInfo.pgType}&nick=&userName=${widget.userJoinInfo.name}&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SM&email=${widget.userJoinInfo.email}&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=";
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
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (widget.userJoinInfo.pgType) {
      case 'SSGOLLA':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.ssg));
          break;
        }
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
      case 'RASSI':
        {
          CustomFirebaseClass.logEvtLogin(describeEnum(LoginPlatform.rassi));
          break;
        }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String prefsUserId = prefs.getString(Const.PREFS_USER_ID) ?? '';
    String globalUserId = AppGlobal().userId;

    if (prefsUserId.isEmpty) {
      if (globalUserId.isEmpty) {
        if (mounted) {
          await CommonPopup.instance.showDialogBasicConfirm(
              context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const IntroStartPage()),
                (route) => false);
          }
        }
      } else {
        await prefs.setString(Const.PREFS_USER_ID, globalUserId);
      }
    }

    if (globalUserId.isEmpty) {
      AppGlobal().userId = prefsUserId;
    }

    if (basePageState != null) {
      //TODO @@@@@
      // basePageState = null;
      basePageState = BasePageState();
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const BasePage(),
              settings: const RouteSettings(name: '/base')),
          (route) => false);
    }
  }

  void _showDialogMsg(String msg) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
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
                    style: TStyle.title20,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    msg,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
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
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
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

    var urls = Uri.parse(url);
    final http.Response response =
        await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.d(JoinRoutePage.TAG, '${response.statusCode}');
    DLog.d(JoinRoutePage.TAG, response.body);

    final String result = response.body;

    if (_reqType == 'join_sns') {
      //SNS 회원가입
      if (result.isNotEmpty) {
        final ThinkLoginSns resData =
            ThinkLoginSns.fromJson(jsonDecode(result));

        if (resData.resultCode.toString().trim() == '0') {
          commonShowToast("회원가입에 실패했습니다");
        } else {
          DLog.d(JoinRoutePage.TAG, "USER ID : ${resData.userId}");
          DLog.d(JoinRoutePage.TAG, "NICK : ${resData.nickName}");
          widget.userJoinInfo.userId = resData.userId;
          HttpProcessClass()
              .callHttpProcess0002(widget.userJoinInfo.userId)
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
                  CommonPopup.instance
                      .showDialogMsg(context, value.appDialogMsg);
                }
            }
          });
        }
      }
    } else if (_reqType == 'join_confirm') {
      //라씨 회원가입
      if (result != 'ERR' && result.isNotEmpty) {
        HttpProcessClass()
            .callHttpProcess0002(widget.userJoinInfo.userId)
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
        if (result == 'PWERR') {
          _showDialogMsg('안전한 비밀번호로 다시 설정해 주세요.');
        } else {
          _showDialogMsg('회원 가입에 실패하였습니다. 고객센터로 문의해주세요.');
        }
      }
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

  RouteInfo(
      this.subItemTitle,
      this.firstContent,
      this.secondContent,
      this.thirdContent,
      this.fourthContent,
      this.firstStatus,
      this.secondStatus,
      this.thirdStatus,
      this.fourthStatus,
      this.expandStatus);
}
