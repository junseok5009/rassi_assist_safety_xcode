import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';

class TestImageFullPage extends StatefulWidget {
  //const TestImageFullPage({super.key});
  final String imageUrl;
  const TestImageFullPage( {super.key, required this.imageUrl,});

  @override
  State<TestImageFullPage> createState() => _TestImageFullPageState();
}

class _TestImageFullPageState extends State<TestImageFullPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '타이틀 영역입니다.',
        elevation: 1,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
            Container(
              color: RColor.mainColor,
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: InkWell(
                onTap: () async {
                  /*if (prom02.linkPage == 'LPHE') {
                    _navigateRefreshPayPromotion(PgData(data: 'new_6m_50'));
                  } else if (prom02.linkPage == 'LPHG') {
                    _navigateRefreshPayPromotion(PgData(data: 'new_6m_70'));
                  } else if (prom02.linkPage == 'LPHF') {
                    _navigateRefreshPayPromotion(PgData(data: 'new_7d'));
                  }*/
                },
                child: Center(
                  child: Text(
                    '버튼 이름 입니다.',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
