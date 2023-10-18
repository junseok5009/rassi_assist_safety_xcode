import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';


/// 2023.03.21 - JS
/// 네이버 커뮤니티 페이지
class NaverCommunityPage extends StatelessWidget {
  static const routeName = '/page_community';
  static const String TAG = "[NaverCommunityPage] ";
  static const String TAG_NAME = "네이버_종목토론";

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0,
          backgroundColor: RColor.deepStat, elevation: 0,),
        body: NaverCommunityPageState(),
      ),);
  }
}

class NaverCommunityPageState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CommunityState();
}

class CommunityState extends State<NaverCommunityPageState> {
  late PgData args;
  String _stockCode = '';
  String _rtUrl = '';
  String _postData = '';
  double _progress = 0;

  late InAppWebViewController _webViewController;
  final InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        // supportZoom: false,
        // disableHorizontalScroll: true,
        // horizontalScrollBarEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _stockCode = args.stockCode;

    //리턴되는 페이지 형식
    if(_stockCode.length > 1) {
      _rtUrl =  Net.THINK_COMMUNITY_STK + _stockCode;
    } else {
      _rtUrl = Net.THINK_COMMUNITY;
    }
    // DLog.d(NaverCommunityPage.TAG, Uri.encodeComponent(_rtUrl));

    return WillPopScope(
      child: Scaffold(
        appBar: _setCustomAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialOptions: _options,
                initialUrlRequest: URLRequest(
                  url: Uri.parse('${Net.NAVER_COMMUNITY_STK}$_stockCode/discuss'),
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onProgressChanged: (controller, progress){
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              _progress < 1.0
                  ? LinearProgressIndicator(value: _progress)
                  : Container(),
            ],
          ),
        ),
      ),
      onWillPop: (){
        var future = _webViewController.canGoBack();
        future.then((canGoBack) {
          if (canGoBack) {
            _webViewController.goBack();
          } else {
            Navigator.of(context).pop();
          }
        });
        return Future.value(false);
      },
    );
  }

  PreferredSizeWidget _setCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        height: Const.HEIGHT_APP_BAR,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: RColor.lineGrey, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 7,),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, ),
                  onPressed: () => _webViewController?.goBack(),
                ),
                // IconButton(
                //   icon: Icon(Icons.arrow_forward_ios, ),
                //   color: Colors.grey,
                //   onPressed: () => _webViewController?.goForward(),
                // ),
              ],
            ),
            const Text('라씨 매매비서', style: TStyle.title20,),
            // const SizedBox(width: 7,),
            IconButton(
              icon: const Icon(Icons.close, ),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeString() {
    final df = DateFormat('yyyyMMddhhmmss');
    return df.format(DateTime.now());
  }
}