import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/dup_warning.dart';

/// AI 购买评估：下单前的“值不值得买”把关。
class PurchaseEvalPage extends ConsumerStatefulWidget {
  const PurchaseEvalPage({super.key});

  @override
  ConsumerState<PurchaseEvalPage> createState() => _PurchaseEvalPageState();
}

class _PurchaseEvalPageState extends ConsumerState<PurchaseEvalPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _months = 24;
  UsageFrequency? _frequency = UsageFrequency.weekly;
  String? _categoryId;
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// 本地即时预估：预计单次使用成本。
  (double uses, double cpu)? get _estimate {
    final price = Money.parse(_priceCtrl.text);
    if (price == null || price <= 0 || _frequency == null) return null;
    final uses = _frequency!.perMonth * _months;
    if (uses < 1) return (1, price / 100);
    return (uses, price / uses / 100);
  }

  Future<void> _evaluate() async {
    final name = _nameCtrl.text.trim();
    final price = Money.parse(_priceCtrl.text);
    if (name.isEmpty || price == null || price <= 0 || _frequency == null) {
      showAutoToast(context, '请填写名称与有效价格');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
      final categories =
          ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
      final category = categories.where((c) => c.id == _categoryId).firstOrNull;
      final text = await ref
          .read(aiServiceProvider)
          .purchaseEvaluation(
            name: name,
            priceCents: price,
            expectMonths: _months,
            frequency: _frequency!,
            categoryName: category?.name,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            items: items,
            budgetCents: ref.read(appSettingsProvider).monthlyBudgetCents,
          );
      if (mounted) setState(() => _result = text);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final config = ref.watch(aiConfigProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final estimate = _estimate;

    return Scaffold(
      appBar: AppBar(title: const Text('AI 购买评估')),
      body: !config.isReady
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '配置 AI 后，下单前先问一句“值不值得买”',
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => context.push('/settings/ai'),
                    child: const Text('去配置'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '想买什么 *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                    hintText: '例如：戴森 HD16 吹风机',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameCtrl,
                  builder: (context, v, _) => DupWarningCard(name: v.text),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '预期价格（元）*',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // 预计使用时长
                DropdownButtonFormField<int>(
                  value: _months,
                  decoration: const InputDecoration(
                    labelText: '预计用多久',
                    prefixIcon: Icon(Icons.hourglass_bottom_outlined),
                  ),
                  items: [3, 6, 12, 24, 36, 60, 120]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m >= 12
                                ? '${(m / 12).toStringAsFixed(m % 12 == 0 ? 0 : 1)} 年'
                                : '$m 个月',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _months = v ?? _months),
                ),
                const SizedBox(height: 14),

                // 预计频次
                DropdownButtonFormField<UsageFrequency>(
                  value: _frequency,
                  decoration: const InputDecoration(
                    labelText: '预计使用频次',
                    prefixIcon: Icon(Icons.speed_outlined),
                  ),
                  items: UsageFrequency.values
                      .map(
                        (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _frequency = v ?? _frequency),
                ),
                const SizedBox(height: 14),

                // 品类（可选）
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: '品类（可选）',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('不选择')),
                    ...categories.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '补充说明（可选）',
                    hintText: '例如：主要是为了替代旧的那台',
                  ),
                ),

                // 本地预估条
                if (estimate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '预计使用 ${estimate.$1.toStringAsFixed(0)} 次，'
                              '单次使用成本约 ${estimate.$2.toStringAsFixed(1)} 元',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _evaluate,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_loading ? '评估中…' : '值不值得买？'),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text('评估失败：$_error', style: AppTheme.caption(cs.error)),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: MarkdownBody(
                        data: _result!,
                        styleSheet: digestMarkdownStyle(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
