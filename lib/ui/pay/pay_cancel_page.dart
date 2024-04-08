import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_order05.dart';
import 'package:rassi_assist/ui/pay/pay_web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.12.15
/// 결제 해지/환불 정보
class PayCancelPage extends StatelessWidget {
  static const routeName = '/page_pay_cancel';
  static const String TAG = "[PayCancelPage]";
  static const String TAG_NAME = '결제해지환불';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: PayCancelWidget(),
      ),
    );
  }
}

class PayCancelWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PayCancelState();
}

class PayCancelState extends State<PayCancelWidget> {
  var appGlobal = AppGlobal();

  late SharedPreferences _prefs;
  String _userId = '';

  late PgData args;
  String _orderSn = '';
  String _orderDate = '';
  String _pdName = '';
  String _paymentAmt = '';
  String _useDays = '';
  String _useAmt = '';
  String _cancelFee = '';
  String _refundAmt = '';
  String _lgTid = '';
  String _lgCancelAmt = '';
  bool _isBankTransfer = false;

  @override
  void initState() {
    super.initState();

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(PayCancelPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.ORDER05,
            jsonEncode(<String, String>{
              'userId': _userId,
              'orderSn': _orderSn,
            }));
      }
    });
  }

  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _orderSn = args.pgSn;

    return Scaffold(
      appBar: _setAppBar(),
      body: SafeArea(
        child: ListView(
          children: [
            _setSubTitle('결제 내역'),
            _setPaymentInfo(),
            _setSubTitle('환불 내역'),
            _setRefundInfo(),

            //무통장입금 환불 계좌정보 입력
            _setRefundBankTransfer(),
            const SizedBox(height: 20),

            _setBottomDesc(RString.pay_refund_guide1),
            _setBottomDesc(RString.pay_refund_guide2),
            _setBottomDesc(RString.pay_refund_guide3),
            const SizedBox(height: 40),
            _setSelectButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _setAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      elevation: 0,
      title: const Text(
        '해지하기',
        style: TStyle.title17,
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop('cancel');
            }),
        const SizedBox(width: 10),
      ],
    );
  }

  //결제 내역
  Widget _setPaymentInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '결제일시  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _orderDate,
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '상  품  명  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _pdName,
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '금        액  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _paymentAmt,
                style: TStyle.content16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //환불 내역
  Widget _setRefundInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '사용기간  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _useDays,
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '사용금액  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _useAmt,
                style: TStyle.content16,
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '환불수수료  ',
                style: TStyle.textGreyDefault,
              ),
              Text(
                _cancelFee,
                style: TStyle.content16,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: UIStyle.boxWeakGrey10(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  '환불금액  ',
                  style: TStyle.textGreyDefault,
                ),
                Text(
                  _refundAmt,
                  style: TStyle.content16,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //무통장
  Widget _setRefundBankTransfer() {
    return Visibility(
      visible: true, // _isBankTransfer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle('환불 계좌 정보'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            alignment: Alignment.centerLeft,
            decoration: UIStyle.boxRoundLine6(),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '환불 예정일  ',
                      style: TStyle.textGreyDefault,
                    ),
                    Text(
                      _useDays,
                      style: TStyle.content16,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '은  행  명  ',
                      style: TStyle.textGreyDefault,
                    ),
                    Container(
                      width: 150,
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          // filled: true,
                          // fillColor: Colors.black12,

                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 1.0,
                            ),
                          ),

                          // disabledBorder: OutlineInputBorder(
                          //   borderSide: BorderSide.none,
                          //   borderRadius: BorderRadius.circular(100),
                          //   //border-radius가 적용된다.
                          // ),

                          //포커스 됐을 때 스타일을 설정해준다.
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '계좌번호  ',
                      style: TStyle.textGreyDefault,
                    ),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '예  금  주  ',
                      style: TStyle.textGreyDefault,
                    ),
                    Container(
                      width: 150,
                      child: TextField(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                MaterialButton(
                  height: 40.0,
                  minWidth: 120.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: RColor.mainColor),
                  ),
                  color: RColor.mainColor,
                  textColor: Colors.white,
                  child: const Text(
                    "등록",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //하단 안내
  Widget _setBottomDesc(String content) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: Text(
        content,
        style: TStyle.defaultContent,
      ),
    );
  }

  //취소 / 확인 선택버튼
  Widget _setSelectButton() {
    return Visibility(
      visible: !_isBankTransfer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            height: 40.0,
            minWidth: 120.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: RColor.deepBlue),
            ),
            color: RColor.deepBlue,
            textColor: Colors.white,
            child: const Text(
              "취소",
              style: TextStyle(fontSize: 17),
            ),
            onPressed: () {
              Navigator.of(context).pop('cancel');
            },
          ),
          const SizedBox(width: 25),
          MaterialButton(
            height: 40.0,
            minWidth: 120.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: RColor.mainColor),
            ),
            color: RColor.mainColor,
            textColor: Colors.white,
            child: const Text(
              "확인",
              style: TextStyle(fontSize: 17),
            ),
            onPressed: () {
              _sendPayWebRefund();
            },
          ),
        ],
      ),
    );
  }

  // 결제웹에서 환불 처리
  void _sendPayWebRefund() {
    appGlobal.userId = _userId;
    appGlobal.payType = 'close';
    appGlobal.orderSn = _orderSn;
    appGlobal.lgTid = _lgTid;
    appGlobal.lgCancelAmt = _lgCancelAmt;
    // Navigator.push(context, new MaterialPageRoute(
    //   builder: (context) => PayWebPage(),
    // ));
    _navigateRefresh(context, const PayWebPage());
  }

  //결제웹 전달&리턴
  _navigateRefresh(BuildContext context, Widget instance) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => instance),
    );
    if (result == 'cancel') {
      DLog.d(PayCancelPage.TAG, '*** navigate cancel');
    } else if (result == 'success') {
      //해지환불 성공 -> 팝업 띄운후 페이지 종료
      DLog.d(PayCancelPage.TAG, '*** navigate success ***');
      _showDialogMsg('환불이 완료되었습니다.', '확인');
    } else if (result == 'fail') {
      DLog.d(PayCancelPage.TAG, '*** navigate fail ***');
      _showDialogMsg('환불이 실패했습니다.\n고객센터에 문의해주세요.', '확인');
    } else {}
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 10),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  //결제 완료시에만 사용 (결제 완료/실패 알림 -> 자동 페이지 종료)
  void _showDialogMsg(String message, String btnText) {
    showDialog(
        context: context,
        barrierDismissible: false,
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
                    _goPreviousPage();
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
                  const SizedBox(height: 15),
                  const Text(
                    '환불 안내',
                    style: TStyle.title20,
                  ),
                  const SizedBox(height: 30),
                  Text(message),
                  const SizedBox(height: 30),
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
                      _goPreviousPage();
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
    DLog.d(PayCancelPage.TAG, '$trStr $json');

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
    DLog.d(PayCancelPage.TAG, response.body);

    if (trStr == TR.ORDER05) {
      // final TrOrder05 resData = TrOrder05.fromJson(jsonDecode(response.body));
      final TrOrder05 resData = TrOrder05.fromJson(jsonDecode(resStr));
      if (resData.retCode == RT.SUCCESS) {
        Order05? item = resData.retData;
        if (item != null) {
          if (item.payMethod == 'PM20') {
            //현재 이용중, 무통장 결제, 환불가능금액 , 경우 환불 계좌 정보 입력 기능
            _isBankTransfer = true;
          }

          _orderDate = TStyle.getDateTimeFormat(item.orderDttm);
          _paymentAmt = '${TStyle.getMoneyPoint(item.paymentAmt)}원';
          _pdName = item.prodName;
          _useDays = '${item.usageDays}일';
          _useAmt = '${TStyle.getMoneyPoint(item.usageAmt)}원';
          _cancelFee = '${TStyle.getMoneyPoint(item.cancelFee)}원';
          _refundAmt = '${TStyle.getMoneyPoint(item.remainAmt)}원';
          _lgTid = item.transactId;
          _lgCancelAmt = item.remainAmt;

          setState(() {});
        }
      } else if (resData.retCode == RT.NO_DATA) {
        // if(orderList.length == 0) isNoData = true;
        // setState(() {});
      }
    } else if (trStr == '') {}
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop('complete'); //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });
  }

  String resStr = '''
  {
  "trCode": "TR_ORDER05",
  "retData": {
      "orderSn": "30392",
      "svcDivision": "S",
      "svcCondition": "U",
      "svcCondText": "이용중",
      
      "orderStatus": "OSR4",
      "orderStatText": "환불(전액)",
      "orderChannel": "CH32",
      "orderChanText": "Web > YNR",
      "prodCode": "AC_PR",
      "prodName": "프리미엄",
      "prodSubdiv": "M06",
      "prodSubdivName": "6개월 상품",
      "prodCateg": "AC",
      
      "startDate": "20240303",
      "endDate": "20240503",
      "pricePolicy": "",
      
      "orderDttm": "20211210092007",
      "paymentAmt": "338000",
      "subscriptStat": "N",
      "payMethod": "PM20",
      "transactId": "",
      
      "usageDays": "14",
      "usageMonth": "2",
      "usageAmt": "0",
      "cancelFee": "0",
      "remainAmt": "0"
    },
  "retCode": "0000",
  "retMsg": "success"
  }
  ''';
}
