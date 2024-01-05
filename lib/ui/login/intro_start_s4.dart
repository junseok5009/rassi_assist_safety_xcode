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
                text: '를 알고 싶다면\n이슈와 테마\n\n',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text:
                    '실시간 업데이트 되는 오늘의 이슈\n대장주와 추세를 AI가 분석해주는 테마주도주\n시장을 움직이는 주류와 관련 종목을\n알려드립니다.',
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
                    child: Stack(
                      children: [
                        // 빅스텝
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: AnimatedFractionallySizedBox(
                            widthFactor: _containerSize.width != 0 ? 0.5 : 0,
                            duration: const Duration(milliseconds: 1000),
                            child: _setRedCircle1(
                              '삼성전자',
                              10,
                            ),
                          ),
                        ),

                        // 방산
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          right: _containerSize.width / 2,
                          child: AnimatedFractionallySizedBox(
                            widthFactor: _containerSize.width != 0 ? 0.5 : 0,
                            duration: const Duration(milliseconds: 1100),
                            child: _setRedCircle1(
                              '방산',
                              10,
                            ),
                          ),
                        ),

                        // 빅스텝
                        /*Positioned(
                          top: _containerSize.height / 10,
                          bottom: _containerSize.height / 10,
                          left: _containerSize.width / 4,
                          right: _containerSize.width / 4,
                          child: AnimatedFractionallySizedBox(
                            widthFactor: _containerSize.width != 0 ? 1.8 : 0,
                            duration: const Duration(milliseconds: 2000),
                            child: _setRedCircle1('빅스텝', 24,),
                          ),
                        ),*/
                        /*   Positioned(
                          top: _containerSize.height / 10 + 70,
                          left: _containerSize.width / 4,
                          right: _containerSize.width / 4,
                          child: AnimatedFractionallySizedBox(
                            widthFactor: _containerSize.width != 0 ? 1.0 : 0,
                            duration: const Duration(milliseconds: 3000),
                            child: _setRedCircle1('123', 24,),
                          ),
                        ),*/

                        // 마리 화나

                        // 로봇

                        // 전기차

                        // 철강

                        // 여행
                      ],
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
