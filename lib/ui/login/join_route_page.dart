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
import 'package:rassi_assist/des/http_process_class.dart';
import 'package:rassi_assist/des/utils.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/think_login_sns.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2021.04.28
/// 회원가입 경로 선택
class JoinRoutePage extends StatelessWidget {
  static const routeName = '/page_join_route';
  static const String TAG = "[JoinRoutePage]";
  static const String TAG_NAME = '회원가입_가입경로';
  const JoinRoutePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepBlue,
          elevation: 0,
        ),
        body: JoinRouteWidget(),
      ),
    );
  }
}


class JoinRouteWidget extends StatefulWidget {
  const JoinRouteWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinRouteState();
}


class JoinRouteState extends State<JoinRouteWidget> {
  late PgData args;
  final _scrollController = ScrollController();
  String deviceOsVer = '';

  bool _isInitBuild = true; //Build 메소드 안에서 처음 한번만 값 저장
  String _reqType = '';
  String _reqParam = '';

  String _strId = '';
  String _strEmail = '';
  String _strName = '';
  String _pgType = ''; //naver, kakao, ssg, rassi

  String _tempId = '';
  String _sJoinRoute = '';

  String _strPhone = '';
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
  Widget build(BuildContext context) {
    if (_isInitBuild) {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      _strId = args.userId ?? '';
      _strEmail = args.pgData ?? ''; //이메일 또는 비밀번호(라씨)
      _strName = args.pgSn ?? ''; //이름 또는 전화번호(라씨)
      _pgType = args.flag ?? '';
      if (_pgType == 'SSGOLLA') {
        _strPhone = _strId;
        _strId = '';
      }
      DLog.d(JoinRoutePage.TAG, 'args : $_strId');
      DLog.d(JoinRoutePage.TAG, 'args : $_pgType');
      _isInitBuild = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            unselectedWidgetColor: Colors.white,
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.white)),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: itemList.length + 2,
          itemBuilder: (context, i) {
            if (i == 0) {
              return _setHeaderTile(); //Header - 어떻게 만나시게 되셨나요?
            } else if (i == 6) {
              return _setFooterTile();
            } else {
              int idx = i - 1;
              return _setDivTile(idx, expandList[idx]);
            }
          },
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
            color: RColor.mainColor,
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: InkWell(
              child: const Center(
                child: Text(
                  '동의하고 시작합니다.',
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
    return Container(
      width: double.infinity,
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo_icon_wt.png',
            height: 50,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            '라씨 매매비서를\n어떻게 만나시게 되셨나요?',
            textAlign: TextAlign.center,
            style: TStyle.content17,
          ),
        ],
      ),
    );
  }

  Widget _setFooterTile() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 25),
        width: double.infinity,
        height: 60,
        decoration:
            statList[10] ? UIStyle.boxBtnSelected() : UIStyle.boxRoundLine6(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '  기타',
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: statList[10] ? Colors.white : Colors.black),
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
      margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
      width: double.infinity,
      decoration:
          expStat ? UIStyle.boxSelectedLine12() : UIStyle.boxRoundLine6(),
      child: _setExpansionTile(idx),
    );
  }

  //확장 리스트 item
  Widget _setExpansionTile(
    int idx,
  ) {
    return ExpansionTile(
      //타이틀 Center 정렬을 위한 아이콘
      leading: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white,
      ),
      // collapsedIconColor: Colors.amber,
      iconColor: Colors.grey,
      //타이틀
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            itemList[idx].subItemTitle,
            style: const TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),

      onExpansionChanged: (expanded) {
        DLog.d(JoinRoutePage.TAG, 'message $expanded | $idx');
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
    );
  }

  Widget _setSubItem1(int idx, bool firstStat) {
    return InkWell(
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
    );
  }

  List<Widget> _setSubItem2(int idx, bool firstStat, bool secondStat) {
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
      //라씨 회원가입
      if (_pgType == 'RASSI') {
        _tempId = _strId.toLowerCase();
        _reqType = 'join_confirm';
        _reqParam = 'userid=${Net.getEncrypt(_strId.toLowerCase())}&passWd=${Net.getEncrypt(_strEmail.trim())}&hp=${Net.getEncrypt(_strName.trim())}&username=&sex_gubun=&joinRoute=$_sJoinRoute&daily=$_emailCheck&tm_sms_f=$_smsCheck';
        DLog.d(JoinRoutePage.TAG, '### userId : ${_strId.toLowerCase()}');
        DLog.d(JoinRoutePage.TAG, '### _tempId : ${_tempId}');
        DLog.d(JoinRoutePage.TAG, '### pass : ${_strEmail.trim()}');
        DLog.d(JoinRoutePage.TAG, '### phone : ${_strName.trim()}');
        _requestThink();
      }
      //쓱가입
      else if (_pgType == 'SSGOLLA') {
        DLog.d('SsgJoinPage.TAG',
            '씽크풀 가입안됨 ' + "SSGOLLA" + utilsGetDeviceHpID(_strPhone));
        _reqType = 'join_sns';
        _reqParam = "snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(_strPhone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SNSM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(_strPhone)}&kt_provide_flag=N&hpEncFlag=Y";
        _requestThink();
      }
      //네이버/카카오/애플
      else {
        if (_strId != null && _strId.isNotEmpty) {
          _reqType = 'join_sns';
          _reqParam = "snsId=${Net.getEncrypt(_strId)}&snsPos=$_pgType&nick=&userName=$_strName&sexGubun=&joinRoute=$_sJoinRoute&joinChannel=SM&email=$_strEmail&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=";
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
  void _goNextRoute(String userId) {
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (_pgType) {
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
    if (userId != '') {
      if (basePageState != null) {
        // basePageState = null;
        basePageState = BasePageState();
      }
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => BasePage()));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BasePage()),
          (route) => false);
    } else {}
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
          _tempId = resData.userId;
          HttpProcessClass().callHttpProcess0002(_tempId).then((value) {
            DLog.d(JoinRoutePage.TAG, 'then() value : $value');
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
    } else if (_reqType == 'join_confirm') {
      //라씨 회원가입
      if (result != 'ERR' && result.isNotEmpty) {
        HttpProcessClass().callHttpProcess0002(_strId).then((value) {
          DLog.d(JoinRoutePage.TAG, 'then() value : $value');
          switch (value.appResultCode) {
            case 200:
              {
                _goNextRoute(_strId);
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
