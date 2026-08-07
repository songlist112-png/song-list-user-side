import 'dart:io';

import 'package:flutter/material.dart';

class SupportAttachmentPreview extends StatelessWidget {
  const SupportAttachmentPreview({
    required this.path,
    required this.name,
    this.height = 150,
    this.onRemove,
    super.key,
  });

  final String path;
  final String name;
  final double height;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Attached image: $name',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.file(
            File(path),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                tooltip: 'Remove image',
                icon: const Icon(Icons.close_rounded),
              ),
            ),
        ],
      ),
    ),
  );
}
