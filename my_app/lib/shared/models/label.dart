import 'package:flutter/material.dart';

class Label {
  final String id;
  final String name;
  final Color color;

  const Label({
    required this.id,
    required this.name,
    this.color = Colors.blue,
  });

  Label copyWith({String? id, String? name, Color? color}) {
    return Label(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
