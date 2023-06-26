import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:flutter/cupertino.dart';
import '../BackEnd/Entities/SearchProduct.dart';
import '../BackEnd/Services/SearchingProductService.dart';

class SearchingProductManagement with ChangeNotifier {
  final TextEditingController controller = TextEditingController();

  List<SearchProduct>? _results;

  List<SearchProduct>? get results => _results;

  updateSearch(MyProduct myProduct, String? remark, String? refurl) {
    if (_results == null) return;
    for (int i = 0; i < _results!.length; i++) {
      if (_results![i].id == myProduct.master) {
        _results![i].myProduct = myProduct;
        results![i].myProduct!.remarks ??= RemarksModel.empty();
        results![i].myProduct?.remarks?.remarksStaff = RemarksWithUserModel.fromRemarks(remark);
        _results![i].myProduct?.remarks!.remarksStaffReferenceUrl = refurl;
        break;
      }

    }
    notifyListeners();
  }

  set results(List<SearchProduct>? value) {
    _results = value;
    notifyListeners();
  }

  get resetQuery {
    if (controller.text.isEmpty) return clear;
    if (controller.text.trim().isEmpty) return clear;
    String currentQuery = controller.text;
    SearchingProductService().searchProducts(currentQuery, 0, 20).then((value) {
      if (controller.text == currentQuery) results = value;
    });
  }

  get clear {
    results = null;
    controller.clear();
  }
}

class TabProduct with ChangeNotifier {
  final PageController controller = PageController();

  int _page = 0;

  int get page => _page;

  set page(int value) {
    _page = value;
    notifyListeners();
  }

  animateTo(int page) {
    controller.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }
}
