import 'package:flutter/cupertino.dart';

class LoginRassiProvider extends ChangeNotifier {

  bool _isKeyboardVisible = false;

  bool get getIsKeyboardVisible {
    return _isKeyboardVisible;
  }

  void initValueFalse() {
    _isKeyboardVisible = false;
  }

  void setValue(bool setKeyboardVisible) {
    if(_isKeyboardVisible != setKeyboardVisible){
      _isKeyboardVisible = setKeyboardVisible;
      notifyListeners();
    }
  }

}
