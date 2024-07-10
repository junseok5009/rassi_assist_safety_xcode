import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_search/tr_search02.dart';
import 'package:rassi_assist/models/tr_search/tr_search05.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.11.29
/// 검색 페이지
class SearchPage extends StatefulWidget {
  static const routeName = '/page_search';
  static const String TAG = "[SearchPage]";
  static const String TAG_NAME = '종목검색';

  // [종목 검색 이후 리스트 클릭 시 무슨 행동해야할 지 결정해주는 스트링 값 입니다.]
  static const String addPocketLayer = 'add_pocket_layer'; // 종목 검색 > [포켓에 종목 추가 레이어] 띄울 때 이거 호출해 주세요.
  static const String addSignalLayer = 'add_signal_layer'; // 종목 검색 > [나만의 매도신호에 종목 추가 레이어] 띄울 때 이거 호출해 주세요.
  static const String goStockHome =
      'go_stock_home'; // 종목 검색 > 종목홈으로 이동할때 호출해 주세요. (pocketSn은 SearchPage.goStockHome 으로 호출해 주세요)
  static const String popAndResult =
      'pop_and_result'; // 종목 검색 후, 창 닫으면서 result로 클릭한 종목 (검색한 종목) Stock 넘겨줄 때 이거 호출해 주세요. (pocketSn은 SearchPage.popAndResult 으로 호출해 주세요)

  final String landWhere;
  final String pocketSn; // add_pocket_layer 에서만 필요합니다.

  // 종목 검색 클래스 24.05.03 정의 by HJS
  // landWhere = 위에 네개 String / pocketSn = [add_pocket_layer : 포켓SN, add_signal_layer/go_stock_home/pop_and_result : 빈 값 '']
  const SearchPage({required this.landWhere, required this.pocketSn, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late UserInfoProvider _userInfoProvider;

  late SharedPreferences _prefs;
  String _userId = "";
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int savedTime = 0;
  bool isSearching = false;
  final List<Stock> _listData = []; //검색어 입력하여 검색된 리스트

  bool isMyKeyword = true;
  final List<Stock> _recentMyList = [];
  List<Stock> _recentPopList = [];

  int curPocketIdx = 0; // 들고온 포켓번호 idx
  int selectedIdx = 0; // 나의 종목 추가하기에서 선택한 포켓번호 idx

  bool isHoldingStk = false; //보유종목(true)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SearchPage.TAG_NAME,
    );
    DLog.e('widget.landWhere  : ${widget.landWhere}');
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    _userInfoProvider.addListener(_outPage);
    _loadPrefData().then(
      (_) => {
        requestSearch05('Y'),
      },
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  void dispose() {
    _userInfoProvider.removeListener(_outPage);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // 여기서 결제 창 열고 결제 성공시 화면 나가기
  void _outPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.simpleWithExit(
        context,
        '종목검색',
        Colors.black,
        Colors.white,
        Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              //검색 box
              _setSearchField(),
              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: isSearching
                      ? ListView.builder(
                          physics: const ScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount: _listData.length,
                          itemBuilder: (BuildContext context, index) => _tileSearch(_listData[index]),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _setSubTitle('나의 최근 검색 종목'),
                              _recentMyList.isEmpty
                                  ? Container(
                                      height: 70,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '최근 검색 종목이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: RColor.new_basic_text_color_grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 10,
                                      ),
                                      child: Wrap(
                                        spacing: 30.0,
                                        runSpacing: 14.0,
                                        children: List.generate(
                                          _recentMyList.length,
                                          (index) {
                                            return InkWell(
                                              child: Text(
                                                _recentMyList[index].stockName,
                                                style: TStyle.content15,
                                              ),
                                              onTap: () => _clickSearchListWidget(_recentMyList[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              _setSubTitle('다른 투자자들의 인기 검색 종목'),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Wrap(
                                  spacing: 30.0,
                                  runSpacing: 14.0,
                                  children: List.generate(_recentPopList.length, (index) {
                                    return InkWell(
                                      child: Text(
                                        _recentPopList[index].stockName,
                                        style: TStyle.content15,
                                      ),
                                      onTap: () => _clickSearchListWidget(_recentPopList[index]),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //검색 Box
  Widget _setSearchField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: UIStyle.roundBtnLineBox(RColor.mainColor),
      child: Stack(
        children: [
          TextField(
            decoration: const InputDecoration.collapsed(
              hintText: '종목명(초성, 중간어 지원) / 종목코드 검색',
              hintStyle: TextStyle(
                color: RColor.new_basic_text_color_grey,
                fontSize: 14,
              ),
            ),
            focusNode: _focusNode,
            controller: null,
            onChanged: (text) {
              if (text.length > 1) {
                _handleSubmit(text.toString());
              } else {
                setState(() {
                  isSearching = false;
                });
              }
            },
          ),
          const Positioned(
            right: 1.0,
            child: Icon(
              Icons.search,
              size: 22,
              color: RColor.mainColor,
            ),
          ),
        ],
      ),
    );
  }

  // 검색 입력 처리
  void _handleSubmit(String keyword) {
    DLog.d(SearchPage.TAG, keyword.toString());
    DLog.d(SearchPage.TAG, '${DateTime.now().millisecondsSinceEpoch}');

    int curTime = DateTime.now().millisecondsSinceEpoch;

    if (savedTime == 0) {
      DLog.d(SearchPage.TAG, '검색 초기 실행');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      requestSearch02(keyword);
    } else if (savedTime > 0 && (curTime - savedTime) > 200) {
      DLog.d(SearchPage.TAG, 'TR 을 실행 (충분한 시간 뒤에 호출됨)');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //일단 타이머를 걸어서 메소드 실행.
      _delaySearch(keyword);
    } else {
      DLog.d(SearchPage.TAG, '짧은 시간 전에 호출된 메소드 취소 후 새로운 메소드 호출');
      savedTime = DateTime.now().millisecondsSinceEpoch;
      //짧은 시간 전에 호출된 메소드 취소하고 이번 메소드 실행
      _timer?.cancel();
      requestSearch02(keyword);
    }
  }

  void _delaySearch(String keyword) {
    _timer = Timer(const Duration(milliseconds: 200), () {
      DLog.d(SearchPage.TAG, '지연된 TR 을 실행');
      requestSearch02(keyword);
    });
  }

  void requestSearch02(String keyword) {
    _fetchPosts(
        TR.SEARCH02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'keyword': keyword,
          'selectCount': '30',
        }));
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
      onTap: () => _clickSearchListWidget(item),
    );
  }

  Future<void> _checkAddStockKeyboardVisibility(String stkCode, String stkName) async {
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      if (widget.landWhere == SearchPage.addPocketLayer) {
        _showAddStockLayerAndResult(stkCode, stkName);
      } else if (widget.landWhere == SearchPage.addSignalLayer) {
        _showAddSignalLayerAndResult(stkCode, stkName);
      }
    } else {
      FocusScope.of(context).unfocus(); //키보드 닫기
      Future.delayed(const Duration(milliseconds: 530), () {
        if (widget.landWhere == SearchPage.addPocketLayer) {
          _showAddStockLayerAndResult(stkCode, stkName);
        } else if (widget.landWhere == SearchPage.addSignalLayer) {
          _showAddSignalLayerAndResult(stkCode, stkName);
        }
      });
    }
  }

  _showAddStockLayerAndResult(String stkCode, String stkName) async {
    String result = await CommonLayer.instance.showLayerAddStock(
        context,
        Stock(
          stockName: stkName,
          stockCode: stkCode,
        ),
        widget.pocketSn);

    if (mounted) {
      if (result == CustomNvRouteResult.refresh) {
        Navigator.pop(
          context,
          CustomNvRouteResult.refresh,
        );
      } else if (result == CustomNvRouteResult.cancel) {
        //
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
      } else if (result == CustomNvRouteResult.landPremiumPopup) {
        String result = await CommonPopup.instance.showDialogPremium(context);
        if (result == CustomNvRouteResult.landPremiumPage) {
          basePageState.navigateAndGetResultPayPremiumPage();
        }
      } else {
        CommonPopup.instance.showDialogBasic(context, '알림', result);
      }
    } else {
      //Navigator.pop(context, CustomNvRouteResult(false, CustomNvRouteResult.fail,),);
    }
  }

  _showAddSignalLayerAndResult(String stkCode, String stkName) async {
    String result = await CommonLayer.instance.showLayerAddSignal(
      context,
      Stock(
        stockName: stkName,
        stockCode: stkCode,
      ),
    );
    if (mounted) {
      if (result == CustomNvRouteResult.refresh) {
        Navigator.pop(
          context,
          CustomNvRouteResult.refresh,
        );
      } else if (result == CustomNvRouteResult.cancel) {
        //
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
      } else {
        CommonPopup.instance.showDialogBasic(context, '알림', result);
      }
    }
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      child: Text(
        subTitle,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: RColor.mainColor,
        ),
      ),
    );
  }

  Future<void> _clickSearchListWidget(Stock stock) async {
    // SearchPage.popAndResult 인 경우
    if (widget.landWhere == SearchPage.popAndResult) {
      Navigator.pop(context, stock);
    }
    // SearchPage.goStockHome 인 경우
    else if (widget.landWhere == SearchPage.goStockHome) {
      CustomFirebaseClass.logEvtSearchStock(stock.stockName);
      if (_userId.isNotEmpty) {
        await _fetchPosts(
            TR.SEARCH06,
            jsonEncode(<String, String>{
              'userId': _userId,
              'stockCode': stock.stockCode,
            }));
      }
      if (mounted) {
        Navigator.pop(context);
      }
      basePageState.goStockHomePage(
        stock.stockCode,
        stock.stockName,
        AppGlobal().tabIndex,
      );
    }
    // SearchPage. 레이어 인 경우
    else if (widget.landWhere == SearchPage.addSignalLayer) {
      _checkAddStockKeyboardVisibility(
        stock.stockCode,
        stock.stockName,
      );
    } else if (widget.landWhere == SearchPage.addPocketLayer &&
        widget.pocketSn.isNotEmpty &&
        Provider.of<PocketProvider>(context, listen: false).getPocketListIndexByPocketSn(widget.pocketSn) != -1) {
      _checkAddStockKeyboardVisibility(
        stock.stockCode,
        stock.stockName,
      );
    }
    // 오류
    else {
      Navigator.pop(context);
    }
  }

  //인기 검색 종목
  void requestSearch05(String yn) {
    _fetchPosts(
        TR.SEARCH05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'isMySearch': yn,
          'selectCount': '10',
        }));
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.d(SearchPage.TAG, '$trStr $json');

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
      DLog.d(SearchPage.TAG, 'ERR : TimeoutException (12 seconds)');
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SearchPage.TAG, response.body);

    //인기 검색어
    if (trStr == TR.SEARCH05) {
      final TrSearch05 resData = TrSearch05.fromJson(jsonDecode(response.body));
      //나의 최근 검색 종목
      if (isMyKeyword) {
        _recentMyList.clear();
        if (resData.retCode == RT.SUCCESS) {
          _recentMyList.addAll(resData.listData);
        }
        isMyKeyword = false;
        requestSearch05('N');
      }
      //다른 투자자들의 인기 검색 종목
      else {
        if (resData.retCode == RT.SUCCESS) {
          _recentPopList = resData.listData;
        }
      }
      setState(() {});
      _focusNode.requestFocus();
    }

    //유저 직접 검색
    else if (trStr == TR.SEARCH02) {
      final TrSearch02 resData = TrSearch02.fromJson(jsonDecode(response.body));
      DLog.d(SearchPage.TAG, '-----------------------------------------');
      // DLog.d(SearchPage.TAG, resData.retCode);

      if (resData.retCode == RT.SUCCESS) {
        List<Stock>? list = resData.retData;
        if (list != null && list.isNotEmpty) {
          setState(() {
            _listData.clear();
            _listData.addAll(list);
            isSearching = true;
          });
        } else {
          setState(() {
            _listData.clear();
            isSearching = false;
          });
        }
      } else {
        //오류
        setState(() {
          isSearching = false;
        });
      }
    }
  }
}
