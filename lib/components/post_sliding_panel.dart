import 'package:flutter/material.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/classes/tag.dart';
import 'package:gelbooru/screens/start_screen.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostSlidingPanel extends StatefulWidget {
  const PostSlidingPanel({super.key, required this.post, required this.tags});

  final Post post;
  final List<Tag> tags;

  @override
  State<PostSlidingPanel> createState() => _PostSlidingPanelState();
}

class _PostSlidingPanelState extends State<PostSlidingPanel> {
  Color _getColorByCategory(Tag tag) {
    // 0: common
    // 1: artist
    // 3: copyright
    // 4: character
    // 5: metadata

    return switch (tag.type) {
      0 => const Color.fromRGBO(21, 101, 192, 0.7),
      1 => const Color.fromRGBO(198, 40, 40, 0.7),
      3 => const Color.fromRGBO(236, 64, 122, 0.7),
      4 => const Color.fromRGBO(102, 187, 106, 0.7),
      5 => const Color.fromRGBO(255, 143, 0, 0.7),
      _ => const Color.fromRGBO(0, 131, 143, 0.7)
    };
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 66.0, 10.0, 10.0),
        child: Column(
          children: [
            ...widget.tags.map(
              (tag) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorByCategory(tag),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                            child: Text(
                              tag.name,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.5),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6.0),
                                ),
                                border: Border.all(
                                  color: Colors.grey[850]!,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  tag.count.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[850]!,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.to(
                                  () => StartScreen(defaultSearch: tag.name),
                                );
                              },
                              color: Colors.grey[850]!,
                              icon: const Icon(Icons.search_outlined),
                            ),
                          ],
                        )
                      ],
                    ),
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
