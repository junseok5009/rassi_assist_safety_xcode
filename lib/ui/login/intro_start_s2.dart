import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';

class IntroStartS2 extends StatefulWidget {
  const IntroStartS2({Key? key}) : super(key: key);

  //const IntroStartS2({super.key});

  @override
  State<IntroStartS2> createState() => _IntroStartS2State();
}

class _IntroStartS2State extends State<IntroStartS2> {
  Timer? _timer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (_count == 2) {
          _count = 0;
        } else {
          _count++;
        }
      });
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        setState(() {
          if (_count == 2) {
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
                  text: '10년간 검증된 AI,\n모든 매매내역 ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '100% ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
                TextSpan(
                  text: '공개\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      '\n2015년 최초의 주식 AI 서비스 출시,\n30만 다운로드 인정받은 주식AI!\n모든 AI매매신호와 내역과 성과는\n100% 투명하게 공개합니다.',
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
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            'images/icon_intro_start2_3.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              const Expanded(flex: 1, child: SizedBox()),
                              Expanded(
                                flex: 4,
                                child: AnimatedContainer(
                                  //bottom: count == 0 ?  ? 20.0 : 0.0,
                                  alignment: _count == 0
                                      ? Alignment.topLeft
                                      : _count == 1
                                          ? Alignment.topRight
                                          : Alignment.bottomRight,
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  child: Image.asset(
                                    'images/icon_intro_start2_2.png',
                                    width: AppGlobal().deviceWidth / 4,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const Expanded(flex: 1, child: SizedBox()),
                            ],
                          ),
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
