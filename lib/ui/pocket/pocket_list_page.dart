import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_global.dart';
import '../pay/pay_premium_aos_page.dart';


/// 2020.12.23
/// 포켓 모두보기
class PocketListPage extends StatelessWidget {
  static const routeName = '/page_pocket_list';
  static const String TAG = "[PocketListPage]";
  static const String TAG_NAME = '포켓_이동';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: PocketListWidget(),
      ),
    );
  }
}

class PocketListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PocketListState();
}

class PocketListState extends State<PocketListWidget> {
  final _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true;     //true: 아직 화면이 사라지기 전

  late SwiperController controller;
  List<Pock03> _pktList = [];     //포켓리스트
  int pageIdx = 0;

  String stkName = '';
  String stkCode = '';
  Color statColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PocketListPage.TAG_NAME);
    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      DLog.d(PocketListPage.TAG, "delayed user id : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.POCK03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('나의 종목 포켓', style: TStyle.commonTitle,),
          automaticallyImplyLeading: false,
          elevation: 1.5,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.black,
              onPressed: () => Navigator.of(context).pop(null),),
            const SizedBox(width: 10.0,),
          ],
        ),

        body: SafeArea(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _pktList.length,
              itemBuilder: (context, index) {
                return TilePocketLst(_pktList[index]);
              }),
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [

              Expanded(
                flex: 3,
                child: InkWell(
                  child: Container(
                    height: 47,
                    margin: const EdgeInsets.only(right: 10.0),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/rassibs_pk_icon_ae_g1.png',
                          color: Colors.white, height: 20,),
                        const SizedBox(width: 10,),
                        const Text('설정', style: TStyle.btnTextWht17,),
                      ],
                    ),
                  ),
                  onTap: (){
                    // basePageState.callPageRouteUP(PocketSettingPage());
                    _navigateRefresh(context, PocketSettingPage.routeName);
                  },
                ),
              ),
              Expanded(
                flex: 4,
                child: InkWell(
                  child: Container(
                    height: 47,
                    decoration: const BoxDecoration(
                      color: RColor.sigBuy,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/rassibs_pk_icon_ae_g2.png',
                          color: Colors.white, height: 20,),
                        const SizedBox(width: 10,),
                        const Text('포켓수 늘리기', style: TStyle.btnTextWht17,),
                      ],
                    ),
                  ),
                  onTap: (){
                    if(_appGlobal.isPremium) {
                      _showPocketAdd();
                    } else {
                      basePageState.callPageRouteUP(
                        Platform.isIOS
                            ? PayPremiumPage()
                            : PayPremiumAosPage());
                    }

                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            borderRadius: BorderRadius.circular(15.0),),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: const Icon(Icons.close, color: Colors.black,),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('images/rassibs_img_infomation.png',
                  height: 60, fit: BoxFit.contain,),
                const SizedBox(height: 15.0,),
                const Text('알림', style: TStyle.commonTitle,),
                const SizedBox(height: 25.0,),
                const Text('종목 포켓을 추가로 만드시겠어요?', style: TStyle.commonTitle,),
                const SizedBox(height: 10.0,),
                const Text('생성 후에는 설정을 통해 노출 순서 변경과\n종목 표켓 이름 등을 변경하실 수 있습니다.',
                  style: TStyle.contentMGrey,),
                const SizedBox(height: 25.0,),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text('만들기', style: TStyle.btnTextWht16,),),
                    ),
                  ),
                  onPressed: (){
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

  _navigateRefresh(BuildContext context, String routeName) async {
    final result = await Navigator.pushNamed(context, routeName);
    if(result == 'cancel') {
      DLog.d(PocketListPage.TAG, '*** ***');
    } else {
      DLog.d(PocketListPage.TAG, '*** navigateRefresh');

      _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
        'userId': _userId,
        'selectCount': '10',
      }));
    }
  }

  //포켓 생성 등록(POCK01)
  requestGenPocket() {
    DLog.d(PocketListPage.TAG, '포켓생성');
    _fetchPosts(TR.POCK01, jsonEncode(<String, String> {
      'userId': _userId,
      'crudType': 'C',
      'pocketSn': '',
      'pocketName': '',
    }));
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
                  child: Icon(Icons.close, color: Colors.black,),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 5.0,),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text('안내', style: TStyle.commonTitle,),
                  ),
                  const SizedBox(height: 25.0,),
                  const Text(RString.err_network, textAlign: TextAlign.center,),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text('확인', style: TStyle.btnTextWht16,),),
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PocketListPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(PocketListPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(PocketListPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // parse
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PocketListPage.TAG, response.body);

    if(trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _pktList = resData.listData;

        setState(() {});
      }
    }

    //포켓 생성 등록
    else if(trStr == TR.POCK01) {
      final TrPock01 resData = TrPock01.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        commonShowToast('포켓이 생성되었습니다.');

        _fetchPosts(TR.POCK03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
      else if(resData.retCode == '8007') {
        commonShowToast('생성 가능한 포켓 갯수를 초과했습니다.');
      }
    }
  }

}