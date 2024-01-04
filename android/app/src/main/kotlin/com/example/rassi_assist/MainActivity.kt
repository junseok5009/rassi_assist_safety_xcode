package com.mobile.thinkpool.trade

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingFlowParams.SubscriptionUpdateParams
import com.android.billingclient.api.BillingFlowParams.SubscriptionUpdateParams.ReplacementMode
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.ConsumeResponseListener
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchaseHistoryRecord
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.SkuDetailsParams
import com.google.android.gms.tasks.Task
import com.google.common.collect.ImmutableList
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import android.os.Build;
import android.content.pm.PackageManager;
import androidx.core.content.ContextCompat;
import android.Manifest;
import androidx.core.app.ActivityCompat
import com.example.rassi_assist.OllaSeedUtil


class MainActivity: FlutterFragmentActivity() {

    //methodchannel
    private val CHANNEL_NAME = "thinkpool.flutter.dev/channel_method"
    private val CHANNEL_PUSH_NAME = "thinkpool.flutter.dev/channel_method_push"
    private val CHANNEL_NAME_INAPP = "thinkpool.flutter.dev/channel_method_inapp"
    private val handler = Handler(Looper.getMainLooper())

    private val PREFS_NAME = "rassi_trade_prefs";    // 프리퍼런스 이름
    private val PREFS_USER_ID = "rassi_id";          // 씽크풀 ID
    lateinit var sharedPreference: SharedPreferences
    lateinit var billingClient: BillingClient
    lateinit var channel: MethodChannel
    lateinit var channel_push: MethodChannel

    private var isInProgress = true     //결제진행중:true
    private var isCallback = false      //콜백 호출 여부
    private var isStoreReady = false    //store 연결 여부
    private var isUserCancel = false    //유저 취소 여부
    private var isGenError = false      //에러 발생 여부
    private var isPending = false       //결제 팬딩 여부

    private var logListSize = -1
    private var logErrCode = 0

    private var orderPrc = ""
    private var typeName = ""
    private var billingType = ""
    private var discountType = ""
    private var sIsSubs = "" // 정기결제: Y, 단건결제: N
    private var currency = "" //통화 코드

    private var token = "" //푸시토큰
    private val REQ_PERMISSION_PUSH = 1020 // request permission code

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sharedPreference  =  getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        FirebaseMessaging.getInstance().token
            .addOnCompleteListener { task: Task<String> ->
                if (!task.isSuccessful) {
                    return@addOnCompleteListener
                }

                // Get new FCM registration token
                Log.w("MainActivity", "##### [RASSI] Push Token ${task.result} ")
                token = task.result
            }

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
            && PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)){
            // 푸쉬 권한 없음
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_PERMISSION_PUSH)
        }

        val intent = intent
        if (intent != null) {
            if (intent.extras != null) {
                //푸시 랜딩 페이지
                val pushClick = intent.extras!!.getBoolean("push_click", false)
                val pushSN = intent.extras!!.getString("pushSn", "")
                val bannerLanding = intent.extras!!.getString("bannerLanding", "")
                val landingPage = intent.extras!!.getString("landingPage", "")
                val linkType = intent.extras!!.getString("linkType", "")
                val pushDiv1 = intent.extras!!.getString("pushDiv1", "")
                val pushDiv2 = intent.extras!!.getString("pushDiv2", "")
                val pushDiv3 = intent.extras!!.getString("pushDiv3", "")
                val stockCode = intent.extras!!.getString("stockCode", "")
                val stockName = intent.extras!!.getString("stockName", "")
                val pocketSn = intent.extras!!.getString("pocketSn", "")
                val discountType = intent.extras!!.getString("discountType", "")
                //                methodCall = intent.getExtras().getString("methodCall", "");

                if (landingPage != "") {
//                  if (pushClick) requestPUSH07()
                    handleFcmMessage(pushSN, landingPage, linkType, pushDiv1, pushDiv2, pushDiv3, stockCode, stockName, pocketSn)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
//        Log.w("MainActivity", "@@@@@ onNewIntent()")

        if (intent != null) {
            if (intent.extras != null) {
                //푸시 랜딩 페이지
                val pushClick = intent.extras!!.getBoolean("push_click", false)
                val pushSN = intent.extras!!.getString("pushSn", "")
                val bannerLanding = intent.extras!!.getString("bannerLanding", "")
                val landingPage = intent.extras!!.getString("landingPage", "")
                val linkType = intent.extras!!.getString("linkType", "")
                val pushDiv1 = intent.extras!!.getString("pushDiv1", "")
                val pushDiv2 = intent.extras!!.getString("pushDiv2", "")
                val pushDiv3 = intent.extras!!.getString("pushDiv3", "")
                val stockCode = intent.extras!!.getString("stockCode", "")
                val stockName = intent.extras!!.getString("stockName", "")
                val pocketSn = intent.extras!!.getString("pocketSn", "")
                discountType = intent.extras!!.getString("discountType", "")

                if (landingPage != "") {
//                  if (pushClick) requestPUSH07()
                    handleFcmMessage(pushSN, landingPage, linkType, pushDiv1, pushDiv2, pushDiv3, stockCode, stockName, pocketSn)
                }
            }
        }

    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        //push methodChannel
        channel_push = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_PUSH_NAME)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->

                // 아이디 저장 ===========================================
                if (call.method == "getPrefUserId") {
//                Log.w("MainActivity", "### getPrefUserId")
                    val userId = getPrefUserId()

                    if (userId != null) {
                        result.success(userId)
                    } else {
                        result.error("UNAVAILABLE", "pref userId not available.", null)
                    }
                }
                else if(call.method == "setPrefLogout") {
//                Log.w("MainActivity", "### setPrefLogout")
                    setPrefLogout()
                }

                // 암호화 ================================================
                else if(call.method == "getSeedEncodeData") {
//                    Log.w("MainActivity", "### getSeedEncodeData")
                    val encodeData = call.argument<String>("data_code")
                    if (encodeData != null) {
                        val encResult = getSeedEncodeData(encodeData)
                        if (encResult != null) {
                            result.success(encResult)
                        } else {
                            result.error("UNAVAILABLE", "getSeedEncodeData not available.", null)
                        }
                    }
                }

                // 결제 ================================================
                // [BillingClient] 초기화
                else if(call.method == "initBillingClient") {
                    Log.w("MainActivity", "##### initBillingClient")
                    initBillingClient()
                }
                // [결제 상품 리스트 요청]
                else if(call.method == "getProductList") {
                    Log.w("MainActivity", "##### getProductList")
                    // 한번에 여러 상품의 정보 리스트를 요청???
                    val pdCode = call.argument<String>("pd_code")
                    if (pdCode != null) {
                        queryProductDetails(
                            pdCode,
                            object : ProductCallback {
                                override fun onRequestPd(fmPrice: String) {
                                    Log.w("MainActivity", "<<상품정보 조회 Callback>> : $fmPrice")
                                    result.success(fmPrice)
//                                    channel.invokeMethod("getFormatedPrice", fmPrice)
                                }
                            }
                        )
                    }
                }
                // [결제 플로우 시작 요청]
                else if(call.method == "startBillingProcess") {
                    Log.w("MainActivity", "##### startBillingProcess")
                    // 특정 조건이 충족 되었다면 결제 플로우 시작 -> 특정 조건?
                    val pdCode = call.argument<String>("pd_code")
                    if (pdCode != null) {
                        flowProductDetails(pdCode)
//                        Log.w("MainActivity", "##### 표시가격 $fPrice")
                    }
                }
                // [결제 Upgrade 시작 요청]
                else if(call.method == "startBillingUpgrade") {
                    Log.w("MainActivity", "##### startBillingUpgrade")
                    // 특정 조건이 충족 되었다면 결제 플로우 시작 -> 특정 조건?
                    val pdCode = call.argument<String>("pd_code")
                    if (pdCode != null) {
                        flowPrePdToken(pdCode, "ac_s3.a01")
//                        Log.w("MainActivity", "##### 표시가격 $fPrice")
                    }
                }
                // [승인되지 않은 결제리스트  처리]
                else if(call.method == "requestPurchasesAsync") {
                    Log.w("MainActivity", "##### requestPurchasesAsync")
                    requestQueryPurchasesAsync()
                }

                else {
                    result.notImplemented()
                }
        }
    }

    private fun getPrefUserId(): String? {
        if(sharedPreference != null) {
            return sharedPreference.getString(PREFS_USER_ID, "")
        }

        return ""
    }

    private fun setPrefLogout() {
        if(sharedPreference != null) {
            sharedPreference.edit().putString(PREFS_USER_ID, "").apply()
        }
    }

    private fun getSeedEncodeData(userId: String): String? {
        return OllaSeedUtil.setSeedEncodeData(userId)
    }

    //TODO [ 결제처리 ]
    // ===============================================================================
    private fun initBillingClient() {
        // NOTE  1.BillingClient 생성 - 리스너 연결하여 구매 관련된 모든 업데이트 내용 수신
        billingClient = BillingClient.newBuilder(this)
            .setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()

        // NOTE  2.구글플레이 연결 설정
        billingClient.startConnection(object: BillingClientStateListener{
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    isStoreReady = true
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.w("MainActivity", "구글플레이 연결 실패시 재시도 로직 필요 ")
                isStoreReady = false
                // 연결 실패시 재시도 로직
                // 참고: 자체 연결 재시도 로직을 구현하고 onBillingServiceDisconnected() 메서드를 재정의하는 것이 좋습니다.
                // 모든 메서드를 실행할 때는 BillingClient 연결을 유지해야 합니다.
//                if (!this@BillingActivity.isFinishing()) {
//                    showToast(
//                        "현재 구글플레이 결제를 이용하기 위해 기기가 준비되지 않았습니다. " +
//                                "앱종료 후 구글플레이 업데이트 상태를 확인하신 후 다시 시도해 주세요."
//                    )
//                }
            }
        })
    }

    // NOTE  리스너 - 구매 관련된 모든 업데이트 내용 수신
    private val purchasesUpdatedListener =
        PurchasesUpdatedListener { billingResult, purchases ->
            Log.w("MainActivity", "모든 구매 관련 업데이트를 수신")

            // 구글 플레이에서 구매 성공, 구매 성공 시 구매 토큰도 생성됩니다.
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                if (purchases != null) {
                    Log.w("MainActivity",  "[결제완료&승인대기] " + billingResult.responseCode + ", size:" + purchases.size)
                    if (purchases.size > 0) {
                        handlePurchase(purchases[0])
                    }
                }
            }
            // 사용자 취소
            else if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
                Log.w("MainActivity", "[사용자취소] (" + billingResult.responseCode + ") " + billingResult.debugMessage)
                handleBillingResponse("USER_CANCELED", billingResult.responseCode,
                    "사용자 취소")
            }
            // 상품이 이미 소유되어있어 구매하지 못했습니다.
            else if (billingResult.responseCode == BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED) {
                Log.w("MainActivity", "[ITEM_ALREADY_OWNED] (" + billingResult.responseCode + ") ")
                handleBillingResponse("ITEM_ALREADY_OWNED", billingResult.responseCode,
                    "상품이 이미 소유되어있어 구매하지 못했습니다.")
            }
            // 아이템을 소유하지 않아 소비하지 못했습니다.
            else if (billingResult.responseCode == BillingClient.BillingResponseCode.ITEM_NOT_OWNED) {
                Log.w("MainActivity", "[ITEM_NOT_OWNED] (" + billingResult.responseCode + ") ")
                handleBillingResponse("ITEM_NOT_OWNED", billingResult.responseCode,
                    "아이템을 소유하지 않아 소비하지 못했습니다.")
            }
            // 에러
            else {
                Log.w("MainActivity", "[결제오류] (" + billingResult.responseCode + ") " + billingResult.debugMessage)
                handleBillingResponse("ETC_ERROR", billingResult.responseCode,
                    "결제 진행중 오류가 발생하였습니다. 잠시후 다시 시도해주세요.")
            }
        }

    /*
    사용자가 구매를 완료하면 앱에서 구매를 처리해야 합니다.
        대부분의 경우 앱은 PurchasesUpdatedListener를 통해 구매 알림을 받습니다.
        그러나 앱이 BillingClient.queryPurchasesAsync() 호출을 인식하는 경우가 있습니다.
    앱은 다음과 같은 방식으로 구매를 처리해야 합니다.
    1. 구매를 인증합니다 : 구매 상태가 PURCHASED인지 확인
    2. 사용자에게 콘텐츠를 제공하고 콘텐츠 전송을 확인합니다. 선택적으로, 사용자가 항목을 다시 구입할 수 있도록 항목을 소비됨으로 표시합니다.*/
    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            Log.w("MainActivity", "### 구매 후 데이터 : ${purchase.toString()}")
            Log.w("MainActivity", "### 구매 후 데이터 : ${purchase.products[0]}")

            val price:String = orderPrc.replace("[^0-9.]".toRegex(), "")
            if(price.isEmpty()) {
                Log.w("MainActivity", "### 구매 후 가격없을경우")
                setBillingPrice(purchase)
            } else {
                Log.w("MainActivity", "### 구매 후 가격있을경우")
                sendBillingSuccess(purchase, price)
            }
        } else if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
            // 결제 보류 상태
            isPending = true
            Log.w("MainActivity", "구매 후 데이터 - PurchaseState.PENDING")
        }
    }

    //NOTE 승인되지 않은 결제건 처리
    private fun requestQueryPurchasesAsync() {
        if (isStoreReady) {
            // In-App purchases
            billingClient.queryPurchasesAsync(BillingClient.SkuType.INAPP) { billingResult, list ->
                if (list != null) {
                    Log.w("MainActivity", "결제 후 처리 SkuType.INAPP")
                    for (purchase in list) {
                        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                            Log.w("MainActivity", "결제 후 처리 - (INAPP)PurchaseState.PURCHASED")
                            if (purchase.isAcknowledged) {
                                consumePurchase(purchase.purchaseToken)
                            } else {
                                // Handle unacknowledged purchases
                                val skuList: List<String?> = purchase.skus ?: emptyList()
                                val params = SkuDetailsParams.newBuilder()
                                    .setSkusList(skuList)
                                    .setType(BillingClient.SkuType.INAPP)
                                    .build()
                                billingClient.querySkuDetailsAsync(params) { billingResult, list ->
                                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && list != null) {
                                        if (list.isNotEmpty()) {
                                            val skuObj = list[0]
                                            for (sSku in purchase.skus.orEmpty()) {
                                                if (sSku == skuObj.sku) {
                                                    // Handle the matching subscription
                                                    val price = skuObj.price.replace("[^0-9.]".toRegex(), "")
                                                    val currencyCode =skuObj.priceCurrencyCode
                                                    Handler(Looper.getMainLooper()).post {
                                                        sendBillingSuccess(purchase, price, currencyCode)
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
                            // Handle pending purchases
                            Log.w("MainActivity", "결제 후 처리:INAPP - PurchaseState.PENDING")
                        }
                    }
                }
            }

            // Subscriptions
            billingClient.queryPurchasesAsync(BillingClient.SkuType.SUBS) { billingResult, list ->
                if (list != null) {
                    Log.w("MainActivity", "결제 후 처리 SkuType.SUBS")
                    for (purchase in list) {
                        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                            if (purchase.isAcknowledged) {
                                // Handle acknowledged subscriptions
//                                mPrefs.edit().putBoolean(IConstants.PAY_CONFIRM_DELAY, false).apply()
                                Log.w("MainActivity", "결제 후 처리 - 승인 완료 상태")
                            } else {
                                Log.w("MainActivity", "결제 후 처리 - Purchase_NOT_PURCHASED")
                                // Handle unacknowledged subscriptions
                                val skuList: List<String?> = purchase.skus ?: emptyList()
                                val params = SkuDetailsParams.newBuilder()
                                    .setSkusList(skuList)
                                    .setType(BillingClient.SkuType.SUBS)
                                    .build()
                                billingClient.querySkuDetailsAsync(params) { billingResult, list ->
                                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && list != null) {
                                        if (list.isNotEmpty()) {
                                            val skuObj = list[0]
                                            for (sSku in purchase.skus.orEmpty()) {
                                                if (sSku == skuObj.sku) {
                                                    // Handle the matching subscription
                                                    val price = skuObj.price.replace("[^0-9.]".toRegex(), "")
                                                    val currencyCode =skuObj.priceCurrencyCode
                                                    Handler(Looper.getMainLooper()).post {
                                                        sendBillingSuccess(purchase, price, currencyCode)
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
                            // Handle pending purchases
                            Log.w("MainActivity", "결제 후 처리:SUBS - PurchaseState.PENDING")
                        }
                    }
                }
            }
        }
    }

    private fun setBillingPrice(purchase: Purchase) {
        val pdCode = purchase.products[0]
        var pdType = BillingClient.ProductType.SUBS
        if(pdCode == "ac_pr.m01")
            pdType = BillingClient.ProductType.INAPP

        val queryProductDetailsParams =
            QueryProductDetailsParams.newBuilder()
                .setProductList(
                    ImmutableList.of(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(pdCode)
                            .setProductType(pdType)
                            .build()
                    )
                ).build()

        billingClient.queryProductDetailsAsync(queryProductDetailsParams) {
                billingResult, productDetailsList ->
            Log.w("MainActivity", "<<상품정보 조회>> : ${billingResult.debugMessage}")
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                Log.w("MainActivity", "<<상품정보 조회 후 결제>> : ${productDetailsList.toString()}")

                if(pdType == BillingClient.ProductType.SUBS) {
                    orderPrc = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.formattedPrice.toString()
                    currency = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.priceCurrencyCode.toString()
                }
                else if(pdType == BillingClient.ProductType.INAPP) {
                    orderPrc = productDetailsList[0].oneTimePurchaseOfferDetails?.formattedPrice.toString()
                    currency = productDetailsList[0].oneTimePurchaseOfferDetails?.priceCurrencyCode.toString()
                }

                val price:String = orderPrc.replace("[^0-9.]".toRegex(), "")
                sendBillingSuccess(purchase, price)
            }
            else {
                Log.w("MainActivity", "!!!Error getting available Products to buy: " +
                        "${billingResult.responseCode} ${billingResult.debugMessage}")
            }
        }
    }

    private fun sendBillingSuccess(purchase: Purchase, price: String) {
        var logMsg = ""
        logMsg = if (isCallback) logMsg + "callback=Y" else logMsg + "callback=N"
        logMsg = if (isUserCancel) "$logMsg, cancel=Y" else "$logMsg, cancel=N"
        logMsg = if (isGenError) "$logMsg, error=Y" else "$logMsg, error=N"
        logMsg = if (isPending) "$logMsg, pending=Y" else "$logMsg, pending=N"
        logMsg = (logMsg + ", listSize=" + logListSize + ", errCode=" + getErrMsg(logErrCode)
                + ", isScreenName=MainActivity")

        if(purchase.products.size > 0){
            sIsSubs = if(purchase.products[0] == "ac_pr.m01") "N"
            else "Y"    //정기결제
        }

        val jsonObj = JSONObject()
        try {
            jsonObj.put("productId", purchase.products[0])  //ex) ac_pr.x01
            jsonObj.put("orderId", purchase.orderId)
            jsonObj.put("purchaseToken", purchase.purchaseToken)
            jsonObj.put("isAutoPay", sIsSubs)
            jsonObj.put("paymentAmt", price)    //TODO 이 값은 결제상품 정보에서.
            jsonObj.put("currency", currency)   //TODO 이 값은 결제상품 정보에서.
            jsonObj.put("inappMsg", logMsg)

            Log.w("MainActivity", "<<sendBillingSuccess 2 >> : \n${purchase.products[0]} | " +
                    "${purchase.orderId} | ${purchase.purchaseToken} | $sIsSubs | $price | $currency \n$logMsg")
        } catch (e: Exception) {
            e.printStackTrace()
        }

        channel.invokeMethod("billing_ok", jsonObj.toString())
    }

    private fun sendBillingSuccess(purchase: Purchase, price: String, currencyCode: String) {
        var logMsg = ""
        logMsg = if (isCallback) logMsg + "callback=Y" else logMsg + "callback=N"
        logMsg = if (isUserCancel) "$logMsg, cancel=Y" else "$logMsg, cancel=N"
        logMsg = if (isGenError) "$logMsg, error=Y" else "$logMsg, error=N"
        logMsg = if (isPending) "$logMsg, pending=Y" else "$logMsg, pending=N"
        logMsg = (logMsg + ", listSize=" + logListSize + ", errCode=" + getErrMsg(logErrCode)
                + ", isScreenName=MainActivity")

        if(purchase.products.size > 0){
            sIsSubs = if(purchase.products[0] == "ac_pr.m01") "N"
            else "Y"    //정기결제
        }

        val jsonObj = JSONObject()
        try {
            jsonObj.put("productId", purchase.products[0])  //ex) ac_pr.x01
            jsonObj.put("orderId", purchase.orderId)
            jsonObj.put("purchaseToken", purchase.purchaseToken)
            jsonObj.put("isAutoPay", sIsSubs)
            jsonObj.put("paymentAmt", price)
            jsonObj.put("currency", currencyCode)
            jsonObj.put("inappMsg", logMsg)

            Log.w("MainActivity", "<<sendBillingSuccess 3 >> : \n${purchase.products[0]} | " +
                    "${purchase.orderId} | ${purchase.purchaseToken} | $sIsSubs | $price | $currencyCode \n$logMsg")
        } catch (e: Exception) {
            e.printStackTrace()
        }

        channel.invokeMethod("billing_ok", jsonObj.toString())
    }

    private fun handleBillingResponse(strCode: String, eCode: Int, msg: String) {
        val jsonObj = JSONObject()
        try {
            jsonObj.put("str_code", strCode)
            jsonObj.put("res_code", eCode)
            jsonObj.put("code_msg", getErrMsg(eCode))
            jsonObj.put("comment", msg)
            jsonObj.put("store_status", "")
        } catch (e: Exception) {
            e.printStackTrace()
        }

        channel.invokeMethod("billing_response", jsonObj.toString())
    }

    // NOTE  3.상품 정보 조회 (구독상품 조회 ??) -> 가격 표시만 조회
    private fun queryProductDetails(pdCode: String, callback: ProductCallback) {
        var pdType = BillingClient.ProductType.SUBS
        if(pdCode == "ac_pr.m01")
            pdType = BillingClient.ProductType.INAPP

        val queryProductDetailsParams =
            QueryProductDetailsParams.newBuilder()
                .setProductList(
                    ImmutableList.of(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(pdCode)
                            .setProductType(pdType)
                            .build()
                    )
                ).build()

        billingClient.queryProductDetailsAsync(queryProductDetailsParams) {
                billingResult, productDetailsList ->
            // process returned productDetailsList
            Log.w("MainActivity", "<<상품정보 조회>> : ${billingResult.debugMessage}")

            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                Log.w("MainActivity", "<<상품정보 조회>> : ${productDetailsList.toString()}")
                if(pdType == BillingClient.ProductType.SUBS) {
                    val result = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.formattedPrice.toString()
                    if (callback != null) {
                        callback.onRequestPd(result)
                    }
                }
                else if(pdType == BillingClient.ProductType.INAPP) {
                    val result = productDetailsList[0].oneTimePurchaseOfferDetails?.formattedPrice.toString()
                    if (callback != null) {
                        callback.onRequestPd(result)
                    }
                }
            }
            else {
                Log.w("MainActivity", "!!!Error getting available Products to buy: " +
                        "${billingResult.responseCode} ${billingResult.debugMessage}")
            }
        }
    }

    // NOTE  4.상품 정보 조회 후 결제 요청
    private fun flowProductDetails(pdCode: String) {
        var pdType = BillingClient.ProductType.SUBS
        if(pdCode == "ac_pr.m01")
            pdType = BillingClient.ProductType.INAPP

        val queryProductDetailsParams =
            QueryProductDetailsParams.newBuilder()
                .setProductList(
                    ImmutableList.of(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(pdCode)
                            .setProductType(pdType)
                            .build()
                    )
                ).build()

        billingClient.queryProductDetailsAsync(queryProductDetailsParams) {
                billingResult, productDetailsList ->
            Log.w("MainActivity", "<<상품정보 조회>> : ${billingResult.debugMessage}")
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                Log.w("MainActivity", "<<상품정보 조회 후 결제>> : ${productDetailsList.toString()}")

                if(pdType == BillingClient.ProductType.SUBS) {
                    orderPrc = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.formattedPrice.toString()
                    currency = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.priceCurrencyCode.toString()
                }
                else if(pdType == BillingClient.ProductType.INAPP) {
                    orderPrc = productDetailsList[0].oneTimePurchaseOfferDetails?.formattedPrice.toString()
                    currency = productDetailsList[0].oneTimePurchaseOfferDetails?.priceCurrencyCode.toString()
                }

                val result = productDetailsList[0]
                doBillingFlow(result, pdType)
            }
            else {
                Log.w("MainActivity", "!!!Error getting available Products to buy: " +
                        "${billingResult.responseCode} ${billingResult.debugMessage}")
            }
        }
    }

    // NOTE 5.결제 플로우 시작
    private fun doBillingFlow(productDetails: ProductDetails, type: String) {
        Log.w("MainActivity", "<<doBillingFlow >>")
        // Retrieve a value for "productDetails" by calling queryProductDetailsAsync()
        // Get the offerToken of the selected offer

        val productDetailsParamsList = when (type) {
            "inapp" -> {
                listOf(
                    BillingFlowParams.ProductDetailsParams.newBuilder()
                        .setProductDetails(productDetails)
                        .build()
                )
            }
            "subs" -> {
                val offerToken =
                    productDetails.subscriptionOfferDetails?.get(0)?.offerToken.toString()
                listOf(
                    BillingFlowParams.ProductDetailsParams.newBuilder()
                        .setProductDetails(productDetails)
                        .setOfferToken(offerToken)
                        .build()
                )
            }
            else -> emptyList()
        }

        val billingFlowParams =
            BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build()

        // Launch the billing flow
        val billingResult = billingClient.launchBillingFlow(this, billingFlowParams)
        Log.w("MainActivity", "구글플레이에 요청 결과 Code : $billingResult")
    }

    // NOTE 결제 상품 업그레이드 시작
    // 현재 사용중인 상품 코드를 비교해서 3종목 알림 상품이라면
    // 현재 사용하는 상품 purchaseToken 추출 -> 업그레이드로 넘겨준다
    private fun flowPrePdToken(pdCode: String, preCode: String) {
        //현재 사용중인 상품 정보 KotlinExtension 사용시
//        val params = QueryPurchaseHistoryParams.newBuilder()
//            .setProductType(BillingClient.ProductType.SUBS)
//        val purchaseHistoryResult = billingClient.queryPurchaseHistory(params.build())

        //현재 사용중인 상품 정보
        billingClient.queryPurchaseHistoryAsync(BillingClient.SkuType.SUBS) {
                billingResult1: BillingResult, list: List<PurchaseHistoryRecord>? ->
            if (billingResult1.responseCode == BillingClient.BillingResponseCode.OK && list != null) {
                for (purchaseRecord in list) {
                    for (i in purchaseRecord.skus.indices) {
                        val sSku = purchaseRecord.skus[i]

                        Log.w("MainActivity", "##### Sku ##### : $sSku " +
                                "\n${purchaseRecord.signature} \n${purchaseRecord.originalJson}")
                        if (preCode == sSku) {
                            val preToken = purchaseRecord.purchaseToken
                            Log.w("MainActivity", "[preToken] " + sSku + " | " + purchaseRecord.purchaseToken)
                            flowUpgradeDetails(pdCode, preToken)
                            break
                        }
                    }
                }
            }
        }
    }
    private fun flowUpgradeDetails(pdCode: String, preCode: String) {
        var pdType = BillingClient.ProductType.SUBS
        if(pdCode == "ac_pr.m01")
            pdType = BillingClient.ProductType.INAPP

        val queryProductDetailsParams =
            QueryProductDetailsParams.newBuilder()
                .setProductList(
                    ImmutableList.of(
                        QueryProductDetailsParams.Product.newBuilder()
                            .setProductId(pdCode)
                            .setProductType(pdType)
                            .build()
                    )
                ).build()

        billingClient.queryProductDetailsAsync(queryProductDetailsParams) {
                billingResult, productDetailsList ->
            Log.w("MainActivity", "<<상품정보 조회>> : ${billingResult.debugMessage}")
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                Log.w("MainActivity", "<<상품정보 조회 후 결제>> : ${productDetailsList.toString()}")

                if(pdType == BillingClient.ProductType.SUBS) {
                    orderPrc = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.formattedPrice.toString()
                    currency = productDetailsList[0]
                        .subscriptionOfferDetails?.get(0)?.pricingPhases!!.pricingPhaseList[0]?.priceCurrencyCode.toString()
                }
                else if(pdType == BillingClient.ProductType.INAPP) {
                    orderPrc = productDetailsList[0].oneTimePurchaseOfferDetails?.formattedPrice.toString()
                    currency = productDetailsList[0].oneTimePurchaseOfferDetails?.priceCurrencyCode.toString()
                }

                val productDetails = productDetailsList[0]
                doBillingUpgradeFlow(productDetails, preCode)
            }
            else {
                Log.w("MainActivity", "!!!Error getting available Products to buy: " +
                        "${billingResult.responseCode} ${billingResult.debugMessage}")
            }
        }
    }
    // NOTE 업그레이드 결제 요청
    private fun doBillingUpgradeFlow(productDetails: ProductDetails, oldToken: String) {
        val updateParams = SubscriptionUpdateParams.newBuilder()
            .setOldPurchaseToken(oldToken)
            .setSubscriptionReplacementMode(ReplacementMode.WITH_TIME_PRORATION)
            .build()
        val productDetailsParamsList = productDetails.subscriptionOfferDetails?.get(0)?.let { offerDetails ->
            val offerToken = offerDetails.offerToken.toString()
            listOf(
                BillingFlowParams.ProductDetailsParams.newBuilder()
                    .setProductDetails(productDetails)
                    .setOfferToken(offerToken)
                    .build()
            )
        } ?: emptyList()
        val billingFlowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(productDetailsParamsList)
            .setSubscriptionUpdateParams(updateParams)
            .build()

        val billingResult = billingClient.launchBillingFlow(this, billingFlowParams)
        Log.w("MainActivity", "구글플레이에 Upgrade 요청 결과 : $billingResult")
    }

    //단건 결제 소비 요청
    private fun consumePurchase(token: String) {
        Log.w("MainActivity", "구매 후 consume 처리")
        val consumeParams = ConsumeParams.newBuilder()
            .setPurchaseToken(token)
            .build()
        billingClient.consumeAsync(consumeParams, consumeListener)
    }

    var consumeListener =
        ConsumeResponseListener { billingResult, outToken ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                Log.w("MainActivity", "구매 후 consume 처리 완료")
//                showToast("결제 승인 완료")
            } else {
                // 소비요청 실패
                Log.w("MainActivity", "구매 후 consume 소비요청 실패")
            }
        }

    private fun getErrMsg(code: Int): String? {
        return when (code) {
            -3 -> "SERVICE_TIMEOUT(-3)"
            -2 -> "FEATURE_NOT_SUPPORTED(-2)"
            -1 -> "SERVICE_DISCONNECTED(-1)"
            1 -> "USER_CANCELED(1)"
            2 -> "SERVICE_UNAVAILABLE(2)"
            3 -> "BILLING_UNAVAILABLE(3)"
            4 -> "ITEM_UNAVAILABLE(4)"
            5 -> "DEVELOPER_ERROR(5)"
            6 -> "ERROR(6)"
            7 -> "ITEM_ALREADY_OWNED(7)"
            8 -> "ITEM_NOT_OWNED(8)"
            0 -> "OK(0)"
            else -> "OK(0)"
        }
    }

/*    //methodchannel 사용예시
    private var CHANNEL = "intent"
    private var methodChannel: MethodChannel? = null

    @SuppressLint("NewApi")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL);
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "launchIntentActivity") {
//                Log.w("MainActivity", "Log message Start")
                var url = call.argument<String>("url");
//                Log.w("MainActivity", "Log message url : " + url)
                val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
                // 실행 가능한 앱이 있으면 앱 실행
                if (intent.resolveActivity(packageManager) != null) {
                    Log.w("MainActivity", "Log message existPackage")
                    val existPackage = packageManager.getLaunchIntentForPackage("" + intent.getPackage());
                    startActivity(intent)
                    result.success(null);
                } else {
//                    Log.w("MainActivity", "Log message Fallback")
                    // Fallback URL이 있으면 현재 웹뷰에 로딩
                    val fallbackUrl = intent.getStringExtra("browser_fallback_url")
                    if (fallbackUrl != null) {
                        result.success(fallbackUrl);
                    }
                }
            } else {
                Log.w("MainActivity", "Log message notImplemented")
                result.notImplemented()
            }
        }
    }*/


    //TODO [ 푸시처리 ]
    // ===============================================================================
    private fun handleFcmMessage(pushSn:String, landingPage:String, linkType:String,
                                 ldDiv1:String, ldDiv2:String, ldDiv3:String,
                                 stockCode:String, stockName:String, pktSn:String) {
        Log.w("MainActivity", "GO LANDING ==>$landingPage")

        val jsonObj = JSONObject()
        try {
            jsonObj.put("pushSn", pushSn)
            jsonObj.put("linkPage", landingPage)
            jsonObj.put("linkType", linkType)
            jsonObj.put("pushDiv1", ldDiv1)
            jsonObj.put("pushDiv2", ldDiv2)
            jsonObj.put("pushDiv3", ldDiv3)
            jsonObj.put("stockCode", stockCode)
            jsonObj.put("stockName", stockName)
            jsonObj.put("pocketSn", pktSn)
        } catch (e: Exception) {
            Log.w("MainActivity", "LANDING JSONObject exception")
            e.printStackTrace()
        }

        if(::channel_push.isInitialized) {
            Log.w("MainActivity", "GO LANDING ===> flutter")
            channel_push.invokeMethod("fcm_message", jsonObj.toString())
        } else {
            //채널이 초기화되지 않은 상태 - 1초 뒤에 다시 실행
            Log.w("MainActivity", "GO LANDING ===> not initialized")
            delayAndExecute(1000) {
                if(::channel_push.isInitialized) {
                    channel_push.invokeMethod("fcm_message", jsonObj.toString())
                }
            }
        }
        Log.w("MainActivity", "GO LANDING ==> END")
    }

    // 메소드 실행을 지연하기 위한 함수
    private fun delayAndExecute(delayMillis: Long, runnable: Runnable) {
        handler.postDelayed(runnable, delayMillis)
    }

}

interface ProductCallback {
    fun onRequestPd(fmPrice: String)
}