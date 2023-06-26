class User {
  final String id;
  final String displayId;
  String name;
  final String phone;
  final String? image;

  User(this.id, this.displayId, this.name, this.phone, {this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json["_id"], json["id"], json["name"], json["phone"],
        image: null);
  }
}
