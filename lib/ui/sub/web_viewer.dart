import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// 2021.04.07
/// 웹뷰어 (일단 공시 뷰어)
class WebViewer extends StatelessWidget {
  static const routeName = '/page_web_view';
  static const String TAG = "[WebViewer]";
  static const String TAG_NAME = '웹 뷰어';

  const WebViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const WebViewerWidget(),
      ),
    );
  }
}

class WebViewerWidget extends StatefulWidget {
  const WebViewerWidget({super.key});

  @override
  State<StatefulWidget> createState() => WebViewState();
}

class WebViewState extends State<WebViewerWidget> {
  late PgData args;
  String _sUrl = '';
  String _stockCode = '';
  late final WebViewController _controller;
  String initUrl = 'http://olla.thinkpool.com/news/itemDart.do';
  // String initUrl = 'http://olla.thinkpool.com/news/itemDart.do?code=$_stockCode';

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: WebViewer.TAG_NAME,
      screenClassOverride: WebViewer.TAG_NAME,);

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
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(initUrl));
  }

  // TODO  ios 에서 back key 가 없어서 뒤로 버튼을 따로 만들어줘야함.

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _stockCode = args.stockCode;

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
        child:  WebViewWidget(controller: _controller,)
      ),
    );
  }
}