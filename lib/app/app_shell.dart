import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_info.dart';
import 'theme.dart';

/// 底部导航外壳：首页/物品/添加(中央圆钮)/统计/我的。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    Widget navItem(IconData icon, IconData activeIcon, String label, int index,
        {bool center = false}) {
      if (center) {
        return GestureDetector(
          onTap: () => _showAddMenu(context),
          child: Semantics(
            label: '添加物品',
            button: true,
            child: Container(
              width: 54,
              height: 54,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: AppTheme.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        );
      }
      final selected = navigationShell.currentIndex == index;
      final color = selected ? cs.primary : cs.onSurfaceVariant;
      return InkWell(
        onTap: () => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 选中时图标背后加胶囊底，一眼可辨。
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: selected
                    ? BoxDecoration(
                        color: AppTheme.green,
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 22,
                  color: selected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11, color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: dark ? AppTheme.darkSurface : AppTheme.lightSurface,
        child: Row(
          children: [
            Expanded(child: Center(child: navItem(Icons.home_outlined, Icons.home_rounded, '首页', 0))),
            Expanded(child: Center(child: navItem(Icons.inventory_2_outlined, Icons.inventory_2_rounded, '物品', 1))),
            Expanded(child: Center(child: navItem(Icons.add, Icons.add, AppInfo.appName, -1, center: true))),
            Expanded(child: Center(child: navItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, '统计', 2))),
            Expanded(child: Center(child: navItem(Icons.person_outline, Icons.person_rounded, '我的', 3))),
          ],
        ),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text('添加物品',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('手动添加'),
              subtitle: const Text('填写表单，信息最完整', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/item/new');
              },
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('AI 一句话添加'),
              subtitle: const Text('说说物品，AI 帮你填表', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/quick-add');
              },
            ),
          ],
        ),
      ),
    );
  }
}
