import 'package:ezdelivershop/BackEnd/ApiService.dart';
import 'package:http/http.dart';

class SuggestionService {
  Future<bool> postSuggestion(String suggestion) async {
    Response? res = await ApiService.post("suggestion/product",
        body: {"suggestion": suggestion},);
    return res != null;
  }
}