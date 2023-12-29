import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_no_retdata.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock13.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock15.dart';

class SignalProviderNetwork {
  SignalProviderNetwork._privateConstructor();

  static final SignalProviderNetwork instance =
      SignalProviderNetwork._privateConstructor();

  // 23.12.08 나만의 신호 리스트 / retrun [pocket13 / pocket13.isEmpty / null]
  Future<Pocket13> getPocket13() async {
    return await _fetchPosts(
        TR.POCK13,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
        }));
  }

  // 23.12.01 나만의 매도 신호 등록 / return [refresh / fail / retMsg]
  Future<String> addSignal(String stockCode, String buyPrice) async {
    // return [refresh / fail / retMsg]
    String result = await _fetchPosts(
        TR.POCK14,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'C',
          'buyPrice': buyPrice,
          'stockCode': stockCode,
        }));

    return result;
  }

  // 23.12.05 "resultDiv": "S" 나만의 매도 신호 수정 / return [refresh / fail / retMsg]
  Future<String> changeSignalS(
      String pocketSn, String stockCode, String buyPrice) async {
    String result = await _fetchPosts(
        TR.POCK14,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'U',
          'pocketSn': pocketSn,
          'buyPrice': buyPrice,
          'stockCode': stockCode,
        }));
    return result;
  }

  // 23.12.07 "resultDiv": "P" 나만의 매도 신호 수정 / return [refresh / fail / retMsg]
  Future<String> changeSignalP(
      String pocketSn, String stockCode, String buyPrice) async {
    String result = await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'U',
          'pocketSn': pocketSn,
          'buyPrice': buyPrice,
          'stockCode': stockCode,
        }));
    return result;
  }

  // 23.12.08 "resultDiv": "S" 나만의 매도 신호 삭제 / return [refresh / fail / retMsg]
  Future<String> delSignalS(String pocketSn, String stockCode) async {
    String result = await _fetchPosts(
        TR.POCK14,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'D',
          'pocketSn': pocketSn,
          'stockCode': stockCode,
        }));
    return result;
  }

  // 23.12.08 "resultDiv": "P" 나만의 매도 신호 삭제 / return [refresh / fail / retMsg]
  Future<String> delSignalP(String pocketSn, String stockCode) async {
    String result = await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'U',
          'pocketSn': pocketSn,
          'buyPrice': '0',
          'stockCode': stockCode
        }));
    return result;
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

  dynamic _parseTrData(String trStr, final http.Response response) {
    DLog.i(response.body);

    // 나만의 매도신호 변경, 삭제 / return [refresh / fail / retMsg]
    if (trStr == TR.POCK05) {
      final TrNoRetData resData =
          TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return CustomNvRouteResult.refresh;
      } else {
        if (int.parse(resData.retCode) > 1000) {
          return resData.retMsg;
        } else {
          return CustomNvRouteResult.fail;
        }
      }
    }

    // 23.12.08 나만의 신호 리스트 / retrun [list / [] / null]
    else if (trStr == TR.POCK13) {
      final TrPock13 resData = TrPock13.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.retData;
      } else if (resData.retCode == RT.NO_DATA) {
        return Pocket13.empty();
      } else {
        return null;
      }
    }

    // 23.12.05 나만의 매도 신호 등록 / return [refresh / fail / retMsg]
    else if (trStr == TR.POCK14) {
      final TrNoRetData resData =
          TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return CustomNvRouteResult.refresh;
      } else {
        if (int.parse(resData.retCode) > 1000) {
          return resData.retMsg;
        } else {
          return CustomNvRouteResult.fail;
        }
      }
    }

    // 포켓 리스트 + 종목 리스트 / return [list]
    else if (trStr == TR.POCK15) {
      final TrPock15 resData = TrPock15.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.listData;
      } else {
        return [];
      }
    }
  }
}
