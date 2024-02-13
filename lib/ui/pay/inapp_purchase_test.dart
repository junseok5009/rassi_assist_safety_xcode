import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/ui/pay/consumable_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/const.dart';
import '../../common/net.dart';
import '../../models/none_tr/app_global.dart';
import '../../models/tr_user/tr_user04.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InAppPurchaseTest());
}

// Auto-consume must be true on iOS.
// To try without auto-consume on another platform, change `true` to `false` here.
final bool _kAutoConsume = Platform.isIOS || true;

const String _kConsumableId = 'consumable';
const String _kUpgradeId = 'upgrade';
const String _kSilverSubscriptionId = 'subscription_silver';
const String _kGoldSubscriptionId = 'subscription_gold';
List<String> _kProductIds = Platform.isAndroid
    ? [
        'ac_s3.a01',
        'ac_pr.a01',
        'ac_pr.m01',
        'ac_pr.am6d0',
        'ac_pr.am6d5', //231000, 330000  (첫결제 미실행시 2가지로 표시됨)
        'ac_pr.mw1e1',
        'ac_pr.ad3',
        'ac_pr.ad4',
        'ac_pr.ad5',
        'ac_pr.at1',
        'ac_pr.at2',
      ]
    : [
        'ios.ac_pr.a01',
        'ios.ac_pr.m01',
        'ios.ac_pr.ad5',
        'ios.ac_pr.ad4',
        'ios.ac_pr.ad3',
        'ios.ac_pr.at1',
        'ios.ac_pr.at2',
      ];
const List<String> _kProductIds_ = <String>[
  _kConsumableId,
  _kUpgradeId,
  _kSilverSubscriptionId,
  _kGoldSubscriptionId,
];


/// 2024.02.01
/// 결제 TEST 페이지 (in_app_purchase 이용한 테스트 : android 상품정보 잘 가져옴)
class InAppPurchaseTest extends StatefulWidget {
  static const routeName = '/test_inapp_purchase';
  static const String TAG = "[InAppPurchaseTest] ";

  const InAppPurchaseTest({super.key});

  @override
  State<InAppPurchaseTest> createState() => _InAppPurchaseState();
}

class _InAppPurchaseState extends State<InAppPurchaseTest> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';
  String _curProd = ''; //현재 사용중인 상품은

  @override
  void initState() {
    DLog.d('Inapp', '=> initState');
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();

    _loadPrefData().then((value) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? appGlobal.userId ?? '';
      _curProd = _prefs.getString(Const.PREFS_CUR_PROD) ?? '';
      if (_userId == '') {
        Navigator.pop(context);
      } else {
        _fetchPosts(
            TR.USER04,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });

    super.initState();
  }

  // 결제 모듈 초기화
  Future<void> initStoreInfo() async {
    DLog.d('Inapp', '=> initStoreInfo');
    final bool isAvailable = await _inAppPurchase.isAvailable();
    DLog.d('Inapp', '#1 isAvailable $isAvailable');
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      DLog.d('Inapp', '#2 Platform.isIOS');
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
      await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      DLog.d('Inapp', '#4 productDetails.isEmpty');
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    DLog.d('Inapp', '#5 ConsumableStore.load');
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    DLog.d('Inapp', '=> dispose');
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DLog.d('Inapp', '=> build');
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildConsumableBox(),
            _buildRestoreButton(),
          ],
        ),
      );
    } else {
      DLog.d('Inapp', '=> => @2');
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      DLog.d('Inapp', '=> => @3');
      stack.add(
        Stack(
          children: const [
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Stack(
          children: stack,
        ),
      ),
    );
  }

  // 연결 체크 타일
  Card _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(
        _isAvailable ? Icons.check : Icons.block,
        color: _isAvailable ? Colors.green : ThemeData.light().colorScheme.error,
      ),
      title: Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(
                color: ThemeData.light().colorScheme.error,
              )),
          subtitle: const Text('Unable to connect to the payments processor. '
              'Has this app been configured correctly? '
              'See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  // 상품리스트 ??
  Card _buildProductList() {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching products...'),
        ),
      );
    }
    if (!_isAvailable) {
      return const Card();
    }
    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text(
            '[${_notFoundIds.join(", ")}] not found',
            style: TextStyle(color: ThemeData.light().colorScheme.error),
          ),
          subtitle: const Text('This app needs special configuration to run. '
              'Please see example/README.md for instructions.')));
    }

    // 이전 구매 코드를 로드하는 것은 단지 데모일 뿐입니다. 이대로 사용하지 마시기 바랍니다.
    // 앱에서 구매 데이터를 신뢰하기 전에 항상 [PurchaseDetails] 개체 내부의 `verificationData`를 사용하여 구매 데이터를 확인해야 합니다.
    // 구매 데이터 검증을 위해 자체 서버를 이용하는 것을 권장합니다.
    final Map<String, PurchaseDetails> purchases =
      Map<String, PurchaseDetails>.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
          title: Text(
            productDetails.title,
          ),
          subtitle: Text(
            productDetails.description,
          ),
          trailing: previousPurchase != null && Platform.isIOS
              ? IconButton(onPressed: () => confirmPriceChange(context), icon: const Icon(Icons.upgrade))
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    late PurchaseParam purchaseParam;

                    if (Platform.isAndroid) {
                    // NOTE: 구독을 구매/업그레이드/다운그레이드하는 경우 다음을 수행하는 것이 좋습니다.
                    // 서버측 영수증 확인을 사용하여 구독의 최신 상태를 확인합니다.
                    // 그에 따라 UI를 업데이트합니다. 표시된 구독 구매 상태
                    // 앱 내부 내용은 정확하지 않을 수 있습니다.
                      final GooglePlayPurchaseDetails? oldSubscription = _getOldSubscription(productDetails, purchases);

                      purchaseParam = GooglePlayPurchaseParam(
                          productDetails: productDetails,
                          changeSubscriptionParam: (oldSubscription != null)
                              ? ChangeSubscriptionParam(
                                  oldPurchaseDetails: oldSubscription,
                                  prorationMode: ProrationMode.immediateWithTimeProration,
                                )
                              : null);
                    } else {
                      purchaseParam = PurchaseParam(
                        productDetails: productDetails,
                      );
                    }

                    if (productDetails.id == _kConsumableId) {
                      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
                    } else {
                      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                    }
                  },
                  child: Text(productDetails.price),
                ),
        );
      },
    ));

    return Card(child: Column(children: <Widget>[productHeader, const Divider()] + productList));
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching consumables...'),
        ),
      );
    }
    if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
      return const Card();
    }
    const ListTile consumableHeader = ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
      child: Column(
        children: <Widget>[
          consumableHeader,
          const Divider(),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: tokens,
          ),
        ],
      ),
    );
  }

  // TODO 구매 복원 버튼??
  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  // TODO 승인된 제품 사용자에게 [서비스제공] 처리
  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // 중요한!! 제품을 배송하기 전에 항상 구매 내역을 확인하십시오.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    try {
      _requestAosInApp01(purchaseDetails);
    } on Exception {
      // _callErrorListeners("Something went wrong");
      // return;
    }

    return Future<bool>.value(false);
  }

  //승인되지 않은 구매 처리
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails); //서버승인과정
          if (valid) {
            unawaited(deliverProduct(purchaseDetails));
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        // if (Platform.isAndroid) {
        //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
        //     final InAppPurchaseAndroidPlatformAddition androidAddition =
        //       _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        //     await androidAddition.consumePurchase(purchaseDetails);
        //   }
        // }
        // if (purchaseDetails.pendingCompletePurchase) {
        //   await _inAppPurchase.completePurchase(purchaseDetails);
        // }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    // Android의 가격 변경은 애플리케이션에서 처리되지 않고 대신 Play 스토어에서 처리됩니다.
    // 보다 자세한 내용은 https://developer.android.com/google/play/billing/price-changes
    // Android의 가격 변동에 대한 정보입니다.
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // 이는 단지 구독 업그레이드 또는 다운그레이드를 보여주기 위한 것입니다.
    // 이 방법은 'subscription_silver' 및 'subscription_gold'라는 그룹에 2개의 구독만 있다고 가정합니다.
    // 'subscription_silver' 구독을 'subscription_gold'로 업그레이드할 수 있으며
    // 'subscription_gold' 구독을 'subscription_silver'로 다운그레이드할 수 있습니다.
    // 앱별로 이전 구독 ID를 찾는 로직을 바꾸는 것을 기억하세요.
    // Apple이 내부적으로 처리하므로 이전 구독은 Android에서만 필요합니다.
    // iTunesConnect의 구독 그룹 기능을 사용합니다.
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _kSilverSubscriptionId && purchases[_kGoldSubscriptionId] != null) {
      oldSubscription = purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId && purchases[_kSilverSubscriptionId] != null) {
      oldSubscription = purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }

  //구매확인(구매승인 절차) - 영수증 검증 요청
  void _requestAosInApp01(PurchaseDetails purchaseDetails) {
    DLog.d('INAPP_TEST', '# requestInApp01 -> ${purchaseDetails.toString()}');
    DLog.d('INAPP_TEST',
        '# requestInApp01 ->'
            ' ${purchaseDetails.productID} |'
            ' ${purchaseDetails.purchaseID} |'
            ' ${purchaseDetails.status} |'
            ' ${purchaseDetails.status.name} |'
            ' ${purchaseDetails.error?.message} |'
            ' ${purchaseDetails.pendingCompletePurchase} |'
            ' ${purchaseDetails.transactionDate} |'
            ' ${purchaseDetails.verificationData.localVerificationData} |'
            ' ${purchaseDetails.verificationData.serverVerificationData} |'
            ' ${purchaseDetails.verificationData.source} |'
            // ' _getPaymentAmount : ${_getPaymentAmount(purchaseDetails.productId!)} |'
            // ' ${_getPaymentCurrency(purchaseDetails.productId!)}'
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d('INAPP', '$trStr $json');
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
    DLog.d('INAPP', response.body);

    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        User04 data = resData.retData;
        DLog.d('INAPP', data.accountData.toString());

        if (data.accountData != null) {
          final AccountData accountData = data.accountData;
          accountData.initUserStatus();
          _curProd = accountData.productId;
          // _payMethod = accountData.payMethod;
          if (accountData.prodName == '프리미엄') {
            //이미 프리미엄 계정으로 결제 화면 종료
          }
          else if (accountData.prodCode == 'AC_S3') {
            // if (_payMethod == 'PM50') {
            //   //인앱으로 결제한 경우
            //   // _isUpgradeOn = true;
            //   // _isPaymentSub = true;
            // }
          } else {
            //베이직 계정
          }
        } else {
          //회원정보 가져오지 못함
          AccountData().setFreeUserStatus();
        }
        setState(() {});
      } else {
        AccountData().setFreeUserStatus();
      }
    }
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
