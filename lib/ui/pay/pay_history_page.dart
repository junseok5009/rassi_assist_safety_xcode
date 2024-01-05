import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_order01.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/pay/pay_cancel_page.dart';
import 'package:rassi_assist/ui/pay/payment_aos_service.dart';
import 'package:rassi_assist/ui/pay/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_date_picker.dart';
import '../common/common_popup.dart';
import '../common/common_view.dart';

/// 2020.12.08
/// 결제 내역
class PayHistoryPage extends StatefulWidget {
  static const routeName = '/page_pay_history';
  static const String TAG = "[PayHistoryPage]";
  static const String TAG_NAME = 'MY_결제내역';

  const PayHistoryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PayHistoryPageState();
}

class PayHistoryPageState extends State<PayHistoryPage> {
  var inAppBilling;

  late SharedPreferences _prefs;
  String _userId = "";

  final List<Order01> _orderList = [];
  DateTime _dateTime = DateTime.now();
  final _dateFormat = DateFormat('yyyy');

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(PayHistoryPage.TAG_NAME,);

    _loadPrefData().then(
      (value) {
        if (_userId.isEmpty) {
          Navigator.pop(context);
        } else {
          _requestTrOrder01();
        }
      },
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';

    Platform.isIOS
        ? inAppBilling = PaymentService()
        : inAppBilling = PaymentAosService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '결제 내역',
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: CommonView.setDatePickerBtnView(
                "${_dateFormat.format(_dateTime)}년",
                () async {
                  await CommonDatePicker.showYearPicker(context, _dateTime)
                      .then(
                    (value) {
                      if (value != null) {
                        _dateTime = value;
                        _requestTrOrder01();
                      }
                    },
                  );
                },
              ),
            ),
            _orderList.isEmpty
                ? Container(
                    margin: const EdgeInsets.all(15),
                    child: CommonView.setNoDataView(200, '결제 내역이 없습니다.'),
                  )
                : Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.symmetric(horizontal: 20,),
                      itemCount: _orderList.length,
                      itemBuilder: (context, index) {
                        return _setTileOrder01(_orderList[index]);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _setTileOrder01(Order01 item) {
    String pdName = '';
    String period = '';
    String csNumber = '';

    bool hasRefund = false;
    if (item.refundAmt != null && item.refundAmt != '0') {
      hasRefund = true;
    } else {
      hasRefund = false;
    }
    bool isPossibleCancel = false;
    if (item.orderChannel == 'CH32' || item.orderChannel == 'CH33') {
      if (item.prodSubdiv.startsWith('M') && item.prodSubdiv != 'M01') {
        //1개월 이상의 상품이면서 환불되지 않은 상품에 해지하기 표시
        if (!hasRefund) isPossibleCancel = true;
      }
      csNumber = item.csPhoneNo;
    }

    if (item.chList.isNotEmpty) {
      pdName = item.chList[0].prodName;
      period = '${TStyle.getDateSFormat(item.chList[0].startDate)}~${TStyle.getDateSFormat(item.chList[0].endDate)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20,),
        Text(
          TStyle.getDateFormat(item.orderDttm),
          style: TStyle.textGrey14,
        ),
        Container(
          margin: const EdgeInsets.only(top: 7.0),
          width: double.infinity,
          alignment: Alignment.centerLeft,
          decoration: UIStyle.boxRoundLine6(),
          child: Padding(
            padding:
                const EdgeInsets.all(15.0,),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2.0),
                      child: const Text(
                        '결제',
                        style: TStyle.contentGrey14,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                TStyle.getMoneyPoint(item.paymentAmt),
                                style: TStyle.defaultTitle,
                              ),
                              Text(
                                '(${item.prodSubdivName})',
                                style: TStyle.textMGrey,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            pdName,
                            style: TStyle.commonPurple14,
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2.0),
                                child: const Text(
                                  '사용기한  ',
                                  style: TStyle.textGreyDefault,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                period,
                                style: TStyle.defaultContent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
             
                Visibility(
                  visible: hasRefund || isPossibleCancel,
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                //환불내역
                Visibility(
                  visible: hasRefund,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: UIStyle.boxWeakGrey10(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '환불',
                              style: TStyle.contentMGrey,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              TStyle.getMoneyPoint(item.refundAmt),
                              style: TStyle.title18,
                            ),
                          ],
                        ),
                        Text(
                          TStyle.getDateSFormat(item.refundDttm),
                          style: TStyle.contentMGrey,
                        ),
                      ],
                    ),
                  ),
                ),

                //해지하기
                Visibility(
                  visible: isPossibleCancel,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: UIStyle.boxWeakGrey10(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '',
                          style: TStyle.contentMGrey,
                        ),
                        InkWell(
                          child: const Text(
                            '- 해지하기  ',
                            style: TStyle.textGrey14,
                          ),
                          onTap: () {
                            // _showRefundInfo(csNumber);
                            if (item.orderChannel == 'CH33') {
                              _showRefundInfo(item.csPhoneNo);
                            } else if (item.orderChannel == 'CH32') {
                              _goRefundPage(
                                item.orderSn,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //웹 결제 내역일 경우 환불 페이지로 이동
  void _goRefundPage(String orderSn) {
    _navigateRefresh(
      context,
      PayCancelPage(),
      RouteSettings(
        arguments: PgData(
          pgSn: orderSn,
        ),
      ),
    );
  }

  _navigateRefresh(
      BuildContext context, Widget instance, RouteSettings settings) async {
    final result =
        await Navigator.push(context, CustomNvRouteClass.createRouteData(instance, settings));
    if (result == 'cancel') {
      DLog.d(PayHistoryPage.TAG, '*** navigate cancel ***');
    } else {
      DLog.d(PayHistoryPage.TAG, '*** navigateRefresh');
      _requestTrOrder01();
    }
  }

  //해지/환불 다이얼로그
  void _showRefundInfo(String number) {
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
                Image.asset(
                  'images/rassibs_img_infomation.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                const Text(
                  '해지안내',
                  style: TStyle.title20,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '해당 상품의 해지문의는\n 결제 고객센터로 연결해 주세요.',
                  textAlign: TextAlign.center,
                  style: TStyle.defaultContent,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '결제 고객센터',
                  style: TStyle.defaultContent,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  number,
                  style: TStyle.title22,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _requestTrOrder01() {
    _fetchPosts(
      TR.ORDER01,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'prodCateg': '',
          'orderYear': _dateFormat.format(_dateTime),
        },
      ),
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayHistoryPage.TAG, '$trStr $json');

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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PayHistoryPage.TAG, response.body);

    if (trStr == TR.ORDER01) {
      final TrOrder01 resData = TrOrder01.fromJson(jsonDecode(response.body));
      _orderList.clear();
      if (resData.retCode == RT.SUCCESS && resData.listData.isNotEmpty) {
        _orderList.addAll(resData.listData);
      }
      setState(() {});

      Future.delayed(const Duration(milliseconds: 500), () {
        if (Platform.isIOS) {
          //앱스토어 결제 히스토리 체크
          inAppBilling.getPurchaseHistory();
        } else {
          inAppBilling.requestPurchaseAsync();
        }
      });
    }
  }

  String resStr = '''
  {
  "trCode": "TR_ORDER01",
  "retData": [
    {
      "orderSn": "30395",
      "svcDivision": "S",
      "orderStatus": "OSP2",
      "orderStatText": "결제완료",
      "orderChannel": "CH32",
      "orderChanText": "Web > TradingPoint",
      "prodCode": "AC_PR",
      "prodName": "프리미엄",
      "prodSubdiv": "A01",
      "prodSubdivName": "정기결제 상품",
      "prodCateg": "AC",
      "orderDttm": "20211210094432",
      "paymentAmt": "59400",
      "refundAmt": "0",
      "list_OrderChange": [
        {
          "changeSeq": "1",
          "prodCode": "AC_PR",
          "prodName": "프리미엄",
          "prodSubdiv": "A01",
          "startDate": "20211210",
          "endDate": "20220110",
          "paymentAmt": "59400",
          "orderDttm": "20211210094432"
        }
      ]
    },
    {
      "orderSn": "30392",
      "svcDivision": "S",
      "orderStatus": "OSR4",
      "orderStatText": "환불(전액)",
      "orderChannel": "CH32",
      "orderChanText": "Web > YNR",
      "csPhoneNo": "1688-3500",
      "prodCode": "AC_PR",
      "prodName": "프리미엄",
      "prodSubdiv": "M06",
      "prodSubdivName": "6개월 상품",
      "prodCateg": "AC",
      "orderDttm": "20211210092007",
      "paymentAmt": "338000",
      "refundDttm": "20211210093921",
      "refundAmt": "0",
      "list_OrderChange": [
        {
          "changeSeq": "1",
          "prodCode": "AC_PR",
          "prodName": "프리미엄",
          "prodSubdiv": "M06",
          "startDate": "20211210",
          "endDate": "20211210",
          "paymentAmt": "338000",
          "orderDttm": "20211210092007"
        }
      ]
    }
  ],
  "retCode": "0000",
  "retMsg": "success"
  }
  ''';
}
