import 'package:flutter/material.dart';
import 'package:gelbooru/classes/post.dart';

class PostSlidingPanel extends StatefulWidget {
  const PostSlidingPanel({super.key, required this.post});

  final Post post;

  @override
  State<PostSlidingPanel> createState() => _PostSlidingPanelState();
}

class _PostSlidingPanelState extends State<PostSlidingPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ...widget.post.tags.split(" ").map(
                    (tag) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
