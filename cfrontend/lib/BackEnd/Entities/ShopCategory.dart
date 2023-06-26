
class ShopCategory {
  final String id;

  final String image;
  final String name;
  final String displayId;

  ShopCategory(this.id, this.image, this.name, this.displayId);

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(json["_id"], json["image"], json["name"], json["id"]);
  }

  @override
  String toString() {
    return name;
  }
}

class SubCategory {
  String id;

  final String image;
  final String name;
  final String displayId;
  double? offset;
  int? skuCount;

  SubCategory(this.id, this.image, this.name, this.displayId, this.skuCount,
      {this.offset});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(json["_id"], json["image"], json["name"],
        json["id"].toString(), json["skuCount"]);
  }

  factory SubCategory.empty(String category) {
    return SubCategory(category, "", "", "", 0);
  }

  SubCategory copy({String? id}) {
    SubCategory sub = SubCategory("test", image, name, displayId, 0, offset: 0);
    sub.id = id ?? this.id;
    return sub;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SubCategory && other.id == id;
  }

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => id.hashCode;

}
