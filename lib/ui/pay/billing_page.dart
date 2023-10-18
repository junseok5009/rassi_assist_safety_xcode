import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/ui/pay/consumable_store.dart';


/// 2022.04.15 다시
/// 결제 테스트 페이지  TODO 테스트 다시 시작
// https://github.com/flutter/flutter/issues/53534
class BillingPage extends StatelessWidget {
  static const routeName = '/page_billing';
  static const String TAG = "[BillingPage] ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BillingWidget(),
    );
  }
}

class BillingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BillingState();
}

//결제 설정값?? ==============================
const bool _kAutoConsume = true;

//상품에 대한 Id 값
const String _kConsumableId = 'consumable';
const List<String> _kProductIds = <String>[
  'ios.ac_s3.a01',
  'ios.ac_pr.a01',
  'ios.ac_pr.m01',
];
// ========================================

// 1. 구매 업데이트 듣기
// 2. 기본 저장소에 연결
// 3. 판매 제품 로드 중
// 4. 이전 구매 복원
// 5. 구매하기
// 6. 구매 완료
// 7. 기존 인앱 구독 업그레이드 또는 다운그레이드
// 8. 플랫폼별 제품 또는 구매 속성에 액세스
// 9. 코드 교환 시트 제시(iOS 14)

class BillingState extends State<BillingWidget> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError = '';

  @override
  void initState() {
    DLog.d('Inapp', '=> initState');
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        }, onDone: () {
          _subscription.cancel();
        }, onError: (Object error) {
          // handle error here.
        });

    initStoreInfo();
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
      DLog.d('Inapp', '#3 productDetailResponse.error');
      setState(() {
        // _queryProductError = productDetailResponse.error.message;
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
        // _queryProductError = null;
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
    if (_queryProductError.isEmpty) {
      DLog.d('Inapp', '=> => @1');
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
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      DLog.d('Inapp', '=> => @3');
      stack.add(
        Stack(
          children: const <Widget>[
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
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. '
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
              title: Text('Fetching products...')));
    }
    if (!_isAvailable) {
      return const Card();
    }
    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'This app needs special configuration to run. '
                  'Please see example/README.md for instructions.')));
    }

    // 이전 구매 코드를 로드하는 이 코드는 데모일 뿐입니다. 그대로 사용하지 마시기 바랍니다.
    // 앱에서 신뢰하기 전에 항상 [PurchaseDetails] 객체 내부의 `verificationData`를 사용하여 구매 데이터를 확인해야 합니다.
    // 구매 데이터를 확인하기 위해 자체 서버를 사용하는 것을 권장합니다.
    final Map<String, PurchaseDetails> purchases = Map<String, PurchaseDetails>.fromEntries(
        _purchases.map((PurchaseDetails purchase) {
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase);
          }
          return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
        }));
    productList.addAll(_products.map((ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(productDetails.title,),
            subtitle: Text(productDetails.description,),
            trailing: previousPurchase != null
                ? IconButton(onPressed: () => confirmPriceChange(context), icon: const Icon(Icons.upgrade))
                : TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green[800], primary: Colors.white,),
              onPressed: () {
                PurchaseParam purchaseParam;
                // if (Platform.isAndroid) {
                //   // isAndroid
                // } else {
                //   purchaseParam = PurchaseParam(
                //     productDetails: productDetails,
                //     applicationUserName: null,
                //   );
                // }

                purchaseParam = PurchaseParam(
                  productDetails: productDetails,
                  applicationUserName: null,
                );

                if (productDetails.id == _kConsumableId) {
                  _inAppPurchase.buyConsumable(
                      purchaseParam: purchaseParam,
                      autoConsume: _kAutoConsume || Platform.isIOS);
                } else {
                  _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                }
              },
              child: Text(productDetails.price),
            ));
      },
    ));

    return Card(
        child: Column(
            children: <Widget>[productHeader, const Divider()] + productList));
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
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
        child: Column(children: <Widget>[
          consumableHeader,
          const Divider(),
          GridView.count(
            crossAxisCount: 5,
            children: tokens,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
          )
        ]));
  }

  // TODO 구매 복원 버튼??
  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              primary: Colors.white,
            ),
            onPressed: () => showRedemptionSheet(),
            child: const Text('Restore purchases'),
            // onPressed: () => _inAppPurchase.restorePurchases(),
          ),
        ],
      ),
    );
  }

  void showRedemptionSheet() {
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
    _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    iosPlatformAddition.presentCodeRedemptionSheet();
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
      await ConsumableStore.save(purchaseDetails.purchaseID ?? '');
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

  // TODO 구매 상태 리스너
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    DLog.d('Inapp', '===> listenToPurchaseUpdated');
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handleError(purchaseDetails.error);
        }
        //purchased
        else if (purchaseDetails.status == PurchaseStatus.purchased) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        //구매복원
        else if(purchaseDetails.status == PurchaseStatus.restored) {

        }

        // ?????????
        if (purchaseDetails.pendingCompletePurchase) {
          DLog.d('Inapp', '결제 CompletePurchase');
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }

    DLog.d('Inapp', 'listenToPurchaseUpdated ===|');
  }



  // TODO 서버 TR을 통해서 승인 확인하는 과정
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // 중요한!! 제품을 배송하기 전에 항상 구매를 확인하십시오.
    // 예시를 위해 직접 true를 반환합니다.
    return Future<bool>.value(true);
  }

  // 구매 승인 실패
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // verifyPurchase`가 실패한 경우 여기에서 잘못된 구매를 처리합니다.
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
      _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  // 에러 코드 처리
  void handleError(IAPError error) {
    DLog.d('Inapp', error.message);
    setState(() {
      _purchasePending = false;
    });
  }

  // 소비성 상품 ???
  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }
}



// 래퍼
// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
// 결제 대기열 대리자를 구현하여 거래를 완료하는 데 필요한 정보를 제공할 수 있습니다.
// [SKPaymentQueueDelegateWrapper]는 iOS 13 이상에서만 사용할 수 있습니다. 이전 iOS 버전에서 대리자를 사용하는 것은 무시됩니다.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {

  // 트랜잭션 중에 장치의 App Store 첫 화면이 변경된 경우 트랜잭션을 계속해야 하는지 여부를 확인하기 위해 시스템에서 호출합니다.
  // - 트랜잭션이 업데이트 된 스토어프론트 내에서 계속되어야 하는 경우 'true'를 반환합니다(기본 동작).
  // - 트랜잭션을 취소해야 하는 경우 'false'를 반환합니다.
  // 이 경우 트랜잭션은 [SKErrorStoreProductNotAvailable]
  // (https://developer.apple.com/documentation/storekit/skerrorcode/skerrorstoreproductnotavailable?language=objc) 오류와 함께 실패합니다.
  // StoreKit의 [`[-SKPaymentQueueDelegate shouldContinueTransaction]`]
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    // DLog.d('### QDelegate ###', '===> ' + transaction.transactionIdentifier);
    // DLog.d('### QDelegate ###', '===> ' + transaction.error.code.toString());
    DLog.d('### QDelegate ###', '===> ' + transaction.toString());
    DLog.d('### QDelegate ###', '===> ' + storefront.countryCode);
    DLog.d('### QDelegate ###', '===> ' + storefront.identifier);
    return true;
    throw UnimplementedError();
  }


  // 가격 동의 양식을 즉시 표시할지 여부를 확인하기 위해 시스템에서 호출합니다. 기본 반환 값은 'true'입니다.
  // App Store Connect에서 구독 가격이 변경되고 구독자가 아직 조치를 취하지 않은 경우 가격 동의 시트를 표시하도록 시스템에 알립니다.
  // StoreKit의 [`[-SKPaymentQueueDelegate shouldShowPriceConsent:]`]
  // (https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc)
  // 문서를 참조하세요.
  @override
  bool shouldShowPriceConsent() {
    // TODO: implement shouldShowPriceConsent
    throw UnimplementedError();
  }
}






