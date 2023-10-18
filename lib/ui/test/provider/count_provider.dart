import 'package:flutter/cupertino.dart';

class CountProvider extends ChangeNotifier{
  int _count = 0;

  int get getCount => _count;

  getCount2() => _count;

  void increase(){
    ++_count;
    notifyListeners();
  }

  void decrease(){
    --_count;
    notifyListeners();
  }

}