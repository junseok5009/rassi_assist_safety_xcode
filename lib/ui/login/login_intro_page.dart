import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/login/login_division_page.dart';


/// 2023.02.17 - HJS 수정
/// 인트로 소개
class LoginIntroPage extends StatelessWidget {
  static const routeName = '/page_login_intro';
  static const String TAG = "[LoginIntroPage]";
  static const String TAG_NAME = '인트로_앱소개';
  final List<IntroItem> _listDesc = [
    IntroItem('images/rassi_bs_introimg_01.jpg'),
    IntroItem('images/rassi_bs_introimg_02.jpg'),
    IntroItem('images/rassi_bs_introimg_03.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: LoginIntroPage.TAG_NAME,
      screenClassOverride: LoginIntroPage.TAG_NAME,);
    _setUserProperty('login_status', 'in_intro_info');

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: SafeArea(
          child: ListView(
            children: [
              //상단 소개
              _setSlider(),
              const SizedBox(height: 30,),

              //1초만에 라씨 매매비서 시작하기
              Column(
                children: [
                  Container(
                    width: 250,
                    child: MaterialButton(
                      padding: const EdgeInsets.symmetric(vertical: 10,),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: RColor.mainColor)
                      ),
                      color: RColor.mainColor,
                      textColor: Colors.white,
                      child: const Text('1초만에 라씨 매매비서 시작하기', style: TStyle.btnTextWht15,),
                      onPressed: (){
                        if(LoginDivisionPage.globalKey.currentState == null){
                          Navigator.pushReplacementNamed(context, LoginDivisionPage.routeName);
                        }else{
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  // 롤링 소개
  Widget _setSlider() {
    return Container(
      width: double.infinity,
      height: 500,
      color: Colors.white,
      // color: RColor.bgWeakGrey,
      child: Swiper(
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
              color: RColor.lineGrey,
              activeColor: RColor.mainColor),
        ),
        autoplay: true,
        loop: false,
        autoplayDelay: 4000,
        itemCount: _listDesc.length,
        itemBuilder: (BuildContext context, int index){
          return TileIntro(_listDesc[index]);
        },
      ),
    );
  }

  void _setUserProperty(String name, String value) async {
    await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }

}

class TileIntro extends StatelessWidget {
  final IntroItem item;
  const TileIntro(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 30.0,),

          Image.asset(item.strPath, height: 400,),
        ],
      ),
    );
  }
}

class IntroItem {
  final String strPath;

  IntroItem(this.strPath);
}