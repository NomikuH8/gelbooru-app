import 'dart:convert';

import 'package:gelbooru/classes/autocomplete_entry.dart';
import 'package:gelbooru/constants/api_constants.dart';
import 'package:gelbooru/controllers/account_controller.dart';
import 'package:http/http.dart' as http;

class AutocompleteApi {
  static Future<List<AutocompleteEntry>> getAutocompleteEntries(
      String term) async {
    final apiKey = AccountController.to.apiKey.value;
    final userId = AccountController.to.userId.value;

    if (term.isEmpty) {
      return [];
    }

    final query = <String>[
      "page=autocomplete2",
      "term=$term",
      "type=tag_query",
      "limit=10",
      if (apiKey.isNotEmpty) "api_key=$apiKey",
      if (userId.isNotEmpty) "user_id=$userId",
    ];

    final uri =
        Uri.parse("${ApiConstants.baseUrl}/index.php?${query.join("&")}");

    final response = await http.get(uri, headers: ApiConstants.headers);

    if (response.statusCode != 200) {
      return [];
    }

    final entryArray = (jsonDecode(response.body) as List<dynamic>);

    return entryArray
        .map((entry) => AutocompleteEntry.fromJson(entry))
        .toList();
  }
}
