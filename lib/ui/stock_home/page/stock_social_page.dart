import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_sns01.dart';
import 'package:rassi_assist/models/tr_sns02.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.01.22 - JS
/// 종목홈_소셜지수 - 사용하지 않음
class StockSocialPage extends StatefulWidget {
  static const routeName = '/sliver_stock_social';
  static const String TAG = "[StockSocialPage] ";
  static const String TAG_NAME = '종목홈_소셜지수';
  const StockSocialPage({Key? key}) : super(key: key);
  @override
  State<StockSocialPage> createState() => _StockSocialPageState();
}

class _StockSocialPageState extends State<StockSocialPage> {

  final _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String stkName = "";
  String stkCode = "";
  Color statColor = Colors.grey;
  String statSns = 'images/rassibs_cht_img_1_1.png';

  List<Sns02> _sList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockSocialPage.TAG_NAME,
    );
    stkCode = _appGlobal.stkCode;
    stkName = _appGlobal.stkName;
    _loadPrefData().then(
          (_) => {
      requestTrAll(),
        Provider.of<StockInfoProvider>(context, listen: false)
            .postRequest(stkCode),
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Text(
              "소셜지수",
              style: TStyle.commonTitle,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: false,
      ),
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 15.0,
                ),
                _setSubTitle('소셜지수', TStyle.commonTitle),
                _setSocialIndex(),
                const SizedBox(
                  height: 15.0,
                ),
                _setSubTitle('최근 1개월의 소셜지수', TStyle.commonTitle),
                const SizedBox(
                  height: 15.0,
                ),
                _setHeaderLine(),
                _setRecentList(context),
                const SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //소셜지수
  Widget _setSocialIndex() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      padding: const EdgeInsets.only(top: 25),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine17(),
      child: Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('참여도\n낮음'),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Image.asset(
                    statSns,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Text('참여도\n높음'),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              '소셜지수',
              style: TStyle.commonTitle,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              RString.social_index_desc,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xdd555555),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setSubTitle(String subTitle, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  Widget _setHeaderLine() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _setRecentList(BuildContext context) {
    double hgt = 50.0 * _sList.length;

    return Container(
      width: double.infinity,
      height: hgt,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sList.length,
          itemBuilder: (context, index) {
            return TileSns02(_sList[index]);
          }),
    );
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
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

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_bYetDispose) {
      setState(() {
        _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      });
    }
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  requestTrAll() async {
    String jsonSNS01 = jsonEncode(<String, String>{
      'userId': _userId,
      'stockCode': stkCode,
    });
    String jsonSNS02 = jsonEncode(<String, String>{
      'userId': _userId,
      'stockCode': stkCode,
    });

    await Future.wait([
      _fetchPosts(
        TR.SNS01,
        jsonSNS01,
      ),
      _fetchPosts(
        TR.SNS02,
        jsonSNS02,
      ),
    ]);

  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.d(StockSocialPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(StockSocialPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(StockSocialPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

   void _parseTrData(String trStr, final http.Response response) {
     DLog.w(trStr + response.body);

    if (trStr == TR.SNS01) {
      final TrSns01 resData = TrSns01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData == '1') {
          statSns = 'images/rassibs_cht_img_1_1.png';
        } else if (resData.retData == '2') {
          statSns = 'images/rassibs_cht_img_1_2.png';
        } else if (resData.retData == '3') {
          statSns = 'images/rassibs_cht_img_1_3.png';
        } else if (resData.retData == '4') {
          statSns = 'images/rassibs_cht_img_1_4.png';
        }
        setState(() {});
      }

    } else if (trStr == TR.SNS02) {
      final TrSns02 resData = TrSns02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _sList = resData.listData;
        setState(() {});
      }
    }
  }
  
}
