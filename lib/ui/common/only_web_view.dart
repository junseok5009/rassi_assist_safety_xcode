import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';

/// 2022.07.13 - JS 실시간 태그별 AI 속보 리스트 > 실시간 특징주 > 웹뷰 기사
/// 2023.10.20 - JS 수정
class OnlyWebViewPage extends StatelessWidget {
  static const routeName = '/page_only_webview';
  static const String TAG = "[OnlyWebViewPage]";
  static const String TAG_NAME = '웹뷰';
  final String title;
  final String url;

  const OnlyWebViewPage({
    this.title = '',
    this.url = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomFirebaseClass.logEvtScreenView(
      OnlyWebViewPage.TAG_NAME,
    );
    DLog.e('_url : $url');
    return Scaffold(
      appBar: CommonAppbar.simpleWithExit(
        context,
        title,
        Colors.black,
        Colors.white,
        Colors.black,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          ),
          // child: WebView(
          //   initialUrl: url,
          //   javascriptMode: JavascriptMode.unrestricted,
          // ),
        ),
      ),
    );
  }
}
