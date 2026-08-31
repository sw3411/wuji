import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';

/// 一级导航围绕四个核心任务：首页、物品、位置、洞察。
/// 添加作为全局动作居中，不占用导航分支。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // body 延伸到底导下方，毛玻璃透出滚动内容。
      extendBody: true,
      bottomNavigationBar: _ArchiveNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onAdd: () => _showAddMenu(context),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('记录一件物品', style: AppTheme.title(cs.onSurface)),
              const SizedBox(height: 4),
              Text(
                '先快速记下来，品牌、票据和保修可以之后再补。',
                style: AppTheme.caption(cs.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              _AddChoice(
                icon: Icons.auto_awesome_outlined,
                title: '快速添加',
                subtitle: '输入一句话或拍照，让 AI 预填信息',
                color: cs.secondary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/ai/quick-add');
                },
              ),
              const SizedBox(height: 10),
              _AddChoice(
                icon: Icons.edit_note_rounded,
                title: '完整录入',
                subtitle: '手动填写名称、分类、位置与购买信息',
                color: cs.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/item/new');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveNavigationBar extends StatelessWidget {
  const _ArchiveNavigationBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // 悬浮毛玻璃胶囊：两侧留边 + 圆角 + 背景模糊 + 轻投影。
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xCC171D2A)
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x143B3535),
                      blurRadius: 18,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: '今日',
                  selected: selectedIndex == 0,
                  onTap: () => onSelect(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: '物品',
                  selected: selectedIndex == 1,
                  onTap: () => onSelect(1),
                ),
              ),
              Expanded(
                child: Center(
                  child: Semantics(
                    label: '添加物品',
                    button: true,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppTheme.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.place_outlined,
                  activeIcon: Icons.place_rounded,
                  label: '位置',
                  selected: selectedIndex == 2,
                  onTap: () => onSelect(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.insights_outlined,
                  activeIcon: Icons.insights_rounded,
                  label: '洞察',
                  selected: selectedIndex == 3,
                  onTap: () => onSelect(3),
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChoice extends StatelessWidget {
  const _AddChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.cardTitle(cs.onSurface)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.caption(cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
