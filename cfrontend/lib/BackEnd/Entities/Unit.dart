
import 'dart:convert';

class Unit {
 String name;

  Unit(this.name);

  factory Unit.fromJson(String json){
    return  Unit(json);


  }
}

List<String> unitFromJson(String str) => List<String>.from(json.decode(str).map((x) => x));

String unitToJson(List<String> data) => json.encode(List<dynamic>.from(data.map((x) => x)));
