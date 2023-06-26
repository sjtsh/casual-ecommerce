class Product {
  final String id;
  final String name;
  double price;
  final int sku;
  final String? image;
  final String categoryId;
  final bool master;
  final String? parent;
  final String unit;
  int returnPolicy;

  Product(this.id, this.name, this.price, this.sku, this.image,
      this.categoryId, this.master, this.parent, this.unit, this.returnPolicy);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        json["_id"],
        json["name"],
        json["price"] + 0.0,
        int.tryParse((json["sku"] ?? "0").toString()) ?? 0,
        json["image"],
        json["category"],
        json["master"] ?? true,
        json["parent"],
      json["unit"],
      json["return"],


    );
  }
}
