class CMSSearchResult {
  const CMSSearchResult({
    required this.id,
    required this.name,
    required this.category,
    required this.professors,
  });

  final int id;
  final String name;
  final String category;
  final List<String> professors;

  factory CMSSearchResult.fromJson(Map<String, dynamic> json) {
    final professorsJson = json['contacts'] as List<dynamic>;
    final professors = professorsJson
        .map((e) => e['fullname'] as String)
        .toList(growable: false);
    return CMSSearchResult(
      id: json['id'] as int,
      name: json['displayname'] as String,
      category: json['categoryname'] as String,
      professors: professors,
    );
  }
}
