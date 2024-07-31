import 'package:flutter/material.dart';

class PoolList extends StatelessWidget {
  const PoolList({super.key, required this.list, required this.onTap});

  final List<String> list;
  final void Function(String entry) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index]),
          onTap: () => onTap(list[index]),
        );
      },
    );
  }
}
