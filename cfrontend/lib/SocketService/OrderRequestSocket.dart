import 'package:ezdelivershop/BackEnd/ApiService.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:ezdelivershop/UI/DialogBox/MultipleAccontAlert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../BackEnd/Services/AuthService.dart';
import '../StateManagement/DeliveryRadiusManagement.dart';

class OrderSocket {
  static Socket? socket;

  static orderSocket(BuildContext context, {String? accessToken}) async {
    socket?.dispose();
    accessToken ??= (await SharedPreferences.getInstance()).getString("token");
    if (accessToken == null) return;
    socket = io(
      ApiService.baseUrlSocket,
      OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({
            "x-access-token": accessToken,
            'device-id': await StaticService.deviceIdOnly()
          })
          .enableForceNewConnection()
          .build(),
    );
    socket?.connect();
    socket?.onConnect((data) {
      AuthService().isConnection().then((connection) {
        if (!connection) {
          context.read<SignInManagement>().logoutFromWrongProduction(context);
        }
      });
      try {
        context.read<DeliveryRadiusManagement>().online = true;
      } catch (e) {}
      if (kDebugMode) {
        print("connected");
      }
    });
    socket?.onDisconnect((data) {
      try {
        context.read<DeliveryRadiusManagement>().online = false;
      } catch (e) {
        rethrow;
      }
      if (kDebugMode) {
        print("disconnected");
      }
    });
    socket?.onError((data) async {
      ApiService.handleUnAuthorizedCredentials(functionBool: () async {
        socket?.auth["x-access-token"] =
            (await SharedPreferences.getInstance()).getString("token");
        socket?.connect();
      });
    });
    // if(Roles.cont(OrderRoles.orderRolesReceive)){
    // socket?.on("order_request", (data) => addOrder(context, data));
    // }
    // socket?.on(
    //     "feedback_confirmation", (data) => feedbackConfirmation(context, data));
    // socket?.on("feedback_missed", (data) => feedbackMissed(context, data));
    // socket?.on("feedback_disregard", (data) => disregardOrder(context, data));
    socket?.on("session_expired", (data) => expireSession(context, data));
    // socket?.on("request_cancelled", (data) => cancelRequest(context, data));
    // socket?.on("delivery_request", (data) => deliveryRequest(context, data));
    // socket?.on("delivery_accepted", (data) => deliveryAccepted(context, data));
    // socket?.on("delivery_missed", (data) => deliveryMissed(context, data));
    // socket?.on("delivery_started", (data) => deliveryStarted(context, data));
    // socket?.on("request_cancelled_by_staff",
    //     (data) => requestCancelledByStaff(context, data));
    // socket?.on("delivery_ended", (data) => deliveryEnded(context, data));
    // socket?.on(
    //     "order_cancelled_system", (data) => cancelOrderSystem(context, data));
    socket?.on("rated", (data) => getRating(context, data));
    // socket?.on("order_reject", (data) => orderReject(context, data));
    // socket?.on("order_failed", (data) => orderFailed(context, data));
    // socket?.on("online_status", (data) => print("online status connected"));
  }

  // static requestCancelledByStaff(BuildContext context, String data) {
  //   context.read<DataManagement>().requestCancelledByStaff(data);
  // }

  // static deliveryAccepted(BuildContext context, Map<String, dynamic> data) {
  //   context.read<DataManagement>().deliveryAccepted(
  //       data["order"].toString(), data["deliveredBy"].toString());
  // }
  //
  // static deliveryMissed(BuildContext context, Map<String, dynamic> data) {
  //   context
  //       .read<NewOrderManagement>()
  //       .missDeliveryOrderFromSocket(data["order"].toString(), context);
  // }
  //
  // static deliveryStarted(BuildContext context, String data) {
  //   context.read<DataManagement>().deliveryStarted(data.toString());
  // }
  //
  // static deliveryEnded(BuildContext context, String data) {
  //   context.read<DataManagement>().deliveryEnded(data.toString());
  // }
  //
  // static orderFailed(BuildContext context, String data) {
  //   Future.delayed(const Duration(seconds: 1)).then(
  //       (value) => context.read<DataManagement>().orderFailed(data.toString()));
  //   context
  //       .read<NewOrderManagement>()
  //       .deliveryOrderFailed(data.toString(), context);
  // }

  // static orderReject(BuildContext context, String data) {
  //   context
  //       .read<NewOrderManagement>()
  //       .rejectOrderFromSocket(data.toString(), context);
  // }

  static emitEndDelivery(String requestID) {
    socket?.emit("end_delivery", requestID);
  }

  static emitSendLocation(Position position) {
    Map<String, dynamic> lData = {
      "coordinates": [position.longitude, position.latitude]
    };
    socket?.emit("stamp", lData);
  }

  // static cancelRequest(BuildContext context, String data) {
  //   context.read<DataManagement>().cancelRequestByUser(data);
  // }

  // static feedbackMissed(BuildContext context, Map<String, dynamic> data) {
  //   context
  //       .read<NewOrderManagement>()
  //       .missOrderFromSocket(data["order"], context);
  // }

  // static cancelOrderSystem(BuildContext context, String orderID) {
  //   context.read<DataManagement>().cancelOrderBySystem(orderID);
  // }

  // static addOrder(BuildContext context, Map<String, dynamic> data) async {
  //   Order order = Order.fromJson(data);
  //   context.read<NewOrderManagement>().newOrders = [
  //     order,
  //     ...context.read<NewOrderManagement>().newOrders
  //   ];
  // }

  static getRating(BuildContext context, Map<String, dynamic> data) {}

  // static disregardOrder(BuildContext context, Map<String, dynamic> data) {
  //   context
  //       .read<DataManagement>()
  //       .changeStatus3Disregard(data["request"], data["selectedRequest"]);
  // }

  // static feedbackConfirmation(
  //     BuildContext context, Map<String, dynamic> data) async {
  //   context.read<DataManagement>().changeStatus3Confirm(data);
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return ConfirmationDialogBox(
    //           onPressed: () {},
    //           title: "FeedBack Confirmation",
    //           subTitle: "Your order has been matched",
    //           onPressedPop: true);
    //     });
  // }

  // static deliveryRequest(BuildContext context, dynamic data) {
  //   Order order = Order.fromJson(data);
  //
  //   context.read<NewOrderManagement>().newDeliveryOrders = [
  //     order,
  //     ...context.read<NewOrderManagement>().newDeliveryOrders
  //   ];
  // }

  static expireSession(BuildContext context, dynamic data) async {
    // context.read<NewOrderManagement>().player.stop();
    await context.read<SignInManagement>().logout(context);
    StaticService.showDialogBox(
        context: context,
        child: MultipleAccountAlert(
          onPressed: () {},
          onPressedPop: true,
        ));
  }
}
