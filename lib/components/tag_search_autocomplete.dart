import 'package:flutter/material.dart';
import 'package:gelbooru/apis/autocomplete_api.dart';
import 'package:gelbooru/classes/autocomplete_entry.dart';

class TagSearchAutocomplete extends StatefulWidget {
  const TagSearchAutocomplete({super.key, required this.onSubmitted});

  final void Function(String submitted) onSubmitted;

  @override
  State<TagSearchAutocomplete> createState() => _TagSearchAutocompleteState();
}

class _TagSearchAutocompleteState extends State<TagSearchAutocomplete> {
  var _lastSearchBeforeSelect = "";
  var _lastTagAutocompleted = "";
  late TextEditingController textEditingController;

  Icon _getIconForCategory(String category) {
    var icon = Icons.tag;
    var color = Colors.amber[400];

    icon = switch (category) {
      "copyright" => Icons.copyright_outlined,
      "metadata" => Icons.message_outlined,
      "artist" => Icons.person_outlined,
      _ => Icons.tag_outlined
    };

    color = switch (category) {
      "copyright" => Colors.green[400],
      "metadata" => Colors.yellow[400],
      "artist" => Colors.red[400],
      _ => Colors.blue[800]
    };

    return Icon(
      icon,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<AutocompleteEntry>(
      displayStringForOption: (option) => option.value,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    onSelected(option);
                  },
                  child: ListTile(
                    title: Text(option.label),
                    trailing: _getIconForCategory(option.category),
                  ),
                );
              },
            ),
          ),
        );
      },
      onSelected: (option) {
        final value = option.value;

        _lastSearchBeforeSelect += " $value";

        _lastSearchBeforeSelect = _lastSearchBeforeSelect.trim();

        textEditingController.text = _lastSearchBeforeSelect;

        // widget.onSubmitted(textEditingController.text);
      },
      optionsBuilder: (textEditingValue) async {
        final lastWord = textEditingValue.text.split(" ").last;
        final lastWordWithoutMinus = lastWord.replaceAll("-", "");

        if (textEditingValue.text.isEmpty ||
            _lastTagAutocompleted == lastWordWithoutMinus) {
          return const Iterable.empty();
        }

        final entries = await AutocompleteApi.getAutocompleteEntries(
          lastWordWithoutMinus,
        );

        _lastTagAutocompleted = lastWordWithoutMinus;

        return entries.where(
          (entry) => entry.value.contains(lastWordWithoutMinus),
        );
      },
      fieldViewBuilder: (
        context,
        fieldTextEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        textEditingController = fieldTextEditingController;
        return TextField(
          controller: fieldTextEditingController,
          onChanged: (value) {
            _lastSearchBeforeSelect = value;
          },
          onSubmitted: widget.onSubmitted,
          focusNode: focusNode,
          decoration: InputDecoration(
            label: const Text("Autocomplete Search"),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () => widget.onSubmitted(textEditingController.text),
              icon: const Icon(Icons.search_outlined),
            ),
          ),
        );
      },
    );
  }
}
