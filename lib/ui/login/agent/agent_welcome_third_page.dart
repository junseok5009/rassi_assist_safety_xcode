import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';

class AgentWelcomeThirdPage extends StatelessWidget {
  const AgentWelcomeThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              '확인하세요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              decoration: UIStyle.boxRoundFullColor16c(
                RColor.greyBox_f5f5f5,
              ),
              child: ListView(
                children: [
                  setTitleTextWidget('수익률을 보장하지는 않습니다.'),
                  const SizedBox(
                    height: 5,
                  ),
                  setContentTextWidget('주식시장에서 100%는 없습니다. 그렇기 때문에 라씨 매매비서도 수익률을 보장하지는 않습니다. '
                      '그러나 라씨 매매비서는 백데스트 기간 5년, 실전매매 기간 3년 동안 시장대비 종목별로 평균 +**%의 수익률을 달성하였습니다.'),
                  const SizedBox(
                    height: 15,
                  ),
                  setTitleTextWidget('매매에 대한 최종 선택은 투자자님의 판단에 따릅니다.'),
                  const SizedBox(
                    height: 5,
                  ),
                  setContentTextWidget('정보 이용에 따른 최종 투자 판단과 매매결정은 투자자님의 선택이며 '
                      '이에 따르는 투자 책임은 투자자님 본인에게 있습니다.'),
                  const SizedBox(
                    height: 15,
                  ),
                  setTitleTextWidget('무단 복사, 전재할 수 없습니다.'),
                  const SizedBox(
                    height: 5,
                  ),
                  setContentTextWidget('앱 내 모든 정보는 무단 복사 및 전재를 하실 수 없으며, '
                      '또한 모든 정보는 오류 및 지연이 있을 수 있습니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setTitleTextWidget(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget setContentTextWidget(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }
}
