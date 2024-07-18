import 'package:flutter/material.dart';

class TagSearchRaw extends StatefulWidget {
  const TagSearchRaw({
    super.key,
    this.defaultText = "",
    required this.onSubmitted,
  });

  final String defaultText;
  final void Function(String search) onSubmitted;

  @override
  State<TagSearchRaw> createState() => _TagSearchRawState();
}

class _TagSearchRawState extends State<TagSearchRaw> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.text = widget.defaultText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: const Text("Raw Search"),
        suffixIcon: IconButton(
          onPressed: () => widget.onSubmitted(_searchController.text),
          icon: const Icon(Icons.search_outlined),
        ),
      ),
    );
  }
}
