import 'package:flutter/material.dart';

class SignInOrRegister extends ChangeNotifier {
  bool _isSignIn = false;

  bool get isSignIn {
    return _isSignIn;
  }

  void setIsSignIn(bool b) {
    _isSignIn = b;
    notifyListeners();
  }
}