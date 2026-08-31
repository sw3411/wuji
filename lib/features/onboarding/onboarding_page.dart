import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/repositories/settings_repository.dart';

/// 首次启动引导：用三个核心场景解释产品，并提供真实的备份恢复入口。
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _pages = [
    _OnboardingContent(
      icon: Icons.inventory_2_outlined,
      eyebrow: '记录',
      title: '把拥有的东西，\n变成清楚的档案',
      description: '名称、照片、价格和购买时间，先记最重要的信息，其余内容以后再补。',
    ),
    _OnboardingContent(
      icon: Icons.travel_explore_outlined,
      eyebrow: '找到与处理',
      title: '需要的时候找得到，\n该处理的时候有提醒',
      description: '记录具体存放位置，集中查看闲置、保修和维护事项，不再靠记忆翻找。',
    ),
    _OnboardingContent(
      icon: Icons.insights_outlined,
      eyebrow: '复盘',
      title: '看懂一次购买，\n留下了多少长期价值',
      description: '从使用时间、日均成本和转卖回收出发，形成更适合自己的消费判断。',
    ),
  ];

  late final PageController _controller;
  int _index = 0;
  bool _importing = false;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(settingsRepoProvider)
        .setBool(SettingsRepository.keyOnboarded, true);
    if (mounted) context.go('/home');
  }

  Future<void> _next() async {
    if (_isLast) {
      await _finish();
      return;
    }
    await _controller.nextPage(
      duration: AppTheme.motionSlow,
      curve: AppTheme.motionIn,
    );
  }

  Future<void> _importBackup() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: false,
    );
    final path = picked?.files.single.path;
    if (path == null || !mounted) return;

    setState(() => _importing = true);
    try {
      final service = ref.read(backupServiceProvider);
      final data = await service.validate(File(path));
      final itemCount = (data['items'] as List).length;
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('恢复这份备份？'),
          content: Text('将导入 $itemCount 件物品以及对应的位置、图片和设置。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认恢复'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final restored = await service.restore(data, overwrite: true);
      ref.invalidate(itemsProvider);
      ref.invalidate(locationsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(salesMapProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已恢复 $restored 件物品')));
      await _finish();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Row(
                  children: [
                    Text('物迹', style: AppTheme.display(cs.onSurface, size: 22)),
                    const Spacer(),
                    TextButton(
                      onPressed: _importing ? null : _finish,
                      child: const Text('跳过'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _OnboardingPanel(
                    content: _pages[index],
                    number: index + 1,
                    total: _pages.length,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: AppTheme.motionBase,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _index ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: index == _index
                                ? cs.primary
                                : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _importing ? null : _next,
                        icon: Icon(
                          _isLast
                              ? Icons.arrow_forward_rounded
                              : Icons.chevron_right_rounded,
                        ),
                        label: Text(_isLast ? '开始建立物品档案' : '继续'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _importing ? null : _importBackup,
                      icon: _importing
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore_outlined, size: 18),
                      label: Text(_importing ? '正在读取备份…' : '我有备份，直接恢复'),
                    ),
                    Text(
                      '无需注册登录 · 数据默认保存在本机',
                      style: AppTheme.caption(cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({
    required this.content,
    required this.number,
    required this.total,
  });

  final _OnboardingContent content;
  final int number;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: AspectRatio(
              aspectRatio: 1.32,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '$number / $total',
                      style: AppTheme.label(cs.onSurfaceVariant),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        content.icon,
                        size: 52,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(content.eyebrow, style: AppTheme.label(cs.primary)),
          const SizedBox(height: 10),
          Text(content.title, style: AppTheme.display(cs.onSurface, size: 30)),
          const SizedBox(height: 14),
          Text(content.description, style: AppTheme.body(cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
}
