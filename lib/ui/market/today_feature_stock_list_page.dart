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
import 'package:rassi_assist/models/tr_rassi/tr_rassi19.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayFeatureStockListPage extends StatefulWidget {
  const TodayFeatureStockListPage({super.key});

  static const routeName = '/today_feature_stock_list_page';
  static const String TAG = "[TodayFeatureStockListPage]";

  @override
  State<TodayFeatureStockListPage> createState() => _TodayFeatureStockListPageState();
}

class _TodayFeatureStockListPageState extends State<TodayFeatureStockListPage> {
  late SharedPreferences _prefs;
  String _userId = '';

  String _tagName = '';
  String _title = '';
  String _menuDiv = '';

  //1) HIGH/LOW (: WEEK52, LIMIT)
  //2) KOSPI/KOSDAQ (: CHANGE)
  bool _isSelectDivLeft = true;
  int _pageNo = 0;
  int _totalPageSize = 0;

  final List<Rassi19Rassiro> _listData = [];
  final _scrollController = ScrollController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients && _scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          _checkAndRequestTrRassi19();
        }
      }
    });
    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () async {
        _menuDiv = ModalRoute.of(context)?.settings.arguments as String;
        if (_menuDiv == _Rassi19Div.real) {
          _tagName = '시장_특징주';
          _title = '시장 특징주';
        } else if (_menuDiv == _Rassi19Div.week52) {
          _tagName = '신고가_신저가';
          _title = '신고가/신저가';
        } else if (_menuDiv == _Rassi19Div.limit) {
          _tagName = '상한가_하한가';
          _title = '상한가/하한가';
        } else if (_menuDiv == _Rassi19Div.change) {
          _tagName = '손바뀜_종목';
          _title = '손바뀜 종목';
        } else {
          Navigator.pop(context);
        }
        CustomFirebaseClass.logEvtScreenView(_tagName);
        setState(() {});
        _requestTrRassi19();
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(buildContext: context, title: _title, elevation: 1),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: Column(
          children: [
            if(_menuDiv != _Rassi19Div.real) _setDivButtons,
            Expanded(
              child: Stack(
                children: [
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_listData.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CommonView.setNoDataView(170, '$_title의 데이터가 없습니다.'),
                        )
                      else
                        Expanded(
                          child: RefreshIndicator(
                            color: RColor.greyBasic_8c8c8c,
                            backgroundColor: RColor.bgBasic_fdfdfd,
                            strokeWidth: 2.0,
                            displacement: 150,
                            onRefresh: () async {
                              _listData.clear();
                              _pageNo = 0;
                              _totalPageSize = 0;
                              await _requestTrRassi19();
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _menuDiv == _Rassi19Div.real ? _listData.isEmpty ? 0 : _listData.length + 1 : _listData.length,
                              itemBuilder: (context, index) {
                                if (_menuDiv == _Rassi19Div.real) {
                                  if(index == 0){
                                    return _topBoxRealWidget;
                                  }else{
                                    return Rassi19RealItemWidget(
                                      item: _listData[index + 1],
                                    );
                                  }
                                } else if (_menuDiv == _Rassi19Div.week52 || _menuDiv == _Rassi19Div.limit) {
                                  return Rassi19Week52ItemWidget(
                                    item: _listData[index],
                                  );
                                } else if (_menuDiv == _Rassi19Div.change) {
                                  return Rassi19ChangeItemWidget(
                                    item: _listData[index],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                              shrinkWrap: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Visibility(
                    visible: _isLoading,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.withOpacity(0.1),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'images/gif_ios_loading_large.gif',
                        height: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  /// widget

  Widget get _topBoxRealWidget {
    return Container(
      color: RColor.greyBox_f5f5f5,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: const Text('AI가 실시간으로 시장의 뉴스를 모니터링하여 특징주를 찾아줍니다.'),
    );
  }

  Widget get _setDivButtons {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: InkWell(
              child: Container(
                //margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1.4,
                    color: _isSelectDivLeft ? Colors.black : RColor.lineGrey,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(
                      5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _menuDiv == _Rassi19Div.week52
                        ? '52주 신고가'
                        : _menuDiv == _Rassi19Div.limit
                            ? '상한가'
                            : _menuDiv == _Rassi19Div.change
                                ? 'KOSPI'
                                : '',
                    style:
                        _isSelectDivLeft ? TStyle.commonTitle15 : const TextStyle(fontSize: 15, color: RColor.lineGrey),
                  ),
                ),
              ),
              onTap: () {
                if (!_isSelectDivLeft && !_isLoading) {
                  setState(() {
                    _listData.clear();
                    _pageNo = 0;
                    _totalPageSize = 0;
                  });
                  _isSelectDivLeft = true;
                  _requestTrRassi19();
                }
              },
            ),
          ),
          Flexible(
            flex: 1,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1.4,
                    color: _isSelectDivLeft ? RColor.lineGrey : Colors.black,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(
                      5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _menuDiv == _Rassi19Div.week52
                        ? '52주 신저가'
                        : _menuDiv == _Rassi19Div.limit
                            ? '하한가'
                            : _menuDiv == _Rassi19Div.change
                                ? 'KOSDAQ'
                                : '',
                    style: _isSelectDivLeft
                        ? const TextStyle(
                            fontSize: 15,
                            color: RColor.lineGrey,
                          )
                        : TStyle.commonTitle15,
                  ),
                ),
              ),
              onTap: () {
                if (_isSelectDivLeft && !_isLoading) {
                  setState(() {
                    _listData.clear();
                    _pageNo = 0;
                    _totalPageSize = 0;
                  });
                  _isSelectDivLeft = false;
                  _requestTrRassi19();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// function
  /// NetWork
  _requestTrRassi19() {
    String jsonSelectDiv = '';
    if (_menuDiv == _Rassi19Div.week52 || _menuDiv == _Rassi19Div.limit) {
      jsonSelectDiv = _isSelectDivLeft ? 'HIGH' : 'LOW';
    } else if (_menuDiv == _Rassi19Div.change) {
      jsonSelectDiv = _isSelectDivLeft ? 'KOSPI' : 'KOSDAQ';
    }

    _fetchPosts(
      TR.RASSI19,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'menuDiv': _menuDiv,
          if (_menuDiv != _Rassi19Div.real) 'selectDiv': jsonSelectDiv,
          'pageNo': '$_pageNo',
          'pageItemSize': '10',
        },
      ),
    );
  }

  _checkAndRequestTrRassi19() {
    if (_pageNo < _totalPageSize) {
      _requestTrRassi19();
    }
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);
    if(_isLoading){
      return;
    }else{
      setState(() => _isLoading = true,);
    }
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.w(trStr + response.body);

    // NOTE 오늘 날짜로 요청 > 해당 일이 영업일이 아니라면 가장가까운 영업일(과거)부터 과거 20일 동안의 영업일 리턴
    if (trStr == TR.RASSI19) {
      final TrRassi19 resData = TrRassi19.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Rassi19 rassi19 = resData.retData;
        _pageNo++;
        _totalPageSize = int.parse(rassi19.totalPageSize);
        if(_pageNo > 1){
          _listData.removeLast();
        }
        if (rassi19.listRassiro.isNotEmpty) {
          _listData.addAll(
            rassi19.listRassiro,
          );
          if (_pageNo < _totalPageSize) {
            _listData.add(Rassi19Rassiro());
          }
        }
      } else {
        if (_pageNo == 0) {
          _listData.clear();
        }
      }
      setState(() {_isLoading = false;});
    }
  }
}

class _Rassi19Div {
  static const String real = 'REAL'; // 실시간 특징주
  static const String week52 = 'WEEK52'; // 52주 신고가/신저가
  static const String limit = 'LIMIT'; // 당일 상한/하한
  static const String change = 'CHANGE'; // 손바뀜: 거래비중 상위
}
