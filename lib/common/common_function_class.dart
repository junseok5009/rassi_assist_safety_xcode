/* DEFINE
      공통으로 사용하는 util 함수 클래스 모음집입니다.
   */
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class CommonFunctionClass {
  CommonFunctionClass._privateConstructor();

  static final CommonFunctionClass instance =
      CommonFunctionClass._privateConstructor();

  Size getSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    } else {
      return const Size(0, 0);
    }
  }

  // 에이전트 관련 url 여부 확인1
  bool isAgentLink(String url) {
    return (url.contains('agentCode'));
  }

  // 저장된 url 에이전트 여부 확인2
  Future<bool> get isAgentLinkSaved async {
    var prefs = await SharedPreferences.getInstance();
    String? prefsLink = prefs.getString(Const.PREFS_DEEPLINK_URI);
    PendingDynamicLinkData? agLink = AppGlobal().pendingDynamicLinkData;
    if(agLink != null && isAgentLink(agLink.link.toString())){
      return true;
    }else if(prefsLink != null && isAgentLink(prefsLink)){
      return true;
    }else{
      return false;
    }
  }

  // 저장된 url 에이전트 링크
  Future<Uri?> get getSavedAgentLink async {
    var prefs = await SharedPreferences.getInstance();
    String? prefsLink = prefs.getString(Const.PREFS_DEEPLINK_URI);
    PendingDynamicLinkData? agLink = AppGlobal().pendingDynamicLinkData;
    if(agLink != null && isAgentLink(agLink.link.toString())){
      return agLink.link;
    }else if(prefsLink != null && isAgentLink(prefsLink)){
      return Uri.parse(prefsLink);
    }else{
      return null;
    }
  }

}
