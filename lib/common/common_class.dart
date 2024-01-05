// 공통 함수들 모음 파일

//웹브라우저 호출
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> commonLaunchURL(String url) async {
  DLog.i('commonLaunchURL : $url');
  Uri uri = Uri.parse(url);
  await canLaunchUrl(uri)
      ? await launchUrl(
          uri,
        )
      : DLog.d('tag', 'could_not_launch_this_url : $url');
}

Future<void> commonLaunchUrlAppOpen(String url) async {
  DLog.i('commonLaunchURL : $url');
  Uri uri = Uri.parse(url);
  await canLaunchUrl(uri)
      ? await launchUrl(uri, mode: LaunchMode.externalApplication)
      : DLog.d('tag', 'could_not_launch_this_url : $url');
}

Future<void> commonLaunchUrlApp(String url) async {
  DLog.d('common_class.dart', 'commonLaunchUrlApp : $url');
  Uri uri = Uri.parse(url);
  await canLaunchUrl(uri)
      ? await launchUrl(uri, mode: LaunchMode.externalApplication)
      : DLog.d('tag', 'could_not_launch_this_url : $url');
}

void commonShowToast(String msg) {
  DLog.d('common_class.dart', 'commonShowToast : $msg');
  Fluttertoast.showToast(
    textColor: Colors.white,
    backgroundColor: const Color(0xff696969),
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
  );
}

void commonShowToastCenter(String msg) {
  DLog.d('common_class.dart', 'commonShowToastTop : $msg');
  Fluttertoast.showToast(
    textColor: Colors.white,
    backgroundColor: const Color(0xff696969),
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
  );
}
