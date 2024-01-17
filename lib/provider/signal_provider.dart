import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/stock_pkt_signal.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock13.dart';

import 'provider_network/signal_provider_network.dart';

/// 나만의 신호 provider
class SignalProvider with ChangeNotifier {
  final String TAG = '[* SignalProvider *]';

  final Pocket13 _pocket13 = Pocket13.empty();

  String get getTimeDesc1 {
    if (_pocket13.tradeDate.isNotEmpty &&
        _pocket13.tradeTime.isNotEmpty &&
        _pocket13.timeDivTxt.isNotEmpty) {
      return '${TStyle.getDateDivFormat(_pocket13.tradeDate)}  '
          '${TStyle.getTimeFormat(_pocket13.tradeTime)}  ${_pocket13.timeDivTxt}';
    } else {
      return '';
    }
  }
  String get getTimeDivTxt => _pocket13.timeDivTxt;

  List<StockPktSignal> get getSignalList => _pocket13.stkList;

  void loggingSignalInfo() {
    _pocket13.stkList.asMap().forEach((key1, value1) {
      DLog.d('[$key1]', ' : ${value1.stockName}');
    });
  }

  // 23.12.08 나만의 신호 리스트 / retrun [true / false]
  Future<bool> setList() async {

    // 23.12.08 나만의 신호 리스트 / retrun [list / [] / null]
    Pocket13 getPocket13 = await SignalProviderNetwork.instance.getPocket13();
    if (getPocket13 == null) {
      return false;
    } else {
      _pocket13.tradeDate = getPocket13.tradeDate;
      _pocket13.timeDivTxt = getPocket13.timeDivTxt;
      _pocket13.tradeTime = getPocket13.tradeTime;
      _pocket13.stkList.clear();
      _pocket13.stkList.addAll(getPocket13.stkList);
      notifyListeners();
      return true;
    }
  }

  // 23.12.08 나만의 신호 등록 / return [refresh / fail / retMsg]
  Future<String> addSignal(Stock newStock, String buyPrice) async {
    //return [refresh / fail / retMsg]
    String result =
        await SignalProviderNetwork.instance.addSignal(newStock.stockCode, buyPrice);
    if (result != null && result == CustomNvRouteResult.refresh) {
      await CustomFirebaseClass.logEvtMySignalAdd(newStock.stockName, newStock.stockCode);
      bool result = await setList();
      if (result) {
        return CustomNvRouteResult.refresh;
      } else {
        return CustomNvRouteResult.fail;
      }
    } else {
      return result;
    }
  }

  // 23.12.05 "resultDiv": "S" 나만의 매도 신호 수정 / return [refresh / fail / retMsg]
  Future<String> changeSignalS(
      String pocketSn, String stockCode, String buyPrice) async {
    //return [refresh / fail / retMsg]
    String result = await SignalProviderNetwork.instance
        .changeSignalS(pocketSn, stockCode, buyPrice);
    if (result != null && result == CustomNvRouteResult.refresh) {
      bool result = await setList();
      if (result) {
        return CustomNvRouteResult.refresh;
      } else {
        return CustomNvRouteResult.fail;
      }
    } else {
      return result;
    }
  }

  // 23.12.07 "resultDiv": "P" 나만의 매도 신호 수정 / return [refresh / fail / retMsg]
  Future<String> changeSignalP(
      String pocketSn, String stockCode, String buyPrice) async {
    String result = await SignalProviderNetwork.instance
        .changeSignalP(pocketSn, stockCode, buyPrice);
    if (result != null && result == CustomNvRouteResult.refresh) {
      bool result = await setList();
      if (result) {
        return CustomNvRouteResult.refresh;
      } else {
        return CustomNvRouteResult.fail;
      }
    } else {
      return result;
    }
  }

  // 23.12.08 "resultDiv": "S" 나만의 매도 신호 삭제 / return [refresh / fail / retMsg]
  Future<String> delSignalS(String pocketSn, String stockCode) async {
    String result =
        await SignalProviderNetwork.instance.delSignalS(pocketSn, stockCode);
    if (result != null && result == CustomNvRouteResult.refresh) {
      bool result = await setList();
      if (result) {
        return CustomNvRouteResult.refresh;
      } else {
        return CustomNvRouteResult.fail;
      }
    } else {
      return result;
    }
  }

  // 23.12.08 "resultDiv": "P" 나만의 매도 신호 삭제 / return [refresh / fail / retMsg]
  Future<String> delSignalP(String pocketSn, String stockCode) async {
    String result =
        await SignalProviderNetwork.instance.delSignalP(pocketSn, stockCode);
    if (result != null && result == CustomNvRouteResult.refresh) {
      bool result = await setList();
      if (result) {
        return CustomNvRouteResult.refresh;
      } else {
        return CustomNvRouteResult.fail;
      }
    } else {
      return result;
    }
  }

/*int getStockPktSignalByStockPktSignalSn(String pocketSn) {
    return _pocket13.stkList
        .indexWhere((element) => element.pktSn == pocketSn);
  }

  // 포켓Sn으로 포켓리스트의 index 찾기
  int getStockPktSignalListIndexByStockPktSignalSn(String pocketSn) {
    return _pocket13.stkList
        .indexWhere((element) => element.pktSn == pocketSn);
  }

  // 포켓리스트의 index + 종목코드로 종목리스트의 Index 찾기
  int _getStockListIndexByStockCode(
      int StockPktSignalListIndex, String stockCode) {
    return _pocket13.stkList[StockPktSignalListIndex]
        .stkList
        .indexWhere((element) => element.stockCode == stockCode);
  }*/
}
