import 'package:flutter/material.dart';

class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Pending synchronization',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Pending Sync',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
