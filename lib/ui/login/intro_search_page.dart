import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search02.dart';
import 'package:rassi_assist/models/tr_search/tr_search03.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/login/login_division_page.dart';
import 'package:rassi_assist/ui/sub/trade_intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.10.14
/// --- 수정 기록 ---
/// 2022.08.03 : 로그인 하지 않은 사용자가 호출하는 전문에는 userId에 'RASSI_APP' 넣어서 호출
/// Intro Search
class IntroSearchPage extends StatefulWidget {
  static const routeName = '/page_intro_search';
  static const String TAG = "[IntroSearchPage]";
  static const String TAG_NAME = '인트로_검색';

  const IntroSearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IntroSearchPageState();
}

class IntroSearchPageState extends State<IntroSearchPage> {

  late SharedPreferences _prefs;

  final List<Search03> _search03StockList = []; // 오늘의 검색 인기 종목
  final List<Stock> _userSearchStockList = []; //검색어 입력하여 검색된 리스트
  final List<String> _searchList = []; //무료 5종목 검색
  String deepLinkData = '';

  Timer? _timer;
  int savedTime = 0;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(IntroSearchPage.TAG_NAME);
    CustomFirebaseClass.setUserProperty(
        CustomFirebaseProperty.LOGIN_STATUS, 'in_intro_search');
    _loadPrefData().then((_) =>
        _fetchPosts(
          TR.SEARCH03,
          jsonEncode(<String, String>{
            'userId': 'RASSI_APP',
            'selectDiv': 'S',
            'selectCount': '5',
          }),
        )
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    //무료 5종목 체크
    _searchList.addAll(_prefs.getStringList(TStyle.getTodayString()) ?? []);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '',
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _setSearchField(),
                    const SizedBox(
                      height: 20,
                    ),
                    _textEditingController.text.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                '오늘의 검색 인기 종목',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              _setPopularStock(),
                            ],
                          )
                        : Expanded(
                            child: _userSearchStockList.isEmpty
                                ? Column(
                                    children: [
                                      CommonView.setNoDataTextView(
                                          100, '검색 결과가 없습니다.'),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const ScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shrinkWrap: true,
                                    itemCount: _userSearchStockList.length,
                                    itemBuilder:
                                        (BuildContext context, index) =>
                                            _tileSearch(
                                                _userSearchStockList[index]),
                                  ),
                          ),
                  ],
                ),
              ),
              Visibility(
                visible: _textEditingController.text.isEmpty,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: UIStyle.boxRoundFullColor25c(
                      RColor.purpleBasic_6565ff,
                    ),
                    child: const Center(
                      child: Text(
                        '1초만에 라씨 매매비서 시작하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, LoginDivisionPage.routeName);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setSearchField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: UIStyle.boxRoundFullColor8c(
        RColor.greyBox_f5f5f5,
      ),
      child: Stack(
        children: [
          TextField(
            decoration:
                const InputDecoration.collapsed(hintText: '종목명/종목코드를 입력하세요.'),
            controller: _textEditingController,
            onChanged: (text) {
              if (text.length > 1) {
                _handleSubmit(text.toString());
              } else {
                setState(() {});
              }
            },
          ),
          Positioned(
            top: 1,
            bottom: 1,
            right: 1.0,
            child: Image.asset(
              'images/icon_search_black.png',
              width: 18,
            ),
          ),
        ],
      ),
    );
  }

  //오늘의 인기 종목
  Widget _setPopularStock() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _search03StockList.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _search03StockList[index].stockName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    _search03StockList[index].stockCode,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              if (_searchList.length < 5 ||
                  _containListData(
                      _searchList, _search03StockList[index].stockCode)) {
                //새로운 종목코드 라면 페이지에 임시 저장
                if (!_containListData(
                    _searchList, _search03StockList[index].stockCode)) {
                  _searchList.add(_search03StockList[index].stockCode);
                  await _prefs.setStringList(TStyle.getTodayString(), _searchList);
                }
                if(mounted){
                  CustomFirebaseClass.logEvtSearchStock(_search03StockList[index].stockName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TradeIntroPage(),
                      settings: RouteSettings(
                        arguments: PgData(
                          userId: '',
                          stockCode: _search03StockList[index].stockCode,
                          stockName: _search03StockList[index].stockName,
                        ),
                      ),
                    ),
                  );
                }
              } else {
                CommonPopup.instance.showDialogBasicConfirm(context, '알림', '로그인 전 매매비서 / 매매신호 열람은 하루 5종목까지 무료로 제공됩니다.');
              }
            },
          );
        });
  }

  //리스트에서 해당 종목코드 있는지
  bool _containListData(List<String> sList, String newStr) {
    if (sList != null && sList.isNotEmpty) {
      for (int i = 0; i < sList.length; i++) {
        if (sList[i] == newStr) return true;
      }
      return false;
    } else {
      return false;
    }
  }

  Widget _tileSearch(Stock item) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 5.0, bottom: 13.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.stockCode,
              overflow: TextOverflow.ellipsis,
              style: TStyle.textGreyDefault,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              width: 8.0,
            ),
            Flexible(
              child: Text(
                item.stockName,
                style: TStyle.content17,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        if (_searchList.length < 5 ||
            _containListData(
                _searchList, item.stockCode)) {
          //새로운 종목코드 라면 페이지에 임시 저장
          if (!_containListData(
              _searchList, item.stockCode)) {
            _searchList.add(item.stockCode);
            await _prefs.setStringList(TStyle.getTodayString(), _searchList);
          }
          if(mounted){
            CustomFirebaseClass.logEvtSearchStock(item.stockName);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TradeIntroPage(),
                settings: RouteSettings(
                  arguments: PgData(
                    userId: 'RASSI_APP',
                    stockCode: item.stockCode,
                    stockName: item.stockName,
                  ),
                ),
              ),
            );
          }
        } else {
          CommonPopup.instance.showDialogBasicConfirm(context, '알림', '로그인 전 매매비서 / 매매신호 열람은 하루 5종목까지 무료로 제공됩니다.');
        }
      },
    );
  }

  // 검색 입력 처리
  void _handleSubmit(String keyword) {
    int curTime = DateTime.now().millisecondsSinceEpoch;
    if (savedTime == 0) {
      savedTime = DateTime.now().millisecondsSinceEpoch;
      _requestSearch02(keyword);
    } else if (savedTime > 0 && (curTime - savedTime) > 200) {
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //일단 타이머를 걸어서 메소드 실행.
      _timer = Timer(const Duration(milliseconds: 200), () {
        _requestSearch02(keyword);
      });
    } else {
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //짧은 시간 전에 호출된 메소드 취소하고 이번 메소드 실행
      _timer?.cancel();
      _requestSearch02(keyword);
    }
  }

  void _requestSearch02(String keyword) {
    _fetchPosts(
        TR.SEARCH02,
        jsonEncode(<String, String>{
          'userId': 'RASSI_APP',
          'keyword': keyword,
          'selectCount': '30',
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IntroSearchPage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(IntroSearchPage.TAG, response.body);

    if (trStr == TR.SEARCH03) {
      _search03StockList.clear();
      TrSearch03 resData = TrSearch03.fromJson(jsonDecode(response.body));
      if (resData.retData!.isNotEmpty) {
        _search03StockList.addAll(resData.retData!);
      }
      setState(() {});
    }

    //유저 직접 검색
    else if (trStr == TR.SEARCH02) {
      final TrSearch02 resData = TrSearch02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        List<Stock> list = resData.retData!;
        if (list != null && list.isNotEmpty) {
          setState(() {
            _userSearchStockList.clear();
            _userSearchStockList.addAll(list);
          });
        } else {
          setState(() {
            _userSearchStockList.clear();
          });
        }
      } else {
        setState(() {
          _userSearchStockList.clear();
        });
      }
    }
  }
}
