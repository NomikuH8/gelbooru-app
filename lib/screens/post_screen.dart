import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/components/post_sliding_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var _videoPlayerController = VideoPlayerController.asset("");
  var _downloadError = false;
  var _downloaded = false;
  var _loading = false;
  late TargetPlatform? _platform;
  final _panelController = PanelController();

  bool isImage() {
    final image = widget.post.image;

    return !(image.endsWith("mp4") || image.endsWith("webm"));
  }

  Future<String?> _prepareSaveDirectory() async {
    final downloadDirectory = await getDownloadsDirectory();

    return downloadDirectory?.path;
  }

  Future<bool> _checkPermission() async {
    if (_platform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      return true;
    }

    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  void _downloadImage() async {
    _downloadError = false;

    if (_downloaded || _loading) {
      return;
    }

    if (!await _checkPermission()) {
      return;
    }

    final saveDirectory = await _prepareSaveDirectory();

    try {
      setState(() {
        _loading = true;
      });

      final post = widget.post;
      await Dio().download(
        post.fileUrl,
        "$saveDirectory/${post.image}",
      );

      setState(() {
        _loading = false;
        _downloaded = true;
      });
    } catch (err) {
      setState(() {
        _loading = false;
        _downloadError = true;
      });
    }
  }

  IconData _getDownloadIcon() {
    if (_downloadError) {
      return Icons.close_outlined;
    }

    if (_downloaded) {
      return Icons.download_done_outlined;
    }

    return Icons.download_outlined;
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _platform = TargetPlatform.android;
    } else {
      _platform = TargetPlatform.linux;
    }

    if (!isImage()) {
      if (_platform == TargetPlatform.linux) {
        return;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.fileUrl),
      );
      _videoPlayerController.addListener(() {
        setState(() {});
      });

      _videoPlayerController.setLooping(true);
      _videoPlayerController.initialize().then((_) => setState(() {}));

      _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () =>
                  _panelController.isAttached && _panelController.isPanelClosed
                      ? _panelController.open()
                      : _panelController.close(),
              iconSize: 32.0,
              icon: Icon(
                _panelController.isAttached && _panelController.isPanelClosed
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              iconSize: 32.0,
              onPressed: _downloadImage,
              icon: _loading
                  ? const CircularProgressIndicator()
                  : Icon(_getDownloadIcon()),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SlidingUpPanel(
                controller: _panelController,
                backdropEnabled: true,
                backdropOpacity: 0.5,
                minHeight: 0.0,
                maxHeight: 800.0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                panel: PostSlidingPanel(post: widget.post),
                body: <Widget>[
                  if (isImage())
                    PhotoView(
                      imageProvider: NetworkImage(widget.post.fileUrl),
                    ),
                  if (!isImage() && _platform == TargetPlatform.android)
                    Stack(
                      children: [
                        VideoPlayer(
                          _videoPlayerController,
                        ),
                        VideoProgressIndicator(
                          _videoPlayerController,
                          allowScrubbing: true,
                        ),
                      ],
                    ),
                  if (!isImage() && _platform == TargetPlatform.linux)
                    const Center(
                      child: Text("Can't show video in this platform"),
                    )
                ].first,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
