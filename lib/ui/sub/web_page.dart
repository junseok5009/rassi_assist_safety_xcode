import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2020.10.08
/// 웹뷰
class WebPage extends StatefulWidget {
  static const routeName = '/page_web';
  static const String TAG = "[WebPage]";
  static const String TAG_NAME = '웹뷰';

  const WebPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WebPageState();
}

class WebPageState extends State<WebPage> {
  late PgData args;
  String sUrl = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      WebPage.TAG_NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    sUrl = args.pgData;
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(
          context, Colors.white, Colors.black),
      body: SafeArea(
        child: WebView(
          initialUrl: sUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
/*        child: WebViewWidget(
          // initialUrl: url,
          // javascriptMode: JavascriptMode.unrestricted,
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  // Update loading bar.
                },
                onPageStarted: (String url) {},
                onPageFinished: (String url) {},
                onWebResourceError: (WebResourceError error) {},
              ),
            )
            ..loadRequest(Uri.parse(sUrl)),
        ),*/
      ),
    );
  }
}
