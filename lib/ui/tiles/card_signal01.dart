import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal01.dart';


// (위젯 크기가 확장될 경우 적용 안됨)
// TODO statefulWidget 으로 바꾸면 될듯한데 퍼포먼스 측면에서 테스트 필요.
// TODO 또는 Align 으로 감싸는 방법도 또는 Extend , Expanded???
class CardSignal01 extends StatelessWidget {
  final Signal01 item;

  CardSignal01({required this.item});

  String prePrc = "";           //매수가 or 매도가
  String stkPrc = "";
  String stkProfit = "";        //수익률
  String holdDays = "";         //보유중 0일째 (매도 전 보유기간)
  String holdPeriod = "";       //지난 거래 전 보유기간
  String dateTime = "";
  String statTxt = "";

  bool bOffHoldDays = false;        //보유일 표시
  bool isTodayTrade = false;        //당일매매 표시
  bool isTodayTag = false;          //Today 매수/매도
  bool isHoldingStk = false;        //보유중
  Color statColor = Colors.grey;    //신호 분류에 따른 컬러(보유중, 관망중...)
  Color profitColor = Colors.grey;  //수익률 컬러
  String imgTodayTag = 'images/main_icon_today_buy.png';


  @override
  Widget build(BuildContext context) {
    _setSignal01(item);

    return Stack(
      children: [
        _setStatusCard(),
        Visibility(
          visible: isTodayTag,
          child: Positioned(top: 25, right: 16,
            child: Image.asset(imgTodayTag, height: 23,),),),
      ],
    );
  }

  Widget _setStatusCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: UIStyle.boxWithOpacity(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setCircleText(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Visibility(
                    visible: isTodayTag,
                    child:  const SizedBox(height: 25,),),
                  Visibility(
                    visible: isHoldingStk,
                    child: Row(
                      children: [
                        const Text('수익률',),
                        const SizedBox(width: 4.0,),
                        Text('$stkProfit', style: TextStyle(
                          color: profitColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),),
                      ],
                    ),
                  ),
                  //관망중
                  Visibility(
                    visible: !isHoldingStk && !isTodayTrade,
                    child: Row(
                      children: [
                        const Text('관망 ',),
                        const SizedBox(width: 4.0,),
                        Text('$holdDays일째',
                          style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0,),

                  Visibility(
                    visible: isHoldingStk,
                    child: Row(
                      children: [
                        const Text('보유 ',),
                        Text(holdDays, style: TStyle.subTitle,),
                        const Text('일째',),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('$prePrc '),
                      Text(TStyle.getMoneyPoint(stkPrc),
                        style: TStyle.subTitle,),
                      const Text('원'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('발생 '),
                      Text(TStyle.getDateFormat(dateTime),
                        style: TStyle.subTitle,),
                    ],
                  ),

                ],
              ),
            ],
          ),
          // _setPeriodRate(),
        ],
      ),
    );
  }

  Widget _setCircleText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(color: statColor, shape: BoxShape.circle,),
      child: Center(
        child: Text('$statTxt', style: TStyle.btnTextWht20,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  //매매신호 Status
  void _setSignal01(Signal01 data) {
    if(data.signalData?.tradeFlag == 'B') {        //당일매수
      statTxt = '매수';
      statColor = RColor.sigBuy;
      prePrc = '매수가';
      isTodayTag = true;
      bOffHoldDays = true;
      imgTodayTag = 'images/main_icon_today_buy.png';
    } else if(data.signalData?.tradeFlag == 'H') {  //보유중
      statTxt = '보유중';
      statColor = RColor.sigHolding;
      prePrc = '매수가';
      isHoldingStk = true;
    } else if(data.signalData?.tradeFlag == 'S') {  //당일매도
      statTxt = '매도';
      statColor = RColor.sigSell;
      prePrc = '매도가';
      isTodayTag = true;
      bOffHoldDays = true;
      isTodayTrade = true;
      isHoldingStk = false;
      imgTodayTag = 'images/main_icon_today_sell.png';
    } else if(data.signalData?.tradeFlag == 'W') { //관망중
      statTxt = '관망중';
      statColor = RColor.sigWatching;
      prePrc = '매도가';
      isHoldingStk = false;
    }

/*    if(data.signalData.profitRate.contains('-')) {
      stkProfit = '${data.signalData.profitRate}%';
      profitColor = RColor.sigSell;
    } else {
      stkProfit = '+${data.signalData.profitRate}%';
      profitColor = RColor.sigBuy;
    }

    holdDays = data.signalData.elapsedDays;
    holdPeriod = data.signalData.termOfTrade;
    stkPrc = '${data.signalData.tradePrc}';
    dateTime = data.signalData.tradeDate + data.signalData.tradeTime;*/
    // setState(() {});
  }
}