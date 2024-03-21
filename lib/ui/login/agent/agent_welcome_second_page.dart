import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';

class AgentWelcomeSecondPage extends StatelessWidget {
  const AgentWelcomeSecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '꼭! 이용해 보세요!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '라씨와 함께하는 POINT!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(),
          ],
        ),
      ],
    );
  }

  Widget _childContainer({
    required String title1,
    required String title2,
    required String title3,
    required String title4,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: UIStyle.boxRoundFullColor8c(
        RColor.greyBox_dcdfe2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title1,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            title2,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _child0 {
    return _childContainer(
      title1: '언제 살까? 언제 팔까? 고민 끝!',
      title2: "전 종목에 대한 'AI매매신호'",
      title3: '지금 검색창에서 매매타이밍이',
      title4: '궁금한 종목을 바로 검색해 보세요!',
      imagePath: 'images/icon_intro_start1_2.png',
    );
  }

}
