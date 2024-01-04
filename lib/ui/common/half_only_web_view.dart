
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
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
  late ScrollController _scrollController;

  HalfOnlyWebView(String vUrl, ScrollController vScrollController, {Key? key}) : super(key: key){
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
  late ScrollController _scrollController;
  HalfOnlyWebViewWidget(String vUrl, ScrollController vScrollController, {Key? key}) : super(key: key){
    _url = vUrl;
    _scrollController = vScrollController;
  }
  @override
  State<StatefulWidget> createState() => HalfOnlyWebViewState();
}

class HalfOnlyWebViewState extends State<HalfOnlyWebViewWidget> {
  String _linkUrl = '';
  late ScrollController _scrollController;
  double _height = 0;
  bool _isExpanded = false;

  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  final UniqueKey _key = UniqueKey();
  late WebViewController _myController;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(HalfOnlyWebView.TAG_NAME,);
  }

  @override
  Widget build(BuildContext context) {
    _linkUrl = widget._url;
    _scrollController = widget._scrollController;
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
            icon: Icon(Icons.close),
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
                      //       _myController.runJavascript("document.getElementsByClassName('ws-header-container')[0].style.display='none';");
                      //       _myController.runJavascript("document.getElementsByClassName('ws-footer-page')[0].style.display='none';");
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
}
