class AutocompleteEntry {
  final String type;
  final String label;
  final String value;
  final String postCount;
  final String category;

  const AutocompleteEntry({
    required this.type,
    required this.label,
    required this.value,
    required this.postCount,
    required this.category,
  });

  factory AutocompleteEntry.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "type": String type,
        "label": String label,
        "value": String value,
        "post_count": String postCount,
        "category": String category,
      } =>
        AutocompleteEntry(
          type: type,
          label: label,
          value: value,
          postCount: postCount,
          category: category,
        ),
      _ => throw const FormatException("Failed to load AutocompleteEntry."),
    };
  }
}
