import 'package:flutter/material.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/screens/post_screen.dart';
import 'package:get/get.dart';

class PostGridItem extends StatelessWidget {
  const PostGridItem({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: InkWell(
        onTap: () => Get.to(() => PostScreen(post: post)),
        child: Image.network(
          post.previewUrl,
        ),
      ),
    );
  }
}
