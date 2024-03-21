import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_pay.dart';
import 'package:rassi_assist/ui/pay/pay_web_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.12.15
/// 정기 결제 해지/환불 정보
class PaySubCancelPage extends StatelessWidget {
  static const routeName = '/page_pay_sub_cancel';
  static const String TAG = "[PaySubCancelPage]";
  static const String TAG_NAME = '정기결제해지';

  const PaySubCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const PaySubCancelWidget(),
      ),
    );
  }
}

class PaySubCancelWidget extends StatefulWidget {
  const PaySubCancelWidget({super.key});

  @override
  State<StatefulWidget> createState() => PaySubCancelState();
}

class PaySubCancelState extends State<PaySubCancelWidget> {
  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';

  late PgPay args;
  String _orderSn = '';
  String _nextPayDate = '';
  String _usePeriod = '';
  bool isLayerFirst = true;
  String _lgTid = '';


  @override
  void initState() {
    super.initState();
    _loadPrefData();
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
    args = ModalRoute.of(context)!.settings.arguments as PgPay;
    _orderSn = args.orderSn;
    _nextPayDate = args.nextPayDay;
    _usePeriod = args.period;
    _lgTid = args.lgTid;
    // DLog.d(PaySubCancelPage.TAG, _orderSn + '|' + _nextPayDate + '|' + _usePeriod + '|' + _lgTid);

    return Scaffold(
      appBar: _setAppBar(),

      body: SafeArea(
        child: ListView(
          children: [
            _setLayer1(),
            _setLayer2(),
            _setSelectButton(),
            const SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }

  //해지 전 화면1
  Widget _setLayer1() {
    return Visibility(
      visible: isLayerFirst,
      child: Column(
        children: [
          const SizedBox(height: 20.0,),
          const Text('해지 전 확인해 주세요!', style: TStyle.title18,),
          const SizedBox(height: 20.0,),
          const Text('프리미엄 계정을 해지하시면\n아래 서비스를 더 이상 이용할 수 없어요.',
            textAlign: TextAlign.center, style: TStyle.textGreyDefault,),
          const SizedBox(height: 20.0,),

          _setBoxDesc('오직 회원님만을 위한 AI매도신호'),
          _setBoxDesc('AI매매신호 실시간 알림 푸시'),
          _setBoxDesc('전종목 AI매매신호 무제한 이용'),
          _setBoxDesc('MY포켓 종목 마음껏 추가 관리'),
          _setBottomDesc(),
        ],
      ),
    );
  }

  //해지 전 화면2
  Widget _setLayer2() {
    String nextDay = TStyle.getDateSFormat(_nextPayDate);
    return Visibility(
      visible: !isLayerFirst,
      child: Column(
        children: [
          const SizedBox(height: 20.0,),
          const Text(
            '해지를 하시면,\n'
                '다음 결제 예정일에 결제가 갱신되지 않으며,\n'
                '이후 서비스 갱신이 모두 종료됩니다.',
            textAlign: TextAlign.center,
            style: TStyle.subTitle16,),
          const SizedBox(height: 20.0,),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
                color: RColor.bgWeakGrey,
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            alignment: Alignment.center,
            child: Text('다음 결제 예정일\n$nextDay',
              textAlign: TextAlign.center, style: TStyle.defaultTitle,),
          ),
          const SizedBox(height: 15.0,),

          const Text(
            '해지를 하시면, 기존 이용기간이 종료되면\n'
                '자동으로 베이직 계정으로 변경됩니다.\n'
                '남아있는 서비스 이용기간을 확인해 주세요.',
            textAlign: TextAlign.center,
            style: TStyle.textGrey15,),
          const SizedBox(height: 20.0,),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
                color: RColor.bgWeakGrey,
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            alignment: Alignment.center,
            child: Text('서비스 이용 기간\n$_usePeriod',
              textAlign: TextAlign.center, style: TStyle.defaultTitle,),
          ),
          const SizedBox(height: 30.0,),
        ],
      ),
    );
  }

  PreferredSizeWidget _setAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      elevation: 0,
      title: const Text('정기결제 해지하기', style: TStyle.title17,),
      actions: [
        IconButton(icon: const Icon(Icons.close),
          color: Colors.black,
          onPressed: (){
            Navigator.of(context).pop('cancel');
          }),
        const SizedBox(width: 10.0,),
      ],
    );
  }


  Widget _setBoxDesc(String title) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0,),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.center,
      decoration: UIStyle.boxRoundLine20(),
      child: Text(title, style: TStyle.title20,),
    );
  }

  //하단 안내
  Widget _setBottomDesc() {
    return Column(
      children: const [
        SizedBox(height: 20.0,),
        Text('라씨 매매비서의 AI는 매일매일 학습되고\n업그레이드 되고 있습니다.',
          textAlign: TextAlign.center, style: TStyle.defaultContent,),
        SizedBox(height: 20.0,),
        Text('라씨 매매비서 AI의 업그레이드 현황은\nMY 하단 \"라씨 매매비서 AI엔진 히스토리\"에서\n확인하실 수 있습니다.',
          textAlign: TextAlign.center, style: TStyle.defaultContent,),
        SizedBox(height: 30.0,),
      ],
    );
  }

  //구독 / 해지 선택버튼
  Widget _setSelectButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          height: 40.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: RColor.deepBlue)),
          color: RColor.deepBlue,
          textColor: Colors.white,
          child: const Text("  구독 유지하기  ", style: TextStyle(fontSize: 17),
              textScaleFactor: Const.TEXT_SCALE_FACTOR),
          onPressed: () {
            Navigator.of(context).pop('cancel');
          },
        ),
        const SizedBox(width: 25),
        MaterialButton(
          height: 40.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: RColor.mainColor)),
          color: RColor.mainColor,
          textColor: Colors.white,
          child: const Text("  해지하기  ", style: TextStyle(fontSize: 17),
              textScaleFactor: Const.TEXT_SCALE_FACTOR),
          onPressed: () {
            _convertLayer2();
          },
        ),
      ],
    );
  }

  void _convertLayer2() {
    if(isLayerFirst) {
      setState(() {
        isLayerFirst = false;
      });
    } else {
      _sendPayWebRefund();
    }
  }

  // 결제웹에서 환불 처리
  void _sendPayWebRefund() {
    appGlobal.userId = _userId;
    appGlobal.payType = 'close';
    appGlobal.orderSn = _orderSn;
    appGlobal.lgTid = _lgTid;
    appGlobal.lgCancelAmt = '0';
    // Navigator.push(context, new MaterialPageRoute(
    //   builder: (context) => PayWebPage(),
    // ));
    _navigateRefresh(context, PayWebPage());
  }

  //결제웹 전달&리턴
  _navigateRefresh(BuildContext context, Widget instance) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => instance));
    if(result == 'cancel') {
      DLog.d(PaySubCancelPage.TAG, '*** navigate cancel');
    }
    else if(result == 'success') {
      //해지환불 성공 -> 팝업 띄운후 페이지 종료
      DLog.d(PaySubCancelPage.TAG, '*** navigate success ***');
      _showDialogMsg('정기결제 해지가 완료되었습니다.', '확인');
    }
    else if(result == 'fail') {
      DLog.d(PaySubCancelPage.TAG, '*** navigate fail ***');
      _showDialogMsg('정기결제 해지가 실패했습니다.\n고객센터에 문의해주세요.', '확인');
    }
    else {
    }
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
                  child: const Icon(Icons.close, color: Colors.black,),
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
                  Image.asset('images/rassibs_img_infomation.png',
                    height: 60, fit: BoxFit.contain,),
                  const SizedBox(height: 15.0,),
                  const Text('해지 안내',
                    style: TStyle.title20,
                    ),
                  const SizedBox(height: 30.0,),
                  Text('$message', ),
                  const SizedBox(height: 30.0,),
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
                          child: Text(btnText, style: TStyle.btnTextWht16,
                            ),),
                      ),
                    ),
                    onPressed: (){
                      _goPreviousPage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //완료, 실패 알림 후 페이지 자동 종료
  void _goPreviousPage() {
    Future.delayed(const Duration(milliseconds: 500), (){
      Navigator.of(context).pop('complete');    //null 자리에 데이터를 넘겨 이전 페이지 갱신???
    });
  }
}