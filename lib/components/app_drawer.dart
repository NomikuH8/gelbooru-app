import 'package:flutter/material.dart';
import 'package:gelbooru/screens/config_screen.dart';
import 'package:gelbooru/screens/start_screen.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ListTile(),
          ListTile(
            title: const Text("Home"),
            onTap: () => Get.off(() => const StartScreen()),
          ),
          ListTile(
            title: const Text("Settings"),
            onTap: () => Get.off(() => const ConfigScreen()),
          )
        ],
      ),
    );
  }
}
