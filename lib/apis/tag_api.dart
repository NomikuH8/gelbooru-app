import 'dart:convert';

import 'package:gelbooru/classes/tag.dart';
import 'package:gelbooru/constants/api_constants.dart';
import 'package:gelbooru/controllers/account_controller.dart';
import 'package:http/http.dart' as http;

class TagApi {
  static Future<List<Tag>> fetchTagsForPost(String tags) async {
    if (tags.isEmpty) {
      return [];
    }

    final apiKey = AccountController.to.apiKey.value;
    final userId = AccountController.to.userId.value;

    final query = <String>[
      "page=dapi",
      "s=tag",
      "q=index",
      "names=${Uri.encodeComponent(tags)}",
      "json=${ApiConstants.json}",
      if (apiKey.isNotEmpty) "api_key=$apiKey",
      if (userId.isNotEmpty) "user_id=$userId",
    ];

    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/index.php?${query.join("&")}",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return [];
    }

    final tagArray = (jsonDecode(response.body) as Map<String, dynamic>)["tag"]
        as List<dynamic>;

    return tagArray.map((post) => Tag.fromJson(post)).toList();
  }
}
