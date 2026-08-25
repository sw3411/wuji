import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// 解锁状态（冷启动 / 回到前台时重置为 false）。
final appUnlockedProvider = StateProvider<bool>((ref) => false);

/// 生物识别 / 设备锁认证。
class AppLock {
  AppLock._();

  static final _auth = LocalAuthentication();

  /// 设备是否可用人脸/指纹/设备密码锁。
  static Future<bool> isAvailable() async {
    try {
      final can = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return can || deviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// 认证。允许回退到设备密码（biometricOnly=false），避免用户被锁死。
  /// 异常直接抛给调用方展示真实错误，不吞掉。
  static Future<bool> authenticate(String reason) {
    return _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
