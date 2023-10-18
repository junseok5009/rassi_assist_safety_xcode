import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/rq_stock_order.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock04.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.03.22
/// 포켓 종목 순서변경 페이지
class PocketStkSeqPage extends StatelessWidget {
  static const routeName = '/page_pocket_stk_seq';
  static const String TAG = "[PocketStkSeqPage]";
  static const String TAG_NAME = '나의_종목_설정';

  const PocketStkSeqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: PocketStkSeqWidget(),
      ),
    );
  }
}

class PocketStkSeqWidget extends StatefulWidget {
  const PocketStkSeqWidget({super.key});

  @override
  State<StatefulWidget> createState() => PocketStkSeqState();
}

class PocketStkSeqState extends State<PocketStkSeqWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  late SwiperController controller;
  List<PStock> _stkList = []; //포켓 종목 리스트
  int pageIdx = 0;

  String _pktSn = '';
  String stkName = '';
  String stkCode = '';
  String pock01Type = '';

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: PocketStkSeqPage.TAG_NAME,
      screenClassOverride: PocketStkSeqPage.TAG_NAME,
    );

    // _setWiseTracker();
    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_userId != '') {
        _fetchPosts(
            TR.POCK04,
            jsonEncode(<String, String>{
              'userId': _userId,
              'pocketSn': _pktSn,
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

  void _popPrePage() {
    _saveListOrder();
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop(null);
    });
  }

  void _saveListOrder() {
    List<SeqStock> seqList = [];
    for (int i = 0; i < _stkList.length; i++) {
      seqList.add(SeqStock(_stkList[i].stockCode, (i + 1).toString()));
    }

    StockOrder order = StockOrder(_userId, _pktSn, seqList);
    if (_userId != '') {
      _fetchPosts(TR.POCK06, jsonEncode(order));
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _pktSn = args.pgSn;

    return Scaffold(
      appBar: _setCustomAppBar(),
      body: SafeArea(
        child: _setReorderableList(),
      ),
    );
  }

  //리스트 순서 변경 리스트
  Widget _setReorderableList() {
    return ReorderableListView(
      children: _stkList.map((item) => _setListItem(item)).toList(),
      onReorder: (int start, int current) {
        //dragging from top to bottom
        if (start < current) {
          int end = current - 1;
          PStock startItem = _stkList[start];
          int i = 0;
          int local = start;
          do {
            _stkList[local] = _stkList[++local];
            i++;
          } while (i < end - start);
          _stkList[end] = startItem;
        }
        //dragging from bottom to top
        else if (start > current) {
          PStock startItem = _stkList[start];
          for (int i = start; i > current; i--) {
            _stkList[i] = _stkList[i - 1];
          }
          _stkList[current] = startItem;
        }
        setState(() {});

        DLog.d(PocketStkSeqPage.TAG, '\n');
        for (int j = 0; j < _stkList.length; j++)
          DLog.d(PocketStkSeqPage.TAG, _stkList[j].toString());
      },
    );
  }

  //리스트 아이템 설정
  Widget _setListItem(PStock item) {
    return Container(
      key: Key('${item.stockCode}'),
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine15(),
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const SizedBox(
                  width: 5.0,
                ),
                Text(
                  item.stockName,
                  style: TStyle.commonTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Text(
                  item.stockCode,
                  style: TStyle.textSGrey,
                ),
              ],
            ),
            Image.asset(
              'images/main_jm_icon_list_awtb.png',
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 타이틀바(AppBar)
  PreferredSizeWidget _setCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                    onPressed: () => _popPrePage()),
                const Text(
                  '종목 순서 변경',
                  style: TStyle.commonTitle,
                ),
                const SizedBox(
                  width: 55.0,
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            toolbarHeight: 50,
            elevation: 1,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Divider(
                height: 1.0,
                color: RColor.lineGrey,
              ),
              Container(
                padding: const EdgeInsets.only(left: 20, top: 15),
                width: double.infinity,
                height: 48,
                child: const Text(
                  '※ 터치 상태에서 상하로 움직여 순서를 변경하실 수 있습니다.',
                  style: TStyle.textMGrey,
                ),
              ),
              // Divider(height: 1.0, color: RColor.lineGrey,),
            ],
          ),
        ],
      ),
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PocketStkSeqPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    _parseTrData(trStr, response);
  }

  // parse
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PocketStkSeqPage.TAG, response.body);

    if (trStr == TR.POCK04) {
      final TrPock04 resData = TrPock04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final retData = resData.retData;
        if(retData != null) {
          _stkList = retData.stkList;
          setState(() {});
        }
      }
    }
  }
}
