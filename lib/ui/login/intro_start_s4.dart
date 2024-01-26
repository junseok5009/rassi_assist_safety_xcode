import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rassi_assist/common/common_function_class.dart';
import 'package:rassi_assist/common/const.dart';

class IntroStartS4 extends StatefulWidget {
  const IntroStartS4({Key? key}) : super(key: key);

  //const IntroStartS4({super.key});

  @override
  State<IntroStartS4> createState() => _IntroStartS4State();
}

class _IntroStartS4State extends State<IntroStartS4> {
  final GlobalKey _containerKey = GlobalKey();
  Size _containerSize = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _containerSize = CommonFunctionClass.instance.getSize(_containerKey);
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          textAlign: TextAlign.start,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'NotoSansKR',
            ),
            children: [
              TextSpan(
                text: '시장의 주류',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: RColor.purpleBasic_6565ff,
                ),
              ),
              TextSpan(
                text: '를 알고 싶다면\n이슈와 테마\n',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text:
                    "\n실시간 업데이트 되는 '오늘의 이슈'\n대장주와 추세를 분석하는 '테마주도주'\n시장을 움직이는 주류와 관련 종목을\n알려드립니다.",
                style: TextStyle(
                  //본문 내용 - 기준
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          flex: 1,
          child: Container(
            key: _containerKey,
            //height: double.infinity,
            alignment: Alignment.centerRight,
            //color: Colors.red,
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    width: double.infinity,
                    height: _containerSize.height,
                    //color: Colors.yellow,
                    child: AnimatedFractionallySizedBox(
                      widthFactor: _containerSize.width != 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 1500),
                      child: Image.asset(
                        'images/icon_intro_start4_1.png',
                        //width: AppGlobal().deviceWidth / 4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 120,
        ),
      ],
    );
  }

  //  진한 빨강
  _setRedCircle1(String title, double fontSize) {
    return Container(
      decoration: const BoxDecoration(
        color: RColor.bubbleChartStrongRed,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
