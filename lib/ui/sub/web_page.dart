import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// 2020.10.08
/// 웹뷰
class WebPage extends StatelessWidget {
  static const routeName = '/page_web';
  static const String TAG = "[WebPage]";
  static const String TAG_NAME = '웹뷰';

  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const WebWidget(),
      ),
    );
  }
}

class WebWidget extends StatefulWidget {
  const WebWidget({super.key});

  @override
  State<StatefulWidget> createState() => WebState();
}

class WebState extends State<WebWidget> {
  late PgData args;
  String sUrl = 'https://www.thinkpool.com/policy/service';
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: WebPage.TAG_NAME,
      screenClassOverride: WebPage.TAG_NAME,);

    _controller = WebViewController()
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
      ..loadRequest(Uri.parse(sUrl));
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    sUrl = args.pgData;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(null),),
          const SizedBox(width: 10.0,),
        ],
      ),

      body: SafeArea(
        child: WebViewWidget(controller: _controller,),
      ),
    );
  }
}