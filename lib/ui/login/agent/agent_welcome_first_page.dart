import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';

class AgentWelcomeFirstPage extends StatelessWidget {
  const AgentWelcomeFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Swiper(
          loop: false,
          autoplay: false,
          //autoplayDelay: 4000,
          //itemHeight: (AppGlobal().deviceHeight / 2) - 30,
          pagination: CommonSwiperPagenation.getNormalSpWithMargin2(
            6,
            0,
            //(AppGlobal().deviceHeight / 2) - 20,
            RColor.purpleBasic_6565ff,
          ),
          itemCount: 6,
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
            } else if (index == 5) {
              return _child5;
            } else {
              return _child0;
            }
          }),
    );
  }

  Widget _childContainer({
    required int index,
    required String title1,
    required String title2,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.only(bottom: 60),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  title1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  title2,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: index == 0
                    ? (AppGlobal().deviceWidth - 40) * 1.1 / 2
                    : index == 1
                        ? (AppGlobal().deviceWidth - 40) * 1.3 / 2
                        : index == 2
                            ? (AppGlobal().deviceWidth - 40) * 1.4 / 2
                            : index == 3
                                ? (AppGlobal().deviceWidth - 40) * 1.5 / 2
                                : index == 4
                                    ? (AppGlobal().deviceWidth - 40) * 4 / 5
                                    : index == 5
                                        ? (AppGlobal().deviceWidth - 40) * 1.3 / 2
                                        : (AppGlobal().deviceWidth - 40) * 3 / 5,
                child: Image.asset(
                  imagePath,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _child0 {
    return _childContainer(
      index: 0,
      title1: '환영합니다!',
      title2: '라씨 매매비서와 함께\n주식투자를 쉽게 해보실까요?\n핵심정보들을 확인하세요!',
      imagePath: 'images/icon_agent_w_f1.png',
    );
  }

  Widget get _child1 {
    return _childContainer(
      index: 1,
      title1: 'AI매매신호',
      title2: 'AI가 알려주는 수익나는\n매매타이밍을 확인해 보세요.',
      imagePath: 'images/icon_agent_w_f2.png',
    );
  }

  Widget get _child2 {
    return _childContainer(
      index: 2,
      title1: '나만의 매도신호',
      title2: '매수가만 입력하면\n오직 한 사람을 위해 AI가 분석합니다.',
      imagePath: 'images/icon_agent_w_f3.png',
    );
  }

  Widget get _child3 {
    return _childContainer(
      index: 3,
      title1: '종목캐치',
      title2: '상승할 종목을 찾아라,\n뭘 살지 모르겠다면 지금 확인하세요.',
      imagePath: 'images/icon_agent_w_f4.png',
    );
  }

  Widget get _child4 {
    return _childContainer(
      index: 4,
      title1: '마켓뷰',
      title2: '매일 매일 AI가 빠르게 시장을 분석!\n오늘의 이슈를 한눈에 확인하세요.',
      imagePath: 'images/icon_agent_w_f5.png',
    );
  }

  Widget get _child5 {
    return _childContainer(
      index: 5,
      title1: '종목인사이트',
      title2: '시각화된 종목정보로\n한눈에 쉽게 보세요.',
      imagePath: 'images/icon_agent_w_f6.png',
    );
  }
}
