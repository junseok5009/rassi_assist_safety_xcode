import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.02.02
/// 커뮤니티 페이지
/// ref: https://stackoverflow.com/questions/66396219/how-to-post-data-to-url-in-flutter-webview
class CommunityPage extends StatelessWidget {
  static const routeName = '/page_community';
  static const String TAG = "[CommunityPage] ";
  static const String TAG_NAME = "종목토론";

  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: const CommunityWidget(),
      ),
    );
  }
}

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({super.key});

  @override
  State<StatefulWidget> createState() => CommunityState();
}

class CommunityState extends State<CommunityWidget> {
  late SharedPreferences _prefs;
  late PgData args;
  String _userId = '';
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
    _loadPrefData();
  }

  //저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    _userId = args.userId;
    _stockCode = args.stockCode;

    //리턴되는 페이지 형식
    if (_stockCode != null && _stockCode.length > 1) {
      _rtUrl = Net.THINK_COMMUNITY_STK + _stockCode;
    } else {
      _rtUrl = Net.THINK_COMMUNITY;
    }
    DLog.d(CommunityPage.TAG, Uri.encodeComponent(_rtUrl));

    _postData = "userid=${Net.getEncrypt(_userId)}&"
        "returnPage=${Uri.encodeComponent(_rtUrl)}&"
        "timeKey=${Net.getEncrypt(getTimeString())}";
    DLog.d(CommunityPage.TAG, '#postData: $_postData');

    return WillPopScope(
      child: Scaffold(
        appBar: _setCustomAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialOptions: _options,
                initialUrlRequest: URLRequest(
                  url: Uri.parse(Net.THINK_COMMUNITY_AJAX),
                  method: 'POST',
                  body: Uint8List.fromList(utf8.encode(_postData)),
                  headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              _progress < 1.0 ? LinearProgressIndicator(value: _progress) : Container(),
            ],
          ),
        ),
      ),
      onWillPop: () {
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
                const SizedBox(
                  width: 7,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                  ),
                  onPressed: () => _webViewController.goBack(),
                ),
                // IconButton(
                //   icon: Icon(Icons.arrow_forward_ios, ),
                //   color: Colors.grey,
                //   onPressed: () => _webViewController?.goForward(),
                // ),
              ],
            ),
            const Text(
              '라씨 매매비서',
              style: TStyle.title20,
            ),
            // const SizedBox(width: 7,),
            IconButton(
              icon: const Icon(
                Icons.close,
              ),
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
