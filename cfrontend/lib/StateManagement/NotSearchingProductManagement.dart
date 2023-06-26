import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:flutter/cupertino.dart';

import '../BackEnd/Entities/SearchProduct.dart';
import '../BackEnd/Entities/ShopCategory.dart';
import '../BackEnd/Enums/Approval.dart';
import '../BackEnd/Services/ProductService.dart';
import '../UI/Product/SubproductScreen/NoSearchResults/NoSearchResults.dart';

class NotSearchingProductManagement with ChangeNotifier {
  MapEntry<int, int>? tabCount;
  List<Approval> _filterApproved = Approval.values.toList();

  List<Approval> get filterApproved => _filterApproved;
  DateTime? lastFilterChangedTime;

  ///multiple shop
  String? _shopId;

  String? get shopId => _shopId;

  set shopId(String? value) {
    _shopId = value;
    notifyListeners();
  }

  set filterApproved(List<Approval> value) {
    _filterApproved = value;
    reset(0, 6,shopId: _shopId!);
    notifyListeners();
  }

  reset(int skip, int limit, {required String? shopId}) async {
    DateTime now = DateTime.now();
    lastFilterChangedTime = now;
    _subsActivated = null;
    _subsDeactivated = null;
    tabCount = null;
    notifyListeners();
    await resetInitial(skip, limit, now, shopId!);
  }

  Map<SubCategory, List<SearchProduct>?>? _subsActivated;

  Iterable<MapEntry<SubCategory, List<SearchProduct>?>>?
      get subcategoryEntriesActivated => _subsActivated?.entries;

  set subcategoriesActivated(List<SubCategory> value) {
    _subsActivated = Map.fromEntries(value.map((e) => MapEntry(e, null)));
    notifyListeners();
  }

  Map<SubCategory, List<SearchProduct>?>? _subsDeactivated;

  Iterable<MapEntry<SubCategory, List<SearchProduct>?>>?
      get subcategoryEntriesDeactivated => _subsDeactivated?.entries;

  set subcategoriesDeactivated(List<SubCategory> value) {
    _subsDeactivated = Map.fromEntries(value.map((e) => MapEntry(e, null)));
    notifyListeners();
  }

  resetInitial(int skip, int limit, DateTime myChangedTime, String shopId) async {
    await Future.wait([
      loadActivated(0, lazyLoadSubCategoryInitialCount,
          myChangedTime: myChangedTime, shopId: shopId),
      loadDeactivated(shopId: shopId, 0, lazyLoadSubCategoryInitialCount,
          myChangedTime: myChangedTime),
      loadTabCount(),
    ]);
  }

  Future loadTabCount() async {
    tabCount =
        await ProductCrudService().getTabCounts(verified: filterApproved);
    notifyListeners();
  }

  Future loadActivated(int skip, int limit, {required String shopId, DateTime? myChangedTime}) async {
    myChangedTime ??= lastFilterChangedTime?.copyWith();
    List<SubCategory> addedSubsActivated = await ProductCrudService()
        .getSubProductsByLength(
        skip, limit,
            activated: true, verified: filterApproved);
    if (myChangedTime.toString() == lastFilterChangedTime.toString()) {
      _subsActivated ??= {};
      for (SubCategory i in addedSubsActivated) {
        if (!(_subsActivated?.containsKey(i) ?? true)) {
          _subsActivated![i] = null;
        }
      }
      notifyListeners();
    }
  }

  Future loadDeactivated(int skip, int limit, {required String shopId,DateTime? myChangedTime}) async {
    myChangedTime ??= lastFilterChangedTime?.copyWith();
    List<SubCategory> addedSubsDeactivated = await ProductCrudService()
        .getSubProductsByLength(skip, limit,
            activated: false, verified: filterApproved);
    if (myChangedTime.toString() == lastFilterChangedTime.toString()) {
      _subsDeactivated ??= {};
      for (SubCategory i in addedSubsDeactivated) {
        if (!(_subsDeactivated?.containsKey(i) ?? true)) {
          _subsDeactivated![i] = null;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getProds(
      int skip, int limit, SubCategory subID, bool activated, String shopId) async {
    DateTime? myChangedTime = lastFilterChangedTime?.copyWith();
    if (activated) {
      _subsActivated ??= {};
      // if (_subsActivated![subID] == null) {
      _subsActivated![subID] ??= [];
      List<SearchProduct> addedProds = await ProductCrudService()
          .getProductByLength(skip, limit, subID.id,
              activated: activated, verified: filterApproved);
      if ((myChangedTime ?? lastFilterChangedTime).toString() ==
          lastFilterChangedTime.toString()) {
        _subsActivated![subID]!.addAll(addedProds);
      }
      notifyListeners();
    } else {
      _subsDeactivated ??= {};
      _subsDeactivated![subID] ??= [];
      List<SearchProduct> addedProds = await ProductCrudService()
          .getProductByLength( skip, limit, subID.id,
              activated: activated, verified: filterApproved);
      if ((myChangedTime ?? lastFilterChangedTime).toString() ==
          lastFilterChangedTime.toString()) {
        _subsDeactivated![subID]!.addAll(addedProds);
      }
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  activateWithCreate(MyProduct prod, SubCategory cat) {
    activateWithCreateProperties(prod, cat);
    notifyListeners();
  }

  activateWithCreateProperties(MyProduct prod, SubCategory cat) {
    SearchProduct searchProduct = SearchProduct(
      myProduct: prod,
      id: prod.id,
      price: prod.price,
      name: prod.name,
      category: prod.category,
      displayId: prod.id,
      margin: prod.margin,
      sku: prod.sku,
      unit: prod.unit,
      image: prod.image,
      returnPolicy: prod.returnPolicy,
    );
    _subsActivated![cat] ??= [];
    _subsActivated![cat]!.insert(0, searchProduct);
    Iterable<SubCategory> subgroups = _subsActivated!.keys;
    for (var i in subgroups) {
      if (i.id == cat.id) {
        i.skuCount = (i.skuCount ?? 0) + 1;
        break;
      }
    }
  }

  deactivateMProduct(
    SearchProduct product, {
    String? remarks,
  }) {
    deactivateProperties(product, remarks: remarks);
    notifyListeners();
  }

  deactivateProperties(SearchProduct product, {String? remarks}) {
    product.myProduct?.remarks ??= RemarksModel.empty();
    product.myProduct?.deactivated = true;

    if (remarks != null) {
      product.myProduct?.remarks?.remarksStaff =
          RemarksWithUserModel.fromRemarks(remarks);
    }

    increDecreTabCount(false);
    SubCategory s = SubCategory.empty(product.category);
    _subsActivated ??= {};
    if (_subsActivated![s] == null) return;
    _subsActivated![s]!.remove(product);
    if (_subsActivated![s]!.isEmpty) _subsActivated?.remove(s);
    _subsDeactivated ??= {};
    SubCategory? deactivated;
    SubCategory? activated;
    if (_subsDeactivated![s] == null) {
      Iterable<SubCategory> subgroups = _subsActivated!.keys;
      for (var i in subgroups) {
        if (i.id == s.id) {
          activated = i;
          deactivated = i.copy();
          _subsDeactivated![deactivated] = [product];
          break;
        }
      }
    } else {
      _subsDeactivated![s]!.insert(0, product);
    }
    incrementSkuCount(s.id, false,
        activeSubCategory: activated, deactiveSubCategory: deactivated);
  }

  activateProperties(SearchProduct product, {String? remarks, String? refUrl}) {
    product.myProduct?.remarks ??= RemarksModel.empty();
    product.myProduct?.deactivated = false;
    if (remarks != null) {
      product.myProduct?.remarks?.remarksStaff =
          RemarksWithUserModel.fromRemarks(remarks);
    }
    product.myProduct?.remarks?.remarksStaffReferenceUrl = refUrl;
    increDecreTabCount(true);
    SubCategory s = SubCategory.empty(product.category);
    _subsDeactivated ??= {};
    if (_subsDeactivated![s] == null) return;
    _subsDeactivated![s]!.remove(product);
    if (_subsDeactivated![s]!.isEmpty) _subsDeactivated?.remove(s);
    _subsActivated ??= {};
    SubCategory? deactivated;
    SubCategory? activated;
    if (_subsActivated![s] == null) {
      Iterable<SubCategory> subgroups = _subsDeactivated!.keys;
      for (SubCategory i in subgroups) {
        if (i.id == s.id) {
          deactivated = i;
          activated = i.copy();
          _subsActivated![activated] = [product];
          break;
        }
      }
    } else {
      _subsActivated![s]?.removeWhere((element) => element.id == product.id);
      _subsActivated![s]!.insert(0, product);
    }
    incrementSkuCount(s.id, true,
        deactiveSubCategory: deactivated, activeSubCategory: activated);
  }

  activateMProduct(SearchProduct product, {String? remarks, String? refUrl}) {
    activateProperties(product, remarks: remarks, refUrl: refUrl);
    notifyListeners();
  }

  increDecreTabCount(bool activate) {
    if (tabCount != null) {
      if (activate) {
        tabCount = MapEntry(tabCount!.key + 1, tabCount!.value - 1);
      } else {
        tabCount = MapEntry(tabCount!.key - 1, tabCount!.value + 1);
      }
    }
  }

  incrementSkuCount(String id, bool activate,
      {SubCategory? activeSubCategory, SubCategory? deactiveSubCategory}) {
    if (activeSubCategory == null) {
      Iterable<SubCategory> subgroups = _subsActivated!.keys;
      for (var i in subgroups) {
        if (i.id == id) {
          activeSubCategory = i;
          break;
        }
      }
    }
    if (deactiveSubCategory == null) {
      Iterable<SubCategory> subgroups = _subsDeactivated!.keys;
      for (var i in subgroups) {
        if (i.id == id) {
          deactiveSubCategory = i;
          break;
        }
      }
    }
    if (activate) {
      activeSubCategory?.skuCount = activeSubCategory.skuCount! + 1;
      deactiveSubCategory?.skuCount = deactiveSubCategory.skuCount! - 1;
    } else {
      activeSubCategory?.skuCount = activeSubCategory.skuCount! - 1;
      deactiveSubCategory?.skuCount = deactiveSubCategory.skuCount! + 1;
    }
  }
}
