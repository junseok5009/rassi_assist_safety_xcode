import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_user/tr_user02.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/common_class.dart';
import '../../common/custom_firebase_class.dart';
import '../../common/net.dart';
import '../../models/pg_news.dart';
import '../../models/tr_basic.dart';
import '../common/common_popup.dart';
import '../common/only_web_view.dart';
import '../main/base_page.dart';

class PremiumCarePage extends StatefulWidget {
  static const String TAG_NAME = '프리미엄_케어';

  const PremiumCarePage({Key? key}) : super(key: key);
  @override
  State<PremiumCarePage> createState() => _PremiumCarePageState();
}

class _PremiumCarePageState extends State<PremiumCarePage> {
  late SharedPreferences _prefs;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  // 유저정보
  String _userId = '';
  String _userPhoneNumber = '';
  bool initExistUserPhoneNumber = false;
  bool _isCallPush08 = false;

  final SwiperController _swiperController = SwiperController();
  bool _isChecked = false;
  int _swiperIndex = 0;
  final List<String> _swiperTitle = [
    '이렇게 달라 집니다!',
    '프리미엄을 위한 매수/매도의 치트키!',
    '프리미엄이라면 실시간 알림으로!',
    '프리미엄 전용 상담 센터'
  ];

  String _reqType = '';
  String _reqParam = '';
  String _certTime = '';

  final _certNumTEController = TextEditingController();
  bool _certNumError = false;
  final _certConfirmTEController = TextEditingController();
  bool _certConfirmError = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      PremiumCarePage.TAG_NAME,
    );
    _loadPrefData().then(
      (_) => {
        _fetchPosts(
          TR.USER02,
          jsonEncode(
            <String, String>{
              'userId': _userId,
            },
          ),
        ),
      },
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _certNumTEController.dispose();
    _certConfirmTEController.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (_, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                onPressed: () => Navigator.of(context).pop(null),
              ),
              const SizedBox(
                width: 10.0,
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (layoutBuilderContext, constraint) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/icon_trophy.png',
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    '프리미엄 계정 가입을',
                                    style: TextStyle(
                                      //height: 1,
                                      fontSize: 16,
                                      color: Color(0xff111111),
                                    ),
                                  ),
                                  const Text(
                                    '환영합니다.',
                                    style: TextStyle(
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Color(0xff111111),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: RColor.mainColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: RColor.jinbora,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${_swiperIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              _swiperTitle[_swiperIndex],
                              style: const TextStyle(
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                                //color: Color(0xffCC0000)
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            SizedBox(
                              height: 340,
                              child: Swiper(
                                scrollDirection: Axis.horizontal,
                                controller: _swiperController,
                                loop: false,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return _set1stView();
                                  } else if (index == 1) {
                                    return _set2ndView();
                                  } else if (index == 2) {
                                    return _set3rdView();
                                  } else if (index == 3) {
                                    return _set4thView();
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                                onIndexChanged: (value) {
                                  setState(() {
                                    _swiperIndex = value;
                                  });
                                },
                              ),
                            ),
                            _swiperIndex == 3
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      width: double.infinity,
                                      height: 65,
                                      color: RColor.mainColor,
                                      //decoration: UIStyle.boxRoundLine6(),
                                      margin: const EdgeInsets.only(top: 5),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '지금부터 라씨 매매비서 프리미엄이 시작됩니다.',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (_isCallPush08) {
                                        // 이미 문자 발송함 > 그냥 나가기
                                        Navigator.of(context).pop('complete');
                                      } else {
                                        _fetchPosts(
                                            TR.PUSH08,
                                            jsonEncode(<String, String>{
                                              'userId': _userId,
                                            }));
                                      }
                                    },
                                  )
                                : InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: UIStyle.boxRoundLine6(),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 15,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '다음',
                                      ),
                                    ),
                                    onTap: () {
                                      _swiperController.next(
                                        animation: true,
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomSheet: isKeyboardVisible
              ? InkWell(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    color: RColor.mainColor,
                    child: const Center(
                      child: Text(
                        '입력완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _set1stView() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black,
          ),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: Row(
              children: [
                Container(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                Flexible(
                  flex: 3,
                  child: Container(),
                ),
                Container(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                const Flexible(
                  flex: 4,
                  child: Center(
                    child: Text(
                      '베이직',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                const Flexible(
                  flex: 4,
                  child: Center(
                    child: Text(
                      '프리미엄',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: RColor.mainColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black,
          ),
          _set1stItemView('AI매매신호\n보기', '매일\n최대 5종목', '무제한\n이용'),
          Container(
            width: double.infinity,
            height: 1,
            color: RColor.new_basic_line_grey,
          ),
          _set1stItemView('포켓과\n종목관리', '포켓 1개\n포켓당 3종목', '포켓 20개\n포켓당 30종목'),
          Container(
            width: double.infinity,
            height: 1,
            color: RColor.new_basic_line_grey,
          ),
          _set1stItemView('AI매매신호\n알림', 'X', '포켓의 모든 종목\n실시간 알림'),
          Container(
            width: double.infinity,
            height: 1,
            color: RColor.new_basic_line_grey,
          ),
        ],
      ),
    );
  }

  Widget _set1stItemView(String title, String basicTitle, String preTitle) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Row(
        children: [
          Container(
            width: 1,
            color: RColor.new_basic_line_grey,
          ),
          Flexible(
            flex: 3,
            child: Container(
              color: RColor.new_basic_box_grey,
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: RColor.new_basic_line_grey,
          ),
          Flexible(
            flex: 4,
            child: Center(
              child: Text(
                basicTitle,
                style: const TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            width: 1,
            color: RColor.new_basic_line_grey,
          ),
          Flexible(
            flex: 4,
            child: Center(
              child: Text(
                preTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: RColor.mainColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            width: 1,
            color: RColor.new_basic_line_grey,
          ),
        ],
      ),
    );
  }

  Widget _set2ndView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: UIStyle.boxRoundFullColor6c(
              RColor.new_basic_box_grey,
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '매수',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: RColor.sigBuy,
                            ),
                          ),
                          Text(
                            ' 종목을 찾을 땐',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' 종목캐치',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: RColor.mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: UIStyle.boxRoundFullColor25c(
                          Colors.white,
                        ),
                        child: const Text(
                          '활용 TIP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 0,
                            fontSize: 12,
                            color: RColor.new_basic_text_color_grey,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showDialog2ndItemViewExample1(
                          context,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: UIStyle.boxRoundFullColor6c(
                          Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: const Text(
                          '큰손들의\n종목캐치',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: UIStyle.boxRoundFullColor6c(
                          Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Text(
                          '성과 TOP\n종목캐치',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: UIStyle.boxRoundFullColor6c(
                          Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Text(
                          '조건별\n종목 리스트',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: UIStyle.boxRoundFullColor6c(
              RColor.new_basic_box_grey,
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '매도',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: RColor.sigSell,
                            ),
                          ),
                          Text(
                            ' 타이밍은',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' 나만의 매도신호',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: RColor.mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: UIStyle.boxRoundFullColor25c(
                          Colors.white,
                        ),
                        child: const Text(
                          '활용 TIP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 0,
                            fontSize: 12,
                            color: RColor.new_basic_text_color_grey,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showDialog2ndItemViewExample2(
                          context,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  decoration: UIStyle.boxRoundFullColor6c(
                    Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: const Text(
                    '보유종목, 나만의 매도신호로 받기',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog2ndItemViewExample1(BuildContext context) {
    if (context != null) {
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
                    Navigator.of(context).pop('complete');
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '종목캐치 이용하기',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _showDialog2ndItemViewExample1Child('① 큰손들의 종목캐치',
                      '기관, 외국인의 매수 + 라씨 매매비서의 매수신호가 함께 발생한 종목을 확인'),
                  _showDialog2ndItemViewExample1Child(
                      '② 성과 TOP 종목캐치', '매매성과가 좋은 종목들의 매매현황 모아보기'),
                  _showDialog2ndItemViewExample1Child(
                      '③ 조건별 종목 리스트', '매매기간, 주간토픽 종목 등 다양한 조건으로 종목찾기'),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _showDialog2ndItemViewExample1Child(String title, String content) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog2ndItemViewExample2(BuildContext context) {
    if (context != null) {
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
                    Navigator.of(context).pop('complete');
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '나만의 매도신호 설정하기',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '나의 포켓에 보유 종목으로 추가하세요.',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '매수 정보(매수가)를 입력하시면 회원님만을 위한 매도신호를 알려드립니다.',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _set3rdView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _set3rdItemView(
            'AI매매신호 실시간 알림',
            '① 관심 종목의 모든 매수/매도신호 실시간 알림',
            '② 나만의 매도신호 발생시 매도신호 알림',
          ),
          const SizedBox(
            height: 10,
          ),
          _set3rdItemView(
            '종목캐치 알림',
            '① 큰손과 라씨가 함께 매수한 종목알림',
            '② 성과가 좋은 종목의 새로운 매수신호 알림',
          ),
        ],
      ),
    );
  }

  Widget _set3rdItemView(
    String title,
    String subTitle1,
    String subTitle2,
  ) {
    return Container(
      width: double.infinity,
      decoration: UIStyle.boxRoundFullColor6c(
        RColor.new_basic_box_grey,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            subTitle1,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            subTitle2,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _set4thView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: UIStyle.boxRoundFullColor6c(
              RColor.new_basic_box_grey,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '''프리미엄 고객님을 위한 전용 상담 채널을 이용하세요!
전문 상담원들이 보다 빠르게 상담해 드립니다.''',
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Row(
                      children: const [
                        Text(
                          '다이렉트 상담 링크 전송받기',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '(선택)',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                      ),
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child:
                          // 인증받기 화면
                          _reqType.isEmpty
                              ? _set4ThViewCertNum()
                              :
                              // 인증 확인 화면
                              _reqType == 'cert_confirm'
                                  ? _set4ThViewCertConfirm()
                                  :
                                  // 링크받기 화면
                                  _reqType == 'phone_change'
                                      ? _set4ThViewPhoneChange()
                                      : _set4ThViewCertNum(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DEFINE 첫번째 단계, 핸드폰 번호
  Widget _set4ThViewCertNum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상담 링크를 전송받을 휴대폰 번호를 입력하세요',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: _certNumError
                        ? RColor.sigBuy
                        : RColor.new_basic_line_grey,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 5,
                ),
                child: TextField(
                  controller: _certNumTEController,
                  textAlign: TextAlign.start,
                  cursorWidth: 1.6,
                  cursorHeight: 24,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    fillColor: Colors.black,
                    focusColor: Colors.black,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '휴대폰 번호를 입력하세요',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: RColor.new_basic_text_color_grey,
                      //fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  scrollPadding: const EdgeInsets.only(bottom: 100),
                  onChanged: (value) {
                    if (_certNumError) {
                      setState(() {
                        _certNumError = false;
                      });
                    }
                  },
                  maxLines: 1,
                  maxLength: 13,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // On
                ),
              ),
            ),
            InkWell(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                margin: const EdgeInsets.only(
                  left: 5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '인증받기',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                if (_certNumTEController.text.isEmpty) {
                  _certNumError = true;
                  commonShowToastCenter('전화번호를 입력해주세요.');
                  setState(() {});
                } else if (_certNumTEController.text.length != 11) {
                  _certNumError = true;
                  commonShowToastCenter('잘못된 전화번호 입니다.\n전화번호를 다시 입력해주세요.');
                  _certNumTEController.clear();
                  setState(() {});
                } else if (!_isChecked) {
                  commonShowToastCenter('개인정보 수집에 동의하여 주십시오.');
                } else {
                  _userPhoneNumber = _certNumTEController.text.trim();
                  _requestCertNum();
                }
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Checkbox(
                      value: _isChecked,
                      activeColor: Colors.black,
                      checkColor: Colors.black,
                      side: MaterialStateBorderSide.resolveWith(
                        (states) =>
                            const BorderSide(width: 1.0, color: Colors.black),
                      ),
                      fillColor:
                          MaterialStateProperty.resolveWith((Set states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.white70;
                        }
                        return Colors.white;
                      }),
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      }),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                '개인정보수집에 동의합니다.',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                child: Row(
                  children: const [
                    Text(
                      '(→',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '내용보기',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      ')',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  basePageState.callPageRouteNews(
                    const OnlyWebView(),
                    PgNews(
                      linkUrl: 'https://www.thinkpool.com/policy/privacy',
                    ),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            if (_isChecked) {
              _isChecked = false;
            } else {
              _isChecked = true;
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  // DEFINE 두번째 단계, 인증번호 인증
  Widget _set4ThViewCertConfirm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '휴대폰 번호로 받은 인증 번호를 입력하세요',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: _certConfirmError
                        ? RColor.sigBuy
                        : RColor.new_basic_line_grey,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 5,
                ),
                child: TextField(
                  controller: _certConfirmTEController,
                  textAlign: TextAlign.start,
                  cursorWidth: 1.6,
                  cursorHeight: 25,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    fillColor: Colors.black,
                    focusColor: Colors.black,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '인증번호를 입력하세요',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: RColor.new_basic_text_color_grey,
                      //fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onChanged: (value) {
                    if (_certConfirmError) {
                      setState(() {
                        _certConfirmError = false;
                      });
                    }
                  },
                  scrollPadding: const EdgeInsets.only(bottom: 100),
                  maxLines: 1,
                  maxLength: 8,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // On
                ),
              ),
            ),
            InkWell(
              child: Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                margin: const EdgeInsets.only(
                  left: 5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                if (_certConfirmTEController.text.isEmpty) {
                  commonShowToastCenter('인증번호를 입력하세요.');
                  _certConfirmError = true;
                  setState(() {});
                } else if (_certConfirmTEController.text.length < 6) {
                  commonShowToastCenter('인증번호 6자리를 입력해 주세요.');
                  _certConfirmTEController.clear();
                  _certConfirmError = true;
                  setState(() {});
                } else {
                  _certConfirmError = false;
                  _requestCertConfirm();
                }
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Checkbox(
                      value: _isChecked,
                      activeColor: Colors.black,
                      checkColor: Colors.black,
                      //hoverColor: Colors.green,
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => const BorderSide(width: 1.0, color: Colors.black),
                      ),
                      fillColor:
                          MaterialStateProperty.resolveWith((Set states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.white70;
                        }
                        return Colors.white;
                      }),
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      }),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                '개인정보수집에 동의합니다.',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                child: Row(
                  children: const [
                    Text(
                      '(→',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '내용보기',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      ')',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  basePageState.callPageRouteNews(
                    OnlyWebView(),
                    PgNews(
                      linkUrl: 'https://www.thinkpool.com/policy/privacy',
                    ),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            if (_reqType.isEmpty) {
              if (_isChecked) {
                _isChecked = false;
              } else {
                _isChecked = true;
              }
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  // DEFINE 세번째 단계, 핸드폰 번호 + 링크 받기
  Widget _set4ThViewPhoneChange() {
    /*_certPhoneChangeTEController.selection = TextSelection.collapsed(
        offset: _certPhoneChangeTEController.text.length);*/
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '문자를 수신하시려면 링크받기 버튼을 눌러주세요.',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: RColor.new_basic_line_grey,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 5,
                ),
                child: Text(
                  _userPhoneNumber,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            InkWell(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                margin: const EdgeInsets.only(
                  left: 5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '링크받기',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                if (!_isChecked) {
                  commonShowToastCenter('개인정보 수집에 동의하여 주십시오.');
                } else {
                  _isCallPush08 = true;
                  _fetchPosts(
                      TR.PUSH08,
                      jsonEncode(<String, String>{
                        'userId': _userId,
                      }));
                }
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          child: const Text(
            '번호 변경하기',
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
          onTap: () {
            setState(() {
              _reqType = 'cert_num';
              initExistUserPhoneNumber = false;
              _isChecked = false;
              _isCallPush08 = false;
            });
          },
        ),
      ],
    );
  }

  //인증번호 요청
  _requestCertNum() {
    _certTime = TStyle.getTodayAllTimeString();
    _reqType = 'cert_num';
    _reqParam =
        'inputNum=${Net.getEncrypt(_userPhoneNumber)}&pos=$_certTime&posName=ollaJoin';
    //_reqParam = "inputNum=" + Net.getEncrypt(sPhone) + "&pos=" + _certTime + '&posName=ollaJoin';
    _requestThink();
  }

  //인증번호 확인
  _requestCertConfirm() {
    _reqType = 'cert_confirm';
    _reqParam =
        'inputNum=${Net.getEncrypt(_userPhoneNumber)}&pos=$_certTime&smsAuthNum=${_certConfirmTEController.text.trim()}';
    //_reqParam = "inputNum=" + Net.getEncrypt(sPhone) + "&pos=" + _certTime + '&smsAuthNum=' + cNum;
    _requestThink();
  }

  //전화번호 변경
  _requestChPhone() {
    _reqType = 'phone_change';
    _reqParam = "userid=$_userId&encHpNo=$_userPhoneNumber";
    _requestThink();
  }

  // 씽크풀 API 호출
  void _requestThink() async {
    String url = '';
    if (_reqType == 'cert_num') {
      //인증번호 요청
      url = Net.THINK_CERT_NUM;
    } else if (_reqType == 'cert_confirm') {
      //인증번호 확인
      url = Net.THINK_CERT_CONFIRM;
    } else if (_reqType == 'phone_change') {
      url = Net.THINK_CH_PHONE;
    }

    var urls = Uri.parse(url);
    final http.Response response = await http.post(
      urls,
      headers: Net.think_headers,
      body: _reqParam,
    );

    // RESPONSE ---------------------------
    DLog.w('${response.statusCode}');
    DLog.w(response.body);

    final String result = response.body;
    if (_reqType == 'cert_num') {
      //인증번호 요청
      if (result == 'success') {
        _reqType = 'cert_confirm';
        // _showDialogMsg(('인증번호가 발송되었습니다. 인증번호가 오지 않으면 입력하신 번호를 확인해 주세요.'));
      } else if (result == 'fail5') {
        CommonPopup()
            .showDialogMsg(context, '휴대폰 인증 5회 이상/실패로 오늘은 인증이 불가능합니다.');
      } else {
        //_showDialogMsg(('인증번호 요청이 실패하였습니다. 정확한 번호 입력 후 다시 시도하여 주세요.'));
        commonShowToastCenter('인증번호 요청이 실패하였습니다.\n정확한 번호 입력 후 다시 시도하여 주세요.');
        _certNumTEController.clear();
      }
      setState(() {});
    } else if (_reqType == 'cert_confirm') {
      //인증번호 확인
      DLog.w('인증결과 : $result');
      if (result == 'success') {
        _certConfirmError = false;
        commonShowToastCenter('인증되었습니다.');
        _reqType = 'phone_change';
        _requestChPhone();
        //_checkEditData();
      } else {
        //실패시 : result = smsAuthChkFail
        _certConfirmError = true;
        commonShowToastCenter('인증번호가 올바르지 않습니다.\n정확한 인증번호 입력 후 다시 시도하여 주세요.');
        _certConfirmTEController.clear();
      }
      setState(() {});
    } else if (_reqType == 'phone_change') {
      if (result == '1') {
        //_showDialogMsg('전화번호 변경이 완료되었습니다.');
      }
      /*else if(result == '-9') {
        //DLog.d(UserInfoPage.TAG, '폰 변경 잘못된 Param');

      } */
      else {
        //_showDialogMsg('전화번호 변경 요청이 실패하였습니다.');
        //commonShowToastCenter('알 수 없는 오류');
        //_reqType = '';
        //_reqParam = '';
        // _certConfirmTEController.clear();
        // setState(() {});
      }
    }
  }

  void _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(response.body);
    if (trStr == TR.USER02) {
      final TrUser02 resData = TrUser02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _userPhoneNumber = resData.retData.userHp.trim();
        if (_userPhoneNumber.isNotEmpty && _userPhoneNumber != '없음') {
          setState(() {
            _reqType = 'phone_change';
            initExistUserPhoneNumber = true;
            _isChecked = true;
          });
        }
      }
    } else if (trStr == TR.PUSH08) {
      final TrBasic resData = TrBasic.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (!_isCallPush08) {
          // 시작하기 버튼으로 온 경우
          if (_reqType == 'phone_change') {
            commonShowToastCenter('다이렉트 링크가 SMS로 전송되었습니다.');
            Navigator.of(context).pop('complete');
          } else {
            Navigator.of(context).pop('complete');
          }
        } else {
          // 링크받기로 온 경우
          commonShowToastCenter('다이렉트 링크가 SMS로 전송되었습니다.');
        }
      }
    }
  }
}
