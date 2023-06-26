import 'package:ezdelivershop/BackEnd/Entities/Shop.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../Components/keys.dart';

class ProductShopManagement with ChangeNotifier {
  Shop? _selectedShop;

  Shop get selectedShop {
    _selectedShop ??=
        CustomKeys.context?.read<SignInManagement>().loginData?.staff.shop?.first;
    return _selectedShop!;
  }

  set selectedShop(Shop value) {
    _selectedShop = value;
    notifyListeners();
  }
}
