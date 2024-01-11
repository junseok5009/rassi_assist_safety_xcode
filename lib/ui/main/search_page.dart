import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search02.dart';
import 'package:rassi_assist/models/tr_search/tr_search05.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/trade_intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.11.29
/// 검색 페이지
class SearchPage extends StatefulWidget {
  static const routeName = '/page_search';
  static const String TAG = "[SearchPage]";
  static const String TAG_NAME = '종목검색';

  static const String landAddPocketLayer = 'landAddPocketLayer';
  static const String landAddSignalLayer = 'landAddSignalLayer';

  String landWhere = '';
  String pocketSn = '';

  // 종목 검색 > 레이어 띄울 때 이거 호출 해주세요.
  SearchPage.goLayer(this.landWhere, this.pocketSn, {Key? key})
      : super(key: key);

  // 종목 검색 > 종목홈으로 이동할때 호출해주세요.
  SearchPage.goStockHome({Key? key}) : super(key: key);

  //const SearchPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late UserInfoProvider _userInfoProvider;

  late SharedPreferences _prefs;
  String _userId = "";

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
              const SizedBox(
                height: 10,
              ),

              //검색 box
              _setSearchField(),

              const SizedBox(
                height: 10,
              ),

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
                          itemBuilder: (BuildContext context, index) =>
                              _tileSearch(_listData[index]),
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
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: CommonView.setNoDataView(
                                        130,
                                        '최근 검색 종목이 없습니다.',
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
                                              onTap: () {
                                                if (widget.landWhere.isEmpty) {
                                                  Navigator.pop(context);
                                                  basePageState.goStockHomePage(
                                                    _recentMyList[index]
                                                        .stockCode,
                                                    _recentMyList[index]
                                                        .stockName,
                                                    AppGlobal().tabIndex,
                                                  );
                                                } else {
                                                  _checkAddStockKeyboardVisibility(
                                                    _recentMyList[index]
                                                        .stockCode,
                                                    _recentMyList[index]
                                                        .stockName,
                                                  );
                                                }
                                              },
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
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Wrap(
                                  spacing: 30.0,
                                  runSpacing: 14.0,
                                  children: List.generate(_recentPopList.length,
                                      (index) {
                                    return InkWell(
                                      child: Text(
                                        _recentPopList[index].stockName,
                                        style: TStyle.content15,
                                      ),
                                      onTap: () {
                                        if (widget.landWhere.isEmpty) {
                                          Navigator.pop(context);
                                          basePageState.goStockHomePage(
                                            _recentPopList[index].stockCode,
                                            _recentPopList[index].stockName,
                                            AppGlobal().tabIndex,
                                          );
                                        } else {
                                          _checkAddStockKeyboardVisibility(
                                            _recentPopList[index].stockCode,
                                            _recentPopList[index].stockName,
                                          );
                                        }
                                      },
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
                hintText: '종목명(초성, 중간어 지원) / 종목코드 검색'),
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
      onTap: () async {
        if (widget.landWhere.isEmpty) {
          CustomFirebaseClass.logEvtSearchStock(item.stockName);
          if (_userId != null && _userId.isNotEmpty) {
            Navigator.pop(context);
            basePageState.goStockHomePage(
              item.stockCode,
              item.stockName,
              AppGlobal().tabIndex,
            );
          } else {
            //로그인 전 인트로 검색화면
            Navigator.pushNamed(
              context,
              TradeIntroPage.routeName,
              arguments: PgData(
                userId: '',
                stockCode: item.stockCode,
                stockName: item.stockName,
              ),
            );
          }
        } else {
          _checkAddStockKeyboardVisibility(
            item.stockCode,
            item.stockName,
          );
        }

        if (_userId.isNotEmpty) {
          _fetchPosts(
              TR.SEARCH06,
              jsonEncode(<String, String>{
                'userId': _userId,
                'stockCode': item.stockCode,
              }));
        }
      },
    );
  }

  Future<void> _checkAddStockKeyboardVisibility(
      String stkCode, String stkName) async {
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      if (widget.landWhere == SearchPage.landAddPocketLayer) {
        _showAddStockLayerAndResult(stkCode, stkName);
      } else if (widget.landWhere == SearchPage.landAddSignalLayer) {
        _showAddSignalLayerAndResult(stkCode, stkName);
      }
    } else {
      FocusScope.of(context).unfocus(); //키보드 닫기
      Future.delayed(const Duration(milliseconds: 530), () {
        if (widget.landWhere == SearchPage.landAddPocketLayer) {
          _showAddStockLayerAndResult(stkCode, stkName);
        } else if (widget.landWhere == SearchPage.landAddSignalLayer) {
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

    if (context.mounted && result != null) {
      if (result == CustomNvRouteResult.refresh) {
        Navigator.pop(
          context,
          CustomNvRouteResult.refresh,
        );
      } else if (result == CustomNvRouteResult.cancel) {
        //
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(
            context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
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

    if (context.mounted && result != null) {
      if (result == CustomNvRouteResult.refresh) {
        Navigator.pop(
          context,
          CustomNvRouteResult.refresh,
        );
      } else if (result == CustomNvRouteResult.cancel) {
        //
      } else if (result == CustomNvRouteResult.fail) {
        CommonPopup.instance.showDialogBasic(
            context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
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
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
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

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SearchPage.TAG, 'ERR : SocketException');
      CommonPopup.instance.showDialogNetErr(context);
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
