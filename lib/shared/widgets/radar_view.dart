import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 六维评分的键与中文标签（表单/详情共用）。
const List<(String, String)> kScoreDimensions = [
  ('scoreValue', '物品价值'),
  ('scoreUsage', '使用时间'),
  ('scoreFavorite', '喜爱程度'),
  ('scoreUtilization', '有效利用率'),
  ('scoreCost', '性价比'),
  ('scoreRetention', '保值度'),
];

/// 六维雷达图（自绘）：每个轴固定 0-10 绝对刻度，不做任何归一化；
/// 网格环为 2/4/6/8/10，顶点旁显示实际分值（null 不显示）。
class RadarView extends StatelessWidget {
  const RadarView({
    super.key,
    required this.labels,
    required this.values,
    this.height = 220,
  });

  final List<String> labels;
  final List<double?> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
            height,
          );
          return CustomPaint(
            size: size,
            painter: _RadarPainter(
              labels: labels,
              values: values,
              primary: cs.primary,
              grid: cs.outlineVariant,
              labelColor: cs.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.labels,
    required this.values,
    required this.primary,
    required this.grid,
    required this.labelColor,
  });

  final List<String> labels;
  final List<double?> values;
  final Color primary;
  final Color grid;
  final Color labelColor;

  static const double _max = 10;

  Offset _point(Offset center, double radius, double ratio, int index, int n) {
    final angle = -math.pi / 2 + index * 2 * math.pi / n;
    return Offset(
      center.dx + math.cos(angle) * radius * ratio,
      center.dy + math.sin(angle) * radius * ratio,
    );
  }

  Offset _dir(Offset center, Offset point) {
    final d = point - center;
    final len = d.distance == 0 ? 1.0 : d.distance;
    return d / len;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    if (n < 3) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;

    // 网格环：2/4/6/8/10，绝对刻度。
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = grid.withValues(alpha: 0.55);
    for (final step in [2, 4, 6, 8, 10]) {
      final path = Path();
      for (int i = 0; i <= n; i++) {
        final p = _point(center, radius, step / _max, i % n, n);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, ringPaint);
    }

    // 轴线。
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = grid.withValues(alpha: 0.35);
    for (int i = 0; i < n; i++) {
      final p = _point(center, radius, 1, i, n);
      canvas.drawLine(center, p, axisPaint);
    }

    // 数据多边形：v/10 绝对映射。
    final dataPath = Path();
    for (int i = 0; i <= n; i++) {
      final v = ((values[i % n] ?? 0).clamp(0.0, _max)).toDouble();
      final p = _point(center, radius, v / _max, i % n, n);
      i == 0 ? dataPath.moveTo(p.dx, p.dy) : dataPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = primary.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = primary,
    );

    final dotPaint = Paint()..color = primary;
    TextPainter scorePainter(String text) => TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    for (int i = 0; i < n; i++) {
      final v = values[i];
      final p = _point(
        center,
        radius,
        ((v ?? 0).clamp(0.0, _max)) / _max,
        i,
        n,
      );
      canvas.drawCircle(p, 3, dotPaint);

      // 顶点旁显示实际分值（未评分为 null 时不显示）。
      if (v != null && v > 0) {
        final tp = scorePainter(v.toInt().toString());
        final dir = _dir(center, p);
        final offset = Offset(
          p.dx + dir.dx * 12 - tp.width / 2,
          p.dy + dir.dy * 12 - tp.height / 2,
        );
        tp.paint(canvas, offset);
      }

      // 轴标签。
      final label = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 64);
      final edge = _point(center, radius, 1, i, n);
      final dir = _dir(center, edge);
      label.paint(
        canvas,
        Offset(
          edge.dx + dir.dx * 18 - label.width / 2,
          edge.dy + dir.dy * 18 - label.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.labels != labels ||
      oldDelegate.values != values ||
      oldDelegate.primary != primary;
}
