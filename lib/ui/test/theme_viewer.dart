import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_info.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme04.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/theme_search.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2022.01.11
/// (종목)테마 상세보기 (사용안함)
class ThemeViewer extends StatelessWidget {
  static const routeName = '/page_theme';
  static const String TAG = "[ThemeViewer] ";
  static const String TAG_NAME = '테마상세보기';

  const ThemeViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),
      body: const ThemeWidget(),
    );
  }
}

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<StatefulWidget> createState() => ThemeState();
}

class ThemeState extends State<ThemeWidget> {
  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _themeCode = '';
  String _themeName = '';
  String _themeCount = '';
  bool _bNewSignal = false;

  List<StockInfo> _relayList = [];
  final List<CountFlag> _listSigStatus = [];  //새로운 매매 알림 롤링
  final List<StockInfo> _newBuyList = [];
  final List<StockInfo> _newSellList = [];


  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView( ThemeViewer.TAG_NAME);
    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 300), (){
      DLog.d(ThemeViewer.TAG, "delayed user id : $_userId");
      DLog.d(ThemeViewer.TAG, "delayed theme code: $_themeCode");

      if(_userId != '') {
        _fetchPosts(TR.THEME04,
            jsonEncode(<String, String>{
              'userId': _userId,
              'themeCode': _themeCode,
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
    _themeCode = args.pgSn;

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
            icon: Icon(Icons.search),
            color: Colors.white,
            iconSize: 30,
            onPressed: () => basePageState.replacePageRouteUpData(
                ThemeSearch(), PgData(pgSn: '')),
          ),
          const SizedBox(width: 3,),

          IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            iconSize: 30,
            onPressed: () => Navigator.of(context).pop(null),),
          const SizedBox(width: 10.0,),
        ],
      ),

      body: SafeArea(
        child: ListView(
          children: [
            _setHeaderInfo(),

            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: _relayList.length,
              itemBuilder: (context, index){
                return TileTheme04.gen(_relayList[index], appGlobal.isPremium);
              },
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget _setHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15,),
          color: RColor.bgBlueCatch,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text('  $_themeName  ', style: TStyle.btnTextWht15,),
                backgroundColor: RColor.sigWatching,
              ),
              const SizedBox(height: 20.0,),
              Text('$_themeName 테마와 관련주를 확인해 보세요.', style: TStyle.btnContentWht16,),
              const SizedBox(height: 25.0,),
            ],
          ),
        ),

        // 새로운 매매 종목 알림
        Visibility(
          visible: _bNewSignal,
          child: _setNewStock(),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _setSubTitle("주요 관련주",),
            Text('(총 $_themeCount종목)', style: TStyle.textSGrey,),
          ],
        ),
        const SizedBox(height: 5.0,),
      ],
    );
  }

  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 5),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  // 오늘 새로운 매수/매도 알림 영역
  Widget _setNewStock() {
    return Stack(
      children: [
        //배경 Color
        Container(
          width: double.infinity,
          height: 50,
          color: RColor.bgBlueCatch,
        ),

        Column(
          children: [
            const SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 90,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: UIStyle.roundBtnBox25(),
              child: Swiper(
                  loop: true,
                  autoplay: _listSigStatus != null && _listSigStatus.length < 2 ? false : true,
                  autoplayDelay: 4000,
                  itemCount: _listSigStatus != null ? _listSigStatus.length : 0,
                  itemBuilder: (BuildContext context, int index){
                    return _setTileSigString(_listSigStatus[index]);
                  }
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ],
    );
  }

  // 오늘 새로운 알림 롤링
  Widget _setTileSigString(CountFlag item) {
    String preStr = '';
    if(item.flag == 'B') {
      preStr = '매수';
    } else if(item.flag == 'S'){
      preStr = '매도';
    }

    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('오늘 새로운  ', style: TStyle.btnContentWht16,),
          Text(' $preStr ',
            style: const TextStyle(color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700, /*backgroundColor: stColor*/),
          ),
          const Text('  종목이 ', style: TStyle.btnContentWht16,),
          Text('${item.count}개', style: TStyle.btnTextWht17,),
          const Text(' 있습니다.', style: TStyle.btnContentWht16,),
        ],
      ),
      onTap: (){
        if(item.flag == 'B' && _newBuyList.length > 0) {
          _showDialogNewList('B');
        }
        if(item.flag == 'S' && _newSellList.length > 0) {
          _showDialogNewList('S');
        }
      },
    );
  }

  // 오늘 발생한 신규 매매 리스트 팝업
  void _showDialogNewList(String bsType) {
    String strDiv = '';
    if(bsType == 'B') {
      strDiv = '매수';
    } else {
      strDiv = '매도';
    }

    // var widgetList = <Widget>[];
    // if(bsType == 'B') {
    //   for(int i=0; i < _newBuyList.length; i++) {
    //     widgetList.add(TileStockInfo(_newBuyList[i], false));
    //   }
    // }

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
                  child: Icon(Icons.close, color: Colors.black,),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: Container(
              height: 350,
              child: Column(
                children: [
                  Text('새로운 $strDiv 신호 발생 종목', style: TStyle.title19T, textAlign: TextAlign.center,),
                  const SizedBox(height: 10,),
                  Container(
                    width: double.maxFinite,
                    height: 300,
                    child:
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: bsType == 'B' ? _newBuyList.length : _newSellList.length,
                      itemBuilder: (BuildContext context, int index){
                        if(bsType == 'B') {
                          return TileStockInfo(_newBuyList[index], appGlobal.isPremium);
                        } else {
                          return TileStockInfo(_newSellList[index], appGlobal.isPremium);
                        }
                      },
                    ),

                    // SingleChildScrollView(
                    //   child: Column(
                    //     children: widgetList,
                    //   ),
                    // ),
                  )
                ],
              ),
            ),
          );
        }
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
                    child: Text('안내', style: TStyle.commonTitle,),
                  ),
                  const SizedBox(height: 25.0,),
                  Text(RString.err_network, textAlign: TextAlign.center,),
                  const SizedBox(height: 30.0,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: Center(
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
    DLog.d(ThemeViewer.TAG, trStr + ' ' +json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(ThemeViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(ThemeViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeViewer.TAG, response.body);

    if(trStr == TR.THEME04) {
      final TrTheme04 resData = TrTheme04.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        DLog.d(ThemeViewer.TAG, resData.retData.totalCount);
        _themeName = resData.retData.themeName;
        _themeCount = resData.retData.totalCount;
        _relayList = resData.retData.listData;
        setState(() {});

        _setNewDataList(_relayList);
      }
    }
  }

  //오늘 발생한 신규 매매 리스트
  void _setNewDataList(List<StockInfo> tList) async {
    for(int i=0; i < tList.length; i++) {
      if(tList[i].flag == 'B') _newBuyList.add(tList[i]);
      if(tList[i].flag == 'S') _newSellList.add(tList[i]);
    }

    if(_newBuyList.length > 0) _listSigStatus.add(CountFlag('B', '${_newBuyList.length}'));
    if(_newSellList.length > 0) _listSigStatus.add(CountFlag('S', '${_newSellList.length}'));
    if(_listSigStatus.length > 0) _bNewSignal = true;

    setState(() {});
  }
}


class CountFlag {
  final String flag;
  final String count;
  CountFlag(this.flag, this.count);
}

