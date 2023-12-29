import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/models/rq_pocket_order.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock02.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock04.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock05.dart';

import '../models/none_tr/stock/stock.dart';

class PocketProviderNetClass{

  PocketProviderNetClass._privateConstructor();
  static final PocketProviderNetClass instance =
  PocketProviderNetClass._privateConstructor();


  // 23.11.23 포켓리스트 + 각 포켓 당 안에 종목 Stock() 셋팅
  Future<List<Pocket>> getList() async {
    List<Pocket> result = await _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
      'userId': AppGlobal().userId,
    })) as List<Pocket>;
    result.asMap().forEach((key, value) async {
      List<Stock> stockList = await _fetchPosts(TR.POCK04, jsonEncode(<String, String>{
        'userId': AppGlobal().userId,
        'pocketSn': value.pktSn,
      })) as List<Stock> ?? [];
      result[key].stkList.addAll(stockList);
    });
    return result;
  }

  // 23.11.23 포켓 추가
  Future<Pocket?> addPocket(String newPocketName) async {
    bool result = await _fetchPosts(TR.POCK01, jsonEncode(<String, String> {
      'userId': AppGlobal().userId,
      'crudType': 'C',
      'pocketName': newPocketName,
    }));
    if(result){
      List<Pocket> result = await _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
        'userId': AppGlobal().userId,
      })) as List<Pocket>;
      return result.last;
    }else{
      return null;
    }
  }

  // 23.11.23 포켓 이름 변경
  Future<bool> changeNamePocket(Pocket pocket) async {
    return await _fetchPosts(TR.POCK01, jsonEncode(<String, String> {
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
    // List<Pocket> deletePocketList = listPocket.map((e){
    //   if(e.isDelete){
    //     return e;
    //   }else{
    //     return null;
    //   }
    // }).toList();
    // deletePocketList.removeWhere((element) => element == null);
    // return await _fetchPosts(TR.POCK01, jsonEncode(<String, dynamic> {
    //   'userId': AppGlobal().userId,
    //   'crudType': 'D',
    //   'list_Pocket': deletePocketList.map((e) => e.pktSn).toList(),
    // }));

    return false;
  }

  // 23.11.23 포켓 삭제
  Future<bool> deletePocket(String pocketSn) async {
    return await _fetchPosts(TR.POCK01, jsonEncode(<String, String> {
      'userId': AppGlobal().userId,
      'crudType': 'D',
      'pocketSn': pocketSn,
    }));
  }

  // 23.11.23 포켓 안에 종목 추가
  Future<bool> addStock(Stock newStock, String pocketSn) async {
    return await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': pocketSn,
          'crudType': 'C',
          'stockCode': newStock.stockCode,
        }));
  }

  // 23.11.23 포켓 안에 종목 삭제
  Future<bool> deleteStock(Stock newStock, String pocketSn) async {
    return await _fetchPosts(
        TR.POCK05,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': pocketSn,
          'crudType': 'D',
          'stockCode': newStock.stockCode,
        }));
  }





  dynamic _fetchPosts(String trStr, String json) async {
    DLog.i('$trStr $json');
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      return _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      DLog.e('ERR : TimeoutException (12 seconds)');
    }
  }

  dynamic _parseTrData(String trStr, final http.Response response) {
    DLog.i(response.body);

    // 포켓 추가 / 변경 / 삭제
    if (trStr == TR.POCK01) {
      final TrPock01 resData = TrPock01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      } /*else if (resData.retCode == '8007') {
        return false;
      } */else{
        commonShowToast(resData.retMsg);
        return false;
      }
    }

    if (trStr == TR.POCK02) {
      final TrPock02 resData = TrPock02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      } /*else if (resData.retCode == '8007') {
        return false;
      } */else{
        commonShowToast(resData.retMsg);
        return false;
      }
    }

    // 포켓 리스트
    else if (trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.listData;
      } else {
        return [];
      }
    }

    // 포켓 상세
    else if (trStr == TR.POCK04) {
      final TrPock04 resData = TrPock04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return resData.retData.stkList;
      }else{
        return [];
      }
    }

    // 포켓 안에 종목 추가
    if (trStr == TR.POCK05) {
      final TrPock05 resData = TrPock05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        return true;
      } else {
        commonShowToast(resData.retMsg);
        return false;
      }
    }

  }
}