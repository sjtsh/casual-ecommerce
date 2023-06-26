import 'dart:async';
import 'dart:collection';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

final cartServiceProvider = ChangeNotifierProvider<CartService>((ref) {
  return CartService();
});
const String cartKey = "cart";

class CartService extends ChangeNotifier {
  CartService({bool temporary = false}) {
    temp = temporary;
    if (!temp) {
      loadCart();
    }
  }
  // Order _currentOrder = Order(items: []);
  final List<OrderItem> _cartItems = [];
  final List<OrderItem> _reorderItems = [];
  Timer timer = Timer(Duration.zero, () {});
  bool temp = false;
  List<OrderItem> get cartItems => UnmodifiableListView(_cartItems);
  List<OrderItem> get reOrderItems => UnmodifiableListView(_reorderItems);
  // Order get cart => _currentOrder;

  late final position = Property<Position?>(null, notifyListeners);

  updateProductAvailabilityInCart(Map<String, dynamic> data) async {
    if (_cartItems.isNotEmpty) {
      final id = data["_id"];
      _cartItems.asMap().entries.forEach((e) {
        if (e.value.product.id == id) {
          _cartItems[e.key].product.deactivated = data["deactivated"];
        }
      });

      await saveCart();
      // tryProductForAvail();
      // print(condi);
      notifyListeners();
    }
  }

  bool? tryProductForAvail(index) {
    int count = 0;
    for (var element in _cartItems) {
      if (element.product.deactivated == false) {
        count++;
      }
    }
    if (count == 0) {
      condi = ConditionsForNotAvail.allNotAvail;
    } else if (count == _cartItems.length) {
      condi = ConditionsForNotAvail.allAvail;
    } else {
      condi = ConditionsForNotAvail.someNotAvail;
    }
    // notifyListeners();
    if (_cartItems[index].product.deactivated) return true;
    return null;
    // print(" incart $condi");
  }

  ConditionsForNotAvail condi = ConditionsForNotAvail.allAvail;
  late final selectedDeliveryAddress =
      Property<AddressModel?>(null, notifyListeners);
  addItem(Product item, {bool inside = true}) {
    if (_cartItems
        .where((element) => element.product.id == item.id)
        .toList()
        .isEmpty) {
      var orderItem = OrderItem(itemCount: 1, product: item, total: item.price);
      _cartItems.add(orderItem);

      if (!temp) {
        saveCart();
      }
      if (inside) {
        // snack.success("Added to cart.");
      }
    } else {
      // var index = _cartItems.indexWhere(
      //   (element) => element.product == item,
      // );

      changeQuantityOfItem(item, inside: inside, add: true);
    }

    notifyListeners();
  }

  removeItem(int index) {
    _cartItems.removeAt(index);
    if (!temp) {
      saveCart();
    }
    notifyListeners();
  }

  List<SubCategory> subcategoriesCart = [];
  bool? checkItemsForAvail(
      {required List<SubCategory> subcategories,
      required List<OrderItem> items,
      required int index}) {
    subcategoriesCart.clear();
    subcategoriesCart.addAll(subcategories);
    int count = 0;

    if (subcategories.isNotEmpty) {
      for (var cartitem in _cartItems) {
        for (var subc in subcategories) {
          if (cartitem.product.category == subc.id) {
            count++;
          }
        }
      }
      if (count == _cartItems.length) {
        condi = ConditionsForNotAvail.allAvail;
      } else {
        condi = ConditionsForNotAvail.someNotAvail;
      }
    } else {
      condi = ConditionsForNotAvail.allNotAvail;
      return true;
    }

    // print(condi);
    return tryProductForAvail(index);

    // if (subcategories.indexWhere(
    //         (element) => element.id == items[index].product.category) ==
    //     -1) return true;

    // return null;
  }

  removeUnavailProducts() {
    List<OrderItem> items = [];

    for (var cartitem in _cartItems) {
      // print({"cart ${cartitem.product.category}"});
      for (var subc in subcategoriesCart) {
        // print({"subc ${subc.category}"});
        if (cartitem.product.category == subc.id) {
          items.add(cartitem);
        }
      }
    }
    // print(items.first.product.toJson());
    _cartItems.clear();
    _cartItems.addAll(items);

    notifyListeners();
  }

  Future<Order> createOrder(AddressModel address, String? remarks) async {
    var order = Order(
        items: _cartItems.toList(),
        total: total().toInt(),
        address: address,
        remarks: remarks);

    return order;
  }

  saveCart() {
    try {
      var cartJson = orderItemsToJson(_cartItems, save: true);

      storage.write(cartKey, cartJson);
    } catch (e, s) {
      print("$e $s");
    }
  }

  loadCart() {
    try {
      var cartJson = storage.read(cartKey);

      if (cartJson != null) {
        _cartItems.clear();
        _cartItems.addAll(orderItemsFromJson(cartJson));
        notifyListeners();
      }
    } catch (e, s) {
      print("$e $s");
    }
  }

  changeQuantityOfItem(Product product,
      {bool inside = false, bool add = false, bool cart = false}) {
    // var index = _cartItems.indexOf(item);
    var index =
        _cartItems.indexWhere((element) => element.product.id == product.id);

    var count = _cartItems[index].itemCount;

    if (count > 19 && add) {
      // snack.info("Max Limit is 20 items");
      timer.cancel();
    } else if (count == 1 && !add) {
      timer.cancel();
      // print("cart $cart");
      if (cart) {
        Future.delayed(const Duration(milliseconds: 20), () {
          return showDialog(
              context: CustomKeys.navigatorkey.currentContext!,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveLayout.margin(0.25)),
                  child: CustomDialog(
                      textSecond: 'remove this item from the cart?',
                      elevatedButtonText: 'Confirm',
                      onPressedElevated: () async {
                        removeItem(index);
                        snack.success("item removed from the cart.");
                      }),
                );
              });
        });
      } else {
        removeItem(index);
        snack.success("item removed from the cart.");
      }
    } else {
      if (add) {
        count++;
        // if (inside) {
        //    snack.success("Quantity increased.");
        // }
      } else {
        if (count == 0) return;
        count--;
      }

      _cartItems[index]
        ..itemCount = count
        ..total = product.price * count;
    }
    if (!temp) {
      saveCart();
    }
    notifyListeners();
  }

  double total({List<OrderItem>? items}) {
    double total = 0.0;

    for (var element in items ?? _cartItems) {
      total += element.product.price * element.itemCount;
    }

    return total + 99;
  }

  clearCart({bool showMsg = true}) {
    _cartItems.clear();
    position.value = null;
    if (!temp) {
      storage.remove(cartKey);
    }
    if (showMsg) {
      // snack.success("Cart emptied.");
    }
    notifyListeners();
  }

  addItemToReOrder(Product item, int quantity) {
    if (_reorderItems
        .where((element) => element.product == item)
        .toList()
        .isEmpty) {
      var orderItem =
          OrderItem(itemCount: quantity, product: item, total: item.price);
      _reorderItems.add(orderItem);
    }
    // notifyListeners();
  }

  int checkItemIsInCart(Product product) {
    for (var element in cartItems) {
      if (element.product.id == product.id) {
        return element.itemCount;
      }
    }
    return 0;
  }

  reorderItems() {}
}
