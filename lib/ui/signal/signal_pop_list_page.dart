import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_info.dart';
import 'package:rassi_assist/models/tr_search/tr_search04.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// 2020.11.20
/// 인기 종목 현황
class SignalPopListPage extends StatefulWidget {
  static const routeName = '/page_signal_popular';
  static const String TAG = "[SignalPopListPage]";
  static const String TAG_NAME = '매매신호_인기종목현황';
  const SignalPopListPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SignalPopListPageState();
}

class SignalPopListPageState extends State<SignalPopListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true;     //true: 아직 화면이 사라지기 전

  List<StockInfo> _popularList = [];

  String stkName = "";
  String stkCode = "";
  Color statColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SignalPopListPage.TAG_NAME,);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      DLog.d(SignalPopListPage.TAG, "delayed user id : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.SEARCH04, jsonEncode(<String, String>{
          'userId': _userId,
          'selectDiv': 'S',     //S: 네이버 검색 상위
          'selectCount': '20',
        }));
      }
    });
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '인기 종목 현황',
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _popularList.length,
          itemBuilder: (context, index){
            //TODO Header Tile
            return TileSearch04(_popularList[index]);
          },),
      ),
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
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
    DLog.d(SignalPopListPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(SignalPopListPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(SignalPopListPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalPopListPage.TAG, response.body);

    if(trStr == TR.SEARCH04) {
      final TrSearch04 resData = TrSearch04.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _popularList = resData.retData!.listStock;
        setState(() {});
      }
    }
  }

}