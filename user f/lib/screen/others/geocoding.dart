// Geocoder Buddy Data Model

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/search/searchService.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

class CustomGeoCoder {
  // static Future<List<CustomAddressData>> query(String address) async {
  //   var data = await NetworkService.searhAddress(address);
  //   return bgSearchDataFromJson(mapDataToJson(data));
  // }

  // static Future<CustomAddressData> searchToCustomAddressData(GBSearchData data) async {
  //   var pos =
  //       GBLatLng(lat: double.parse(data.lat), lng: double.parse(data.lon));
  //   var res = await NetworkService.getDetails(pos);
  //   return res;
  // }

  static Future<CustomAddressData?> findDetails(Position pos) async {
    var data = await NetworkService.getDetails(pos);
    return data;
  }
}

// ignore: constant_identifier_names
const PATH = "https://nominatim.openstreetmap.org";

class NetworkService {
  // static Future<List<MapData>> searhAddress(String query) async {
  //   var request =
  //       http.Request('GET', Uri.parse("$PATH/search?q=$query&format=jsonv2"));
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     var data = await response.stream.bytesToString();
  //     return mapDataFromJson(data);
  //   } else {
  //     throw Exception(response.reasonPhrase);
  //   }
  // }

  static Future<CustomAddressData?> getDetails(Position pos) async {
    return await CustomKeys.ref
        .read(searchServiceProvider)
        .searchByCoordinate(LatLng(pos.latitude, pos.longitude));
    // var response = await client.get(Uri.parse(
    //     '$PATH/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=jsonv2'));

    // if (response.statusCode == 200) {
    //   return customAddressDataFromJson(response.body);
    // } else {
    //   throw Exception(response.reasonPhrase);
    // }
  }
}

CustomAddressData customAddressDataFromJson(String str) =>
    CustomAddressData.fromJson(json.decode(str));

String customAddressDataToJson(CustomAddressData data) =>
    json.encode(data.toJson());

class CustomAddressData {
  CustomAddressData({
    required this.placeId,
    required this.osmType,
    required this.id,
    required this.lat,
    required this.lon,
    required this.placeRank,
    required this.importance,
    required this.displayName,
    required this.address,
    required this.boundingbox,
    this.current = true,
  });

  int placeId;
  String osmType;
  int id;
  String lat;
  String lon;
  int placeRank;
  double importance;
  String displayName;
  CustomAddress address;
  bool current;
  List<String> boundingbox;
  CustomAddressData copywith({
    int? placeId,
    String? osmType,
    int? id,
    String? lat,
    String? lon,
    int? placeRank,
    double? importance,
    String? displayName,
    CustomAddress? address,
    bool? current,
    List<String>? boundingbox,
  }) {
    return CustomAddressData(
        placeId: placeId ?? this.placeId,
        osmType: osmType ?? this.osmType,
        id: id ?? this.id,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        placeRank: placeRank ?? this.placeRank,
        importance: importance ?? this.importance,
        displayName: displayName ?? this.displayName,
        address: address ?? this.address,
        boundingbox: boundingbox ?? this.boundingbox);
  }

  factory CustomAddressData.fromJson(Map<String, dynamic> json) =>
      CustomAddressData(
        placeId: json["place_id"],
        osmType: json["osm_type"],
        id: json["osm_id"],
        lat: json["lat"],
        lon: json["lon"],
        placeRank: json["place_rank"],
        importance: json["importance"].toDouble(),
        displayName: json["display_name"],
        address: CustomAddress.fromJson(json["address"]),
        boundingbox: List<String>.from(json["boundingbox"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "osm_type": osmType,
        "osm_id": id,
        "lat": lat,
        "lon": lon,
        "place_rank": placeRank,
        "importance": importance,
        "display_name": displayName,
        "address": address.toJson(),
        "boundingbox": List<dynamic>.from(boundingbox.map((x) => x)),
      };

  static CustomAddressData? fromAddressModel(AddressModel? model) {
    if (model == null) return null;
    return CustomAddressData(
        placeId: 0,
        osmType: '',
        id: 0,
        lat: model.location.coordinates.last.toString(),
        lon: model.location.coordinates.first.toString(),
        placeRank: 100,
        importance: 1,
        displayName: model.fullAddress,
        address: CustomAddress(),
        boundingbox: []);
  }

  static CustomAddressData? fromSingleHereApi(Map<String, dynamic> json) {
    try {
      var a = CustomAddressData(
          placeId: 0,
          osmType: "",
          id: 0,
          lat: json["position"]["lat"].toString(),
          lon: json["position"]["lng"].toString(),
          placeRank: 0,
          importance: 0.0,
          displayName: json["title"],
          address: CustomAddress(),
          boundingbox: []);
      return a;
    } catch (e) {
      return null;
    }
  }

  static List<CustomAddressData> fromHereApi(String data) {
    List<CustomAddressData> addresses = [];
    var json = jsonDecode(data);
    var tempData = List<CustomAddressData?>.from(
        json["items"].map((e) => fromSingleHereApi(e)));
    for (var element in tempData) {
      if (element != null) addresses.add(element);
    }
    return addresses;
  }
}

class CustomAddress {
  CustomAddress({
    this.road,
    this.village,
    this.county,
    this.stateDistrict,
    this.state,
    this.iso31662Lvl4,
    this.postcode,
    this.country,
    this.countryCode,
  });

  String? road;
  String? village;
  String? county;
  String? stateDistrict;
  String? state;
  String? iso31662Lvl4;
  String? postcode;
  String? country;
  String? countryCode;

  factory CustomAddress.fromJson(Map<String, dynamic> json) => CustomAddress(
        road: json["road"],
        village: json["village"],
        county: json["county"],
        stateDistrict: json["state_district"],
        state: json["state"],
        iso31662Lvl4: json["ISO3166-2-lvl4"],
        postcode: json["postcode"],
        country: json["country"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "road": road,
        "village": village,
        "county": county,
        "state_district": stateDistrict,
        "state": state,
        "ISO3166-2-lvl4": iso31662Lvl4,
        "postcode": postcode,
        "country": country,
        "country_code": countryCode,
      };
}
