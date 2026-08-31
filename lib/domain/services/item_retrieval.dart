import '../models/enums.dart';
import '../models/item.dart';
import '../models/sale_record.dart';
import 'item_calculator.dart';

/// 检索结果：相关物品明细 + 全局统计摘要。
class RetrievedContext {
  const RetrievedContext({
    required this.matched,
    required this.hints,
    required this.digest,
  });

  /// 与问题相关的物品（按相关度排序，最多 topK）。
  final List<Item> matched;

  /// 命中的话题物品名（含上一轮话题延续）。
  final List<String> hints;

  /// 紧凑统计摘要文本（榜单/分类/闲置/保修等）。
  final String digest;
}

/// 本地 RAG 检索：纯函数，不联网。
///
/// 两路召回：
/// 1. 实体匹配——问题或话题中出现物品名/品牌/型号/标签/分类/位置；
/// 2. 统计摘要——最贵/日均最高/分类分布/闲置/保修到期等榜单，
///    覆盖“最贵的”“哪个分类花得多”这类非实体问题。
class ItemRetrieval {
  const ItemRetrieval._();

  static RetrievedContext retrieve(
    String question,
    List<Item> items,
    Map<String, SaleRecord> sales, {
    List<String> subjectHints = const [],
    int topK = 8,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final active = items.where((i) => !i.isDeleted).toList();
    final q = question.toLowerCase();

    final scores = <String, double>{};
    double scoreOf(Item i) => scores[i.id] ?? 0;

    void add(Item i, double v) => scores[i.id] = scoreOf(i) + v;

    for (final i in active) {
      final name = i.name.toLowerCase();
      if (name.length >= 2 && q.contains(name)) {
        // 名称越长越具体，得分越高。
        add(i, (10 + name.length).toDouble());
      }
      final brand = i.brand?.toLowerCase();
      if (brand != null && brand.length >= 2 && q.contains(brand)) {
        add(i, 6);
      }
      final model = i.model?.toLowerCase();
      if (model != null && model.length >= 2 && q.contains(model)) {
        add(i, 6);
      }
      for (final t in i.tags) {
        if (t.length >= 2 && q.contains(t.toLowerCase())) add(i, 4);
      }
      if (q.contains(i.categoryName)) add(i, 3);
      final loc = i.locationName?.toLowerCase();
      if (loc != null && loc.length >= 2 && q.contains(loc)) add(i, 3);
    }

    // 话题延续：上一轮讨论过的物品直接进入候选。
    for (final hint in subjectHints) {
      for (final i in active.where((e) => e.name == hint)) {
        add(i, 8);
      }
    }

    final matched = active.where((i) => scoreOf(i) > 0).toList()
      ..sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));

    final hints = subjectHints
        .where((h) => active.any((i) => i.name == h))
        .take(3)
        .toList();
    for (final m in matched.take(3)) {
      if (hints.length >= 3) break;
      if (!hints.contains(m.name)) hints.add(m.name);
    }

    return RetrievedContext(
      matched: matched.take(topK).toList(),
      hints: hints,
      digest: buildDigest(active, sales, now: now_),
    );
  }

  /// 紧凑统计摘要：覆盖榜单类/分布类问题，控制在 ~30 行。
  static String buildDigest(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final owned = items.where((i) => i.status.isOwned).toList();
    if (items.isEmpty) return '（暂无物品）';
    final buf = StringBuffer();

    final ownedTotal = owned.fold<int>(0, (s, i) => s + i.purchasePrice);
    buf.writeln(
      '总览：历史 ${items.length} 件；当前持有 ${owned.length} 件，购买总额 ${_yuan(ownedTotal)}元。',
    );

    final byPrice = [...owned]
      ..sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
    buf.writeln('最贵前5：${_namePrice(byPrice.take(5))}');

    final byDaily = [...owned]
      ..sort(
        (a, b) => ItemCalculator.dailyCost(
          b,
          sales[b.id],
          now: now_,
        ).compareTo(ItemCalculator.dailyCost(a, sales[a.id], now: now_)),
      );
    buf.writeln(
      '日均最高3：${byDaily.take(3).map((i) => '${i.name}(${_yuan(ItemCalculator.dailyCost(i, sales[i.id], now: now_))}元/天)').join('、')}',
    );

    final catMap = <String, List<Item>>{};
    for (final i in owned) {
      catMap.putIfAbsent(i.categoryName, () => []).add(i);
    }
    final cats = catMap.entries.toList()
      ..sort(
        (a, b) => b.value
            .fold<int>(0, (s, i) => s + i.purchasePrice)
            .compareTo(a.value.fold<int>(0, (s, i) => s + i.purchasePrice)),
      );
    buf.writeln(
      '分类金额top6：${cats.take(6).map((e) {
        final total = e.value.fold<int>(0, (s, i) => s + i.purchasePrice);
        return '${e.key}(${e.value.length}件/${_yuan(total)}元)';
      }).join('、')}',
    );

    final idle = items.where((i) => i.status == ItemStatus.idle).toList();
    if (idle.isNotEmpty) {
      buf.writeln(
        '闲置${idle.length}件：${idle.take(8).map((i) => i.name).join('、')}',
      );
    }

    final warranty = items.where((i) {
      final s = ItemCalculator.warrantyState(i, now: now_);
      return s == WarrantyState.expiringSoon || s == WarrantyState.expired;
    }).toList();
    if (warranty.isNotEmpty) {
      buf.writeln(
        '保修将到期/已过期：${warranty.take(8).map((i) {
          final end = i.effectiveWarrantyEndDate!;
          return '${i.name}(${end.month}/${end.day})';
        }).join('、')}',
      );
    }

    final monthStart = DateTime(now_.year, now_.month);
    final recent = items
        .where((i) => !i.purchaseDate.isBefore(monthStart))
        .toList();
    if (recent.isNotEmpty) {
      buf.writeln(
        '本月新增${recent.length}件：${recent.take(8).map((i) => i.name).join('、')}',
      );
    }

    final sold = items.where((i) => i.status == ItemStatus.sold).toList();
    if (sold.isNotEmpty) {
      final income = sold.fold<int>(
        0,
        (s, i) => s + (sales[i.id]?.netIncome ?? 0),
      );
      buf.writeln('已转卖${sold.length}件，回收净收入${_yuan(income)}元。');
    }

    return buf.toString().trimRight();
  }

  static String _yuan(int minor) => (minor / 100).toStringAsFixed(1);

  static String _namePrice(Iterable<Item> list) =>
      list.map((i) => '${i.name}(${_yuan(i.purchasePrice)}元)').join('、');
}
