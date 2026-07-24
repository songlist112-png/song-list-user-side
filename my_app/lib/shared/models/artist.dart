class Artist {
  final String id;
  final String name;

  const Artist({
    required this.id,
    required this.name,
  });

  Artist copyWith({String? id, String? name}) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
