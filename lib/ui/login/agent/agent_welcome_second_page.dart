import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';

class AgentWelcomeSecondPage extends StatelessWidget {
  const AgentWelcomeSecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  '꼭! 이용해 보세요!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '라씨와 함께하는 ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'POINT',
                        style: TextStyle(
                          color: RColor.purpleBasic_6565ff,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _child0,
                const SizedBox(height: 20,),
                _child1,
                const SizedBox(height: 20,),
                _child2,
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _childContainer({
    required String title1,
    required String title2,
    required String title3,
  }) {
    return Container(
      width: double.infinity,
      //height: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: UIStyle.boxRoundFullColor16c(
        RColor.greyBox_f5f5f5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: title1,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' ',
                  style: TextStyle(
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
                TextSpan(
                  text: title2,
                  style: TextStyle(
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Text(title3, style: TextStyle(fontSize: 16,),),
        ],
      ),
    );
  }

  Widget get _child0 {
    return _childContainer(
      title1: '종목 관리는',
      title2: '포켓',
      title3: '24시간 관심종목을 모니터링 하여 AI매매신호를 포함 다양한 종목 이벤트를 알려드립니다.'
    );
  }

  Widget get _child1 {
    return _childContainer(
        title1: '매수의 치트키는',
        title2: '종목캐치',
        title3: '큰손들과 라씨가 함께 매수하는 종목 라씨 성과가 뛰어난 종목의 신규 매수 신호를 바로 확인해 보세요.'
    );
  }

  Widget get _child2 {
    return _childContainer(
        title1: '매도의 치트키는',
        title2: '나만의 매도신호',
        title3: '매수가 입력 한 번으로 내 매수 정보에 꼭 맞춘 나만의 매도신호를 만들어 보세요. AI가 오직 한 사람을 위해 분석을 시작합니다.'
    );
  }

}
