import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_app/tr_app03.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/custom_firebase_class.dart';
import '../../common/ui_style.dart';
import '../../models/none_tr/app_global.dart';
import '../../models/tr_prom02.dart';

/// 2024.03
/// 무통장결제 by bank transfer
class PayMutongPage extends StatefulWidget {
  static const routeName = '/page_pay_mutong';
  static const String TAG = "[PayMutongPage]";
  static const String TAG_NAME = '무통장_결제';

  const PayMutongPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PayMutongState();
}

class PayMutongState extends State<PayMutongPage> {
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = "";
  String _curProd = ''; //현재 사용중인 상품은
  bool statusCon = false; //결제모듈 연결상태

  // TODO 무통장 결제 상품코드??

  var statCallback;
  var errCallback;

  bool prBanner = false;
  final List<Prom02> _listPrBanner = [];

  // 23.10.11 추가 구매 안내 문구 전문으로 가져오기
  final List<App03PaymentGuide> _listApp03 = [];

  // TODO 1. 이미 결제된 상품 확인 (프리미엄일 경우 결제 불가)
  // TODO 2. 결제 가능 상태 확인 (매매비서 서버에 확인, 앱스토어 모듈에 확인)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PayMutongPage.TAG_NAME);

    _loadPrefData().then((value) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      _curProd = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
      if (_userId == '') {
        Navigator.pop(context);
      } else {
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.simpleWithExit(
        context,
        '무통장 입금 결제',
        Colors.black,
        Colors.white,
        Colors.black,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _setTopDesc(),
                        const SizedBox(height: 10),

                        _setBanner(),
                        const SizedBox(height: 15),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          child: Text(
                            '결제 상품',
                            style: TStyle.commonTitle,
                          ),
                        ),
                        _setProductInfo(),
                        const SizedBox(height: 15),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          child: Text(
                            '입금 계좌 정보',
                            style: TStyle.commonTitle,
                          ),
                        ),
                        _setAccountInfo(),
                        const SizedBox(height: 25),

                        //관련 문의
                        _setRelatedQuestion(),
                        //구매 안내
                        Platform.isIOS ? _setPayInfo() : _setPayInfoAOS(),

                        ////이용약관, 개인정보처리방침(ios만 표시)
                        Platform.isIOS ? _setTerms() : Container(),
                      ],
                    ),
                  ),
                  Container(
                    color: RColor.mainColor,
                    height: 70,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: InkWell(
                      child: const Center(
                        child: Text(
                          '무통장 입금 신청',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // TODO @@@@@
                        if (_curProd.contains('ac_s3')) {
                          commonShowToast('이미 사용중인 상품입니다. 상품이 보이지 않으시면 앱을 종료 후 다시 시작해 보세요.');
                        } else {
                          DLog.d(PayMutongPage.TAG, '프리미엄 결제 요청');
                          setState(() {
                            // _bProgress = true;
                          });
                          if (Platform.isIOS) {
                          } else if (Platform.isAndroid) {}
                        }
                      },
                    ),
                  ),
                ],
              ),

              //Progress
              const Visibility(
                visible: false,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: ModalBarrier(dismissible: false, color: Colors.grey),
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //무통장 소개
  Widget _setTopDesc() {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        '무통장 입금 결제로 가입을 원하시는 경우\n결제 상품 확인 후 아래 계좌로 입금하세요.',
        style: TStyle.content16,
      ),
    );
  }

  //결제 상품 정보
  Widget _setProductInfo() {
    return Container(
      decoration: UIStyle.boxRoundFullColor16c(
        RColor.greyBox_f5f5f5,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
      child: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상품명 : ',
                style: TStyle.content16,
              ),
              Text(
                '라씨 매매비서 프리미엄',
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이용기간 : ',
                style: TStyle.content16,
              ),
              Text(
                '12개월',
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '할인가 : ',
                style: TStyle.content16,
              ),
              Text(
                '499,000원',
                style: TStyle.content16,
              ),
            ],
          )
        ],
      ),
    );
  }

  //입금 계좌 정보
  Widget _setAccountInfo() {
    return Container(
      decoration: UIStyle.boxRoundFullColor16c(
        RColor.greyBox_f5f5f5,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '계좌번호 : ',
                style: TStyle.content16,
              ),
              const Text(
                '106-369477-00804',
                style: TStyle.content16,
              ),
              const SizedBox(width: 7),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: UIStyle.boxRoundLine6bgColor(
                    Colors.white,
                  ),
                  child: const Text(
                    '복사',
                    style: TStyle.textGrey14,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '10636947700804'));
                  commonShowToast('복사되었습니다');
                },
              )
            ],
          ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '은행명 : ',
                style: TStyle.content16,
              ),
              Text(
                '하나은행',
                style: TStyle.content16,
              ),
            ],
          ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예금주 : ',
                style: TStyle.content16,
              ),
              Text(
                '(주)씽크풀',
                style: TStyle.content16,
              ),
            ],
          )
        ],
      ),
    );
  }

  //
  Widget _setRelatedQuestion() {
    return Container(
      // color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '결제 관련 문의는?',
                style: TStyle.commonTitle,
              ),
              const SizedBox(width: 7),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: UIStyle.boxRoundLine15bgColor(
                    Colors.white,
                  ),
                  child: const Text(
                    '전화 문의',
                    style: TStyle.textGrey14,
                  ),
                ),
                onTap: () async {
                  await FlutterPhoneDirectCaller.callNumber("12345678");
                },
              ),
              const SizedBox(width: 7),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: UIStyle.boxRoundLine15bgColor(
                    Colors.white,
                  ),
                  child: const Text(
                    '카카오톡 문의',
                    style: TStyle.textGrey14,
                  ),
                ),
                onTap: () {
                  String strUrl = 'http://pf.kakao.com/_swxiLxb/chat';
                  Platform.isIOS ? commonLaunchURL(strUrl) : commonLaunchUrlApp(strUrl);
                },
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text('상담가능 시간 : 월~금(공휴일, 점심시간 제외) 오전9시~오후5시'),
        ],
      ),
    );
  }

  //결제 안내 - iOS
  Widget _setPayInfo() {
    return Container(
      // color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "App Store 구매안내",
            style: TStyle.commonTitle,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listApp03.length,
            itemBuilder: (context, index) => Text(_listApp03[index].guideText),
          ),
          const SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  //결제 안내 - android
  Widget _setPayInfoAOS() {
    return Container(
      // color: RColor.bgWeakGrey,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "안내",
            style: TStyle.commonTitle,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listApp03.length,
            itemBuilder: (context, index) => Text(_listApp03[index].guideText),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _setTerms() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle('이용약관 및 개인정보 취급방침'),
          const SizedBox(height: 10),
          _setTermsText(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  //이용약관, 개인정보처리방침
  Widget _setTermsText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: const Text(
              '이용약관 보기',
              style: TStyle.ulTextPurple,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebPage(),
                    settings: RouteSettings(
                      arguments: PgData(pgData: Net.AGREE_TERMS),
                    ),
                  ));
            },
          ),
          const SizedBox(height: 7),
          InkWell(
            child: const Text(
              '개인정보 처리방침 보기',
              style: TStyle.ulTextPurple,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebPage(),
                    settings: RouteSettings(
                      arguments: PgData(pgData: Net.AGREE_POLICY_INFO),
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //결제 완료시에만 사용 (결제 완료/실패 알림 -> 자동 페이지 종료)
  void _showDialogMsg(String message, String btnText) {
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
                    _goPreviousPage();
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
                  Text(message),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        // margin: const EdgeInsets.only(top: 20.0),
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Center(
                          child: Text(
                            btnText,
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _goPreviousPage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 배너
  Widget _setBanner() {
    return Visibility(
      visible: prBanner,
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: CardProm02(_listPrBanner),
      ),
    );
  }

  //전화 문의
  void makePhoneCall(String url) async {
    var telUrl = 'tel:' + url;
    telUrl = telUrl.replaceAll((RegExp(r'-')), '');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // printError(info: '연결이 되지 않습니다.');
    }
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayMutongPage.TAG, '$trStr $json');

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
    DLog.d(PayMutongPage.TAG, response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.accountData != null) {
          final AccountData accountData = resData.retData.accountData;
          accountData.initUserStatus();
        } else {
          const AccountData().setFreeUserStatus();
        }
        _fetchPosts(
            TR.APP03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    } else if (trStr == TR.APP03) {
      final TrApp03 resData = TrApp03.fromJson(jsonDecode(response.body));
      _listApp03.clear();
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData!.listPaymentGuide.isNotEmpty) {
          _listApp03.addAll(resData.retData!.listPaymentGuide);
          setState(() {});
        }
        _fetchPosts(
            TR.PROM02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'viewPage': 'LPH2',
              'promoDiv': '',
            }));
      }
    }

    //홍보
    else if (trStr == TR.PROM02) {
      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          for (int i = 0; i < resData.retData.length; i++) {
            Prom02 item = resData.retData[i];
            if (item.promoDiv == 'BANNER') {
              if (item.viewPosition != '') {
                if (item.viewPosition == 'TOP') _listPrBanner.add(item);
                if (item.viewPosition == 'HGH') _listPrBanner.add(item);
                if (item.viewPosition == 'MID') _listPrBanner.add(item);
                //if (item.viewPosition == 'LOW') _listPrBanner.add(item);
              }
            }
          }
        }
        setState(() {
          if (_listPrBanner.length > 0) prBanner = true;
          //if (_listPrHgh.length > 0) prHGH = true;
          //if (_listPrMid.length > 0) prMID = true;
          //if (_listPrLow.length > 0) prLOW = true;
        });
      }
    }
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      DLog.d(PayMutongPage.TAG, '화면 종료');
      Navigator.of(context).pop(null); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });
  }
}
