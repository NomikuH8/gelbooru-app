import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gelbooru/apis/post_api.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/components/app_drawer.dart';
import 'package:gelbooru/components/post_grid_item.dart';
import 'package:gelbooru/constants/api_constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _tagsController = TextEditingController();
  final _pagingController = PagingController<int, Post>(firstPageKey: 0);

  Future<void> _searchTags() async {
    _pagingController.itemList = null;
    _pagingController.nextPageKey = 0;
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final posts = await PostApi.fetchPosts(_tagsController.text, pageKey);
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

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelbooru"),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _tagsController,
              onSubmitted: (value) => _searchTags(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Search"),
                suffixIcon: IconButton(
                  onPressed: _searchTags,
                  icon: const Icon(Icons.search_outlined),
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: PagedGridView<int, Post>(
                pagingController: _pagingController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridCount(),
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0),
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) =>
                      PostGridItem(post: item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
