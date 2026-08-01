import 'package:flutter/material.dart';

class Label {
  final String id;
  final String? createdBy;
  final String name;
  final Color color;
  final bool canEdit;

  const Label({
    required this.id,
    required this.name,
    this.createdBy,
    this.color = Colors.blue,
    this.canEdit = true,
  });

  Label copyWith({
    String? id,
    String? createdBy,
    String? name,
    Color? color,
    bool? canEdit,
  }) {
    return Label(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      color: color ?? this.color,
      canEdit: canEdit ?? this.canEdit,
    );
  }
}
