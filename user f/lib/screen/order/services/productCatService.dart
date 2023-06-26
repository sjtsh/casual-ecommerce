import 'dart:collection';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/bannerModel.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';

import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/models/subCategoyProductList.dart';
import 'package:ezdeliver/screen/others/tabledataholder.dart';

final productCategoryServiceProvider =
    ChangeNotifierProvider<ProductCategoryService>((ref) {
  return ProductCategoryService._();
});

class ProductCategoryService extends ChangeNotifier {
  ProductCategoryService._() {
    // fetchCategories();
    // fetchAllProductBySubCategory();
  }

  List<Category>? _categories;
  final List<SubCategory> _subCategories = [];
  final List<SubCategory> subCategoryForDropDown = [];
  List<SubCategoyProduct>? _productFromSubCategories;

  final List<Product> _product = [];
  final List<Product> _productNewFetch = [];
  final List<Product> _trendingProducts = [];
  final List<CustomMenuItem> dropDownSubCategoryItems = [];
  final List<CustomMenuItem> dropDownCategoryItems = [];

  List<Product>? _selectedProducts;

  List<BannerModel>? _homeBanners;
  List<BannerModel>? get homeBanners =>
      _homeBanners != null ? UnmodifiableListView(_homeBanners!) : null;
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  List<Category>? get category =>
      _categories != null ? UnmodifiableListView(_categories!) : null;
  List<Product>? get trendingProducts =>
      _categories != null ? UnmodifiableListView(_trendingProducts) : null;
  List<SubCategory> get subCategory => UnmodifiableListView(_subCategories);
  List<SubCategoyProduct>? get productFromSubCategories =>
      _productFromSubCategories != null
          ? UnmodifiableListView(_productFromSubCategories!)
          : null;
  List<Product> get product => UnmodifiableListView(_product);
  List<Product>? get selectedProducts => _selectedProducts != null
      ? UnmodifiableListView(_selectedProducts!)
      : null;

  late final error = Property<String?>(null, notifyListeners);

  set productFromSubCategories(value) {
    productFromSubCategories = value;
  }

  clearAll() {
    if (_categories != null) {
      _categories = null;
    }
    _subCategories.clear();
    _product.clear();
    _selectedProducts = null;
    _trendingProducts.clear();
    notifyListeners();
  }

  addCategorytoDropDown() {
    if (_categories != null) {
      dropDownCategoryItems.clear();
      List<CustomMenuItem> items = _categories!
          .asMap()
          .entries
          .map((e) => CustomMenuItem(label: e.value.name, value: e.value.id))
          .toList();
      dropDownCategoryItems.addAll(items);
      notifyListeners();
    }
  }

  addSubCategorytoDropDown() {
    dropDownSubCategoryItems.clear();
    List<CustomMenuItem> items = subCategoryForDropDown
        .asMap()
        .entries
        .map((e) => CustomMenuItem(label: e.value.name, value: e.value.id))
        .toList();
    dropDownSubCategoryItems.addAll(items);
    notifyListeners();
  }

  fetchHomeBanners() async {
    var response = await Api.get(
        endpoint: 'user/banner/${BannerType.landing.name}', successCode: 200);

    if (response != null) {
      var json = jsonDecode(response.body);

      _homeBanners ??= [];
      _homeBanners!.clear();
      _homeBanners!.addAll(List.from(json.map((e) => BannerModel.fromJson(e))));
      notifyListeners();
    }
  }

  // getSubCategoriesForDrop(String query, {bool forCreateNew = false}) async {
  //   if (subCategoryForDropDown.isNotEmpty && forCreateNew) return null;
  //   try {
  //     var response = await Api.get(
  //         endpoint:
  //             "dashboard/product/${forCreateNew ? "master/" : ""}subcategory?$query",
  //         throwError: true);

  //     if (response != null) {
  //       // print(response.body);
  //       var data = TableDataHolder<SubCategory>.fromRawJson(
  //           response.body,
  //           (data) => SubCategory.fromJson(
  //                 data,
  //               ));
  //       if (forCreateNew) {
  //         subCategoryForDropDown.clear();
  //         subCategoryForDropDown.addAll(data.data);
  //       }
  //       // shops.clear();
  //       // shops.addAll(shop.getRange(0, 20).toList());
  //     }
  //     return null;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  updateBanner(Map<String, dynamic> data) {
    String bannerId = data["_id"];
    String bannerType = data["group"];
    if (bannerType == BannerType.subgroup.name) {
      String? foreign = data["foreign"];
      var subCategoryIndex =
          _subCategories.indexWhere((element) => element.id == foreign);
      if (subCategoryIndex != -1) {
        var bannerIndex = _subCategories[subCategoryIndex]
            .banners
            .indexWhere((element) => element.id == bannerId);
        if (bannerIndex == -1) {
          _subCategories[subCategoryIndex]
              .banners
              .add(BannerModel.fromJson(data));
        } else {
          if (data["deactivated"] != null) {
            if (data["deactivated"]) {
              _subCategories[subCategoryIndex].banners.removeAt(bannerIndex);
            }
          } else {
            var banner = _subCategories[subCategoryIndex]
                .banners[bannerIndex]
                .copyWithFromJson(data);
            _subCategories[subCategoryIndex].banners[bannerIndex] = banner;
          }
        }
      }
    } else if (bannerType == BannerType.landing.name) {
      _homeBanners ??= [];

      var bannerIndex =
          _homeBanners!.indexWhere((element) => element.id == bannerId);
      if (bannerIndex != -1) {
        if (data["deactivated"] != null) {
          if (data["deactivated"]) {
            _homeBanners!.removeAt(bannerIndex);
          }
        } else {
          var banner = _homeBanners![bannerIndex].copyWithFromJson(data);
          _homeBanners![bannerIndex] = banner;
        }
      } else {
        _homeBanners!.add(BannerModel.fromJson(data));
      }
    }

    notifyListeners();
  }

  updateProduct(Map<String, dynamic> data) {
    //check in products
    final id = data["_id"];
    var productIndex = _product.indexWhere((element) => element.id == id);
    if (productIndex != -1) {
      _product[productIndex].deactivated = data["deactivated"];
    }

    //check for trending
    var productInTrendingIndex =
        _trendingProducts.indexWhere((element) => element.id == id);
    if (productInTrendingIndex != -1) {
      _trendingProducts[productInTrendingIndex].deactivated =
          data["deactivated"];
    }

    //check for product sub group
    if (_productFromSubCategories != null) {
      _productFromSubCategories!.asMap().entries.forEach((e) {
        var productIndex =
            e.value.products.indexWhere((element) => element.id == id);
        if (productIndex != -1) {
          _productFromSubCategories![e.key].products[productIndex].deactivated =
              data["deactivated"];
        }
      });

      // });
    }
    //check product in cart
    CustomKeys.ref
        .read(cartServiceProvider)
        .updateProductAvailabilityInCart(data);

    //check product in favourites
    CustomKeys.ref.read(userChangeProvider).checkProductAvailability(data);

    notifyListeners();
  }

  selectSubCategory(SubCategory subCategoryTemp, {bool clear = true}) async {
    if (selectedSubCategory != null) {
      if (selectedSubCategory!.category != subCategoryTemp.category) {
        _product.clear();

        notifyListeners();
      }
    }

    selectedSubCategory = subCategoryTemp;

    var products = _product
        .where((element) => element.category == subCategoryTemp.id)
        .toList();
    if (clear) {
      _selectedProducts = null;
      if (products.isEmpty) {
        skipOfProduct = 0;
        await fetchProductByCategory(subCategoryTemp.id, clear: clear);
        var productsLoad = _product.where((element) {
          return element.category == subCategoryTemp.id;
        }).toList();

        if (productsLoad.isNotEmpty) {
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 1000), () {
            _selectedProducts ??= [];
            _selectedProducts!.addAll(productsLoad.toList());
            // print("products : ${_selectedProducts.length}");
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
      } else {
        _selectedProducts ??= [];
        _selectedProducts!.addAll(products.toList());
        checkSkip(_selectedProducts!.length);
        // print("products : ${_selectedProducts.length}");
        notifyListeners();
      }
    } else {
      await fetchProductByCategory(subCategoryTemp.id, clear: clear);
      var productsLoad = _productNewFetch.where((element) {
        return element.category == subCategoryTemp.id;
      }).toList();
      Future.delayed(const Duration(milliseconds: 20), () {
        _selectedProducts!.addAll(productsLoad.toList());
        // print("products : ${_selectedProducts!.length}");
        notifyListeners();
      });
    }
  }

  Future<bool> sendProductSuggestion(String suggestion) async {
    var response = await Api.post(
        endpoint: 'suggestion/product',
        body: jsonEncode({"suggestion": suggestion}),
        successCode: 201);
    if (response != null) {
      return true;
    } else {
      return false;
    }
  }

  productToFavourite(Product product, BuildContext context,
      {bool? favourite}) async {
    final fav = favourite ?? product.favourite;
    if (!fav) {
      if (await CustomKeys.ref
          .read(userChangeProvider)
          .addToFavourite(product: product)) {
        product.favourite = !fav;
        notifyListeners();
      }
    } else {
      Utilities.showCustomDialog(
          context: context,
          onpressedElevated: () async {
            if (await CustomKeys.ref
                .read(userChangeProvider)
                .removeFromFavourite(product: product)) {
              product.favourite = !fav;
              await checkAllProductsForFavourite();
              await checkAllProductsForFavourite(
                  checkProduct: _trendingProducts);
              notifyListeners();
            }
          },
          textSecond: 'remove this item from favourite?');
      // await showDialog(
      //     context: context,
      //     builder: (context) {
      //       return CustomDialog(
      //           // title: "Favourite",
      //           textSecond: 'remove this item from favourite?',
      //           elevatedButtonText: 'Confirm',
      //           onPressedElevated: () async {
      //             if (await CustomKeys.ref
      //                 .read(userChangeProvider)
      //                 .removeFromFavourite(product: product)) {
      //               product.favourite = !fav;
      //               await checkAllProductsForFavourite();
      //               await checkAllProductsForFavourite(
      //                   checkProduct: _trendingProducts);
      //               notifyListeners();
      //             }
      //           });
      //     });
    }
  }

  categoryToFavourite(Category category, BuildContext context) async {
    if (!category.favourite) {
      if (await CustomKeys.ref
          .read(userChangeProvider)
          .addToFavourite(category: category)) {
        category.favourite = !category.favourite;

        notifyListeners();
      }
    } else {
      Utilities.showCustomDialog(
          context: context,
          onpressedElevated: () async {
            if (await CustomKeys.ref
                .read(userChangeProvider)
                .removeFromFavourite(category: category)) {
              category.favourite = !category.favourite;
              await checkAllCategoriesForFavourite();
              notifyListeners();
            }
          },
          textSecond: 'remove this item from favourite?');
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return CustomDialog(
      //           textSecond: 'remove this item from favourite?',
      //           elevatedButtonText: 'Confirm',
      //           onPressedElevated: () async {
      //             if (await CustomKeys.ref
      //                 .read(userChangeProvider)
      //                 .removeFromFavourite(category: category)) {
      //               category.favourite = !category.favourite;
      //               await checkAllCategoriesForFavourite();
      //               notifyListeners();
      //             }
      //           });
      //     });
    }
  }

  List<SubCategory> getSubCategoryFromCategory(Category category) {
    List<SubCategory> subcategories = subCategory
        .where((element) => element.category == category.id)
        .toList();

    return subcategories;
  }

  fetchSubCategories(String categorId) async {
    try {
      var response = await Api.get(
        endpoint: "subcategory/$categorId",
      );

      // client.get(Uri.parse("${Api.baseUrl}subcategory/$categorId"),
      //     headers: header());

      if (response != null) {
        _subCategories.clear();
        _subCategories.addAll(subCategoryFromJson(response.body));
        if (_subCategories.isNotEmpty) {
          error.value = null;
          selectSubCategory(_subCategories.first);
        } else {
          error.value = "This Category doesn't have any products";
        }
      } else {
        // print(response!.body);
        // throw 'Error';
      }
    } catch (e) {
      rethrow;
    }
  }

  fetchAllSubCategoriesWithProducts({bool clear = true}) async {
    // print("object");
    var location = CustomKeys.ref.read(locationServiceProvider).location;
    if (location == null) return;
    if (clear) {
      skip = 0;
      _productFromSubCategories = null;
      notifyListeners();
    }
    var url =
        "user/product/subcategory?lat=${location.latitude}&lon=${location.longitude}&skip=$skip&limit=12";
    // print(url);
    try {
      var response = await Api.get(endpoint: url);
      if (response != null) {
        // print(response.body);
        var data = subCategoyProductListFromJson(response.body);
        // print(" skip $skip");
        // print("from server ${data.length}");
        if (skip == 0) {
          data.shuffle();
          _productFromSubCategories = [];
          _productFromSubCategories!.clear();
          _productFromSubCategories!.addAll(data);
        } else {
          // _productFromSubCategories!.addAll(data);
          for (var element in data) {
            // print(element.toJson());
            var i = _productFromSubCategories!
                .indexWhere((e) => e.id == element.id);
            if (i == -1) {
              _productFromSubCategories!.add(element);
            } else {
              // print(element.toJson());
              // print(_productFromSubCategories![i].toJson());
            }
          }
        }
        // print(" otttal ${_productFromSubCategories!.length}");
        // print(_productFromSubCategories!.length);
        // _productFromSubCategories!.addAll(data);
        loadingMoreSubCategories = false;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future fetchCategories() async {
    var location = CustomKeys.ref.read(locationServiceProvider).location;
    if (location == null) return;
    // clearAll();
    try {
      var response = await Api.get(
        endpoint:
            "user/category?lat=${location.latitude}&lon=${location.longitude}",
      );
      // print(response!.statusCode);
      // print(response!.body);

      // client.get(Uri.parse("${Api.baseUrl}category"), headers: header());
      if (response != null) {
        var data = categoryFromJson(response.body);

//Clear cart
        // for (var element in data) {
        //   if (_categories?.indexWhere((e) => e.id == element.id) == -1) {
        //     CustomKeys.ref.read(cartServiceProvider).clearCart();
        //     break;
        //   }
        // }

        clearAll();
        _categories = [];
        _categories!.addAll(data);
        _subCategories.clear();
        for (var element in data) {
          _subCategories.addAll(element.subcategories as Iterable<SubCategory>);
        }

        // for (var element in data.trending) {
        //   _trendingProducts.add(element.product);
        // }
        // fetchTrendingProducts();
        await checkAllCategoriesForFavourite();
        if (_subCategories.isNotEmpty) {
          await fetchProductByCategory(_subCategories.first.id);
        }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  clear() {
    error.value = null;

    _selectedProducts = null;
    // _subCategories.clear();
    notifyListeners();
  }

  fetchProductByCategory(String id, {bool clear = true}) async {
    var location = CustomKeys.ref.read(locationServiceProvider).location;
    if (location == null) return;

    // print(id);
    if (clear) {
      skipOfProduct = 0;
    }
    // print("skip $skipOfProduct");
    try {
      var response = await Api.get(
          endpoint:
              "user/product/$id?lat=${location.latitude}&lon=${location.longitude}&skip=$skipOfProduct&limit=10");

      // client.get(Uri.parse("${Api.baseUrl}product/$id"), headers: header());

      if (response != null) {
        var data = productFromJson(response.body);
        // print(" lenght of pro ${data.length}");
        _productNewFetch.clear();
        if (data.isNotEmpty) {
          if (skipOfProduct == 0) {
            _product.addAll(data);
          } else {
            for (var element in data) {
              if (!_product.contains(element)) {
                _product.add(element);
              }
            }
            _productNewFetch.addAll(data);
          }
          await checkAllProductsForFavourite();
        }

        // _product.clear();
      }
    } catch (e) {
      rethrow;
    }
  }

  fetchTrendingProducts() async {
    var location = CustomKeys.ref.read(locationServiceProvider).location;
    if (location == null) return;

    if (_subCategories.isEmpty) return;
    List<String> id = [];
    for (var element in _subCategories) {
      id.add(element.id.toString());
    }

    var response = await Api.get(
        endpoint:
            'user/product/trending${id.isNotEmpty ? "?subCat=${id.join(",")}" : ""}&lat=${location.latitude}&lon=${location.longitude}');
    if (response != null) {
      // log(response.body);
      var products = trendingProductModelFromJson(response.body);

      for (var element in products) {
        _trendingProducts.add(element.product);
      }
      checkAllProductsForFavourite(checkProduct: _trendingProducts);
      notifyListeners();
    }
  }

  checkAllProductsForFavourite({List<Product>? checkProduct}) async {
    await Future.forEach(checkProduct ?? _product, (element) {
      element.favourite = CustomKeys.ref
          .read(userChangeProvider)
          .checkProductFavourite(element.id);
    });
  }

  checkAllCategoriesForFavourite() async {
    if (_categories != null) {
      await Future.forEach(_categories!, (element) {
        element.favourite = CustomKeys.ref
            .read(userChangeProvider)
            .checkCategoryFavourite(element.id);
      });
    }
  }

  bool loadingMoreSubCategories = false;
  int skip = 0;
  loadingMoreSubCategoy() async {
    if (!loadingMoreSubCategories) {
      loadingMoreSubCategories = true;
      notifyListeners();
      skip += 10;

      await fetchAllSubCategoriesWithProducts(clear: false);
      if (!Api.production) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      loadingMoreSubCategories = false;
      notifyListeners();
    }
  }

  bool loadingMoreSubCategoriesProducts = false;
  int skipOfProduct = 0;
  loadingMoreSubCategoyProDucts() async {
    if (!loadingMoreSubCategoriesProducts) {
      loadingMoreSubCategoriesProducts = true;
      notifyListeners();
      skipOfProduct += 10;
      await selectSubCategory(selectedSubCategory!, clear: false);
      // await fetchProductByCategory(selectedSubCategory!.id, clear: false);
      if (!Api.production) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      loadingMoreSubCategoriesProducts = false;
      notifyListeners();
    }
  }

  checkSkip(length) {
    // print(((length / 10) - 1) * 10);
    // print("l $length");
    // print((((length / 10).toInt() - 1) * 10));
    if (length % 10 == 0) {
      skipOfProduct = (((length / 10).toInt() - 1) * 10);
    } else {
      skipOfProduct = ((length / 10).toInt() * 10);
    }
    // print(skipOfProduct);
  }
}
