import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_prom02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_page.dart';

import '../pay/pay_premium_page.dart';

/// 24.02.15 메인 > 팝업/배너 > 프로모션 페이지 > 결제 페이지 를 위한 프로모션 페이지
class PromotionPage extends StatefulWidget {
  //const PromotionPage({super.key});
  final String promotionCode;
  static const String TAG = "[PromotionPage]";
  static const String TAG_NAME = '프로모션_페이지';

  const PromotionPage({Key? key, required this.promotionCode})
      : super(key: key);

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  Prom02 prom02 = Prom02(
    title: '',
    buttonTxt: '',
    content: '',
    linkPage: '',
  );

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
        PromotionPage.TAG_NAME + widget.promotionCode);
    _fetchPostsProm02WithParse();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: prom02.title,
        elevation: 1,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Image.network(
                    prom02.content,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
            Container(
              color: RColor.mainColor,
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: InkWell(
                onTap: () async {
                  switch (prom02.linkPage) {
                    case 'LPH1':
                      {
                        Navigator.push(
                          context,
                          Platform.isIOS
                              ? CustomNvRouteClass.createRoute(
                                  const PayPremiumPage())
                              : CustomNvRouteClass.createRoute(
                                  const PayPremiumAosPage()),
                        );
                        break;
                      }
                    case 'LPH7':
                      {
                        _navigateRefreshPayPromotion(PgData(data: 'ad5'));
                        break;
                      }
                    case 'LPH8':
                      {
                        _navigateRefreshPayPromotion(PgData(data: 'ad4'));
                        break;
                      }
                    case 'LPH9':
                      {
                        _navigateRefreshPayPromotion(PgData(data: 'ad3'));
                        break;
                      }
                    case 'LPHA':
                      {
                        _navigateRefreshPayPromotion(PgData(data: 'at1'));
                        break;
                      }
                    case 'LPHB':
                      {
                        _navigateRefreshPayPromotion(PgData(data: 'at2'));
                        break;
                      }
                    case 'LPHD':
                      {
                        if (Platform.isAndroid) {
                          _navigateRefreshPayPromotion(PgData(data: 'new_6m'));
                        }
                        break;
                      }
                    case 'LPHE':
                      {
                        if (Platform.isAndroid) {
                          _navigateRefreshPayPromotion(
                              PgData(data: 'new_6m_50'));
                        }
                        break;
                      }
                    case 'LPHG':
                      {
                        if (Platform.isAndroid) {
                          _navigateRefreshPayPromotion(
                              PgData(data: 'new_6m_70'));
                        }
                        break;
                      }
                    case 'LPHF':
                      {
                        if (Platform.isAndroid) {
                          _navigateRefreshPayPromotion(PgData(data: 'new_7d'));
                        }
                        break;
                      }
                    default:
                      {
                        Navigator.pop(context);
                        basePageState.goLandingPage(
                            prom02.linkPage, '', '', '', '');
                      }
                  }
                },
                child: Center(
                  child: Text(
                    prom02.buttonTxt,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchPostsProm02WithParse() async {
    var url = Uri.parse(Net.TR_BASE + TR.PROM02);
    try {
      final http.Response response = await http
          .post(
            url,
            body: jsonEncode(<String, String>{
              'userId': AppGlobal().userId,
              'viewPage': widget.promotionCode,
              'promoDiv': '',
            }),
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      final TrProm02 resData = TrProm02.fromJson(jsonDecode(response.body));
      DLog.e('prom02 ${resData.retData.toString()}');
      if (resData.retCode == RT.SUCCESS &&
          resData.retData.isNotEmpty &&
          mounted) {
        prom02 = resData.retData[0];
        setState(() {});
      } else {
        if (mounted) {
          Navigator.pop(context, null);
        }
      }
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _navigateRefreshPayPromotion(PgData pgData) async {
    Navigator.push(
      context,
      Platform.isIOS
          ? CustomNvRouteClass.createRouteData(
              const PayPremiumPromotionPage(),
              RouteSettings(
                arguments: pgData,
              ),
            )
          : CustomNvRouteClass.createRouteData(
              const PayPremiumPromotionAosPage(),
              RouteSettings(
                arguments: pgData,
              ),
            ),
    );
  }
}
