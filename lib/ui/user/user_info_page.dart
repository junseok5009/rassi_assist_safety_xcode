import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_mgr_agent/tr_mgr_agent02.dart';
import 'package:rassi_assist/models/tr_no_retdata.dart';
import 'package:rassi_assist/models/tr_push01.dart';
import 'package:rassi_assist/models/tr_push04.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/intro_start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.12.
/// 회원정보 관리
class UserInfoPage extends StatefulWidget {
  static const routeName = '/page_user_info';
  static const String TAG = "[UserInfoPage] ";
  static const String TAG_NAME = 'MY_회원정보';

  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserInfoState();
}

class UserInfoState extends State<UserInfoPage> {
  final String _appEnv = Platform.isIOS ? "EN20" : "EN10";
  static const channel = MethodChannel(Const.METHOD_CHANNEL_NAME);

  late SharedPreferences _prefs;
  String _userId = '';
  String? _token = '';

  String title = '';
  String nDate = '';
  Color statColor = Colors.grey;

  bool _isChPass = false;
  String _sBtnPass = '변경하기';
  String _sPassHint = '******';

  bool _isChPhone = false;
  bool _isCertInput = false;
  String _certTime = '';
  String _sBtnPhone = '변경하기';

  String _phone = ''; // 현재 회원의 전화번호

  // 마켓팅 동의
  bool _smsYn = false;
  bool _pushYn = false;

  // 추천인
  bool _isDoingRec = false; // 추천인 입력가능한 상태 = true
  bool _isSearchingRec = false; // 추천인 입력하여 연관 검색 리스트 떠야하는 상태
  bool _isSearh02Processing = false; // 중복호출방지
  final List<MgrAgent02Agent> _listRec = []; //검색어 입력하여 검색된 리스트
  int _clickRecItemIndex = -1; // 검색 아이템 리스트를 클릭한 인덱스, -1이면 선택을 안했거나, 수정중 임.
  String _recSearchText = ''; // 유저가 타이핑하여 조회해야할 추천인 입력값
  late UserInfoProvider _userInfoProvider;

  final _passController = TextEditingController();
  final FocusNode _passFocusNode = FocusNode();
  final _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final _certController = TextEditingController();
  final FocusNode _certFocusNode = FocusNode();
  final _recommendController = TextEditingController();
  final FocusNode _recommendFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      UserInfoPage.TAG_NAME,
    );
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    _loadPrefData().then((value) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _fetchPosts(
          TR.USER02,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    });
  }

  @override
  void dispose() {
    _passController.dispose();
    _certController.dispose();
    _phoneController.dispose();
    _recommendController.dispose();
    _passFocusNode.dispose();
    _phoneFocusNode.dispose();
    _certFocusNode.dispose();
    _recommendFocusNode.dispose();
    super.dispose();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _token = await FirebaseMessaging.instance.getToken();
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        Colors.white,
        Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
                child: ListView(
                  children: [
                    const Text(
                      '회원 정보 관리',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(height: 25),

                    //아이디
                    _setSubTitle("아이디"),
                    const SizedBox(height: 10),
                    _setGreyBoxWidget(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _userId,
                              style: TStyle.textGrey15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _pressedBtn(
                            false,
                            '로그아웃',
                            _showDialogLogout,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _userId.isEmpty
                          ? ''
                          : _userId.contains('@nv')
                              ? '현재 네이버 아이디로 로그인하여 이용중입니다.'
                              : _userId.contains('@ko')
                                  ? '현재 카카오 아이디로 로그인하여 이용중입니다.'
                                  : _userId.contains('@gl')
                                      ? '현재 구글 아이디로 로그인하여 이용중입니다.'
                                      : _userId.contains('@ap')
                                          ? '현재 애플 아이디로 로그인하여 이용중입니다.'
                                          : _userId.contains('@sa')
                                              ? '현재 휴대폰번호로 간편하게 시작하기로 이용중입니다.'
                                              : '현재 라씨(씽크풀) 아이디로 로그인하여 이용중입니다.',
                      style: TStyle.contentGrey13,
                    ),

                    //비밀번호
                    Visibility(
                      visible: !_userId.contains('@') ||
                          (!_userId.contains('@nv') &&
                              !_userId.contains('@ko') &&
                              !_userId.contains('@gl') &&
                              !_userId.contains('@ap') &&
                              !_userId.contains('@sa')),
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _setSubTitle("비밀번호"),
                            const SizedBox(
                              height: 10,
                            ),
                            _setGreyBoxWidget(
                              child: Row(
                                //crossAxisAlignment: _isChPass ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: _isChPass
                                        ? TextField(
                                            enabled: _isChPass,
                                            controller: _passController,
                                            cursorColor: RColor.new_basic_text_color_grey,
                                            style: TStyle.textGrey15,
                                            decoration: InputDecoration(
                                              hintText: _sPassHint,
                                              hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: RColor.new_basic_text_color_light_grey,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            focusNode: _passFocusNode,
                                          )
                                        : Text(
                                            _sPassHint,
                                            style: TStyle.textGrey15,
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  _pressedBtn(
                                    _isChPass,
                                    _sBtnPass,
                                    () {
                                      //변경중
                                      if (_isChPass) {
                                        String chPass = _passController.text.trim();
                                        if (_isPwCheck(chPass) || _passController.text.trim().length < 6) {
                                          CommonPopup.instance.showDialogBasicConfirm(
                                            context,
                                            '알림',
                                            RString.join_err_pw_rule,
                                          ); //6~12자리 영문, 숫자만 가능
                                        } else {
                                          _requestChPass(chPass);
                                        }
                                      } else {
                                        setState(() {
                                          _sBtnPass = '확인';
                                          _isChPass = true;
                                          _sPassHint = '6~12자리 영문/숫자, 동일 3자리 불가';
                                        });
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          FocusScope.of(context).requestFocus(_passFocusNode);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    //나의 추천인
                    _setSubTitle("나의 추천인"),
                    const SizedBox(height: 10),
                    _setGreyBoxWidget(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _isDoingRec
                                // 에이전트 유저 + 추천인 입력 중(변경)
                                ? TextField(
                                    enabled: _isDoingRec,
                                    controller: _recommendController,
                                    cursorColor: RColor.new_basic_text_color_grey,
                                    style: TStyle.textGrey15,
                                    decoration: const InputDecoration(
                                      hintText: '추천인을 입력해 주세요.',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: RColor.new_basic_text_color_light_grey,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    focusNode: _recommendFocusNode,
                                    onChanged: (_) async {
                                      _clickRecItemIndex = -1;
                                      await Future.delayed(const Duration(milliseconds: 10));
                                      if (_recommendController.text.length > 1) {
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
                                      bottom: 150,
                                    ),
                                  )
                                // 에이전트 유저 + 추천인 노출
                                : _userInfoProvider.isAgentUser
                                    ? Text(
                                        _userInfoProvider.getUser04.agentData.agentName,
                                        style: TStyle.textGrey15,
                                      )
                                    // 에이전트 유저가 아님
                                    : const Text(
                                        '추천을 받아 라씨 매매비서에 가입한 경우 추천인이 표시됩니다.',
                                        style: TStyle.textMGrey,
                                      ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          _pressedBtn(
                            _isDoingRec,
                            _userInfoProvider.isAgentUser && !_isDoingRec ? '변경하기' : '등록하기',
                            () {
                              // 추천인 등록 과정
                              if (_isDoingRec) {
                                if (_clickRecItemIndex == -1) {
                                  CommonPopup.instance
                                      .showDialogBasicConfirm(context, '알림', '등록하실 추천인을 선택하신 후 등록하기를 눌러주세요.');
                                } else {
                                  setState(() {
                                    _isDoingRec = false;
                                  });
                                  // 우리 서버 - 추천인 등록 > 웹 API joinRoute 변경
                                  _requestUserEditJoinRoute();
                                }
                              } else {
                                setState(() {
                                  _isDoingRec = true;
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  FocusScope.of(context).requestFocus(_recommendFocusNode);
                                });
                              }
                            },
                          ),
                        ],
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
                          itemBuilder: (BuildContext context, index) => _setRecommendListChild(index, _listRec[index]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    _setSubTitle("휴대폰 번호"),
                    const SizedBox(height: 10),
                    _setGreyBoxWidget(
                      child: Row(
                        children: [
                          Expanded(
                            child: _isChPhone
                                ? TextField(
                                    enabled: _isChPhone,
                                    controller: _phoneController,
                                    cursorColor: RColor.new_basic_text_color_grey,
                                    style: TStyle.textGrey15,
                                    decoration: const InputDecoration(
                                      hintText: '번호 입력 후 인증번호를 요청해주세요.',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: RColor.new_basic_text_color_light_grey,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    maxLines: 1,
                                    maxLength: 13,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    scrollPadding: const EdgeInsets.only(
                                      bottom: 500,
                                    ),
                                    focusNode: _phoneFocusNode,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly], // On
                                  )
                                : Text(
                                    _phone.length == 11
                                        ? '${_phone.substring(0, 3)}-${_phone.substring(3, 7)}-${_phone.substring(7)}'
                                        : _phone,
                                    style: TStyle.textGrey15,
                                  ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _pressedBtn(
                            _isChPhone,
                            _sBtnPhone,
                            () {
                              //변경중
                              if (_isChPhone) {
                                String chPhone = _phoneController.text.trim();
                                if (chPhone.length > 7) {
                                  DLog.d('인증번호요청 -> ', chPhone);
                                  _requestCertNum(chPhone);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                                  });
                                } else {
                                  CommonPopup.instance.showDialogBasicConfirm(
                                    context,
                                    '알림',
                                    '휴대폰 번호를 입력해주세요',
                                  );
                                }
                              } else {
                                setState(() {
                                  _isChPhone = true;
                                  _sBtnPhone = '인증번호 요청';
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    //인증번호 입력
                    Visibility(
                      visible: _isCertInput,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: _setGreyBoxWidget(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _certController,
                                  cursorColor: RColor.new_basic_text_color_grey,
                                  style: TStyle.textGrey15,
                                  decoration: const InputDecoration(
                                    hintText: '수신된 인증번호를 입력하세요.',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: RColor.new_basic_text_color_light_grey,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  focusNode: _certFocusNode,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              _pressedBtn(
                                true,
                                '확인',
                                () {
                                  String strNum = _certController.text.trim();
                                  if (strNum.length > 4) {
                                    _requestCertConfirm(_phoneController.text.trim(), strNum);
                                  } else {
                                    CommonPopup.instance.showDialogBasicConfirm(
                                      context,
                                      '알림',
                                      '인증번호를 입력해주세요',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    //마케팅 동의
                    _setSubTitle("마케팅 동의"),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          runSpacing: 0,
                          spacing: 10,
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          children: [
                            SizedBox(
                              width: 114,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                        activeColor: RColor.purpleBasic_6565ff,
                                        checkColor: RColor.purpleBasic_6565ff,
                                        side: MaterialStateBorderSide.resolveWith(
                                          (states) => BorderSide(
                                            width: 1.2,
                                            color: _smsYn ? RColor.purpleBasic_6565ff : RColor.iconGrey,
                                          ),
                                        ),
                                        fillColor: MaterialStateProperty.resolveWith((Set states) {
                                          if (states.contains(MaterialState.disabled)) {
                                            return Colors.white70;
                                          }
                                          return Colors.white;
                                        }),
                                        value: _smsYn,
                                        onChanged: (value) {
                                          _smsYn = value!;
                                          String param =
                                              'userid=$_userId&etcData=tm_sms_f:${_smsYn == true ? 'Y' : 'N'}|daily:N|';
                                          _requestThink('user_edit', param);
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      _smsYn = !_smsYn;
                                      String param =
                                          'userid=$_userId&etcData=tm_sms_f:${_smsYn == true ? 'Y' : 'N'}|daily:N|';
                                      _requestThink('user_edit', param);
                                    },
                                    child: const Text(
                                      'SMS 수신동의',
                                      style: TStyle.textGrey15S,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: 135,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                        activeColor: RColor.purpleBasic_6565ff,
                                        checkColor: RColor.purpleBasic_6565ff,
                                        side: MaterialStateBorderSide.resolveWith(
                                          (states) => BorderSide(
                                              width: 1.2, color: _pushYn ? RColor.purpleBasic_6565ff : RColor.iconGrey),
                                        ),
                                        fillColor: MaterialStateProperty.resolveWith((Set states) {
                                          if (states.contains(MaterialState.disabled)) {
                                            return Colors.white70;
                                          }
                                          return Colors.white;
                                        }),
                                        value: _pushYn,
                                        onChanged: (value) {
                                          _pushYn = value!;
                                          _fetchPosts(
                                              TR.PUSH06,
                                              jsonEncode(<String, String>{
                                                'userId': _userId,
                                                'rcvAssentYn': _pushYn == true ? 'Y' : 'N',
                                              }));
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      _pushYn = !_pushYn;
                                      _fetchPosts(
                                          TR.PUSH06,
                                          jsonEncode(<String, String>{
                                            'userId': _userId,
                                            'rcvAssentYn': _pushYn == true ? 'Y' : 'N',
                                          }));
                                    },
                                    child: const Text(
                                      '앱푸시 수신동의',
                                      style: TStyle.textGrey15S,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '수신에 동의하시면 이벤트 및 서비스 등의 혜택을 받으실 수 있습니다.(유료서비스 관련 및 회사의 주요 정책은 동의 여부와 관계없이 발송됩니다.)',
                          style: TStyle.contentGrey13,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    //회원 탈퇴
                    _setSubTitle("회원탈퇴"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '라씨 매매비서를 더이상 이용하지 않을 경우 회원 탈퇴를 진행해 주세요.',
                            style: TStyle.textGrey14S,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        _pressedBtn(
                          false,
                          '회원탈퇴',
                          _showDialogClose,
                        ),
                      ],
                    ),
                  ],
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

  //비밀번호 유효성 체크(동일한 문자, 숫자 3자리 불가)
  bool _isPwCheck(String strPw) {
    if (strPw.isEmpty) return false;

    int count = 0; //중복된 글자수
    String tmp = strPw[0];

    for (int i = 0; i < strPw.length; i++) {
      if (tmp == strPw[i]) {
        tmp = strPw[i];
        count = count + 1;
      } else {
        tmp = strPw[i];
        if (count < 3) {
          count = 1;
        }
      }
    }
    return count > 2;
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
          _clickRecItemIndex = index;
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

  Widget _pressedBtn(
    bool isOnBtn,
    String title,
    Function function,
  ) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => function(),
      child: Container(
        //constraints: BoxConstraints(minHeight: 30,),
        padding: const EdgeInsets.all(
          7,
        ),
        decoration: isOnBtn
            ? UIStyle.boxRoundLine8LineColor(
                RColor.purpleBasic_6565ff,
              )
            : UIStyle.boxRoundLine8LineColor(
                RColor.greyBox_dcdfe2,
              ),
        child: Text(
          title,
          style: TStyle.textGrey15,
        ),
      ),
    );
  }

  Widget _setGreyBoxWidget({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        5,
      ),
      constraints: const BoxConstraints(
        minHeight: 40,
      ),
      decoration: UIStyle.boxRoundFullColor8c(
        RColor.greyBox_f5f5f5,
      ),
      child: child,
    );
  }

  void _requestTrMgrAgent02(String keyword) {
    //DLog.d('','_requestTrMgrAgent02 keyword : ${keyword}');
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

  //로그아웃 다이얼로그
  void _showDialogLogout() {
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
                  const SizedBox(height: 25),
                  const Text('로그아웃 하시겠어요?'),
                  const SizedBox(height: 30),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: const Center(
                          child: Text(
                            '로그아웃',
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _setLogoutStatus();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //로그아웃 처리
  Future<void> _setLogoutStatus() async {
    AppGlobal().setLogoutStatus();
    Provider.of<UserInfoProvider>(context, listen: false).clearUser04();
    if (_userId.length > 3) {
      String checkLoginDiv = _userId.substring(_userId.length - 3);
      switch (checkLoginDiv) {
        case '@ko':
          {
            await kakaoLogout();
            break;
          }
        case '@nv':
          {
            await naverLogout();
            break;
          }
        case '@ap':
          {
            break;
          }
      }
    }

    await _prefs.setString(Const.PREFS_USER_ID, '');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, IntroStartPage.routeName, (route) => false);
    }

    if (Platform.isAndroid) {
      try {
        await channel.invokeMethod('setPrefLogout');
      } on PlatformException catch (_) {}
    }
  }

  Future<void> kakaoLogout() async {
    DLog.d(UserInfoPage.TAG, 'goKakaoLogout()');
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.unlink(); // unlink는 토큰 삭제 + 로그아웃
      } catch (error) {
        DLog.d(UserInfoPage.TAG, 'error : $error');
      }
    }
  }

  Future<void> naverLogout() async {
    DLog.d(UserInfoPage.TAG, 'naverLogout()');
    await FlutterNaverLogin.logOutAndDeleteToken();
  }

  //회원탈퇴 확인
  void _showDialogClose() {
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
                  const SizedBox(height: 5),
                  _setSubTitle('회원탈퇴'),
                  const SizedBox(height: 25),
                  const Text(
                    '사용중인 유료 결제 서비스가 있으신 경우 사용중인 서비스를 해지하신 후 탈퇴를 하시기 바랍니다.\n'
                    '회원탈퇴를 하시면 씽크풀 웹, 모바일, 앱의 모든 활동정보가 삭제됩니다.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
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
                      _fetchPosts(
                          TR.USER04,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                          }));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(UserInfoPage.TAG, '$trStr $json');

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

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(UserInfoPage.TAG, response.body);
    if (_isLoading) {
      setState(() => _isLoading = false);
    }

    if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        String hp = resData.retData.userHp.trim();
        if (hp == 'null' || hp == 'NULL' || hp.isEmpty || hp == '없음') {
          _sBtnPhone = '등록하기';
          _phone = '없음';
        } else {
          _phone = hp;
        }
        setState(() {});
        DLog.d(UserInfoPage.TAG, resData.retData.userHp);
        DLog.d(UserInfoPage.TAG, _token ?? '');

        if (resData.retData.pushValid == 'N') {
          //푸시 재등록
          if (_token != '') {
            if (!Const.isDebuggable) {
              _fetchPosts(
                  TR.PUSH01,
                  jsonEncode(<String, String>{
                    'userId': _userId,
                    'appEnv': _appEnv,
                    'deviceId': _prefs.getString(Const.PREFS_DEVICE_ID) ?? '',
                    'pushToken': _token ?? '',
                  }));
            }
          }
        } else {
          _fetchPosts(
              TR.PUSH04,
              jsonEncode(<String, String>{
                'userId': _userId,
              }));
        }
      }
    } else if (trStr == TR.USER04) {
      //탈퇴 가능 여부
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _checkCloseStatus(resData.retData);
      } else if (resData.retCode == RT.NO_DATA) {}
    }

    //푸시 토큰 등록
    else if (trStr == TR.PUSH01) {
      final TrPush01 resData = TrPush01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _prefs.setString(Const.PREFS_SAVED_TOKEN, _token ?? '');
      } else {
        //푸시 등록 실패
        _prefs.setString(Const.PREFS_DEVICE_ID, '');
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
        _pushYn = resData.retData.rcvAssentYn == 'Y';
        String type = 'get_sms';
        String strParam = "userid=$_userId";
        _requestThink(type, strParam);
      }
    }

    // 광고성 푸시 설정
    else if (trStr == TR.PUSH06) {
      final TrNoRetData resData = TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        setState(() {});
        CommonPopup.instance.showDialogBasicConfirm(context, '알림', _pushYn == true ? '동의 되었습니다.' : '동의가 취소되었습니다.');
      }
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
          if (_recommendController.text.length > 1) {
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

  void _checkCloseStatus(User04 item) {
    AccountData aData = item.accountData;
    //체험상품 사용자 -> 탈퇴가능
    if (aData.isFreeUser == 'Y') {
      _requestAppClose();
    }
    //프리미엄 사용자 -> 탈퇴 불가
    else if (aData.prodName == '프리미엄') {
      if (mounted) {
        CommonPopup.instance.showDialogBasicConfirm(
            context,
            '알림',
            '현재 사용중인 유료 결제 서비스가 있습니다.\n'
                '사용중인 서비스를 해지하신 후\n탈퇴를 하시기 바랍니다.');
      }
    }
    //유료상품 사용자 -> 탈퇴 불가
    else if (aData.prodCode == 'AC_S3') {
      if (mounted) {
        CommonPopup.instance.showDialogBasicConfirm(
            context,
            '알림',
            '현재 사용중인 유료 결제 서비스가 있습니다.\n'
                '사용중인 서비스를 해지하신 후\n탈퇴를 하시기 바랍니다.');
      }
    }
    //사용 상품 없음
    else {
      _requestAppClose();
    }
  }

  //인증번호 요청
  _requestCertNum(String sPhone) {
    _certTime = TStyle.getTodayAllTimeString();
    String strParam = "inputNum=${Net.getEncrypt(sPhone)}"
        "&pos=$_certTime&posName=ollaJoin";
    _requestThink('cert_num', strParam);
  }

  //인증번호 확인
  _requestCertConfirm(String sPhone, String cNum) {
    String strParam = "inputNum=${Net.getEncrypt(sPhone)}"
        "&pos=$_certTime&smsAuthNum=$cNum";
    _requestThink('cert_confirm', strParam);
  }

  //전화번호 변경
  _requestChPhone(String sPhone) {
    setState(() {
      _isChPhone = false;
      _sBtnPhone = '변경하기';
      _isCertInput = false;
    });

    DLog.d(UserInfoPage.TAG, 'CH_Phone : $sPhone');
    String strParam = "userid=$_userId&encHpNo=$sPhone";
    _requestThink('phone_change', strParam);
  }

  //비밀번호 변경
  _requestChPass(String newPass) {
    String strParam = "userid=${Net.getEncrypt(_userId)}"
        "&newPassWd=${Net.getEncrypt(newPass)}";
    _requestThink('ch_pass', strParam);
  }

  //회원탈퇴 처리
  _requestAppClose() {
    DLog.d(UserInfoPage.TAG, '회원탈퇴 처리');

    String strParam = "userid=${Net.getEncrypt(_userId)}&memo=RassiAssistDismiss";
    _requestThink('close', strParam);

    _fetchPosts(
        TR.USER01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'userStatus': 'C',
          'encHp': '',
          'appEnv': _appEnv,
          'userGroup': 'UGTA',
        }));
    _setLogoutStatus();
  }

  //간편 > 일반회원 전환
  _requestChangeReg() {
    String strParam =
        "userid=${Net.getEncrypt(_userId)}&nick=$_userId&hp=$_phone&tm_sms_f=${_smsYn == true ? 'Y' : 'N'}&join_channel=NM";
    _requestThink('change_reg', strParam);
  }

  //에이전트 (joinRoute 변경)
  _requestUserEditJoinRoute() async {
    DLog.e('_clickRecItemIndex : $_clickRecItemIndex / _listRec[_clickRecItemIndex].agentCode : ${_listRec[_clickRecItemIndex].agentCode}');
    // 1. 매매비서 DB에도 에이전트 추천인 등록 + 웰컴페이지 띄워서 확인하세요는 여기서 안해도 됩니다.
    if (_clickRecItemIndex >= _listRec.length) {
      _showRecCancelPopup();
      return;
    }
    final http.Response response = await http.post(
      Uri.parse(Net.TR_BASE + TR.MGR_AGENT03),
      body: jsonEncode(
        <String, String>{
          'userId': _userId,
          'agentCode': _listRec[_clickRecItemIndex].agentCode,
        },
      ),
      headers: Net.headers,
    );
    final TrNoRetData resData = TrNoRetData.fromJson(jsonDecode(response.body));
    DLog.e('resData : ${resData.toString()}');
    if (resData.retCode == RT.SUCCESS) {
      await _userInfoProvider.updatePayment();
      final http.Response response = await http.post(Uri.parse(Net.THINK_EDIT_MARKETING),
          headers: Net.think_headers,
          body: 'userid=$_userId&etcData=join_route:${_listRec[_clickRecItemIndex].joinRoute}|');
      final String result = response.body;
      DLog.e('result2 : ${result.toString()}');
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '회원정보 변경 성공');
        setState(() {
          _isSearchingRec = false;
          _clickRecItemIndex = -1;
        });
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(
            context,
            '알림',
            '추천인이 등록되었습니다.',
          );
        }
      } /*else {
      씽크풀에서 실패한다면..? 모르겠
        _showRecCancelPopup();
      }*/
    } else if (int.parse(resData.retCode) > 1000) {
      if (mounted) CommonPopup.instance.showDialogBasicConfirm(context, '알림', resData.retMsg);
    } else {
      _showRecCancelPopup();
    }
  }

  void _showRecCancelPopup() {
    DLog.d(UserInfoPage.TAG, '회원정보 변경 실패');
    if (mounted) {
      CommonPopup.instance.showDialogBasicConfirm(
        context,
        '알림',
        '추천인이 잘못되었습니다. 잠시 후에 다시 시도하여 주십시오.',
      );
    }
  }

  // 씽크풀 API 호출
  void _requestThink(String type, String param) async {
    DLog.d(UserInfoPage.TAG, 'param : $param / Net.getEncrypt($_userId) : ${Net.getEncrypt(_userId)}');

    String url = '';
    if (type == 'ch_pass') {
      url = Net.THINK_CH_PASS;
    } else if (type == 'cert_num') {
      url = Net.THINK_CERT_NUM;
    } else if (type == 'cert_confirm') {
      url = Net.THINK_CERT_CONFIRM;
    } else if (type == 'phone_change') {
      url = Net.THINK_CH_PHONE;
    } else if (type == 'close') {
      url = Net.THINK_USER_CLOSE;
    } else if (type == 'user_edit') {
      url = Net.THINK_EDIT_MARKETING;
    } else if (type == 'get_sms') {
      url = Net.THINK_INFO_MARKETING;
    } else if (type == 'change_reg') {
      url = Net.THINK_JOIN_CHANGE_REG;
    }

    var urls = Uri.parse(url);
    final http.Response response = await http.post(urls, headers: Net.think_headers, body: param);

    DLog.d(UserInfoPage.TAG, '${response.statusCode}');
    DLog.d(UserInfoPage.TAG, response.body);

    // ----- Response -----
    final String result = response.body;
    if (type == 'ch_pass') {
      if (result == '1') {
        _passController.clear();
        setState(() {
          _sBtnPass = '변경하기';
          _isChPass = false;
          _sPassHint = '******';
        });
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '비밀번호가 변경되었습니다.');
        }
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '비밀번호 변경시 오류가 발생하였습니다.');
        }
      }
    } else if (type == 'cert_num') {
      setState(() {
        _isChPhone = false;
        _isCertInput = true;
      });
      if (mounted) {
        CommonPopup.instance
            .showDialogBasicConfirm(context, '알림', '인증번호가 발송되었습니다.\n\n인증번호가 수신되지 않으면 등록하신 휴대폰 번호를 확인해 주세요.');
        FocusScope.of(context).requestFocus(_certFocusNode);
      }
    } else if (type == 'cert_confirm') {
      if (result == 'success') {
        DLog.d(UserInfoPage.TAG, '인증번호 확인 완료');
        _requestChPhone(_phoneController.text.trim());
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '인증번호가 틀립니다.\n인증번호를 확인 후 다시 입력해 주세요.');
        }
      }
    } else if (type == 'phone_change') {
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '전화번호 변경 완료');
        _phone = _phoneController.text;
        _requestChangeReg();
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '휴대폰 번호가 변경되었습니다.');
        }
      } else if (result == '-9') {
        DLog.d(UserInfoPage.TAG, '폰 변경 잘못된 Param');
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '휴대폰 번호 변경 요청이 실패하였습니다.');
        }
      }
    } else if (type == 'close') {
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '씽크풀 회원 탈퇴 완료');
      } else {
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '회원 탈퇴에 실패하였습니다.');
        }
      }
    } else if (type == 'user_edit') {
      DLog.d(UserInfoPage.TAG, 'result : ${result.toString()}');
      if (result == '1') {
        DLog.d(UserInfoPage.TAG, '회원정보 변경 성공');
        setState(() {});
        if (mounted) {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', _smsYn == true ? '동의 되었습니다.' : '동의가 취소되었습니다.');
        }
      } else {
        DLog.d(UserInfoPage.TAG, '회원정보 변경 실패');
      }
    } else if (type == 'get_sms') {
      final String result = response.body;
      Map<String, dynamic> json = jsonDecode(result);
      _smsYn = (json['tm_sms_f'] ?? 'N') == 'Y';
      setState(() {});
    } else if (type == 'change_reg') {
      DLog.d(UserInfoPage.TAG, 'result : ${result.toString()}');
      if (result == '0') {
        DLog.d(UserInfoPage.TAG, '입력 오류');
      } else if (result == '-1') {
        DLog.d(UserInfoPage.TAG, '간편회원아님');
      } else if (result == '-2') {
        DLog.d(UserInfoPage.TAG, '휴대폰번호필수');
      } else if (result == '-3') {
        DLog.d(UserInfoPage.TAG, '불량등록된 휴대폰번호');
      } else if (result == '-4') {
        DLog.d(UserInfoPage.TAG, '필명중복');
      } else if (result == '-5') {
        DLog.d(UserInfoPage.TAG, '필명필수체크');
      } else if (result == '-6') {
        DLog.d(UserInfoPage.TAG, '전화번호 중복');
      }
    }
  }
}
