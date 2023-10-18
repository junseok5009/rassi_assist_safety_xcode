import 'package:flutter/cupertino.dart';

// 포켓에 종목 추가할 때 사용하는 프로바이더
class AddStockProvider extends ChangeNotifier {

  String _stockCode = '';
  String _stockName = '';
  String _pocketSn = '';

  String get getStockCode => _stockCode;
  String get getStockName => _stockName;
  String get getPocketSn => _pocketSn;

  void updateAll(String vStockCode, String vStockName, String vPocketSn){
    this._stockCode = vStockCode;
    this._stockName = vStockName;
    this._pocketSn = vPocketSn;
    notifyListeners();
  }

}