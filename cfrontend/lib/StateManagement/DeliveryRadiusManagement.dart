import 'package:flutter/cupertino.dart';

class DeliveryRadiusManagement with ChangeNotifier {
  bool ?_changeToProduct;

  bool? get changeToProduct => _changeToProduct;

  set changeToProduct(bool? value) {
    _changeToProduct = value;
    notifyListeners();
  }

  changeUIwithRole(){
    changeToProduct= !changeToProduct!;
    notifyListeners();

}

  bool _online =
      false; //this variable will represent whether the user is online or not
  //until the user connects to our server, the online status will stay false

  bool get online => _online;

  set online(bool value) {
      _online = value;
      notifyListeners();
  }

  double? _radius;

  changeCircleRadiusStart(double r) {
    _radius = r * 0.1142;
    notifyListeners();
  }

  set radius(double? value) {
    _radius = value;
    notifyListeners();
  }

  double? get radius => _radius;
}
