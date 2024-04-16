import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';

import '../../common/ui_style.dart';

/// 2024.03.
/// 계정별 이용 안내
class UsageInfoPage extends StatefulWidget {
  static const routeName = '/page_usage_info';
  static const String TAG = "[UsageInfoPage] ";
  static const String TAG_NAME = 'MY_계정별이용안내';

  const UsageInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserInfoState();
}

class UserInfoState extends State<UsageInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _setLayout();
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: CommonAppbar.simpleWithExit(
        context,
        '계정별 이용 안내',
        Colors.black,
        Colors.white,
        Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 5),
            _setSubTitle("계정안내"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '라씨 매매비서의 계정은 베이직, 3종목 알림, 프리미엄 총 3단계로 되어있습니다.',
                style: TStyle.content16T,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _setGradeInfo(
                    '베이직',
                    RString.user_usage_desc_basic,
                    'images/main_my_icon_basic.png',
                  ),
                  const SizedBox(height: 5),
                  _setGradeInfo(
                    '3종목 알림',
                    RString.user_usage_desc_three_stock,
                    'images/main_my_icon_three.png',
                  ),
                  const SizedBox(height: 5),
                  _setGradeInfo(
                    '프리미엄',
                    RString.user_usage_desc_premium,
                    'images/main_my_icon_premium.png',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _setSubTitle("계정별 이용 권한 비교"),
            _setGradeUsageCompare(),
            const SizedBox(height: 25),

            //---------
            _setSubTitle("프리미엄 계정을 위한 콘텐츠"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '매수 종목을 찾는다면 \'종목캐치\'\n'
                '보유 종목의 매도 타이밍은 \'나만의 매도 신호\'',
                style: TStyle.content16T,
              ),
            ),
            Row(
              children: [
                _setSubTitle("매수의 치트키"),
                const Text(
                  '종목캐치',
                  style: TStyle.textMainColor19,
                )
              ],
            ),
            _setDescStockCatch(),
            const SizedBox(height: 25),

            Row(
              children: [
                _setSubTitle("매도의 치트키"),
                const Text(
                  '나만의 매도신호',
                  style: TStyle.textMainColor19,
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: UIStyle.boxRoundLine(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나만의 매도신호 만들기',
                    style: TStyle.commonTitle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '보유종목의 매수가를 설정하면 '
                    '오직 한 사람을 위한 매도 타이밍 분석이 시작됩니다.',
                    style: TStyle.content16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            //---------
            _setSubTitle("프리미엄 전용 상담 센터"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                RString.user_premium_only_consultation_dese,
                style: TStyle.content16,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  //매수의 치트키 종목캐치
  Widget _setDescStockCatch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: UIStyle.boxRoundLine(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '큰손들의 종목캐치',
            style: TStyle.commonTitle,
          ),
          SizedBox(height: 4),
          Text(
            '기관/외국인 매수 + 라씨 매수신호',
            style: TStyle.content16,
          ),
          SizedBox(height: 5),
          Divider(),
          SizedBox(height: 5),
          Text(
            '성과 TOP 종목캐치',
            style: TStyle.commonTitle,
          ),
          SizedBox(height: 4),
          Text(
            '라씨의 매매성과가 좋은 종목들의 매매현황',
            style: TStyle.content16,
          ),
          SizedBox(height: 5),
          Divider(),
          SizedBox(height: 5),
          Text(
            '조건별 종목 리스트',
            style: TStyle.commonTitle,
          ),
          SizedBox(height: 4),
          Text(
            '매매기간, 주간 토픽 등 다양 조건의 종목들',
            style: TStyle.content16,
          ),
        ],
      ),
    );
  }

  //계정별 이용 권한 비교
  Widget _setGradeUsageCompare() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: RColor.lineGrey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(width: 1, color: Colors.black),
                          vertical: BorderSide(width: 1, color: RColor.lineGrey),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '베이직',
                          style: TStyle.title18T,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(width: 1, color: Colors.black),
                          vertical: BorderSide(width: 1, color: RColor.lineGrey),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '3종목 알림',
                          style: TStyle.title18T,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(width: 1, color: Colors.black),
                          vertical: BorderSide(width: 1, color: RColor.lineGrey),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '프리미엄',
                          style: TStyle.textMainColor19,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: RColor.greyBox_f5f5f5,
            ),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                'AI매매신호 보기',
                style: TStyle.content16,
              ),
            ),
          ),
          _setGradeCompare(
            '매일\n최대 5종목',
            '매일\n최대 5종목',
            '무제한\n이용',
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: RColor.greyBox_f5f5f5,
            ),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                '포켓과 종목관리',
                style: TStyle.content16,
              ),
            ),
          ),
          _setGradeCompare(
            '포켓1개\n포켓당50종목',
            '포켓1개\n포켓당50종목',
            '포켓10개\n포켓당50종목',
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: RColor.greyBox_f5f5f5,
            ),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                'AI매매신호 알림',
                style: TStyle.content16,
              ),
            ),
          ),
          _setGradeCompare(
            'X',
            '포켓 종목 중\n선택한 3종목',
            '포켓의 모든 종목\n실시간 알림',
          ),
        ],
      ),
    );
  }

  //계정별 이용 권한 비교
  Widget _setGradeCompare(String basic, String three, String premium) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 80,
            decoration: UIStyle.boxSquareLine(),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                basic,
                textAlign: TextAlign.center,
                style: TStyle.content16,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            decoration: UIStyle.boxSquareLine(),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                three,
                textAlign: TextAlign.center,
                style: TStyle.content16T,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            decoration: UIStyle.boxSquareLine(),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                premium,
                textAlign: TextAlign.center,
                style: TStyle.textMainColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //상품 설명
  Widget _setGradeInfo(String gradeText, String desc, String imgPath) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: RColor.greyBox_f5f5f5,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  imgPath,
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                gradeText,
                style: TStyle.textGrey18,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TStyle.content16,
          ),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 10, bottom: 15),
      child: Text(
        subTitle,
        style: TStyle.title18T,
      ),
    );
  }
}
