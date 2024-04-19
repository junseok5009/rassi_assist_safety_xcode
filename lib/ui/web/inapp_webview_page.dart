import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';

/// 2023.10.18 inapp_webview + 웹뷰 셋팅 추가
class InappWebviewPage extends StatefulWidget {
  //const InappWebviewPage({Key? key}) : super(key: key);
  static const String TAG = "[InappWebviewPage]";
  static const String TAG_NAME = '웹뷰';
  final String _title;
  final String _url;

  InappWebviewPage(this._title, this._url, {Key? key}) : super(key: key);

  final InAppWebViewGroupOptions _inAppWebViewGroupOptions =
      InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      preferredContentMode: UserPreferredContentMode.MOBILE,
      resourceCustomSchemes: ['intent'],
      javaScriptCanOpenWindowsAutomatically: true,
      javaScriptEnabled: true,
      useOnDownloadStart: true,
      useOnLoadResource: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: true,
      allowFileAccessFromFileURLs: true,
      allowUniversalAccessFromFileURLs: true,
      verticalScrollBarEnabled: true,
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Chrome/81.0.4044.122 Mobile Safari/537.36',
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      allowContentAccess: true,
      //builtInZoomControls: true,
      thirdPartyCookiesEnabled: true,
      allowFileAccess: true,
      supportMultipleWindows: true,
      builtInZoomControls: true,
      useWideViewPort: true,

    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,
      //enableViewportScale: true,
      //alwaysBounceHorizontal: true,
      //alwaysBounceVertical: true,
    ),
  );

  @override
  State<InappWebviewPage> createState() => _InappWebviewPageState();
}

class _InappWebviewPageState extends State<InappWebviewPage> {
  late InAppWebViewController _inAppWebViewController;
  bool _isOut = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      InappWebviewPage.TAG_NAME,
    );
    DLog.e('initState _url : ${widget._url}');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        DLog.e('didPop : $didPop');
        if (didPop) {
          return;
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget._title,
              style: TStyle.commonTitle,
            ),
            leading: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                  if (Platform.isAndroid) {
                    await _onBackKeyAos();
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
              },
              child: const Icon(
                Icons.arrow_back_ios_sharp,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 1,
            centerTitle: false,
            leadingWidth: 40,
            titleSpacing: 5.0,
          ),
        ),
        body: SafeArea(
          child: _isOut
              ? Container()
              : InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(widget._url),
                  ),
                  initialOptions: widget._inAppWebViewGroupOptions,
                  onProgressChanged: (controller, progress) {},
                  onWebViewCreated: (InAppWebViewController controller) {
                    DLog.e('onWebViewCreated()');
                    _inAppWebViewController = controller;
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT,
                    );
                  },

                  // 웹 페이지에서 버튼 같은 거 클릭해서 다른 창 띄울 때 이 메소드 표현되는 것 같음.
                  onCreateWindow: (controller, createWindowRequest) async {
                    DLog.e('onCreateWindow()');
                    commonLaunchUrlApp(
                        createWindowRequest.request.url.toString());
                    return true;
                  },

                  onCloseWindow: (controller) {
                    DLog.e('onCloseWindow()');
                  },

                  onUpdateVisitedHistory: (controller, url, androidIsReload) {},
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {},
                  onLoadResourceCustomScheme: (controller, url) async {
                    await controller.stopLoading();
                    return null;
                  },
                  onLoadStart: (controller, url) async {
                    DLog.e('onLoadStart()');
                  },
                  onLoadError: (controller, url, code, message) {
                    DLog.e('onLoadError msg : ${message}');
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    DLog.e('onLoadHttpError msg : ${description}');
                  },
                  onLoadStop: (controller, url) {
                    DLog.e('onLoadStop');
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    DLog.e(
                        'onConsoleMessage() msg : ${consoleMessage.message}');
                  },
                  onFindResultReceived: (controller, activeMatchOrdinal,
                      numberOfMatches, isDoneCounting) {},
                ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    DLog.e('dispose()');
    super.dispose();
  }

  Future<bool> _onBackKeyAos() async {
    await _inAppWebViewController?.clearFocus();
    //_inAppWebViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse('')));
    await _inAppWebViewController?.android?.pause();
    await _inAppWebViewController?.stopLoading();
    //await Future.delayed(const Duration(milliseconds: 2000), () {});
    setState(() {
      _isOut = true;
    });
    await _checkFinishOutStatus();
    DLog.e('_onBackKeyAos await finish soon return');
    return true;
  }

  Future<void> _checkFinishOutStatus() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      DLog.e('_checkFinishOutStatus addPostFrameCallback finish');
    });
  }
}
