import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_kword02.dart';
import 'package:rassi_assist/ui/tiles/tile_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.04.05
/// 키워드 상세 페이지
class KeywordViewer extends StatelessWidget {
  static const routeName = '/page_keyword_detail';
  static const String TAG = "[KeywordViewer]";
  static const String TAG_NAME = '키워드_상세보기';

  const KeywordViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),
      body: const KeywordDetailWidget(),
    );
  }
}

class KeywordDetailWidget extends StatefulWidget {
  const KeywordDetailWidget({super.key});

  @override
  State<StatefulWidget> createState() => KeywordDetailState();
}

class KeywordDetailState extends State<KeywordDetailWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _keyword = '';
  List<Stock> _stkList = [];

  @override
  void initState() {
    super.initState();

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      DLog.d(KeywordViewer.TAG, "delayed user id : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.KWORD02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'keyword': _keyword,
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
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _keyword = args.pgData;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),);
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: RColor.bgBlueCatch,
        shadowColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(null),),
          const SizedBox(width: 10.0,),
        ],
      ),

      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15,),
              color: RColor.bgBlueCatch,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(_keyword, style: TStyle.btnTextWht15,),
                        backgroundColor: RColor.jinbora,
                      ),

                      IconButton(
                        icon: const ImageIcon(
                          AssetImage('images/rassi_icon_qu_bl.png',),
                          size: 22,),
                        color: Colors.white,
                        onPressed: (){
                          _showDialogKeyword();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15.0,),

                  const Text('종목 키워드는 여러가지 사유로 특정 종목들과 함께 언급되는 단어입니다.',
                    style: TStyle.btnContentWht15,),
                  const SizedBox(height: 15.0,),
                ],
              ),
            ),
            const SizedBox(height: 10.0,),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                _setSubTitle("해당 키워드가 언급된 종목들",),
                Text('', style: TStyle.textSGrey,),
              ],
            ),
            const SizedBox(height: 5.0,),
            GridView.count(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2,
              children: List.generate(_stkList.length, (index) =>
                  TileStock(_stkList[index])),
            ),
            const SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }

  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 5),
      child: Text(subTitle, style: TStyle.commonTitle, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
    );
  }

  void _showDialogKeyword() {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),   //전체 margin 동작
          child: Container(
            width: double.infinity,
            // height: 250,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 25.0,),
                  const Text('종목 키워드', style: TStyle.defaultTitle,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  const SizedBox(height: 20.0,),
                  const Text(RString.desc_stock_keyword, style: TStyle.defaultContent,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                    child: Text('안내', style: TStyle.commonTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  ),
                  const SizedBox(height: 25.0,),
                  const Text(RString.err_network, textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,),
                  const SizedBox(height: 30.0,),
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '확인',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                    onTap: () {
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
    DLog.d(KeywordViewer.TAG, trStr + ' ' +json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(KeywordViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(KeywordViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(KeywordViewer.TAG, response.body);

    if(trStr == TR.KWORD02) {
      final TrKWord02 resData = TrKWord02.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        // DLog.d(KeywordViewer.TAG, resData.retData.issueInfo.toString());

        _stkList = resData.retData.listData;
        setState(() {});
      }
    }
  }

}