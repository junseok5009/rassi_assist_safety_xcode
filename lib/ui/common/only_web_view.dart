import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2022.07.13 - JS 실시간 태그별 AI 속보 리스트 > 실시간 특징주 > 웹뷰 기사
class OnlyWebView extends StatelessWidget {
  static const routeName = '/page_only_webview';
  static const String TAG = "[OnlyWebView]";
  static const String TAG_NAME = '웹뷰';
  const OnlyWebView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: const OnlyWebViewWidget(),
    );
  }
}

class OnlyWebViewWidget extends StatefulWidget {
  const OnlyWebViewWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OnlyWebViewState();
}

class OnlyWebViewState extends State<OnlyWebViewWidget> {
  String linkUrl = '';
  late PgNews args;
  late final WebViewController _controller;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: OnlyWebView.TAG_NAME,
      screenClassOverride: OnlyWebView.TAG_NAME,
    );

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
      ..loadRequest(Uri.parse(linkUrl));
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgNews;
    linkUrl = args.linkUrl;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10,),
          child: WebViewWidget(controller: _controller,),
        ),
      ),
    );
  }
  
}
