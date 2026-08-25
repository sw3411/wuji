/// 产品级常量集中配置，方便后续统一修改。
class AppInfo {
  AppInfo._();

  /// 产品名称，全局唯一出处。
  static const String appName = '物迹';

  static const String appTagline = '看见自己拥有什么，理解每一次消费的长期价值';

  static const String version = '0.1.0';

  /// 备份文件格式版本，恢复时校验。
  static const int backupVersion = 1;

  static const String backupFileExtension = 'wuji.json';
}
