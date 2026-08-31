import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_config.dart';

/// 消息角色。
class AiMessage {
  AiMessage(this.role, this.content) : _rawContent = null;

  /// 直接使用已组装好的 content 结构（多模态消息用）。
  AiMessage.raw(this.role, this._rawContent) : content = '';

  final String role; // system / user / assistant

  /// 纯文本内容（多模态消息为空串）。
  final String content;

  /// 多模态原始 content（非空时优先于 [content]）。
  final Map<String, dynamic>? _rawContent;

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': _rawContent ?? content,
  };
}

/// AI 调用异常。
class AiException implements Exception {
  AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// OpenAI 兼容 API 客户端。
/// 适配 OpenAI / DeepSeek / GLM / Moonshot / 本地 Ollama 等所有
/// 提供 /chat/completions 接口的服务，用户只需配置 baseUrl/apiKey/model。
class AiClient {
  AiClient(this.config);

  final AiConfig config;

  Uri get _endpoint => Uri.parse(
    '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions',
  );

  /// 单轮/多轮对话。返回首个回复文本。
  Future<String> chat(
    List<AiMessage> messages, {
    bool jsonMode = false,
    int timeoutSeconds = 60,
  }) async {
    if (!config.isReady) {
      throw AiException('AI 未配置或未启用，请先在“我的 → AI 助手”中完成配置');
    }
    final body = <String, dynamic>{
      'model': config.model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': config.temperature,
    };
    if (jsonMode) {
      body['response_format'] = {'type': 'json_object'};
    }
    final data = await _post(body);
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiException('API 返回格式异常：缺少 choices');
    }
    final message = (choices.first as Map<String, dynamic>)['message'];
    final content = (message as Map<String, dynamic>?)?['content'];
    if (content == null || content.toString().isEmpty) {
      throw AiException('API 返回了空内容');
    }
    return content.toString();
  }

  /// 工具调用循环（OpenAI function calling 兼容协议）。
  /// AI 主动决定查询什么，[executor] 在本地执行并返回文本结果，
  /// 循环直到 AI 给出最终回答或达到 [maxTurns]。
  Future<String> chatWithTools(
    List<AiMessage> messages,
    List<Map<String, dynamic>> tools,
    Future<String> Function(String name, Map<String, dynamic> args) executor, {
    int maxTurns = 4,
  }) async {
    if (!config.isReady) {
      throw AiException('AI 未配置或未启用，请先在“我的 → AI 助手”中完成配置');
    }
    final conversation = [...messages.map((m) => m.toJson())];
    for (var turn = 0; turn < maxTurns; turn++) {
      final resp = await _post({
        'model': config.model,
        'messages': conversation,
        'temperature': config.temperature,
        'tools': tools,
        'tool_choice': 'auto',
      });
      final choices = resp['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw AiException('API 返回格式异常：缺少 choices');
      }
      final message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>?;
      if (message == null) {
        throw AiException('API 返回格式异常：缺少 message');
      }
      final toolCalls = message['tool_calls'] as List<dynamic>?;
      if (toolCalls == null || toolCalls.isEmpty) {
        final content = message['content'];
        if (content == null || content.toString().isEmpty) {
          throw AiException('API 返回了空内容');
        }
        return content.toString();
      }

      // 记录 assistant 的工具调用请求，再逐个回填工具结果。
      conversation.add({
        'role': 'assistant',
        'content': message['content'] ?? '',
        'tool_calls': toolCalls,
      });
      for (final call in toolCalls) {
        final fn =
            (call as Map<String, dynamic>)['function'] as Map<String, dynamic>?;
        final id = call['id'] as String? ?? '';
        final name = fn?['name'] as String? ?? '';
        var args = <String, dynamic>{};
        if (fn != null && fn['arguments'] != null) {
          try {
            final decoded = fn['arguments'];
            args = decoded is String
                ? (jsonDecode(decoded) as Map<String, dynamic>? ?? {})
                : (decoded as Map<String, dynamic>? ?? {});
          } catch (_) {
            args = {};
          }
        }
        String result;
        try {
          result = await executor(name, args);
        } catch (e) {
          result = '工具执行失败：$e';
        }
        conversation.add({
          'role': 'tool',
          'tool_call_id': id,
          'content': result.length > 6000 ? result.substring(0, 6000) : result,
        });
      }
    }
    throw AiException('工具调用轮次过多，请稍后简化重试');
  }

  /// 便捷方法：system + user 单轮。
  Future<String> ask(String system, String user, {bool jsonMode = false}) =>
      chat([
        AiMessage('system', system),
        AiMessage('user', user),
      ], jsonMode: jsonMode);

  /// 多模态单轮：user 消息附带一张 base64 图片（OpenAI 兼容 image_url 协议）。
  Future<String> askWithImage(
    String system,
    String user,
    String imageBase64, {
    String mime = 'image/jpeg',
    bool jsonMode = false,
  }) {
    final multimodal = {
      'role': 'user',
      'content': [
        {'type': 'text', 'text': user},
        {
          'type': 'image_url',
          'image_url': {'url': 'data:$mime;base64,$imageBase64'},
        },
      ],
    };
    return chat([
      AiMessage('system', system),
      AiMessage.raw('user', multimodal),
    ], jsonMode: jsonMode);
  }

  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    http.Response resp;
    try {
      resp = await http
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));
    } catch (e) {
      throw AiException('网络请求失败：$e');
    }
    if (resp.statusCode != 200) {
      String detail = '';
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          detail = err['message']?.toString() ?? '';
        }
      } catch (_) {}
      throw AiExceptionWithStatus(
        resp.statusCode,
        'API 返回 ${resp.statusCode}${detail.isEmpty ? '' : '：$detail'}',
      );
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}

/// 带状态码的异常，供调用方判断是否降级（如服务商不支持 tools）。
class AiExceptionWithStatus extends AiException {
  AiExceptionWithStatus(this.statusCode, String message) : super(message);

  final int statusCode;
}
