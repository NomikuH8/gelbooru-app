import 'package:flutter/material.dart';
import 'package:gelbooru/components/tag_autocomplete.dart';
import 'package:gelbooru/constants/search_constants.dart';
import 'package:gelbooru/screens/start_screen.dart';
import 'package:get/get.dart';

class SearchHelperScreen extends StatefulWidget {
  const SearchHelperScreen({super.key});

  @override
  State<SearchHelperScreen> createState() => _SearchHelperScreenState();
}

class _SearchHelperScreenState extends State<SearchHelperScreen> {
  final _finalSearchController = TextEditingController();
  var _dropdownOrderByValue = SearchConstants.sortOptions.first;
  var _dropdownOrderingValue = "asc";
  var _dropdownRatingValue = "General";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Helper"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _finalSearchController.text = "",
                    child: const Text("Clear"),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: _finalSearchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Final search"),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.off(
                      () => StartScreen(
                        defaultSearch: _finalSearchController.text,
                      ),
                    );
                  },
                  label: const Text("Search"),
                  icon: const Icon(Icons.search_outlined),
                  iconAlignment: IconAlignment.end,
                )
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  TagAutocomplete(
                    isRemover: false,
                    targetController: _finalSearchController,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TagAutocomplete(
                    isRemover: true,
                    targetController: _finalSearchController,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DropdownMenu(
                          width: (MediaQuery.of(context).size.width / 3) - 16.0,
                          label: const Text("Order by"),
                          initialSelection: _dropdownOrderByValue,
                          onSelected: (value) {
                            setState(() {
                              _dropdownOrderByValue = value!;
                            });
                          },
                          dropdownMenuEntries: SearchConstants.sortOptions.map(
                            (value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: DropdownMenu(
                          width: (MediaQuery.of(context).size.width / 3) - 16.0,
                          label: const Text("Ordering"),
                          initialSelection: _dropdownOrderingValue,
                          onSelected: (value) {
                            setState(() {
                              _dropdownOrderingValue = value!;
                            });
                          },
                          dropdownMenuEntries: ["asc", "desc"].map(
                            (value) {
                              return DropdownMenuEntry(
                                  value: value,
                                  label: value == "asc"
                                      ? "Ascending"
                                      : "Descending");
                            },
                          ).toList(),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          child: const Text("Add"),
                          onPressed: () {
                            _finalSearchController.text +=
                                " sort:$_dropdownOrderByValue:$_dropdownOrderingValue";
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownMenu(
                          onSelected: (value) {
                            setState(() {
                              _dropdownRatingValue = value ?? "";
                            });
                          },
                          width: (MediaQuery.of(context).size.width / 2) - 16.0,
                          label: const Text("Rating"),
                          dropdownMenuEntries: [
                            "General",
                            "Questionable",
                            "Sensitive",
                            "Explicit"
                          ].map(
                            (rating) {
                              return DropdownMenuEntry(
                                value: rating.toLowerCase(),
                                label: rating,
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _finalSearchController.text.contains("rating:")
                                  ? null
                                  : () {
                                      _finalSearchController.text +=
                                          " rating:$_dropdownRatingValue";
                                    },
                          child: const Text("Add"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
