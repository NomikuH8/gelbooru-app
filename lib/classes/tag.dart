class Tag {
  final int id;
  final String name;
  final int count;
  final int type;
  final int ambiguous;

  const Tag(
      {required this.id,
      required this.name,
      required this.count,
      required this.type,
      required this.ambiguous});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "name": String name,
        "count": int count,
        "type": int type,
        "ambiguous": int ambiguous,
      } =>
        Tag(id: id, name: name, count: count, type: type, ambiguous: ambiguous),
      _ => throw const FormatException("Failed to load tag."),
    };
  }
}
