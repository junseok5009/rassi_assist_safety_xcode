import 'dart:convert';

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
import 'package:rassi_assist/models/tr_mgr_agent/tr_mgr_agent02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2024.04.29
/// 에이전트 : 일반가입 회원가입에서 링크없이 추천인 입력받아 에이전트 가입으로 넘어오는 페이지
class AgentNoLinkSignUpPage extends StatefulWidget {
  const AgentNoLinkSignUpPage({super.key});

  static const routeName = '/agent_no_link_sign_up';

  @override
  State<AgentNoLinkSignUpPage> createState() => _AgentNoLinkSignUpPageState();
}

class _AgentNoLinkSignUpPageState extends State<AgentNoLinkSignUpPage> {
  UserJoinInfo _userJoinInfo = UserJoinInfo();
  bool _isLoading = false; //
  late SharedPreferences _prefs;

  String _reqType = ''; // 씽크풀 API 호출 종류 변수
  String _reqParam = ''; // 씽크풀 API 호출 파라미터 변수
  String _strOnTime = ''; // 씽크풀 API 호출 시간

  // 추천인
  bool _isSearchingRec = false; // 추천인 입력하여 연관 검색 리스트 떠야하는 상태
  bool _isSearh02Processing = false; // 중복호출방지
  final List<MgrAgent02Agent> _listRec = []; //검색어 입력하여 검색된 리스트
  String _recSearchText = ''; // 유저가 타이핑하여 조회해야할 추천인 입력값

  MgrAgent02Agent _mgrAgent02Agent = const MgrAgent02Agent();

  final _recommendController = TextEditingController();
  final FocusNode _recommendFocusNode = FocusNode();

  // 휴대폰 인증
  final _phoneController = TextEditingController(); // 휴대폰 번호 입력 박스 컨트롤러
  String _strPhone = ''; // 휴대폰 번호
  bool _phoneEditEnabled = true; // 휴대폰 번호 수정 가능 여부 (인증 이후에는 수정할 수 없음)
  bool _isConfirmPhone = false; // 휴대폰 인증 여부

  bool _visibleAuth = false; // 인증번호 박스 보여주기 여부 체크
  final _authController = TextEditingController(); // 인증번호 입력 박스 컨트롤러
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _authFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView('에이전트_초대한_추천인');
    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () async {
        _userJoinInfo = ModalRoute.of(context)?.settings.arguments as UserJoinInfo;
        if (_userJoinInfo.pgType == 'SSGOLLA') {
          _strPhone = _userJoinInfo.phone;
          _phoneController.text = _userJoinInfo.phone;
          _phoneEditEnabled = false;
          _isConfirmPhone = true;
        } else if (_userJoinInfo.pgType == 'RASSI') {}
        setState(() {});
        DLog.e('_userJoinInfo : ${_userJoinInfo.toString()}');
      });
    });
  }

  @override
  void dispose() {
    _recommendController.dispose();
    _phoneController.dispose();
    _authController.dispose();
    super.dispose();
  }


  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '',
        elevation: 0,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                          child: ListView(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '초대한 추천인이 있어요.',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                '라씨 매매비서를 추천 받으셨나요?\n추천인 정보를 확인해 보세요.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 25),

                              //나의 추천인
                              _setSubTitle("나의 추천인"),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _recommendController,
                                cursorColor: Colors.black,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: '추천인을 입력해 주세요.',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    //color: RColor.new_basic_text_color_grey,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: RColor.greyBox_f5f5f5,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: RColor.greyBox_f5f5f5,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                ),
                                focusNode: _recommendFocusNode,
                                onChanged: (_) async {
                                  _mgrAgent02Agent = const MgrAgent02Agent();
                                  await Future.delayed(const Duration(milliseconds: 10));
                                  if (_recommendController.text.isNotEmpty) {
                                    if (!_isSearh02Processing) {
                                      _isSearh02Processing = true;
                                      _recSearchText = _recommendController.text.toUpperCase().trim();
                                      _requestTrMgrAgent02(_recSearchText);
                                    } else {
                                      _recSearchText = _recommendController.text.toUpperCase().trim();
                                    }
                                  } else {
                                    setState(() {
                                      _isSearchingRec = false;
                                    });
                                  }
                                },
                                scrollPadding: const EdgeInsets.only(
                                    //  bottom: 150,
                                    ),
                              ),
                              //추천인 연관 검색어
                              Visibility(
                                visible: _isSearchingRec,
                                child: Container(
                                  width: double.infinity,
                                  height: (_listRec.length * 30) + 20,
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                  ),
                                  decoration: UIStyle.boxRoundFullColor8c(
                                    RColor.greyBox_f5f5f5,
                                  ),
                                  child: ListView.builder(
                                    physics: const ScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 5,
                                    ),
                                    shrinkWrap: true,
                                    itemCount: _listRec.length,
                                    itemBuilder: (BuildContext context, index) =>
                                        _setRecommendListChild(index, _listRec[index]),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // 휴대폰 번호
                              const Text(
                                '휴대폰 번호',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(5),
                                decoration: UIStyle.boxRoundFullColor8c(
                                  RColor.greyBox_f5f5f5,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        style: const TextStyle(color: Colors.black),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                          hintText: '휴대폰 번호를 입력해 주세요',
                                          border: InputBorder.none,
                                        ),
                                        focusNode: _phoneFocusNode,
                                        cursorColor: Colors.black,
                                        enabled: _phoneEditEnabled,
                                        controller: _phoneController,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (!_isConfirmPhone) {
                                          _checkPhone();
                                        }
                                      },
                                      child: Container(
                                        width: 75,
                                        height: 40,
                                        decoration: UIStyle.boxRoundLine8LineColor(
                                          _isConfirmPhone ? RColor.greyBasic_8c8c8c : RColor.purpleBasic_6565ff,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isConfirmPhone ? '인증완료' : '인증받기',
                                            style: TextStyle(
                                              color: _isConfirmPhone
                                                  ? RColor.greyBasicStrong_666666
                                                  : RColor.purpleBasic_6565ff,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 인증번호
                              Visibility(
                                visible: _visibleAuth,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      TextField(
                                        controller: _authController,
                                        style: const TextStyle(color: Colors.black),
                                        decoration: const InputDecoration(
                                          filled: true,
                                          hintText: '수신된 인증번호를 입력하세요.',
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: RColor.greyBox_f5f5f5,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: RColor.greyBox_f5f5f5,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          ),
                                        ),
                                        focusNode: _authFocusNode,
                                        cursorColor: Colors.black,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            _checkAuthNum(_authController.text.trim());
                                          },
                                          child: Container(
                                            width: 75,
                                            height: 40,
                                            margin: const EdgeInsets.only(right: 4),
                                            decoration: UIStyle.boxRoundLine8LineColor(
                                              RColor.purpleBasic_6565ff,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '확인',
                                                style: TextStyle(
                                                  color: RColor.purpleBasic_6565ff,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // 추천인 등록 과정
                          if (_mgrAgent02Agent.agentCode.isEmpty) {
                            CommonPopup.instance.showDialogBasicConfirm(context, '알림', '등록하실 추천인을 검색 후 선택해 주세요.').then(
                                  (value) => WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      FocusScope.of(context).requestFocus(_recommendFocusNode);
                                    },
                                  ),
                                );
                          } else if (!_isConfirmPhone) {
                            CommonPopup.instance.showDialogBasicConfirm(context, '알림', '전화번호를 인증해 주세요.').then(
                                  (value) => WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      FocusScope.of(context).requestFocus(_phoneFocusNode);
                                    },
                                  ),
                                );
                          } else {
                            // 회원가입 절차 <라씨/휴대폰/sns 구분>
                            // 에이전트 회원가입은 휴대폰번호가 있어서 일반 회원으로 가입시키기 위해 join_channel = NM 입니다.
                            if (_userJoinInfo.pgType == 'RASSI') {
                              _reqType = 'join_confirm';
                              _reqParam =
                                  'userid=${Net.getEncrypt(_userJoinInfo.userId.toLowerCase())}&passWd=${Net.getEncrypt(_userJoinInfo.email)}&hp=${Net.getEncrypt(_strPhone.trim())}&username=&sex_gubun=&joinRoute=${_mgrAgent02Agent.joinRoute}&daily=N&tm_sms_f=N&joinChannel=NM';
                              _requestThink();
                            } else if (_userJoinInfo.pgType == 'SSGOLLA') {
                              _reqType = 'join_sns';
                              _reqParam =
                                  "snsId=${Net.getEncrypt("SSGOLLA${utilsGetDeviceHpID(_userJoinInfo.phone)}")}&snsPos=SSGOLLA&nick=&userName=&sexGubun=&joinRoute=${_mgrAgent02Agent.joinRoute}&joinChannel=NM&email=&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${Net.getEncrypt(_userJoinInfo.phone)}&kt_provide_flag=N&hpEncFlag=Y";
                              _requestThink();
                            }
                            //네이버/카카오/애플/구글
                            else {
                              _reqType = 'join_sns';
                              _reqParam =
                                  "snsId=${Net.getEncrypt(_userJoinInfo.userId)}&snsPos=${_userJoinInfo.pgType}&nick=&userName=${_userJoinInfo.name}&sexGubun=&joinRoute=${_mgrAgent02Agent.joinRoute}&joinChannel=NM&email=${_userJoinInfo.email}&daily=N&infomailFlag=N&privacyFlag=N&tm_sms_f=N&encHpNo=${_userJoinInfo.phone}";
                              _requestThink();
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: UIStyle.boxRoundFullColor6c(
                            RColor.purpleBasic_6565ff,
                          ),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Text(
      subTitle,
      style: TStyle.subTitle16,
    );
  }

  //추천인 연관검색어 리스트
  Widget _setRecommendListChild(int index, MgrAgent02Agent agent) {
    int s1i1 = agent.agentName.indexOf(_recSearchText);
    String s1 = agent.agentName.substring(0, s1i1 == -1 ? 0 : s1i1);
    String s2 = agent.agentName.substring(s1i1, s1i1 + _recSearchText.length);
    String s3 = agent.agentName.substring(s1i1 + _recSearchText.length);
    return InkWell(
      onTap: () {
        setState(() {
          _mgrAgent02Agent = agent;
          _isSearchingRec = false;
          _recommendController.text = agent.agentName;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      },
      child: Container(
        width: double.infinity,
        height: 30,
        alignment: Alignment.centerLeft,
        child: RichText(
          //textAlign: TextAlign.center,
          text: TextSpan(
            style: TStyle.textGrey15S,
            children: [
              TextSpan(
                text: s1,
              ),
              TextSpan(
                text: s2,
                style: const TextStyle(
                  color: RColor.purpleBasic_6565ff,
                ),
              ),
              TextSpan(
                text: s3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestTrMgrAgent02(String keyword) {
    _fetchPosts(
      TR.MGR_AGENT02,
      jsonEncode(
        <String, String>{
          "selectDiv": "NAME",
          "selectValue": keyword,
        },
      ),
    );
  }

  // 휴대폰 번호 인증 1단계 : 번호 입력 + 인증받기 버튼
  void _checkPhone() {
    _strPhone = _phoneController.text.trim();
    if (_strPhone.isEmpty) {
      CommonPopup.instance.showDialogBasicConfirm(context, '알림', '전화번호를 입력해 주세요');
    } else if (_strPhone.length < 5) {
      CommonPopup.instance.showDialogBasicConfirm(context, '알림', '전화번호를 확인해 주세요');
    } else {
      //인증번호 발송
      _reqType = 'phone_check';
      _strOnTime = TStyle.getTimeString();
      _reqParam = 'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=ollaTdJoin';
      _requestThink();
    }
  }

  // 휴대폰 번호 인증 3단계 : 인증번호 확인
  void _checkAuthNum(String data) {
    if (data.isNotEmpty) {
      //인증번호 확인
      _reqType = 'phone_confirm';
      _reqParam = 'inputNum=${Net.getEncrypt(_strPhone)}&pos=$_strOnTime&posName=ollaTdJoin&smsAuthNum=$data';
      _requestThink();
    } else {
      CommonPopup.instance.showDialogBasicConfirm(context, '알림', '인증번호를 입력해 주세요');
    }
  }

  // 씽크풀 API 호출
  void _requestThink() async {
    DLog.e('_requestThink _reqType : $_reqType / _reqParam : $_reqParam');

    String url = '';
    if (_reqType == 'phone_check') {
      //인증번호 요청
      url = Net.THINK_CERT_NUM;
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      url = Net.THINK_CERT_CONFIRM;
    } else if (_reqType == 'join_sns') {
      //SNS 회원가입
      url = Net.THINK_SNS_JOIN;
    } else if (_reqType == 'join_confirm') {
      //회원가입
      url = Net.THINK_JOIN;
    }
    if (_isLoading) {
      return;
    } else {
      setState(() => _isLoading = true);
    }
    var urls = Uri.parse(url);
    final http.Response response = await http.post(urls, headers: Net.think_headers, body: _reqParam);

    // RESPONSE ---------------------------
    DLog.e('씽크풀 API response / response.statusCode : ${response.statusCode} / response.body : ${response.body}');

    final String result = response.body.trim();
    if (_reqType == 'phone_check') {
      //인증번호 요청
      if (result == 'success' && mounted) {
        CommonPopup.instance
            .showDialogBasicConfirm(context, '알림', ('인증번호가 발송되었습니다.\n인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'))
            .then(
              (value) => WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  FocusScope.of(context).requestFocus(_authFocusNode);
                },
              ),
            );
        _phoneEditEnabled = false;
        _visibleAuth = true;
      } else {
        _phoneEditEnabled = true;
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', ('인증번호 요청이 실패하였습니다.\n정확한 번호 입력 후 다시 시도하여 주세요.'));
        }
      }
      setState(() => _isLoading = false);
    } else if (_reqType == 'phone_confirm') {
      //인증번호 확인
      if (result == '00' || result == 'success') {
        //인증완료 회원가입 진행
        commonShowToastCenter('인증되었습니다');
        setState(() {
          // 전화번호 필드 고정. 확인 완료
          _isConfirmPhone = true; //전화번호 확인 완료
          _phoneEditEnabled = false;
          _visibleAuth = false;
          _userJoinInfo.phone = _strPhone;
        });
      } else if (result == '10' || result == '01' || result == '11') {
        if (mounted) {
          CommonPopup.instance.showDialogBasic(
              context, '알림', '이미 가입된 아이디가 있습니다.\n가입하셨던 아이디로 로그인 하시기 바랍니다.\n아이디가 기억나지 않으실 경우 아이디 찾기를 통해 찾을 수 있습니다.');
        }
      } else if (result == '99') {
        //아이디 체크시 오류
        if (mounted) {
          CommonPopup.instance.showDialogBasic(context, '알림', '없는 정보이거나 입력한 정보가 맞지 않습니다.');
        }
      } else if (result == 'standby') {
        //휴면 전환된 전화번호를 가진 아이디 있는 상태
        commonShowToastCenter('이미 가입하신 휴면상태의 아이디가 있습니다.');
      } else if (result == 'smsAuthChkFail') {
        commonShowToastCenter('인증실패 - 인증번호를 확인해주세요');
      } else if (result == 'smsAuth3Fail') {
        commonShowToastCenter('인증 3회 실패 - 인증번호를 확인해주세요');
      } else {
        commonShowToast('인증번호를 확인해주세요');
      }
      setState(() => _isLoading = false);
    } else if (_reqType == 'join_sns') {
      //SNS 회원가입
      if (result.isNotEmpty) {
        final ThinkLoginSns resData = ThinkLoginSns.fromJson(jsonDecode(result));
        if (resData.resultCode.toString().trim() == '0') {
          commonShowToast("회원가입에 실패했습니다");
        } else {
          _userJoinInfo.userId = resData.userId;
          await HttpProcessClass()
              .callHttpProcess0002(
            vUserId: _userJoinInfo.userId,
            vAgentCode: _mgrAgent02Agent.agentCode,
          )
              .then((value) {
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
        }
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
        }
      }
      setState(() => _isLoading = false);
    } else if (_reqType == 'join_confirm') {
      //회원가입
      if (result != 'ERR' && result.isNotEmpty) {
        HttpProcessClass()
            .callHttpProcess0002(
          vUserId: _userJoinInfo.userId,
          vAgentCode: _mgrAgent02Agent.agentCode,
        )
            .then((value) {
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
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '회원 가입에 실패하였습니다. 고객센터로 문의해주세요.');
        }
      }
    }
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.w('$trStr $json');

    if (_isLoading) {
      return;
    } else {
      if (trStr != TR.MGR_AGENT02) {
        setState(() => _isLoading = true);
      }
    }
    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(response.body);
    if (_isLoading) {
      setState(() => _isLoading = false);
    }

    //유저 추천인 직접 타이핑 검색
    else if (trStr == TR.MGR_AGENT02) {
      final TrMgrAgent02 resData = TrMgrAgent02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<MgrAgent02Agent>? list = resData.retData.listAgent;
        _listRec.clear();
        if (list.isNotEmpty) {
          _listRec.addAll(list);
          _isSearchingRec = true;
        } else {
          _listRec.clear();
          _isSearchingRec = false;
        }
        if (_recSearchText != _recommendController.text.toUpperCase().trim()) {
          if (_recommendController.text.isNotEmpty) {
            _isSearh02Processing = true;
            _recSearchText = _recommendController.text.toUpperCase().trim();
            _requestTrMgrAgent02(_recSearchText);
          } else {
            _isSearh02Processing = false;
          }
        } else {
          _isSearh02Processing = false;
        }
      } else {
        //오류
        _isSearchingRec = false;
      }
      setState(() {
        _isSearh02Processing = false;
      });
    }
  }

  // 다음 페이지로 이동
  Future<void> _goNextRoute() async {
    CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.LOGIN_STATUS, 'complete');
    switch (_userJoinInfo.pgType) {
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

    AppGlobal().pendingDynamicLinkData = null;
    await _prefs.setString(Const.PREFS_DEEPLINK_URI, '');
    basePageState = BasePageState();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        BasePage.routeName,
        (route) => false,
      );
    }
  }
}
