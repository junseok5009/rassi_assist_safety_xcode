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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'NotoSansKR',
                  ),
                  children: [
                    TextSpan(
                      text: '매도',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: RColor.purpleBasic_6565ff,
                      ),
                    ),
                    TextSpan(
                      text: '가 곧 수익이다!\n',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'AI매매신호\n',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          '\n매도를 잘해야 수익이 납니다.\n궁금한 종목을 입력하시면\n정확한 시점과 가격을 알려드립니다.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(
                  top: 25,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                decoration: BoxDecoration(
                  color: RColor.greyBox_f5f5f5,
                  border: Border.all(
                    color: RColor.purpleBasic_6565ff,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          '종목명/종목코드를 입력하세요.',
                          style: TextStyle(
                            fontSize: 16,
                            color: RColor.purpleBasic_6565ff,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Image.asset(
                        'images/rassibs_icon_img_2.png',
                        width: 22,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IntroSearchPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: AppGlobal().isTablet
                ? AppGlobal().deviceWidth / 2
                : AppGlobal().deviceWidth * 2 / 3,
            height: AppGlobal().deviceWidth / 2,
            child: Center(
              child: Stack(
                children: [
                  AnimatedPositioned(
                    right: 0,
                    left: 0,
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
          ),
        ),
        const SizedBox(
          height: 120,
        ),
      ],
    );
  }
}
