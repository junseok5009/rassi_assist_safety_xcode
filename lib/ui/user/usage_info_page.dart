import 'package:flutter/material.dart';
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
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        Colors.white,
        Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            _setSubTitle("계정별 이용 안내"),
            const SizedBox(height: 25),
            _setSubTitle("계정안내"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text('라씨 매매비서의 계정은 베이직, 3종목 알림, 프리미엄 총 3단계로 되어있습니다.'),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          '베이직',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          RString.user_usage_desc_basic,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          '3종목',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          RString.user_usage_desc_three_stock,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          '프리미엄',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          RString.user_usage_desc_premium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _setSubTitle("계정별 이용 권한 비교"),
            const SizedBox(height: 25),
            _setSubTitle("프리미엄 계정을 위한 콘텐츠"),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: UIStyle.boxRoundLine6(),
              child: const Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '종목캐치',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('큰손들의 종목캐치'),
                      Text('기관/외국인 매수 + 라씨 매수신호'),
                      Text('성과 TOP 종목캐치'),
                      Text('라씨의 매매성과가 좋은 종목들의 매매현황'),
                      Text('조건별 종목 리스트'),
                      Text('매매기간, 주간 토픽 등 다양 조건의 종목들'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: UIStyle.boxRoundLine6(),
              child: const Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '나만의\n매도신호',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나만의 매도신호 만들기'),
                        Text('나만의 매도 신호 만들기 보유종목의 매수가를 설정하면 오직 한 사람을 위한 매도 타이밍 분석이 시작됩니다.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _setSubTitle("프리미엄 전용 상담 센터"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text('프리미엄 계정 이용고객님을 위한 맞춤 상담을 제공합니다.'
                  '프리미엄 전용 상담은 MY페이지 메인화면 나의 계정 옆의 상담하기 버튼을 누르시면 연결됩니다.\n'
                  '프리미엄 계정 고객님이시라면 프리미엄 전용 상담 채널을 이용하세요!'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      child: Text(
        subTitle,
        style: TStyle.title17,
      ),
    );
  }
}
