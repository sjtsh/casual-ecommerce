import 'dart:async';
import 'dart:io';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:http/http.dart';

class Api {
  Api._();
  static bool production = true;
  static bool test = false;
  static bool realDevice = true;
  static String get baseUrl => production
      ? "https://$productionUrl/${test ? "test" : ""}"
      : "http://$localUrl:$apiPort/";

  static String get baseUrlSocket =>
      '${production ? "https" : "http"}://${production ? "${test ? "ts" : "socket"}.faasto.co" : localUrl}${production ? "" : ":$socketPort"}';

  static int apiPort = 10000, socketPort = 10001;

  static String localUrl = realDevice ? "192.168.1.75" : "10.0.2.2";

  static const productionUrl = "api.faasto.co";

  static const timeoutDuration = Duration(seconds: 6);

  static Map<String, String>? getHeader({bool refresh = false}) {
    var user = CustomKeys.ref.read(userChangeProvider).loggedInUser.value;
    if (user != null) {
      return {
        "Content-Type": "application/json",
        "x-access-token": "${!refresh ? user.accessToken : user.refreshToken}"
      };
    } else {
      return {"Content-Type": "application/json"};
    }
  }

  static bool hasInternet = true;
  static setInternetStatus(bool status) {
    hasInternet = status;

    if (status) {
      snack.success("Internet Connection Restored");
    } else {
      snack.error("Internet Connection Lost");
    }
  }

  static Future<Response?> get(
      {String? url,
      required String endpoint,
      Duration timeout = timeoutDuration,
      int successCode = 200,
      bool notify = true,
      bool throwError = false,
      bool refresh = false}) async {
    // print(baseUrl + endpoint);
    return await request(
        () => client
            .get(Uri.parse((url ?? baseUrl) + endpoint),
                headers: getHeader(refresh: refresh))
            .timeout(timeout),
        notify: notify,
        throwErr: throwError);
  }

  static Future<Response?> head(
      {String? url,
      required String endpoint,
      Duration timeout = timeoutDuration,
      int successCode = 200,
      bool notify = true,
      bool throwError = false}) async {
    return await request(
        () => client
            .head(Uri.parse((url ?? baseUrl) + endpoint), headers: getHeader())
            .timeout(timeout),
        notify: notify,
        throwErr: throwError);
  }

  static Future<Response?> post(
      {String? url,
      required String endpoint,
      Duration timeout = timeoutDuration,
      Object? body,
      int successCode = 201,
      bool notify = true,
      bool throwError = false}) async {
    return await request(
        () => client
            .post(Uri.parse((url ?? baseUrl) + endpoint),
                body: body, headers: getHeader())
            .timeout(timeout),
        notify: notify,
        successCode: successCode,
        throwErr: throwError);
  }

  static Future<Response?> put(
      {String? url,
      required String endpoint,
      Duration timeout = timeoutDuration,
      Object? body,
      int successCode = 200,
      bool notify = true,
      bool throwError = false}) async {
    return await request(
        () => client
            .put(Uri.parse((url ?? baseUrl) + endpoint),
                body: body, headers: getHeader())
            .timeout(timeout),
        notify: notify,
        throwErr: throwError);
  }

  static Future<Response?> getToken(
      {Future<Response>? Function()? mainfunction}) async {
    var response = await client.get(Uri.parse("${baseUrl}auth/refresh"),
        headers: getHeader(refresh: true));
    if (response.statusCode == 200) {
      var userService = CustomKeys.ref.read(userChangeProvider);
      var token = jsonDecode(response.body);
      userService.loggedInUser.value!.accessToken = token["x-access-token"];
      userService.store();
      userService.load();
      // print(token["x-access-token"]);
      if (mainfunction != null) {
        var resp = await mainfunction();
        // CustomKeys.ref
        //     .read(customSocketProvider)
        //     .refreshAuth(token["x-access-token"], close: false);
        return resp;
      } else {
        CustomKeys.ref
            .read(customSocketProvider)
            .refreshAuth(token["x-access-token"], close: false);
      }
    } else {
      CustomDialogBox.alertMessage(() {
        logout(CustomKeys.context);
      },
          title: "Session Expired",
          message: "Your session has expired! Login to continue");
      return null;
    }
  }

  static Future<Response?> delete(
      {String? url,
      required String endpoint,
      Duration timeout = timeoutDuration,
      Object? body,
      int successCode = 200,
      bool notify = true,
      bool throwError = false}) async {
    return await request(
        () => client
            .delete(Uri.parse((url ?? baseUrl) + endpoint),
                body: body, headers: getHeader())
            .timeout(timeout),
        notify: notify,
        throwErr: throwError);
  }

  static Future<Response?> request(Future<Response> Function() mainfunction,
      {int successCode = 200,
      bool notify = true,
      bool throwErr = false}) async {
    if (hasInternet) {
      try {
        Response response = await mainfunction();
        print(response.statusCode);
        // print(response.body);

        if (response.statusCode == successCode) {
          return response;
        } else {
          if (response.statusCode == 500) {
            const msg = "Server Error. Try again later";
            if (throwErr) throw msg;
            snack.error(msg);
            // throw "Internal Server Error";
          }
          //token expired
          else if (response.statusCode == 401) {
            var body = jsonDecode(response.body);
            if (body["error"] == "Invalid token") {
              return await getToken(mainfunction: mainfunction);
            } else {
              throw body["message"];
            }
          } else {
            try {
              var error = jsonDecode(response.body);
              print(error);
              if (notify) {
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (error["message"] != null) {
                    if (throwErr) throw error["message"];
                    snack.error(error["message"]);
                  }
                });
              }
            } catch (e) {
              throw response.reasonPhrase!;
            }
          }
        }
      } on SocketException {
        const msg = "Service Unavailable";
        if (throwErr) throw msg;
        snack.error("Service Unavailable");
      } on TimeoutException {
        const msg = "Service Unavailable";
        if (throwErr) throw msg;
        snack.error(msg);
        if (throwErr) throw msg;
      } catch (e, s) {
        // snack.error(e);
        // snack.error(title: e.toString());
        print("$e $s");
        if (throwErr) rethrow;
      }
    } else {
      if (throwErr) throw "No Internet Connection";
      Utilities.futureDelayed(20, () {
        snack.noInternet();
      });
    }

    return null;
  }
}
