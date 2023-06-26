import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Components/keys.dart';
import '../Components/snackbar/customsnackbar.dart';
import '../StateManagement/SignInManagement.dart';
import 'Enums/ServerService.dart';
import 'Services/AuthService.dart';

class ApiService {
  //9844785495
  static String showVersion = "1.0.0.5";
  static double version = 2;
  static ServerService serverService = ServerService.localhost;
  static String? authToken;
  static String? refreshToken;

  static Future<Response?> post(String url,
          {Map<String, dynamic>? body,
          bool withToken = true,
          bool handle = true}) async =>
      await request(
              () async => await http.post(Uri.parse("$baseUrl$url"),
                  body: body == null ? null : jsonEncode(body),
                  headers: getHeaders(withToken)),
              handle: handle,
              url: url)
          .onError((error, stackTrace) {
        if (kDebugMode) {
          print(stackTrace);
        }
        return null;
      });


  static Future<Response?> put(String url,
          {Map<String, dynamic>? body,
          bool withToken = true,
          bool handle = true}) async =>
      await request(
              () async => await http.put(Uri.parse("$baseUrl$url"),
                  body: body == null ? null : jsonEncode(body),
                  headers: getHeaders(withToken)),
              handle: handle,
              url: url)
          .onError((error, stackTrace) {
        if (kDebugMode) {
          print(stackTrace);
        }
        return null;
      });

  static Future<Response?> delete(String url,
      {bool withToken = true, bool handle = true}) async {
    return await request(
            () async => await http.delete(Uri.parse("$baseUrl$url"),
                headers: getHeaders(withToken)),
            handle: handle,
            url: url)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
      }
      return null;
    });
  }

  static Future<Response?> get(String url,
      {bool withToken = true,
      bool handle = true,
      bool withRefreshToken = false}) async {
    return await request(
            () async => await http.get(Uri.parse("$baseUrl$url"),
                headers:
                    getHeaders(withToken, withRefreshToken: withRefreshToken)),
            handle: handle,
            url: url)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
      }
      return null;
    });
  }

  static Map<String, String> getHeaders(bool withToken,
      {bool withRefreshToken = false}) {
    Map<String, String> headers = {
      "content-type": "application/json",
    };
    if (withToken) {
      String? authTokenLocal = CustomKeys.context?.read<SignInManagement>().authToken;
      String? refreshTokenLocal = CustomKeys.context?.read<SignInManagement>().refreshToken;
      if (authTokenLocal != null) {
        if (!withRefreshToken) {
          headers['x-access-token'] = authTokenLocal;
          return headers;
        }
        if (refreshTokenLocal != null) {
          headers['x-access-token'] = refreshTokenLocal;
          return headers;
        }
      }
    }
    return headers;
  }

  static printAll(String s) {
    int printed = s.length;
    int increment = 1;
    while (printed < 0) {
      int end = increment * 500;
      end = min(s.length, end);
      printed -= end + (increment - 1) * 500;
      if (kDebugMode) {
        print(s.substring((increment - 1) * 500, end));
      }
      increment++;
    }
  }

  static Future<Response?> request(Future<Response> Function() mainFunction,
      {required bool handle, required String url}) async {
    try {
      var response = await mainFunction();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        if (handle) {
          if (kDebugMode) {
            print(baseUrl + url);
          }
          return await handleUnwantedStatusCode(response, mainFunction);
        }
      }
    } on SocketException {
      CustomSnackBar().error("No internet connection");
    } on TimeoutException {
      CustomSnackBar().error("Server failed to respond");
    } catch (e) {
      if (kDebugMode) {
        print("exception from $url $e");
      }
      rethrow;
    }
    return null;
  }

  static Future<Response?> handleUnwantedStatusCode(
      Response res, Future<Response> Function() function) async {
    // print(res.statusCode);
    // print(res.body);
    if (res.statusCode == 500) {
      CustomSnackBar().error("Internal server error");
    } else if (res.statusCode == 403) {
      CustomSnackBar().error("Access Denied");
    } else if (res.statusCode == 404) {
      CustomSnackBar().error("Page not found");
    } else if (res.statusCode == 401) {
      return await handleUnAuthorizedCredentials(functionResponse: function);
    } else if (res.statusCode == 410) {
      return await handleUnAuthorizedCredentials(functionResponse: function);
    } else if (res.statusCode == 207) {
      CustomSnackBar().error("Incorrect OTP");
    } else if (res.statusCode == 501) {
      CustomSnackBar().error("Something went wrong : ${res.body.toString()}");
    } else if (res.statusCode == 411) {
      Map<String, dynamic> parsable = jsonDecode(res.body);
      CustomSnackBar().error(parsable["message"]);
    } else {
      try {
        var body = jsonDecode(res.body);
        if (body is String) {
          CustomSnackBar().error(body);
        } else if (body is Map<String, dynamic>) {
          CustomSnackBar().error(body["message"].toString());
        }
      } catch (E) {
        CustomSnackBar().error(res.body.toString());
      }
    }
    return Future.value(null);
  }

  static Future<Response?> handleUnAuthorizedCredentials(
      {Future<Response> Function()? functionResponse,
      Function()? functionBool}) async {
    await AuthService().refreshToken();
    if (functionResponse != null) {
      Response response = await functionResponse();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
    }
    if (functionBool != null) {
      await functionBool();
      return null;
    }
    CustomSnackBar().error("Unauthorized Credentials");
    CustomKeys.messengerKey.currentContext
        ?.read<SignInManagement>()
        .logout(CustomKeys.messengerKey.currentContext!);
    return null;
  }

  static bool hasInternet = true;

  static setInternetStatus(bool status) {
    hasInternet = status;

    if (status) {
      CustomSnackBar().success("Internet Connection Restored");
    } else {
      CustomSnackBar().error("Internet Connection Lost");
    }
  }

  static String get baseUrl => serverService.baseUrlHttp;

  static String get baseUrlSocket => serverService.baseUrlSocket;
}
