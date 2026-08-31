import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../core/utils/formatters.dart';

/// 空状态占位。
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 34, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// 状态徽标：颜色 + 图标 + 文本，不只依赖颜色表达状态。
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.compact = false});

  final ItemStatus status;
  final bool compact;

  /// 状态同时通过文字与图标表达，不只依赖颜色。
  static const Map<ItemStatus, (Color, IconData)> _meta = {
    ItemStatus.inUse: (AppTheme.okGreen, Icons.check_circle_outline),
    ItemStatus.idle: (AppTheme.ochre, Icons.pause_circle_outline),
    ItemStatus.stored: (AppTheme.steel, Icons.inventory_2_outlined),
    ItemStatus.lent: (AppTheme.mauve, Icons.logout),
    ItemStatus.repairing: (AppTheme.rose, Icons.build_outlined),
    ItemStatus.consumed: (AppTheme.taupe, Icons.remove_circle_outline),
    ItemStatus.lost: (AppTheme.taupe, Icons.help_outline),
    ItemStatus.discarded: (AppTheme.taupe, Icons.delete_outline),
    ItemStatus.sold: (AppTheme.steel, Icons.currency_exchange),
    ItemStatus.gifted: (AppTheme.rose, Icons.card_giftcard),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _meta[status]!;
    return _Stamp(
      color: color,
      icon: icon,
      text: status.label,
      compact: compact,
    );
  }
}

/// 戳记标签：档案体系统一的小方章——4px 圆角、发丝边框、底色微染。
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.color,
    required this.text,
    this.icon,
    this.compact = false,
    this.solid = false,
  });

  final Color color;
  final String text;
  final IconData? icon;
  final bool compact;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.stampRadius),
        border: Border.all(
          color: solid ? Colors.transparent : color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 12, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: compact ? 11.5 : 12.5,
              height: 1.25,
              color: fg,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用信息行。
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null || v.trim().isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: cs.outline),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// 数字突出展示的小卡片。
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    this.onTap,
    this.accent = false,
  });

  final String label;
  final String value;
  final String? subValue;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTheme.label(cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTheme.bigNumber(
                    accent ? cs.primary : cs.onSurface,
                    size: 24,
                  ),
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(subValue!, style: AppTheme.caption(cs.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 区块标题。
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 26, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(text, style: AppTheme.title(cs.onSurface))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 日均成本展示：负数显示为“日均收益”。
class DailyCostText extends StatelessWidget {
  const DailyCostText({
    super.key,
    required this.dailyCostMinor,
    this.currency = 'CNY',
    this.style,
  });

  final int dailyCostMinor;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (dailyCostMinor < 0) {
      return Text(
        '日均收益 ${Money.formatCompact(dailyCostMinor.abs(), currency: currency)}',
        style: (style ?? const TextStyle()).copyWith(
          color: AppTheme.sage,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Text(
      '日均 ${Money.formatCompact(dailyCostMinor, currency: currency)}',
      style: (style ?? const TextStyle()).copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// 加载中。
const loadingView = Center(child: CircularProgressIndicator());

/// 金额展示，等宽清晰。
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.minorUnits, {
    super.key,
    this.currency = 'CNY',
    this.style,
    this.bold = false,
  });

  final int minorUnits;
  final String currency;
  final TextStyle? style;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      Money.format(minorUnits, currency: currency),
      style: (style ?? const TextStyle(fontSize: 14)).copyWith(
        fontWeight: bold ? FontWeight.w700 : null,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 保修状态徽标：剩余 ≤30 天红色、30-90 天黄色、>90 天绿色；无保修不显示。
class WarrantyChip extends StatelessWidget {
  const WarrantyChip(this.item, {super.key, this.compact = false});

  final Item item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final end = item.effectiveWarrantyEndDate;
    if (end == null) return const SizedBox.shrink();
    final today = Fmt.dayOnly(DateTime.now());
    final endDay = Fmt.dayOnly(end);
    final left = Fmt.daysBetween(today, endDay);

    // 状态语义色：红（过保/紧急）/ 琥珀（留意）/ 绿（安心）。
    final (color, label) = left < 0
        ? (AppTheme.warnRed, '已过保')
        : left <= 30
        ? (AppTheme.warnAmber, '保修剩 $left 天')
        : left <= 90
        ? (AppTheme.ochre, '保修剩 $left 天')
        : (AppTheme.okGreen, '保修剩 $left 天');

    return _Stamp(
      color: color,
      icon: Icons.shield_outlined,
      text: label,
      compact: compact,
    );
  }
}

/// 统一规格的胶囊徽标：与 StatusChip 同高，可指定前景/背景组合。
/// 绿底白字（solid=true）或浅底彩字（默认）。
class PillChip extends StatelessWidget {
  const PillChip(
    this.text, {
    super.key,
    this.color = AppTheme.green,
    this.solid = false,
    this.compact = false,
    this.icon,
  });

  final String text;
  final Color color;
  final bool solid;
  final bool compact;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _Stamp(
      color: color,
      icon: icon,
      text: text,
      compact: compact,
      solid: solid,
    );
  }
}

/// 展示 4 秒自动消失的 SnackBar（带 controller 兜底强制关闭，
/// 避免个别机型/场景下带 action 的 SnackBar 不自动收起）。
void showAutoToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
  // 兜底：无论框架计时器是否工作，4 秒后主动收起。
  final messenger = ScaffoldMessenger.of(context);
  Future.delayed(const Duration(seconds: 4), () {
    messenger.hideCurrentSnackBar();
  });
}

/// AI 诊断类内容的统一 Markdown 排版规则：
/// - **加粗** → 放大加粗的绿色数字/关键词（对应 Prompt 中“关键金额用**包裹”的约定）
/// - 正文 13.5/1.8，标题 15.5，列表同级
MarkdownStyleSheet digestMarkdownStyle(BuildContext context) {
  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: const TextStyle(fontSize: 14.5, height: 1.7),
    strong: const TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    listBullet: const TextStyle(fontSize: 14.5, height: 1.7),
    // 引用块不带底色，融入画布。
    blockquoteDecoration: const BoxDecoration(),
    code: const TextStyle(fontSize: 12.5),
    h2: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    h3: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
  );
}

/// 页面主数字卡：一眼说明当前规模，不用装饰压过内容。
class SceneCard extends StatefulWidget {
  const SceneCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.subLabel,
    this.subValue,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });

  final String label;
  final String value;
  final String? unit;
  final String? subLabel;
  final String? subValue;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard> {
  bool _played = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 纯数字才做滚动动画（带“万”等单位的直接显示）。
    final n = int.tryParse(widget.value);
    return Container(
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 7),
              Text(widget.label, style: AppTheme.label(cs.onPrimaryContainer)),
              if (widget.trailing != null) ...[
                const Spacer(),
                widget.trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (n != null)
                        CountUpText(
                          target: n,
                          style: AppTheme.bigNumber(
                            cs.onPrimaryContainer,
                            size: 44,
                          ),
                          enabled: !_played,
                          onDone: () => _played = true,
                        )
                      else
                        Text(
                          widget.value,
                          style: AppTheme.bigNumber(
                            cs.onPrimaryContainer,
                            size: 40,
                          ),
                        ),
                      if (widget.unit != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 5),
                          child: Text(
                            unitext,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.subValue != null) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTheme.caption(cs.onPrimaryContainer),
                children: [
                  if (widget.subLabel != null && widget.subLabel!.isNotEmpty)
                    TextSpan(text: widget.subLabel),
                  TextSpan(
                    text: widget.subValue!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get unitext => widget.unit ?? '';
}

/// 数值滚动：900ms 内从 0 计数到目标，decelerate 收尾。
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.target,
    required this.style,
    required this.enabled,
    this.onDone,
  });

  final int target;
  final TextStyle style;
  final bool enabled;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Text('$target', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: AppTheme.motionIn,
      onEnd: onDone,
      builder: (context, v, _) => Text(v.round().toString(), style: style),
    );
  }
}

class AiTypingDots extends StatefulWidget {
  const AiTypingDots({super.key, this.size = 8});

  final double size;

  @override
  State<AiTypingDots> createState() => _AiTypingDotsState();
}

class _AiTypingDotsState extends State<AiTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
            final bounce = (t < 0.5 ? t : 1 - t) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, -4 * bounce),
                child: Icon(
                  Icons.circle,
                  size: widget.size,
                  color: color.withValues(alpha: 0.4 + 0.6 * bounce),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 悬浮毛玻璃卡：真背景模糊 + 半透明面 + 顶部高光 + 发丝边 + 柔投影。
/// 用于金刚位等画布上的少数强调元素（每屏控制在个位数，保证性能）。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 18,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // 悬浮感：柔和下投阴影（包裹在模糊层外，避免被裁掉）。
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.22)
                : const Color(0x1420242A),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              // 玻璃面：竖向光泽渐变（顶部更亮）。
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.78),
                        Colors.white.withValues(alpha: 0.52),
                      ],
              ),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
    if (onTap == null) return body;
    return GestureDetector(onTap: onTap, child: body);
  }
}
