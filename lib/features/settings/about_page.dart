import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/constants/app_info.dart';

/// 关于页。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(AppInfo.appName,
                style: AppTheme.display(
                    Theme.of(context).colorScheme.onSurface,
                    size: 34)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text('v${AppInfo.version}',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              AppInfo.appTagline,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('本地优先'),
                  subtitle: Text('数据保存在本机，无需联网、无需注册', style: TextStyle(fontSize: 12)),
                ),
                Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.cloud_off_outlined),
                  title: Text('云端功能规划中'),
                  subtitle: Text('账号、云同步、多设备将在后续版本提供', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
