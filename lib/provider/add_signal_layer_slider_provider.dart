import 'package:flutter/cupertino.dart';

class SignalLayerSliderProvider extends ChangeNotifier {
  String _stockCode = '';

  String get getStockCode => _stockCode;

  double _currentPrice = 0;

  double get getCurrentPrice => _currentPrice;

  double _minPrice = 0;

  double get getMinPrice {
    if (_minPrice > _currentPrice) {
      return _currentPrice;
    }
    return _minPrice;
  }

  double _maxPrice = 1;

  double get getMaxPrice {
    if (_maxPrice < _currentPrice) {
      return _currentPrice + 1;
    }
    return _maxPrice;
  }

  double _hogaPrice = 1;

  double get getHogaPrice => _hogaPrice;

  int _division = 1;

  int get getDivision => _division;

  void setValues(String setStockCode, double setCurrentPrice,
      double setMinPrice, double setMaxPrice, double setHogaPrice) {
    _stockCode = setStockCode;
    _currentPrice = setCurrentPrice;
    _hogaPrice = setHogaPrice;
    _minPrice = ((setMinPrice / _hogaPrice).ceil()) * _hogaPrice;
    _maxPrice = ((setMaxPrice / _hogaPrice).floor()) * _hogaPrice;
    _division = (_maxPrice - _minPrice) ~/ _hogaPrice;
    notifyListeners();
  }

  void setCurrentPrice(double setCurrentPrice) {
    if (_currentPrice != setCurrentPrice) {
      _currentPrice = setCurrentPrice;
      notifyListeners();
    }
  }
}
