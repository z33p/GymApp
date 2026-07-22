import 'package:flutter/material.dart';

import '../domain/fauna_rank.dart';

class FaunaMascot extends StatelessWidget {
  const FaunaMascot({required this.rank, this.compact = false, super.key});

  final FaunaRank rank;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mascotSize = compact ? 44.0 : 88.0;
    final titleStyle =
        compact ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall;

    return Semantics(
      label: '${rank.tier.label}, ${rank.formPoints} pontos de Forma',
      container: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: mascotSize,
            height: mascotSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(rank.tier.mascot,
                style: TextStyle(fontSize: compact ? 25 : 48)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rank.tier.label,
                  style: titleStyle?.copyWith(fontWeight: FontWeight.bold)),
              Text('${rank.formPoints} Forma • ${rank.legacyPoints} Legado'),
            ],
          ),
        ],
      ),
    );
  }
}
