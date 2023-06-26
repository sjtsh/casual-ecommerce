import 'package:flutter/cupertino.dart';


class SplashScreenManagement with ChangeNotifier {
  bool _phase1Completed = false;
  bool _phase2Completed = false;

  bool get phase1Completed => _phase1Completed;

  set phase1Completed(bool value) {
    _phase1Completed = value;
    notifyListeners();
  }

  bool get phase2Completed => _phase2Completed;

  set phase2Completed(bool value) {
    _phase2Completed = value;
    notifyListeners();
  }
}
