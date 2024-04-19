import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/web/web_page.dart';

///약관 페이지
//
class TermsPage extends StatelessWidget {
  static const routeName = '/page_terms';
  static const String TAG = "[TermsPage]";
  static const String TAG_NAME = '이용약관';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: TermsWidget(),
    );
  }
}

class TermsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TermsState();
}

class TermsState extends State<TermsWidget> {
  var appVersion = Platform.isIOS ? Const.APP_VER : Const.APP_VER_AOS;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      TermsPage.TAG_NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '이용약관',
          style: TStyle.commonTitle,
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _setBoxButton('이용약관', Net.AGREE_TERMS),
            _setBoxButton('개인정보 처리방침', Net.AGREE_POLICY_INFO),
            _setBoxButton('저작권 안내', Net.COPYRIGHT_INFO),
            ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: double.infinity, minHeight: 50),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: RColor.lineGrey, width: 0.7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '사용중인 앱 버전',
                      style: TStyle.content14,
                    ),
                    Text(
                      appVersion,
                      style: TStyle.textMGrey,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _setBoxButton(String label, String termsUrl) {
    return InkWell(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minWidth: double.infinity, minHeight: 50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: RColor.lineGrey, width: 0.7)),
          ),
          child: Text(
            label,
            style: TStyle.content14,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WebPage(),
              settings: RouteSettings(
                arguments: PgData(pgData: termsUrl),
              ),
            ));
      },
    );
  }
}
