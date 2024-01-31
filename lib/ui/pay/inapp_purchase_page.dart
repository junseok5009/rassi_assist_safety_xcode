import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/tr_inapp01.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.12.21
/// 결제 TEST 페이지 (flutter_inapp_purchase)
class InAppPurchase extends StatelessWidget {
  static const routeName = '/page_in_app_purchase';
  static const String TAG = "[FlutterPurchaseTest] ";

  const InAppPurchase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: const InAppWidget(),
    );
  }
}

class InAppWidget extends StatefulWidget {
  const InAppWidget({super.key});

  @override
  State<StatefulWidget> createState() => _InAppState();
}

class _InAppState extends State<InAppWidget> {
  late SharedPreferences _prefs;
  String _userId = "";

  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _connectionSubscription;

  final List<String> _productLists = Platform.isAndroid
      ? [
          'ac_s3.a01',
          'ac_pr.a01',
          'ac_pr.m01',
        ]
      : [
          'ios.ac_s3.a01',
          'ios.ac_pr.a01',
          'ios.ac_pr.m01',
        ];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  //IAPItem _pdItem;

  String _selectAmt = '';
  String _selectCurrency = '';
  String _purchasedTrId = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      debugPrint("delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.USER04,
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
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription?.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription?.cancel();
      _purchaseErrorSubscription = null;
    }
    if (_connectionSubscription != null) {
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
    }
    super.dispose();
  }

  //결제 동작은 비동기적으로 구동되어서 초기화 작업이 필요
  Future<void> initPlatformState() async {
    String platformVersion = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    /*try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }*/

    // prepare
    var result = await FlutterInappPurchase.instance.initialize();
    debugPrint('result: $result');

    //비동기 상태에서 연결이 느릴 경우 setState 호출 전에 리턴
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    //연결 정보 리스너
    _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      commonShowToast('connected');
      debugPrint('[connected]: $connected');
      //TODO 앱스토어 연결/해제 테스트
    });

    //구매 업데이트 리스너
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((purchasedItem) {
      commonShowToast('purchase-updated ${purchasedItem?.transactionId}');
      debugPrint('[purchase-updated]: $purchasedItem');

      if (purchasedItem != null) {
        setState(() {
          _purchases.add(purchasedItem);
          _purchasedTrId = purchasedItem.transactionId!;
        });
      }
    });

    //에러 리스트
    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      commonShowToast('purchase-error');
      debugPrint('[purchase-error]: $purchaseError');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 20;
    double buttonWidth = (screenWidth / 3) - 20;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '결제 테스트',
          style: TStyle.commonTitle,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.8,
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Running on: $_platformVersion\n',
                  style: const TextStyle(fontSize: 18.0),
                ),

                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        //연결 초기화 버튼
                        Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: const EdgeInsets.all(7.0),
                          child: MaterialButton(
                            color: Colors.amber,
                            padding: const EdgeInsets.all(0.0),
                            onPressed: () async {
                              debugPrint("---------- Connect Billing Button Pressed");
                              await FlutterInappPurchase.instance.initialize();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              alignment: const Alignment(0.0, 0.0),
                              child: const Text(
                                'Connect Billing',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //연결 종료 버튼
                        Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: const EdgeInsets.all(7.0),
                          child: MaterialButton(
                            color: Colors.amber,
                            padding: const EdgeInsets.all(0.0),
                            onPressed: () async {
                              debugPrint("---------- End Connection Button Pressed");
                              await FlutterInappPurchase.instance.finalize();
                              if (_purchaseUpdatedSubscription != null) {
                                _purchaseUpdatedSubscription?.cancel();
                                _purchaseUpdatedSubscription = null;
                              }
                              if (_purchaseErrorSubscription != null) {
                                _purchaseErrorSubscription?.cancel();
                                _purchaseErrorSubscription = null;
                              }
                              setState(() {
                                _items = [];
                                _purchases = [];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              alignment: const Alignment(0.0, 0.0),
                              child: const Text(
                                'End Connection',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                      //상품정보 가져오기 버튼
                      Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: const EdgeInsets.all(7.0),
                          child: MaterialButton(
                            color: Colors.green,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              alignment: const Alignment(0.0, 0.0),
                              child: const Text(
                                'Get Items',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            onPressed: () {
                              debugPrint("---------- Get Items Button Pressed");
                              _getProduct();
                            },
                          )),

                      //가용 구매 가져오기 버튼
                      Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: const EdgeInsets.all(7.0),
                          child: MaterialButton(
                            color: Colors.green,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              alignment: const Alignment(0.0, 0.0),
                              child: const Text(
                                'Get Purchases',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            onPressed: () {
                              debugPrint("---------- Get Purchases Button Pressed");
                              _getPurchases();
                            },
                          )),

                      //구매 내역 가져오기 버튼
                      Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: const EdgeInsets.all(7.0),
                          child: MaterialButton(
                            color: Colors.green,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              alignment: const Alignment(0.0, 0.0),
                              child: const Text(
                                'Get Purchase History',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            onPressed: () {
                              debugPrint("---------- Get Purchase History Button Pressed");
                              _getPurchaseHistory();
                            },
                          )),
                    ]),
                  ],
                ),

                //상품정보 표시
                Column(
                  children: _renderInApps(),
                ),

                //가용 구매 or 구매 내역 표시
                Column(
                  children: _renderPurchases(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //상품정보 가져오기
  Future _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      debugPrint(item.toString());
      _items.add(item);
    }

    setState(() {
      _items = items;
      _purchases = [];
    });
  }

  //가용 구매 가져오기 ???
  Future _getPurchases() async {
    List<PurchasedItem>? items = await FlutterInappPurchase.instance.getAvailablePurchases();
    DLog.d(InAppPurchase.TAG, '\nListSize : ${items?.length}\n');
    for (var item in items!) {
      // print('${item.toString()}');
      // DLog.d(InAppPurchase.TAG,
      //     '==================================================================');
      if (item.transactionStateIOS == TransactionState.purchased) {
        DLog.d(
            InAppPurchase.TAG,
            '\n${item.productId}\n'
            '${item.transactionDate}\n'
            '${item.transactionId}\n'
            '${item.originalTransactionIdentifierIOS}\n'
            '${item.transactionStateIOS}\n');
      }
      if (item.transactionStateIOS == TransactionState.restored) {
        DLog.d(
            InAppPurchase.TAG,
            '\n${item.productId}\n'
                '${item.transactionDate}\n'
                '${item.transactionId}\n'
                '${item.originalTransactionIdentifierIOS}\n'
                '${item.transactionStateIOS}\n');
      }
      _purchases.add(item);
    }

    setState(() {
      _items = [];
      _purchases = items;
    });
  }

  //구매 내역 가져오기
  Future _getPurchaseHistory() async {
    List<PurchasedItem>? items = await FlutterInappPurchase.instance.getPurchaseHistory();
    DLog.d(InAppPurchase.TAG, '\nListSize : ${items?.length}\n');
    for (var item in items!) {
      // print('${item.toString()}');
      DLog.d(
          InAppPurchase.TAG,
          '\n${item.productId}\n${item.transactionId}\n'
          '${item.transactionDate}\n${item.originalTransactionIdentifierIOS}\n'
          '${item.transactionStateIOS}\n');
      _purchases.add(item);
    }

    setState(() {
      _items = [];
      _purchases = items;
    });
  }

  //상품정보 표시
  List<Widget> _renderInApps() {
    List<Widget> widgets = _items
        .map((item) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: Colors.orange,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 48.0,
                            alignment: const Alignment(-1.0, 0.0),
                            child: const Text('Buy Item'),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      debugPrint("---------- Buy Item Button Pressed");
                      setState(() {
                        _selectAmt = item.price!;
                        _selectCurrency = item.currency!;
                      });
                      _requestPurchase(item);
                    },
                  ),
                ],
              ),
            ))
        .toList();

    return widgets;
  }

  //가용 구매 or 구매 내역 표시
  List<Widget> _renderPurchases() {
    List<Widget> widgets = _purchases
        .map((item) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Column(
                      children: [
                        Text(
                          // item.toString(),
                          '${item.productId} | ${item.transactionId} | '
                          '${item.transactionDate} | ${item.transactionStateIOS}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
                        Row(
                          children: [
                            MaterialButton(
                              color: Colors.green,
                              child: Container(
                                height: 35.0,
                                alignment: Alignment.center,
                                child: const Text('InApp01'),
                              ),
                              onPressed: () {
                                requestInApp01(item);
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            MaterialButton(
                              color: Colors.orange,
                              child: Container(
                                height: 35.0,
                                alignment: Alignment.center,
                                child: const Text('finishTr'),
                              ),
                              onPressed: () {
                                debugPrint("---------- finish Button Pressed");
                                _finishTransaction(item);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
        .toList();

    return widgets;
  }

  //상품 구매 요청
  void _requestPurchase(IAPItem item) {
    DLog.d(InAppPurchase.TAG, '# 상품구매요청 -> ${item.productId}');
    FlutterInappPurchase.instance.requestPurchase(item.productId!);
  }

  //finish transaction (failed / purchased / restored 상태는 finishTransaction 호출)
  void _finishTransaction(PurchasedItem purchasedItem) {
    DLog.d(InAppPurchase.TAG, '# finishTransaction -> ${purchasedItem.productId} | ${purchasedItem.transactionId}');
    FlutterInappPurchase.instance.finishTransactionIOS(purchasedItem.transactionId!);
  }

  //영수증 검증 요청
  void requestInApp01(PurchasedItem purchasedItem) {
    DLog.d(InAppPurchase.TAG, '# requestInApp01 -> ${purchasedItem.productId} | ${purchasedItem.transactionId}');

    _fetchPosts(
        TR.INAPP01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'svcDiv': Const.isDebuggable ? 'T' : 'S',
          'paymentAmt': _selectAmt,
          'currency': _selectCurrency,
          'productId': purchasedItem.productId ?? '',
          'orgOrderId': purchasedItem.originalTransactionIdentifierIOS ?? '',
          'orderId': purchasedItem.transactionId ?? '',
          'purchaseToken': purchasedItem.transactionReceipt ?? '',
          'inappMsg': 'ios_purchase_msg',
        }));
  }

  // 언제 사용되는 메소드 인지 알수 없음
  // void checkForAppStoreInitiatedProducts() async {
  //   List<IAPItem> appStoreProducts = await FlutterInappPurchase.getAppStoreInitiatedProducts(); // Get list of products
  //   if (appStoreProducts.length > 0) {
  //     _requestPurchase(appStoreProducts.last); // Buy last product in the list
  //   }
  // }

  // 다이얼로그
  void _showDialogMsg(String message, String btnText) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    message,
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
                        // margin: const EdgeInsets.only(top: 20.0),
                        decoration: const BoxDecoration(
                          color: RColor.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Center(
                          child: Text(
                            btnText,
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

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    debugPrint('$trStr $json');

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
    debugPrint(response.body);

    if (trStr == TR.USER04) {
    } else if (trStr == TR.INAPP01) {
      final TrInApp01 resData = TrInApp01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //결제 완료
        if (_purchases.length > 0 && _purchases[0].transactionId == _purchasedTrId) {
          _finishTransaction(_purchases[0]);
          _showDialogMsg('결제가 완료 되었습니다.', '확인');
        }
      } else {
        //결제 승인 실패
        _showDialogMsg('결제 영수증 검증이 실패했습니다.\n잠시후 다시 시도해주세요.\n${resData.retMsg}', '확인');
      }
    }
  }
}
