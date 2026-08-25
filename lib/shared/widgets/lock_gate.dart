import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/constants/app_info.dart';
import '../../core/security/app_lock.dart';

/// 应用锁门卫：包在 MaterialApp builder 外层，
/// 设置了应用锁且未解锁时遮住全部内容。
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  bool _authenticating = false;

  /// 最近一次解锁时间：生物识别弹窗关闭后会跟一次 resumed 回调，
  /// 若此时重新上锁会造成“刚验证成功又被锁回去”的假象，需短暂豁免。
  DateTime? _unlockedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 冷启动直接弹一次认证。
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 回到前台时重新上锁。两类豁免：
    // 1) 认证进行中（弹窗显示/关闭过程会触发 resumed）；
    // 2) 刚解锁 3 秒内（认证结果回调与生命周期回调的先后顺序不确定）。
    if (state != AppLifecycleState.resumed || _authenticating) return;
    final t = _unlockedAt;
    if (t != null &&
        DateTime.now().difference(t) < const Duration(seconds: 3)) {
      return;
    }
    if (ref.read(appSettingsProvider).appLockEnabled) {
      ref.read(appUnlockedProvider.notifier).state = false;
    }
  }

  Future<void> _tryUnlock() async {
    if (!ref.read(appSettingsProvider).appLockEnabled) return;
    if (ref.read(appUnlockedProvider)) return;
    if (_authenticating) return;
    _authenticating = true;
    _authError = null;
    try {
      final ok = await AppLock.authenticate('解锁 ${AppInfo.appName}');
      if (!mounted) return;
      if (ok) {
        _unlockedAt = DateTime.now();
        ref.read(appUnlockedProvider.notifier).state = true;
      } else {
        setState(() => _authError = '验证未通过，请再试一次');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _authError = '验证出错：$e');
      }
    } finally {
      _authenticating = false;
    }
  }

  String? _authError;

  @override
  Widget build(BuildContext context) {
    final locked =
        ref.watch(appSettingsProvider).appLockEnabled && !ref.watch(appUnlockedProvider);
    if (!locked) return widget.child;
    // 用 Stack 盖住而不是替换 child：路由栈保持挂载，解锁后回到原页面。
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        Positioned.fill(
          child: _LockScreen(
            onUnlock: _tryUnlock,
            authenticating: _authenticating,
            error: _authError,
          ),
        ),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({
    required this.onUnlock,
    required this.authenticating,
    required this.error,
  });

  final Future<void> Function() onUnlock;
  final bool authenticating;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: cs.surface,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.inventory_2_outlined, size: 40, color: cs.primary),
                ),
                const SizedBox(height: 20),
                Text(AppInfo.appName,
                    style: AppTheme.display(cs.onSurface, size: 28)),
                const SizedBox(height: 8),
                Text('物品数据已保护',
                    style: AppTheme.caption(cs.onSurfaceVariant)),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: authenticating ? null : onUnlock,
                  icon: authenticating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.fingerprint),
                  label: Text(authenticating ? '验证中…' : '解锁'),
                ),
                if (error != null && error!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: AppTheme.caption(cs.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
