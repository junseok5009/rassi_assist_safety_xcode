import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';

class AgentWelcomeFirstPage extends StatelessWidget {
  const AgentWelcomeFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '환영합니다!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\n라씨 매매비서와 함께\n주식투자를 쉽게 해보실까요?\n\n핵심 정보들을 확인하세요!',
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
            Container(
              width: double.infinity,
              height: (AppGlobal().deviceHeight / 2),
              padding: const EdgeInsets.only(bottom: 30),
              child: Swiper(
                  loop: false,
                  autoplay: false,
                  //autoplayDelay: 4000,
                  itemHeight: (AppGlobal().deviceHeight / 2) - 30,
                  pagination: CommonSwiperPagenation.getNormalSpWithMargin2(
                    7,
                    0,
                    //(AppGlobal().deviceHeight / 2) - 20,
                    RColor.purpleBasic_6565ff,
                  ),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return _child0;
                    } else if (index == 1) {
                      return _child1;
                    } else if (index == 2) {
                      return _child2;
                    } else if (index == 3) {
                      return _child3;
                    } else if (index == 4) {
                      return _child4;
                    } else{
                      return _child0;
                    }
                  }),
            ),
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
      decoration: UIStyle.boxRoundFullColor50c(
        RColor.greyBox_dcdfe2,
      ),
      child: Column(
        children: [
          Text(
            title1,
            style: TextStyle(
              fontSize: 14,
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
          Expanded(
            child: Image.asset(
              imagePath,
            ),
          ),
          Text(
            title3,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            title4,
            style: TextStyle(
              fontSize: 15,
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

  Widget get _child1 {
    return _childContainer(
      title1: '매도가 곧 수익! 매도를 잘하는 AI',
      title2: "오직 한 사람을 위한 '나만의 매도신호'",
      title3: '보유 종목이 있으신가요?',
      title4: '매수가 입력 한번만 해보세요!',
      imagePath: 'images/icon_intro_start1_2.png',
    );
  }

  Widget get _child2 {
    return _childContainer(
      title1: '상승할 종목을 찾아라!',
      title2: "큰손들의 '종목캐치'",
      title3: '시장들의 큰손들과',
      title4: '라씨 매매신호가 함께 매수하는 종목은 무엇?',
      imagePath: 'images/icon_intro_start1_2.png',
    );
  }

  Widget get _child3 {
    return _childContainer(
      title1: '매일 매일 AI가 빠르게 시장 분석!',
      title2: "오늘의 이슈를 한눈에 '마켓뷰'",
      title3: '지금 시장의 핫이슈와',
      title4: '관련 종목은 무엇?',
      imagePath: 'images/icon_intro_start1_2.png',
    );
  }

  Widget get _child4 {
    return _childContainer(
      title1: '시각화된 종목정보',
      title2: "접근이 다른 종목정보 '종목 인사이트'",
      title3: '종목정보도 시각화해서 보세요.',
      title4: '영향을 주는 정보를 통찰할 수 있습니다.',
      imagePath: 'images/icon_intro_start1_2.png',
    );
  }
}
