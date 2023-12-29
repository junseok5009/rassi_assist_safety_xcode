import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/models/rq_pocket_order.dart';
import 'package:rassi_assist/models/rq_stock_order.dart';
import 'package:rassi_assist/models/tr_no_retdata.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock04.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock15.dart';

class PocketProviderNetwork {
  PocketProviderNetwork._privateConstructor();

  static final PocketProviderNetwork instance =
      PocketProviderNetwork._privateConstructor();

  // 23.12.01 포켓리스트 + 각 포켓 당 안에 종목 Stock() 셋팅
  Future<List<Pocket>> getList() async {
    List<Pocket> result = await _fetchPosts(
        TR.POCK15,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
        }));
    return result;
  }

  // 23.11.23 포켓 추가
  Future<Pock03?> addPocket(String newPocketName) async {
    bool result = await _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'C',
          'pocketName': newPocketName,
        }));
    if (result) {
      List<Pock03> result = await _fetchPosts(
          TR.POCK03,
          jsonEncode(<String, String>{
            'userId': AppGlobal().userId,
          })) as List<Pock03>;
      Pock03 newPocket = result.last;
      if(newPocket.waitCount != '0' || newPocket.holdCount != '0'){
        List<PStock> result = await _fetchPosts(
            TR.POCK04,
            jsonEncode(<String, String>{
              'userId': AppGlobal().userId,
              'pocketSn': newPocket.pocketSn,
            })) as List<PStock>;
        newPocket.stkList.addAll(result as Iterable<Stock>);
      }
      return newPocket;
    } else {
      return null;
    }
  }

  // 23.11.23 포켓 이름 변경
  Future<bool> changeNamePocket(Pocket pocket) async {
    return await _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'U',
          'pocketSn': pocket.pktSn,
          'pocketName': pocket.pktName,
        }));
  }

  // 23.11.28 포켓 순서 변경
  Future<bool> changeOrderPocket(List<Pocket> listPocket) async {
    List<SeqItem> seqList = [];
    for (int i = 0; i < listPocket.length; i++) {
      seqList.add(SeqItem(listPocket[i].pktSn, (i + 1).toString()));
    }
    PocketOrder order = PocketOrder(AppGlobal().userId, seqList);
    return await _fetchPosts(TR.POCK02, jsonEncode(order));
  }

  // 23.11.28 포켓 리스트 삭제
  Future<bool> deleteListPocket(List<Pocket> listPocket) async {
    return await _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, dynamic>{
          'userId': AppGlobal().userId,
          'crudType': 'D',
          'list_Pocket': listPocket.map((e) => e.pktSn).toList(),
        }));
  }

  // 23.11.23 포켓 삭제
  Future<bool> deletePocket(String pocketSn) async {
    return await _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'crudType': 'D',
          'pocketSn': pocketSn,
        }));
  }

  // 23.11.23 포켓 안에 종목 추가 / return [refresh / fail / retMsg]
  Future<String> addStock(Stock newStock, String pocketSn) async {
    return await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': pocketSn,
          'crudType': 'C',
          'stockCode': newStock.stockCode,
        }));
  }

  // 23.11.23 포켓 안에 종목 삭제 / return [refresh / fail / retMsg]
  Future<String> deleteStock(Stock delStock, String pocketSn) async {
    return await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': pocketSn,
          'crudType': 'D',
          'stockCode': delStock.stockCode,
        }));
  }

  // 23.11.29 포켓 안에 종목 순서 변경
  Future<bool> changeOrderStock(String pocketSn, List<Stock> listStock) async {
    List<SeqStock> seqList = [];
    for (int i = 0; i < listStock.length; i++) {
      seqList.add(SeqStock(listStock[i].stockCode, (i + 1).toString()));
    }
    StockOrder order = StockOrder(AppGlobal().userId, pocketSn, seqList);
    return await _fetchPosts(TR.POCK06, jsonEncode(order));
  }

  // 23.11.29 포켓 안에 종목 리스트 삭제 / return [refresh / fail / retMsg]
  Future<String> deleteListStock(String pocketSn, List<Stock> listStock) async {
    return await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, dynamic>{
          'userId': AppGlobal().userId,
          'pocketSn': pocketSn,
          'crudType': 'D',
          'list_Stock': listStock.map((e) => e.stockCode).toList(),
        }));
  }

  // 23.12.15 3종목 알림 설정 / return [refresh / fail / retMsg]
  Future<String> changeAlarmListStock(List<Stock> listStock) async {
    return await _fetchPosts(
        TR.POCK12,
        jsonEncode(<String, dynamic>{
          'userId': AppGlobal().userId,
          'list_Stock': listStock.map((e) => e.stockCode).toList(),
        }));
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

    // 포켓 추가 / 변경 / 삭제
    if (trStr == TR.POCK01) {
      final TrNoRetData resData =
          TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      }
      /*else if (resData.retCode == '8007') {
        return false;
      } */
      else {
        commonShowToast(resData.retMsg);
        return false;
      }
    }

    // 포켓 순서 변경
    else if (trStr == TR.POCK02) {
      final TrNoRetData resData =
          TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      }
      /*else if (resData.retCode == '8007') {
        return false;
      } */
      else {
        commonShowToast(resData.retMsg);
        return false;
      }
    }

    // 포켓 리스트 조회
    else if (trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.listData;
      } else {
        return [];
      }
    }

    // 포켓 상세 조회
    else if (trStr == TR.POCK04) {
      final TrPock04 resData = TrPock04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.retData.stkList;
      } else {
        return [];
      }
    }

    // 포켓 안에 종목 추가 / 삭제 / return [refresh / fail / retMsg]
    else if (trStr == TR.POCK05) {
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

    // 포켓 순서 변경
    else if (trStr == TR.POCK06) {
      final TrNoRetData resData =
          TrNoRetData.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      }
      /*else if (resData.retCode == '8007') {
        return false;
      } */
      else {
        commonShowToast(resData.retMsg);
        return false;
      }
    }

    // 3종목 알림 설정 / return [refresh / fail / retMsg]
    else if (trStr == TR.POCK12) {
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
