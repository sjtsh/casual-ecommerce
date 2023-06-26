import 'dart:convert';
import 'package:http/http.dart';

import '../ApiService.dart';

class DeveloperService {
  Future<List<dynamic>> getRoles() async {
    Response ? res = await ApiService.get("developer");
    return jsonDecode(res!.body);
  }



  Future<bool> updateRoles(List<dynamic> update) async {
    Response? res =
        await ApiService.put("developer", body: {
      "role": {"roles": update}
    });
    return res != null;
  }
}
