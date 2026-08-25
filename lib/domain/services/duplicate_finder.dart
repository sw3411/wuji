import '../models/item.dart';

/// 相似物品检测：添加/解析物品时提示“你可能已经有类似的了”。
/// 纯本地计算，不依赖 AI。
class DuplicateFinder {
  /// 返回与 [name] 相似度达标的物品（分数降序，最多 [limit] 个）。
  ///
  /// 打分：完全同名 100；一方包含另一方 80；
  /// **AI 标签命中 90**（“华为手机”能命中标签为“手机”的 oppo find x8）；
  /// 二元组（相邻两字）重合率 ≥0.4 时按 1.2 倍折算；
  /// 品牌相同再 +15。≥50 分才入选。
  static List<DupMatch> findSimilar(
    String name,
    List<Item> items, {
    String? excludeId,
    String? brand,
    int limit = 3,
  }) {
    final target = _normalize(name);
    if (target.isEmpty) return const [];
    // 输入关键词：整串 + 按空格/斜杠切分的子词（“华为 手机”→[华为,手机]）。
    final keywords = <String>{target};
    for (final seg in name.trim().split(RegExp(r'[\s/、,，]'))) {
      final n = _normalize(seg);
      if (n.length >= 2) keywords.add(n);
    }
    final brandLower = brand?.trim().toLowerCase();
    final results = <DupMatch>[];
    for (final i in items) {
      if (i.isDeleted || !i.status.isOwned) continue;
      if (excludeId != null && i.id == excludeId) continue;
      final other = _normalize(i.name);
      if (other.isEmpty) continue;
      var score = 0;
      if (other == target) {
        score = 100;
      } else if (target.length >= 2 &&
          other.length >= 2 &&
          (other.contains(target) || target.contains(other))) {
        score = 80;
      } else {
        // AI 标签命中：任一关键词命中任一标签（相等或包含）。
        final tags = i.aiTags;
        if (tags != null && tags.isNotEmpty) {
          outer:
          for (final tag in tags) {
            final t = _normalize(tag);
            if (t.isEmpty) continue;
            for (final k in keywords) {
              if (t == k || t.contains(k) || k.contains(t)) {
                score = 90;
                break outer;
              }
            }
          }
        }
        if (score < 50) {
          final r = _bigramRatio(target, other);
          if (r >= 0.4) score = (120 * r).round();
        }
      }
      if (score > 0 &&
          brandLower != null &&
          brandLower.isNotEmpty &&
          (i.brand ?? '').toLowerCase() == brandLower) {
        score += 15;
      }
      if (score >= 50) results.add(DupMatch(i, score));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\-_/·,，。.()（）]'), '');

  /// 相邻两字组合的重合率（ Dice 系数 ）：中文物品名短，二元组够用。
  static double _bigramRatio(String a, String b) {
    if (a.length < 2 || b.length < 2) return 0;
    final setA = <String>{};
    for (var i = 0; i < a.length - 1; i++) {
      setA.add(a.substring(i, i + 2));
    }
    final setB = <String>{};
    for (var i = 0; i < b.length - 1; i++) {
      setB.add(b.substring(i, i + 2));
    }
    var hit = 0;
    for (final g in setA) {
      if (setB.contains(g)) hit++;
    }
    return 2 * hit / (setA.length + setB.length);
  }
}

/// 一条相似匹配结果。
class DupMatch {
  const DupMatch(this.item, this.score);

  final Item item;

  /// 0-115 的相似度分。
  final int score;
}
