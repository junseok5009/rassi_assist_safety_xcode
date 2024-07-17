import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.02.02
/// 커뮤니티 페이지
/// ref: https://stackoverflow.com/questions/66396219/how-to-post-data-to-url-in-flutter-webview

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  static const routeName = '/page_community';
  static const String TAG = "[CommunityPage] ";
  static const String TAG_NAME = "종목토론";

  @override
  State<StatefulWidget> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  late SharedPreferences _prefs;
  late PgData args;
  String _userId = '';
  String _stockCode = '';
  String _rtUrl = '';
  String _postData = '';
  double _progress = 0;
  bool _isOut = false;

  late InAppWebViewController? _inAppWebViewController;
  final InAppWebViewSettings _inAppWebViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true, // URL 로딩 제어
    mediaPlaybackRequiresUserGesture: false, // 미디어 자동 재생
    javaScriptEnabled: true, // 자바스크립트 실행 여부
    javaScriptCanOpenWindowsAutomatically: true, // 팝업 여부
    useHybridComposition: true, // 하이브리드 사용을 위한 안드로이드 웹뷰 최적화
    supportMultipleWindows: true, // 멀티 윈도우 허용
    allowsInlineMediaPlayback: true, // 웹뷰 내 미디어 재생 허용
  );

  @override
  void initState() {
    super.initState();
    _loadPrefData().then(
      (value) {
        Future.delayed(Duration.zero, () async {
          args = ModalRoute.of(context)!.settings.arguments as PgData;
          _stockCode = args.stockCode;
          if (_stockCode.isNotEmpty) {
            _rtUrl = Net.THINK_COMMUNITY_STK + _stockCode;
          } else {
            _rtUrl = Net.THINK_COMMUNITY;
          }
          _postData = "userid=${Net.getEncrypt(_userId)}&"
              "returnPage=${Uri.encodeComponent(_rtUrl)}&"
              "timeKey=${Net.getEncrypt(getTimeString())}";
          setState(() {});
          DLog.d(CommunityPage.TAG, '#postData: $_postData');
        });
      },
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        } else {
          if (Platform.isAndroid) {
            await _onBackKeyAos();
          }
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: CommonAppbar.simpleNoTitleWithExit(context, Colors.white, Colors.black),
        body: SafeArea(
          child: _isOut || _rtUrl.isEmpty
              ? Container()
              : Stack(
                  children: [
                    InAppWebView(
                      initialSettings: _inAppWebViewSettings,
                      initialUrlRequest: URLRequest(
                        //url: WebUri.uri(UriData.fromString(Net.THINK_COMMUNITY_AJAX).uri),
                        url: WebUri(_rtUrl),
                        method: 'POST',
                        body: Uint8List.fromList(utf8.encode(_postData)),
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                      ),
                      onWebViewCreated: (controller) {
                        _inAppWebViewController = controller;
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        return NavigationActionPolicy.ALLOW;
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
    );
  }

  String getTimeString() {
    final df = DateFormat('yyyyMMddhhmmss');
    return df.format(DateTime.now());
  }

  Future<bool> _onBackKeyAos() async {
    await _inAppWebViewController?.clearFocus();
    await _inAppWebViewController?.stopLoading();
    setState(() {
      _isOut = true;
    });
    await _checkFinishOutStatus();
    return true;
  }

  Future<void> _checkFinishOutStatus() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      DLog.e('_checkFinishOutStatus addPostFrameCallback finish');
    });
  }
}
