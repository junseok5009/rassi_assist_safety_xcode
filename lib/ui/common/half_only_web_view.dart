import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2022.07.13 - JS 실시간 태그별 AI 속보 리스트 > 실시간 특징주 > 웹뷰 기사
class HalfOnlyWebView extends StatelessWidget {
  static const routeName = '/page_only_webview';
  static const String TAG = "[HalfOnlyWebView]";
  static const String TAG_NAME = '웹뷰';
  String _url = '';
  ScrollController? _scrollController;

  HalfOnlyWebView(String vUrl, ScrollController vScrollController){
    _url = vUrl;
    _scrollController = vScrollController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: HalfOnlyWebViewWidget(_url, _scrollController),
    );
  }

}

class HalfOnlyWebViewWidget extends StatefulWidget {
  String _url = '';
  ScrollController? _scrollController;

  HalfOnlyWebViewWidget(String vUrl, ScrollController? vScrollController){
    _url = vUrl;
    _scrollController = vScrollController;
  }

  @override
  State<StatefulWidget> createState() => HalfOnlyWebViewState();
}

class HalfOnlyWebViewState extends State<HalfOnlyWebViewWidget> {
  String _linkUrl = '';
  double _height = 0;
  bool _isExpanded = false;
  late ScrollController _scrollController;
  late final WebViewController _controller;

  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  final UniqueKey _key = UniqueKey();
  late WebViewController _myController;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: HalfOnlyWebView.TAG_NAME,
      screenClassOverride: HalfOnlyWebView.TAG_NAME,
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
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    _linkUrl = widget._url;
    _scrollController = widget._scrollController!;
    _scrollListener() {
      if(_scrollController.offset > 0.5){
        setState(() {
          _height = MediaQuery.of(context).size.height * 0.9;
          _isExpanded = true;
        });
      }
    }
    _scrollController.addListener(_scrollListener);
    if(_height == 0){
      _height = MediaQuery.of(context).size.height * 0.4;
    }
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
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child:
                    //_makeWebView(),
                    Container(
                      height: _height,
                      // child: WebView(
                      //   key: _key,
                      //   initialUrl: _linkUrl,
                      //   gestureRecognizers: _isExpanded ? gestureRecognizers : null,
                      //   javascriptMode: JavascriptMode.unrestricted,
                      //   onPageFinished: (initialUrl) {
                      //     if(_isExpanded){
                      //       _myController.evaluateJavascript("document.getElementsByClassName('ws-header-container')[0].style.display='none';");
                      //       _myController.evaluateJavascript("document.getElementsByClassName('ws-footer-page')[0].style.display='none';");
                      //     }
                      //   },
                      // ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '확인',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

}
