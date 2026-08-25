import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_client.dart';
import '../../core/ai/ai_config.dart';

/// AI 助手设置：OpenAI 兼容 API 配置。
class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  late final TextEditingController _baseUrl;
  late final TextEditingController _apiKey;
  late final TextEditingController _model;
  late bool _enabled;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(aiConfigProvider);
    _baseUrl = TextEditingController(text: config.baseUrl);
    _apiKey = TextEditingController(text: config.apiKey);
    _model = TextEditingController(text: config.model);
    _enabled = config.enabled;
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _apiKey.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final config = ref.read(aiConfigProvider).copyWith(
          baseUrl: _baseUrl.text.trim(),
          apiKey: _apiKey.text.trim(),
          model: _model.text.trim(),
          enabled: _enabled,
        );
    await ref.read(aiConfigProvider.notifier).save(config);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('AI 配置已保存')));
    }
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      final config = ref.read(aiConfigProvider).copyWith(
            baseUrl: _baseUrl.text.trim(),
            apiKey: _apiKey.text.trim(),
            model: _model.text.trim(),
            enabled: true,
          );
      final reply = await AiClient(config)
          .ask('你是一个连通性测试助手。', '请回复：连接成功');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('连接成功：$reply')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('测试失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 助手')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '隐私提示',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '使用 AI 功能时，会把相关物品数据发送到你配置的 API 服务商。'
                    '数据不经任何第三方中转，直接从本机发送。不配置则完全不发送。',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('启用 AI 功能'),
            subtitle: const Text('关闭后隐藏 AI 入口'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _baseUrl,
            decoration: const InputDecoration(
              labelText: 'API 地址（Base URL）',
              hintText: '例如 https://api.openai.com/v1',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: '填写你的密钥',
              prefixIcon: Icon(Icons.key),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _model,
            decoration: const InputDecoration(
              labelText: '模型名称',
              hintText: '例如 gpt-4o-mini / deepseek-chat / glm-4-flash',
              prefixIcon: Icon(Icons.smart_toy_outlined),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持所有 OpenAI 兼容接口：OpenAI、DeepSeek、智谱 GLM、Moonshot、'
            '本地 Ollama（地址填 http://localhost:11434/v1）等。',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _test,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.wifi_tethering),
                  label: const Text('测试连接'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _AiConfigCopy on AiConfig {
  AiConfig copyWith({
    bool? enabled,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) =>
      AiConfig(
        enabled: enabled ?? this.enabled,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        temperature: temperature,
      );
}
