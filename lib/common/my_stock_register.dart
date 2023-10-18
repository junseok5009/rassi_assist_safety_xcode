import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock05.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';

import '../models/app_global.dart';
import '../provider/stock_home/stock_home_stock_info_provider.dart';
import 'common_class.dart';
import 'ui_style.dart';

// 종목홈에서 사용하는 내 종목 등록 해주는 클래스
// 종목홈이 떠 있는 상황 + 다른 화면에서 즐겨찾기 해제할 시, 종목홈의 종목과 해지한 종목이 같다면 이거 이용해서 해지해야 합니다.
// 언젠간 다른 화면에서도 동시 적용 가능하게 변경 예정
class MyStockRegister {
  static const String TAG = '[MyStockRegister]';

  MyStockRegister({
    required this.buildContext, // 생성자
    this.screenName = '',
  })  : _stockInfoProvider =
            Provider.of<StockInfoProvider>(buildContext, listen: false),
        _userId = AppGlobal().userId; // 초기화 init?

  final BuildContext buildContext;
  final StockInfoProvider _stockInfoProvider;
  final String _userId;
  final String screenName;
  bool _isInterest = true; // 관심 = true, 보유 = false
  final AppGlobal _appGlobal = AppGlobal();

  startLogic() {
    if (_stockInfoProvider.getIsMyStock) {
      //종목 해제
      _showDialogUnReg();
    } else {
      //종목 등록
      _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  _showDialogUnReg() {
    showDialog(
        context: buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  const SizedBox(height: 10,),
                  Text(
                      _stockInfoProvider.getMyTradeFlag == 'W' ?
                          '관심 종목에서 삭제 하시겠습니까?' : _stockInfoProvider.getMyTradeFlag == 'H' ?
                          '보유 종목에서 삭제 하시겠습니까?' :
                      '즐겨찾기를 해제합니다.',
                  ),
                  const SizedBox(height: 10,),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20.0),
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _fetchPosts(
                          TR.POCK05,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                            'pocketSn': _stockInfoProvider.getPockSn,
                            'crudType': 'D',
                            'stockCode': _stockInfoProvider.getStockCode,
                            'buyPrice': '',
                          }));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 관심 종목으로 등록 이후 바텀시트
  _showBottomSheetMyStock() {
    showModalBottomSheet<void>(
      context: buildContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나의 종목 추가하기',
                      style: TStyle.title18T,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  '${TStyle.getPostWord(AppGlobal().stkName, '이', '가')} '
                      '나의 ${_isInterest ? '관심' : '보유'} 종목으로 추가되었습니다.\n'
                      '나의 종목 포켓에서 확인하시겠어요?',
                  style: TStyle.content15,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  child: SizedBox(
                    width: 240,
                    //height: 40,
                    child: Image.asset(
                      'images/rassibs_btn_pk.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if(_appGlobal.isOnPocket) {
                      Navigator.pop(buildContext);
                      _appGlobal.pocketSn = _stockInfoProvider.getPockSn;
                      _appGlobal.pktStockCode = _stockInfoProvider.getStockCode;
                      _appGlobal.pktStockName = _stockInfoProvider.getStockName;
                      _appGlobal.sendPageStatusRefresh('stk_change');
                    } else {
                      Navigator.pop(buildContext);
                      Navigator.of(context).pushNamed(
                        PocketPage.routeName,
                        arguments: PgData(
                          pgSn: _stockInfoProvider.getPockSn,
                          stockCode: _stockInfoProvider.getStockCode,
                          stockName: _stockInfoProvider.getStockName,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //포켓에 종목 추가
  _showBottomSheetAddStock(List<Pock03> vListPock03) {
    CustomFirebaseClass.logEvtScreenView('포켓_종목추가');
    showModalBottomSheet(
      context: buildContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        final SwiperController controller = SwiperController();
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
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Text(
                      '나의 종목 추가하기',
                      style: TStyle.defaultTitle,
                      textScaleFactor: Const.TEXT_SCALE_FACTOR,
                    ),
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pop(bc);
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 15.0,
              ),

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
                    margin: const EdgeInsets.symmetric(horizontal: 20,),
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
                        itemCount: vListPock03.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TilePock03(vListPock03[index]);
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
                height: 20,
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
                      DLog.d(TAG, '현재 인덱스 -> $currentIndex');
                      DLog.d(TAG,
                          '포켓 SN -> ${vListPock03[currentIndex].pocketSn}');
                      DLog.d(TAG,
                          '포켓이름 -> ${vListPock03[currentIndex].pocketName}');
                      Navigator.pop(bc);
                      // 포켓에 종목 등록
                      _isInterest = true;
                      _fetchPosts(
                          TR.POCK05,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                            'pocketSn': vListPock03[currentIndex].pocketSn,
                            'crudType': 'C',
                            'stockCode': _stockInfoProvider.getStockCode,
                            'buyPrice': '0',
                          }));
                      CustomFirebaseClass.logEvtMyPocketAdd(
                          screenName,
                          _stockInfoProvider.getStockName,
                          _stockInfoProvider.getStockCode);
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
                      DLog.d(TAG, '현재 인덱스 -> $currentIndex');
                      if (_appGlobal.isPremium) {
                        Navigator.pop(bc);
                        _showDialogPrice(vListPock03[currentIndex].pocketSn);
                      } else {
                        Navigator.pop(bc);
                        Future.delayed(
                          const Duration(milliseconds: 350),
                          () {
                            _showDialogPay(
                                '매수가를 입력하면 AI가 회원님만을 위한 분석을 시작하여 매도가를 제공해 드립니다.'
                                '\n지금 프리미엄으로 업그레이드 해보세요.');
                          },
                        );
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

  //종목 매수가 입력
  void _showDialogPrice(String pockSn) {
    CustomFirebaseClass.logEvtScreenView('포켓_매수가입력');
    final priceController = TextEditingController();
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Text(
                  '나의 종목 추가하기',
                  style: TStyle.defaultTitle,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
              ),
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: RColor.mainColor,
                            width: 1.0,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7.0)),
                        ),
                        child: TextField(
                          decoration: InputDecoration.collapsed(hintText: '0'),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Text(
                        '! 확인해 주세요',
                        style: TStyle.defaultTitle,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
                      ),
                    ),
                    Text(
                      RString.desc_input_buy_prc,
                      style: TStyle.contentMGrey,
                      // textAlign: TextAlign.center,
                    ),
                  ],
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.deepBlue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
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
                    if (price.isEmpty) {
                      commonShowToast('매수가격을 입력해주세요');
                    } else {
                      Navigator.pop(context);
                      _isInterest = false;
                      _fetchPosts(
                          TR.POCK05,
                          jsonEncode(<String, String>{
                            'userId': _userId,
                            'pocketSn': pockSn,
                            'crudType': 'C',
                            'stockCode': _stockInfoProvider.getStockCode,
                            'buyPrice': price,
                          }));
                      CustomFirebaseClass.logEvtMyPocketAdd(
                          screenName,
                          _stockInfoProvider.getStockName,
                          _stockInfoProvider.getStockCode);
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

  //결제 연결 다이얼로그
  void _showDialogPay(String msg) {
    showDialog(
        context: buildContext,
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
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // if(_prodCode != 'AC_PR')

                      if (StockHomeTab.globalKey.currentState != null) {
                        var tabCurrentState =
                            StockHomeTab.globalKey.currentState;
                        tabCurrentState?.navigateAndGetResultPayPremiumPage();
                      }

                      //navigateAndGetResultPayPremiumPage(); //프리미엄 계정으로 가입
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //알림 다이얼로그
  void _showDialogInfo(String msg) {
    showDialog(
        context: buildContext,
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
        });
  }

  //convert 패키지의 jsonDecode 사용
  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

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
      CommonPopup().showDialogNetErr(buildContext);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(buildContext);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(TAG, response.body);

    if (trStr == TR.POCK05) {
      //포켓 종목 등록/해제
      final TrPock05 resData = TrPock05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (!_stockInfoProvider.getIsMyStock) {
          // 관심 종목에 추가된 종목을 나의 종목 포켓에서 확인하기
          _showBottomSheetMyStock();
        }
        _stockInfoProvider.postRequest(_stockInfoProvider.getStockCode);
      } else if (resData.retCode == '8008') {
        _showDialogPay('베이직 계정에서는 3종목까지 이용이 가능합니다.'
            '\n종목추가와 포켓을 마음껏 이용할 수 있는 프리미엄 계정으로 업그레이드 해보세요.');
      } else if (resData.retCode == '8009') {
        commonShowToast(resData.retMsg);
      } else if (resData.retCode == '8010') {
        commonShowToast(resData.retMsg);
      } else if (resData.retCode == '0225') {
        CommonPopup().showDialogTitleMsgAlignCenter(buildContext, '안내',
            '${_stockInfoProvider.getStockName} 종목은 AI매매신호가 발생되지 않으므로,\n포켓에 등록이 불가합니다.\n\nAI의 정확한 분석을 위한 데이터가 부족한 경우\nAI매매신호가 발생되지 않습니다.\n\n감사합니다.');
      } else if (resData.retCode == '8011') {
        //현재가 대비 -9%
        _showDialogInfo(
            '회원님만을 위한 AI매도신호\n제공을 위한 매수가 입력은\n\'현재가 대비 -9%\'이내 가격에서만\n가능합니다.');
      }
    } else if (trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _showBottomSheetAddStock(resData.listData);
      }
    }
  }
}
