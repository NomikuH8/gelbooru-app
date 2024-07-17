import 'package:flutter/material.dart';
import 'package:gelbooru/apis/autocomplete_api.dart';
import 'package:gelbooru/classes/autocomplete_entry.dart';

class TagAutocomplete extends StatefulWidget {
  const TagAutocomplete(
      {super.key, required this.targetController, required this.isRemover});

  final bool isRemover;
  final TextEditingController targetController;

  @override
  State<TagAutocomplete> createState() => _TagAutocompleteState();
}

class _TagAutocompleteState extends State<TagAutocomplete> {
  late TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<AutocompleteEntry>(
      displayStringForOption: (option) => option.label,
      onSelected: (option) {
        final value = "${widget.isRemover ? "-" : ""}${option.value}";
        widget.targetController.text += " $value";
        textEditingController.text = "";
      },
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable.empty();
        }

        final entries = await AutocompleteApi.getAutocompleteEntries(
          textEditingValue.text,
        );

        return entries.where(
          (entry) => entry.value.contains(
            textEditingValue.text.split(" ").last,
          ),
        );
      },
      fieldViewBuilder:
          (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
        textEditingController = fieldTextEditingController;
        return TextField(
          controller: fieldTextEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            label: Text(
              !widget.isRemover ? "Search wanted tags" : "Search unwanted tags",
            ),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
