import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/login/intro_start_s1.dart';
import 'package:rassi_assist/ui/login/intro_start_s2.dart';
import 'package:rassi_assist/ui/login/intro_start_s3.dart';
import 'package:rassi_assist/ui/login/intro_start_s4.dart';
import 'package:rassi_assist/ui/login/login_division_page.dart';

class IntroStartPage extends StatefulWidget {
  const IntroStartPage({Key? key}) : super(key: key);

  //const IntroStartPage({super.key});

  @override
  State<IntroStartPage> createState() => _IntroStartPageState();
}

class _IntroStartPageState extends State<IntroStartPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(
            30,
          ),
          margin: const EdgeInsets.only(top: 10),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Swiper(
                    loop: false,
                    autoplay: false,
                    //autoplayDelay: 4000,
                    pagination: CommonSwiperPagenation.getNormalSpWithMargin2(
                      7,
                      75,
                      RColor.purpleBasic_6565ff,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return const IntroStartS1();
                      } else if (index == 1) {
                        return const IntroStartS2();
                      } else if (index == 2) {
                        return IntroStartS3();
                      } else if (index == 3) {
                        return const IntroStartS4();
                      } else {
                        return const SizedBox();
                      }
                    }),
              ),
              InkWell(
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  decoration: UIStyle.boxRoundFullColor50c(
                    RColor.mainColor,
                  ),
                  child: const Text(
                    '1초만에 라씨 매매비서 시작하기',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginDivisionPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
