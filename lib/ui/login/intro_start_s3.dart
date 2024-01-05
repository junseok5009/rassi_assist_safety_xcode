import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';

class IntroStartS3 extends StatefulWidget {
  const IntroStartS3({Key? key}) : super(key: key);

  //const IntroStartS3({super.key});

  @override
  State<IntroStartS3> createState() => _IntroStartS3State();
}

class _IntroStartS3State extends State<IntroStartS3> {
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
                  text: '이미지',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: RColor.purpleBasic_6565ff,
                  ),
                ),
                TextSpan(
                  text: '로 보는 종목정보,\n종목인사이트\n\n',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      '종목이슈, 실적, 투자자별 매매동향, 대차공매 등\n모든 종목정보를 시각화하여 쉽게 분석!\n이제 숫자가 아닌 이미지로 확인하세요!',
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
            height: 30,
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
                    flex: 5,
                    child: Column(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.topCenter,
                            decoration: UIStyle.boxShadowBasic(16),
                            padding: const EdgeInsets.all(10),
                            //margin: EdgeInsets.symmetric(vertical: 10,),
                            child: Swiper(
                              onTap: (index) {},
                              itemCount: 4,
                              loop: true,
                              pagination:
                                  CommonSwiperPagenation.getNormalSpWithMargin2(
                                5,
                                5,
                                RColor.purpleBasic_6565ff,
                              ),
                              itemBuilder: (context, index) {
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.asset(
                                      'images/icon_intro_start3_1.png',
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                );
                              },
                              autoplay: true,
                              autoplayDelay: 2000,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
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

  @override
  void initState() {
    super.initState();
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
}
