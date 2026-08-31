import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../shared/widgets/common.dart';

/// 年度账单：本地年度数据大屏 + AI 年度总结 + 分享。
class YearlyReportPage extends ConsumerStatefulWidget {
  const YearlyReportPage({super.key});

  @override
  ConsumerState<YearlyReportPage> createState() => _YearlyReportPageState();
}

class _YearlyReportPageState extends ConsumerState<YearlyReportPage> {
  int _year = DateTime.now().year;
  bool _loading = false;
  String? _aiText;
  String? _aiTextYear;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCached();
  }

  Future<void> _loadCached() async {
    final json = await ref
        .read(settingsRepoProvider)
        .getJson('ai_yearly_$_year');
    if (json == null || !mounted) return;
    final text = json['text'] as String?;
    if (text != null && text.isNotEmpty) {
      setState(() {
        _aiText = text;
        _aiTextYear = '$_year';
      });
    }
  }

  Future<void> _generate() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
      final sales =
          ref.read(salesMapProvider).valueOrNull ??
          const <String, SaleRecord>{};
      final text = await ref
          .read(aiServiceProvider)
          .yearlyReport(items, sales, year: _year);
      await ref.read(settingsRepoProvider).setJson('ai_yearly_$_year', {
        'text': text,
      });
      if (mounted) {
        setState(() {
          _aiText = text;
          _aiTextYear = '$_year';
        });
      }
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
    final currency = ref.watch(appSettingsProvider).currency;
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final d = _YearData.of(items, sales, _year);
    final aiReady = config.isReady;

    return Scaffold(
      appBar: AppBar(
        title: Text('$_year 年度账单'),
        actions: [
          if (_aiText != null && _aiTextYear == '$_year')
            IconButton(
              tooltip: '分享',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(
                '【物迹 $_year 年度账单】\n'
                '全年新增 ${d.newCount} 件 · 花费 ${Money.formatCompact(d.newSpendCents, currency: currency)}\n'
                '最贵：${d.topName}\n'
                '转卖 ${d.soldCount} 件 · 净回收 ${Money.formatCompact(d.saleIncomeCents, currency: currency)}\n\n'
                '${_aiText!.replaceAll('**', '')}',
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 年份切换
          Row(
            children: [
              for (final y in [DateTime.now().year, DateTime.now().year - 1])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$y 年'),
                    selected: _year == y,
                    onSelected: (_) => setState(() {
                      _year = y;
                      _aiText = null;
                      _aiTextYear = null;
                      _error = null;
                      _loadCached();
                    }),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 场景卡：年度总花费（页面唯一渐变主视觉）。
          SceneCard(
            label: '$_year 年购买总额',
            value: d.newSpendCents == 0
                ? '0'
                : Money.format(d.newSpendCents, currency: currency),
            subLabel: '',
            subValue: '新增 ${d.newCount} 件物品',
          ),
          const SizedBox(height: 10),

          // 三格指标
          Row(
            children: [
              Expanded(
                child: _statTile(
                  cs,
                  '最贵一笔',
                  d.topName == null ? '—' : d.topName!,
                  sub: d.topPriceCents == null
                      ? null
                      : Money.formatCompact(
                          d.topPriceCents!,
                          currency: currency,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  cs,
                  '转卖净回收',
                  Money.formatCompact(d.saleIncomeCents, currency: currency),
                  sub: '共 ${d.soldCount} 件',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  cs,
                  '现已闲置',
                  d.idleCount == 0 ? '0 件' : '${d.idleCount} 件',
                  sub: d.idleCount == 0 ? '很克制' : '考虑处置',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 月度柱状（简单文本柱）
          if (d.monthMax > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('月度花费', style: AppTheme.label(cs.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    for (var m = 0; m < 12; m++)
                      if (d.monthlyCents[m] > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${m + 1}月',
                                  style: AppTheme.caption(cs.onSurfaceVariant),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: d.monthlyCents[m] / d.monthMax,
                                    minHeight: 8,
                                    backgroundColor: cs.surfaceContainerHighest,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  Money.formatCompact(
                                    d.monthlyCents[m],
                                    currency: currency,
                                  ),
                                  textAlign: TextAlign.right,
                                  style: AppTheme.caption(cs.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // AI 年度总结
          if (aiReady) ...[
            if (_aiText == null || _aiTextYear != '$_year')
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _loading ? null : _generate,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: Center(child: AiTypingDots(size: 5)),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(_loading ? '生成中…' : 'AI 年度总结'),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          Text('年度总结', style: AppTheme.cardTitle(cs.onSurface)),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: '重新生成',
                            onPressed: _loading ? null : _generate,
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MarkdownBody(
                        data: _aiText!,
                        styleSheet: digestMarkdownStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('生成失败：$_error', style: AppTheme.caption(cs.error)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _statTile(ColorScheme cs, String label, String value, {String? sub}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.label(cs.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bigNumber(cs.onSurface, size: 16),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.caption(cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 年度本地数据（纯函数）。
class _YearData {
  const _YearData(
    this.newCount,
    this.newSpendCents,
    this.monthlyCents,
    this.monthMax,
    this.topName,
    this.topPriceCents,
    this.soldCount,
    this.saleIncomeCents,
    this.idleCount,
  );

  final int newCount;
  final int newSpendCents;
  final List<int> monthlyCents;
  final int monthMax;
  final String? topName;
  final int? topPriceCents;
  final int soldCount;
  final int saleIncomeCents;
  final int idleCount;

  static _YearData of(
    List<Item> items,
    Map<String, SaleRecord> sales,
    int year,
  ) {
    final active = items.where((i) => !i.isDeleted).toList();
    final inYear = active.where((i) => i.purchaseDate.year == year).toList();
    final monthly = List<int>.filled(12, 0);
    for (final i in inYear) {
      monthly[i.purchaseDate.month - 1] += i.purchasePrice;
    }
    final top = [...inYear]
      ..sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
    final sold = active
        .where(
          (i) =>
              i.status == ItemStatus.sold &&
              sales[i.id] != null &&
              sales[i.id]!.saleDate.year == year,
        )
        .toList();
    return _YearData(
      inYear.length,
      inYear.fold<int>(0, (s, i) => s + i.purchasePrice),
      monthly,
      monthly.reduce((a, b) => a > b ? a : b),
      top.isEmpty ? null : top.first.name,
      top.isEmpty ? null : top.first.purchasePrice,
      sold.length,
      sold.fold<int>(0, (s, i) => s + (sales[i.id]?.netIncome ?? 0)),
      inYear.where((i) => i.status == ItemStatus.idle).length,
    );
  }
}
