import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gelbooru/apis/tag_api.dart';
import 'package:gelbooru/classes/post.dart';
import 'package:gelbooru/classes/tag.dart';
import 'package:gelbooru/components/post_sliding_panel.dart';
import 'package:gelbooru/constants/shared_preferences_constants.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var _tags = <Tag>[];
  var _downloadError = false;
  var _downloaded = false;
  var _loadSample = true;
  var _showAppBar = true;
  var _loading = false;
  late final _player = Player();
  late final _videoController = VideoController(_player);
  late TargetPlatform? _platform;

  Future<void> _launchUrl() async {
    final url = Uri.parse(widget.post.source);
    if (!await launchUrl(url)) {
      const snackBar = SnackBar(content: Text("Couldn't open source"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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

  Future<void> _getTagInformation() async {
    _tags = await TagApi.fetchTagsForPost(widget.post.tags);
    _tags.sort(
      (a, b) {
        if (a.type == b.type) {
          return -a.name.compareTo(b.name);
        }

        return a.type - b.type;
      },
    );
    _tags = _tags.reversed.toList();
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

  void toggleSlidingPanel() {
    showMaterialModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      builder: (context) => PostSlidingPanel(
        post: widget.post,
        tags: _tags,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadSettings();
    _getTagInformation();

    if (Platform.isAndroid) {
      _platform = TargetPlatform.android;
    } else {
      _platform = TargetPlatform.linux;
    }

    if (!_isImage()) {
      _player.open(
        Media(widget.post.fileUrl),
      );

      _player.setVolume(70.0);
      _player.setPlaylistMode(PlaylistMode.single);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: _showAppBar ? 56.0 : 0.0,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const Icon(Icons.launch_outlined),
              onPressed: _launchUrl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: toggleSlidingPanel,
              iconSize: 36.0,
              icon: const Icon(
                Icons.arrow_drop_up_outlined,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              iconSize: 36.0,
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
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _showAppBar = !_showAppBar;
                });
              },
              child: <Widget>[
                if (_isImage())
                  PhotoView(
                    minScale: PhotoViewComputedScale.contained,
                    imageProvider: NetworkImage(_getImageLink()),
                  ),
                if (!_isImage())
                  Center(
                    child: Video(
                      controls: (state) => MaterialVideoControls(state),
                      controller: _videoController,
                    ),
                  ),
              ].first,
            ),
          ),
        ],
      ),
    );
  }
}
