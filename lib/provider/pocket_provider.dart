import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/provider/provider_network/pocket_provider_network.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pocket.dart';

/// MY 포켓 리스트 provider
class PocketProvider with ChangeNotifier {
  final String TAG = '[* PocketProvider *]';

  final List<Pocket> _pktList = [];
  List<Pocket> get getPocketList => _pktList;

  void loggingPocketInfo() {
    _pktList.asMap().forEach((key1, value1) {
      DLog.d('ㅡㅡㅡㅡㅡ[$key1] ${value1.pktName} ${value1.pktSn}', 'ㅡㅡㅡㅡㅡ');
      value1.stkList.asMap().forEach((key2, value2) {
        DLog.d('[$key1] ${value1.pktName}', '[$key2] ${value2.stockName} / ${value2.stockCode}');
      });
      DLog.d(
          'ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ', 'ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    });
  }

  // 23.12.01 포켓리스트 + 각 포켓 당 안에 종목 Stock() 셋팅
  // 24.05.08 UserInfoProvider에 유저 결제 시 사용하는 updatePayment 사용하는 곳에 포켓 새로 불러오는 setList 도 호출해야합니다.
  // 결제 이후에 미리 포켓 상태가 달라질 수 있기 때문.
  Future<bool> setList() async {
    List<Pocket> getPcoketList =
        await PocketProviderNetwork.instance.getList();
    _pktList.clear();
    _pktList.addAll(getPcoketList);
    notifyListeners();
    if (_pktList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // 23.11.23 포켓 추가
  Future<bool> addPocket(String newPocketName) async {
    Pocket newPocket =
        (await PocketProviderNetwork.instance.addPocket(newPocketName)) as Pocket;
    if (newPocket.pktSn.isEmpty) {
      return false;
    } else {
      _pktList.add(newPocket);
      await CustomFirebaseClass.logEvtMyPocketMake(_pktList.length.toString());
      notifyListeners();
      return true;
    }
  }

  // 23.11.23 포켓 이름 변경
  Future<bool> changeNamePocket(Pocket pocket) async {
    bool result =
        await PocketProviderNetwork.instance.changeNamePocket(pocket);
    if (result) {
      int findIndex =
          _pktList.indexWhere((findPocket) => findPocket.pktSn == pocket.pktSn);
      if (findIndex > -1) {
        _pktList[findIndex].pktName = pocket.pktName;
        notifyListeners();
      }
      return true;
    } else {
      return false;
    }
  }

  // 23.11.28 포켓 순서 변경
  Future<bool> changeOrderPocket(List<Pocket> listPocket) async {
    bool result =
        await PocketProviderNetwork.instance.changeOrderPocket(listPocket);
    if (result) {
      _pktList.clear();
      _pktList.addAll(listPocket);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  // 23.11.28 포켓 리스트 삭제
  Future<bool> deleteListPocket(List<Pocket> listPocket) async {
    listPocket.removeWhere((element) => element.isDelete == false);
    bool result =
        await PocketProviderNetwork.instance.deleteListPocket(listPocket);
    if (result) {
      _pktList.removeWhere((element) {
        return listPocket
            .any((deletePocket) => deletePocket.pktSn == element.pktSn);
      });
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  // 23.11.23 포켓 삭제
  Future<bool> deletePocket(String pocketSn) async {
    bool result = await PocketProviderNetwork.instance.deletePocket(pocketSn);
    if (result) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  // 23.11.23 포켓 안에 종목 추가 / return [refresh / fail / retMsg]
  Future<String> addStock(Stock newStock, String pocketSn) async {
    String result =
        await PocketProviderNetwork.instance.addStock(newStock, pocketSn);
    if (result == CustomNvRouteResult.refresh) {
    await CustomFirebaseClass.logEvtMyPocketAdd(newStock.stockName, newStock.stockCode);
    int pocketListIndex = getPocketListIndexByPocketSn(pocketSn);
    if (pocketListIndex == -1) {
      await setList();
      return CustomNvRouteResult.fail;
    } else {
      _pktList[pocketListIndex].stkList.insert(0, newStock);
      notifyListeners();
      return CustomNvRouteResult.refresh;
    }
  } else {
    return result;
  }
  }

  // 23.11.23 포켓 안에 종목 삭제 / return [refresh / fail / retMsg]
  Future<String> deleteStock(Stock delStock, String pocketSn) async {
    String result =
        await PocketProviderNetwork.instance.deleteStock(delStock, pocketSn);
    if (result == CustomNvRouteResult.refresh) {
    int pocketListIndex = getPocketListIndexByPocketSn(pocketSn);
    if (pocketListIndex == -1) {
      await setList();
      return CustomNvRouteResult.fail;
    } else {
      int stockListIndex =
          _getStockListIndexByStockCode(pocketListIndex, delStock.stockCode);
      if (stockListIndex == -1) {
        await setList();
        return CustomNvRouteResult.fail;
      } else {
        _pktList[pocketListIndex].stkList.removeAt(stockListIndex);
        notifyListeners();
        return CustomNvRouteResult.refresh;
      }
    }
  } else {
    return result;
  }
  }

  // 23.11.29 포켓 안에 종목 순서 변경
  Future<bool> changeOrderStock(String pocketSn, List<Stock> listStock) async {
    bool result = await PocketProviderNetwork.instance
        .changeOrderStock(pocketSn, listStock);
    if (result) {
      try {
        Pocket pocket =
            _pktList.singleWhere((element) => element.pktSn == pocketSn);
        pocket.stkList.clear();
        pocket.stkList.addAll(listStock);
        notifyListeners();
        return true;
      } on Exception catch (_, __) {
        return false;
      }
    } else {
      return false;
    }
  }

  // 23.11.29 포켓 안에 종목 리스트 삭제 / return [refresh / fail / retMsg]
  Future<String> deleteListStock(String pocketSn, List<Stock> listStock) async {
    listStock.removeWhere((element) => element.isDelete == false);
    String result = await PocketProviderNetwork.instance
        .deleteListStock(pocketSn, listStock);
    if (result == CustomNvRouteResult.refresh) {
    try {
      Pocket pocket =
          _pktList.singleWhere((element) => element.pktSn == pocketSn);
      pocket.stkList.removeWhere((element) {
        return listStock
            .any((deleteStock) => deleteStock.stockCode == element.stockCode);
      });
      notifyListeners();
      return CustomNvRouteResult.refresh;
    } on Exception catch (_, __) {
      return CustomNvRouteResult.fail;
    }
  } else {
    return result;
  }
  }

  // 23.12.15 3종목 알림 설정 / return [refresh / fail / retMsg]
  Future<String> changeAlarmListStock(List<Stock> listStock) async {
    String result = await PocketProviderNetwork.instance
        .changeAlarmListStock(listStock);
    notifyListeners();
    return result;
    }

  Pocket getPocketByPocketSn(String pocketSn) {
    int listIndex = _pktList.indexWhere((element) => element.pktSn == pocketSn);
    if(listIndex == -1){
      return _pktList.first;
    }else{
      return _pktList[listIndex];
    }
  }

  // 포켓Sn으로 포켓리스트의 index 찾기
  int getPocketListIndexByPocketSn(String pocketSn) {
    return _pktList.indexWhere((element) => element.pktSn == pocketSn);
  }

  // 포켓리스트의 index + 종목코드로 종목리스트의 Index 찾기
  int _getStockListIndexByStockCode(int pocketListIndex, String stockCode) {
    return _pktList[pocketListIndex]
        .stkList
        .indexWhere((element) => element.stockCode == stockCode);
  }

  int get getAllStockListCount{
    int count = 0;
    for (var element in _pktList) {
      count += element.stkList.length;
    }
    DLog.e('getAllStockListCount() count : $count');
    return count;
  }

  @override
  String toString() {
    return 'Pockets_Size : ${_pktList.length}';
  }
}
