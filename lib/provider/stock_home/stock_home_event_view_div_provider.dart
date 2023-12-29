import 'package:flutter/cupertino.dart';

class StockHomeEventViewDivProvider extends ChangeNotifier {

  bool _disposed = false;

  int index = 0;
  int get getIndex => index;

  void setIndex(int selectedIndex) {
    index = selectedIndex;
    notifyListeners();
  }

  // dispose 할 때 _disposed -> true
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // _disposed == false 일 때만, super.notifyListeners() 호출!
  @override
  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

}