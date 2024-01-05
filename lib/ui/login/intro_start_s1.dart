import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/login/intro_search_page.dart';

class IntroStartS1 extends StatefulWidget {
  const IntroStartS1({Key? key}) : super(key: key);

  //const IntroStartS1({super.key});

  @override
  State<IntroStartS1> createState() => _IntroStartS1State();
}

class _IntroStartS1State extends State<IntroStartS1> {
  Timer? _timer;
  bool _isUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isUp = !_isUp;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
        setState(() {
          _isUp = !_isUp;
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
              children: [
                TextSpan(
                  text: '매매타이밍',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
                TextSpan(
                  text: '의 정답\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'AI매매신호\n\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      '고도화된 알고리즘이 사고 팔 시점과\n정확한 가격을 알려드립니다.\n지금, 궁금한 종목을 검색해 보세요!',
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
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IntroSearchPage(),),),
            child: Container(
              width: 220,
              height: 40,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: RColor.purpleBasic_6565ff,
                  width: 1,
                ),
                //borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: const Text(
                'AI매매신호 검색',
                style: TextStyle(
                  color: RColor.purpleBasic_6565ff,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: double.infinity,
                  child: Row(
                    children: [
                      const Expanded(
                        child: SizedBox(),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'images/icon_intro_start1_1.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  bottom: _isUp ? 25.0 : 0.0,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.fastOutSlowIn,
                  child: Image.asset(
                    'images/icon_intro_start1_2.png',
                    width: AppGlobal().deviceWidth -
                        (AppGlobal().deviceWidth / 2.5),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
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
