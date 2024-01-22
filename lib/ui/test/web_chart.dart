import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// Web Chart Page
class WebChartPage extends StatelessWidget {
  static const routeName = '/page_web_chart';
  static const String TAG = "[WebChartPage] ";

  const WebChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),
      body: const WebChartWidget(),
    );
  }
}

class WebChartWidget extends StatefulWidget {
  const WebChartWidget({super.key});

  @override
  State<StatefulWidget> createState() => WebChartState();
}

class WebChartState extends State<WebChartWidget> {
  late PgData args;
  bool _isOnCreate = true;
  late final WebViewController _controller;

  String _testUrl = 'https://www.naver.com';

  @override
  void initState() {
    super.initState();

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
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_testUrl));*/
  }


  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    DLog.d(WebChartPage.TAG, 'build');
    if(_isOnCreate && args != null) {
      // DLog.d(WebChartPage.TAG, '11111');
      if(args.pgData != null) _testUrl = args.pgData;
    }

    return SafeArea(
      child: WebView(
        initialUrl: _testUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
/*      child: WebViewWidget(controller: _controller,
        // initialUrl: _testUrl,
        // javascriptMode: JavascriptMode.unrestricted,

        // navigationDelegate: (NavigationRequest request) {
        //   if (request.url.startsWith('https:')) {
        //     print('blocking navigation to $request}');
        //     _launchURL(request.url);
        //     return NavigationDecision.prevent;
        //   }
        //
        //   print('allowing navigation to $request');
        //   return NavigationDecision.navigate;
        // },
      ),*/
    );


    /// chart test
    // return Scaffold(
    //   body: Builder(builder: (BuildContext context){
    //     return WebView(
    //       initialUrl: 'assets/chart.html',//'about:blank',
    //       javascriptMode: JavascriptMode.unrestricted,
    //       onWebViewCreated: (WebViewController controller){
    //         _controller = controller;
    //         _loadHtmlFromAssets();
    //       },
    //     );
    //   }),
    // );
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/chart.html');
    // _controller.loadUrl(Uri.dataFromString(
    //   fileText,
    //   mimeType: 'text/html',
    //   encoding: Encoding.getByName('utf-8')
    // ).toString());
  }
}





