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
            Icon(icon, size: 56, color: cs.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
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

  /// 低饱和暖灰色系（与 Anthropic 色板同族），柔和不刺眼。
  static const Map<ItemStatus, (Color, IconData)> _meta = {
    ItemStatus.inUse: (Color(0xFF7D8F66), Icons.check_circle_outline),
    ItemStatus.idle: (Color(0xFFC08A6E), Icons.pause_circle_outline),
    ItemStatus.stored: (Color(0xFF7E93AC), Icons.inventory_2_outlined),
    ItemStatus.lent: (Color(0xFF8D8399), Icons.logout),
    ItemStatus.repairing: (Color(0xFFC08368), Icons.build_outlined),
    ItemStatus.consumed: (Color(0xFF9C988E), Icons.remove_circle_outline),
    ItemStatus.lost: (Color(0xFF9C988E), Icons.help_outline),
    ItemStatus.discarded: (Color(0xFF9C988E), Icons.delete_outline),
    ItemStatus.sold: (Color(0xFF7E93AC), Icons.currency_exchange),
    ItemStatus.gifted: (Color(0xFFA57F92), Icons.card_giftcard),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _meta[status]!;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: color,
              fontWeight: FontWeight.w500,
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
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontSize: 14)),
          ),
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
                    size: 22,
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
    return Padding(
      // 区块间留足呼吸感：上 22 下 10。
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
                text, style: AppTheme.label(
                    Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
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
        style: (style ?? const TextStyle())
            .copyWith(color: const Color(0xFF6B8F87), fontWeight: FontWeight.w700),
      );
    }
    return Text(
      '日均 ${Money.formatCompact(dailyCostMinor, currency: currency)}',
      style: (style ?? const TextStyle())
          .copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// 加载中。
const loadingView = Center(child: CircularProgressIndicator());

/// 金额展示，等宽清晰。
class MoneyText extends StatelessWidget {
  const MoneyText(this.minorUnits,
      {super.key, this.currency = 'CNY', this.style, this.bold = false});

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

    // 低饱和警示色：粘土红（紧急）/ 赭金（留意）/ 橄榄绿（安心）。
    final (color, label) = left < 0
        ? (const Color(0xFFAD6A63), '已过保')
        : left <= 30
            ? (const Color(0xFFAD6A63), '保修剩 $left 天')
            : left <= 90
                ? (const Color(0xFF9C8A52), '保修剩 $left 天')
                : (const Color(0xFF7D8F66), '保修剩 $left 天');

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    final fg = solid ? Colors.white : color;
    final bg = solid ? color : color.withValues(alpha: 0.10);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: fg,
              fontWeight: solid ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
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
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              onPressed: onAction ?? () {},
            ),
    ));
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
  final cs = Theme.of(context).colorScheme;
  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: const TextStyle(fontSize: 13.5, height: 1.75),
    strong: TextStyle(
      fontSize: 16.5,
      fontWeight: FontWeight.w800,
      color: cs.primary,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    listBullet: const TextStyle(fontSize: 13.5, height: 1.75),
    h2: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
    h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}
