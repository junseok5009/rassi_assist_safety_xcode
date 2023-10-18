import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';

class TestGtmRegistPage extends StatelessWidget {
//  const TestGtmRegistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: TestGtmRegistWidget(),),);
  }

}

class TestGtmRegistWidget extends StatefulWidget {
  //const TestGtmRegistWidget({Key? key}) : super(key: key);

  @override
  State<TestGtmRegistWidget> createState() => _TestGtmRegistWidgetState();
}

class _TestGtmRegistWidgetState extends State<TestGtmRegistWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [

          _setGridWidgetDevPage(),

        ],
      ),
    );
  }

  Widget _setGridWidgetDevPage() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      physics: NeverScrollableScrollPhysics(),
      children: [

        Builder(
          builder: (context) =>
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    '이벤트 발생 1',
                    style: TStyle.subTitle,
                  ),
                  color: Colors.redAccent[100],
                ),
                onTap: () {

                  FirebaseAnalytics.instance.logEvent(name: 'J_GTM_EVENT_NAME1', parameters: {
                    'test_key_name_1': 'test_key_name_1_J_value',
                    'test_key_name_2': 'test_key_name_2_J_value',
                  });
                },
              ),
        ),

        Builder(
          builder: (context) =>
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    '이벤트 발생 2',
                    style: TStyle.subTitle,
                  ),
                  color: Colors.redAccent[100],
                ),
                onTap: () {

               /*   gtm.pushEvent('test_page_button2-click');
                  gtm.pushEvent('button2-J_GTM_EVENT_NAME2', data: {
                    'test_key_name_1': 'test_key_name_1-2_J_value',
                    'test_key_name_2': 'test_key_name_2-2_J_value',
                  });
                  gtm.push({'gtm_push_J_NAME': 'gtm_push_J_VALUE'});*/
                  FirebaseAnalytics.instance.setCurrentScreen(
                      screenName: '테스트_쥐티엠_레지스트_페이지',
                      screenClassOverride: 'TestGtmRegistPage',
                      );
                },
              ),
        ),
        // 프로바이더 테스트 페이지
        Builder(
          builder: (context) =>
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    '이벤트 발생 3',
                    style: TStyle.subTitle,
                  ),
                  color: Colors.redAccent[100],
                ),
                onTap: () {
                  FirebaseAnalytics.instance.setUserProperty(
                    name: 'testSetUserPropertyName',
                    value: 'test_setUserProperty_value',
                  );
                }

              ),
        ),
        // 하프레이어 + 웹뷰
        Builder(
          builder: (context) =>
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    '이벤트 발생 4',
                    style: TStyle.subTitle,
                  ),
                  color: Colors.redAccent[100],
                ),
                onTap: () {

                }
              ),
        ),

        Builder(
          builder: (context) =>
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    '이벤트 발생 5',
                    style: TStyle.subTitle,
                  ),
                  color: Colors.redAccent[100],
                ),
                onTap: (){


                }
              ),
        ),

      ],
    );
  }

}

