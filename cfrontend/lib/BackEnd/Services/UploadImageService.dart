import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../ApiService.dart';
import '../Entities/UploadedImage.dart';

class UploadImageService {
  Future<List<UploadedImage>> uploadOwnerImage(
      List<UploadableImage> uploadableImages) async {
    if (uploadableImages.isEmpty) return [];
    MultipartRequest req =
        http.MultipartRequest("POST", Uri.parse("${ApiService.baseUrl}upload"));
    for (int i = 0; i < uploadableImages.length; i++) {
      if (uploadableImages[i].devicePath != null &&
          uploadableImages[i].fileName != null &&
          uploadableImages[i].serverPath != null) {
        req.files.add(await http.MultipartFile.fromPath(
            "files$i", uploadableImages[i].devicePath!,
            filename: uploadableImages[i].fileName));
        req.fields.addAll({"files$i": uploadableImages[i].serverPath!});
      }
    }
    Response res = await Response.fromStream(await req.send());
    if (res.statusCode != 200) throw "try again";
    Map<String, dynamic> parsable = jsonDecode(res.body);

    return parsable.entries
        .map((entry) => UploadedImage(entry.value, entry.key))
        .toList();
  }
}
