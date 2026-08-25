import 'package:flutter/material.dart';

/// 矩形树图数据块。
class TreemapTile {
  const TreemapTile({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final String label;
  final int value;
  final Color color;

  /// 可选副标题（金额等），与 label 一起展示。
  final String? subtitle;
}

class _LaidTile {
  const _LaidTile(this.tile, this.rect);

  final TreemapTile tile;
  final Rect rect;
}

/// 矩形树图：按数值比例切分区域，小块也能看清占比。
/// 布局采用递归二分：每轮把列表按约一半总值切成两组，
/// 沿容器长边按比例分割后递归，得到接近正方的分块。
class TreemapView extends StatelessWidget {
  const TreemapView({
    super.key,
    required this.tiles,
    this.height = 220,
    this.onTap,
  });

  final List<TreemapTile> tiles;
  final double height;
  final void Function(TreemapTile)? onTap;

  @override
  Widget build(BuildContext context) {
    final list = [...tiles]..sort((a, b) => b.value.compareTo(a.value));
    final total = list.fold<int>(0, (s, t) => s + (t.value <= 0 ? 1 : t.value));

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
              constraints.maxHeight.isFinite ? constraints.maxHeight : height,
            );
            final laid = _layout(
              list,
              Rect.fromLTWH(0, 0, size.width, size.height),
              total,
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final e in laid)
                  Positioned.fromRect(
                    rect: e.rect,
                    child: GestureDetector(
                      onTap: onTap == null ? null : () => onTap!(e.tile),
                      child: Container(
                        color: e.tile.color,
                        padding: const EdgeInsets.all(6),
                        alignment: Alignment.topLeft,
                        child: e.rect.width > 62 && e.rect.height > 34
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      e.tile.label,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: e.rect.width > 100 ? 13 : 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (e.tile.subtitle != null &&
                                      e.rect.height > 52)
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        e.tile.subtitle!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_LaidTile> _layout(List<TreemapTile> tiles, Rect rect, int total) {
    if (tiles.isEmpty || rect.width <= 0 || rect.height <= 0) return const [];
    if (tiles.length == 1) {
      return [_LaidTile(tiles.first, rect)];
    }
    // 贪心二分：找到累计值最接近一半的切点。
    final half = total / 2;
    int acc = 0;
    int split = 1;
    double bestDelta = double.infinity;
    for (int i = 0; i < tiles.length - 1; i++) {
      acc += tiles[i].value <= 0 ? 1 : tiles[i].value;
      final delta = (acc - half).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        split = i + 1;
      }
    }
    final head = tiles.sublist(0, split);
    final tail = tiles.sublist(split);
    final headTotal = head.fold<int>(
        0, (s, t) => s + (t.value <= 0 ? 1 : t.value));
    final tailTotal = tail.fold<int>(
        0, (s, t) => s + (t.value <= 0 ? 1 : t.value));
    final ratio = headTotal / (headTotal + tailTotal);

    // 沿长边分割，保持分块接近正方。
    late Rect headRect;
    late Rect tailRect;
    if (rect.width >= rect.height) {
      final w = rect.width * ratio;
      headRect = Rect.fromLTWH(rect.left, rect.top, w, rect.height);
      tailRect =
          Rect.fromLTWH(rect.left + w, rect.top, rect.width - w, rect.height);
    } else {
      final h = rect.height * ratio;
      headRect = Rect.fromLTWH(rect.left, rect.top, rect.width, h);
      tailRect =
          Rect.fromLTWH(rect.left, rect.top + h, rect.width, rect.height - h);
    }
    return [
      ..._layout(head, headRect, headTotal),
      ..._layout(tail, tailRect, tailTotal),
    ];
  }
}

/// 分类色板（Anthropic 强调色系扩展）。
List<Color> treemapPalette(Brightness brightness) {
  return const [
    Color(0xFFC98F78), // 柔赤陶
    Color(0xFF8A9B7A), // 灰绿
    Color(0xFF7E93AC), // 灰蓝
    Color(0xFFB08A72), // 柔赭
    Color(0xFF9A8FA5), // 灰紫
    Color(0xFFB08A9A), // 灰玫瑰
    Color(0xFF85807A), // 暖灰
    Color(0xFFA8A49B), // Cloudy
  ];
}
