import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gelbooru/constants/shared_preferences_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _downloadFolderController = TextEditingController();
  var _preferSamples = false;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _downloadFolderController.text = prefs.getString(
          SharedPreferencesConstants.downloadFolderKey,
        ) ??
        (await getDownloadsDirectory())!.path;

    _preferSamples =
        prefs.getBool(SharedPreferencesConstants.preferSamplesKey) ?? false;
  }

  Future<void> _searchDownloadFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select a folder to download",
    );

    if (folder == null) {
      return;
    }

    final directory = Directory(folder);

    if (!directory.existsSync()) {
      directory.createSync();
    }

    _downloadFolderController.text = folder;
  }

  void _updatePreferSamples(bool? value) {
    setState(() {
      _preferSamples = value ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      SharedPreferencesConstants.downloadFolderKey,
      _downloadFolderController.text,
    );

    await prefs.setBool(
      SharedPreferencesConstants.preferSamplesKey,
      _preferSamples,
    );

    final snackBar = SnackBar(
      content: const Text("Settings successfully saved!"),
      action: SnackBarAction(label: "Ok", onPressed: () {}),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      label: Text("Downloads folder"),
                      border: OutlineInputBorder(),
                    ),
                    controller: _downloadFolderController,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: _searchDownloadFolder,
                  child: const Text("Search"),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saving images...",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  ListTile(
                    title: const Text("I prefer the samples"),
                    leading: Radio(
                      groupValue: _preferSamples,
                      value: true,
                      onChanged: _updatePreferSamples,
                    ),
                  ),
                  ListTile(
                    title: const Text("I prefer the full images (HD)"),
                    leading: Radio(
                      groupValue: _preferSamples,
                      value: false,
                      onChanged: _updatePreferSamples,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
