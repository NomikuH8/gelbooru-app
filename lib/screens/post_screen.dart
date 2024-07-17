import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/components/post_sliding_panel.dart';
import 'package:gelbooru/constants/shared_preferences_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var _loadSample = true;
  var _showAppBar = true;
  var _loading = false;
  late TargetPlatform? _platform;
  final _panelController = PanelController();

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _loadSample =
          prefs.getBool(SharedPreferencesConstants.preferSamplesKey) ?? false;
    });
  }

  String _getImageLink() {
    if (_loadSample && widget.post.sampleUrl.isNotEmpty) {
      return widget.post.sampleUrl;
    }

    return widget.post.fileUrl;
  }

  bool _isImage() {
    final image = widget.post.image;

    return !(image.endsWith("mp4") || image.endsWith("webm"));
  }

  Future<String?> _prepareSaveDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadDirectory =
        prefs.getString(SharedPreferencesConstants.downloadFolderKey) ??
            (await getDownloadsDirectory())!.path;

    return downloadDirectory;
  }

  Future<bool> _checkPermission() async {
    if (_platform != TargetPlatform.android) {
      return true;
    }

    final status = await Permission.storage.status;
    final newStatus = await Permission.manageExternalStorage.status;
    if (status == PermissionStatus.granted ||
        newStatus == PermissionStatus.granted) {
      return true;
    }

    final result = await Permission.storage.request();
    final newResult = await Permission.manageExternalStorage.request();
    if (result == PermissionStatus.granted ||
        newResult == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  Future<void> _downloadImage() async {
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
      var imageName = post.image;
      var downloadLink = post.fileUrl;

      if (_loadSample && post.sampleUrl.isNotEmpty) {
        imageName = "sample_${post.image}";
        downloadLink = post.sampleUrl;
      }

      await Dio().download(
        downloadLink,
        "$saveDirectory/$imageName",
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

  Future<void> toggleSlidingPanel() async {
    if (_panelController.isAttached && _panelController.isPanelOpen) {
      await _panelController.close();
    } else {
      await _panelController.open();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadSettings();

    if (Platform.isAndroid) {
      _platform = TargetPlatform.android;
    } else {
      _platform = TargetPlatform.linux;
    }

    if (!_isImage()) {
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
        toolbarHeight: _showAppBar ? 56.0 : 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: toggleSlidingPanel,
              iconSize: 32.0,
              icon: Icon(
                _panelController.isAttached && _panelController.isPanelOpen
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
      body: Column(
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
              body: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAppBar = !_showAppBar;
                  });
                },
                child: <Widget>[
                  if (_isImage())
                    PhotoView(
                      imageProvider: NetworkImage(_getImageLink()),
                    ),
                  if (!_isImage() && _platform == TargetPlatform.android)
                    Center(
                      child: Stack(
                        children: [
                          if (_videoPlayerController.value.isInitialized)
                            AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(
                                _videoPlayerController,
                              ),
                            ),
                          VideoProgressIndicator(
                            _videoPlayerController,
                            allowScrubbing: true,
                          ),
                        ],
                      ),
                    ),
                  if (!_isImage() && _platform == TargetPlatform.linux)
                    const Center(
                      child: Text("Can't show video in this platform"),
                    )
                ].first,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
