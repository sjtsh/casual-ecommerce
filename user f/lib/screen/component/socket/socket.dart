import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/users/model/user.dart';
import 'package:socket_io_client/socket_io_client.dart';

// final customSocket = CustomSocket._();
final customSocketProvider = StateProvider<CustomSocket>((ref) {
  return CustomSocket._();
});

class CustomSocket {
  CustomSocket._();
  static Socket? socket;
  static final socketStatusProvider = StateProvider<bool>((ref) {
    return false;
  });

  Socket? setSocket({User? user}) {
    user ??= CustomKeys.ref.read(userChangeProvider).loggedInUser.value;

    if (user == null) return null;

    return io(
        Api.baseUrlSocket,
        OptionBuilder()
            // .setPath("/")
            .setTransports(['websocket'])
            // .disableAutoConnect()
            .setAuth({"x-access-token": user.accessToken}).build());
  }

  connect() async {
    try {
      final user = CustomKeys.ref.read(userChangeProvider).loggedInUser.value;

      if (user != null && socket == null) {
        socket = setSocket(user: user);

        if (!socket!.connected) {
          socket!.connect();
          // print("in here");
          socket!.onConnect((data) async {
            print("Connected");

            setStatus(true);

            if (CustomKeys.ref.read(productCategoryServiceProvider).category ==
                null) {
              await CustomKeys.ref
                  .read(productCategoryServiceProvider)
                  .fetchCategories();
              await CustomKeys.ref
                  .read(productCategoryServiceProvider)
                  .fetchTrendingProducts();
              await CustomKeys.ref
                  .read(productCategoryServiceProvider)
                  .fetchAllSubCategoriesWithProducts(clear: true);
              await CustomKeys.ref
                  .read(orderHistoryServiceProvider)
                  .fetchOrders(clear: true);
            }
          });
          socket!.onConnecting((data) => print("connecting"));

          //

          socket!.onConnectError((data) {
            // snack.error(data);
            print(data);
            setStatus(false);
            // ref.read(status.state).state = false;
          });

          socket!.onConnectTimeout((data) {
            // snack.error(data);
            setStatus(false);
            print(data);
            // print(baseUrlSocket);
            // ref.read(status.state).state = false;
          });

          socket!.onError((data) async {
            setStatus(false);
            socket!.close();
            await Api.getToken();
          });
          socket!.onDisconnect((data) {
            // ref.read(status.state).state = false;
            setStatus(false);

            // snack.error("disconnected");
          });
          socket!.on("session_expired", (data) {
            // snack.info(data);
            socket!.disconnect();
            storage.erase();
            CustomDialogBox.alertMessage(() {
              logout(CustomKeys.context);
            },
                title: "Session Expired",
                message: "Your session has expired! Login to continue");
          });
          socket!.on("trending_update", (data) {
            // snack.info(data);

            CustomKeys.ref
                .read(productCategoryServiceProvider)
                .fetchTrendingProducts();
          });

          socket!.on("end_delivery", (jsonData) {
            try {
              // var jsonData = jsonDecode(data);

              CustomLocalNotification.otpShop(
                orderId: jsonData["order_id"],
                otp: jsonData["otp"],
                staff: jsonData["staff"] ?? "XYZ",
              );
            } catch (e) {
              rethrow;
            }
          });

          socket!.on("banner", (jsonData) {
            CustomKeys.ref
                .read(productCategoryServiceProvider)
                .updateBanner(jsonData);
          });

          socket!.on("product", (jsonData) {
            CustomKeys.ref
                .read(productCategoryServiceProvider)
                .updateProduct(jsonData);
          });

          socket!.on("rated", (jsonData) {
            try {
              CustomKeys.ref.read(userChangeProvider).userUpdateRating(
                    jsonData["avgRating"],
                    jsonData["raterCount"],
                  );
              CustomLocalNotification.ratedbyshop(
                jsonData["shop"],
                jsonData["ratingByShop"] ?? 0,
              );
            } catch (e) {
              rethrow;
            }
          });
          socket!.on("request_update", (jsonData) {
            try {
              // var jsonData = jsonDecode(data);
              // print("request $jsonData");

              CustomKeys.ref
                  .read(orderHistoryServiceProvider)
                  .updateOrderStatus(jsonData["status"],
                      orderId: jsonData["order_id"],
                      requestId: jsonData["request_id"],
                      socket: true,
                      otp: jsonData["otp"]);
            } catch (e) {
              rethrow;
            }
          });
          socket!.on(
              "app_update", (data) => {UpdateService().checkForInAppUpdate()});
          socket!.on("order_update", (jsonData) {
            print("oder $jsonData");
            try {
              // var jsonData = jsonDecode(data);

              CustomKeys.ref
                  .read(orderHistoryServiceProvider)
                  .updateOrderStatus(jsonData["status"],
                      orderId: jsonData["order_id"],
                      socket: true,
                      fulfilled: jsonData["fulfilled"]);
            } catch (e) {
              rethrow;
            }
          });
        }
      } else {
        if (socket == null) {
          socket = setSocket();
          socket?.connect();
        }
      }
    } catch (e) {
      print('$e');
    }
  }

  setStatus(bool status) {
    Future.delayed(const Duration(milliseconds: 10), () {
      try {
        CustomKeys.ref.read(socketStatusProvider.state).state = status;
      } catch (e, s) {
        print("$e $s");
      }
    });
  }

  disconnect() {
    if (socket != null) {
      socket!.dispose();
      socket = null;
    }
  }

  refreshAuth(String token, {bool close = true}) {
    socket!.dispose();
    connect();
    // if (close) {
    //   socket!.dispose();

    // }
    // socket!.auth["x-access-token"] = token;

    // if (!socket!.connected) {
    //   socket!.connect();
    // }
  }
}
