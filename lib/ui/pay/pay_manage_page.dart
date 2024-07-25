import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_pay.dart';
import 'package:rassi_assist/models/tr_order/tr_order02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/pay/pay_cancel_sub.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.10.07
/// 정기결제 내역
class PayManagePage extends StatefulWidget {
  static const routeName = '/page_pay_manage';
  static const String TAG = "[PayManagePage]";
  static const String TAG_NAME = 'MY_정기결제관리';

  const PayManagePage({super.key});

  @override
  State<StatefulWidget> createState() => PayManagePageState();
}

class PayManagePageState extends State<PayManagePage> {
  late SharedPreferences _prefs;
  String _userId = "";

  bool isNoData = false;
  bool _isInAppPay = false;
  List<Order02> orderList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      PayManagePage.TAG_NAME,
    );
    _loadPrefData().then((value) {
      if (_userId != '') {
        _fetchPosts(
            TR.ORDER02,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      }
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '정기결제 관리',
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return _setTileOrder02(orderList[index]);
                  },
                ),
                Visibility(
                  visible: _isInAppPay,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    child: Text(
                      Platform.isIOS ? RString.desc_in_app_cancel : RString.desc_in_app_cancel_aos,
                      style: TStyle.content17T,
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isNoData,
              child: Container(
                margin: const EdgeInsets.only(top: 40.0),
                width: double.infinity,
                alignment: Alignment.topCenter,
                child: const Text(
                  '이용중인 정기결제 상품이 없습니다',
                  style: TStyle.defaultContent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setTileOrder02(Order02 item) {
    String period = '';
    period = '${TStyle.getDateSFormat(item.startDate)} ~ '
        '${TStyle.getDateSFormat(item.endDate)}';

    bool isClosed = false;
    if (item.svcCondition == 'C') isClosed = true;

    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Container(
        margin: const EdgeInsets.only(top: 7.0),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3), //changes position of shadow
            )
          ],
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      item.prodName,
                      style: TStyle.titleGrey,
                    ),
                  ),
                  const Text(
                    '(정기결제)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xdd555555),
                    ),
                  ),
                  const SizedBox(height: 3),
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
                      const SizedBox(width: 4),
                      Text(
                        period,
                        style: TStyle.defaultContent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: UIStyle.boxWeakGrey10(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Visibility(
                      visible: !isClosed,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            child: const Text(
                              '다음 결제 예정일',
                              style: TStyle.textGrey15,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            TStyle.getDateMdKorFormat(item.nextPayDate, isZeroVisible : true),
                            style: TStyle.defaultContent,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isClosed,
                      child: InkWell(
                        child: const Text(
                          '- 정기결제 해지하기 ',
                          style: TStyle.textGrey14,
                        ),
                        onTap: () {
                          DLog.d(PayManagePage.TAG, '정기결제 해지하기 클릭, orderChannel : ${item.orderChannel}');
                          if (item.orderChannel == 'CH33') {
                            _showRefundInfo(item.csPhoneNo);
                          } else if (item.orderChannel == 'CH32') {
                            String period = '${TStyle.getDateSFormat(item.startDate)}~'
                                '${TStyle.getDateSFormat(item.endDate)}';
                            _goRefundPage(item.orderSn, item.nextPayDate, period, item.transactId);
                          }
                        },
                      ),
                    ),
                    Visibility(
                      visible: isClosed,
                      child: const Text(
                        '해지된 상품입니다',
                        style: TStyle.textGrey14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goRefundPage(String orderSn, String nextPayDay, String usePeriod, String tid) {
    _navigateRefresh(context, const PaySubCancelPage(),
        RouteSettings(arguments: PgPay(orderSn: orderSn, nextPayDay: nextPayDay, period: usePeriod, lgTid: tid)));
  }

  _navigateRefresh(BuildContext context, Widget instance, RouteSettings settings) async {
    final result = await Navigator.push(context, _createRouteData(instance, settings));
    if (result == 'cancel') {
      DLog.d(PaySubCancelPage.TAG, '*** navigate cancel ***');
    } else {
      DLog.d(PaySubCancelPage.TAG, '*** navigateRefresh');
      orderList.clear();
      _fetchPosts(
          TR.ORDER02,
          jsonEncode(<String, String>{
            'userId': _userId,
          }));
    }
  }

  //페이지 전환 에니메이션
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
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
                const SizedBox(height: 15),
                const Text(
                  '해지안내',
                  style: TStyle.title20,
                ),
                const SizedBox(height: 30),
                const Text(
                  '해당 상품의 해지문의는\n 결제 고객센터로 연결해 주세요.',
                  textAlign: TextAlign.center,
                  style: TStyle.defaultContent,
                ),
                const SizedBox(height: 30),
                const Text(
                  '결제 고객센터',
                  style: TStyle.defaultContent,
                ),
                const SizedBox(height: 5),
                Text(
                  number,
                  style: TStyle.title22,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
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
                  const SizedBox(height: 5),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PayManagePage.TAG, '$trStr $json');

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
      DLog.d(PayManagePage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(PayManagePage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PayManagePage.TAG, response.body);

    if (trStr == TR.ORDER02) {
      // final TrOrder02 resData = TrOrder02.fromJson(jsonDecode(_resStr)); //TEST DATA
      final TrOrder02 resData = TrOrder02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        isNoData = false;
        orderList = resData.listData;
        if (orderList.isNotEmpty) {
          Order02 item = orderList.first;
          if (item.payMethod == 'PM60' || item.payMethod == 'PM50') {
            //인앱결제(ios) or Android
            _isInAppPay = true;
          }
        }
        setState(() {});
      } else if (resData.retCode == RT.NO_DATA) {
        if (orderList.isEmpty) isNoData = true;
        setState(() {});
      }
    }
  }

}
