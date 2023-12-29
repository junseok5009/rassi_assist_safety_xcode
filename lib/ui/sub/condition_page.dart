import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/signal/signal_top_m_page.dart';

import '../common/common_appbar.dart';

/// 2022.01.12
/// 조건 탐색 캐치
class ConditionPage extends StatefulWidget {
  static const routeName = '/page_condition';
  static const String TAG = "[ConditionPage]";
  static const String TAG_NAME = '조건탐색캐치_목록';

  @override
  State<StatefulWidget> createState() => ConditionPageState();
}

class ConditionPageState extends State<ConditionPage> {
  var appGlobal = AppGlobal();
  bool _isFreeVisible = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: ConditionPage.TAG_NAME,
      screenClassOverride: ConditionPage.TAG_NAME,
    );
    if (!appGlobal.isPremium) _isFreeVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.basic(context, '조건 탐색 캐치'),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            children: [
              // Find01 (기존)
              _setConditionTile(
                  "최근 3일 매수 후 급등 종목", RString.desc_find_01, 'CUR_B'),
              // Find07
              _setConditionTile(
                  "평균 보유 기간 짧은 종목", RString.desc_find_07, 'SHT_S'),
              // Find08
              // _setConditionTile("평균 관망 기간을 50% 이상 초과한 종목", RString.desc_find_08, 'PSS_S'),
              // Find09
              _setConditionTile(
                  "라씨 매매비서의 주간 토픽 중 최근 매수 종목", RString.desc_find_09, 'TPC_S'),
              // Find02 (기존)
              _setConditionTile(
                  "적중률 TOP 중 최근 3일 매수 종목", RString.desc_find_02, 'HIT_H'),
              // Find03 (기존)
              _setConditionTile(
                  "적중률 TOP 중 관망 종목", RString.desc_find_03, 'HIT_W'),
              // Find04 (기존)
              _setConditionTile(
                  "평균수익률 TOP 중 최근 3일 매수 종목", RString.desc_find_04, 'AVG_H'),
              // Find05 (기존)
              _setConditionTile(
                  "평균수익률 TOP 중 관망 종목", RString.desc_find_05, 'AVG_W'),
              const SizedBox(
                height: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 소항목 타이틀 (+ 더보기)
  Widget _setConditionTile(String subTitle, String desc, String type) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      decoration: UIStyle.boxRoundLine6(),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subTitle,
                style: TStyle.commonTitle15,
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                desc,
                style: TStyle.contentGrey14,
              )
            ],
          ),
        ),
        onTap: () {
          if (_isFreeVisible) {
            if (type == 'CUR_B') {
              // FIND01 - 3일내에 매수 후 급등
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else {
              _showDialogPremium();
            }
          } else {
            if (type == 'CUR_B') {
              // FIND01 - 3일내에 매수 후 급등
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'HIT_H') {
              // FIND02 - 적중률 높은 최근 매수
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'HIT_W') {
              // FIND03 - 적중률 높은 최근 관망
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'AVG_H') {
              // FIND04 - 평균수익률 높은 최근 매수
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'AVG_W') {
              // FIND05 - 평균수익률 높은 관망
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'SHT_S') {
              // FIND07 - 평균보유기간 짧은 종목
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'PSS_S') {
              // FIND08 - 평균 관망 기간을 50% 초과한 종목
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            } else if (type == 'TPC_S') {
              // FIND09 - 주간 토픽 중 최근 매수 종목
              basePageState.callPageRouteData(
                  SignalMTopPage(), PgData(pgData: type));
            }
          }
        },
      ),
    );
  }

  //페이지 전환 에니메이션
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

  _navigateRefreshPay(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, _createRoute(instance));
    if (result == 'cancel') {
      DLog.d(ConditionPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(ConditionPage.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.USER04,
      //     jsonEncode(<String, String>{
      //       'userId': _userId,
      //     }));
    }
  }

  //프리미엄 가입하기 다이얼로그
  void _showDialogPremium() {
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
                  height: 25.0,
                ),
                const Text(
                  '안내',
                  style: TStyle.title20,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  '매매비서 프리미엄에서\n이용할 수 있는 정보입니다.',
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  '프리미엄으로 업그레이드 하시고 더 완벽하게 이용해 보세요.',
                  textAlign: TextAlign.center,
                  textScaleFactor: Const.TEXT_SCALE_FACTOR,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                MaterialButton(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: RColor.deepBlue,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: const Center(
                        child: Text(
                          '프리미엄 가입하기',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Platform.isIOS
                        ? _navigateRefreshPay(context, PayPremiumPage())
                        : _navigateRefreshPay(context, PayPremiumAosPage());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
