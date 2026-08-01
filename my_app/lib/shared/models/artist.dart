class Artist {
  final String id;
  final String? createdBy;
  final String name;
  final bool canEdit;

  const Artist({
    required this.id,
    this.createdBy,
    required this.name,
    this.canEdit = true,
  });

  Artist copyWith({
    String? id,
    String? createdBy,
    String? name,
    bool? canEdit,
  }) {
    return Artist(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      canEdit: canEdit ?? this.canEdit,
    );
  }
}
