import 'package:flutter/cupertino.dart';

class StockTabNameProvider extends ChangeNotifier {
  bool isTop = true;
  bool get getIsTop => isTop;
  void setJustTopTrue(){
    isTop = true;
  }
  void setTopTrue() {
    isTop = true;
    notifyListeners();
  }
  void setTopFalse() {
    isTop = false;
    notifyListeners();
  }
}