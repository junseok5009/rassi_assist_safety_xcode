import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2020.10.08
/// 웹뷰
class WebPage extends StatelessWidget {
  const WebPage({super.key});
  static const routeName = '/page_web';
  static const String TAG = "[WebPage]";
  static const String TAG_NAME = '웹뷰';
  @override
  Widget build(BuildContext context) {
    CustomFirebaseClass.logEvtScreenView(
      WebPage.TAG_NAME,
    );
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null || arguments is! PgData || arguments.pgData.isEmpty) {
      Navigator.pop(context);
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: CommonAppbar.simpleWithExit(context, arguments.data, Colors.black, Colors.white, Colors.black),
      body: SafeArea(
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(arguments.pgData),),
        ),
      ),
    );
  }
}