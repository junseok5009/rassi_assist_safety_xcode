import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';

class IntroStartS3 extends StatefulWidget {
  const IntroStartS3({Key? key}) : super(key: key);

  //const IntroStartS3({super.key});

  @override
  State<IntroStartS3> createState() => _IntroStartS2State();
}

class _IntroStartS2State extends State<IntroStartS3> {
  Timer? _timer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (_count == 1) {
          _count = 0;
        } else {
          _count++;
        }
      });
      _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
        setState(() {
          if (_count == 1) {
            _count = 0;
          } else {
            _count++;
          }
        });
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
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
                  text: '이미지',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
                TextSpan(
                  text: '로 보는 종목정보,\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '종목인사이트\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      '\n종목이슈, 실적, 투자자별 매매동향, 대차공매 등 모든 종목정보를 시각화하여 쉽게 분석! 이제 숫자가 아닌 이미지로 확인하세요!',
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
              //height: double.infinity,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            'images/icon_intro_start3_1.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Column(
                          children: [
                            const Expanded(flex: 2, child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: AnimatedContainer(
                                //bottom: count == 0 ?  ? 20.0 : 0.0,
                                //color: Colors.red.withOpacity(0.3),
                                alignment: _count == 0
                                    ? Alignment.bottomLeft
                                    : Alignment.bottomRight,
                                duration: const Duration(milliseconds: 3500),
                                curve: Curves.fastOutSlowIn,
                                child: Image.asset(
                                  'images/icon_intro_start3_2.png',
                                  width: AppGlobal().deviceWidth / 4,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                          ],
                        )
                      ],
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
      ),
    );
  }
}
