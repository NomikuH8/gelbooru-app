import 'dart:convert';

import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/constants/api_constants.dart';
import 'package:gelbooru/controllers/account_controller.dart';
import 'package:http/http.dart' as http;

class PostApi {
  static Future<List<Post>> fetchPosts(String searchTags, int pageId) async {
    final apiKey = AccountController.to.apiKey.value;
    final userId = AccountController.to.userId.value;

    final query = <String>[
      "page=dapi",
      "s=post",
      "q=index",
      if (searchTags.isNotEmpty) "tags=$searchTags",
      "pid=$pageId",
      "limit=${ApiConstants.limit}",
      "json=${ApiConstants.json}",
      if (apiKey.isNotEmpty) "api_key=$apiKey",
      if (userId.isNotEmpty) "user_id=$userId",
    ];

    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/index.php?${query.join("&")}",
    );

    final response = await http.get(uri, headers: ApiConstants.headers);

    if (response.statusCode != 200) {
      return [];
    }

    final postArray = (jsonDecode(response.body)
        as Map<String, dynamic>)["post"] as List<dynamic>;

    return postArray.map((post) => Post.fromJson(post)).toList();
  }
}
