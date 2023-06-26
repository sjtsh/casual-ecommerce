import 'dart:collection';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/component/search_page_web/search_page.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/others/geocoding.dart';

final searchServiceProvider = ChangeNotifierProvider<SearchService>((ref) {
  return SearchService._();
});

class SearchService extends ChangeNotifier {
  SearchService._();
  final String apiKey = "kxCVlVVXD0hSE25FxCyy-EefSKRff66-jrXt3qADgyE";
  final List<Product> _searchProduct = [];
  final List<CustomAddressData> _searchAddress = [];

  final searchWebFieldProvider = Provider<TextEditingController>((ref) {
    return TextEditingController();
  });
  List<Product> get searchProduct => UnmodifiableListView(_searchProduct);
  Future<List<Product>> searchProducts(String query) async {
    var location = CustomKeys.ref.read(locationServiceProvider).location;
    if (location == null) return [];
    var url =
        "faasto/product/search?s=$query&lat=${location.latitude}&lon=${location.longitude}";

    try {
      var response = await Api.get(
          endpoint: url,
          timeout: const Duration(seconds: 10),
          throwError: true);
      // Api.request(
      //   () => client.get(
      //     Uri.parse("${Api.baseUrl}product/search?s=$query"),
      //     headers: header(),
      //   ),
      // ).timeout(const Duration(seconds: 10));

      if (response != null) {
        _searchProduct.clear();
        var data = productFromJson(response.body);
        _searchProduct.addAll(data);

        notifyListeners();
        return data;
      } else {
        throw "Some Error Occured";
      }
    } catch (e) {
      rethrow;
    }
  }

  searchProductsForWeb(String query) {
    ResponsiveLayout.setHolderWidget(const Center(
      child: CircularProgressIndicator(),
    ));

    Utilities.futureDelayed(50, () {
      ResponsiveLayout.setHolderWidget(SearchPage(
        query: query,
      ));
    });
  }

  Future<List<CustomAddressData>> searchAddress(String query) async {
    try {
      var response = await Api.get(
          url: "https://autosuggest.search.hereapi.com/v1/",
          endpoint:
              "autosuggest?apiKey=$apiKey&q=$query&in=bbox:80.0884245137,26.3978980576,88.1748043151,30.4227169866&in=countryCode:NPL",
          timeout: const Duration(seconds: 10),
          throwError: true);
      // Api.request(
      //   () => client.get(
      //     Uri.parse("${Api.baseUrl}product/search?s=$query"),
      //     headers: header(),
      //   ),
      // ).timeout(const Duration(seconds: 10));

      if (response != null) {
        _searchAddress.clear();
        var data = CustomAddressData.fromHereApi(response.body);

        _searchAddress.addAll(data);
        notifyListeners();
        return data;
      } else {
        throw "Some Error Occured";
      }
    } catch (e, s) {
      print("$e $s");
      rethrow;
    }
  }

  Future<CustomAddressData?> searchByCoordinate(LatLng coordinate) async {
    //&in=countryCode:NPL
    try {
      var response = await Api.get(
          url: "https://revgeocode.search.hereapi.com/v1/",
          endpoint:
              "revgeocode?apiKey=$apiKey&at=${coordinate.latitude},${coordinate.longitude}",
          timeout: const Duration(seconds: 10),
          throwError: true);
      // Api.request(
      //   () => client.get(
      //     Uri.parse("${Api.baseUrl}product/search?s=$query"),
      //     headers: header(),
      //   ),
      // ).timeout(const Duration(seconds: 10));

      if (response != null) {
        _searchAddress.clear();
        var data = CustomAddressData.fromHereApi(response.body);

        notifyListeners();

        if (data.isEmpty) return null;
        return data.first;
      } else {
        throw "Some Error Occured";
      }
    } catch (e, s) {
      print("$e $s");
      rethrow;
    }
  }

  clearProducts() {
    _searchProduct.clear();
    notifyListeners();
  }
}
