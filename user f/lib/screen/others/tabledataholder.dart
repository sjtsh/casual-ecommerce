import 'package:ezdeliver/screen/component/helper/exporter.dart';

typedef Callback<T, U> = U Function(T data);

class TableDataHolder<T> {
  TableDataHolder({required this.count, required this.data});
  late final int count;
  final List<T> data;

  factory TableDataHolder.fromRawJson(
          String str, Callback<Map<String, dynamic>, T> callback) =>
      TableDataHolder.fromJson(json.decode(str), callback);
  factory TableDataHolder.fromJson(
      Map<String, dynamic> json, Callback<Map<String, dynamic>, T> callback) {
    // json is List<dynamic> ? json = json[0] : json;
    return TableDataHolder(
        count: json["count"] ?? 0,
        data: json["data"] != null
            ? List.from(
                json["data"].map((e) => callback(e as Map<String, dynamic>)))
            : []);
  }
}
