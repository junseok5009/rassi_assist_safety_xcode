import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock05.dart';
import 'package:rassi_assist/models/tr_search/tr_search02.dart';
import 'package:rassi_assist/models/tr_search/tr_search05.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/sub/trade_intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pay/pay_premium_aos_page.dart';

/// 2020.11.20 검색 페이지
/// 다른 페이지로 넘어갈때 아이디, 종목코드 넘긴다.
/// 2023.09.07 포켓번호 필수 아니게 수정, 포켓 번호 없을때 TR로 포켓번호 가져오기
class SearchPage extends StatefulWidget {
  static const routeName = '/page_search';
  static const String TAG = "[SearchPage]";
  static const String TAG_NAME = '종목검색';

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  String _prodCode = ''; //상품코드

  late Timer _timer;
  int savedTime = 0;
  bool isSearching = false;
  final List<Stock> _listData = []; //검색어 입력하여 검색된 리스트

  String pktSn = '';
  bool isMyKeyword = true;
  final List<Stock> _recentMyList = [];
  List<Stock> _recentPopList = [];

  List<Pock03> _pktList = [];
  int curPocketIdx = 0;
  int selectedIdx = 0;

  String crudPock05 = '';
  bool isHoldingStk = false; //보유종목(true)

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      SearchPage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
            if (args != null) {
              pktSn = args.pgSn;
            }
            if (_userId != '') {
              requestSearch05('Y');
            }
          }),
        });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _prodCode = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            horizontal: 15,
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
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _setSubTitle('나의 최근 검색 종목'),
                            _recentMyList.isEmpty
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: CommonView.setNoDataView(
                                        130, '최근 검색 종목이 없습니다.'))
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
                                              if (pktSn == '') {
                                                Navigator.pop(context);
                                                basePageState.goStockHomePage(
                                                  _recentMyList[index]
                                                      .stockCode,
                                                  _recentMyList[index]
                                                      .stockName,
                                                  Const.STK_INDEX_SIGNAL,
                                                );
                                              } else {
                                                if (_pktList.isNotEmpty) {
                                                  _setModalBottomSheet(
                                                    context,
                                                    _recentMyList[index]
                                                        .stockCode,
                                                    _recentMyList[index]
                                                        .stockName,
                                                  );
                                                }
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
                                      if (pktSn == '') {
                                        Navigator.pop(context);
                                        basePageState.goStockHomePage(
                                          _recentPopList[index].stockCode,
                                          _recentPopList[index].stockName,
                                          Const.STK_INDEX_SIGNAL,
                                        );
                                      } else {
                                        _setModalBottomSheet(
                                          context,
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
      onTap: () {
        if (pktSn == '') {
          CustomFirebaseClass.logEvtSearchStock(item.stockName);
          if (_userId != null && _userId.isNotEmpty) {
            Navigator.pop(context);
            basePageState.goStockHomePage(
              item.stockCode,
              item.stockName,
              Const.STK_INDEX_SIGNAL,
            );
          } else {
            //로그인 전 인트로 검색화면
            Navigator.pushNamed(
              context,
              TradeIntroPage.routeName,
              arguments: PgData(
                  userId: '',
                  stockCode: item.stockCode,
                  stockName: item.stockName),
            );
          }
        } else {
          FocusScope.of(context).unfocus(); //키보드 닫기
          Future.delayed(const Duration(milliseconds: 600), () {
            //포켓에 종목 추가
            _setModalBottomSheet(context, item.stockCode, item.stockName);
          });
        }

        if (_userId.length > 0) {
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

  //포켓에 종목 추가
  void _setModalBottomSheet(context, String stkCode, String stkName) {
    CustomFirebaseClass.logEvtScreenView('포켓_종목추가');

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        SwiperController controller = SwiperController();
        int currentIndex = 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setSubTitle('나의 종목 추가하기'),
                  InkWell(
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Image.asset(
                        'images/main_jm_aw_l_g.png',
                        width: 70.0,
                      ),
                      onPressed: () {
                        //DLog.e('controller.index : ${controller.}');
                        controller.previous(animation: true);
                        //controller.mov
                      },
                  ),
                  Container(
                    width: 220,
                    height: Const.HEIGHT_PKT_ADD_CIRCLE,
                    color: Colors.blue,
                    child: Swiper(
                        onIndexChanged: (idx) {
                          currentIndex = idx;
                        },
                        controller: controller,
                        loop: false,
                        itemCount: _pktList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TilePock03(_pktList[index]);
                        },
                    ),
                  ),
                  IconButton(
                      icon: Image.asset('images/main_jm_aw_r_g.png'),
                      onPressed: () {
                        controller.next(animation: true);
                      },
                  ),
                ],
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: IconButton(
                      icon: Image.asset(
                        'images/main_jm_aw_l_g.png',
                      ),
                      onPressed: () {
                        controller.previous(animation: true);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 180,
                    ),
                    height: Const.HEIGHT_PKT_ADD_CIRCLE,
                    child: Swiper(
                        onIndexChanged: (idx) {
                          currentIndex = idx;
                        },
                        controller: controller,
                        loop: false,
                        itemCount: _pktList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TilePock03(_pktList[index]);
                        }),
                  ),
                  Flexible(
                    child: IconButton(
                      icon: Image.asset('images/main_jm_aw_r_g.png'),
                      onPressed: () {
                        controller.next(animation: true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: RColor.deepBlue)),
                    color: RColor.deepBlue,
                    textColor: Colors.white,
                    child: Text(
                      "관심종목".toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                    onPressed: () {
                      DLog.d(SearchPage.TAG, '현재 인덱스 -> $currentIndex');
                      DLog.d(SearchPage.TAG,
                          '포켓 SN -> ${_pktList[currentIndex].pocketSn}');
                      DLog.d(SearchPage.TAG,
                          '포켓이름 -> ${_pktList[currentIndex].pocketName}');
                      Navigator.pop(context);
                      requestRegPocket(_pktList[selectedIdx].pocketSn, stkName,
                          stkCode, '0');
                    },
                  ),
                  const SizedBox(width: 25),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: RColor.mainColor)),
                    color: RColor.mainColor,
                    textColor: Colors.white,
                    child: Text(
                      "보유종목".toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                    onPressed: () {
                      DLog.d(SearchPage.TAG, '현재 인덱스 -> $currentIndex');
                      DLog.d(SearchPage.TAG, 'ProdCode : $_prodCode');
                      if (_prodCode.contains('ac_pr')) {
                        Navigator.pop(context);
                        _showDialogPrice(
                            _pktList[currentIndex].pocketSn, stkCode, stkName);
                      } else {
                        _showDialogPay(
                            '매수가를 입력하면 AI가 회원님만을 위한 분석을 시작하여 매도가를 제공해 드립니다.'
                            '\n지금 프리미엄으로 업그레이드 해보세요.');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //결제 연결 다이얼로그
  void _showDialogPay(String msg) {
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
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateRefresh(
                        context,
                        Platform.isIOS ? PayPremiumPage() : PayPremiumAosPage(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //종목 매수가 입력
  void _showDialogPrice(String pktSn, String stkCode, String stkName) {
    CustomFirebaseClass.logEvtScreenView('포켓_매수가입력');
    final priceController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setSubTitle('나의 종목 추가하기'),
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.all(15),
                  color: RColor.bgWeakGrey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '매수가 입력',
                        style: TStyle.commonTitle,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        decoration: UIStyle.roundBtnLineBox(RColor.mainColor),
                        child: TextField(
                          decoration: const InputDecoration.collapsed(hintText: '0'),
                          controller: priceController,
                          textAlign: TextAlign.end,
                          // keyboardType: TextInputType.number,  //키보드를 내릴수 없음
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //확인해 주세요
                _setInputDesc(),

                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 40,
                      decoration: UIStyle.roundBtnBox(RColor.deepBlue),
                      child: const Center(
                        child: Text(
                          '매수가 등록하기',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    String price = priceController.text.trim();
                    if (price.length == 0) {
                      commonShowToast('매수가격을 입력해주세요');
                    } else {
                      Navigator.pop(context);
                      requestRegPocket(pktSn, stkName, stkCode, price);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _setInputDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _setSubTitle('! 확인해 주세요'),
        const Text(
          RString.desc_input_buy_prc,
          style: TStyle.contentMGrey,
          // textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _navigateRefresh(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.w('*** navigete cancel ***');
    } else {
      DLog.w('*** navigateRefresh');
      _fetchPosts(
          TR.USER04,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //페이지 이동 에니메이션
  Route _createRoute(Widget instance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
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

  //포켓 종목 등록(POCK05)
  requestRegPocket(
      String pktSn, String stkName, String stkCode, String bPrice) {
    if (bPrice.length > 2) {
      isHoldingStk = true;
    } else {
      isHoldingStk = false;
    }

    crudPock05 = 'C';
    _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'pocketSn': pktSn,
          'crudType': crudPock05,
          'stockCode': stkCode,
          'buyPrice': bPrice,
        }));
    CustomFirebaseClass.logEvtMyPocketAdd(
        SearchPage.TAG_NAME, stkName, stkCode);
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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SearchPage.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
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
        setState(() {});
        requestSearch05('N');
      }
      //다른 투자자들의 인기 검색 종목
      else {
        if (resData.retCode == RT.SUCCESS) {
          _recentPopList = resData.listData;
          setState(() {});
        }
      }
      _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }

    //포켓 리스트
    else if (trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pktList = resData.listData;
        if (pktSn.isEmpty) pktSn = _pktList[0].pocketSn;
        for (int i = 0; i < _pktList.length; i++) {
          if (_pktList[i].pocketSn == pktSn) {
            curPocketIdx = i;
            selectedIdx = i;
          }
        }
        setState(() {});
      }
    }

    //포켓 종목 등록/업데이트
    else if (trStr == TR.POCK05) {
      final TrPock05 resData = TrPock05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (crudPock05 == 'C') {
          if (isHoldingStk) {
            commonShowToast('포켓에 보유종목으로 등록되었습니다.');
          } else {
            commonShowToast('포켓에 관심종목으로 등록되었습니다.');
          }
        } else if (crudPock05 == 'U') {}

        setState(() {});
      } else if (resData.retCode == '8008' || resData.retCode == '8009') {
        //등록가능 종목수 초과
        commonShowToast(resData.retMsg);
        // _showDialogMsg('');
      } else if (resData.retCode == '8010') {
        commonShowToast(resData.retMsg);
      } else if (resData.retCode == '8011') {
        //현재가 대비 -9%
        CommonPopup().showDialogMsg(context, '회원님만을 위한 AI매도신호 제공을 위한\n매수가 입력은 \'현재가 대비 -9%\'이내\n가격에서만 가능합니다.');
      }
    }

    //유저 직접 검색
    else if (trStr == TR.SEARCH02) {
      final TrSearch02 resData = TrSearch02.fromJson(jsonDecode(response.body));
      DLog.d(SearchPage.TAG, '-----------------------------------------');
      // DLog.d(SearchPage.TAG, resData.retCode);

      if (resData.retCode == RT.SUCCESS) {
        List<Stock>? list = resData.retData;

        if (list != null && list.length > 0) {
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
