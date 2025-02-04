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
    if (_pocket13.tradeDate.isNotEmpty && _pocket13.tradeTime.isNotEmpty && _pocket13.timeDivTxt.isNotEmpty) {
      return '${TStyle.getDateDivFormat(_pocket13.tradeDate)}  '
          '${TStyle.getTimeFormat(_pocket13.tradeTime)}  ${_pocket13.timeDivTxt}';
    } else {
      return '';
    }
  }

  String get getTimeDivTxt => _pocket13.timeDivTxt;

  List<StockPktSignal> get getSignalList => _pocket13.stkList;

  // 나만의 신호 필터 0 : 추가순 / 1 : 수익률순 / 2 : 신호발생순 / 3:종목명순
  int _sortIndex = 0;
  int get getSortIndex => _sortIndex;

  // 24.06.05 나만의 신호 sortIndex == 2 (신호 발생순) 일 경우에,
  // 나만의 신호로 등록된 종목은 있는데, 신호 발생 종목이 하나도 없을 경우 체크를 위한 변수
  bool _sortSignalStockCountIsZero = false;
  bool get getSortSignalStockCountIsZero => _sortSignalStockCountIsZero;

  void loggingSignalInfo() {
    _pocket13.stkList.asMap().forEach((key1, value1) {
      DLog.d('[$key1]', ' : ${value1.stockName}');
    });
  }

  // 23.12.08 나만의 신호 리스트 / retrun [true / false]
  Future<bool> setList() async {
    // 23.12.08 나만의 신호 리스트 / retrun [list / [] / null]
    Pocket13 getPocket13 = await SignalProviderNetwork.instance.getPocket13();
    _pocket13.tradeDate = getPocket13.tradeDate;
    _pocket13.timeDivTxt = getPocket13.timeDivTxt;
    _pocket13.tradeTime = getPocket13.tradeTime;
    _pocket13.stkList.clear();
    _pocket13.stkList.addAll(getPocket13.stkList);
    _sortIndex = 0;
    notifyListeners();
    return true;
  }

  // 23.12.08 나만의 신호 등록 / return [refresh / fail / retMsg]
  Future<String> addSignal(Stock newStock, String buyPrice) async {
    //return [refresh / fail / retMsg]
    String result = await SignalProviderNetwork.instance.addSignal(newStock.stockCode, buyPrice);
    if (result == CustomNvRouteResult.refresh) {
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
  Future<String> changeSignalS(String pocketSn, String stockCode, String buyPrice) async {
    //return [refresh / fail / retMsg]
    String result = await SignalProviderNetwork.instance.changeSignalS(pocketSn, stockCode, buyPrice);
    if (result == CustomNvRouteResult.refresh) {
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
  Future<String> changeSignalP(String pocketSn, String stockCode, String buyPrice) async {
    String result = await SignalProviderNetwork.instance.changeSignalP(pocketSn, stockCode, buyPrice);
    if (result == CustomNvRouteResult.refresh) {
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
    String result = await SignalProviderNetwork.instance.delSignalS(pocketSn, stockCode);
    if (result == CustomNvRouteResult.refresh) {
      int deleteListIndex = _pocket13.stkList.indexWhere((element) => element.pocketSn == pocketSn);
      if(deleteListIndex != -1){
        _pocket13.stkList.removeAt(deleteListIndex);
        notifyListeners();
        return CustomNvRouteResult.refresh;
      }else{
        bool result = await setList();
        if (result) {
          return CustomNvRouteResult.refresh;
        } else {
          return CustomNvRouteResult.fail;
        }
      }
    } else {
      return result;
    }
  }

  // 23.12.08 "resultDiv": "P" 나만의 매도 신호 삭제 / return [refresh / fail / retMsg]
  Future<String> delSignalP(String pocketSn, String stockCode) async {
    String result = await SignalProviderNetwork.instance.delSignalP(pocketSn, stockCode);
    if (result == CustomNvRouteResult.refresh) {
      int deleteListIndex = _pocket13.stkList.indexWhere((element) => element.pocketSn == pocketSn);
      if(deleteListIndex != -1){
        _pocket13.stkList.removeAt(deleteListIndex);
        notifyListeners();
        return CustomNvRouteResult.refresh;
      }else{
        bool result = await setList();
        if (result) {
          return CustomNvRouteResult.refresh;
        } else {
          return CustomNvRouteResult.fail;
        }
      }
    } else {
      return result;
    }
  }


  /// 24.04.25 나만의 신호 리스트 정렬(필터)
  // 24.04.25 sortIndex = 0 / 나만의 신호 리스트 정렬 [최근 등록순 butRegDttm(매도신호발생시 이 값은 없음)]
  Future<bool> get filterListBuyRegDttm async {
    if(_pocket13.isEmpty){
      await setList();
    }
    _pocket13.stkList.sort(
          (a, b) {
        return (int.tryParse(b.buyRegDttm) ?? 0)
            .compareTo((int.tryParse(a.buyRegDttm) ?? 0));
      },
    );
    _sortIndex = 0;
    notifyListeners();
    return true;
  }

  // 24.04.25 sortIndex = 1 / 나만의 신호 리스트 정렬 [수익률순(보유>매도완료)]
  Future<bool> get filterListProfitRate async {
    if(_pocket13.isEmpty){
        await setList();
    }
    _pocket13.stkList.sort(
          (a, b) {
            if (a.myTradeFlag == 'S' && b.myTradeFlag == 'S') {
              return double.parse(b.profitRate).compareTo(double.parse(a.profitRate));
            } else if (a.myTradeFlag == 'H' && b.myTradeFlag == 'H') {
              return double.parse(b.profitRate).compareTo(double.parse(a.profitRate));
            } else {
              // 's'와 'h'가 아닌 경우, 'H'를 우선시
              return a.myTradeFlag == 'H' ? -1 : 1;
            }
      },
    );
    _sortIndex = 1;
    notifyListeners();
    return true;
  }

  // 24.04.26 sortIndex = 2 / 나만의 신호 리스트 정렬 [신호발생순(보유 노출X)]
  Future<bool> get filterListSellDttm async {
    if(_pocket13.isEmpty){
      await setList();
    }
    bool vSortSignalStockCountIsZero = true;
    _pocket13.stkList.sort(
          (a, b) {
        if (a.myTradeFlag == 'S' && b.myTradeFlag == 'S') {
          vSortSignalStockCountIsZero = false;
          return int.parse(b.sellDttm).compareTo(int.parse(a.sellDttm));
        } else {
          // 's'와 'h'가 아닌 경우, 's'를 우선시
          return a.myTradeFlag == 'S' ? -1 : 1;
        }
      },
    );
    _sortIndex = 2;
    _sortSignalStockCountIsZero = vSortSignalStockCountIsZero;
    notifyListeners();
    return true;
  }

  // 24.04.26 sortIndex = 3 / 나만의 신호 리스트 정렬 [종목명(영어A~한글ㄱ)]
  Future<bool> get filterListStockName async {
    if(_pocket13.isEmpty){
      await setList();
    }
    _pocket13.stkList.sort(
          (a, b) {
        return a.stockName
            .compareTo(b.stockName);
      },
    );
    notifyListeners();
    _sortIndex = 3;
    return true;
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
