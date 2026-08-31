import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/item.dart';
import '../../domain/services/duplicate_finder.dart';

/// 相似物品提醒卡：添加物品时提示“你可能已经有类似的了”。
/// name 为空或无匹配时隐藏。
class DupWarningCard extends ConsumerWidget {
  const DupWarningCard({
    super.key,
    required this.name,
    this.excludeId,
    this.brand,
  });

  final String name;
  final String? excludeId;
  final String? brand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmed = name.trim();
    if (trimmed.length < 2) return const SizedBox.shrink();
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final matches = DuplicateFinder.findSimilar(
      trimmed,
      items,
      excludeId: excludeId,
      brand: brand,
    );
    if (matches.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    const tone = AppTheme.ochre;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.content_copy, size: 15, color: tone),
              const SizedBox(width: 6),
              Text(
                '已经有相似的物品，还要买吗？',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: tone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final m in matches)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                onTap: () => context.push('/item/${m.item.id}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${m.item.name}（${m.item.status.label}，'
                        '${Money.formatCompact(m.item.purchasePrice)}）',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 15,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
