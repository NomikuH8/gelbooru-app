import 'package:flutter/material.dart';
import 'package:gelbooru/controllers/account_controller.dart';
import 'package:gelbooru/screens/start_screen.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StartScreen(
        defaultSearch: "",
      ),
    );
  }
}
