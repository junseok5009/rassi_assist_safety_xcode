import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';

/// 2023.10.18 inapp_webview + 웹뷰 셋팅 추가
class InappWebviewPage extends StatefulWidget {
  //const InappWebviewPage({Key? key}) : super(key: key);
  static const String TAG = "[InappWebviewPage]";
  static const String TAG_NAME = '인앱웹뷰';
  final String title;
  final String url;

  const InappWebviewPage({required this.title, required this.url, Key? key}) : super(key: key);

  @override
  State<InappWebviewPage> createState() => _InappWebviewPageState();
}

class _InappWebviewPageState extends State<InappWebviewPage> {
  late InAppWebViewController? _inAppWebViewController;

  final InAppWebViewSettings _inAppWebViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    // URL 로딩 제어
    mediaPlaybackRequiresUserGesture: false,
    // 미디어 자동 재생
    javaScriptEnabled: true,
    // 자바스크립트 실행 여부
    javaScriptCanOpenWindowsAutomatically: true,
    // 팝업 여부
    useHybridComposition: true,
    // 하이브리드 사용을 위한 안드로이드 웹뷰 최적화
    supportMultipleWindows: true,
    // 멀티 윈도우 허용
    allowsInlineMediaPlayback: true, // 웹뷰 내 미디어 재생 허용
  );

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      InappWebviewPage.TAG_NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        } else {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: CommonAppbar.simpleNoTitleWithExit(context, Colors.white, Colors.black),
        body: SafeArea(
          child:InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
            ),
            initialSettings: _inAppWebViewSettings,
            onProgressChanged: (controller, progress) {
              //DLog.e('[InAppWebView_onProgressChanged] progress : ${progress}');
            },
            onWebViewCreated: (InAppWebViewController controller) {
              //DLog.e('onWebViewCreated()');
              _inAppWebViewController = controller;
            },
            shouldOverrideUrlLoading: (controller, action) async {
              return NavigationActionPolicy.ALLOW;
            },
            // 웹 페이지에서 버튼 같은 거 클릭해서 다른 창 띄울 때 이 메소드 표현되는 것 같음.
            onCreateWindow: (controller, createWindowRequest) async {
              //DLog.e('onCreateWindow()');
              commonLaunchUrlApp(createWindowRequest.request.url.toString());
              return true;
            },
            onLoadStop: (controller, url) {
              //DLog.e('onLoadStop');
            },
            onConsoleMessage: (controller, consoleMessage) {
              //DLog.e('onConsoleMessage() msg : ${consoleMessage.message}');
            },
          ),
        ),
      ),
    );
  }

  Future<void> _checkFinishOutStatus() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      DLog.e('_checkFinishOutStatus addPostFrameCallback finish');
    });
  }
}
