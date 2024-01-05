import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_search/tr_search02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/sub/trade_intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.09.08
/// --- 수정 기록 ---
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// 검색 키보드 (로그인 전 종목 검색에서만 사용)
class KeyboardPage extends StatefulWidget {
  static const routeName = '/page_keyboard';
  static const String TAG = "[KeyboardPage]";
  static const String TAG_NAME = '종목검색_키보드';

  const KeyboardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage> {
  late SharedPreferences _prefs;
  String _userId = "";

  final _searchController = TextEditingController();
  final List<Stock> _listData = [];
  List<String> _searchList = []; //무료 5종목 검색

  late Timer _timer;
  int savedTime = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(KeyboardPage.TAG_NAME,);
    _loadPrefData().then(
      (value) {
        if (_userId != '') {
          _fetchPosts(
            TR.TODAY01,
            jsonEncode(
              <String, String>{
                'userId': _userId,
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId =
        _prefs.getString(Const.PREFS_USER_ID) == null ? AppGlobal().userId : '';
    //무료 5종목 체크
    _searchList = _prefs.getStringList(TStyle.getTodayString()) ?? [];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(context, Colors.white, Colors.black,),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
          const Divider(
            height: 1.0,
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _listData.length,
              itemBuilder: (BuildContext context, index) =>
                  _tileSearch(_listData[index]),
            ),
          )
        ],
      ),
    );
  }

  // 검색어 입력 UI
  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              decoration: const InputDecoration.collapsed(
                  hintText: '종목명(초성, 중간어 지원) / 종목코드 검색'),
              controller: _searchController,
              onChanged: (text) {
                if (text.length > 1) {
                  _handleSubmit(text.toString());
                }
              },
            ),
          ),

          //검색버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12,),
            child: IconButton(
              icon: const Icon(Icons.search),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => null,
            ),
          )
        ],
      ),
    );
  }

  // 검색 입력 처리
  void _handleSubmit(String keyword) {
    DLog.d(KeyboardPage.TAG, keyword.toString());
    DLog.d(KeyboardPage.TAG, '${DateTime.now().millisecondsSinceEpoch}');

    int curTime = DateTime.now().millisecondsSinceEpoch;

    if (savedTime == 0) {
      DLog.d(KeyboardPage.TAG, '검색 초기 실행');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      requestSearch02(keyword);
    } else if (savedTime > 0 && (curTime - savedTime) > 200) {
      DLog.d(KeyboardPage.TAG, 'TR 을 실행 (충분한 시간 뒤에 호출됨)');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //일단 타이머를 걸어서 메소드 실행.
      _delaySearch(keyword);
    } else {
      DLog.d(KeyboardPage.TAG, '짧은 시간 전에 호출된 메소드 취소 후 새로운 메소드 호출');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //짧은 시간 전에 호출된 메소드 취소하고 이번 메소드 실행
      _timer?.cancel();
      requestSearch02(keyword);
    }
  }

  void _delaySearch(String keyword) {
    _timer = Timer(const Duration(milliseconds: 200), () {
      DLog.d(KeyboardPage.TAG, '지연된 TR 을 실행');
      requestSearch02(keyword);
    });
  }

  void requestSearch02(String keyword) {
    _fetchPosts(
        TR.SEARCH02,
        jsonEncode(<String, String>{
          'userId': _userId.isEmpty ? 'RASSI_APP' : _userId,
          'keyword': keyword,
          'selectCount': '30',
        }));
  }

  Widget _tileSearch(Stock item) {
    // DLog.d(KeyboardPage.TAG, '무료5종목 리스트: ${_searchList.toString()}');
    return ListTile(
      title: Text(item.stockName),
      onTap: () {
        if (_searchList.length < 5 ||
            _containListData(_searchList, item.stockCode)) {
          // DLog.d(KeyboardPage.TAG, '무료5종목 열람가능 종목코드-> ${item.stockCode}');
          _searchList.add(item.stockCode);
          _searchController.clear();
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            TradeIntroPage.routeName,
            arguments: PgData(
                userId: _userId,
                stockCode: item.stockCode,
                stockName: item.stockName),
          );
        } else {
          // DLog.d(KeyboardPage.TAG, '무료5종목 열람제한 종목코드-> ${item.stockCode}');
          _showDialogLimit();
        }
      },
    );
  }

  //리스트에서 해당 종목코드 있는지
  bool _containListData(List<String> sList, String newStr) {
    if (sList != null && sList.length > 0) {
      for (int i = 0; i < sList.length; i++) {
        if (sList[i] == newStr) return true;
      }
      return false;
    } else {
      return false;
    }
  }

  //5종목 초과 검색시 알림
  void _showDialogLimit() {
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
                  'images/rassibs_iconimg_01.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '알림',
                  textAlign: TextAlign.center,
                  style: TStyle.title18,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '로그인 전 매매비서 / 매매신호 열람은 하루 5종목까지 무료로 제공됩니다.',
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
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(KeyboardPage.TAG, '$trStr $json');

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
    DLog.d(KeyboardPage.TAG, response.body);

    if (trStr == TR.SEARCH02) {
      final TrSearch02 resData = TrSearch02.fromJson(jsonDecode(response.body));
      DLog.d(KeyboardPage.TAG, resData.retCode);

      if (resData.retCode == RT.SUCCESS) {
        List<Stock> list = resData.retData!;
        setState(() {
          _listData.clear();
          _listData.addAll(list);
        });
      } else {
        //오류
      }
    }
  }
}
