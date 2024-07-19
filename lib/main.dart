import 'package:flutter/material.dart';
import 'package:gelbooru/controllers/account_controller.dart';
import 'package:gelbooru/screens/start_screen.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  MediaKit.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(3, 90, 199, 1.0),
          brightness: Brightness.dark,
        ),
      ),
      home: const StartScreen(
        defaultSearch: "",
      ),
    );
  }
}
