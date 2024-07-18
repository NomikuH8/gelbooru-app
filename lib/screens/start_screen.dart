import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gelbooru/apis/post_api.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/components/app_drawer.dart';
import 'package:gelbooru/components/post_grid_item.dart';
import 'package:gelbooru/components/tag_search_raw.dart';
import 'package:gelbooru/constants/api_constants.dart';
import 'package:gelbooru/constants/shared_preferences_constants.dart';
import 'package:gelbooru/screens/search_helper_screen.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.defaultSearch});

  final String defaultSearch;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _pagingController = PagingController<int, Post>(firstPageKey: 0);
  var _currentSearch = "";
  var _rawSearch = true;

  void _searchTags(String value) {
    _currentSearch = value;
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final posts = await PostApi.fetchPosts(_currentSearch, pageKey);
      final isLastPage = posts.length < ApiConstants.limit;
      if (isLastPage) {
        _pagingController.appendLastPage(posts);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(posts, nextPageKey);
      }
    } catch (err) {
      _pagingController.error = err;
    }
  }

  int _getGridCount() {
    final platform =
        Platform.isAndroid ? TargetPlatform.android : TargetPlatform.linux;
    var divider = 250;

    if (platform == TargetPlatform.android) {
      divider = 100;
    }

    var count = (MediaQuery.of(context).size.width ~/ divider).toInt();

    if (count == 0) {
      count = 1;
    }

    return count;
  }

  Future<void> _updateRawSearchSharedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      SharedPreferencesConstants.preferRawSearchKey,
      _rawSearch,
    );
  }

  Future<void> _loadRawSearchSharedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rawSearch =
          prefs.getBool(SharedPreferencesConstants.preferRawSearchKey) ?? true;
    });
  }

  @override
  void initState() {
    super.initState();

    _currentSearch = widget.defaultSearch;

    _loadRawSearchSharedPreference();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelbooru"),
        actions: [
          IconButton(
            onPressed: () {
              _pagingController.refresh();
            },
            icon: const Icon(Icons.refresh_outlined),
          )
        ],
      ),
      drawer: widget.defaultSearch.isEmpty ? const AppDrawer() : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _rawSearch = !_rawSearch;
                    });
                    _updateRawSearchSharedPreference();
                  },
                  icon: _rawSearch
                      ? const Icon(Icons.raw_on_outlined)
                      : const Icon(Icons.raw_off),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: TagSearchRaw(
                    defaultText: widget.defaultSearch,
                    onSubmitted: _searchTags,
                  ),
                  // child: _rawSearch
                  //     ? TagSearchRaw(
                  //         onSubmitted: _searchTags,
                  //       )
                  //     : TagSearchAutocomplete(
                  //         onSubmitted: _searchTags,
                  //       ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                IconButton(
                  onPressed: () => Get.to(() => const SearchHelperScreen()),
                  icon: const Icon(Icons.help),
                )
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _pagingController.refresh()),
                child: PagedGridView<int, Post>(
                  pagingController: _pagingController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridCount(),
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) =>
                        PostGridItem(post: item),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
