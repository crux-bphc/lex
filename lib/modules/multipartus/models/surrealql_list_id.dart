typedef SurrealQlListIdParser<T> = List<T> Function(String text);

class SurrealQlListId<T> {
  final List<T> items;

  SurrealQlListId(this.items);

  SurrealQlListId.parse(SurrealQlListIdParser<T> parser, String text)
      : items = parser(text) {
    if (items.isEmpty) {
      throw ArgumentError("could not parse id $text");
    }
  }
}

SurrealQlListIdParser<T> surrealQlListIdParser<T>(
  String tableName,
  T Function(String) parser,
) {
  final regexp = RegExp('^$tableName:\\[(.*)\\]\$');

  return (String text) {
    final match = regexp.firstMatch(text);
    final group = match?.group(1);

    if (group == null) return [];

    return group.split(",").map((item) => parser(item.trim())).toList();
  };
}
