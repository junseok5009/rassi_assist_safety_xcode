import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// AI 엔진 버전 --> 추후에 공통 웹뷰 페이지로 전환
class AiVersionPage extends StatelessWidget {
  static const routeName = '/page_ai_engine';
  static const String TAG = "[AiVersionPage]";
  static const String TAG_NAME = 'AI_버전_히스토리';
  const AiVersionPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: const VerWidget(),
      ),);
  }
}

class VerWidget extends StatefulWidget {
  const VerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VerState();
}

class VerState extends State<VerWidget> {
  late PgData args;
  late String sUrl;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(AiVersionPage.TAG_NAME,);

/*
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
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://www.youtube.com/')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(Uri.parse(Net.URL_ENGINE_VER));*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('AI 버전 히스토리', style: TStyle.title18,),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: WebView(
          initialUrl: Net.URL_ENGINE_VER,
          javascriptMode: JavascriptMode.unrestricted,
        ),
        // child: WebViewWidget(controller: _controller,),
      ),
    );
  }
}