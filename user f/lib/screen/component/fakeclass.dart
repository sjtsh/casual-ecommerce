external JsObject get context;

class JsObject {
  external dynamic callMethod(Object method, [List? args]);
}

class UrlStrategy {}

class PathUrlStrategy extends UrlStrategy {}

void setUrlStrategy(UrlStrategy strategy) {}
