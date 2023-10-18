import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock07.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock08.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_stk_seq_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2020.11.12
/// 포켓 board
class PocketBoard extends StatelessWidget {
  static const routeName = '/page_pocket_board';
  static const String TAG = "[PocketBoard]";
  static const String TAG_NAME = '포켓_보드';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: PocketBoardWidget(),
      ),
    );
  }
}

class PocketBoardWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PocketBoardState();
}

class PocketBoardState extends State<PocketBoardWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true;    //true: 아직 화면이 사라지기 전

  final SwiperController _controller = SwiperController();
  List<Pock03> _pktList = [];     //포켓리스트
  List<PtStock> _stkList = [];    //종목리스트
  late PocketBrief _pktInfo;           //포켓 간략 정보
  bool _bHasStk = false;
  int pageIdx = 0;

  String _pktSn = '';
  String _pktTmp = '';
  String stkName = "";
  String stkCode = "";
  Color statColor = Colors.grey;
  int _rcvPktIndex = 0;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: PocketBoard.TAG_NAME,
      screenClassOverride: PocketBoard.TAG_NAME,);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), (){
      DLog.d(PocketBoard.TAG, "delayed user id : $_userId");
      if(_userId != '') {
        _fetchPosts(TR.POCK07,
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
    _controller.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    DLog.d(PocketBoard.TAG, args.pgSn);
    if(args != null) _pktSn = args.pgSn;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('나의 포켓 종합보드', style: TStyle.commonTitle,),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: false,
          leadingWidth: 20,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Swiper(
          loop: false,
          itemCount: _pktList.length,
          controller: _controller,
          onIndexChanged: (int index){
            DLog.d(PocketBoard.TAG, 'page index : $index');
            pageIdx = index;
            _fetchPosts(TR.POCK08, jsonEncode(<String, String>{
              'userId': _userId,
              'pocketSn': _pktList[index].pocketSn,
            }));
          },
          itemBuilder: (BuildContext context, int index) {
            return ListView.builder(
              itemCount: _stkList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                String pageStr = (pageIdx + 1).toString() + '/' + _pktList.length.toString();
                // if(index == 0) return HeaderBoard(_pktInfo, pageStr);
                if(index == 0) return _setPageHeader(_pktInfo, pageStr);
                else {
                  bool isUserSig = false;
                  if(_stkList[index -1].sellPrice.length > 0)
                    _stkList[index -1].myTradeFlag == 'S' ? isUserSig = true : isUserSig = false;
                  return TileBoardItem(_stkList[index -1], _pktInfo.pocketSn, isUserSig);
                }
              },
            );
          },
          // onTap: (int index) {
          //   DLog.d(PocketBoard.TAG, 'onTap : $index');  //페이지 배경 전체가 클릭됨
          // },
        ),
      ),
    );
  }

  Widget _setPageHeader(PocketBrief item, String pgStr) {
    return Container(
      height: 220,
      child: Column(
        children: [
          _setTopInfo(item, pgStr),
          _setBottomInfo(item),
        ],
      ),
    );
  }

  //포켓명, 포켓상세보기
  Widget _setTopInfo(PocketBrief item, String pageStr) {
    return Container(
      height: 170,
      color: RColor.deepBlue,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Text(item.pocketName, style: TStyle.btnTextWht20,),
          const SizedBox(height: 10,),
          _setRoundBotton('+상세보기', item.pocketSn),
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('images/rassibs_pk_icon_myp_1.png', height: 20,),
                  const SizedBox(width: 5.0,),
                  Text(item.waitCount, style: TStyle.btnTextWht16,),
                  const SizedBox(width: 8.0,),
                  Image.asset('images/rassibs_pk_icon_myp_2.png', height: 20,),
                  const SizedBox(width: 5.0,),
                  Text(item.holdCount, style: TStyle.btnTextWht16,),
                ],
              ),
              Text(pageStr, style: TStyle.btnTextWht16,),
            ],
          ),
        ],
      ),
    );
  }

  //종목추가 / 순서변경
  Widget _setBottomInfo(PocketBrief item,) {
    return Container(
      height: 50,
      child: Column(
        children: [
          Container(
            height: 49.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //종목 추가
                    InkWell(
                      child: Image.asset('images/rassibs_pk_icon_plu.png', height: 25,),
                      onTap: (){      //종목 검색 페이지로 이동
                        _navigateSearchData(context, SearchPage(), PgData(pgSn: item.pocketSn,));
                      },
                    ),
                    const SizedBox(width: 15.0,),
                    //종목 순서변경
                    Visibility(
                      visible: _bHasStk,
                      child: InkWell(
                        child: Image.asset('images/rassibs_pk_icon_awr.png', height: 25,),
                        onTap: (){
                          _pktTmp = item.pocketSn;
                          _navigateDataSeq(context, PocketStkSeqPage(), PgData(pgSn: item.pocketSn,));
                        },
                      ),
                    ),
                  ],
                ),

                const Text('AI매매신호 현황'),    //TODO 아래 리스트와 내용이 같이 변경
              ],
            ),
          ),
          Container(height: 0.7, color: Colors.grey, alignment: Alignment.bottomCenter,),
        ],
      ),
    );
  }

  // +상세보기(포켓)
  Widget _setRoundBotton(String bTitle, String pktSn) {
    return Center(
      child: InkWell(
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: UIStyle.roundBtnStBox(),
          child: Center(child: Text(bTitle, style: TStyle.btnSTextWht,),),
        ),
        onTap: (){    //포켓 상세보기로 이동
          Navigator.of(context).pushReplacementNamed(PocketPage.routeName,
            arguments: PgData(pgSn: pktSn,),);
        },
      ),
    );
  }

  //페이지 리프레시
  _navigateSearchData(BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, UIStyle.createRoute(instance, pgData));
    if(result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    }
    else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
        'userId': _userId,
      }));
    }
  }

  //페이지 리프레시
  _navigateDataSeq(BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, UIStyle.createRoute(instance, pgData));
    if(result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    }
    else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      if(_pktTmp != null && _pktTmp.length > 0) {
        _fetchPosts(TR.POCK08, jsonEncode(<String, String>{
          'userId': _userId,
          'pocketSn': _pktTmp,
        }));
      }
    }
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
                          child: Text('확인',
                            style: TStyle.btnTextWht16,),),
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
    DLog.d(PocketBoard.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if(_bYetDispose) _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.d(PocketBoard.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(PocketBoard.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // parse
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PocketBoard.TAG, response.body);

    if(trStr == TR.POCK07) {
      final TrPock07 resData = TrPock07.fromJson(jsonDecode(response.body));
      DLog.d(PocketBoard.TAG, resData.retData.toString());

      _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
        'userId': _userId,
      }));
    }
    else if(trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _pktList = resData.listData!;

        //TODO 페이지가 열린 후 초기 페이지를 얻어온다.
        if(_pktList != null && _pktList.isNotEmpty) {
          for(int i=0; i < _pktList.length; i++) {
            if(_pktList[i].pocketSn == _pktSn) {
              _rcvPktIndex = i;
            }
          }
        }

        _controller.move(_rcvPktIndex);   //TODO
        if(_pktList.isNotEmpty) {
          _fetchPosts(TR.POCK08, jsonEncode(<String, String>{
            'userId': _userId,
            'pocketSn': _pktList[0].pocketSn,
          }));
        }
      }
    }
    else if(trStr == TR.POCK08) {
      final TrPock08 resData = TrPock08.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        final retData = resData.retData;
        if(retData != null) {
          _pktInfo = retData.pocketBrief!;
          _stkList = retData.stkList;
          if(_stkList != null && _stkList.isNotEmpty) {
            _bHasStk = true;
          } else {
            _bHasStk = false;
          }

          setState(() {});
        }
      }
    }
  }

}