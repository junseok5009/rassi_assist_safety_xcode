import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_user/tr_user04.dart';

// 12.08 유저 정보 프로바이더 ( 결제 시 업데이트 )
class UserInfoProvider extends ChangeNotifier {
  final String TAG = '[* UserInfoProvider *]';

  User04 _user04 = defUser04;

  bool isPremiumUser() {
    if (_user04.accountData.prodCode == 'AC_PR') {
      return true;
    } else {
      return false;
    }
  }

  //3종목 알림 사용자
  bool is3StockUser() {
    if (_user04.accountData.prodCode == 'AC_S3') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> init() async {
    User04 getUser04 = await _fetchPosts(
        TR.USER04,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
        }));
    if (getUser04 == null) {
      AccountData().setFreeUserStatus();
      return false;
    } else {
      _user04 = getUser04;
      //notifyListeners();
      if (_user04.accountData != null) {
        return await _user04.accountData.initUserStatus();
      } else {
        AccountData().setFreeUserStatus();
        return false;
      }
    }
  }

  Future<bool> updatePayment() async {
    User04 getUser04 = await _fetchPosts(
        TR.USER04,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
        }));
    if (getUser04 == null) {
      AccountData().setFreeUserStatus();
      return false;
    } else {
      _user04 = getUser04;
      if (_user04.accountData != null) {
        await _user04.accountData.initUserStatusAfterPayment();
        notifyListeners();
        return true;
      } else {
        AccountData().setFreeUserStatus();
        return false;
      }
    }
  }

  dynamic _fetchPosts(String trStr, String json) async {
    DLog.i('$trStr $json');
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      return _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.e('ERR : TimeoutException (12 seconds)');
    }
  }

  dynamic _parseTrData(String trStr, final http.Response response) async {
    DLog.i(response.body);

    // 포켓 추가 / 변경 / 삭제
    if (trStr == TR.USER04) {
      final TrUser04 resData = TrUser04.fromJson(jsonDecode(response.body));

      if (resData.retCode == RT.SUCCESS) {
        return resData.retData;
      } else {
        AccountData().setFreeUserStatus();
        return null;
      }
    }
  }
}
