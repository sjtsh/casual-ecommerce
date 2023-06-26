import 'dart:collection';

import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/models/ratingModel.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/models/staffmodel.dart';

final orderHistoryServiceProvider =
    ChangeNotifierProvider<OrderHistoryService>((ref) {
  return OrderHistoryService._();
});

class OrderHistoryService extends ChangeNotifier {
  OrderHistoryService._() {
    // fetchOrders(clear: true);
  }
  final List<Order> _orders = [];
  final List<Order> _ordersToday = [];
  final RatingModelWithStat _staffRating =
      RatingModelWithStat(ratings: [], starCounts: []);
  List<Order> get orders => UnmodifiableListView(_orders);
  List<Order> get ordersToday => UnmodifiableListView(_ordersToday);
  RatingModelWithStat get staffRating => _staffRating;
  final remarksController = TextEditingController();
  // late Timer timer;
  Order? selectedOrder;
  int countDownTime = 100000;
  bool _cancelOrderPage = false;
  bool get cancelOrderPage => _cancelOrderPage;
  set cancelOrderPage(bool value) {
    _cancelOrderPage = value;
    notifyListeners();
  }

  //OrderPageTab Section
  final PageController pageController = PageController();
  final List<String> tabs = ["Today", "History"];

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  final List<int> activeFilters = [];

  //Active Filter

  addOrRemoveFilter(int index) {
    if (activeFilters.isEmpty) {
      // print(index);

      activeFilters.add(index);
    } else if (activeFilters.contains(index)) {
      activeFilters.remove(index);
    } else {
      activeFilters.add(index);
    }
    print(activeFilters);
    notifyListeners();
  }

  allFilter() {
    if (activeFilters.isEmpty) {
      activeFilters.clear();
    } else {
      activeFilters.addAll(Status.values.map((e) => e.index).toList());
    }
    notifyListeners();
  }

  //Active Filter End

  int currentPage = 1, currentHistoryPage = 1;
  bool isLoadingMoreData = false;
//

  loadMoreData({bool today = true}) async {
    if (!isLoadingMoreData) {
      isLoadingMoreData = true;
      notifyListeners();
      today ? currentPage++ : currentHistoryPage++;

      await fetchOrders(today: today);
      if (!Api.production) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      isLoadingMoreData = false;
      notifyListeners();
    }
  }

  Future<bool> punchOrder(Order order, {String? oldOrder}) async {
    // print(jsonEncode(order.toJson()));
    try {
      var response = await Api.post(
          endpoint: "user/order",
          body: jsonEncode(
            order.toJson(order: oldOrder),
          ),
          notify: true,
          successCode: 200);
      // log(" add a${response!.statusCode}");
      if (response != null) {
        var updatedOrder = Order.fromJson(jsonDecode(response.body));
        // print(updatedOrder.id);
        order.id = updatedOrder.id;
        order.createdAt = updatedOrder.createdAt;
        order.updatedAt = updatedOrder.updatedAt;
        order.status = updatedOrder.status;
        order.orderId = updatedOrder.orderId;
        _ordersToday.insert(0, order);
        // if (oldOrder != null) {
        //   _ordersToday.removeWhere((element) => element.id == oldOrder);
        //   _orders.removeWhere((element) => element.id == oldOrder);
        // }
        // snack.success("Order placed!");
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  autoOrder() async {
    var products = CustomKeys.ref.watch(productCategoryServiceProvider).product;
    var address =
        CustomKeys.ref.watch(userChangeProvider).loggedInUser.value!.address;
    if (address.isEmpty) {
      throw "Add address first";
    }
    var order = Order(
        items: [
          OrderItem(
            itemCount: 1,
            product: products.first,

            //   Product(
            //       id: "632c0fc0b557402f686bb0b7",
            //       name: "Hilife SuperFine Chiura 1KG (1KGX14)POUCH MRP 110",
            //       price: 125,
            //       weight: 250,
            //       image:
            //           "https://hilifefoods.com.np/images/Mockup/Hilife%20Chiura/Mock%20-01.png",
            //       category: "6352363d1b664fe79552d0a7"),
            //   total: 125,
          ),
          if (products.length > 1)
            OrderItem(
              itemCount: 1,
              product: products.last,

              //   Product(
              //       id: "632c0fc0b557402f686bb0b7",
              //       name: "Hilife SuperFine Chiura 1KG (1KGX14)POUCH MRP 110",
              //       price: 125,
              //       weight: 250,
              //       image:
              //           "https://hilifefoods.com.np/images/Mockup/Hilife%20Chiura/Mock%20-01.png",
              //       category: "6352363d1b664fe79552d0a7"),
              //   total: 125,
            )
        ],
        total: products.first.price +
            (products.length > 1 ? products.last.price : 0),
        address: address.first);
    // print(jsonEncode(order.toJson()));
    for (int i = 0; i < 1; i++) {
      print(i);
      await Utilities.futureDelayed(1000, () async {
        try {
          var response = await Api.post(
              endpoint: "user/order",
              body: jsonEncode(
                order.toJson(),
              ),
              successCode: 200);
          // print(response!.body);
          if (response != null) {
            var updatedOrder = Order.fromJson(jsonDecode(response.body));
            // print("adada  ada ${updatedOrder.id}");
            order.id = updatedOrder.id;
            order.createdAt = updatedOrder.createdAt;
            order.updatedAt = updatedOrder.updatedAt;
            order.status = updatedOrder.status;
            order.orderId = updatedOrder.orderId;
            _ordersToday.insert(0, order);
            // print(_ordersToday.first.id);
            // snack.success("Order placed!");
            notifyListeners();
          } else {
            // // print(response!.body);
            // var msg = jsonDecode(response!.body);

            // throw msg["message"];
          }
        } catch (e, s) {
          print("$e $s");
          rethrow;
        }
      });
    }
    // var response = await Api.post(
    //     endpoint: "user/order",
    //     body: jsonEncode(
    //       order.toJson(),
    //     ),
    //     successCode: 200);
    // log(response!.body);
    // if (response != null) {
    //   var updatedOrder = Order.fromJson(jsonDecode(response.body));
    //   // print("adada  ada ${updatedOrder.id}");
    //   order.id = updatedOrder.id;
    //   order.createdAt = updatedOrder.createdAt;
    //   order.updatedAt = updatedOrder.updatedAt;
    //   order.status = updatedOrder.status;
    //   order.orderId = updatedOrder.orderId;
    //   _ordersToday.insert(0, order);
    //   // print(_ordersToday.first.id);
    //   // snack.success("Order placed!");
    //   notifyListeners();
    // } else {
    //   // print(response!.body);
    //   var msg = jsonDecode(response!.body);

    //   throw msg["message"];
    // }
  }

  Future<bool> deleteAllOrderData() async {
    var response = await Api.delete(endpoint: "bulkupload");
    if (response != null) {
      _orders.clear();
      _ordersToday.clear();
      notifyListeners();
      return true;
    }
    return false;
  }

  reorder(List<OrderItem> items) async {
    final cartProvider = ChangeNotifierProvider<CartService>((ref) {
      return CartService(temporary: true);
    });

    var cartService = CustomKeys.ref.read(cartProvider);

    for (var element in items) {
      for (int i = 0; i < element.itemCount; i++) {
        cartService.addItem(element.product);
      }
    }
    if (ResponsiveLayout.isMobile) {
      Utilities.pushPage(
          Cart(
            newScreen: true,
            notifier: cartProvider,
          ),
          10);
    } else {
      ResponsiveLayout.setWidget(
        Cart(
          newScreen: true,
          notifier: cartProvider,
        ),
      );
      CustomKeys.webScaffoldKey.currentState!.openEndDrawer();
    }
  }

  Future<bool> cancelOrder(String id, {String? requestId}) async {
    try {
      var response = await Api.put(
          endpoint: "user/${requestId == null ? "order" : "feedback"}/cancel",
          body: jsonEncode(
              {requestId == null ? "order_id" : "request_id": requestId ?? id}),
          successCode: 200);

      if (response != null) {
        var data = jsonDecode(response.body);

        updateOrderStatus(data["status"], orderId: id, requestId: requestId);
        // snack.success("Order placed!");
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  updateOrderOnConfirmation(FeedbackModel feedback) {
    // var orderToUpdate =
    //     _orders.firstWhere((element) => element.id == feedback.order);
    // orderToUpdate.status = feedback.status;
    // orderToUpdate.feedback = feedback;
    // snack.floatingNotification("Your order has been updated", () {
    //   Navigator.push(CustomKeys.context, MaterialPageRoute(builder: (context) {
    //     return OrderDetail();
    //   }));
    // });
    // notifyListeners();
  }
  int statusOrder = 0;
  checkOrderStatus() {
    statusOrder = 0;
    for (var element in _ordersToday) {
      if (element.status >= 2 && element.status != 5) {
        statusOrder++;
      }
    }
    notifyListeners();
  }

  updateOrderStatus(int status,
      {required String orderId,
      String? requestId,
      int? countDownTimeinMs,
      bool socket = false,
      int? otp,
      bool? fulfilled}) {
    // if (countDownTimeinMs != null) {
    //   countDownTime = countDownTimeinMs;
    // }
    // print(otp);
    // print(status);

    if (_cancelOrderPage) {
      if (status < 0 || status == 1) {
        CustomDialogBox.alertMessage(() {
          Navigator.pop(CustomKeys.navigatorkey.currentState!.context);
          Navigator.pop(CustomKeys.navigatorkey.currentState!.context);
        },
            title: "",
            message:
                "This order has already been cancelled.\n Got to order detail.");
      }
    }

    var orderToUpdate = _ordersToday.firstWhere(
      (element) => element.id == orderId,
      orElse: () {
        return _orders.firstWhere((element) => element.id == orderId);
      },
    );

    if (requestId != null) {
      try {
        var requestedShop = orderToUpdate.requestedShops
            .firstWhere((element) => element.id == requestId);
        requestedShop.status = status;
        if (otp != null && selectedOrder != null) {
          requestedShop.verficationOTP = otp;
        }
      } catch (e) {
        // print("$e $s");
      }
    } else {
      orderToUpdate.status = status;
      if (fulfilled != null) {
        orderToUpdate.fulfilled = fulfilled;
      }
    }
    if (selectedOrder != null) {
      if (status == 3 && requestId == null && selectedOrder!.id == orderId) {
        fetchOneOrder(order: selectedOrder);
      }
    }

    if (status != Status.pending.index &&
        status != Status.processing.index &&
        requestId == null) {
      CustomLocalNotification.orderUpdate(getStatusDetail(
          // requestId != null
          // ? getStatusForFeedback(status)
          // :
          getStatus(status)), orderId);
    }
    checkOrderStatus();
    notifyListeners();
  }

  Order? findOrderById(String id) {
    Order? order;
    for (var element in ordersToday) {
      if (element.id == id) order = element;
    }
    if (order == null) {
      for (var element in orders) {
        if (element.id == id) order = element;
      }
    }
    return order;
  }

  fetchOrders({bool clear = false, bool today = true}) async {
    if (clear) {
      currentPage = 1;
      currentHistoryPage = 1;
    }

    try {
      var response = await Api.get(
          endpoint: "user/order?tpage=$currentPage&hpage=$currentHistoryPage",
          successCode: 200);

      if (response != null) {
        if (clear) {
          _orders.clear();
          _ordersToday.clear();
        }
        var orderHolder = orderHolderModelFromJson(response.body);
        // print(orderHolder.today.length + orderHolder.history.length);

        // var today = orderFromJson(response.body);

        var orderToday = orderHolder.today.toList();
        var orderHistory = orderHolder.history.toList();

        if (orderToday.isEmpty && currentPage > 1) currentPage--;
        if (orderHistory.isEmpty && currentHistoryPage > 1) {
          currentHistoryPage--;
        }

        for (var element in orderToday) {
          if (_ordersToday.indexWhere((e) => element.id == e.id) == -1) {
            _ordersToday.add(element);
          }
        }

        for (var element in orderHistory) {
          if (_orders.indexWhere((e) => element.id == e.id) == -1) {
            _orders.add(element);
          }
        }

        // for (var element in orders) {
        //   if (element.createdAt.toString().substring(0, 10) ==
        //       DateTime.now().toString().substring(0, 10)) {
        //     if (!_ordersToday.contains(element)) _ordersToday.add(element);
        //   } else {
        //     if (!_orders.contains(element)) _orders.add(element);
        //   }
        // }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  fetchOneOrder({Order? order, String? id}) async {
    try {
      var response = await Api.get(
        endpoint: "user/order/${id ?? order!.id}",
      );

      // client.get(Uri.parse("${Api.baseUrl}order/${order.id}"),
      //     headers: header());
      // log(response!.body);
      if (response != null) {
        // print(response.body);
        if (order != null) {
          // inspect(response.body);
          int index = _ordersToday.indexOf(order);
          if (index == -1) {
            index = _orders.indexOf(order);
            _orders[index] = Order.fromJson(jsonDecode(response.body));
            selectedOrder = _orders[index];
          } else {
            _ordersToday[index] = Order.fromJson(jsonDecode(response.body));
            selectedOrder = _ordersToday[index];
          }
        } else {
          selectedOrder = Order.fromJson(jsonDecode(response.body));
        }

        // print(index);

        // print(selectedOrder.feedback!.toJson());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rateShop(
      {String? review, required double rating, required String id}) async {
    Map<String, dynamic> data;

    if (review == "") {
      data = {"rate": rating, "requestedshop": id, "isShop": false};
    } else {
      data = {
        "review": review,
        "rate": rating,
        "requestedshop": id,
        "isShop": false
      };
    }
    // print(data);

    try {
      var response = await Api.put(
        endpoint: "user/feedback/review/",
        body: jsonEncode(data),
      );

      if (response != null) {
        // log(response.body);
        Map<String, dynamic> resp = jsonDecode(response.body);

        int index = selectedOrder!.requestedShops
            .indexWhere((element) => element.shop.id == resp["_id"]);
        final thisUser =
            CustomKeys.ref.read(userChangeProvider).loggedInUser.value!;

        if (index != -1) {
          RatingModel customRating = RatingModel(
              id: id,
              user: thisUser,
              ratingByUser: rating.toInt(),
              reviewByUser: review,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now());

          selectedOrder!.requestedShops[index].shop.avgRating =
              double.parse(resp["avgRating"].toString());
          selectedOrder!.requestedShops[index].shop.rateCount =
              resp["raterCount"];
          selectedOrder!.requestedShops[index].feedback.rating = customRating;

          // selectedOrder!.requestedShops[index].feedback.rating!.user!.id =
          //     thisUser.id;
          // selectedOrder!.requestedShops[index].feedback.rating!.user!.name =
          //     thisUser.name;
          // print(selectedOrder!.requestedShops[index].feedback.rating!);
        }

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  bool gettingfirstTimeReview = true;
  // Future<RatingModelWithStat>
  getReviews({
    bool clear = false,
    required String staffId,
  }) async {
    if (clear) {
      skip = 0;
      _staffRating.ratings.clear();
      _staffRating.starCounts.clear();
    }
    try {
      var response = await Api.get(
        endpoint: "user/feedback/review/$staffId?skip=$skip",
      );

      if (response != null) {
        gettingfirstTimeReview = false;
        RatingModelWithStat temp =
            RatingModelWithStat.fromJson(json.decode(response.body));

        _staffRating.ratings.addAll(temp.ratings);
        if (skip == 0) {
          _staffRating.starCounts.addAll(temp.starCounts);
        } else {
          _staffRating.starCounts.clear();
          _staffRating.starCounts.addAll(temp.starCounts);
        }

        // return ;
      }
      loadingMoreShopsReview = false;
      notifyListeners();
    } catch (e, s) {
      print("$e $s");
      rethrow;
    }
  }

  bool loadingMoreShopsReview = false;
  int skip = 10;

  clear() {
    _staffRating.ratings.clear();
    _staffRating.starCounts.clear();

    gettingfirstTimeReview = true;
  }

  loadMoreshopsReview({required Shop shop, required Staff staff}) async {
    if (!loadingMoreShopsReview) {
      loadingMoreShopsReview = true;
      notifyListeners();
      skip += 10;

      await getReviews(staffId: staff.id);
      if (!Api.production) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      loadingMoreShopsReview = false;
      notifyListeners();
    }
  }
}
