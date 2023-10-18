import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/tr_search/tr_search01.dart';


/// (종목 가격 / my종목)프로바이더 + http Search01
class StockInfoProvider with ChangeNotifier {

  Search01 _search01 = defSearch01;
  Color _color = Colors.white;
  String _curSubInfo = '';
  String _timeTxt = '';
  bool _isLoading = true;

  String get getStockName => _search01 == null ? '' : _search01.stockName;
  String get getStockCode => _search01 == null ? '' : _search01.stockCode;
  bool get getIsMyStock => _search01 == null ? false : _search01.isMyStock == 'Y' ? true : false;
  String get getMyTradeFlag => _search01 == null ? '' : _search01.myTradeFlag;
  String get getCurrentPrice => _search01 == null ? '' : _search01.currentPrice;
  String get getFluctaionRate => _search01 == null ? '' : _search01.fluctuationRate;
  String get getCurrentSubInfo => _curSubInfo;
  Color get getColor => _color;
  String get getTimeTxt => _timeTxt;
  String get getPockSn => _search01 == null ? '' : _search01.pocketSn;
  bool get getIsLoading => _isLoading;

  void postRequest(String vStockCode){
    if(!_isLoading){
      _isLoading = true;
      notifyListeners();
    }
    _fetchPosts(vStockCode);
  }

  void _fetchPosts(String vStockCode) async {
    var url = Uri.parse(Net.TR_BASE + TR.SEARCH01);
    try {
      final http.Response response = await http.post(
        url,
        body: jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'stockCode': vStockCode,
        }),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      final TrSearch01 resData = TrSearch01.fromJson(jsonDecode(response.body));
      if(resData.retCode == RT.SUCCESS) {
        _search01 = resData.retData!;
        if(_search01.fluctuationRate.contains('-')) {
          _curSubInfo = '▼${TStyle.getMoneyPoint(_search01.fluctuationAmt.replaceAll('-', ''))}  ${_search01.fluctuationRate}%';
          _color = RColor.sigSell;
        } else if(_search01.fluctuationRate == '0.00') {
          _curSubInfo = '${TStyle.getMoneyPoint(_search01.fluctuationAmt)}  ${_search01.fluctuationRate}%';
          _color = Colors.grey[500]!;
        } else {
          _curSubInfo = '▲${TStyle.getMoneyPoint(_search01.fluctuationAmt)}  +${_search01.fluctuationRate}%';
          _color = RColor.sigBuy;
        }

        _timeTxt = '${TStyle.getDateDivFormat(_search01.tradeDate)} ${TStyle.getTimeFormat(_search01.tradeTime)} ${_search01.timeDivTxt}';

        DLog.e('StockInfoProvider finish notifyListeners()');
        _isLoading = false;
        notifyListeners();
      }


    } on TimeoutException catch (_) {

    } on SocketException catch (_) {

    }
  }

}