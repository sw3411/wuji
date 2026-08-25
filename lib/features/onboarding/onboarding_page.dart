import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/repositories/settings_repository.dart';

/// 首次启动引导页。
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const _pages = [
    (Icons.inventory_2_rounded, '记录所有拥有的物品',
        '买了什么、花了多少钱、什么时候买的，一目了然'),
    (Icons.place_outlined, '快速找到物品存放位置',
        '树状位置管理，从“家”到“衣柜第二层”都能记录'),
    (Icons.query_stats_rounded, '追踪日均使用成本',
        '每件物品每天花多少钱，转卖后实际损耗多少，清晰可见'),
    (Icons.all_inclusive_rounded, '管理物品生命周期',
        '保修提醒、闲置提醒、转卖保值率，全程陪伴'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = PageController();
    final cs = Theme.of(context).colorScheme;

    Future<void> finish() async {
      await ref
          .read(settingsRepoProvider)
          .setBool(SettingsRepository.keyOnboarded, true);
      if (context.mounted) context.go('/home');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                children: _pages
                    .map((p) => Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppTheme.green.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(p.$1,
                                    size: 56, color: AppTheme.green),
                              ),
                              const SizedBox(height: 40),
                              Text(p.$2,
                                  style: AppTheme.display(
                                      Theme.of(context).colorScheme.onSurface,
                                      size: 30)),
                              const SizedBox(height: 16),
                              Text(
                                p.$3,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            _PageDots(controller: controller, count: _pages.length),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: finish,
                      child: const Text('立即开始'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      finish();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('可在“我的 → 数据备份”中导入备份文件')),
                      );
                    },
                    child: const Text('导入备份'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '无需注册登录，数据保存在本机',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.controller, required this.count});

  final PageController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients &&
                controller.position.hasContentDimensions
            ? controller.page ?? 0
            : 0.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final active = page.round() == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppTheme.green : AppTheme.inkSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
