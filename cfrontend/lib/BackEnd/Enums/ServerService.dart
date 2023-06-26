

import '../ApiService.dart';

enum ServerService {
  testProduction,
  production,
  localhost;

  static String _unsecureProtocol = "http";
  static String _secureProtocol = "https";

  bool get isProduction => this != localhost;

  String get baseUrlSocket => "${isProduction ? _secureProtocol: _unsecureProtocol}://$urlSocket/";

  String get baseUrlHttp => "$protocol://$urlHttp/";

  String get urlSocket {
    switch (this) {
      case ServerService.production:
        return socketUrl;
      case ServerService.testProduction:
        return socketUrl;
      case ServerService.localhost:
        return "$localUrl:$portSocket";
    }
  }

  String get urlHttp {
    switch (this) {
      case ServerService.production:
        return productionUrl;
      case ServerService.testProduction:
        return "$productionUrl/test";
      case ServerService.localhost:
        return "$localUrl:$portHttp";
    }
  }

  static String localUrl = "192.168.1.75";
  static String productionUrl = "api.faasto.co";
  static int socketPortLocal = 10001;
  static int apiPortLocal = 10000;

  int get portHttp {
    switch (this) {
      case ServerService.production:
        return 9000;
      case ServerService.testProduction:
        return 10000;
      case ServerService.localhost:
        return apiPortLocal;
    }
  }

  int? get portSocket {
    switch (this) {
      case ServerService.production:
        return null;
      case ServerService.testProduction:
        return null;
      case ServerService.localhost:
        return socketPortLocal;
    }
  }

  String get protocol {
    switch (this) {
      case ServerService.testProduction:
        return _secureProtocol;
      case ServerService.production:
        return _secureProtocol;
      case ServerService.localhost:
        return _unsecureProtocol;
    }
  }
  String get socketUrl {
    switch (this) {
      case ServerService.production:
        return "socket.faasto.co";
      case ServerService.testProduction:
        return "ts.faasto.co";
      case ServerService.localhost:
        return localUrl;
    }
  }

  static _printable(a, b) {
    print("$a | $b");
  }

  static printAllUrls() {
    print("*#" * 100);
    print("current");
    _printable("ApiService.serverService.baseUrlHttp",
        ApiService.serverService.baseUrlHttp);
    _printable("ApiService.serverService.baseUrlSocket",
        ApiService.serverService.baseUrlSocket);
    print("*#" * 100);
    _printable("localhost socketUrl", ServerService.localhost.baseUrlSocket);
    _printable("localhost urlHttp", ServerService.localhost.baseUrlHttp);
    _printable(
        "testProduction socketUrl", ServerService.testProduction.baseUrlSocket);
    _printable(
        "testProduction urlHttp", ServerService.testProduction.baseUrlHttp);
    _printable("production socketUrl", ServerService.production.baseUrlSocket);
    _printable("production urlHttp", ServerService.production.baseUrlHttp);
  }
}
