import 'package:flutter/material.dart';
import 'package:rassi_assist/common/ui_style.dart';


/// 결제하지 않은 회원에게 보여지는 카드
class CardReqPay extends StatelessWidget {
  const CardReqPay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
      padding: const EdgeInsets.all(15.0,),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/rassi_itemar_icon_ar_wch.png', height: 40,),
          const SizedBox(height: 10.0,),
          const Text('AI매매신호는 매일 5종목까지 무료로 제공됩니다.'
              '\n프리미엄 계정으로 가입하여 확인해 보시겠어요?',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}