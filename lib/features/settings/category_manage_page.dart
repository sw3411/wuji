import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/default_categories.dart';
import '../../domain/models/category.dart';

/// 分类管理：自定义分类增删改、系统分类隐藏、排序。
class CategoryManagePage extends ConsumerWidget {
  const CategoryManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];

    return Scaffold(
      appBar: AppBar(title: const Text('分类管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final list = [...categories];
          final moved = list.removeAt(oldIndex);
          list.insert(newIndex, moved);
          ref.read(categoryRepoProvider).reorder(list);
        },
        itemBuilder: (context, index) {
          final c = categories[index];
          return Card(
            key: ValueKey(c.id),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(CategoryIcons.of(c.icon), color: c.color),
              title: Text(
                c.name,
                style: TextStyle(
                    color: c.isHidden
                        ? Theme.of(context).colorScheme.outline
                        : null),
              ),
              subtitle: Text(
                c.isSystem ? '系统分类 · ${c.isHidden ? '已隐藏' : '可选'}' : '自定义',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (c.isSystem)
                    IconButton(
                      tooltip: c.isHidden ? '显示' : '隐藏',
                      icon: Icon(
                          c.isHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20),
                      onPressed: () => ref
                          .read(categoryRepoProvider)
                          .setHidden(c.id, !c.isHidden),
                    )
                  else
                    IconButton(
                      tooltip: '编辑',
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _edit(context, ref, c),
                    ),
                  if (!c.isSystem)
                    IconButton(
                      tooltip: '删除',
                      icon: Icon(Icons.delete_outline,
                          size: 20, color: Theme.of(context).colorScheme.error),
                      onPressed: () => _delete(context, ref, c),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Category? existing) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var icon = existing?.icon ?? 'category';
    var color = existing?.colorValue ?? 0xFF2E6E5C;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? '新建分类' : '编辑分类',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: existing == null,
                decoration: const InputDecoration(labelText: '分类名称 *'),
              ),
              const SizedBox(height: 16),
              const Text('图标'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoryIcons.map.keys.map((k) {
                  final selected = icon == k;
                  return InkWell(
                    onTap: () => setSheet(() => icon = k),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? Color(color).withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected ? Color(color) : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(CategoryIcons.of(k), color: Color(color)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('颜色'),
              Wrap(
                spacing: 8,
                children: [
                  0xFF2E6E5C, 0xFF4A6FA5, 0xFFB8860B, 0xFF8D6E9C,
                  0xFF7E93AC, 0xFFC08368, 0xFFA57F92, 0xFF6F6E69,
                ].map((v) {
                  final selected = color == v;
                  return GestureDetector(
                    onTap: () => setSheet(() => color = v),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(v),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.black87, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved != true) return;

    await ref.read(categoryRepoProvider).upsert(Category(
          id: existing?.id ??
              'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: nameCtrl.text.trim(),
          icon: icon,
          colorValue: color,
          sortOrder: existing?.sortOrder ?? 99,
          isSystem: false,
        ));
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Category c) async {
    final items = await ref.read(itemRepoProvider).getAll();
    final usedCount =
        items.where((i) => i.categoryId == c.id && !i.isDeleted).length;
    if (usedCount > 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('仍有 $usedCount 件物品使用该分类，请先在物品中修改分类')));
      return;
    }
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除「${c.name}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) {
      final deleted = await ref.read(categoryRepoProvider).delete(c.id);
      if (!deleted && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('系统分类不能删除，只能隐藏')));
      }
    }
  }
}
